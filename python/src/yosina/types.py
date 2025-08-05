"""Core types for the Yosina transliteration library."""

from __future__ import annotations

from collections.abc import Iterable
from typing import Any, Protocol, runtime_checkable

from .chars import Char

__all__ = ["Transliterator", "TransliteratorFactory"]


@runtime_checkable
class Transliterator(Protocol):
    """Protocol for transliterator functions.

    .. automethod:: __call__
    """

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Transliterate an iterable of characters.

        :param input_chars: The characters to transliterate
        :returns: The transliterated characters
        """
        ...


class TransliteratorFactory(Protocol):
    """Protocol for transliterator factory functions.

    .. automethod:: __call__
    """

    def __call__(self, **options: Any) -> Transliterator:
        """Create a transliterator with the given options.

        :param options: Configuration options for the transliterator
        :returns: A configured transliterator instance
        """
        ...
