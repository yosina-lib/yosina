"""Tests for circled-or-squared transliterator."""

import pytest

from yosina.chars import build_char_list, from_chars
from yosina.transliterators.circled_or_squared import Transliterator as CircledOrSquaredTransliterator
from yosina.types import Transliterator


@pytest.fixture
def transliterator() -> Transliterator:
    return CircledOrSquaredTransliterator()


def test_circled_number_1(transliterator: Transliterator):
    """Test ① to (1)."""
    result = from_chars(transliterator(build_char_list("①")))
    assert result == "(1)"


def test_circled_number_2(transliterator: Transliterator):
    """Test ② to (2)."""
    result = from_chars(transliterator(build_char_list("②")))
    assert result == "(2)"


def test_circled_number_20(transliterator: Transliterator):
    """Test ⑳ to (20)."""
    result = from_chars(transliterator(build_char_list("⑳")))
    assert result == "(20)"


def test_circled_number_0(transliterator: Transliterator):
    """Test ⓪ to (0)."""
    result = from_chars(transliterator(build_char_list("⓪")))
    assert result == "(0)"


def test_circled_uppercase_a(transliterator: Transliterator):
    """Test Ⓐ to (A)."""
    result = from_chars(transliterator(build_char_list("Ⓐ")))
    assert result == "(A)"


def test_circled_uppercase_z(transliterator: Transliterator):
    """Test Ⓩ to (Z)."""
    result = from_chars(transliterator(build_char_list("Ⓩ")))
    assert result == "(Z)"


def test_circled_lowercase_a(transliterator: Transliterator):
    """Test ⓐ to (a)."""
    result = from_chars(transliterator(build_char_list("ⓐ")))
    assert result == "(a)"


def test_circled_lowercase_z(transliterator: Transliterator):
    """Test ⓩ to (z)."""
    result = from_chars(transliterator(build_char_list("ⓩ")))
    assert result == "(z)"


def test_circled_kanji_ichi(transliterator: Transliterator):
    """Test ㊀ to (一)."""
    result = from_chars(transliterator(build_char_list("㊀")))
    assert result == "(一)"


def test_circled_kanji_getsu(transliterator: Transliterator):
    """Test ㊊ to (月)."""
    result = from_chars(transliterator(build_char_list("㊊")))
    assert result == "(月)"


def test_circled_kanji_yoru(transliterator: Transliterator):
    """Test ㊰ to (夜)."""
    result = from_chars(transliterator(build_char_list("㊰")))
    assert result == "(夜)"


def test_circled_katakana_a(transliterator: Transliterator):
    """Test ㋐ to (ア)."""
    result = from_chars(transliterator(build_char_list("㋐")))
    assert result == "(ア)"


def test_circled_katakana_wo(transliterator: Transliterator):
    """Test ㋾ to (ヲ)."""
    result = from_chars(transliterator(build_char_list("㋾")))
    assert result == "(ヲ)"


def test_squared_letter_a(transliterator: Transliterator):
    """Test 🅰 to [A]."""
    result = from_chars(transliterator(build_char_list("🅰")))
    assert result == "[A]"


def test_squared_letter_z(transliterator: Transliterator):
    """Test 🆉 to [Z]."""
    result = from_chars(transliterator(build_char_list("🆉")))
    assert result == "[Z]"


def test_regional_indicator_a(transliterator: Transliterator):
    """Test 🇦 to [A]."""
    result = from_chars(transliterator(build_char_list("🇦")))
    assert result == "[A]"


def test_regional_indicator_z(transliterator: Transliterator):
    """Test 🇿 to [Z]."""
    result = from_chars(transliterator(build_char_list("🇿")))
    assert result == "[Z]"


def test_emoji_exclusion_default(transliterator: Transliterator):
    """Test 🅰 (emoji) not processed when includeEmojis is false."""
    result = from_chars(transliterator(build_char_list("🆂🅾🆂")))
    assert result == "[S][O][S]"


def test_empty_string(transliterator: Transliterator):
    """Test empty string."""
    result = from_chars(transliterator(build_char_list("")))
    assert result == ""


def test_unmapped_characters(transliterator: Transliterator):
    """Test unmapped characters."""
    input_text = "hello world 123 abc こんにちは"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == input_text


def test_mixed_content(transliterator: Transliterator):
    """Test mixed content."""
    input_text = "Hello ① World Ⓐ Test"
    expected = "Hello (1) World (A) Test"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected


class TestCustomTemplates:
    @pytest.fixture
    def transliterator(self) -> Transliterator:
        return CircledOrSquaredTransliterator(
            templates={
                "circle": "〔?〕",
                "square": "【?】",
            },
        )

    def test_custom_circle_template(self, transliterator: Transliterator):
        """Test custom circle template."""
        result = from_chars(transliterator(build_char_list("①")))
        assert result == "〔1〕"

    def test_custom_square_template(self, transliterator: Transliterator):
        """Test custom square template."""
        result = from_chars(transliterator(build_char_list("🅰")))
        assert result == "【A】"

    def test_custom_templates_with_kanji(self, transliterator: Transliterator):
        """Test custom templates with kanji."""
        result = from_chars(transliterator(build_char_list("㊀")))
        assert result == "〔一〕"


@pytest.mark.parametrize(
    ("expected", "include_emojis", "input_"),
    [
        ("[SOS]", True, "🆘"),
        ("🆘", False, "🆘"),
    ],
)
def test_include_emojis_true(expected: str, include_emojis: bool, input_: str):
    """Test emoji characters are processed when includeEmojis is true."""
    transliterator = CircledOrSquaredTransliterator(include_emojis=include_emojis)
    result = from_chars(transliterator(build_char_list(input_)))
    assert result == expected


def test_sequence_of_circled_numbers(transliterator: Transliterator):
    """Test sequence of circled numbers."""
    input_text = "①②③④⑤"
    expected = "(1)(2)(3)(4)(5)"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected


def test_sequence_of_circled_letters(transliterator: Transliterator):
    """Test sequence of circled letters."""
    input_text = "ⒶⒷⒸ"
    expected = "(A)(B)(C)"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected


def test_mixed_circles_and_squares(transliterator: Transliterator):
    """Test mixed circles and squares."""
    input_text = "①🅰②🅱"
    expected = "(1)[A](2)[B]"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected


def test_circled_kanji_sequence(transliterator: Transliterator):
    """Test circled kanji sequence."""
    input_text = "㊀㊁㊂㊃㊄"
    expected = "(一)(二)(三)(四)(五)"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected


def test_japanese_text_with_circled_elements(transliterator: Transliterator):
    """Test Japanese text with circled elements."""
    input_text = "項目①は重要で、項目②は補足です。"
    expected = "項目(1)は重要で、項目(2)は補足です。"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected


def test_numbered_list_with_circled_numbers(transliterator: Transliterator):
    """Test numbered list with circled numbers."""
    input_text = "①準備\n②実行\n③確認"
    expected = "(1)準備\n(2)実行\n(3)確認"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected


def test_large_circled_numbers(transliterator: Transliterator):
    """Test large circled numbers."""
    input_text = "㊱㊲㊳"
    expected = "(36)(37)(38)"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected


def test_circled_numbers_up_to_50(transliterator: Transliterator):
    """Test circled numbers up to 50."""
    input_text = "㊿"
    expected = "(50)"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected


def test_special_circled_characters(transliterator: Transliterator):
    """Test special circled characters."""
    input_text = "🄴🅂"
    expected = "[E][S]"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected
