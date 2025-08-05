"""Tests for kanji old-new conversion transliterator."""

import pytest

from yosina.chars import build_char_list, from_chars
from yosina.transliterators.kanji_old_new import Transliterator as KanjiOldNewTransliterator


@pytest.mark.parametrize(
    "input_str,expected",
    [
        # Kanji old-new conversion with variation selectors
        ("\u6a9c\U000e0100", "\u6867\U000e0100"),  # 檜 -> 桧 with VS17
        ("\u8fbb\U000e0101", "\u8fbb\U000e0100"),  # 辻 with VS18 -> VS17
    ],
)
def test_kanji_old_new_conversion(input_str: str, expected: str) -> None:
    """Test kanji old-new conversion."""
    transliterator = KanjiOldNewTransliterator()
    result = from_chars(transliterator(build_char_list(input_str)))
    assert result == expected
