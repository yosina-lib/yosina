# frozen_string_literal: true

require_relative 'utils'

# Render a combined character transliterator
def render_combined_transliterator_data(mappings)
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
            end
          end
        end
  RUBY
end
