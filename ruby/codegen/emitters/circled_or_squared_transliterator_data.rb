# frozen_string_literal: true

require_relative 'utils'

# Render a circled or squared character transliterator
def render_circled_or_squared_transliterator_data(mappings)
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
            end
          end
        end
  RUBY
end
