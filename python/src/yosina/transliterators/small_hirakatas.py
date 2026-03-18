"""Auto-generated small_hirakatas transliterator.

Replace small hiragana/katakana with ordinary-sized equivalents.
"""

from collections.abc import Iterable
from typing import Any

from ..chars import Char

__all__ = ["Transliterator"]

# Generated mapping data
SMALL_HIRAKATAS_MAPPINGS = {
    "\u3041": "\u3042",
    "\u3043": "\u3044",
    "\u3045": "\u3046",
    "\u3047": "\u3048",
    "\u3049": "\u304a",
    "\u3063": "\u3064",
    "\u3083": "\u3084",
    "\u3085": "\u3086",
    "\u3087": "\u3088",
    "\u308e": "\u308f",
    "\u3095": "\u304b",
    "\u3096": "\u3051",
    "\u30a1": "\u30a2",
    "\u30a3": "\u30a4",
    "\u30a5": "\u30a6",
    "\u30a7": "\u30a8",
    "\u30a9": "\u30aa",
    "\u30c3": "\u30c4",
    "\u30e3": "\u30e4",
    "\u30e5": "\u30e6",
    "\u30e7": "\u30e8",
    "\u30ee": "\u30ef",
    "\u30f5": "\u30ab",
    "\u30f6": "\u30b1",
    "\u31f0": "\u30af",
    "\u31f1": "\u30b7",
    "\u31f2": "\u30b9",
    "\u31f3": "\u30c8",
    "\u31f4": "\u30cc",
    "\u31f5": "\u30cf",
    "\u31f6": "\u30d2",
    "\u31f7": "\u30d5",
    "\u31f8": "\u30d8",
    "\u31f9": "\u30db",
    "\u31fa": "\u30e0",
    "\u31fb": "\u30e9",
    "\u31fc": "\u30ea",
    "\u31fd": "\u30eb",
    "\u31fe": "\u30ec",
    "\u31ff": "\u30ed",
    "\uff67": "\uff71",
    "\uff68": "\uff72",
    "\uff69": "\uff73",
    "\uff6a": "\uff74",
    "\uff6b": "\uff75",
    "\uff6c": "\uff94",
    "\uff6d": "\uff95",
    "\uff6e": "\uff96",
    "\uff6f": "\uff82",
    "\U0001b132": "\u3053",
    "\U0001b150": "\u3090",
    "\U0001b151": "\u3091",
    "\U0001b152": "\u3092",
    "\U0001b155": "\u30b3",
    "\U0001b164": "\u30f0",
    "\U0001b165": "\u30f1",
    "\U0001b166": "\u30f2",
    "\U0001b167": "\u30f3",
}


class Transliterator:
    """Transliterator for small_hirakatas.

    Replace small hiragana/katakana with ordinary-sized equivalents.
    """

    def __init__(self, **_options: Any) -> None:
        """Initialize the transliterator with options.

        :param _options: Configuration options (currently unused)
        """

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Replace small hiragana/katakana with ordinary-sized equivalents."""
        offset = 0

        for char in input_chars:
            replacement = SMALL_HIRAKATAS_MAPPINGS.get(char.c)
            if replacement is not None:
                yield Char(c=replacement, offset=offset, source=char)
                offset += len(replacement)
            else:
                yield char.with_offset(offset)
                offset += len(char.c)
