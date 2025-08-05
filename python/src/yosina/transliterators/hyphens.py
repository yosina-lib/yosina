"""Hyphen character normalization transliterator."""

from collections.abc import Iterable

from ..chars import Char
from .hyphens_data import HYPHENS_MAPPINGS, HyphensRecord

__all__ = ["Transliterator"]

# Default precedence of mappings (matching JavaScript default)
DEFAULT_PRECEDENCE = ["jisx0208_90"]


class Transliterator:
    """Hyphen character normalization transliterator.

    This transliterator substitutes commoner counterparts for hyphens and a number of symbols.
    It handles various dash/hyphen symbols and normalizes them to those common in Japanese
    writing based on the precedence order.
    """

    precedence: list[str]

    def __init__(self, *, precedence: list[str] | None = None) -> None:
        """Initialize the transliterator with options.

        :param precedence: List of mapping variants to apply in order.
                Available options: "ascii", "jisx0201", "jisx0208_90",
                "jisx0208_90_windows", "jisx0208_verbatim"
                Defaults to ["jisx0208_90"]
        """
        self.precedence = precedence if precedence is not None else DEFAULT_PRECEDENCE.copy()

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Normalize hyphen characters."""
        offset = 0
        for char in input_chars:
            record = HYPHENS_MAPPINGS.get(char.c)
            if record is not None:
                replacement = self._get_replacement(record)
                if replacement is not None and replacement != char.c:
                    yield Char(c=replacement, offset=offset, source=char)
                    offset += len(replacement)
                else:
                    yield char.with_offset(offset)
                    offset += len(char.c)
            else:
                yield char.with_offset(offset)
                offset += len(char.c)

    def _get_replacement(self, record: HyphensRecord) -> str | None:
        """Get the replacement character based on precedence.

        :param record: The hyphen record containing mapping options
        :returns: The replacement character or None if no mapping found
        """
        for mapping_type in self.precedence:
            if mapping_type == "ascii":
                replacement = record.ascii
            elif mapping_type == "jisx0201":
                replacement = record.jisx0201
            elif mapping_type == "jisx0208_90":
                replacement = record.jisx0208_90
            elif mapping_type == "jisx0208_90_windows":
                replacement = record.jisx0208_90_windows
            elif mapping_type == "jisx0208_verbatim":
                replacement = record.jisx0208_verbatim
            else:
                continue  # Unknown mapping type, skip

            if replacement is not None:
                return replacement

        return None
