#!/usr/bin/env ruby
# frozen_string_literal: true

# Advanced usage examples for Yosina Ruby library.
# This example demonstrates complex use cases and various configuration options.

require 'yosina'

def main
  puts "=== Advanced Yosina Ruby Usage Examples ===\n\n"

  # 1. Web scraping text normalization
  puts "1. Web Scraping Text Normalization"
  puts "   (Typical use case: cleaning scraped Japanese web content)"

  web_scraping_recipe = Yosina::TransliterationRecipe.new(
    kanji_old_new: true,
    replace_spaces: true,
    replace_suspicious_hyphens_to_prolonged_sound_marks: true,
    replace_ideographic_annotations: true,
    replace_radicals: true,
    combine_decomposed_hiraganas_and_katakanas: true
  )

  normalizer = Yosina.make_transliterator(web_scraping_recipe)

  # Simulate messy web content
  messy_content = [
    ["これは　テスト です。", "Mixed spaces from different sources"],
    ["コンピューター-プログラム", "Suspicious hyphens in katakana"],
    ["古い漢字：廣島、檜、國", "Old-style kanji forms"],
    ["部首：⺅⻌⽊", "CJK radicals instead of regular kanji"]
  ]

  messy_content.each do |text, description|
    cleaned = normalizer.call(text)
    puts "  #{description}:"
    puts "    Before: '#{text}'"
    puts "    After:  '#{cleaned}'"
    puts
  end

  # 2. Document standardization
  puts "2. Document Standardization"
  puts "   (Use case: preparing documents for consistent formatting)"

  document_recipe = Yosina::TransliterationRecipe.new(
    to_fullwidth: true,
    replace_spaces: true,
    kanji_old_new: true,
    combine_decomposed_hiraganas_and_katakanas: true
  )

  document_standardizer = Yosina.make_transliterator(document_recipe)

  document_samples = [
    ["Hello World 123", "ASCII text to full-width"],
    ["カ゛", "Decomposed katakana with combining mark"],
    ["檜原村", "Old kanji in place names"]
  ]

  document_samples.each do |text, description|
    standardized = document_standardizer.call(text)
    puts "  #{description}:"
    puts "    Input:  '#{text}'"
    puts "    Output: '#{standardized}'"
    puts
  end

  # 3. Search index preparation
  puts "3. Search Index Preparation"
  puts "   (Use case: normalizing text for search engines)"

  search_recipe = Yosina::TransliterationRecipe.new(
    kanji_old_new: true,
    replace_spaces: true,
    to_halfwidth: true,
    replace_suspicious_hyphens_to_prolonged_sound_marks: true
  )

  search_normalizer = Yosina.make_transliterator(search_recipe)

  search_samples = [
    ["東京スカイツリー", "Famous landmark name"],
    ["プログラミング言語", "Technical terms"],
    ["コンピューター-サイエンス", "Academic field with suspicious hyphen"]
  ]

  search_samples.each do |text, description|
    normalized = search_normalizer.call(text)
    puts "  #{description}:"
    puts "    Original:   '#{text}'"
    puts "    Normalized: '#{normalized}'"
    puts
  end

  # 4. Custom pipeline example
  puts "4. Custom Processing Pipeline"
  puts "   (Use case: step-by-step text transformation)"

  # Create multiple transliterators for pipeline processing
  steps = [
    ["Spaces", [["spaces", {}]]],
    [
      "Old Kanji",
      [
        ["ivs-svs-base", { mode: "ivs-or-svs", charset: "unijis_2004" }],
        ["kanji-old-new", {}],
        ["ivs-svs-base", { mode: "base", charset: "unijis_2004" }]
      ]
    ],
    ["Width", [["jisx0201-and-alike", { u005c_as_yen_sign: false }]]],
    ["ProlongedSoundMarks", [["prolonged-sound-marks", {}]]]
  ]

  transliterators = []
  steps.each do |name, config|
    transliterator = Yosina.make_transliterator(config)
    transliterators << [name, transliterator]
  end

  pipeline_text = "hello\u{3000}world ﾃｽﾄ 檜-システム"
  current_text = pipeline_text

  puts "  Starting text: '#{current_text}'"

  transliterators.each do |step_name, transliterator|
    previous_text = current_text
    current_text = transliterator.call(current_text)
    if previous_text != current_text
      puts "  After #{step_name}: '#{current_text}'"
    end
  end

  puts "  Final result: '#{current_text}'"

  # 5. Unicode normalization showcase
  puts "\n5. Unicode Normalization Showcase"
  puts "   (Demonstrating various Unicode edge cases)"

  unicode_recipe = Yosina::TransliterationRecipe.new(
    replace_spaces: true,
    replace_mathematical_alphanumerics: true,
    replace_radicals: true
  )

  unicode_normalizer = Yosina.make_transliterator(unicode_recipe)

  unicode_samples = [
    ["\u{2003}\u{2002}\u{2000}", "Various em/en spaces"],
    ["\u{3000}\u{00A0}\u{202F}", "Ideographic and narrow spaces"],
    ["⺅⻌⽊", "CJK radicals"],
    ["\u{1D400}\u{1D401}\u{1D402}", "Mathematical bold letters"]
  ]

  puts "\n   Processing text samples with character codes:\n"
  unicode_samples.each do |text, description|
    puts "   #{description}:"
    puts "     Original: '#{text}'"
    
    # Show character codes for clarity
    char_codes = text.codepoints.map { |c| "U+#{c.to_s(16).upcase.rjust(4, '0')}" }.join(" ")
    puts "     Codes:    #{char_codes}"
    
    normalized = unicode_normalizer.call(text)
    puts "     Result:   '#{normalized}'\n"
  end

  # 6. Performance considerations
  puts "6. Performance Considerations"
  puts "   (Reusing transliterators for better performance)"

  perf_recipe = Yosina::TransliterationRecipe.new(
    kanji_old_new: true,
    replace_spaces: true
  )

  perf_transliterator = Yosina.make_transliterator(perf_recipe)

  # Simulate processing multiple texts
  texts = [
    "これはテストです",
    "檜原村は美しい",
    "hello　world",
    "プログラミング"
  ]

  puts "  Processing #{texts.length} texts with the same transliterator:"
  texts.each_with_index do |text, i|
    result = perf_transliterator.call(text)
    puts "    #{i + 1}: '#{text}' → '#{result}'"
  end

  puts "\n=== Advanced Examples Complete ==="
end

main if __FILE__ == $0