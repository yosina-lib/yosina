"""Hiragana-Katakana composition transliterator."""

from collections.abc import Iterable

from ..chars import Char
from .hira_kata_table import SEMI_VOICED_CHARACTERS, VOICED_CHARACTERS

__all__ = ["Transliterator"]


class Transliterator:
    """Hiragana-Katakana composition transliterator.

    Combines decomposed hiragana and katakana characters into their composed
    equivalents. For example, か + ゛becomes が.
    """

    compose_non_combining_marks: bool
    table: dict[str, dict[str, str]]

    def __init__(self, *, compose_non_combining_marks: bool = False) -> None:
        """Initialize the transliterator with options.

        :param compose_non_combining_marks: Whether to also compose non-combining
                marks (゛ and ゜) in addition to combining marks (゛and ゜).
                Defaults to False.
        """
        self.compose_non_combining_marks = compose_non_combining_marks
        self.table = self._build_table()

    def _build_table(self) -> dict[str, dict[str, str]]:
        """Build the lookup table from the character arrays."""
        # Build voiced table
        voiced_table = dict(VOICED_CHARACTERS)

        # Build semi-voiced table
        semi_voiced_table = dict(SEMI_VOICED_CHARACTERS)

        table = {
            "\u3099": voiced_table,  # combining voiced mark
            "\u309a": semi_voiced_table,  # combining semi-voiced mark
        }

        # Add non-combining marks if enabled
        if self.compose_non_combining_marks:
            table["\u309b"] = voiced_table  # non-combining voiced mark
            table["\u309c"] = semi_voiced_table  # non-combining semi-voiced mark

        return table

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Compose decomposed hiragana and katakana characters."""
        offset = 0
        pending_char: Char | None = None

        for char in input_chars:
            if pending_char is not None:
                # Check if current char is a combining mark
                mark_table = self.table.get(char.c)
                if mark_table is not None:
                    composed = mark_table.get(pending_char.c)
                    if composed is not None:
                        yield Char(c=composed, offset=offset, source=pending_char)
                        offset += len(composed)
                        pending_char = None
                        continue
                # No composition, yield pending char
                yield pending_char.with_offset(offset)
                offset += len(pending_char.c)
            pending_char = char

        # Handle any remaining character
        if pending_char is not None:
            yield pending_char.with_offset(offset)
            offset += len(pending_char.c)
