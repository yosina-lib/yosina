# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestCombined < Minitest::Test
  def setup
    @transliterator = Yosina::Transliterators::Combined::Transliterator.new
  end

  def test_null_symbol_to_nul
    result = @transliterator.call(Yosina::Chars.build_char_array("␀")).to_s
    assert_equal "NUL", result
  end

  def test_start_of_heading_to_soh
    result = @transliterator.call(Yosina::Chars.build_char_array("␁")).to_s
    assert_equal "SOH", result
  end

  def test_start_of_text_to_stx
    result = @transliterator.call(Yosina::Chars.build_char_array("␂")).to_s
    assert_equal "STX", result
  end

  def test_backspace_to_bs
    result = @transliterator.call(Yosina::Chars.build_char_array("␈")).to_s
    assert_equal "BS", result
  end

  def test_horizontal_tab_to_ht
    result = @transliterator.call(Yosina::Chars.build_char_array("␉")).to_s
    assert_equal "HT", result
  end

  def test_carriage_return_to_cr
    result = @transliterator.call(Yosina::Chars.build_char_array("␍")).to_s
    assert_equal "CR", result
  end

  def test_space_symbol_to_sp
    result = @transliterator.call(Yosina::Chars.build_char_array("␠")).to_s
    assert_equal "SP", result
  end

  def test_delete_symbol_to_del
    result = @transliterator.call(Yosina::Chars.build_char_array("␡")).to_s
    assert_equal "DEL", result
  end

  def test_parenthesized_number_1
    result = @transliterator.call(Yosina::Chars.build_char_array("⑴")).to_s
    assert_equal "(1)", result
  end

  def test_parenthesized_number_5
    result = @transliterator.call(Yosina::Chars.build_char_array("⑸")).to_s
    assert_equal "(5)", result
  end

  def test_parenthesized_number_10
    result = @transliterator.call(Yosina::Chars.build_char_array("⑽")).to_s
    assert_equal "(10)", result
  end

  def test_parenthesized_number_20
    result = @transliterator.call(Yosina::Chars.build_char_array("⒇")).to_s
    assert_equal "(20)", result
  end

  def test_period_number_1
    result = @transliterator.call(Yosina::Chars.build_char_array("⒈")).to_s
    assert_equal "1.", result
  end

  def test_period_number_10
    result = @transliterator.call(Yosina::Chars.build_char_array("⒑")).to_s
    assert_equal "10.", result
  end

  def test_period_number_20
    result = @transliterator.call(Yosina::Chars.build_char_array("⒛")).to_s
    assert_equal "20.", result
  end

  def test_parenthesized_letter_a
    result = @transliterator.call(Yosina::Chars.build_char_array("⒜")).to_s
    assert_equal "(a)", result
  end

  def test_parenthesized_letter_z
    result = @transliterator.call(Yosina::Chars.build_char_array("⒵")).to_s
    assert_equal "(z)", result
  end

  def test_parenthesized_kanji_ichi
    result = @transliterator.call(Yosina::Chars.build_char_array("㈠")).to_s
    assert_equal "(一)", result
  end

  def test_parenthesized_kanji_getsu
    result = @transliterator.call(Yosina::Chars.build_char_array("㈪")).to_s
    assert_equal "(月)", result
  end

  def test_parenthesized_kanji_kabu
    result = @transliterator.call(Yosina::Chars.build_char_array("㈱")).to_s
    assert_equal "(株)", result
  end

  def test_japanese_unit_apaato
    result = @transliterator.call(Yosina::Chars.build_char_array("㌀")).to_s
    assert_equal "アパート", result
  end

  def test_japanese_unit_kiro
    result = @transliterator.call(Yosina::Chars.build_char_array("㌔")).to_s
    assert_equal "キロ", result
  end

  def test_japanese_unit_meetoru
    result = @transliterator.call(Yosina::Chars.build_char_array("㍍")).to_s
    assert_equal "メートル", result
  end

  def test_scientific_unit_hpa
    result = @transliterator.call(Yosina::Chars.build_char_array("㍱")).to_s
    assert_equal "hPa", result
  end

  def test_scientific_unit_khz
    result = @transliterator.call(Yosina::Chars.build_char_array("㎑")).to_s
    assert_equal "kHz", result
  end

  def test_scientific_unit_kg
    result = @transliterator.call(Yosina::Chars.build_char_array("㎏")).to_s
    assert_equal "kg", result
  end

  def test_combined_control_and_numbers
    result = @transliterator.call(Yosina::Chars.build_char_array("␉⑴␠⒈")).to_s
    assert_equal "HT(1)SP1.", result
  end

  def test_combined_with_regular_text
    result = @transliterator.call(Yosina::Chars.build_char_array("Hello ⑴ World ␉")).to_s
    assert_equal "Hello (1) World HT", result
  end

  def test_empty_string
    result = @transliterator.call(Yosina::Chars.build_char_array("")).to_s
    assert_equal "", result
  end

  def test_unmapped_characters
    input_text = "hello world 123 abc こんにちは"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal input_text, result
  end

  def test_sequence_of_combined_characters
    input_text = "␀␁␂␃␄"
    expected = "NULSOHSTXETXEOT"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end

  def test_japanese_months
    input_text = "㋀㋁㋂"
    expected = "1月2月3月"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end

  def test_japanese_units_combinations
    input_text = "㌀㌁㌂"
    expected = "アパートアルファアンペア"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end

  def test_scientific_measurements
    input_text = "\u3378\u3379\u337a"
    expected = "dm2dm3IU"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end
end