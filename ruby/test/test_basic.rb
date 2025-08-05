# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestBasic < Minitest::Test
  def test_char_creation
    char = Yosina::Char.new(c: 'a', offset: 0)
    assert_equal 'a', char.c
    assert_equal 0, char.offset
    assert_nil char.source
  end

  def test_build_char_array
    result = Yosina::Chars.build_char_array('hello')
    assert_equal 6, result.length
    assert_equal 'h', result[0].c
    assert_equal 0, result[0].offset
    assert_equal 'o', result[4].c
    assert_equal 4, result[4].offset
  end

  def test_as_s
    chars = [
      Yosina::Char.new(c: 'h', offset: 0),
      Yosina::Char.new(c: 'e', offset: 1),
      Yosina::Char.new(c: 'l', offset: 2),
      Yosina::Char.new(c: 'l', offset: 3),
      Yosina::Char.new(c: 'o', offset: 4),
      Yosina::Char.new(c: '', offset: 5),
    ]
    result = Yosina::Chars.as_s(chars)
    assert_equal 'hello', result
  end

  def test_chars_extension
    chars = [
      Yosina::Char.new(c: 'h', offset: 0),
      Yosina::Char.new(c: 'e', offset: 1),
      Yosina::Char.new(c: 'l', offset: 2),
      Yosina::Char.new(c: 'l', offset: 3),
      Yosina::Char.new(c: 'o', offset: 4),
      Yosina::Char.new(c: '', offset: 5),
    ]
    class << chars
      include Yosina::Chars
    end
    assert_equal 'hello', chars.to_s
    assert_equal 6, chars.each.count
    assert_equal 'll', chars.select { |c| c.c == 'l' }.to_s
    assert_equal 'h-el-l-o-', chars.chunk { |c| c.offset % 3 != 0 }.map { |k, chunk| "#{chunk.to_s}-" }.join
    assert_equal 'olleh', chars.sort_by {|c| -c.offset }.to_s
    assert_equal({ 'h' => 'h', 'e' => 'e', 'l' => 'll', 'o' => 'o', '' => ''}, chars.group_by {|c| c.c }.transform_values(&:to_s))
  end

  def test_make_transliterator_with_space_normalization
    recipe = Yosina::TransliterationRecipe.new(replace_spaces: true)
    transliterator = Yosina.make_transliterator(recipe)

    # Test with ideographic space (should be normalized to regular space)
    test_input = "hello\u3000world" # ideographic space
    result = transliterator.call(test_input)
    assert_equal 'hello world', result
  end

  def test_make_transliterator_with_configs
    configs = [Yosina::TransliteratorConfig.new(:spaces)]
    transliterator = Yosina.make_transliterator(configs)

    # Test with ideographic space
    test_input = "hello\u3000world"
    result = transliterator.call(test_input)
    assert_equal 'hello world', result
  end

  def test_make_transliterator_with_string_configs
    configs = [:spaces]
    transliterator = Yosina.make_transliterator(configs)

    # Test with ideographic space
    test_input = "hello\u3000world"
    result = transliterator.call(test_input)
    assert_equal 'hello world', result
  end

  def test_invalid_transliterator_name
    assert_raises(Yosina::TransliteratorFactoryError) do
      Yosina.make_transliterator([:invalid_name])
    end
  end

  def test_chained_transliterators
    recipe = Yosina::TransliterationRecipe.new(
      replace_spaces: true,
      kanji_old_new: true
    )
    transliterator = Yosina.make_transliterator(recipe)

    # Test with ideographic space
    test_input = "hello\u3000world"
    result = transliterator.call(test_input)
    assert_equal 'hello world', result
  end
end
