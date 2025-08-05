# frozen_string_literal: true

require_relative 'utils'

# Render IVS/SVS base transliterator data
def render_ivs_svs_base_transliterator_data(records)
  # Build compressed data similar to Python implementation
  compressed_parts = []
  records.each do |record|
    compressed_parts << (record[:ivs] || '')
    compressed_parts << (record[:svs] || '')
    compressed_parts << (record[:base90] || '')
    compressed_parts << (record[:base2004] || '')
  end
  compressed_data = compressed_parts.join("\0")
  compressed_data_escaped = to_string_literal(compressed_data)

  dedent(4, <<~RUBY
    # frozen_string_literal: true

    module Yosina
      module Transliterators
        # Generated IVS/SVS base data
        module IvsSvsBaseData
          # Record for IVS/SVS base transliteration data
          IvsSvsBaseRecord = Struct.new(:ivs, :svs, :base90, :base2004, keyword_init: true) do
            def initialize(ivs:, svs: nil, base90: nil, base2004: nil)
              super
            end
          end

          # Compressed data table - 4 strings per record: [ivs, svs, base90, base2004, ...]
          COMPRESSED_DATA = #{compressed_data_escaped}.freeze
          RECORDS_COUNT = #{records.length}

          # Expand compressed data into a mapping dictionary
          def self.expand_compressed_data
            mappings = {}
            # Split by null bytes to get all fields
            fields = COMPRESSED_DATA.split("\\0")
            # Process 4 fields at a time (ivs, svs, base90, base2004)
            (0...fields.length).step(4) do |i|
              next unless i + 3 < fields.length
              ivs = fields[i]
              svs = fields[i + 1].empty? ? nil : fields[i + 1]
              base90 = fields[i + 2].empty? ? nil : fields[i + 2]
              base2004 = fields[i + 3].empty? ? nil : fields[i + 3]
              # Only add if ivs is not empty
              if !ivs.empty?
                mappings[ivs] = IvsSvsBaseRecord.new(
                  ivs: ivs,
                  svs: svs,
                  base90: base90,
                  base2004: base2004
                )
              end
            end
            mappings
          end

          # Lazy-loaded mappings cache
          @mappings_cache = nil
          @base_to_variants_cache = nil
          @variants_to_base_cache = nil

          # Get the IVS/SVS mappings dictionary, loading it if necessary
          def self.get_ivs_svs_mappings
            @mappings_cache ||= expand_compressed_data
          end

          # Build optimized lookup tables for base-to-variants and variants-to-base mappings
          def self.populate_lookup_tables
            return if @base_to_variants_cache && @variants_to_base_cache

            mappings = get_ivs_svs_mappings

            # For base->IVS/SVS lookup (used in "ivs-or-svs" mode)
            base_to_variants_2004 = {}
            base_to_variants_90 = {}

            # For IVS/SVS->base lookup (used in "base" mode)
            variants_to_base = {}

            mappings.each do |variant_seq, record|
              # Map base characters to their IVS/SVS variants
              if record.base2004 && !base_to_variants_2004.key?(record.base2004)
                base_to_variants_2004[record.base2004] = record
              end

              if record.base90 && !base_to_variants_90.key?(record.base90)
                base_to_variants_90[record.base90] = record
              end

              # Map IVS/SVS variants back to base characters
              variants_to_base[variant_seq] = record
            end

            @base_to_variants_cache = {
              'unijis_2004' => base_to_variants_2004,
              'unijis_90' => base_to_variants_90
            }
            @variants_to_base_cache = variants_to_base
          end

          # Get base character to variants mapping for the specified charset
          def self.get_base_to_variants_mappings(charset = 'unijis_2004')
            populate_lookup_tables
            @base_to_variants_cache[charset]
          end

          # Get variants to base character mapping
          def self.get_variants_to_base_mappings
            populate_lookup_tables
            @variants_to_base_cache
          end
        end
      end
    end
  RUBY
  )
end
