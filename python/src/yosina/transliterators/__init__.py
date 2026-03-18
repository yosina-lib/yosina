"""Transliterator implementations."""

from typing import Any, Literal

from ..types import TransliteratorFactory
from . import (
    archaic_hirakatas,
    circled_or_squared,
    combined,
    hira_kata,
    hira_kata_composition,
    historical_hirakatas,
    hyphens,
    ideographic_annotations,
    ivs_svs_base,
    japanese_iteration_marks,
    jisx0201_and_alike,
    kanji_old_new,
    mathematical_alphanumerics,
    prolonged_sound_marks,
    radicals,
    roman_numerals,
    small_hirakatas,
    spaces,
)

__all__ = [
    "archaic_hirakatas",
    "circled_or_squared",
    "combined",
    "hira_kata",
    "hira_kata_composition",
    "historical_hirakatas",
    "hyphens",
    "ideographic_annotations",
    "ivs_svs_base",
    "japanese_iteration_marks",
    "jisx0201_and_alike",
    "kanji_old_new",
    "mathematical_alphanumerics",
    "prolonged_sound_marks",
    "radicals",
    "roman_numerals",
    "small_hirakatas",
    "spaces",
    "TRANSLITERATORS",
    "TransliteratorConfig",
    "TransliteratorIdentifier",
]

TransliteratorIdentifier = Literal[
    "archaic-hirakatas",
    "circled-or-squared",
    "combined",
    "hira-kata",
    "hira-kata-composition",
    "historical-hirakatas",
    "hyphens",
    "ideographic-annotations",
    "ivs-svs-base",
    "japanese-iteration-marks",
    "jisx0201-and-alike",
    "kanji-old-new",
    "mathematical-alphanumerics",
    "prolonged-sound-marks",
    "radicals",
    "roman-numerals",
    "small-hirakatas",
    "spaces",
]

# For now, using generic dict for options - can be refined later with specific types
TransliteratorConfig = tuple[TransliteratorIdentifier, dict[str, Any]]

_TRANSLITERATOR_MODULES = {
    "archaic-hirakatas": archaic_hirakatas,
    "circled-or-squared": circled_or_squared,
    "combined": combined,
    "hira-kata": hira_kata,
    "hira-kata-composition": hira_kata_composition,
    "historical-hirakatas": historical_hirakatas,
    "hyphens": hyphens,
    "ideographic-annotations": ideographic_annotations,
    "ivs-svs-base": ivs_svs_base,
    "japanese-iteration-marks": japanese_iteration_marks,
    "jisx0201-and-alike": jisx0201_and_alike,
    "kanji-old-new": kanji_old_new,
    "mathematical-alphanumerics": mathematical_alphanumerics,
    "prolonged-sound-marks": prolonged_sound_marks,
    "radicals": radicals,
    "roman-numerals": roman_numerals,
    "small-hirakatas": small_hirakatas,
    "spaces": spaces,
}

# Supported transliterator names
TRANSLITERATORS = tuple(_TRANSLITERATOR_MODULES.keys())


def get_transliterator_factory(name: TransliteratorIdentifier) -> TransliteratorFactory:
    """Get a transliterator factory by name.

    :param name: The name of the transliterator
    :returns: A transliterator factory class
    :raises ValueError: If the transliterator name is invalid or not found
    """
    module = _TRANSLITERATOR_MODULES.get(name)
    if module is None:
        raise ValueError(f"transliterator not found: {name}")

    class_ = getattr(module, "Transliterator", None)
    if class_ is None:
        raise ValueError(f"unexpected module structure for {name}")

    return class_
