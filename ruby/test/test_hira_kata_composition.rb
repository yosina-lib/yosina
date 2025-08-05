# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestHiraKataComposition < Minitest::Test
  def setup
    @factory = Yosina::Transliterators::HiraKataComposition
  end

  def test_combining_voiced_marks_hiragana
    transliterator = @factory.call

    # Test basic hiragana combinations
    test_cases = [
      ['か', '゙', 'が'],
      ['き', '゙', 'ぎ'],
      ['く', '゙', 'ぐ'],
      ['け', '゙', 'げ'],
      ['こ', '゙', 'ご'],
      ['さ', '゙', 'ざ'],
      ['し', '゙', 'じ'],
      ['す', '゙', 'ず'],
      ['せ', '゙', 'ぜ'],
      ['そ', '゙', 'ぞ'],
      ['た', '゙', 'だ'],
      ['ち', '゙', 'ぢ'],
      ['つ', '゙', 'づ'],
      ['て', '゙', 'で'],
      ['と', '゙', 'ど'],
      ['は', '゙', 'ば'],
      ['ひ', '゙', 'び'],
      ['ふ', '゙', 'ぶ'],
      ['へ', '゙', 'べ'],
      ['ほ', '゙', 'ぼ'],
      ['う', '゙', 'ゔ']
    ]

    test_cases.each do |base, mark, expected|
      chars = [
        Yosina::Char.new(c: base, offset: 0),
        Yosina::Char.new(c: mark, offset: 1)
      ]
      result = transliterator.call(chars).to_a
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected #{base}#{mark} → #{expected}"
    end
  end

  def test_combining_semi_voiced_marks_hiragana
    transliterator = @factory.call(:compose_non_combining_marks => true)

    # Test hiragana h-series → p-series
    test_cases = [
      ['は', '゜', 'ぱ'],
      ['ひ', '゜', 'ぴ'],
      ['ふ', '゜', 'ぷ'],
      ['へ', '゜', 'ぺ'],
      ['ほ', '゜', 'ぽ']
    ]

    test_cases.each do |base, mark, expected|
      chars = [
        Yosina::Char.new(c: base, offset: 0),
        Yosina::Char.new(c: mark, offset: 1)
      ]
      result = transliterator.call(chars).to_a
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected #{base}#{mark} → #{expected}"
    end
  end

  def test_combining_voiced_marks_katakana
    transliterator = @factory.call

    # Test basic katakana combinations
    test_cases = [
      ['カ', '゙', 'ガ'],
      ['キ', '゙', 'ギ'],
      ['ク', '゙', 'グ'],
      ['ケ', '゙', 'ゲ'],
      ['コ', '゙', 'ゴ'],
      ['サ', '゙', 'ザ'],
      ['シ', '゙', 'ジ'],
      ['ス', '゙', 'ズ'],
      ['セ', '゙', 'ゼ'],
      ['ソ', '゙', 'ゾ'],
      ['タ', '゙', 'ダ'],
      ['チ', '゙', 'ヂ'],
      ['ツ', '゙', 'ヅ'],
      ['テ', '゙', 'デ'],
      ['ト', '゙', 'ド'],
      ['ハ', '゙', 'バ'],
      ['ヒ', '゙', 'ビ'],
      ['フ', '゙', 'ブ'],
      ['ヘ', '゙', 'ベ'],
      ['ホ', '゙', 'ボ'],
      ['ウ', '゙', 'ヴ']
    ]

    test_cases.each do |base, mark, expected|
      chars = [
        Yosina::Char.new(c: base, offset: 0),
        Yosina::Char.new(c: mark, offset: 1)
      ]
      result = transliterator.call(chars).to_a
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected #{base}#{mark} → #{expected}"
    end
  end

  def test_combining_semi_voiced_marks_katakana
    transliterator = @factory.call(:compose_non_combining_marks => true)

    # Test katakana h-series → p-series
    test_cases = [
      ['ハ', '゜', 'パ'],
      ['ヒ', '゜', 'ピ'],
      ['フ', '゜', 'プ'],
      ['ヘ', '゜', 'ペ'],
      ['ホ', '゜', 'ポ']
    ]

    test_cases.each do |base, mark, expected|
      chars = [
        Yosina::Char.new(c: base, offset: 0),
        Yosina::Char.new(c: mark, offset: 1)
      ]
      result = transliterator.call(chars).to_a
      assert_equal 1, result.length, result
      assert_equal expected, result[0].c, "Expected #{base}#{mark} → #{expected}"
    end
  end

  def test_special_katakana_combinations
    transliterator = @factory.call

    # Test special katakana combinations
    test_cases = [
      ['ワ', '゙', 'ヷ'],
      ['ヰ', '゙', 'ヸ'],
      ['ヱ', '゙', 'ヹ'],
      ['ヲ', '゙', 'ヺ']
    ]

    test_cases.each do |base, mark, expected|
      chars = [
        Yosina::Char.new(c: base, offset: 0),
        Yosina::Char.new(c: mark, offset: 1)
      ]
      result = transliterator.call(chars).to_a
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected #{base}#{mark} → #{expected}"
    end
  end

  def test_iteration_marks
    transliterator = @factory.call

    # Test iteration mark combinations
    test_cases = [
      ['ゝ', '゙', 'ゞ'], # Hiragana iteration mark + voiced mark
      ['ヽ', '゙', 'ヾ'], # Katakana iteration mark + voiced mark
      ['〱', '゙', '〲'], # Vertical hiragana iteration mark + voiced mark
      ['〳', '゙', '〴']  # Vertical katakana iteration mark + voiced mark
    ]

    test_cases.each do |base, mark, expected|
      chars = [
        Yosina::Char.new(c: base, offset: 0),
        Yosina::Char.new(c: mark, offset: 1)
      ]
      result = transliterator.call(chars).to_a
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected #{base}#{mark} → #{expected}"
    end
  end

  def test_iteration_marks_with_non_combining
    transliterator = @factory.call(compose_non_combining_marks: true)

    # Test iteration marks with non-combining voiced marks
    test_cases = [
      ['ゝ', '゛', 'ゞ'], # Hiragana iteration mark + non-combining voiced mark
      ['ヽ', '゛', 'ヾ'], # Katakana iteration mark + non-combining voiced mark
      ['〱', '゛', '〲'], # Vertical hiragana iteration mark + non-combining voiced mark
      ['〳', '゛', '〴']  # Vertical katakana iteration mark + non-combining voiced mark
    ]

    test_cases.each do |base, mark, expected|
      chars = [
        Yosina::Char.new(c: base, offset: 0),
        Yosina::Char.new(c: mark, offset: 1)
      ]
      result = transliterator.call(chars).to_a
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected #{base}#{mark} → #{expected}"
    end
  end

  def test_non_combining_marks_disabled_by_default
    transliterator = @factory.call

    # Test that non-combining marks are NOT composed by default
    chars = [
      Yosina::Char.new(c: 'か', offset: 0),
      Yosina::Char.new(c: '゛', offset: 1) # Non-combining voiced mark
    ]
    result = transliterator.call(chars).to_a
    assert_equal 2, result.length
    assert_equal 'か', result[0].c
    assert_equal '゛', result[1].c
  end

  def test_non_combining_marks_enabled
    transliterator = @factory.call(compose_non_combining_marks: true)

    # Test that non-combining marks ARE composed when enabled
    test_cases = [
      ['か', '゛', 'が'], # Using U+309B (non-combining voiced mark)
      ['は', '゜', 'ぱ'], # Using U+309C (non-combining semi-voiced mark)
      ['カ', '゛', 'ガ'],
      ['ハ', '゜', 'パ']
    ]

    test_cases.each do |base, mark, expected|
      chars = [
        Yosina::Char.new(c: base, offset: 0),
        Yosina::Char.new(c: mark, offset: 1)
      ]
      result = transliterator.call(chars).to_a
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected #{base}#{mark} → #{expected}"
    end
  end

  def test_non_composable_combinations
    transliterator = @factory.call

    # Test characters that cannot be composed
    test_cases = [
      ['あ', '゙'], # Vowel + voiced mark (not composable)
      ['な', '゜'], # N-series + semi-voiced mark (not composable)
      ['ん', '゙'], # N + voiced mark (not composable)
    ]

    test_cases.each do |base, mark|
      chars = [
        Yosina::Char.new(c: base, offset: 0),
        Yosina::Char.new(c: mark, offset: 1)
      ]
      result = transliterator.call(chars).to_a
      assert_equal 2, result.length
      assert_equal base, result[0].c
      assert_equal mark, result[1].c
    end
  end

  def test_multiple_character_sequence
    transliterator = @factory.call

    # Test a sequence with both composable and non-composable parts
    chars = [
      Yosina::Char.new(c: 'か', offset: 0),
      Yosina::Char.new(c: '゙', offset: 1),  # Should compose: か゛→ が
      Yosina::Char.new(c: 'き', offset: 2),
      Yosina::Char.new(c: '゙', offset: 3),  # Should compose: き゛→ ぎ
      Yosina::Char.new(c: 'あ', offset: 4),
      Yosina::Char.new(c: '゙', offset: 5)   # Should NOT compose: あ゛(stays separate)
    ]

    result = transliterator.call(chars).to_a
    assert_equal 4, result.length
    assert_equal 'が', result[0].c
    assert_equal 'ぎ', result[1].c
    assert_equal 'あ', result[2].c
    assert_equal '゙', result[3].c
  end

  def test_isolated_marks
    transliterator = @factory.call

    # Test that isolated marks (no base character) are passed through
    chars = [
      Yosina::Char.new(c: '゙', offset: 0), # No base character before
      Yosina::Char.new(c: 'test', offset: 1)
    ]

    result = transliterator.call(chars).to_a
    assert_equal 2, result.length
    assert_equal '゙', result[0].c
    assert_equal 'test', result[1].c
  end

  def test_offset_tracking
    transliterator = @factory.call

    chars = [
      Yosina::Char.new(c: 'か', offset: 0),
      Yosina::Char.new(c: '゙', offset: 1)
    ]

    result = transliterator.call(chars).to_a
    assert_equal 1, result.length
    assert_equal 'が', result[0].c
    assert_equal 0, result[0].offset
  end
end
