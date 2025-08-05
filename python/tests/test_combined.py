"""Tests for combined transliterator."""

import pytest

from yosina.chars import build_char_list, from_chars
from yosina.transliterators.combined import Transliterator as CombinedTransliterator
from yosina.types import Transliterator


@pytest.fixture
def transliterator() -> Transliterator:
    return CombinedTransliterator()


def test_null_symbol_to_nul(transliterator: Transliterator):
    """Test null symbol to NUL."""
    result = from_chars(transliterator(build_char_list("␀")))
    assert result == "NUL"


def test_start_of_heading_to_soh(transliterator: Transliterator):
    """Test start of heading to SOH."""
    result = from_chars(transliterator(build_char_list("␁")))
    assert result == "SOH"


def test_start_of_text_to_stx(transliterator: Transliterator):
    """Test start of text to STX."""
    result = from_chars(transliterator(build_char_list("␂")))
    assert result == "STX"


def test_backspace_to_bs(transliterator: Transliterator):
    """Test backspace to BS."""
    result = from_chars(transliterator(build_char_list("␈")))
    assert result == "BS"


def test_horizontal_tab_to_ht(transliterator: Transliterator):
    """Test horizontal tab to HT."""
    result = from_chars(transliterator(build_char_list("␉")))
    assert result == "HT"


def test_carriage_return_to_cr(transliterator: Transliterator):
    """Test carriage return to CR."""
    result = from_chars(transliterator(build_char_list("␍")))
    assert result == "CR"


def test_space_symbol_to_sp(transliterator: Transliterator):
    """Test space symbol to SP."""
    result = from_chars(transliterator(build_char_list("␠")))
    assert result == "SP"


def test_delete_symbol_to_del(transliterator: Transliterator):
    """Test delete symbol to DEL."""
    result = from_chars(transliterator(build_char_list("␡")))
    assert result == "DEL"


def test_parenthesized_number_1(transliterator: Transliterator):
    """Test (1) to (1)."""
    result = from_chars(transliterator(build_char_list("⑴")))
    assert result == "(1)"


def test_parenthesized_number_5(transliterator: Transliterator):
    """Test (5) to (5)."""
    result = from_chars(transliterator(build_char_list("⑸")))
    assert result == "(5)"


def test_parenthesized_number_10(transliterator: Transliterator):
    """Test (10) to (10)."""
    result = from_chars(transliterator(build_char_list("⑽")))
    assert result == "(10)"


def test_parenthesized_number_20(transliterator: Transliterator):
    """Test (20) to (20)."""
    result = from_chars(transliterator(build_char_list("⒇")))
    assert result == "(20)"


def test_period_number_1(transliterator: Transliterator):
    """Test 1. to 1."""
    result = from_chars(transliterator(build_char_list("⒈")))
    assert result == "1."


def test_period_number_10(transliterator: Transliterator):
    """Test 10. to 10."""
    result = from_chars(transliterator(build_char_list("⒑")))
    assert result == "10."


def test_period_number_20(transliterator: Transliterator):
    """Test 20. to 20."""
    result = from_chars(transliterator(build_char_list("⒛")))
    assert result == "20."


def test_parenthesized_letter_a(transliterator: Transliterator):
    """Test (a) to (a)."""
    result = from_chars(transliterator(build_char_list("⒜")))
    assert result == "(a)"


def test_parenthesized_letter_z(transliterator: Transliterator):
    """Test (z) to (z)."""
    result = from_chars(transliterator(build_char_list("⒵")))
    assert result == "(z)"


def test_parenthesized_kanji_ichi(transliterator: Transliterator):
    """Test (一) to (一)."""
    result = from_chars(transliterator(build_char_list("㈠")))
    assert result == "(一)"


def test_parenthesized_kanji_getsu(transliterator: Transliterator):
    """Test (月) to (月)."""
    result = from_chars(transliterator(build_char_list("㈪")))
    assert result == "(月)"


def test_parenthesized_kanji_kabu(transliterator: Transliterator):
    """Test (株) to (株)."""
    result = from_chars(transliterator(build_char_list("㈱")))
    assert result == "(株)"


def test_japanese_unit_apaato(transliterator: Transliterator):
    """Test アパート to アパート."""
    result = from_chars(transliterator(build_char_list("㌀")))
    assert result == "アパート"


def test_japanese_unit_kiro(transliterator: Transliterator):
    """Test キロ to キロ."""
    result = from_chars(transliterator(build_char_list("㌔")))
    assert result == "キロ"


def test_japanese_unit_meetoru(transliterator: Transliterator):
    """Test メートル to メートル."""
    result = from_chars(transliterator(build_char_list("㍍")))
    assert result == "メートル"


def test_scientific_unit_hpa(transliterator: Transliterator):
    """Test hPa to hPa."""
    result = from_chars(transliterator(build_char_list("㍱")))
    assert result == "hPa"


def test_scientific_unit_khz(transliterator: Transliterator):
    """Test kHz to kHz."""
    result = from_chars(transliterator(build_char_list("㎑")))
    assert result == "kHz"


def test_scientific_unit_kg(transliterator: Transliterator):
    """Test kg to kg."""
    result = from_chars(transliterator(build_char_list("㎏")))
    assert result == "kg"


def test_combined_control_and_numbers(transliterator: Transliterator):
    """Test combined control and numbers."""
    result = from_chars(transliterator(build_char_list("␉⑴␠⒈")))
    assert result == "HT(1)SP1."


def test_combined_with_regular_text(transliterator: Transliterator):
    """Test combined with regular text."""
    result = from_chars(transliterator(build_char_list("Hello ⑴ World ␉")))
    assert result == "Hello (1) World HT"


def test_empty_string(transliterator: Transliterator):
    """Test empty string."""
    result = from_chars(transliterator(build_char_list("")))
    assert result == ""


def test_unmapped_characters(transliterator: Transliterator):
    """Test unmapped characters."""
    input_text = "hello world 123 abc こんにちは"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == input_text


def test_sequence_of_combined_characters(transliterator: Transliterator):
    """Test sequence of combined characters."""
    input_text = "␀␁␂␃␄"
    expected = "NULSOHSTXETXEOT"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected


def test_japanese_months(transliterator: Transliterator):
    """Test Japanese months."""
    input_text = "㋀㋁㋂"
    expected = "1月2月3月"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected


def test_japanese_units_combinations(transliterator: Transliterator):
    """Test Japanese units combinations."""
    input_text = "㌀㌁㌂"
    expected = "アパートアルファアンペア"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected


def test_scientific_measurements(transliterator: Transliterator):
    """Test scientific measurements."""
    input_text = "\u3378\u3379\u337a"
    expected = "dm2dm3IU"
    result = from_chars(transliterator(build_char_list(input_text)))
    assert result == expected
