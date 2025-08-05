# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestJapaneseIterationMarks < Minitest::Test
  def setup
    @factory = Yosina::Transliterators::JapaneseIterationMarks
  end

  # Test cases for Japanese iteration marks
  TEST_CASES = [
    # Basic hiragana repetition
    [
      "basic hiragana repetition",
      "さゝ",
      "ささ",
      {}
    ],
    [
      "hiragana voiced repetition",
      "はゞ",
      "はば",
      {}
    ],
    [
      "multiple hiragana repetitions",
      "みゝこゝろ",
      "みみこころ",
      {}
    ],
    # Basic katakana repetition
    [
      "basic katakana repetition",
      "サヽ",
      "ササ",
      {}
    ],
    [
      "katakana voiced repetition",
      "ハヾ",
      "ハバ",
      {}
    ],
    [
      "katakana u voicing",
      "ウヾ",
      "ウヴ",
      {}
    ],
    # Kanji repetition
    [
      "basic kanji repetition",
      "人々",
      "人人",
      {}
    ],
    [
      "multiple kanji repetitions",
      "日々月々年々",
      "日日月月年年",
      {}
    ],
    # Invalid combinations
    [
      "hiragana mark after katakana",
      "カゝ",
      "カゝ",
      {}
    ],
    [
      "katakana mark after hiragana",
      "かヽ",
      "かヽ",
      {}
    ],
    [
      "iteration mark at start",
      "ゝあ",
      "ゝあ",
      {}
    ],
    # Consecutive iteration marks
    [
      "consecutive iteration marks",
      "さゝゝ",
      "ささゝ",
      {}
    ],
    # Special characters that cannot repeat
    [
      "hiragana hatsuon cannot repeat",
      "んゝ",
      "んゝ",
      {}
    ],
    [
      "katakana hatsuon cannot repeat",
      "ンヽ",
      "ンヽ",
      {}
    ],
    [
      "hiragana sokuon cannot repeat",
      "っゝ",
      "っゝ",
      {}
    ],
    [
      "katakana sokuon cannot repeat",
      "ッヽ",
      "ッヽ",
      {}
    ],
    # Voiced characters cannot voice again
    [
      "voiced character cannot voice again",
      "がゞ",
      "がゞ",
      {}
    ],
    [
      "semi-voiced character cannot voice",
      "ぱゞ",
      "ぱゞ",
      {}
    ],
    # Mixed text
    [
      "mixed hiragana, katakana, and kanji",
      "こゝろ、コヽロ、其々",
      "こころ、ココロ、其其",
      {}
    ],
    [
      "iteration marks in sentence",
      "日々の暮らしはさゝやかだがウヾしい",
      "日日の暮らしはささやかだがウヴしい",
      {}
    ],
    # Halfwidth katakana
    [
      "halfwidth katakana repetition",
      "ｻヽ",
      "ｻｻ",
      {}
    ],
    # No voicing possible
    [
      "no voicing possible for あ",
      "あゞ",
      "あゞ",
      {}
    ],
    # Voicing all consonants
    [
      "voicing all consonants",
      "かゞたゞはゞさゞ",
      "かがただはばさざ",
      {}
    ],
    # Empty string
    [
      "empty string",
      "",
      "",
      {}
    ],
    # No iteration marks
    [
      "string with no iteration marks",
      "こんにちは世界",
      "こんにちは世界",
      {}
    ],
    # Complex combinations
    [
      "complex mixed script",
      "私々はﾀﾞヾ々と歩く",
      "私私はﾀﾞヾ々と歩く",
      {}
    ],
    [
      "multiple types of iteration marks",
      "さゝ、カヾ、人々、みゞ",
      "ささ、カガ、人人、みゞ",
      {}
    ],
    # Edge cases with voicing
    [
      "hiragana all voiceable characters",
      "かゞきゞくゞけゞこゞ",
      "かがきぎくぐけげこご",
      {}
    ],
    [
      "katakana all voiceable characters",
      "カヾキヾクヾケヾコヾ",
      "カガキギクグケゲコゴ",
      {}
    ],
    [
      "hiragana ta row voicing",
      "たゞちゞつゞてゞとゞ",
      "ただちぢつづてでとど",
      {}
    ],
    [
      "katakana ta row voicing",
      "タヾチヾツヾテヾトヾ",
      "タダチヂツヅテデトド",
      {}
    ],
    # Non-Japanese characters
    [
      "iteration mark after non-Japanese",
      "ABC々123ゝ",
      "ABC々123ゝ",
      {}
    ],
    [
      "mixed with English",
      "Hello々World",
      "Hello々World",
      {}
    ],
    # Special Unicode cases
    [
      "emoji with iteration marks",
      "😀々😊ゝ",
      "😀々😊ゝ",
      {}
    ],
    # Multiple consecutive marks of different types
    [
      "different iteration marks in sequence",
      "人々さゝカヽ",
      "人人ささカカ",
      {}
    ],
    # Kanji with other marks
    [
      "kanji mark after hiragana",
      "さ々",
      "さ々",
      {}
    ],
    [
      "kanji mark after katakana",
      "サ々",
      "サ々",
      {}
    ]
  ].freeze

  def test_japanese_iteration_marks
    TEST_CASES.each do |name, input_str, expected, options|
      transliterator = @factory.call(**options)
      chars = Yosina::Chars::build_char_array(input_str)
      result = transliterator.call(chars)
      output = result.to_s

      assert_equal expected, output, "Failed test: #{name}"
    end
  end

  def test_character_preservation
    # Test that the transliterator preserves character properties
    transliterator = @factory.call
    input_str = "さゝ"
    chars = Yosina::Chars::build_char_array(input_str)
    result = transliterator.call(chars)
    result_array = result.to_a
    
    # Should have 3 chars including sentinel
    assert_equal 3, result_array.length
    
    # First char should be original with offset
    assert_equal "さ", result_array[0].c
    assert_equal 0, result_array[0].offset
    
    # Second char should be replaced
    assert_equal "さ", result_array[1].c
    assert_equal 1, result_array[1].offset  # Character offset, not bytes
    # The source should be the original iteration mark
    assert_equal "ゝ", result_array[1].source.c
  end

  def test_offset_tracking
    # Test that offsets are properly tracked
    transliterator = @factory.call
    input_str = "あゝいゞう"
    chars = Yosina::Chars::build_char_array(input_str)
    result = transliterator.call(chars)
    
    result_array = result.to_a.select { |c| !c.c.empty? }  # Remove sentinel
    assert_equal "あ", result_array[0].c
    assert_equal 0, result_array[0].offset
    
    assert_equal "あ", result_array[1].c
    assert_equal 1, result_array[1].offset
    
    assert_equal "い", result_array[2].c
    assert_equal 2, result_array[2].offset
    
    assert_equal "ゞ", result_array[3].c  # No voicing for い, so mark stays
    assert_equal 3, result_array[3].offset
    
    assert_equal "う", result_array[4].c
    assert_equal 4, result_array[4].offset
  end

  def test_source_tracking
    # Test that source references are maintained
    transliterator = @factory.call
    input_str = "人々"
    chars = Yosina::Chars::build_char_array(input_str)
    result = transliterator.call(chars)
    
    result_array = result.to_a.select { |c| !c.c.empty? }  # Remove sentinel
    # First character might have source if it went through with_offset
    # Check the character value instead
    assert_equal "人", result_array[0].c
    
    # Second character should be replaced with the kanji
    assert_equal "人", result_array[1].c
    # The source chain should lead back to the iteration mark
    assert_equal "々", result_array[1].source.c
  end

  def test_voicing_combinations
    # Test various voicing combinations
    transliterator = @factory.call
    
    # Test all hiragana voicing combinations
    voicing_tests = [
      ["かゞ", "かが"], ["きゞ", "きぎ"], ["くゞ", "くぐ"], ["けゞ", "けげ"], ["こゞ", "こご"],
      ["さゞ", "さざ"], ["しゞ", "しじ"], ["すゞ", "すず"], ["せゞ", "せぜ"], ["そゞ", "そぞ"],
      ["たゞ", "ただ"], ["ちゞ", "ちぢ"], ["つゞ", "つづ"], ["てゞ", "てで"], ["とゞ", "とど"],
      ["はゞ", "はば"], ["ひゞ", "ひび"], ["ふゞ", "ふぶ"], ["へゞ", "へべ"], ["ほゞ", "ほぼ"]
    ]
    
    voicing_tests.each do |input, expected|
      chars = Yosina::Chars::build_char_array(input)
      result = transliterator.call(chars)
      assert_equal expected, result.to_s, "Failed voicing: #{input} -> #{expected}"
    end
  end

  def test_katakana_voicing_combinations
    # Test katakana voicing combinations
    transliterator = @factory.call
    
    voicing_tests = [
      ["カヾ", "カガ"], ["キヾ", "キギ"], ["クヾ", "クグ"], ["ケヾ", "ケゲ"], ["コヾ", "コゴ"],
      ["サヾ", "サザ"], ["シヾ", "シジ"], ["スヾ", "スズ"], ["セヾ", "セゼ"], ["ソヾ", "ソゾ"],
      ["タヾ", "タダ"], ["チヾ", "チヂ"], ["ツヾ", "ツヅ"], ["テヾ", "テデ"], ["トヾ", "トド"],
      ["ハヾ", "ハバ"], ["ヒヾ", "ヒビ"], ["フヾ", "フブ"], ["ヘヾ", "ヘベ"], ["ホヾ", "ホボ"],
      ["ウヾ", "ウヴ"]
    ]
    
    voicing_tests.each do |input, expected|
      chars = Yosina::Chars::build_char_array(input)
      result = transliterator.call(chars)
      assert_equal expected, result.to_s, "Failed katakana voicing: #{input} -> #{expected}"
    end
  end

  def test_no_voicing_characters
    # Test characters that cannot be voiced
    transliterator = @factory.call
    
    no_voicing_tests = [
      "あゞ", "いゞ", "うゞ", "えゞ", "おゞ",
      "なゞ", "にゞ", "ぬゞ", "ねゞ", "のゞ",
      "まゞ", "みゞ", "むゞ", "めゞ", "もゞ",
      "やゞ", "ゆゞ", "よゞ",
      "らゞ", "りゞ", "るゞ", "れゞ", "ろゞ",
      "わゞ", "をゞ", "んゞ"
    ]
    
    no_voicing_tests.each do |input|
      chars = Yosina::Chars::build_char_array(input)
      result = transliterator.call(chars)
      assert_equal input, result.to_s, "Should not voice: #{input}"
    end
  end
end