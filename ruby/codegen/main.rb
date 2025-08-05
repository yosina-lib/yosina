#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'pathname'

require_relative 'dataset'
require_relative 'emitters'

# Main code generation entry point
def main
  # Determine project paths
  current_dir = Pathname(__FILE__).parent
  project_root = current_dir.parent
  data_root = project_root.parent / 'data'
  dest_root = project_root / 'lib' / 'yosina' / 'transliterators'

  puts "Loading dataset from: #{data_root}"
  puts "Writing output to: #{dest_root}"

  # Ensure destination directory exists
  dest_root.mkpath

  # Define dataset source definitions
  defs = DatasetSourceDefs.new(
    spaces: 'spaces.json',
    radicals: 'radicals.json',
    mathematical_alphanumerics: 'mathematical-alphanumerics.json',
    ideographic_annotations: 'ideographic-annotation-marks.json',
    hyphens: 'hyphens.json',
    ivs_svs_base: 'ivs-svs-base-mappings.json',
    kanji_old_new: 'kanji-old-new-form.json',
    combined: 'combined-chars.json',
    circled_or_squared: 'circled-or-squared.json'
  )

  # Load the dataset
  dataset = build_dataset_from_data_root(data_root, defs)

  # Generate simple transliterators
  simple_transliterators = [
    [
      'spaces',
      'Replace various space characters with plain whitespace',
      dataset.spaces
    ],
    [
      'radicals',
      'Replace Kangxi radicals with equivalent CJK ideographs',
      dataset.radicals
    ],
    [
      'mathematical_alphanumerics',
      'Replace mathematical alphanumeric symbols with plain characters',
      dataset.mathematical_alphanumerics
    ],
    [
      'ideographic_annotations',
      'Replace ideographic annotation marks used in traditional translation',
      dataset.ideographic_annotations
    ],
    [
      'kanji_old_new',
      'Replace old-style kanji with modern equivalents',
      dataset.kanji_old_new
    ]
  ]

  simple_transliterators.each do |name, description, data|
    output = render_simple_transliterator(name, description, data)
    filename = "#{snake_case(name)}.rb"
    filepath = dest_root / filename
    puts "Generating: #{filename}"
    filepath.write(output)
  end

  # Generate hyphens data
  output = render_hyphens_transliterator_data(dataset.hyphens)
  filepath = dest_root / 'hyphens_data.rb'
  puts 'Generating: hyphens_data.rb'
  filepath.write(output)

  # Generate IVS/SVS base data
  output = render_ivs_svs_base_transliterator_data(dataset.ivs_svs_base)
  filepath = dest_root / 'ivs_svs_base_data.rb'
  puts 'Generating: ivs_svs_base_data.rb'
  filepath.write(output)

  # Generate combined transliterator
  output = render_combined_transliterator_data(dataset.combined)
  filepath = dest_root / 'combined_data.rb'
  puts 'Generating: combined_data.rb'
  filepath.write(output)

  # Generate circled or squared transliterator
  output = render_circled_or_squared_transliterator_data(dataset.circled_or_squared)
  filepath = dest_root / 'circled_or_squared_data.rb'
  puts 'Generating: circled_or_squared_data.rb'
  filepath.write(output)

  puts 'Code generation complete!'
end

# Convert camelCase to snake_case
def snake_case(str)
  str.gsub(/([A-Z])/, '_\1').downcase.sub(/^_/, '')
end

main if $PROGRAM_NAME == __FILE__
