"""Main transliterator interface."""

from __future__ import annotations

from collections.abc import Callable

from .chars import build_char_list, from_chars
from .intrinsics import make_chained_transliterator
from .recipes import TransliterationRecipe, build_transliterator_configs_from_recipe
from .transliterators import TransliteratorConfig, TransliteratorIdentifier

__all__ = ["make_transliterator"]


def make_transliterator(
    configs_or_recipe: list[TransliteratorConfig | TransliteratorIdentifier] | TransliterationRecipe,
) -> Callable[[str], str]:
    """Frontend convenience function to create a string-to-string transliterator.

    This is the main entry point for the library. It accepts either a recipe or
    a list of transliterator configs and returns a function that can transliterate strings.

    :param configs_or_recipe: Either a list of TransliteratorConfig/string names or
                              a TransliterationRecipe object
    :returns: A function that takes a string and returns a transliterated string

    :Example:

    Using a recipe:

    >>> from yosina import make_transliterator, TransliterationRecipe
    >>> recipe = TransliterationRecipe(
    ...     kanji_old_new=True,
    ...     replace_spaces=True
    ... )
    >>> transliterator = make_transliterator(recipe)
    >>> result = transliterator("some japanese text")

    Using configs directly:

    >>> configs = [("kanji-old-new", {}), ("spaces", {})]
    >>> transliterator = make_transliterator(configs)
    >>> result = transliterator("some japanese text")
    """
    if isinstance(configs_or_recipe, TransliterationRecipe):
        configs = build_transliterator_configs_from_recipe(configs_or_recipe)
    else:
        configs = configs_or_recipe

    chained_transliterator = make_chained_transliterator(configs)

    def transliterator_func(input_str: str) -> str:
        """Transliterate the input string."""
        char_array = build_char_list(input_str)
        transliterated_chars = chained_transliterator(char_array)
        return from_chars(transliterated_chars)

    return transliterator_func
