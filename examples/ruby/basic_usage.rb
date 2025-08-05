#!/usr/bin/env ruby
# frozen_string_literal: true

# Basic usage example for Yosina Ruby library.
# This example demonstrates the fundamental transliteration functionality.

require_relative '../../ruby/lib/yosina'

def main
  puts "=== Yosina Ruby Basic Usage Example ===\n\n"

  # Create a simple recipe for kanji old-to-new conversion
  recipe = Yosina::TransliteratorRecipe.new(kanji_old_new: true)
  transliterator = Yosina.make_transliterator(recipe)

  # Test text with old-style kanji
  test_text = "舊字體の變換テスト"
  result = transliterator.call(test_text)

  puts "Original: #{test_text}"
  puts "Result:   #{result}"

  # More comprehensive example
  puts "\n--- Comprehensive Example ---"

  comprehensive_recipe = Yosina::TransliteratorRecipe.new(
    kanji_old_new: true,
    replace_spaces: true,
    replace_suspicious_hyphens_to_prolonged_sound_marks: true,
    to_fullwidth: true,
    combine_decomposed_hiraganas_and_katakanas: true,
    replace_radicals: true,
    replace_circled_or_squared_characters: true,
    replace_combined_characters: true
  )

  comprehensive_transliterator = Yosina.make_transliterator(comprehensive_recipe)

  # Test with various Japanese text issues
  test_cases = [
    ["hello　world", "Ideographic space"],
    ["カタカナ-テスト", "Suspicious hyphen"],
    ["ABC123", "Half-width to full-width"],
    ["舊字體の變換テスト", "Old kanji"],
    ["ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana"],
    ["①②③ⒶⒷⒸ", "Circled characters"],
    ["㋿㍿", "CJK compatibility characters"]
  ]

  test_cases.each do |test_case, description|
    result = comprehensive_transliterator.call(test_case)
    puts "#{description}: '#{test_case}' → '#{result}'"
  end
end

main if __FILE__ == $0