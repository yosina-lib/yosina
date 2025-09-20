# frozen_string_literal: true

require_relative 'utils'

# Render a roman numerals transliterator
def render_roman_numerals_transliterator_data(mappings)
  # Generate mapping entries for roman numerals -> decomposed arrays
  mapping_entries = mappings.map do |key, record|
    decomposed_array = record[:decomposed]
    value_repr = "[#{decomposed_array.map { |c| to_string_literal(c) }.join(', ')}]"
    "            #{to_string_literal(key)} => #{value_repr}"
  end.join(",\n")

  dedent 4, <<~RUBY
        # frozen_string_literal: true

        module Yosina
          module Transliterators
            # Replace roman numeral characters with their ASCII letter equivalents
            module RomanNumerals
              # Generated mapping data from roman-numerals.json
              ROMAN_NUMERAL_MAPPINGS = {
    #{mapping_entries}
              }.freeze
            end
          end
        end
  RUBY
end
