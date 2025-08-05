# frozen_string_literal: true

require_relative 'utils'

# Render a simple transliterator with a mapping table
def render_simple_transliterator(name, description, mappings)
  class_name = name.split('_').map(&:capitalize).join
  constant_name = "#{name.upcase}_MAPPINGS"

  # Generate mapping entries
  mapping_entries = mappings.map do |key, value|
    "            #{to_string_literal(key)} => #{to_string_literal(value)}"
  end.join(",\n")

  dedent 4, <<~RUBY
        # frozen_string_literal: true

        module Yosina
          module Transliterators
            # #{description}
            module #{class_name}
              # Generated mapping data from #{name}.json
              #{constant_name} = {
    #{mapping_entries}
              }.freeze

              # Transliterator for #{name}
              class Transliterator < Yosina::BaseTransliterator
                # Initialize the transliterator with options
                #
                # @param _options [Hash] Configuration options (currently unused)
                def initialize(_options = {})
                  # Options currently unused for #{name} transliterator
                  super()
                end

                # #{description}
                #
                # @param input_chars [Array<Char>] The characters to transliterate
                # @return [Array<Char>] The transliterated characters
                def call(input_chars)
                  input_chars.map do |char|
                    replacement = #{constant_name}[char.c]
                    if replacement
                      # Skip empty replacements (character removal)
                      next if replacement.empty?

                      Char.new(c: replacement, offset: char.offset, source: char)
                    else
                      char
                    end
                  end.compact
                end
              end

              # Factory method to create a #{name} transliterator
              #
              # @param _options [Hash] Configuration options
              # @return [Transliterator] A new #{name} transliterator instance
              def self.call(options = {})
                Transliterator.new(options)
              end
            end
          end
        end
  RUBY
end
