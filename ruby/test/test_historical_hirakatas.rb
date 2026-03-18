# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestHistoricalHirakatas < Minitest::Test
  def test_simple_hiragana_default
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call
    chars = Yosina::Chars.build_char_array('ゐゑ')
    result = transliterator.call(chars).map(&:c).join
    assert_equal 'いえ', result
  end

  def test_passthrough
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call
    chars = Yosina::Chars.build_char_array('あいう')
    result = transliterator.call(chars).map(&:c).join
    assert_equal 'あいう', result
  end

  def test_mixed_input
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call
    chars = Yosina::Chars.build_char_array('あゐいゑう')
    result = transliterator.call(chars).map(&:c).join
    assert_equal 'あいいえう', result
  end

  def test_decompose_hiragana
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call(hiraganas: 'decompose', katakanas: 'skip')
    chars = Yosina::Chars.build_char_array('ゐゑ')
    result = transliterator.call(chars).map(&:c).join
    assert_equal 'うぃうぇ', result
  end

  def test_skip_hiragana
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call(hiraganas: 'skip', katakanas: 'skip')
    chars = Yosina::Chars.build_char_array('ゐゑ')
    result = transliterator.call(chars).map(&:c).join
    assert_equal 'ゐゑ', result
  end

  def test_simple_katakana_default
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call
    chars = Yosina::Chars.build_char_array('ヰヱ')
    result = transliterator.call(chars).map(&:c).join
    assert_equal 'イエ', result
  end

  def test_decompose_katakana
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call(hiraganas: 'skip', katakanas: 'decompose')
    chars = Yosina::Chars.build_char_array('ヰヱ')
    result = transliterator.call(chars).map(&:c).join
    assert_equal 'ウィウェ', result
  end

  def test_voiced_katakana_decompose
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call(
      hiraganas: 'skip', katakanas: 'skip', voiced_katakanas: 'decompose'
    )
    chars = Yosina::Chars.build_char_array('ヷヸヹヺ')
    result = transliterator.call(chars).map(&:c).join
    assert_equal 'ヴァヴィヴェヴォ', result
  end

  def test_voiced_katakana_skip_default
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call(hiraganas: 'skip', katakanas: 'skip')
    chars = Yosina::Chars.build_char_array('ヷヸヹヺ')
    result = transliterator.call(chars).map(&:c).join
    assert_equal 'ヷヸヹヺ', result
  end

  def test_all_decompose
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call(
      hiraganas: 'decompose', katakanas: 'decompose', voiced_katakanas: 'decompose'
    )
    chars = Yosina::Chars.build_char_array('ゐゑヰヱヷヸヹヺ')
    result = transliterator.call(chars).map(&:c).join
    assert_equal 'うぃうぇウィウェヴァヴィヴェヴォ', result
  end

  def test_all_skip
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call(
      hiraganas: 'skip', katakanas: 'skip', voiced_katakanas: 'skip'
    )
    chars = Yosina::Chars.build_char_array('ゐゑヰヱヷヸヹヺ')
    result = transliterator.call(chars).map(&:c).join
    assert_equal 'ゐゑヰヱヷヸヹヺ', result
  end

  def test_decomposed_voiced_katakana_decompose
    # Decomposed ワ+゙ ヰ+゙ ヱ+゙ ヲ+゙ should convert like composed ヷヸヹヺ
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call(
      hiraganas: 'skip', katakanas: 'skip', voiced_katakanas: 'decompose'
    )
    chars = Yosina::Chars.build_char_array("ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099")
    result = transliterator.call(chars).map(&:c).join
    assert_equal "ウ\u{3099}ァウ\u{3099}ィウ\u{3099}ェウ\u{3099}ォ", result
  end

  def test_decomposed_voiced_katakana_skip
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call(
      hiraganas: 'skip', katakanas: 'skip', voiced_katakanas: 'skip'
    )
    chars = Yosina::Chars.build_char_array("ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099")
    result = transliterator.call(chars).map(&:c).join
    assert_equal "ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099", result
  end

  def test_decomposed_voiced_not_split_from_base
    # ヰ+゙ must be treated as ヸ (voiced), not as ヰ (katakana) + separate ゙
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call(
      hiraganas: 'skip', katakanas: 'simple', voiced_katakanas: 'skip'
    )
    chars = Yosina::Chars.build_char_array("ヰ\u3099")
    result = transliterator.call(chars).map(&:c).join
    assert_equal "ヰ\u3099", result
  end

  def test_decomposed_voiced_with_decompose
    # ヰ+゙ = ヸ, should produce ヴィ
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call(
      hiraganas: 'skip', katakanas: 'skip', voiced_katakanas: 'decompose'
    )
    chars = Yosina::Chars.build_char_array("ヰ\u3099")
    result = transliterator.call(chars).map(&:c).join
    assert_equal "ウ\u{3099}ィ", result
  end

  def test_empty_input
    transliterator = Yosina::Transliterators::HistoricalHirakatas.call
    chars = Yosina::Chars.build_char_array('')
    result = transliterator.call(chars).map(&:c).join
    assert_equal '', result
  end
end
