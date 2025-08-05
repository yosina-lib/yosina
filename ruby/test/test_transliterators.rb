# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestTransliterators < Minitest::Test
  def test_spaces_transliterator
    factory = Yosina::Transliterators::Spaces
    transliterator = factory.call

    chars = [
      Yosina::Char.new(c: "\u3000", offset: 0), # ideographic space
      Yosina::Char.new(c: 'a', offset: 1),
      Yosina::Char.new(c: "\u00a0", offset: 2) # no-break space
    ]

    result = transliterator.call(chars).to_a
    assert_equal ' ', result[0].c
    assert_equal 'a', result[1].c
    assert_equal ' ', result[2].c
  end

  def test_spaces_transliterator_removes_chars
    factory = Yosina::Transliterators::Spaces
    transliterator = factory.call

    chars = [
      Yosina::Char.new(c: "\ufeff", offset: 0), # zero width no-break space (should be removed)
      Yosina::Char.new(c: 'a', offset: 1)
    ]

    result = transliterator.call(chars).to_a
    assert_equal 1, result.length
    assert_equal 'a', result[0].c
  end

  def test_radicals_transliterator
    factory = Yosina::Transliterators::Radicals
    transliterator = factory.call

    # Test that it creates without error
    assert_instance_of Yosina::Transliterators::Radicals::Transliterator, transliterator

    # Test basic functionality (pass-through for non-radical chars)
    chars = [Yosina::Char.new(c: 'a', offset: 0)]
    result = transliterator.call(chars).to_a
    assert_equal 1, result.length
    assert_equal 'a', result[0].c
  end

  def test_kanji_old_new_transliterator
    factory = Yosina::Transliterators::KanjiOldNew
    transliterator = factory.call

    # Test that it creates without error
    assert_instance_of Yosina::Transliterators::KanjiOldNew::Transliterator, transliterator

    # Test basic functionality
    chars = [Yosina::Char.new(c: 'a', offset: 0)]
    result = transliterator.call(chars).to_a
    assert_equal 1, result.length
    assert_equal 'a', result[0].c
  end

  def test_mathematical_alphanumerics_transliterator
    factory = Yosina::Transliterators::MathematicalAlphanumerics
    transliterator = factory.call

    # Test that it creates without error
    assert_instance_of Yosina::Transliterators::MathematicalAlphanumerics::Transliterator, transliterator

    # Test basic functionality
    chars = [Yosina::Char.new(c: 'a', offset: 0)]
    result = transliterator.call(chars).to_a
    assert_equal 1, result.length
    assert_equal 'a', result[0].c
  end

  def test_ideographic_annotations_transliterator
    factory = Yosina::Transliterators::IdeographicAnnotations
    transliterator = factory.call

    # Test that it creates without error
    assert_instance_of Yosina::Transliterators::IdeographicAnnotations::Transliterator, transliterator

    # Test basic functionality
    chars = [Yosina::Char.new(c: 'a', offset: 0)]
    result = transliterator.call(chars).to_a
    assert_equal 1, result.length
    assert_equal 'a', result[0].c
  end

  def test_stub_transliterators
    # Test all stub transliterators
    stub_factories = [
      Yosina::Transliterators::Hyphens,
      Yosina::Transliterators::HiraKataComposition,
      Yosina::Transliterators::IvsSvsBase,
      Yosina::Transliterators::ProlongedSoundMarks,
      Yosina::Transliterators::Jisx0201AndAlike
    ]

    stub_factories.each do |factory|
      transliterator = factory.call

      # Test basic functionality (should pass through unchanged)
      chars = [Yosina::Char.new(c: 'test', offset: 0)]
      result = transliterator.call(chars).to_a
      assert_equal 1, result.length
      assert_equal 'test', result[0].c
    end
  end
end
