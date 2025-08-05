# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestCombined < Minitest::Test
  def setup
    @transliterator = Yosina::Transliterators::Combined::Transliterator.new
  end

  def test_null_symbol_to_nul
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("␀")))
    assert_equal "NUL", result
  end

  def test_start_of_heading_to_soh
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("␁")))
    assert_equal "SOH", result
  end

  def test_start_of_text_to_stx
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("␂")))
    assert_equal "STX", result
  end

  def test_backspace_to_bs
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("␈")))
    assert_equal "BS", result
  end

  def test_horizontal_tab_to_ht
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("␉")))
    assert_equal "HT", result
  end

  def test_carriage_return_to_cr
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("␍")))
    assert_equal "CR", result
  end

  def test_space_symbol_to_sp
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("␠")))
    assert_equal "SP", result
  end

  def test_delete_symbol_to_del
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("␡")))
    assert_equal "DEL", result
  end

  def test_parenthesized_number_1
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("⑴")))
    assert_equal "(1)", result
  end

  def test_parenthesized_number_5
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("⑸")))
    assert_equal "(5)", result
  end

  def test_parenthesized_number_10
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("⑽")))
    assert_equal "(10)", result
  end

  def test_parenthesized_number_20
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("⒇")))
    assert_equal "(20)", result
  end

  def test_period_number_1
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("⒈")))
    assert_equal "1.", result
  end

  def test_period_number_10
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("⒑")))
    assert_equal "10.", result
  end

  def test_period_number_20
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("⒛")))
    assert_equal "20.", result
  end

  def test_parenthesized_letter_a
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("⒜")))
    assert_equal "(a)", result
  end

  def test_parenthesized_letter_z
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("⒵")))
    assert_equal "(z)", result
  end

  def test_parenthesized_kanji_ichi
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("㈠")))
    assert_equal "(一)", result
  end

  def test_parenthesized_kanji_getsu
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("㈪")))
    assert_equal "(月)", result
  end

  def test_parenthesized_kanji_kabu
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("㈱")))
    assert_equal "(株)", result
  end

  def test_japanese_unit_apaato
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("㌀")))
    assert_equal "アパート", result
  end

  def test_japanese_unit_kiro
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("㌔")))
    assert_equal "キロ", result
  end

  def test_japanese_unit_meetoru
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("㍍")))
    assert_equal "メートル", result
  end

  def test_scientific_unit_hpa
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("㍱")))
    assert_equal "hPa", result
  end

  def test_scientific_unit_khz
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("㎑")))
    assert_equal "kHz", result
  end

  def test_scientific_unit_kg
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("㎏")))
    assert_equal "kg", result
  end

  def test_combined_control_and_numbers
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("␉⑴␠⒈")))
    assert_equal "HT(1)SP1.", result
  end

  def test_combined_with_regular_text
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("Hello ⑴ World ␉")))
    assert_equal "Hello (1) World HT", result
  end

  def test_empty_string
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array("")))
    assert_equal "", result
  end

  def test_unmapped_characters
    input_text = "hello world 123 abc こんにちは"
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array(input_text)))
    assert_equal input_text, result
  end

  def test_sequence_of_combined_characters
    input_text = "␀␁␂␃␄"
    expected = "NULSOHSTXETXEOT"
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array(input_text)))
    assert_equal expected, result
  end

  def test_japanese_months
    input_text = "㋀㋁㋂"
    expected = "1月2月3月"
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array(input_text)))
    assert_equal expected, result
  end

  def test_japanese_units_combinations
    input_text = "㌀㌁㌂"
    expected = "アパートアルファアンペア"
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array(input_text)))
    assert_equal expected, result
  end

  def test_scientific_measurements
    input_text = "\u3378\u3379\u337a"
    expected = "dm2dm3IU"
    result = Yosina::Chars.from_chars(@transliterator.call(Yosina::Chars.build_char_array(input_text)))
    assert_equal expected, result
  end
end