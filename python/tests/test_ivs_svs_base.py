"""Tests for IVS/SVS base transliterator."""

from typing import Any

import pytest

from yosina.chars import build_char_list, from_chars
from yosina.transliterators.ivs_svs_base import Transliterator as IvsSvsBaseTransliterator


@pytest.mark.parametrize(
    "input_str,expected,options",
    [
        # IVS/SVS mode - add selectors
        (
            "\u9038\u70ba",
            "\u9038\U000e0100\u70ba\U000e0100",
            {"mode": "ivs-or-svs"},
        ),
        ("\u8fbb", "\u8fbb\U000e0101", {"mode": "ivs-or-svs"}),
        # Base mode - remove selectors
        ("\u9038\U000e0100\u70ba\U000e0100", "\u9038\u70ba", {"mode": "base"}),
        ("\u8fbb\U000e0101", "\u8fbb", {"mode": "base"}),
        # Base mode - keep unmapped selectors
        ("\u8fbb\U000e0100", "\u8fbb\U000e0100", {"mode": "base"}),
        # Base mode - drop all selectors
        (
            "\u8fbb\U000e0100",
            "\u8fbb",
            {"mode": "base", "drop_selectors_altogether": True},
        ),
        (
            "\u8fbb\U000e0101",
            "\u8fbb",
            {"mode": "base", "drop_selectors_altogether": True},
        ),
    ],
)
def test_ivs_svs_processing(input_str: str, expected: str, options: dict[str, Any]) -> None:
    """Test IVS/SVS processing."""
    transliterator = IvsSvsBaseTransliterator(**options)
    result = from_chars(transliterator(build_char_list(input_str)))

    # Compare codepoint by codepoint for better debugging
    result_codepoints = [hex(ord(c)) for c in result]
    expected_codepoints = [hex(ord(c)) for c in expected]
    assert result_codepoints == expected_codepoints
