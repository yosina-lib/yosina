# frozen_string_literal: true

require_relative 'utils'

# Render hyphens transliterator data
def render_hyphens_transliterator_data(records)
  # Generate records array - now using proper hyphens data structure
  records_data = records.map do |record|
    # Build HyphensRecord fields
    fields = []
    fields << "ascii: #{to_string_literal(record[:ascii])}" if record[:ascii]
    fields << "jisx0201: #{to_string_literal(record[:jisx0201])}" if record[:jisx0201]
    fields << "jisx0208_90: #{to_string_literal(record[:jisx0208_90])}" if record[:jisx0208_90]
    fields << "jisx0208_90_windows: #{to_string_literal(record[:jisx0208_90_windows])}" if record[:jisx0208_90_windows]
    fields << "jisx0208_verbatim: #{to_string_literal(record[:jisx0208_verbatim])}" if record[:jisx0208_verbatim]

    record_repr = if fields.empty?
                    'HyphensRecord.new'
                  else
                    "HyphensRecord.new(#{fields.join(', ')})"
                  end

    "        #{to_string_literal(record[:hyphen])} => #{record_repr}"
  end.join(",\n")

  <<~RUBY
    # frozen_string_literal: true

    module Yosina
      module Transliterators
        # Generated hyphens data
        module HyphensData
          # Record for hyphen transliteration data
          HyphensRecord = Struct.new(:ascii, :jisx0201, :jisx0208_90, :jisx0208_90_windows, :jisx0208_verbatim, keyword_init: true) do
            def initialize(ascii: nil, jisx0201: nil, jisx0208_90: nil, jisx0208_90_windows: nil, jisx0208_verbatim: nil)
              super
            end
          end

          # Generated mapping data
          HYPHENS_MAPPINGS = {
    #{records_data}
          }.freeze
        end
      end
    end
  RUBY
end
