"""Character array building and string conversion utilities."""

from __future__ import annotations

from collections.abc import Iterable
from dataclasses import dataclass

__all__ = ["Char", "build_char_list", "from_chars"]


@dataclass
class Char:
    """Represents a character with metadata for transliteration."""

    c: str
    """The character string"""
    offset: int
    """The offset position in the original text"""
    source: Char | None = None
    """Optional reference to the original character"""

    def with_offset(self, new_offset: int) -> Char:
        """Return a new Char with the specified offset."""
        return Char(c=self.c, offset=new_offset, source=self)

    def is_transliterated(self) -> bool:
        """Check if this character has been transliterated."""
        c = self
        while True:
            s = c.source
            if s is None:
                break
            if s.c != c.c:
                return True
            c = s
        return False


def build_char_list(input_str: str) -> list[Char]:
    """Build a list of characters from a string, handling IVS/SVS sequences.

    This function properly handles Ideographic Variation Sequences (IVS) and
    Standardized Variation Sequences (SVS) by combining base characters with
    their variation selectors into single Char objects.

    :param input_str: The input string to convert to character array
    :returns: A list of Char objects representing the input string, with a sentinel
              empty character at the end
    """
    result: list[Char] = []
    offset = 0
    prev_char: str | None = None
    prev_codepoint: int | None = None

    for char in input_str:
        codepoint = ord(char)

        if prev_char is not None and prev_codepoint is not None:
            # Check if current character is a variation selector
            # Variation selectors are in ranges: U+FE00-U+FE0F, U+E0100-U+E01EF
            if (0xFE00 <= codepoint <= 0xFE0F) or (0xE0100 <= codepoint <= 0xE01EF):
                # Combine previous character with variation selector
                combined_char = prev_char + char
                result.append(Char(c=combined_char, offset=offset))
                offset += len(combined_char)
                prev_char = prev_codepoint = None
                continue

            # Previous character was not followed by a variation selector
            result.append(Char(c=prev_char, offset=offset))
            offset += len(prev_char)

        # Store current character for next iteration
        prev_char = char
        prev_codepoint = codepoint

    # Handle the last character if any
    if prev_char is not None:
        result.append(Char(c=prev_char, offset=offset))
        offset += len(prev_char)

    # Add sentinel empty character
    result.append(Char(c="", offset=offset))

    return result


def from_chars(chars: Iterable[Char]) -> str:
    """Convert an iterable of characters back to a string.

    This function filters out sentinel characters (empty strings) that are
    used internally by the transliteration system.

    :param chars: An iterable of Char objects
    :returns: A string composed of the non-empty characters
    """
    return "".join(char.c for char in chars if char.c)
