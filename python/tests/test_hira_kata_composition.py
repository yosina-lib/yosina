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
        # Hiragana iteration mark with combining voiced mark
        (
            "\u309d\u3099",  # ゝ + ゛
            "\u309e",  # ゞ
            {},
        ),
        # Katakana iteration mark with combining voiced mark
        (
            "\u30fd\u3099",  # ヽ + ゛
            "\u30fe",  # ヾ
            {},
        ),
        # Special katakana with dakuten
        (
            "\u30ef\u3099",  # ワ + ゛
            "\u30f7",  # ヷ
            {},
        ),
        (
            "\u30f0\u3099",  # ヰ + ゛
            "\u30f8",  # ヸ
            {},
        ),
        (
            "\u30f1\u3099",  # ヱ + ゛
            "\u30f9",  # ヹ
            {},
        ),
        (
            "\u30f2\u3099",  # ヲ + ゛
            "\u30fa",  # ヺ
            {},
        ),
        # Hiragana u with dakuten
        (
            "\u3046\u3099",  # う + ゛
            "\u3094",  # ゔ
            {},
        ),
        # Katakana u with dakuten
        (
            "\u30a6\u3099",  # ウ + ゛
            "\u30f4",  # ヴ
            {},
        ),
        # Iteration marks with non-combining marks
        (
            "\u309d\u309b",  # ゝ + ゛ (non-combining)
            "\u309e",  # ゞ
            {"compose_non_combining_marks": True},
        ),
        (
            "\u30fd\u309b",  # ヽ + ゛ (non-combining)
            "\u30fe",  # ヾ
            {"compose_non_combining_marks": True},
        ),
        # Vertical iteration marks with combining voiced mark
        (
            "\u3031\u3099",  # 〱 + ゛
            "\u3032",  # 〲
            {},
        ),
        (
            "\u3033\u3099",  # 〳 + ゛
            "\u3034",  # 〴
            {},
        ),
        # Vertical iteration marks with non-combining marks
        (
            "\u3031\u309b",  # 〱 + ゛ (non-combining)
            "\u3032",  # 〲
            {"compose_non_combining_marks": True},
        ),
        (
            "\u3033\u309b",  # 〳 + ゛ (non-combining)
            "\u3034",  # 〴
            {"compose_non_combining_marks": True},
        ),
        # Mixed text with iteration marks
        (
            "テスト\u309d\u3099カタカナ\u30fd\u3099",
            "テスト\u309eカタカナ\u30fe",
            {},
        ),
        # Empty string
        (
            "",
            "",
            {},
        ),
        # Non-composable characters
        (
            "\u3042\u3099",  # あ + ゛ (not composable)
            "\u3042\u3099",
            {},
        ),
        # Multiple compositions in sequence
        (
            "\u304b\u3099\u304d\u3099\u304f\u3099\u3051\u3099\u3053\u3099",
            "\u304c\u304e\u3050\u3052\u3054",
            {},
        ),
    ],
)
def test_composition(input_str: str, expected: str, options: dict[str, Any]) -> None:
    """Test hiragana-katakana composition."""
    transliterator = HiraKataCompositionTransliterator(**options)
    result = from_chars(transliterator(build_char_list(input_str)))
    assert result == expected
