"""Prolonged sound marks transliterator."""

from __future__ import annotations

from collections.abc import Iterable
from enum import IntFlag

from ..chars import Char

__all__ = ["Transliterator"]


class CharType(IntFlag):
    """Character type classification flags."""

    OTHER = 0x00
    HIRAGANA = 0x20
    KATAKANA = 0x40
    ALPHABET = 0x60
    DIGIT = 0x80
    EITHER = 0xA0

    # Additional flags
    HALFWIDTH = 1 << 0
    VOWEL_ENDED = 1 << 1
    HATSUON = 1 << 2
    SOKUON = 1 << 3
    PROLONGED_SOUND_MARK = 1 << 4

    # Combined types
    HALFWIDTH_DIGIT = DIGIT | HALFWIDTH
    FULLWIDTH_DIGIT = DIGIT
    HALFWIDTH_ALPHABET = ALPHABET | HALFWIDTH
    FULLWIDTH_ALPHABET = ALPHABET
    ORDINARY_HIRAGANA = HIRAGANA | VOWEL_ENDED
    ORDINARY_KATAKANA = KATAKANA | VOWEL_ENDED
    ORDINARY_HALFWIDTH_KATAKANA = KATAKANA | VOWEL_ENDED | HALFWIDTH

    def is_alnum(self) -> bool:
        """Check if character type is alphanumeric."""
        t = self & 0xE0
        return t == CharType.ALPHABET or t == CharType.DIGIT

    def is_halfwidth(self) -> bool:
        """Check if character type is halfwidth."""
        return bool(self & CharType.HALFWIDTH)

    @classmethod
    def from_codepoint(cls, codepoint: int) -> CharType:
        """Get the character type for a given Unicode codepoint."""
        # Halfwidth digits
        if 0x30 <= codepoint <= 0x39:
            return CharType.HALFWIDTH_DIGIT

        # Fullwidth digits
        if 0xFF10 <= codepoint <= 0xFF19:
            return CharType.FULLWIDTH_DIGIT

        # Halfwidth alphabets
        if (0x41 <= codepoint <= 0x5A) or (0x61 <= codepoint <= 0x7A):
            return CharType.HALFWIDTH_ALPHABET

        # Fullwidth alphabets
        if (0xFF21 <= codepoint <= 0xFF3A) or (0xFF41 <= codepoint <= 0xFF5A):
            return CharType.FULLWIDTH_ALPHABET

        # Special characters
        if codepoint in SPECIALS:
            return SPECIALS[codepoint]

        # Hiragana
        if (0x3041 <= codepoint <= 0x309C) or codepoint == 0x309F:
            return CharType.ORDINARY_HIRAGANA

        # Katakana
        if (0x30A1 <= codepoint <= 0x30FA) or (0x30FD <= codepoint <= 0x30FF):
            return CharType.ORDINARY_KATAKANA

        # Halfwidth katakana
        if (0xFF66 <= codepoint <= 0xFF6F) or (0xFF71 <= codepoint <= 0xFF9F):
            return CharType.ORDINARY_HALFWIDTH_KATAKANA

        return CharType.OTHER


# Special character mappings
SPECIALS = {
    0xFF70: CharType.KATAKANA | CharType.PROLONGED_SOUND_MARK | CharType.HALFWIDTH,  # ｰ
    0x30FC: CharType.EITHER | CharType.PROLONGED_SOUND_MARK,  # ー
    0x3063: CharType.HIRAGANA | CharType.SOKUON,  # っ
    0x3093: CharType.HIRAGANA | CharType.HATSUON,  # ん
    0x30C3: CharType.KATAKANA | CharType.SOKUON,  # ッ
    0x30F3: CharType.KATAKANA | CharType.HATSUON,  # ン
    0xFF6F: CharType.KATAKANA | CharType.SOKUON | CharType.HALFWIDTH,  # ｯ
    0xFF9D: CharType.KATAKANA | CharType.HATSUON | CharType.HALFWIDTH,  # ﾝ
}

# Hyphen-like characters that could be prolonged sound marks
HYPHEN_LIKE_CHARS = {
    "\u002d",
    "\u2010",
    "\u2014",
    "\u2015",
    "\u2212",
    "\uff0d",
    "\uff70",
    "\u30fc",
}


class Transliterator:
    """Prolonged sound marks transliterator.

    This transliterator handles the replacement of hyphen-like characters with
    appropriate prolonged sound marks (ー or ｰ) when they appear after Japanese
    characters that can be prolonged.
    """

    skip_already_transliterated_chars: bool
    allow_prolonged_hatsuon: bool
    allow_prolonged_sokuon: bool
    replace_prolonged_marks_following_alnums: bool
    prolongables: CharType

    def __init__(
        self,
        *,
        skip_already_transliterated_chars: bool = False,
        allow_prolonged_hatsuon: bool = False,
        allow_prolonged_sokuon: bool = False,
        replace_prolonged_marks_following_alnums: bool = False,
    ) -> None:
        """Initialize the transliterator with options.

        :param skip_already_transliterated_chars: Skip chars that have been transliterated. Defaults to False.
        :param allow_prolonged_hatsuon: Allow prolonging hatsuon characters (ん/ン). Defaults to False.
        :param allow_prolonged_sokuon: Allow prolonging sokuon characters (っ/ッ). Defaults to False.
        :param replace_prolonged_marks_following_alnums: Whether to replace prolonged voice marks following an
               alphanumeric. Defaults to False.
        """
        self.skip_already_transliterated_chars = skip_already_transliterated_chars
        self.allow_prolonged_hatsuon = allow_prolonged_hatsuon
        self.allow_prolonged_sokuon = allow_prolonged_sokuon
        self.replace_prolonged_marks_following_alnums = replace_prolonged_marks_following_alnums

        # Build prolongable character types
        self.prolongables = CharType.VOWEL_ENDED | CharType.PROLONGED_SOUND_MARK
        if allow_prolonged_hatsuon:
            self.prolongables |= CharType.HATSUON
        if allow_prolonged_sokuon:
            self.prolongables |= CharType.SOKUON

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Transliterate prolonged sound marks."""
        offset = 0
        processed_chars_in_lookahead = False
        lookahead_buf: list[Char] = []
        last_non_prolonged_char: tuple[Char, CharType] | None = None

        for char in input_chars:
            if lookahead_buf:
                if char.c in HYPHEN_LIKE_CHARS:
                    if char.source is not None:
                        processed_chars_in_lookahead = True
                    lookahead_buf.append(char)
                    continue
                # Process buffered characters
                prev_non_prolonged_char = last_non_prolonged_char
                codepoint = ord(char.c[0]) if char.c else -1
                last_non_prolonged_char = (char, CharType.from_codepoint(codepoint))

                # Check if we should replace with hyphens for alphanumerics
                if (prev_non_prolonged_char is None or prev_non_prolonged_char[1].is_alnum()) and (
                    not self.skip_already_transliterated_chars or not processed_chars_in_lookahead
                ):
                    if (
                        last_non_prolonged_char[1].is_halfwidth()
                        if prev_non_prolonged_char is None
                        else prev_non_prolonged_char[1].is_halfwidth()
                    ):
                        replacement = "\u002d"
                    else:
                        replacement = "\uff0d"

                    for buffered_char in lookahead_buf:
                        yield Char(c=replacement, offset=offset, source=buffered_char)
                        offset += len(replacement)
                else:
                    # Just pass through the buffered characters
                    for buffered_char in lookahead_buf:
                        yield buffered_char.with_offset(offset)
                        offset += len(buffered_char.c)

                lookahead_buf = []
                yield char.with_offset(offset)
                offset += len(char.c)
                codepoint = ord(char.c[0]) if char.c else -1
                last_non_prolonged_char = (char, CharType.from_codepoint(codepoint))
                processed_chars_in_lookahead = False
                continue

            # Check if this is a hyphen-like character that might be a prolonged sound mark
            if char.c in HYPHEN_LIKE_CHARS:
                should_process = not self.skip_already_transliterated_chars or not char.is_transliterated()
                if should_process and last_non_prolonged_char is not None:
                    if self.prolongables & last_non_prolonged_char[1]:
                        replacement = "\uff70" if last_non_prolonged_char[1].is_halfwidth() else "\u30fc"
                        yield Char(c=replacement, offset=offset, source=char)
                        offset += len(replacement)
                        continue
                    else:
                        # Check if we should buffer for alphanumeric replacement
                        if self.replace_prolonged_marks_following_alnums and last_non_prolonged_char[1].is_alnum():
                            lookahead_buf.append(char)
                            continue
            else:
                # Update last non-prolonged character
                codepoint = ord(char.c[0]) if char.c else -1
                last_non_prolonged_char = (char, CharType.from_codepoint(codepoint))

            # Default: pass through the character
            yield char.with_offset(offset)
            offset += len(char.c)
