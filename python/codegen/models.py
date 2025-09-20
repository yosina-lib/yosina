"""Data models for code generation."""

from dataclasses import dataclass
from typing import Literal

__all__ = ["HyphensRecord", "IvsSvsBaseRecord", "CircledOrSquaredRecord", "RomanNumeralsRecord"]


@dataclass
class HyphensRecord:
    """Record for hyphen transliteration data."""

    ascii: str | None = None
    jisx0201: str | None = None
    jisx0208_90: str | None = None
    jisx0208_90_windows: str | None = None
    jisx0208_verbatim: str | None = None


@dataclass
class IvsSvsBaseRecord:
    """Record for IVS/SVS base transliteration data."""

    ivs: str
    svs: str | None = None
    base90: str | None = None
    base2004: str | None = None


@dataclass
class CircledOrSquaredRecord:
    """Record for circled or squared character transliteration data."""

    rendering: str
    type: Literal["circle", "square"]
    emoji: bool


@dataclass
class RomanNumeralsRecord:
    """Record for roman numerals transliteration data."""

    value: int
    upper: str
    lower: str
    decomposed_upper: list[str]
    decomposed_lower: list[str]
