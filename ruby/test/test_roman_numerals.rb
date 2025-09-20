# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestRomanNumerals < Minitest::Test
  def setup
    @transliterator = Yosina::Transliterators::RomanNumerals.call
  end

  # Test data for Roman numerals transliterations - uppercase
  UPPERCASE_TEST_CASES = [
    ['I', 'Ⅰ', 'Roman I'],
    ['II', 'Ⅱ', 'Roman II'],
    ['III', 'Ⅲ', 'Roman III'],
    ['IV', 'Ⅳ', 'Roman IV'],
    ['V', 'Ⅴ', 'Roman V'],
    ['VI', 'Ⅵ', 'Roman VI'],
    ['VII', 'Ⅶ', 'Roman VII'],
    ['VIII', 'Ⅷ', 'Roman VIII'],
    ['IX', 'Ⅸ', 'Roman IX'],
    ['X', 'Ⅹ', 'Roman X'],
    ['XI', 'Ⅺ', 'Roman XI'],
    ['XII', 'Ⅻ', 'Roman XII'],
    ['L', 'Ⅼ', 'Roman L'],
    ['C', 'Ⅽ', 'Roman C'],
    ['D', 'Ⅾ', 'Roman D'],
    ['M', 'Ⅿ', 'Roman M']
  ].freeze

  # Test data for Roman numerals transliterations - lowercase
  LOWERCASE_TEST_CASES = [
    ['i', 'ⅰ', 'Roman i'],
    ['ii', 'ⅱ', 'Roman ii'],
    ['iii', 'ⅲ', 'Roman iii'],
    ['iv', 'ⅳ', 'Roman iv'],
    ['v', 'ⅴ', 'Roman v'],
    ['vi', 'ⅵ', 'Roman vi'],
    ['vii', 'ⅶ', 'Roman vii'],
    ['viii', 'ⅷ', 'Roman viii'],
    ['ix', 'ⅸ', 'Roman ix'],
    ['x', 'ⅹ', 'Roman x'],
    ['xi', 'ⅺ', 'Roman xi'],
    ['xii', 'ⅻ', 'Roman xii'],
    ['l', 'ⅼ', 'Roman l'],
    ['c', 'ⅽ', 'Roman c'],
    ['d', 'ⅾ', 'Roman d'],
    ['m', 'ⅿ', 'Roman m']
  ].freeze

  # Test uppercase Roman numerals
  UPPERCASE_TEST_CASES.each_with_index do |(expected, input, description), i|
    define_method("test_#{i}_uppercase_#{description.downcase.gsub(/\s+/, '_')}") do
      result = process_string(input)
      assert_equal expected, result, description
    end
  end

  # Test lowercase Roman numerals  
  LOWERCASE_TEST_CASES.each_with_index do |(expected, input, description), i|
    define_method("test_#{i}_lowercase_#{description.downcase.gsub(/\s+/, '_')}") do
      result = process_string(input)
      assert_equal expected, result, description
    end
  end

  def test_mixed_text_with_year
    input = 'Year Ⅻ'
    expected = 'Year XII'
    result = process_string(input)
    assert_equal expected, result, 'Should convert Roman numeral in year context'
  end

  def test_mixed_text_with_chapter
    input = 'Chapter ⅳ'
    expected = 'Chapter iv'
    result = process_string(input)
    assert_equal expected, result, 'Should convert lowercase Roman numeral in chapter context'
  end

  def test_mixed_text_with_section
    input = 'Section Ⅲ.A'
    expected = 'Section III.A'
    result = process_string(input)
    assert_equal expected, result, 'Should convert Roman numeral with period'
  end

  def test_multiple_uppercase_romans
    input = 'Ⅰ Ⅱ Ⅲ'
    expected = 'I II III'
    result = process_string(input)
    assert_equal expected, result, 'Should convert multiple uppercase Roman numerals'
  end

  def test_multiple_lowercase_romans
    input = 'ⅰ, ⅱ, ⅲ'
    expected = 'i, ii, iii'
    result = process_string(input)
    assert_equal expected, result, 'Should convert multiple lowercase Roman numerals'
  end

  def test_empty_string
    result = process_string('')
    assert_equal '', result, 'Empty string should remain empty'
  end

  def test_unmapped_characters
    input = 'ABC123'
    result = process_string(input)
    assert_equal input, result, 'Characters without Roman numerals should remain unchanged'
  end

  def test_consecutive_romans
    input = 'ⅠⅡⅢ'
    expected = 'IIIIII'
    result = process_string(input)
    assert_equal expected, result, 'Consecutive Roman numerals should be converted individually'
  end

  def test_factory_creation
    factory = Yosina::Transliterators::RomanNumerals
    transliterator = factory.call
    assert_instance_of Yosina::Transliterators::RomanNumerals::Transliterator, transliterator
  end

  def test_iterator_properties
    input = 'Ⅰ Ⅱ Ⅲ'
    chars = Yosina::Chars.build_char_array(input)
    result = @transliterator.call(chars).to_a
    refute_nil result
    assert result.length > 0
  end

  private

  def process_string(input)
    chars = Yosina::Chars.build_char_array(input)
    result = @transliterator.call(chars)
    result.to_s
  end
end