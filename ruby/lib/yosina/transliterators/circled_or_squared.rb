# frozen_string_literal: true

require_relative 'circled_or_squared_data'

module Yosina
  module Transliterators
    # Replace circled or squared characters with their corresponding templates
    module CircledOrSquared
      # Transliterator for circled or squared characters
      class Transliterator < Yosina::BaseTransliterator
        # Initialize the transliterator with options
        #
        # @param options [Hash] Configuration options
        # @option options [Boolean] :include_emojis Whether to include emoji representations
        # @option options [Hash] :templates Custom templates for circle and square
        # @option options [String] :templates['circle'] Template for circled characters
        # @option options [String] :templates['square'] Template for squared characters
        def initialize(options = {})
          super()
          @include_emojis = options[:include_emojis] || false
          templates = options[:templates] || {}
          @templates = {
            'c' => templates['circle'] || '(?)',
            's' => templates['square'] || '[?]'
          }
        end

        # Replace circled or squared characters with their corresponding templates
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          offset = 0

          Chars.enum do |y|
            input_chars.each do |char|
              mapping = CIRCLED_OR_SQUARED_MAPPINGS[char.c]
              if mapping && (!mapping[:emoji] || @include_emojis)
                rendering = mapping[:rendering]
                type_abbrev = mapping[:type]
                template = @templates[type_abbrev]
                replacement = +template
                replacement['?'] = rendering

                replacement.each_char do |replacement_char|
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
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new combined transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
