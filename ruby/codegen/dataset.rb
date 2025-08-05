# frozen_string_literal: true

require 'json'

# Dataset source definitions
DatasetSourceDefs = Struct.new(
  :spaces,
  :radicals,
  :mathematical_alphanumerics,
  :ideographic_annotations,
  :hyphens,
  :ivs_svs_base,
  :kanji_old_new,
  :combined,
  :circled_or_squared,
  keyword_init: true
)

# Dataset container
Dataset = Struct.new(
  :spaces,
  :radicals,
  :mathematical_alphanumerics,
  :ideographic_annotations,
  :hyphens,
  :ivs_svs_base,
  :kanji_old_new,
  :combined,
  :circled_or_squared,
  keyword_init: true
)

# Convert Unicode codepoint string to character
def unicode_to_char(unicode_str)
  return '' if unicode_str.nil?

  # Remove U+ prefix and convert to integer
  codepoint = unicode_str.sub(/^U\+/, '').to_i(16)
  [codepoint].pack('U*')
end

# Load simple mapping data (key -> value or key -> null for removal)
def load_simple_data(filepath)
  data = JSON.parse(File.read(filepath))
  mappings = {}

  data.each do |key, value|
    char_key = unicode_to_char(key)
    char_value = value.nil? ? '' : unicode_to_char(value)
    mappings[char_key] = char_value
  end

  mappings
end

# Load kanji old-new form data (array of pairs)
def load_kanji_old_new_data(filepath)
  data = JSON.parse(File.read(filepath))
  mappings = {}

  data.each do |pair|
    next unless pair.is_a?(Array) && pair.length == 2

    old_form = pair[0]
    new_form = pair[1]

    # Convert IVS sequences to characters
    old_chars = []
    new_chars = []

    if old_form['ivs']
      old_chars = old_form['ivs'].map { |cp| unicode_to_char(cp) }
    elsif old_form['svs']
      old_chars = old_form['svs'].map { |cp| unicode_to_char(cp) }
    end

    if new_form['ivs']
      new_chars = new_form['ivs'].map { |cp| unicode_to_char(cp) }
    elsif new_form['svs']
      new_chars = new_form['svs'].map { |cp| unicode_to_char(cp) }
    end

    next if old_chars.empty? || new_chars.empty?

    old_key = old_chars.join
    new_value = new_chars.join

    mappings[old_key] = new_value
  end

  mappings
end

# Load hyphens data (array of hyphen records)
def load_hyphens_data(filepath)
  data = JSON.parse(File.read(filepath))
  records = []

  data.each do |record|
    hyphen_char = unicode_to_char(record['code'])

    # Extract mappings from the record
    hyphens_record = {
      hyphen: hyphen_char,
      ascii: nil,
      jisx0201: nil,
      jisx0208_90: nil,
      jisx0208_90_windows: nil,
      jisx0208_verbatim: nil
    }

    # Map ASCII field
    if record['ascii'] && !record['ascii'].empty?
      hyphens_record[:ascii] = record['ascii'].map { |cp| unicode_to_char(cp) }.join
    end

    # Map JIS X 0201 field
    if record['jisx0201'] && !record['jisx0201'].empty?
      hyphens_record[:jisx0201] = record['jisx0201'].map { |cp| unicode_to_char(cp) }.join
    end

    # Map JIS X 0208-1978 field (use as jisx0208_90)
    if record['jisx0208-1978'] && !record['jisx0208-1978'].empty?
      hyphens_record[:jisx0208_90] = record['jisx0208-1978'].map { |cp| unicode_to_char(cp) }.join
    end

    # Map JIS X 0208-1978 Windows field
    if record['jisx0208-1978-windows'] && !record['jisx0208-1978-windows'].empty?
      hyphens_record[:jisx0208_90_windows] = record['jisx0208-1978-windows'].map { |cp| unicode_to_char(cp) }.join
    end

    records << hyphens_record
  end

  records
end

# Load IVS/SVS base data (array of mapping records)
def load_ivs_svs_base_data(filepath)
  data = JSON.parse(File.read(filepath))
  records = []

  data.each do |record|
    # Build IVS sequence
    ivs_chars = []
    ivs_chars = record['ivs'].map { |cp| unicode_to_char(cp) } if record['ivs'].is_a?(Array)

    # Build SVS sequence
    svs_chars = []
    svs_chars = record['svs'].map { |cp| unicode_to_char(cp) } if record['svs'].is_a?(Array)

    # Get base characters
    base90_char = record['base90'] ? unicode_to_char(record['base90']) : nil
    base2004_char = record['base2004'] ? unicode_to_char(record['base2004']) : nil

    # Only add record if we have IVS data
    next if ivs_chars.empty?

    records << {
      ivs: ivs_chars.join,
      svs: svs_chars.empty? ? nil : svs_chars.join,
      base90: base90_char,
      base2004: base2004_char
    }
  end

  records
end

# Load combined characters data (key -> string to be split into characters)
def load_combined_data(filepath)
  data = JSON.parse(File.read(filepath))
  mappings = {}

  data.each do |key, value|
    char_key = unicode_to_char(key)
    char_list = value.chars
    mappings[char_key] = char_list
  end

  mappings
end

# Load circled or squared characters data
def load_circled_or_squared_data(filepath)
  data = JSON.parse(File.read(filepath))
  mappings = {}

  data.each do |key, record|
    char_key = unicode_to_char(key)
    record_data = {
      rendering: record['rendering'],
      type: record['type'],
      emoji: record['emoji']
    }
    mappings[char_key] = record_data
  end

  mappings
end

# Build dataset from data root directory
def build_dataset_from_data_root(data_root, defs)
  Dataset.new(
    spaces: load_simple_data(data_root / defs.spaces),
    radicals: load_simple_data(data_root / defs.radicals),
    mathematical_alphanumerics: load_simple_data(data_root / defs.mathematical_alphanumerics),
    ideographic_annotations: load_simple_data(data_root / defs.ideographic_annotations),
    hyphens: load_hyphens_data(data_root / defs.hyphens),
    ivs_svs_base: load_ivs_svs_base_data(data_root / defs.ivs_svs_base),
    kanji_old_new: load_kanji_old_new_data(data_root / defs.kanji_old_new),
    combined: load_combined_data(data_root / defs.combined),
    circled_or_squared: load_circled_or_squared_data(data_root / defs.circled_or_squared)
  )
end
