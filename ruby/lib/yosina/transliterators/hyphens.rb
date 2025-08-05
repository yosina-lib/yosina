# frozen_string_literal: true

require_relative 'hyphens_data'

module Yosina
  module Transliterators
    # Handle hyphen replacement with precedence logic
    module Hyphens
      # Default precedence of mappings (matching JavaScript default)
      # rubocop:disable Naming/VariableNumber
      DEFAULT_PRECEDENCE = [:jisx0208_90].freeze
      # rubocop:enable Naming/VariableNumber

      # Transliterator for hyphens
      class Transliterator < Yosina::BaseTransliterator
        attr_reader :precedence

        # Initialize the transliterator with options
        #
        # @param options [Hash] Configuration options
        # @option options [Array<Symbol>] :precedence List of mapping variants to apply in order.
        #   Available options: :ascii, :jisx0201, :jisx0208_90, :jisx0208_90_windows, :jisx0208_verbatim
        #   Defaults to [:jisx0208_90]
        def initialize(options = nil)
          super()
          @precedence = options[:precedence] || DEFAULT_PRECEDENCE
        end

        # Normalize hyphen characters based on precedence
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          offset = 0

          Chars.enum do |y|
            input_chars.each do |char|
              record = HyphensData::HYPHENS_MAPPINGS[char.c]
              if record
                replacement = get_replacement(record)
                if replacement && replacement != char.c
                  replacement.each_char do |c|
                    y << Char.new(c: c, offset: offset, source: char)
                    offset += replacement.length
                  end
                else
                  y << Char.new(c: char.c, offset: offset, source: char)
                  offset += char.c.length
                end
              else
                y << Char.new(c: char.c, offset: offset, source: char)
                offset += char.c.length
              end
            end
          end
        end

        private

        # Get the replacement character based on precedence
        #
        # @param record [HyphensData::HyphensRecord] The hyphen record containing mapping options
        # @return [String, nil] The replacement character or nil if no mapping found
        def get_replacement(record)
          @precedence.each do |mapping_type|
            replacement = (record.send mapping_type if record.respond_to?(mapping_type))
            return replacement if replacement
          end

          nil
        end
      end

      # Factory method to create a hyphens transliterator
      #
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new hyphens transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
