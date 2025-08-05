#!/usr/bin/env ruby
# frozen_string_literal: true

# Basic usage example for Yosina Ruby library.
# This example demonstrates the fundamental transliteration functionality
# as shown in the README documentation.

require 'yosina'

def main
  puts "=== Yosina Ruby Basic Usage Example ===\n\n"

  # Create a recipe with desired transformations (matching README example)
  recipe = Yosina::TransliterationRecipe.new(
    kanji_old_new: true,
    replace_spaces: true,
    replace_suspicious_hyphens_to_prolonged_sound_marks: true,
    replace_circled_or_squared_characters: true,
    replace_combined_characters: true,
    replace_japanese_iteration_marks: true, # Expand iteration marks
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
  
  # Demonstrate Japanese iteration marks expansion
  puts "\n--- Japanese Iteration Marks Examples ---"
  iteration_examples = [
    "佐々木", # kanji iteration
    "すゝき", # hiragana iteration
    "いすゞ", # hiragana voiced iteration
    "サヽキ", # katakana iteration
    "ミスヾ"  # katakana voiced iteration
  ]
  
  iteration_examples.each do |text|
    result = transliterator.call(text)
    puts "#{text} → #{result}"
  end
  
  # Demonstrate hiragana to katakana conversion separately
  puts "\n--- Hiragana to Katakana Conversion ---"
  # Create a separate recipe for just hiragana to katakana conversion
  hira_kata_recipe = Yosina::TransliterationRecipe.new(
    hira_kata: "hira-to-kata" # Convert hiragana to katakana
  )
  
  hira_kata_transliterator = Yosina.make_transliterator(hira_kata_recipe)
  
  hira_kata_examples = [
    "ひらがな", # pure hiragana
    "これはひらがなです", # hiragana sentence
    "ひらがなとカタカナ" # mixed hiragana and katakana
  ]
  
  hira_kata_examples.each do |text|
    result = hira_kata_transliterator.call(text)
    puts "#{text} → #{result}"
  end
  
  # Also demonstrate katakana to hiragana conversion
  puts "\n--- Katakana to Hiragana Conversion ---"
  kata_hira_recipe = Yosina::TransliterationRecipe.new(
    hira_kata: "kata-to-hira" # Convert katakana to hiragana
  )
  
  kata_hira_transliterator = Yosina.make_transliterator(kata_hira_recipe)
  
  kata_hira_examples = [
    "カタカナ", # pure katakana
    "コレハカタカナデス", # katakana sentence
    "カタカナとひらがな" # mixed katakana and hiragana
  ]
  
  kata_hira_examples.each do |text|
    result = kata_hira_transliterator.call(text)
    puts "#{text} → #{result}"
  end
end

main if __FILE__ == $0