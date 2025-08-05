# frozen_string_literal: true

module Yosina
  module Transliterators
    # Replace various space characters with plain whitespace
    module Spaces
      # Generated mapping data from spaces.json
      SPACES_MAPPINGS = {
        "\u{a0}" => ' ',
        "\u{180e}" => '',
        "\u{2000}" => ' ',
        "\u{2001}" => ' ',
        "\u{2002}" => ' ',
        "\u{2003}" => ' ',
        "\u{2004}" => ' ',
        "\u{2005}" => ' ',
        "\u{2006}" => ' ',
        "\u{2007}" => ' ',
        "\u{2008}" => ' ',
        "\u{2009}" => ' ',
        "\u{200a}" => ' ',
        "\u{200b}" => ' ',
        "\u{202f}" => ' ',
        "\u{205f}" => ' ',
        "\u{3000}" => ' ',
        "\u{3164}" => ' ',
        "\u{ffa0}" => ' ',
        "\u{feff}" => ''
      }.freeze

      # Transliterator for spaces
      class Transliterator < Yosina::BaseTransliterator
        # Initialize the transliterator with options
        #
        # @param _options [Hash] Configuration options (currently unused)
        def initialize(_options = {})
          # Options currently unused for spaces transliterator
          super()
        end

        # Replace various space characters with plain whitespace
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          offset = 0

          result = input_chars.filter_map do |char|
            replacement = SPACES_MAPPINGS[char.c]
            c = if replacement
                  # Skip empty replacements (character removal)
                  next if replacement.empty?

                  Char.new(c: replacement, offset: offset, source: char)
                else
                  char.with_offset(offset)
                end
            offset += c.c.length
            c
          end

          class << result
            include Yosina::Chars
          end

          result
        end
      end

      # Factory method to create a spaces transliterator
      #
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new spaces transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
