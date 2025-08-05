"""Basic functionality tests for yosina."""

import pytest

from yosina import make_transliterator
from yosina.chars import Char, build_char_list, from_chars
from yosina.recipes import TransliterationRecipe
from yosina.transliterators import TransliteratorConfig, TransliteratorIdentifier


def test_char_creation():
    """Test Char dataclass creation."""
    char = Char(c="a", offset=0)
    assert char.c == "a"
    assert char.offset == 0
    assert char.source is None


def test_build_char_list():
    """Test building character arrays from strings."""
    result = build_char_list("hello")
    assert len(result) == 6
    assert result[0].c == "h"
    assert result[0].offset == 0
    assert result[4].c == "o"
    assert result[4].offset == 4


def test_from_chars():
    """Test converting character arrays back to strings."""
    chars = [
        Char(c="h", offset=0),
        Char(c="e", offset=1),
        Char(c="l", offset=2),
        Char(c="l", offset=3),
        Char(c="o", offset=4),
    ]
    result = from_chars(chars)
    assert result == "hello"


def test_make_transliterator_with_empty_recipe():
    """Test creating a transliterator with an empty recipe."""
    recipe = TransliterationRecipe()

    # Empty recipe should raise an error since no transliterators are configured
    with pytest.raises(ValueError, match="at least one transliterator"):
        make_transliterator(recipe)


def test_make_transliterator_with_space_normalization():
    """Test space normalization functionality."""
    recipe = TransliterationRecipe(replace_spaces=True)
    transliterator = make_transliterator(recipe)

    # Test with ideographic space (should be normalized to regular space)
    test_input = "hello\u3000world"  # ideographic space
    result = transliterator(test_input)
    assert result == "hello world"


def test_recipe_mutual_exclusion():
    """Test that mutually exclusive options raise an error."""
    recipe = TransliterationRecipe(
        to_fullwidth=True,
        to_halfwidth=True,
    )

    with pytest.raises(ValueError, match="mutually exclusive"):
        make_transliterator(recipe)


def test_make_transliterator_with_configs():
    """Test creating a transliterator with direct configs."""
    configs: list[TransliteratorIdentifier | TransliteratorConfig] | TransliterationRecipe = [("spaces", {})]
    transliterator = make_transliterator(configs)

    # Test with ideographic space
    test_input = "hello\u3000world"
    result = transliterator(test_input)
    assert result == "hello world"


def test_empty_config_list_raises_error():
    """Test that empty config list raises an error."""
    with pytest.raises(ValueError, match="at least one transliterator"):
        make_transliterator([])


def test_invalid_transliterator_name():
    """Test that invalid transliterator names raise errors."""
    with pytest.raises(ValueError, match="transliterator not found"):
        make_transliterator([("invalid-name", {})])  # type: ignore
