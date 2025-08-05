# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestJisX0201AndAlike < Minitest::Test
  def setup
    @factory = Yosina::Transliterators::JisX0201AndAlike
  end

  def test_fullwidth_to_halfwidth_ascii
    transliterator = @factory.call # Default: fullwidth_to_halfwidth = true

    # Test fullwidth ASCII to halfwidth ASCII
    test_cases = [
      ['　', ' '], # Ideographic space → space
      ['！', '!'],   ['＂', '"'],   ['＃', '#'],   ['＄', '$'],   ['％', '%'],
      ['＆', '&'],   ['＇', "'"],   ['（', '('],   ['）', ')'],   ['＊', '*'],
      ['＋', '+'],   ['，', ','],   ['－', '-'],   ['．', '.'],   ['／', '/'],
      ['０', '0'],   ['１', '1'],   ['２', '2'],   ['３', '3'],   ['９', '9'],
      ['Ａ', 'A'],   ['Ｂ', 'B'],   ['Ｚ', 'Z'],
      ['ａ', 'a'],   ['ｂ', 'b'],   ['ｚ', 'z']
    ]

    test_cases.each do |input, expected|
      chars = [Yosina::Char.new(c: input, offset: 0)]
      result = transliterator.call(chars)
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected '#{input}' → '#{expected}'"
    end
  end

  def test_halfwidth_to_fullwidth_ascii
    transliterator = @factory.call(fullwidth_to_halfwidth: false)

    # Test halfwidth ASCII to fullwidth ASCII
    test_cases = [
      [' ', '　'], # space → Ideographic space
      ['!', '！'],   ['"', '＂'],   ['#', '＃'],   ['$', '＄'],   ['%', '％'],
      ['&', '＆'],   ["'", '＇'],   ['(', '（'],   [')', '）'],   ['*', '＊'],
      ['+', '＋'],   [',', '，'],   ['-', '－'],   ['.', '．'],   ['/', '／'],
      ['0', '０'],   ['1', '１'],   ['2', '２'],   ['3', '３'],   ['9', '９'],
      ['A', 'Ａ'],   ['B', 'Ｂ'],   ['Z', 'Ｚ'],
      ['a', 'ａ'],   ['b', 'ｂ'],   ['z', 'ｚ']
    ]

    test_cases.each do |input, expected|
      chars = [Yosina::Char.new(c: input, offset: 0)]
      result = transliterator.call(chars)
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected '#{input}' → '#{expected}'"
    end
  end

  def test_fullwidth_to_halfwidth_katakana
    transliterator = @factory.call

    # Test basic katakana
    test_cases = [
      ['ア', 'ｱ'],   ['イ', 'ｲ'],   ['ウ', 'ｳ'],   ['エ', 'ｴ'],   ['オ', 'ｵ'],
      ['カ', 'ｶ'],   ['キ', 'ｷ'],   ['ク', 'ｸ'],   ['ケ', 'ｹ'],   ['コ', 'ｺ'],
      ['サ', 'ｻ'],   ['シ', 'ｼ'],   ['ス', 'ｽ'],   ['セ', 'ｾ'],   ['ソ', 'ｿ'],
      ['タ', 'ﾀ'],   ['チ', 'ﾁ'],   ['ツ', 'ﾂ'],   ['テ', 'ﾃ'],   ['ト', 'ﾄ'],
      ['ナ', 'ﾅ'],   ['ニ', 'ﾆ'],   ['ヌ', 'ﾇ'],   ['ネ', 'ﾈ'],   ['ノ', 'ﾉ'],
      ['ハ', 'ﾊ'],   ['ヒ', 'ﾋ'],   ['フ', 'ﾌ'],   ['ヘ', 'ﾍ'],   ['ホ', 'ﾎ'],
      ['マ', 'ﾏ'],   ['ミ', 'ﾐ'],   ['ム', 'ﾑ'],   ['メ', 'ﾒ'],   ['モ', 'ﾓ'],
      ['ヤ', 'ﾔ'],   ['ユ', 'ﾕ'],   ['ヨ', 'ﾖ'],
      ['ラ', 'ﾗ'],   ['リ', 'ﾘ'],   ['ル', 'ﾙ'], ['レ', 'ﾚ'], ['ロ', 'ﾛ'],
      ['ワ', 'ﾜ'],   ['ヲ', 'ｦ'],   ['ン', 'ﾝ'],
      ['ァ', 'ｧ'],   ['ィ', 'ｨ'],   ['ゥ', 'ｩ'],   ['ェ', 'ｪ'], ['ォ', 'ｫ'],
      ['ッ', 'ｯ'],   ['ャ', 'ｬ'],   ['ュ', 'ｭ'],   ['ョ', 'ｮ'],
      ['ー', 'ｰ'],   ['・', '･'],   ['「', '｢'],   ['」', '｣']
    ]

    test_cases.each do |input, expected|
      chars = [Yosina::Char.new(c: input, offset: 0)]
      result = transliterator.call(chars)
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected '#{input}' → '#{expected}'"
    end
  end

  def test_fullwidth_to_halfwidth_voiced_katakana
    transliterator = @factory.call

    # Test voiced katakana → base + voice mark
    test_cases = [
      ['ガ', 'ｶﾞ'],  ['ギ', 'ｷﾞ'],  ['グ', 'ｸﾞ'],  ['ゲ', 'ｹﾞ'],  ['ゴ', 'ｺﾞ'],
      ['ザ', 'ｻﾞ'],  ['ジ', 'ｼﾞ'],  ['ズ', 'ｽﾞ'],  ['ゼ', 'ｾﾞ'],  ['ゾ', 'ｿﾞ'],
      ['ダ', 'ﾀﾞ'],  ['ヂ', 'ﾁﾞ'],  ['ヅ', 'ﾂﾞ'],  ['デ', 'ﾃﾞ'],  ['ド', 'ﾄﾞ'],
      ['バ', 'ﾊﾞ'],  ['ビ', 'ﾋﾞ'],  ['ブ', 'ﾌﾞ'],  ['ベ', 'ﾍﾞ'],  ['ボ', 'ﾎﾞ'],
      ['ヴ', 'ｳﾞ'],
      ['パ', 'ﾊﾟ'], ['ピ', 'ﾋﾟ'], ['プ', 'ﾌﾟ'], ['ペ', 'ﾍﾟ'], ['ポ', 'ﾎﾟ']
    ]

    test_cases.each do |input, expected|
      chars = [Yosina::Char.new(c: input, offset: 0)]
      result = transliterator.call(chars)
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected '#{input}' → '#{expected}'"
    end
  end

  def test_halfwidth_to_fullwidth_katakana
    transliterator = @factory.call(fullwidth_to_halfwidth: false)

    # Test basic halfwidth katakana → fullwidth
    test_cases = [
      ['ｱ', 'ア'],   ['ｲ', 'イ'],   ['ｳ', 'ウ'],   ['ｴ', 'エ'],   ['ｵ', 'オ'],
      ['ｶ', 'カ'],   ['ｷ', 'キ'],   ['ｸ', 'ク'],   ['ｹ', 'ケ'],   ['ｺ', 'コ'],
      ['ﾊ', 'ハ'],   ['ﾋ', 'ヒ'],   ['ﾌ', 'フ'],   ['ﾍ', 'ヘ'],   ['ﾎ', 'ホ'],
      ['ﾝ', 'ン'],   ['ｰ', 'ー']
    ]

    test_cases.each do |input, expected|
      chars = [Yosina::Char.new(c: input, offset: 0)]
      result = transliterator.call(chars)
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected '#{input}' → '#{expected}'"
    end
  end

  def test_halfwidth_to_fullwidth_voice_mark_combinations
    transliterator = @factory.call(fullwidth_to_halfwidth: false, combine_voiced_sound_marks: true)

    # Test voice mark combinations
    test_cases = [
      ['ｶﾞ', 'ガ'], ['ｷﾞ', 'ギ'], ['ｸﾞ', 'グ'], ['ｹﾞ', 'ゲ'], ['ｺﾞ', 'ゴ'],
      ['ｻﾞ', 'ザ'], ['ｼﾞ', 'ジ'], ['ｽﾞ', 'ズ'], ['ｾﾞ', 'ゼ'], ['ｿﾞ', 'ゾ'],
      ['ﾀﾞ', 'ダ'], ['ﾁﾞ', 'ヂ'], ['ﾂﾞ', 'ヅ'], ['ﾃﾞ', 'デ'], ['ﾄﾞ', 'ド'],
      ['ﾊﾞ', 'バ'], ['ﾋﾞ', 'ビ'], ['ﾌﾞ', 'ブ'], ['ﾍﾞ', 'ベ'], ['ﾎﾞ', 'ボ'],
      ['ｳﾞ', 'ヴ'],
      ['ﾊﾟ', 'パ'], ['ﾋﾟ', 'ピ'], ['ﾌﾟ', 'プ'], ['ﾍﾟ', 'ペ'], ['ﾎﾟ', 'ポ']
    ]

    test_cases.each do |input, expected|
      chars = input.chars.map.with_index { |c, i| Yosina::Char.new(c: c, offset: i) }
      result = transliterator.call(chars)
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected '#{input}' → '#{expected}'"
    end
  end

  def test_hiragana_to_halfwidth_katakana
    transliterator = @factory.call(convert_hiraganas: true)

    # Test hiragana → halfwidth katakana
    test_cases = [
      ['あ', 'ｱ'],   ['い', 'ｲ'],   ['う', 'ｳ'],   ['え', 'ｴ'],   ['お', 'ｵ'],
      ['か', 'ｶ'],   ['き', 'ｷ'],   ['く', 'ｸ'],   ['け', 'ｹ'],   ['こ', 'ｺ'],
      ['が', 'ｶﾞ'],  ['ぎ', 'ｷﾞ'],  ['ぐ', 'ｸﾞ'],  ['げ', 'ｹﾞ'],  ['ご', 'ｺﾞ'],
      ['ぱ', 'ﾊﾟ'],  ['ぴ', 'ﾋﾟ'],  ['ぷ', 'ﾌﾟ'],  ['ぺ', 'ﾍﾟ'],  ['ぽ', 'ﾎﾟ']
    ]

    test_cases.each do |input, expected|
      chars = [Yosina::Char.new(c: input, offset: 0)]
      result = transliterator.call(chars)
      assert_equal 1, result.length
      assert_equal expected, result[0].c, "Expected '#{input}' → '#{expected}'"
    end
  end

  def test_convert_options
    # Test convert_gl disabled
    transliterator = @factory.call(convert_gl: false)
    chars = [Yosina::Char.new(c: 'Ａ', offset: 0)]
    result = transliterator.call(chars)
    assert_equal 'Ａ', result[0].c # Should remain unchanged

    # Test convert_gr disabled
    transliterator = @factory.call(convert_gr: false)
    chars = [Yosina::Char.new(c: 'ア', offset: 0)]
    result = transliterator.call(chars)
    assert_equal 'ア', result[0].c # Should remain unchanged

    # Test convert_hiraganas disabled (default)
    transliterator = @factory.call
    chars = [Yosina::Char.new(c: 'あ', offset: 0)]
    result = transliterator.call(chars)
    assert_equal 'あ', result[0].c # Should remain unchanged
  end

  def test_special_characters
    # Test unsafe specials disabled by default
    transliterator = @factory.call
    chars = [Yosina::Char.new(c: '゠', offset: 0)]
    result = transliterator.call(chars)
    assert_equal '゠', result[0].c # Should remain unchanged

    # Test unsafe specials enabled
    transliterator = @factory.call(convert_unsafe_specials: true)
    chars = [Yosina::Char.new(c: '゠', offset: 0)]
    result = transliterator.call(chars)
    assert_equal '=', result[0].c # Should convert

    # Test reverse conversion
    transliterator = @factory.call(fullwidth_to_halfwidth: false, convert_unsafe_specials: true)
    chars = [Yosina::Char.new(c: '=', offset: 0)]
    result = transliterator.call(chars)
    assert_equal '゠', result[0].c # Should convert back
  end

  def test_mixed_text_conversion
    transliterator = @factory.call

    # Test mixed fullwidth text → halfwidth
    input_text = "Ｈｅｌｌｏ　Ｗｏｒｌｄ　１２３　カタカナ　ガパ"
    chars = input_text.chars.map.with_index { |c, i| Yosina::Char.new(c: c, offset: i) }
    result = transliterator.call(chars)
    output = result.map(&:c).join

    assert_equal "Hello World 123 ｶﾀｶﾅ ｶﾞﾊﾟ", output
  end

  def test_offset_tracking
    transliterator = @factory.call

    chars = [
      Yosina::Char.new(c: 'Ａ', offset: 0),
      Yosina::Char.new(c: 'Ｂ', offset: 1)
    ]

    result = transliterator.call(chars)
    assert_equal 2, result.length
    assert_equal 'A', result[0].c
    assert_equal 0, result[0].offset
    assert_equal 'B', result[1].c
    assert_equal 1, result[1].offset
  end
end
