"""Tests for hiragana-katakana composition transliterator."""

from typing import Any

import pytest

from yosina.chars import build_char_list, from_chars
from yosina.transliterators.hira_kata_composition import (
    Transliterator as HiraKataCompositionTransliterator,
)


@pytest.mark.parametrize(
    "input_str,expected,options",
    [
        # Katakana with dakuten and handakuten
        (
            "\u30ab\u3099\u30ac\u30ad\u30ad\u3099\u30af",
            "\u30ac\u30ac\u30ad\u30ae\u30af",
            {},
        ),
        (
            "\u30cf\u30cf\u3099\u30cf\u309a\u30d2\u30d5\u30d8\u30db",
            "\u30cf\u30d0\u30d1\u30d2\u30d5\u30d8\u30db",
            {},
        ),
        # Hiragana with dakuten and handakuten
        (
            "\u304b\u3099\u304c\u304d\u304d\u3099\u304f",
            "\u304c\u304c\u304d\u304e\u304f",
            {},
        ),
        (
            "\u306f\u306f\u3099\u306f\u309a\u3072\u3075\u3078\u307b",
            "\u306f\u3070\u3071\u3072\u3075\u3078\u307b",
            {},
        ),
        # Non-combining marks (゛ and ゜)
        (
            "\u30cf\u30cf\u309b\u30cf\u309c\u30d2\u30d5\u30d8\u30db",
            "\u30cf\u30d0\u30d1\u30d2\u30d5\u30d8\u30db",
            {"compose_non_combining_marks": True},
        ),
    ],
)
def test_composition(input_str: str, expected: str, options: dict[str, Any]) -> None:
    """Test hiragana-katakana composition."""
    transliterator = HiraKataCompositionTransliterator(**options)
    result = from_chars(transliterator(build_char_list(input_str)))
    assert result == expected
