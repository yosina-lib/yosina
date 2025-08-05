"""Japanese iteration marks transliterator."""

from __future__ import annotations

from collections.abc import Iterable

from ..chars import Char

__all__ = ["Transliterator"]

# Iteration mark characters
ITERATION_MARKS = {
    "ゝ",  # hiragana repetition
    "ゞ",  # hiragana voiced repetition
    "〱",  # vertical hiragana repetition
    "〲",  # vertical hiragana voiced repetition
    "ヽ",  # katakana repetition
    "ヾ",  # katakana voiced repetition
    "〳",  # vertical katakana repetition
    "〴",  # vertical katakana voiced repetition
    "々",  # kanji repetition
}

# Semi-voiced characters
SEMI_VOICED_CHARS = {
    # Hiragana semi-voiced
    "ぱ",
    "ぴ",
    "ぷ",
    "ぺ",
    "ぽ",
    # Katakana semi-voiced
    "パ",
    "ピ",
    "プ",
    "ペ",
    "ポ",
}

# Special characters that cannot be repeated
HATSUON_CHARS = {
    "ん",
    "ン",
}

SOKUON_CHARS = {
    "っ",
    "ッ",
}

# Voicing mappings for hiragana (unvoiced -> voiced)
HIRAGANA_VOICING = {
    "か": "が",
    "き": "ぎ",
    "く": "ぐ",
    "け": "げ",
    "こ": "ご",
    "さ": "ざ",
    "し": "じ",
    "す": "ず",
    "せ": "ぜ",
    "そ": "ぞ",
    "た": "だ",
    "ち": "ぢ",
    "つ": "づ",
    "て": "で",
    "と": "ど",
    "は": "ば",
    "ひ": "び",
    "ふ": "ぶ",
    "へ": "べ",
    "ほ": "ぼ",
    "う": "ゔ",
    "ゝ": "ゞ",
}

# Voicing mappings for katakana (unvoiced -> voiced)
KATAKANA_VOICING = {
    "カ": "ガ",
    "キ": "ギ",
    "ク": "グ",
    "ケ": "ゲ",
    "コ": "ゴ",
    "サ": "ザ",
    "シ": "ジ",
    "ス": "ズ",
    "セ": "ゼ",
    "ソ": "ゾ",
    "タ": "ダ",
    "チ": "ヂ",
    "ツ": "ヅ",
    "テ": "デ",
    "ト": "ド",
    "ハ": "バ",
    "ヒ": "ビ",
    "フ": "ブ",
    "ヘ": "ベ",
    "ホ": "ボ",
    "ウ": "ヴ",
    "ワ": "ヷ",
    "ヰ": "ヸ",
    "ヱ": "ヹ",
    "ヲ": "ヺ",
    "ヽ": "ヾ",
}

# Derived set of all voiced characters (values from voicing maps)
VOICED_CHARS = set(HIRAGANA_VOICING.values()) | set(KATAKANA_VOICING.values())

# Reverse voicing maps (voiced -> unvoiced)
HIRAGANA_UNVOICING = {v: k for k, v in HIRAGANA_VOICING.items()}
KATAKANA_UNVOICING = {v: k for k, v in KATAKANA_VOICING.items()}


def is_hiragana(char: str) -> bool:
    """Check if a character is hiragana."""
    if not char:
        return False
    codepoint = ord(char[0])
    return 0x3041 <= codepoint <= 0x309F


def is_katakana(char: str) -> bool:
    """Check if a character is katakana."""
    if not char:
        return False
    codepoint = ord(char[0])
    return 0x30A0 <= codepoint <= 0x30FF


def is_kanji(char: str) -> bool:
    """Check if a character is kanji."""
    if not char:
        return False
    codepoint = ord(char[0])
    # Basic CJK Unified Ideographs
    return 0x4E00 <= codepoint <= 0x9FFF


class Transliterator:
    """Japanese iteration marks transliterator.

    This transliterator handles the replacement of Japanese iteration marks:
    - ゝ (hiragana repetition): Repeat previous hiragana if valid
    - ゞ (hiragana voiced repetition): Repeat previous hiragana with voicing if possible
    - 〱 (vertical hiragana repetition): Same as ゝ
    - 〲 (vertical hiragana voiced repetition): Same as ゞ
    - ヽ (katakana repetition): Repeat previous katakana if valid
    - ヾ (katakana voiced repetition): Repeat previous katakana with voicing if possible
    - 〳 (vertical katakana repetition): Same as ヽ
    - 〴 (vertical katakana voiced repetition): Same as ヾ
    - 々 (kanji repetition): Repeat previous kanji

    Invalid combinations remain unchanged.
    """

    skip_already_transliterated_chars: bool

    def __init__(self, *, skip_already_transliterated_chars: bool = False) -> None:
        """Initialize the transliterator with options.

        :param skip_already_transliterated_chars: Skip chars that have been transliterated. Defaults to False.
        """
        self.skip_already_transliterated_chars = skip_already_transliterated_chars

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Transliterate Japanese iteration marks."""
        offset = 0
        last_char: Char | None = None

        for char in input_chars:
            # Check if this is an iteration mark
            if char.c in ITERATION_MARKS:
                should_process = not self.skip_already_transliterated_chars or not char.is_transliterated()

                if should_process and last_char is not None:
                    replacement = self._get_replacement(char.c, last_char.c)
                    if replacement is not None:
                        yield Char(c=replacement, offset=offset, source=char)
                        offset += len(replacement)
                        # Don't update last_char - the replacement becomes the new last char
                        last_char = Char(c=replacement, offset=offset - len(replacement), source=char)
                        continue

            # Default: pass through the character
            yield char.with_offset(offset)
            offset += len(char.c)

            # Update last character (skip empty sentinel characters)
            if char.c:
                last_char = char.with_offset(offset - len(char.c))

    def _get_replacement(self, mark: str, prev_char: str) -> str | None:
        """Get the replacement character for an iteration mark.

        :param mark: The iteration mark character
        :param prev_char: The previous character
        :returns: The replacement character, or None if invalid
        """
        # Check if previous character cannot be repeated
        if prev_char in SEMI_VOICED_CHARS or prev_char in HATSUON_CHARS or prev_char in SOKUON_CHARS:
            return None

        if mark in ("ゝ", "〱"):  # Hiragana repetition marks
            if is_hiragana(prev_char):
                if prev_char in VOICED_CHARS:
                    # Voiced character followed by unvoiced iteration mark
                    return HIRAGANA_UNVOICING.get(prev_char, None)
                return prev_char
            return None

        elif mark in ("ゞ", "〲"):  # Hiragana voiced repetition marks
            if is_hiragana(prev_char):
                if prev_char in VOICED_CHARS:
                    # Voiced character followed by voiced iteration mark
                    return prev_char
                # Try to add voicing
                return HIRAGANA_VOICING.get(prev_char, None)
            return None

        elif mark in ("ヽ", "〳"):  # Katakana repetition marks
            if is_katakana(prev_char):
                if prev_char in VOICED_CHARS:
                    # Voiced character followed by unvoiced iteration mark
                    return KATAKANA_UNVOICING.get(prev_char, None)
                return prev_char
            return None

        elif mark in ("ヾ", "〴"):  # Katakana voiced repetition marks
            if is_katakana(prev_char):
                if prev_char in VOICED_CHARS:
                    # Voiced character followed by voiced iteration mark
                    return prev_char
                # Try to add voicing
                return KATAKANA_VOICING.get(prev_char, None)
            return None

        elif mark == "々":
            # Kanji repetition - only repeat if previous is kanji
            return prev_char if is_kanji(prev_char) else None

        return None
