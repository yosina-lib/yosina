"""Auto-generated roman numerals transliterator.

Replace roman numeral characters with their ASCII letter equivalents.
"""

from collections.abc import Iterable
from typing import Any

from ..chars import Char

__all__ = ["Transliterator"]

# Generated mapping data
ROMAN_NUMERAL_MAPPINGS = {
    "\u2160": ["I"],
    "\u2161": ["I", "I"],
    "\u2162": ["I", "I", "I"],
    "\u2163": ["I", "V"],
    "\u2164": ["V"],
    "\u2165": ["V", "I"],
    "\u2166": ["V", "I", "I"],
    "\u2167": ["V", "I", "I", "I"],
    "\u2168": ["I", "X"],
    "\u2169": ["X"],
    "\u216a": ["X", "I"],
    "\u216b": ["X", "I", "I"],
    "\u216c": ["L"],
    "\u216d": ["C"],
    "\u216e": ["D"],
    "\u216f": ["M"],
    "\u2170": ["i"],
    "\u2171": ["i", "i"],
    "\u2172": ["i", "i", "i"],
    "\u2173": ["i", "v"],
    "\u2174": ["v"],
    "\u2175": ["v", "i"],
    "\u2176": ["v", "i", "i"],
    "\u2177": ["v", "i", "i", "i"],
    "\u2178": ["i", "x"],
    "\u2179": ["x"],
    "\u217a": ["x", "i"],
    "\u217b": ["x", "i", "i"],
    "\u217c": ["l"],
    "\u217d": ["c"],
    "\u217e": ["d"],
    "\u217f": ["m"],
}


class Transliterator:
    """Transliterator for roman numerals.

    Replace roman numeral characters with their ASCII letter equivalents.
    """

    def __init__(self, **_options: Any) -> None:
        """Initialize the transliterator with options.

        :param _options: Configuration options (currently unused)
        """

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Replace each roman numeral with its ASCII letter equivalent."""
        offset = 0
        for char in input_chars:
            replacement_list = ROMAN_NUMERAL_MAPPINGS.get(char.c)
            if replacement_list is not None:
                for replacement_char in replacement_list:
                    yield Char(c=replacement_char, offset=offset, source=char)
                    offset += len(replacement_char)
            else:
                yield char.with_offset(offset)
                offset += len(char.c)
