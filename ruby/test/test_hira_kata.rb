# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestHiraKata < Minitest::Test
  def test_hira_to_kata_basic
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :hira_to_kata)
    
    input = 'あいうえお'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'アイウエオ', result
  end

  def test_hira_to_kata_voiced
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :hira_to_kata)
    
    input = 'がぎぐげご'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'ガギグゲゴ', result
  end

  def test_hira_to_kata_semi_voiced
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :hira_to_kata)
    
    input = 'ぱぴぷぺぽ'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'パピプペポ', result
  end

  def test_hira_to_kata_small
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :hira_to_kata)
    
    input = 'ぁぃぅぇぉっゃゅょ'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'ァィゥェォッャュョ', result
  end

  def test_hira_to_kata_mixed
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :hira_to_kata)
    
    input = 'あいうえお123ABCアイウエオ'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'アイウエオ123ABCアイウエオ', result
  end

  def test_hira_to_kata_sentence
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :hira_to_kata)
    
    input = 'こんにちは、世界！'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'コンニチハ、世界！', result
  end

  def test_kata_to_hira_basic
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :kata_to_hira)
    
    input = 'アイウエオ'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'あいうえお', result
  end

  def test_kata_to_hira_voiced
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :kata_to_hira)
    
    input = 'ガギグゲゴ'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'がぎぐげご', result
  end

  def test_kata_to_hira_semi_voiced
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :kata_to_hira)
    
    input = 'パピプペポ'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'ぱぴぷぺぽ', result
  end

  def test_kata_to_hira_small
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :kata_to_hira)
    
    input = 'ァィゥェォッャュョ'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'ぁぃぅぇぉっゃゅょ', result
  end

  def test_kata_to_hira_mixed
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :kata_to_hira)
    
    input = 'アイウエオ123ABCあいうえお'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'あいうえお123ABCあいうえお', result
  end

  def test_kata_to_hira_sentence
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :kata_to_hira)
    
    input = 'コンニチハ、世界！'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'こんにちは、世界！', result
  end

  def test_kata_to_hira_vu
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :kata_to_hira)
    
    input = 'ヴ'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'ゔ', result
  end

  def test_kata_to_hira_special_unchanged
    transliterator = Yosina::Transliterators::HiraKata.call(mode: :kata_to_hira)
    
    input = 'ヷヸヹヺ'
    chars = Yosina::Chars.build_char_array(input)
    result = transliterator.call(chars).map(&:c).join
    
    assert_equal 'ヷヸヹヺ', result
  end

  def test_caching_behavior
    # Clear cache first
    Yosina::Transliterators::HiraKata.mapping_cache.clear
    
    # Create two instances with the same mode
    t1 = Yosina::Transliterators::HiraKata.call(mode: :hira_to_kata)
    t2 = Yosina::Transliterators::HiraKata.call(mode: :hira_to_kata)
    
    # Both should use the same cached table
    assert Yosina::Transliterators::HiraKata.mapping_cache.key?(:hira_to_kata)
    assert_equal 1, Yosina::Transliterators::HiraKata.mapping_cache.keys.size
    
    # Create instance with different mode
    t3 = Yosina::Transliterators::HiraKata.call(mode: :kata_to_hira)
    
    # Now cache should have both modes
    assert Yosina::Transliterators::HiraKata.mapping_cache.key?(:kata_to_hira)
    assert_equal 2, Yosina::Transliterators::HiraKata.mapping_cache.keys.size
  end
end