# frozen_string_literal: true

require_relative 'utils'

# Render a combined character transliterator
def render_combined_transliterator(mappings)
  # Generate mapping entries for combined characters -> character arrays
  mapping_entries = mappings.map do |key, value_array|
    value_repr = "[#{value_array.map { |c| to_string_literal(c) }.join(', ')}]"
    "            #{to_string_literal(key)} => #{value_repr}"
  end.join(",\n")

  dedent 4, <<~RUBY
        # frozen_string_literal: true

        module Yosina
          module Transliterators
            # Replace each combined character with its corresponding individual characters
            module Combined
              # Generated mapping data from combined-chars.json
              COMBINED_MAPPINGS = {
    #{mapping_entries}
              }.freeze

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
                # @param input_chars [Array<Char>] The characters to transliterate
                # @return [Array<Char>] The transliterated characters
                def call(input_chars)
                  result = []
                  offset = 0

                  input_chars.each do |char|
                    replacement_array = COMBINED_MAPPINGS[char.c]
                    if replacement_array
                      replacement_array.each do |replacement_char|
                        result << Char.new(c: replacement_char, offset: offset, source: char)
                        offset += replacement_char.length
                      end
                    else
                      result << Char.new(c: char.c, offset: offset, source: char.source)
                      offset += char.c.length
                    end
                  end

                  result
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
  RUBY
end
