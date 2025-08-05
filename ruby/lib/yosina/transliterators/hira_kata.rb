# frozen_string_literal: true

require_relative 'hira_kata_table'

module Yosina
  module Transliterators
    # Module for converting between Hiragana and Katakana scripts
    module HiraKata
      include HiraKataTable

      # Cache for mapping tables
      @mapping_cache = {}

      class << self
        attr_accessor :mapping_cache
      end

      # Transliterator for hiragana/katakana conversion
      class Transliterator < Yosina::BaseTransliterator
        attr_reader :mode

        # Initialize the transliterator with options
        #
        # @param options [Hash] Configuration options
        # @option options [Symbol] :mode Either :hira_to_kata or :kata_to_hira
        def initialize(options = {})
          super()
          @mode = options[:mode] || :hira_to_kata
          @mapping_table = HiraKata.build_mapping_table(@mode)
        end

        # Convert between hiragana and katakana
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          Chars.enum do |y|
            input_chars.each do |char|
              if char.sentinel?
                y << char
                break
              end

              mapped = @mapping_table[char.c]
              y << if mapped
                     Char.new(c: mapped, offset: char.offset, source: char)
                   else
                     char
                   end
            end
          end
        end
      end

      # Build the mapping table for the specified mode
      # @param mode [Symbol] :hira_to_kata or :kata_to_hira
      # @return [Hash<String, String>]
      def self.build_mapping_table(mode)
        # Check cache first
        cached = @mapping_cache[mode]
        return cached if cached

        mapping = {}

        # Main table mappings
        HIRAGANA_KATAKANA_TABLE.each do |hiragana_entry, katakana_entry, _|
          next unless hiragana_entry

          hira, hira_voiced, hira_semivoiced = hiragana_entry
          kata, kata_voiced, kata_semivoiced = katakana_entry

          if mode == :hira_to_kata
            mapping[hira] = kata
            mapping[hira_voiced] = kata_voiced if hira_voiced && kata_voiced
            mapping[hira_semivoiced] = kata_semivoiced if hira_semivoiced && kata_semivoiced
          else
            mapping[kata] = hira
            mapping[kata_voiced] = hira_voiced if kata_voiced && hira_voiced
            mapping[kata_semivoiced] = hira_semivoiced if kata_semivoiced && hira_semivoiced
          end
        end

        # Small character mappings
        HIRAGANA_KATAKANA_SMALL_TABLE.each do |hira, kata, _|
          if mode == :hira_to_kata
            mapping[hira] = kata
          else
            mapping[kata] = hira
          end
        end

        # Cache the result
        @mapping_cache[mode] = mapping
        mapping
      end

      # Factory method to create a hiragana/katakana transliterator
      #
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new hiragana/katakana transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
