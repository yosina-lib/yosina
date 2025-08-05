# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestHyphens < Minitest::Test
  def test_default_precedence_jisx0208_90
    # Test with default precedence ["jisx0208_90"]
    transliterator = Yosina::Transliterators::Hyphens.call

    # Hyphen-minus should be converted to minus sign in JIS X 0208-90
    input_str = "test\u002dhyphen"    # ASCII hyphen-minus
    expected = "test\u2212hyphen"     # minus sign

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    # This will fail because Ruby implementation is stub
    assert_equal expected, result, "Should convert hyphen-minus to minus sign with default precedence"
  end

  def test_ascii_precedence
    # Test with ASCII precedence
    transliterator = Yosina::Transliterators::Hyphens.call({ precedence: ['ascii'] })

    # Hyphen should remain as ASCII hyphen
    input_str = "test\u002dhyphen"
    expected = "test\u002dhyphen"

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    # This will fail because Ruby implementation is stub
    assert_equal expected, result, "Should keep ASCII hyphen with ASCII precedence"
  end

  def test_jisx0201_precedence
    # Test with JIS X 0201 precedence
    transliterator = Yosina::Transliterators::Hyphens.call({ precedence: ['jisx0201'] })

    input_str = "test\u002dhyphen"
    expected = "test\u002dhyphen" # JIS X 0201 maps to ASCII hyphen

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    # This will fail because Ruby implementation is stub
    assert_equal expected, result, "Should use JIS X 0201 mapping"
  end

  def test_multiple_precedence_order
    # Test with multiple precedence options
    transliterator = Yosina::Transliterators::Hyphens.call({
                                                             precedence: ['jisx0201', 'jisx0208_90']
                                                           })

    input_str = "test\u002dhyphen"
    expected = "test\u002dhyphen" # Should use first available (jisx0201)

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    # This will fail because Ruby implementation is stub
    assert_equal expected, result, "Should use first available precedence option"
  end

  def test_various_hyphen_characters
    # Test with various hyphen/dash characters
    transliterator = Yosina::Transliterators::Hyphens.call({ precedence: ['jisx0208_90'] })

    # Test different hyphen characters
    test_cases = [
      ["\u002d", "\u2212"],    # hyphen-minus -> minus sign
      ["\u2010", "\u2010"],    # hyphen -> hyphen (unchanged with jisx0208_90)
      ["\u2014", "\u2014"],    # em dash -> em dash (unchanged with jisx0208_90)
      ["\u2015", "\u2015"],    # horizontal bar -> horizontal bar (unchanged with jisx0208_90)
      ["\uff0d", "\u2212"],    # fullwidth hyphen-minus -> minus sign
    ]

    test_cases.each do |input_char, expected_char|
      input_str = "test#{input_char}char"
      expected = "test#{expected_char}char"

      chars = Yosina::Chars.build_char_array(input_str)
      result_chars = transliterator.call(chars)
      result = result_chars.to_s

      # This will fail because Ruby implementation is stub
      assert_equal expected, result, "Should convert #{input_char} to #{expected_char}"
    end
  end

  def test_no_mapping_available
    # Test character that has no mapping for given precedence
    transliterator = Yosina::Transliterators::Hyphens.call({ precedence: ['ascii'] })

    # Use a character that only maps to non-ASCII - horizontal bar has ASCII mapping
    input_str = "test\u2015char"    # horizontal bar
    expected = "test-char"          # should convert to ASCII hyphen

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    # This will fail because Ruby implementation is stub
    assert_equal expected, result, "Should remain unchanged when no mapping available"
  end

  def test_mixed_content
    # Test mixed content with hyphens
    transliterator = Yosina::Transliterators::Hyphens.call

    input_str = "hello\u002dworld\u2014test\uff0dexample"
    expected = "hello\u2212world\u2014test\u2212example"

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    # This will fail because Ruby implementation is stub
    assert_equal expected, result, "Should handle mixed content with multiple hyphen types"
  end
end
