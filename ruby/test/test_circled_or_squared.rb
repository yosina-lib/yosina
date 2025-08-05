# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestCircledOrSquared < Minitest::Test
  def setup
    @transliterator = Yosina::Transliterators::CircledOrSquared::Transliterator.new
  end

  def test_circled_number_1
    result = @transliterator.call(Yosina::Chars.build_char_array("①")).to_s
    assert_equal "(1)", result
  end

  def test_circled_number_2
    result = @transliterator.call(Yosina::Chars.build_char_array("②")).to_s
    assert_equal "(2)", result
  end

  def test_circled_number_20
    result = @transliterator.call(Yosina::Chars.build_char_array("⑳")).to_s
    assert_equal "(20)", result
  end

  def test_circled_number_0
    result = @transliterator.call(Yosina::Chars.build_char_array("⓪")).to_s
    assert_equal "(0)", result
  end

  def test_circled_uppercase_a
    result = @transliterator.call(Yosina::Chars.build_char_array("Ⓐ")).to_s
    assert_equal "(A)", result
  end

  def test_circled_uppercase_z
    result = @transliterator.call(Yosina::Chars.build_char_array("Ⓩ")).to_s
    assert_equal "(Z)", result
  end

  def test_circled_lowercase_a
    result = @transliterator.call(Yosina::Chars.build_char_array("ⓐ")).to_s
    assert_equal "(a)", result
  end

  def test_circled_lowercase_z
    result = @transliterator.call(Yosina::Chars.build_char_array("ⓩ")).to_s
    assert_equal "(z)", result
  end

  def test_circled_kanji_ichi
    result = @transliterator.call(Yosina::Chars.build_char_array("㊀")).to_s
    assert_equal "(一)", result
  end

  def test_circled_kanji_getsu
    result = @transliterator.call(Yosina::Chars.build_char_array("㊊")).to_s
    assert_equal "(月)", result
  end

  def test_circled_kanji_yoru
    result = @transliterator.call(Yosina::Chars.build_char_array("㊰")).to_s
    assert_equal "(夜)", result
  end

  def test_circled_katakana_a
    result = @transliterator.call(Yosina::Chars.build_char_array("㋐")).to_s
    assert_equal "(ア)", result
  end

  def test_circled_katakana_wo
    result = @transliterator.call(Yosina::Chars.build_char_array("㋾")).to_s
    assert_equal "(ヲ)", result
  end

  def test_squared_letter_a
    result = @transliterator.call(Yosina::Chars.build_char_array("🅰")).to_s
    assert_equal "[A]", result
  end

  def test_squared_letter_z
    result = @transliterator.call(Yosina::Chars.build_char_array("🆉")).to_s
    assert_equal "[Z]", result
  end

  def test_regional_indicator_a
    result = @transliterator.call(Yosina::Chars.build_char_array("🇦")).to_s
    assert_equal "[A]", result
  end

  def test_regional_indicator_z
    result = @transliterator.call(Yosina::Chars.build_char_array("🇿")).to_s
    assert_equal "[Z]", result
  end

  def test_emoji_exclusion_default
    result = @transliterator.call(Yosina::Chars.build_char_array("🆂🅾🆂")).to_s
    assert_equal "[S][O][S]", result
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

  def test_mixed_content
    input_text = "Hello ① World Ⓐ Test"
    expected = "Hello (1) World (A) Test"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end
end

class TestCircledOrSquaredIncludeEmojis < Minitest::Test
  def test_include_emojis_true
    transliterator = Yosina::Transliterators::CircledOrSquared::Transliterator.new(include_emojis: true)
    result = transliterator.call(Yosina::Chars.build_char_array("🆘")).to_s
    assert_equal "[SOS]", result
  end

  def test_include_emojis_true_non_emoji
    transliterator = Yosina::Transliterators::CircledOrSquared::Transliterator.new(include_emojis: false)
    result = transliterator.call(Yosina::Chars.build_char_array("🆘")).to_s
    assert_equal "🆘", result
  end
end

class TestCircledOrSquaredComplexScenarios < Minitest::Test
  def setup
    @transliterator = Yosina::Transliterators::CircledOrSquared::Transliterator.new
  end

  def test_sequence_of_circled_numbers
    input_text = "①②③④⑤"
    expected = "(1)(2)(3)(4)(5)"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end

  def test_sequence_of_circled_letters
    input_text = "ⒶⒷⒸ"
    expected = "(A)(B)(C)"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end

  def test_mixed_circles_and_squares
    input_text = "①🅰②🅱"
    expected = "(1)[A](2)[B]"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end

  def test_circled_kanji_sequence
    input_text = "㊀㊁㊂㊃㊄"
    expected = "(一)(二)(三)(四)(五)"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end

  def test_japanese_text_with_circled_elements
    input_text = "項目①は重要で、項目②は補足です。"
    expected = "項目(1)は重要で、項目(2)は補足です。"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end

  def test_numbered_list_with_circled_numbers
    input_text = "①準備\n②実行\n③確認"
    expected = "(1)準備\n(2)実行\n(3)確認"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end
end

class TestCircledOrSquaredEdgeCases < Minitest::Test
  def setup
    @transliterator = Yosina::Transliterators::CircledOrSquared::Transliterator.new
  end

  def test_large_circled_numbers
    input_text = "㊱㊲㊳"
    expected = "(36)(37)(38)"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end

  def test_circled_numbers_up_to_50
    input_text = "㊿"
    expected = "(50)"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end

  def test_special_circled_characters
    input_text = "🄴🅂"
    expected = "[E][S]"
    result = @transliterator.call(Yosina::Chars.build_char_array(input_text)).to_s
    assert_equal expected, result
  end
end