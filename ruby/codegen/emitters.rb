# frozen_string_literal: true

# Main emitters file that requires all individual emitter modules
require_relative 'emitters/simple_transliterator'
require_relative 'emitters/hyphens_transliterator_data'
require_relative 'emitters/ivs_svs_base_transliterator_data'
require_relative 'emitters/combined_transliterator_data'
require_relative 'emitters/circled_or_squared_transliterator_data'
require_relative 'emitters/roman_numerals_transliterator_data'
