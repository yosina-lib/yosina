"""Auto-generated ideographic_annotations transliterator.

Replace ideographic annotation marks used in traditional translation.
"""
from collections.abc import Iterable
from typing import Any

from ..chars import Char

__all__ = ["Transliterator"]

# Generated mapping data
IDEOGRAPHIC_ANNOTATIONS_MAPPINGS = {
    "\u3192": "\u4e00",
    "\u3193": "\u4e8c",
    "\u3194": "\u4e09",
    "\u3195": "\u56db",
    "\u3196": "\u4e0a",
    "\u3197": "\u4e2d",
    "\u3198": "\u4e0b",
    "\u3199": "\u7532",
    "\u319a": "\u4e59",
    "\u319b": "\u4e19",
    "\u319c": "\u4e01",
    "\u319d": "\u5929",
    "\u319e": "\u5730",
    "\u319f": "\u4eba",
}


class Transliterator:
    """Transliterator for ideographic_annotations.

    Replace ideographic annotation marks used in traditional translation.
    """

    def __init__(self, **_options: Any) -> None:
        """Initialize the transliterator with options.

        :param _options: Configuration options (currently unused)
        """

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Replace ideographic annotation marks used in traditional translation."""
        offset = 0

        for char in input_chars:
            replacement = IDEOGRAPHIC_ANNOTATIONS_MAPPINGS.get(char.c)
            if replacement is not None:
                yield Char(c=replacement, offset=offset, source=char)
                offset += len(replacement)
            else:
                yield char.with_offset(offset)
                offset += len(char.c)

