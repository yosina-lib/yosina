"""File loaders for transliteration datasets."""

from pathlib import Path

from .models import CircledOrSquaredRecord, HyphensRecord, IvsSvsBaseRecord, RomanNumeralsRecord
from .parsers import (
    parse_circled_or_squared_transliteration_records,
    parse_combined_transliteration_records,
    parse_hyphen_transliteration_records,
    parse_ivs_svs_base_transliteration_records,
    parse_kanji_old_new_transliteration_records,
    parse_roman_numerals_records,
    parse_simple_transliteration_records,
)

__all__ = [
    "load_spaces",
    "load_radicals",
    "load_mathematical_alphanumerics",
    "load_ideographic_annotations",
    "load_hyphens",
    "load_ivs_svs_base",
    "load_kanji_old_new",
    "load_combined",
    "load_circled_or_squared",
    "load_roman_numerals",
]


def load_file(path: Path) -> str:
    """Load file contents as string."""
    return path.read_text(encoding="utf-8")


def load_spaces(path: Path) -> list[tuple[str, str]]:
    """Load space character mappings."""
    content = load_file(path)
    return parse_simple_transliteration_records(content)


def load_radicals(path: Path) -> list[tuple[str, str]]:
    """Load radical character mappings."""
    content = load_file(path)
    return parse_simple_transliteration_records(content)


def load_mathematical_alphanumerics(path: Path) -> list[tuple[str, str]]:
    """Load mathematical alphanumeric character mappings."""
    content = load_file(path)
    return parse_simple_transliteration_records(content)


def load_ideographic_annotations(path: Path) -> list[tuple[str, str]]:
    """Load ideographic annotation character mappings."""
    content = load_file(path)
    return parse_simple_transliteration_records(content)


def load_hyphens(path: Path) -> list[tuple[str, HyphensRecord]]:
    """Load hyphen character mappings."""
    content = load_file(path)
    return parse_hyphen_transliteration_records(content)


def load_ivs_svs_base(path: Path) -> list[IvsSvsBaseRecord]:
    """Load IVS/SVS base character mappings."""
    content = load_file(path)
    return parse_ivs_svs_base_transliteration_records(content)


def load_kanji_old_new(path: Path) -> list[tuple[str, str]]:
    """Load kanji old-new form mappings."""
    content = load_file(path)
    return parse_kanji_old_new_transliteration_records(content)


def load_combined(path: Path) -> list[tuple[str, list[str]]]:
    """Load combined character mappings."""
    content = load_file(path)
    return parse_combined_transliteration_records(content)


def load_circled_or_squared(path: Path) -> list[tuple[str, CircledOrSquaredRecord]]:
    """Load circled or squared character mappings."""
    content = load_file(path)
    return parse_circled_or_squared_transliteration_records(content)


def load_roman_numerals(path: Path) -> list[tuple[str, RomanNumeralsRecord]]:
    """Load roman numerals character mappings."""
    content = load_file(path)
    return parse_roman_numerals_records(content)
