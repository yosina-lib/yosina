# frozen_string_literal: true

require_relative 'utils'

# Render a circled or squared character transliterator
def render_circled_or_squared_transliterator(mappings)
  # Generate mapping entries for circled/squared characters
  mapping_entries = mappings.map do |key, record|
    type_abbrev = record[:type] == 'circle' ? 'c' : 's'
    record_repr = "{ rendering: #{to_string_literal(record[:rendering])}" \
                  ", type: #{to_string_literal(type_abbrev)}, emoji: #{record[:emoji]} }"
    "            #{to_string_literal(key)} => #{record_repr}"
  end.join(",\n")

  dedent 4, <<~RUBY
        # frozen_string_literal: true

        module Yosina
          module Transliterators
            # Replace circled or squared characters with their corresponding templates
            module CircledOrSquared
              # Generated mapping data from circled-or-squared.json
              CIRCLED_OR_SQUARED_MAPPINGS = {
    #{mapping_entries}
              }.freeze

              # Options for the circled or squared transliterator
              class Options
                attr_accessor :templates, :include_emojis

                def initialize(templates: nil, include_emojis: false)
                  @templates = templates || { 'circle' => '(?)', 'square' => '[?]' }
                  @include_emojis = include_emojis
                end
              end

              # Transliterator for circled or squared characters
              class Transliterator < Yosina::BaseTransliterator
                # Initialize the transliterator with options
                #
                # @param options [Hash] Configuration options
                def initialize(options = {})
                  super()
                  opts = Options.new(**options)
                  @include_emojis = opts.include_emojis
                  @templates = {
                    'c' => opts.templates['circle'] || '(?)',
                    's' => opts.templates['square'] || '[?]'
                  }
                end

                # Replace circled or squared characters with their corresponding templates
                #
                # @param input_chars [Array<Char>] The characters to transliterate
                # @return [Array<Char>] The transliterated characters
                def call(input_chars)
                  result = []
                  offset = 0

                  input_chars.each do |char|
                    mapping = CIRCLED_OR_SQUARED_MAPPINGS[char.c]
                    if mapping && (!mapping[:emoji] || @include_emojis)
                      rendering = mapping[:rendering]
                      type_abbrev = mapping[:type]
                      template = @templates[type_abbrev]
                      replacement = template.gsub('?', rendering)
    #{'                  '}
                      replacement.each_char do |replacement_char|
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
              # @param options [Hash] Configuration options
              # @return [Transliterator] A new combined transliterator instance
              def self.call(options = {})
                Transliterator.new(options)
              end
            end
          end
        end
  RUBY
end
