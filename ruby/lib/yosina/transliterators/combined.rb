# frozen_string_literal: true

require_relative 'combined_data'

module Yosina
  module Transliterators
    # Replace each combined character with its corresponding individual characters
    module Combined
      # Transliterator for combined characters
      class Transliterator < Yosina::BaseTransliterator
        # Initialize the transliterator with options
        #
        # @param _options [Hash] Configuration options (currently unused)
        def initialize(_options = {})
          # Options currently unused for combined transliterator
          super()
        end

        # Replace each combined character with its corresponding individual characters
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          offset = 0

          Chars.enum do |y|
            input_chars.each do |char|
              replacement_array = COMBINED_MAPPINGS[char.c]
              if replacement_array
                replacement_array.each do |replacement_char|
                  y << Char.new(c: replacement_char, offset: offset, source: char)
                  offset += replacement_char.length
                end
              else
                y << Char.new(c: char.c, offset: offset, source: char.source)
                offset += char.c.length
              end
            end
          end
        end
      end

      # Factory method to create a combined transliterator
      #
      # @param _options [Hash] Configuration options
      # @return [Transliterator] A new combined transliterator instance
      def self.call(_options = {})
        Transliterator.new
      end
    end
  end
end
