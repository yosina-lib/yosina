"""Dataset loading and management for code generation."""

from dataclasses import dataclass
from pathlib import Path

from .loaders import (
    load_circled_or_squared,
    load_combined,
    load_hyphens,
    load_ideographic_annotations,
    load_ivs_svs_base,
    load_kanji_old_new,
    load_mathematical_alphanumerics,
    load_radicals,
    load_roman_numerals,
    load_spaces,
)
from .models import CircledOrSquaredRecord, HyphensRecord, IvsSvsBaseRecord, RomanNumeralsRecord

__all__ = ["Dataset", "DatasetSourceDefs", "build_dataset_from_data_root"]


@dataclass(frozen=True)
class DatasetSourceDefs:
    spaces: str
    radicals: str
    mathematical_alphanumerics: str
    ideographic_annotations: str
    hyphens: str
    ivs_svs_base: str
    kanji_old_new: str
    combined: str
    circled_or_squared: str
    roman_numerals: str


@dataclass(frozen=True)
class Dataset:
    """Complete dataset for transliterator code generation."""

    spaces: list[tuple[str, str]]
    radicals: list[tuple[str, str]]
    mathematical_alphanumerics: list[tuple[str, str]]
    ideographic_annotations: list[tuple[str, str]]
    hyphens: list[tuple[str, HyphensRecord]]
    ivs_svs_base: list[IvsSvsBaseRecord]
    kanji_old_new: list[tuple[str, str]]
    combined: list[tuple[str, list[str]]]
    circled_or_squared: list[tuple[str, CircledOrSquaredRecord]]
    roman_numerals: list[tuple[str, RomanNumeralsRecord]]


def build_dataset_from_data_root(root: Path, defs: DatasetSourceDefs) -> Dataset:
    """Build dataset from data root directory and source definitions.

    Args:
        root: Path to the data root directory
        defs: Dictionary mapping dataset names to filenames

    Returns:
        Complete Dataset object
    """
    return Dataset(
        spaces=load_spaces(root / defs.spaces),
        radicals=load_radicals(root / defs.radicals),
        mathematical_alphanumerics=load_mathematical_alphanumerics(root / defs.mathematical_alphanumerics),
        ideographic_annotations=load_ideographic_annotations(root / defs.ideographic_annotations),
        hyphens=load_hyphens(root / defs.hyphens),
        ivs_svs_base=load_ivs_svs_base(root / defs.ivs_svs_base),
        kanji_old_new=load_kanji_old_new(root / defs.kanji_old_new),
        combined=load_combined(root / defs.combined),
        circled_or_squared=load_circled_or_squared(root / defs.circled_or_squared),
        roman_numerals=load_roman_numerals(root / defs.roman_numerals),
    )
