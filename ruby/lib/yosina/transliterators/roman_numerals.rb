# frozen_string_literal: true

require_relative 'roman_numerals_data'

module Yosina
  module Transliterators
    # Replace roman numeral characters with their ASCII letter equivalents
    module RomanNumerals
      # Transliterator for roman numerals
      class Transliterator < Yosina::BaseTransliterator
        # Initialize the transliterator
        def initialize(_options = nil)
          super()
        end

        # Convert roman numeral characters to ASCII equivalents
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          offset = 0

          Chars.enum do |y|
            input_chars.each do |char|
              replacement = RomanNumerals::ROMAN_NUMERAL_MAPPINGS[char.c]
              if replacement
                replacement.each do |c|
                  y << Char.new(c: c, offset: offset, source: char)
                  offset += c.length
                end
              else
                y << Char.new(c: char.c, offset: offset, source: char)
                offset += char.c.length
              end
            end
          end
        end
      end

      # Factory method to create a transliterator
      #
      # @param options [Hash] Configuration options (currently unused)
      # @return [Transliterator] A new transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
