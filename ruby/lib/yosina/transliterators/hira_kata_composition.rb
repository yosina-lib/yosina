# frozen_string_literal: true

require_relative 'hira_kata_table'

module Yosina
  module Transliterators
    # Hiragana/katakana composition transliterator
    module HiraKataComposition
      include HiraKataTable

      VOICED_SOUND_MARK_MAPPINGS = Hash[VOICED_CHARACTERS].freeze
      SEMI_VOICED_SOUND_MARK_MAPPINGS = Hash[SEMI_VOICED_CHARACTERS].freeze

      # Combining mark mappings for hiragana and katakana
      COMBINING_MARKS = {
        "\u3099" => VOICED_SOUND_MARK_MAPPINGS,
        "\u309A" => SEMI_VOICED_SOUND_MARK_MAPPINGS
      }.freeze

      # Non-combining mark mappings
      NON_COMBINING_MARKS = {
        "\u3099" => VOICED_SOUND_MARK_MAPPINGS,
        "\u309A" => SEMI_VOICED_SOUND_MARK_MAPPINGS,
        "\u309B" => VOICED_SOUND_MARK_MAPPINGS,
        "\u309C" => SEMI_VOICED_SOUND_MARK_MAPPINGS
      }.freeze

      # Transliterator for hiragana/katakana composition
      class Transliterator < Yosina::BaseTransliterator
        attr_reader :compose_non_combining_marks

        # Initialize the transliterator with options
        #
        # @param options [Hash] Configuration options
        # @option options [Boolean] :compose_non_combining_marks Whether to compose non-combining
        #     marks (゛ and ゜) too. Defaults to false.
        def initialize(options = {})
          super()
          @compose_non_combining_marks = options[:compose_non_combining_marks] || false
          @mappings = @compose_non_combining_marks ? NON_COMBINING_MARKS : COMBINING_MARKS
        end

        # Combine decomposed hiragana and katakana characters with their marks
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          e = input_chars.each
          offset = 0

          Chars.enum do |y|
            begin
              prev = e.next
            rescue StopIteration
              break
            end

            if prev.sentinel?
              y << prev
              break
            end

            loop do
              begin
                char = e.next
              rescue StopIteration
                break
              end

              if prev
                # Check for combining marks
                if (mark_mapping = @mappings[char.c]) && (composed = mark_mapping[prev.c])
                  # Found a composable combination
                  y << Char.new(c: composed, offset: offset, source: char)
                  offset += composed.length
                  prev = nil
                  next
                end

                # No composition possible, keep original character
                y << prev.with_offset(offset)
                offset += prev.c.length
              end
              prev = char
            end
            if prev
              y << prev.with_offset(offset)
              offset += prev.c.length
            end
          end
        end
      end

      # Factory method to create a hiragana/katakana composition transliterator
      #
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new composition transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
