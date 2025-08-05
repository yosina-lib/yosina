#!/usr/bin/env ruby
# frozen_string_literal: true

# Basic usage example for Yosina Ruby library.
# This example demonstrates the fundamental transliteration functionality
# as shown in the README documentation.

require 'yosina'

def main
  puts "=== Yosina Ruby Basic Usage Example ===\n\n"

  # Create a recipe with desired transformations (matching README example)
  recipe = Yosina::TransliteratorRecipe.new(
    replace_spaces: true,
    kanji_old_new: true,
    replace_circled_or_squared_characters: true,
    replace_combined_characters: true,
    to_fullwidth: true
  )
  
  # Create the transliterator
  transliterator = Yosina.make_transliterator(recipe)
  
  # Use it with various special characters (matching README example)
  input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"  # circled numbers, letters, space, combined characters
  result = transliterator.call(input)
  
  puts "Input:  #{input}"
  puts "Output: #{result}"
  puts "Expected: （１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"
  
  # Convert old kanji to new
  puts "\n--- Old Kanji to New ---"
  old_kanji = "舊字體"
  result = transliterator.call(old_kanji)
  puts "Input:  #{old_kanji}"
  puts "Output: #{result}"
  puts "Expected: 旧字体"
  
  # Convert half-width katakana to full-width
  puts "\n--- Half-width to Full-width ---"
  half_width = "ﾃｽﾄﾓｼﾞﾚﾂ"
  result = transliterator.call(half_width)
  puts "Input:  #{half_width}"
  puts "Output: #{result}"
  puts "Expected: テストモジレツ"
end

main if __FILE__ == $0