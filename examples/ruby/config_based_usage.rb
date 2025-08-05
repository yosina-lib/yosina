#!/usr/bin/env ruby
# frozen_string_literal: true

# Configuration-based usage example for Yosina Ruby library.
# This example demonstrates using direct transliterator configurations instead of recipes.

require 'yosina'

def main
  puts "=== Yosina Ruby Configuration-based Usage Example ===\n\n"

  # Create transliterator with direct configurations
  configs = [
    ["spaces", {}],
    [
      "prolonged-sound-marks",
      {
        replace_prolonged_marks_following_alnums: true
      }
    ],
    ["jisx0201-and-alike", {}]
  ]

  transliterator = Yosina.make_transliterator(configs)

  puts "--- Configuration-based Transliteration ---"

  # Test cases demonstrating different transformations
  test_cases = [
    ["hello　world", "Space normalization"],
    ["カタカナーテスト", "Prolonged sound mark handling"],
    ["ＡＢＣ１２３", "Full-width conversion"],
    ["ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana conversion"]
  ]

  test_cases.each do |test_text, description|
    result = transliterator.call(test_text)
    puts "#{description}:"
    puts "  Input:  '#{test_text}'"
    puts "  Output: '#{result}'"
    puts
  end

  # Demonstrate individual transliterators
  puts "--- Individual Transliterator Examples ---"

  # Spaces only
  spaces_config = [["spaces", {}]]
  spaces_only = Yosina.make_transliterator(spaces_config)
  space_test = "hello　world　test" # ideographic spaces
  puts "Spaces only: '#{space_test}' → '#{spaces_only.call(space_test)}'"

  # Kanji old-new only
  kanji_config = [
    ["ivs-svs-base", { mode: "ivs-or-svs", charset: "unijis_2004" }],
    ["kanji-old-new", {}],
    ["ivs-svs-base", { mode: "base", charset: "unijis_2004" }]
  ]
  kanji_only = Yosina.make_transliterator(kanji_config)
  kanji_test = "廣島檜"
  puts "Kanji only: '#{kanji_test}' → '#{kanji_only.call(kanji_test)}'"

  # JIS X 0201 conversion only
  jisx0201_config = [["jisx0201-and-alike", { fullwidth_to_halfwidth: false }]]
  jisx0201_only = Yosina.make_transliterator(jisx0201_config)
  jisx_test = "ﾊﾛｰ ﾜｰﾙﾄﾞ"
  puts "JIS X 0201 only: '#{jisx_test}' → '#{jisx0201_only.call(jisx_test)}'"
end

main if __FILE__ == $0