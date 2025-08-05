"""Hiragana-Katakana conversion transliterator."""

from collections.abc import Iterable
from typing import Literal

from ..chars import Char
from .hira_kata_table import HIRAGANA_KATAKANA_SMALL_TABLE, HIRAGANA_KATAKANA_TABLE

__all__ = ["Transliterator"]


class Transliterator:
    """Hiragana-Katakana conversion transliterator.

    Converts between hiragana and katakana scripts.
    """

    # Class-level cache for mapping tables
    _mapping_cache: dict[str, dict[str, str]] = {}

    mode: Literal["hira-to-kata", "kata-to-hira"]
    mapping_table: dict[str, str]

    def __init__(self, *, mode: Literal["hira-to-kata", "kata-to-hira"] = "hira-to-kata") -> None:
        """Initialize the transliterator with options.

        :param mode: Conversion mode - either 'hira-to-kata' or 'kata-to-hira'.
                    Defaults to 'hira-to-kata'.
        """
        self.mode = mode
        self.mapping_table = self._get_mapping_table(mode)

    @classmethod
    def _get_mapping_table(cls, mode: Literal["hira-to-kata", "kata-to-hira"]) -> dict[str, str]:
        """Get or build the mapping table for the specified mode."""
        # Check cache first
        cached = cls._mapping_cache.get(mode)
        if cached is not None:
            return cached

        mapping: dict[str, str] = {}

        # Main table mappings
        for hiragana_entry, katakana_entry, _ in HIRAGANA_KATAKANA_TABLE:
            hira, hira_voiced, hira_semivoiced = hiragana_entry
            kata, kata_voiced, kata_semivoiced = katakana_entry

            if mode == "hira-to-kata":
                mapping[hira] = kata
                if hira_voiced is not None and kata_voiced is not None:
                    mapping[hira_voiced] = kata_voiced
                if hira_semivoiced is not None and kata_semivoiced is not None:
                    mapping[hira_semivoiced] = kata_semivoiced
            else:
                mapping[kata] = hira
                if kata_voiced is not None and hira_voiced is not None:
                    mapping[kata_voiced] = hira_voiced
                if kata_semivoiced is not None and hira_semivoiced is not None:
                    mapping[kata_semivoiced] = hira_semivoiced

        # Small character mappings
        for hira, kata, _ in HIRAGANA_KATAKANA_SMALL_TABLE:
            if mode == "hira-to-kata":
                mapping[hira] = kata
            else:
                mapping[kata] = hira

        # Cache the result
        cls._mapping_cache[mode] = mapping
        return mapping

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Convert between hiragana and katakana."""
        for char in input_chars:
            mapped = self.mapping_table.get(char.c)
            if mapped is not None:
                yield Char(c=mapped, offset=char.offset, source=char)
            else:
                yield char
