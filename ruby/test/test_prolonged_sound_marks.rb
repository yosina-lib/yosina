# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestProlongedSoundMarks < Minitest::Test
  def setup
    @factory = Yosina::Transliterators::ProlongedSoundMarks
  end

  # Test cases matching Python implementation
  TEST_CASES = [
    # Basic hyphen replacements
    [
      "fullwidth hyphen-minus to prolonged sound mark",
      "イ\uff0dハト\uff0dヴォ",
      "イ\u30fcハト\u30fcヴォ",
      {}
    ],
    [
      "fullwidth hyphen-minus at end of word",
      "カトラリ\uff0d",
      "カトラリ\u30fc",
      {}
    ],
    [
      "ASCII hyphen-minus to prolonged sound mark",
      "イ\u002dハト\u002dヴォ",
      "イ\u30fcハト\u30fcヴォ",
      {}
    ],
    [
      "ASCII hyphen-minus at end of word",
      "カトラリ\u002d",
      "カトラリ\u30fc",
      {}
    ],
    # Prolonged marks between alphanumerics
    [
      "don't replace prolonged sound marks between alphanumerics by default",
      "1\u30fc\u30fc2\u30fc3",
      "1\u30fc\u30fc2\u30fc3",
      {}
    ],
    [
      "replace prolonged marks between alphanumerics",
      "1\u30fc\uff0d2\u30fc3",
      "1\u002d\u002d2\u002d3",
      { replace_prolonged_marks_following_alnums: true }
    ],
    [
      "replace prolonged sound marks between fullwidth alphanumerics",
      "\uff11\u30fc\uff0d\uff12\u30fc\uff13",
      "\uff11\uff0d\uff0d\uff12\uff0d\uff13",
      { replace_prolonged_marks_following_alnums: true }
    ],
    # Sokuon and hatsuon handling
    [
      "don't prolong sokuon by default",
      "ウッ\uff0dウン\uff0d",
      "ウッ\uff0dウン\uff0d",
      {}
    ],
    [
      "allow prolonged sokuon",
      "ウッ\uff0dウン\uff0d",
      "ウッ\u30fcウン\uff0d",
      { allow_prolonged_sokuon: true }
    ],
    [
      "allow prolonged hatsuon",
      "ウッ\uff0dウン\uff0d",
      "ウッ\uff0dウン\u30fc",
      { allow_prolonged_hatsuon: true }
    ],
    [
      "allow both prolonged sokuon and hatsuon",
      "ウッ\uff0dウン\uff0d",
      "ウッ\u30fcウン\u30fc",
      { allow_prolonged_sokuon: true, allow_prolonged_hatsuon: true }
    ],
    # Edge cases
    [
      "empty string",
      "",
      "",
      {}
    ],
    [
      "string with no hyphens",
      "こんにちは世界",
      "こんにちは世界",
      {}
    ],
    [
      "mixed hiragana and katakana with hyphens",
      "あいう\u002dかきく\uff0d",
      "あいう\u30fcかきく\u30fc",
      {}
    ],
    # Halfwidth katakana
    [
      "halfwidth katakana with hyphen",
      "ｱｲｳ\u002d",
      "ｱｲｳ\uff70",
      {}
    ],
    [
      "halfwidth katakana with fullwidth hyphen",
      "ｱｲｳ\uff0d",
      "ｱｲｳ\uff70",
      {}
    ],
    # Non-Japanese characters
    [
      "hyphen after non-Japanese character",
      "ABC\u002d123\uff0d",
      "ABC\u002d123\uff0d",
      {}
    ],
    # Multiple hyphens
    [
      "multiple hyphens in sequence",
      "ア\u002d\u002d\u002dイ",
      "ア\u30fc\u30fc\u30fcイ",
      {}
    ],
    # Various hyphen types
    [
      "various hyphen types",
      "ア\u002dイ\u2010ウ\u2014エ\u2015オ\u2212カ\uff0d",
      "ア\u30fcイ\u30fcウ\u30fcエ\u30fcオ\u30fcカ\u30fc",
      {}
    ],
    # Prolonged sound marks remain unchanged
    [
      "prolonged sound mark remains unchanged (1)",
      "ア\u30fcＡ\uff70Ｂ",
      "ア\u30fcＡ\uff70Ｂ",
      {}
    ],
    [
      "prolonged sound mark remains unchanged (2)",
      "ア\u30fcン\uff70ウ",
      "ア\u30fcン\uff70ウ",
      {}
    ],
    # Mixed alphanumeric and Japanese with replace option
    [
      "mixed alphanumeric and Japanese with replace option",
      "A\u30fcB\uff0dアイウ\u002d123\u30fc",
      "A\u002dB\u002dアイウ\u30fc123\u002d",
      { replace_prolonged_marks_following_alnums: true }
    ],
    # Hiragana sokuon
    [
      "hiragana sokuon with hyphen",
      "あっ\u002d",
      "あっ\u002d",
      {}
    ],
    [
      "hiragana sokuon with hyphen and allow prolonged sokuon",
      "あっ\u002d",
      "あっ\u30fc",
      { allow_prolonged_sokuon: true }
    ],
    # Hiragana hatsuon
    [
      "hiragana hatsuon with hyphen",
      "あん\u002d",
      "あん\u002d",
      {}
    ],
    [
      "hiragana hatsuon with hyphen and allow prolonged hatsuon",
      "あん\u002d",
      "あん\u30fc",
      { allow_prolonged_hatsuon: true }
    ],
    # Halfwidth katakana sokuon
    [
      "halfwidth katakana sokuon with hyphen",
      "ｳｯ\u002d",
      "ｳｯ\u002d",
      {}
    ],
    [
      "halfwidth katakana sokuon with hyphen and allow prolonged sokuon",
      "ｳｯ\u002d",
      "ｳｯ\uff70",
      { allow_prolonged_sokuon: true }
    ],
    # Halfwidth katakana hatsuon
    [
      "halfwidth katakana hatsuon with hyphen",
      "ｳﾝ\u002d",
      "ｳﾝ\u002d",
      {}
    ],
    [
      "halfwidth katakana hatsuon with hyphen and allow prolonged hatsuon",
      "ｳﾝ\u002d",
      "ｳﾝ\uff70",
      { allow_prolonged_hatsuon: true }
    ],
    # Hyphen at start
    [
      "hyphen at start of string",
      "\u002dアイウ",
      "\u002dアイウ",
      {}
    ],
    # Only hyphens
    [
      "only hyphens",
      "\u002d\uff0d\u2010\u2014\u2015\u2212",
      "\u002d\uff0d\u2010\u2014\u2015\u2212",
      {}
    ],
    # Special characters
    [
      "newline and tab characters",
      "ア\n\u002d\tイ\uff0d",
      "ア\n\u002d\tイ\u30fc",
      {}
    ],
    [
      "emoji with hyphens",
      "😀\u002d😊\uff0d",
      "😀\u002d😊\uff0d",
      {}
    ],
    [
      "unicode surrogates",
      "\u{1f600}ア\u002d\u{1f601}イ\uff0d",
      "\u{1f600}ア\u30fc\u{1f601}イ\u30fc",
      {}
    ],
    # Character type transitions
    [
      "hyphen between different character types",
      "あ\u002dア\u002dA\u002d1\u002dａ\u002d１",
      "あ\u30fcア\u30fcA\u002d1\u002dａ\u002d１",
      {}
    ],
    [
      "hyphen between different character types with replace option",
      "A\u002d1\u30fcａ\uff70１",
      "A\u002d1\u002dａ\uff0d１",
      { replace_prolonged_marks_following_alnums: true }
    ],
    # Skip already transliterated
    [
      "skip already transliterated chars option",
      "ア\u002dイ\uff0d",
      "ア\u30fcイ\u30fc",
      { skip_already_transliterated_chars: true }
    ],
    # Vowel-ended characters
    [
      "hiragana vowel-ended characters",
      "あ\u002dか\u002dさ\u002dた\u002dな\u002dは\u002dま\u002dや\u002dら\u002dわ\u002d",
      "あ\u30fcか\u30fcさ\u30fcた\u30fcな\u30fcは\u30fcま\u30fcや\u30fcら\u30fcわ\u30fc",
      {}
    ],
    [
      "katakana vowel-ended characters",
      "ア\u002dカ\u002dサ\u002dタ\u002dナ\u002dハ\u002dマ\u002dヤ\u002dラ\u002dワ\u002d",
      "ア\u30fcカ\u30fcサ\u30fcタ\u30fcナ\u30fcハ\u30fcマ\u30fcヤ\u30fcラ\u30fcワ\u30fc",
      {}
    ],
    [
      "halfwidth katakana vowel-ended characters",
      "ｱ\u002dｶ\u002dｻ\u002dﾀ\u002dﾅ\u002dﾊ\u002dﾏ\u002dﾔ\u002dﾗ\u002dﾜ\u002d",
      "ｱ\uff70ｶ\uff70ｻ\uff70ﾀ\uff70ﾅ\uff70ﾊ\uff70ﾏ\uff70ﾔ\uff70ﾗ\uff70ﾜ\uff70",
      {}
    ],
    # Digits
    [
      "digits with hyphens",
      "0\u002d1\u002d2\u002d3\u002d4\u002d5\u002d6\u002d7\u002d8\u002d9\u002d",
      "0\u002d1\u002d2\u002d3\u002d4\u002d5\u002d6\u002d7\u002d8\u002d9\u002d",
      {}
    ],
    [
      "fullwidth digits with hyphens",
      "０\u002d１\u002d２\u002d３\u002d４\u002d５\u002d６\u002d７\u002d８\u002d９\u002d",
      "０\u002d１\u002d２\u002d３\u002d４\u002d５\u002d６\u002d７\u002d８\u002d９\u002d",
      {}
    ],
    [
      "fullwidth digits with hyphens with options",
      "０\u002d１\u002d２\u002d３\u002d４\u002d５\u002d６\u002d７\u002d８\u002d９\u002d",
      "０\uff0d１\uff0d２\uff0d３\uff0d４\uff0d５\uff0d６\uff0d７\uff0d８\uff0d９\uff0d",
      { replace_prolonged_marks_following_alnums: true }
    ],
    # Alphabets
    [
      "alphabet with hyphens",
      "A\u002dB\u002dC\u002da\u002db\u002dc\u002d",
      "A\u002dB\u002dC\u002da\u002db\u002dc\u002d",
      {}
    ],
    [
      "alphabet with hyphens with options",
      "A\u002dB\u002dC\u002da\u002db\u002dc\u002d",
      "A\u002dB\u002dC\u002da\u002db\u002dc\u002d",
      { replace_prolonged_marks_following_alnums: true }
    ],
    [
      "fullwidth alphabet with hyphens",
      "Ａ\u002dＢ\u002dＣ\u002dａ\u002dｂ\u002dｃ\u002d",
      "Ａ\u002dＢ\u002dＣ\u002dａ\u002dｂ\u002dｃ\u002d",
      {}
    ],
    [
      "fullwidth alphabet with hyphens with options",
      "Ａ\u002dＢ\u002dＣ\u002dａ\u002dｂ\u002dｃ\u002d",
      "Ａ\uff0dＢ\uff0dＣ\uff0dａ\uff0dｂ\uff0dｃ\uff0d",
      { replace_prolonged_marks_following_alnums: true }
    ]
  ].freeze

  def test_prolonged_sound_marks
    TEST_CASES.each do |name, input_str, expected, options|
      transliterator = @factory.call(**options)
      chars = Yosina::Chars::build_char_array(input_str)
      result = transliterator.call(chars)
      output = result.to_s

      assert_equal expected, output, "Failed test: #{name}"
    end
  end
end
