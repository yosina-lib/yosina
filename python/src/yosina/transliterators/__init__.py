"""Transliterator implementations."""

from typing import Any, Literal

from ..types import TransliteratorFactory
from . import (
    circled_or_squared,
    combined,
    hira_kata,
    hira_kata_composition,
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
    spaces,
)

__all__ = [
    "circled_or_squared",
    "combined",
    "hira_kata",
    "hira_kata_composition",
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
    "spaces",
    "TRANSLITERATORS",
    "TransliteratorConfig",
    "TransliteratorIdentifier",
]

TransliteratorIdentifier = Literal[
    "circled-or-squared",
    "combined",
    "hira-kata",
    "hira-kata-composition",
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
    "spaces",
]

# For now, using generic dict for options - can be refined later with specific types
TransliteratorConfig = tuple[TransliteratorIdentifier, dict[str, Any]]

_TRANSLITERATOR_MODULES = {
    "circled-or-squared": circled_or_squared,
    "combined": combined,
    "hira-kata": hira_kata,
    "hira-kata-composition": hira_kata_composition,
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
