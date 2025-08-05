"""Auto-generated spaces transliterator.

Replace various space characters with plain whitespace.
"""
from collections.abc import Iterable
from typing import Any

from ..chars import Char

__all__ = ["Transliterator"]

# Generated mapping data
SPACES_MAPPINGS = {
    "\xa0": " ",
    "\u180e": "",
    "\u2000": " ",
    "\u2001": " ",
    "\u2002": " ",
    "\u2003": " ",
    "\u2004": " ",
    "\u2005": " ",
    "\u2006": " ",
    "\u2007": " ",
    "\u2008": " ",
    "\u2009": " ",
    "\u200a": " ",
    "\u200b": " ",
    "\u202f": " ",
    "\u205f": " ",
    "\u3000": " ",
    "\u3164": " ",
    "\uffa0": " ",
    "\ufeff": "",
}


class Transliterator:
    """Transliterator for spaces.

    Replace various space characters with plain whitespace.
    """

    def __init__(self, **_options: Any) -> None:
        """Initialize the transliterator with options.

        :param _options: Configuration options (currently unused)
        """

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Replace various space characters with plain whitespace."""
        offset = 0

        for char in input_chars:
            replacement = SPACES_MAPPINGS.get(char.c)
            if replacement is not None:
                yield Char(c=replacement, offset=offset, source=char)
                offset += len(replacement)
            else:
                yield char.with_offset(offset)
                offset += len(char.c)

