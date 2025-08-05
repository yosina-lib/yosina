# frozen_string_literal: true

module Yosina
  module Transliterators
    # Replace ideographic annotation marks used in traditional translation
    module IdeographicAnnotations
      # Generated mapping data from ideographic_annotations.json
      IDEOGRAPHIC_ANNOTATIONS_MAPPINGS = {
        "\u{3192}" => "\u{4e00}",
        "\u{3193}" => "\u{4e8c}",
        "\u{3194}" => "\u{4e09}",
        "\u{3195}" => "\u{56db}",
        "\u{3196}" => "\u{4e0a}",
        "\u{3197}" => "\u{4e2d}",
        "\u{3198}" => "\u{4e0b}",
        "\u{3199}" => "\u{7532}",
        "\u{319a}" => "\u{4e59}",
        "\u{319b}" => "\u{4e19}",
        "\u{319c}" => "\u{4e01}",
        "\u{319d}" => "\u{5929}",
        "\u{319e}" => "\u{5730}",
        "\u{319f}" => "\u{4eba}"
      }.freeze

      # Transliterator for ideographic_annotations
      class Transliterator < Yosina::BaseTransliterator
        # Initialize the transliterator with options
        #
        # @param _options [Hash] Configuration options (currently unused)
        def initialize(_options = {})
          # Options currently unused for ideographic_annotations transliterator
          super()
        end

        # Replace ideographic annotation marks used in traditional translation
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          offset = 0

          result = input_chars.filter_map do |char|
            replacement = IDEOGRAPHIC_ANNOTATIONS_MAPPINGS[char.c]
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

      # Factory method to create a ideographic_annotations transliterator
      #
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new ideographic_annotations transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
