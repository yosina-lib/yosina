"""Tests for character array building and string conversion utilities."""

from yosina.chars import Char, build_char_list, from_chars


def test_build_char_list_simple():
    """Test building character arrays from simple strings."""
    result = build_char_list("hello")

    # Should have 5 characters + 1 sentinel
    assert len(result) == 6

    # Check each character
    assert result[0].c == "h"
    assert result[0].offset == 0
    assert result[1].c == "e"
    assert result[1].offset == 1
    assert result[4].c == "o"
    assert result[4].offset == 4

    # Check sentinel
    assert result[5].c == ""
    assert result[5].offset == 5


def test_build_char_list_with_ivs():
    """Test building character arrays with IVS sequences."""
    # Test with variation selector-15 (U+FE0E)
    input_str = "a\ufe0eb"
    result = build_char_list(input_str)

    # Should have 2 characters + 1 sentinel (a+selector combined, b separate)
    assert len(result) == 3

    # First character should be combined
    assert result[0].c == "a\ufe0e"
    assert result[0].offset == 0

    # Second character
    assert result[1].c == "b"
    assert result[1].offset == 2  # offset accounts for 2-char sequence

    # Sentinel
    assert result[2].c == ""
    assert result[2].offset == 3


def test_build_char_list_with_svs():
    """Test building character arrays with SVS sequences."""
    # Test with variation selector from private use area (U+E0100)
    input_str = "漢\U000e0100字"
    result = build_char_list(input_str)

    # Should have 2 characters + 1 sentinel
    assert len(result) == 3

    # First character should be combined
    assert result[0].c == "漢\U000e0100"
    assert result[0].offset == 0

    # Second character
    assert result[1].c == "字"
    assert result[1].offset == 2  # offset accounts for 2-char sequence

    # Sentinel
    assert result[2].c == ""
    assert result[2].offset == 3


def test_build_char_list_multiple_selectors():
    """Test building character arrays with multiple variation selectors."""
    input_str = "a\ufe0fb\ufe0ec"
    result = build_char_list(input_str)

    # Should have 3 characters + 1 sentinel
    assert len(result) == 4

    assert result[0].c == "a\ufe0f"
    assert result[0].offset == 0
    assert result[1].c == "b\ufe0e"
    assert result[1].offset == 2
    assert result[2].c == "c"
    assert result[2].offset == 4
    assert result[3].c == ""
    assert result[3].offset == 5


def test_build_char_list_no_selectors():
    """Test building character arrays without variation selectors."""
    input_str = "abc"
    result = build_char_list(input_str)

    # Should have 3 characters + 1 sentinel
    assert len(result) == 4

    for i, char in enumerate("abc"):
        assert result[i].c == char
        assert result[i].offset == i

    # Sentinel
    assert result[3].c == ""
    assert result[3].offset == 3


def test_build_char_list_empty_string():
    """Test building character arrays from empty strings."""
    result = build_char_list("")

    # Should have only sentinel
    assert len(result) == 1
    assert result[0].c == ""
    assert result[0].offset == 0


def test_from_chars_simple():
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


def test_from_chars_with_sentinels():
    """Test converting character arrays with sentinels back to strings."""
    chars = [
        Char(c="h", offset=0),
        Char(c="e", offset=1),
        Char(c="", offset=2),  # sentinel
        Char(c="l", offset=3),
        Char(c="o", offset=4),
        Char(c="", offset=5),  # sentinel
    ]
    result = from_chars(chars)
    assert result == "helo"  # sentinels filtered out


def test_from_chars_with_ivs():
    """Test converting character arrays with IVS sequences back to strings."""
    chars = [
        Char(c="a\ufe0e", offset=0),
        Char(c="b", offset=2),
        Char(c="", offset=3),  # sentinel
    ]
    result = from_chars(chars)
    assert result == "a\ufe0eb"


def test_from_chars_empty():
    """Test converting empty character arrays."""
    result = from_chars([])
    assert result == ""


def test_from_chars_only_sentinels():
    """Test converting character arrays with only sentinels."""
    chars = [
        Char(c="", offset=0),
        Char(c="", offset=1),
    ]
    result = from_chars(chars)
    assert result == ""


def test_roundtrip():
    """Test roundtrip conversion (string -> chars -> string)."""
    test_strings: list[str] = [
        "hello",
        "漢字",
        "a\ufe0eb",
        "漢\U000e0100字",
        "",
        "mixed\ufe0f漢\U000e0101字abc",
    ]

    for test_str in test_strings:
        chars = build_char_list(test_str)
        result = from_chars(chars)
        assert result == test_str


def test_variation_selector_ranges():
    """Test all variation selector ranges are handled correctly."""
    # Test FE00-FE0F range
    for i in range(0xFE00, 0xFE10):
        selector = chr(i)
        input_str = f"a{selector}b"
        result = build_char_list(input_str)
        assert len(result) == 3  # combined char + b + sentinel
        assert result[0].c == f"a{selector}"

    # Test E0100-E01EF range (sample a few)
    test_selectors: list[int] = [0xE0100, 0xE0101, 0xE01EF]
    for codepoint in test_selectors:
        selector = chr(codepoint)
        input_str = f"漢{selector}字"
        result = build_char_list(input_str)
        assert len(result) == 3  # combined char + 字 + sentinel
        assert result[0].c == f"漢{selector}"
