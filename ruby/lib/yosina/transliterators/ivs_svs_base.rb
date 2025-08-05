# frozen_string_literal: true

require_relative 'ivs_svs_base_data'

module Yosina
  module Transliterators
    # IVS/SVS base handling with proper forward and reverse transliteration
    module IvsSvsBase
      # Forward transliterator to add IVS/SVS selectors to base characters
      class ForwardTransliterator
        attr_reader :base_to_variants, :prefer_svs

        # Initialize the forward transliterator with options
        #
        # @param base_to_variants [Hash] Mapping of base characters to their IVS/SVS variants
        # @param prefer_svs [Boolean] Whether to prefer SVS over IVS when both exist
        def initialize(base_to_variants, prefer_svs)
          @base_to_variants = base_to_variants
          @prefer_svs = prefer_svs
        end

        # Add IVS/SVS selectors to base characters
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          offset = 0

          Chars.enum do |y|
            input_chars.each do |char|
              # Try to add IVS/SVS selectors to base characters
              record = @base_to_variants[char.c]
              replacement = nil
              if record
                if @prefer_svs && record.svs
                  replacement = record.svs
                elsif record.ivs
                  replacement = record.ivs
                end
              end

              if replacement
                y << Char.new(c: replacement, offset: offset, source: char)
                offset += replacement.length
              else
                y << char.with_offset(offset)
                offset += char.c.length
              end
            end
          end
        end
      end

      # Reverse transliterator to remove IVS/SVS selectors and get base characters
      class ReverseTransliterator
        attr_reader :variants_to_base, :charset, :drop_selectors_altogether

        # Initialize the reverse transliterator with options
        #
        # @param variants_to_base [Hash] Mapping of IVS/SVS characters to their base forms
        # @param charset [String] The charset to use for base mappings ("unijis_90" or "unijis_2004")
        # @param drop_selectors_altogether [Boolean] Whether to drop all selectors
        def initialize(variants_to_base, charset, drop_selectors_altogether)
          @variants_to_base = variants_to_base
          @charset = charset
          @drop_selectors_altogether = drop_selectors_altogether
        end

        # Remove IVS/SVS selectors to get base characters
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          offset = 0

          Chars.enum do |y|
            input_chars.each do |char|
              replacement = nil

              # Try to remove IVS/SVS selectors
              record = @variants_to_base[char.c]
              if record
                if @charset == 'unijis_2004' && record.base2004
                  replacement = record.base2004
                elsif @charset == 'unijis_90' && record.base90
                  replacement = record.base90
                end
              end

              # If no replacement found and drop_selectors_altogether is true,
              # try to remove variation selectors manually
              if !replacement && @drop_selectors_altogether && char.c.length > 1
                second_char = char.c[1]
                second_char_ord = second_char.ord
                # Check for variation selectors: U+FE00-U+FE0F or U+E0100-U+E01EF
                if (second_char_ord >= 0xFE00 && second_char_ord <= 0xFE0F) ||
                   (second_char_ord >= 0xE0100 && second_char_ord <= 0xE01EF)
                  replacement = char.c[0]
                end
              end

              if replacement
                y << Char.new(c: replacement, offset: offset, source: char)
                offset += replacement.length
              else
                y << char.with_offset(offset)
                offset += char.c.length
              end
            end
          end
        end
      end

      # Main IVS/SVS base transliterator
      class Transliterator < Yosina::BaseTransliterator
        attr_reader :mode, :drop_selectors_altogether, :charset, :prefer_svs, :inner

        # Initialize the transliterator with options
        #
        # @param options [Hash] Configuration options
        # @option options [String] :mode The mode of operation ("ivs-or-svs", "base"). Defaults to "base".
        #   - "ivs-or-svs": Add IVS/SVS selectors to kanji characters
        #   - "base": Remove IVS/SVS selectors to get base characters
        # @option options [Boolean] :drop_selectors_altogether Whether to drop all selectors when mode is "base".
        #   Defaults to false.
        # @option options [String] :charset The charset to use for base mappings ("unijis_90" or "unijis_2004").
        #   Defaults to "unijis_2004".
        # @option options [Boolean] :prefer_svs When mode is "ivs-or-svs", prefer SVS over IVS if both exist.
        #   Defaults to false.
        def initialize(options = {})
          super()
          @mode = options[:mode] || 'base'
          @drop_selectors_altogether = options[:drop_selectors_altogether] || false
          @charset = options[:charset] || 'unijis_2004'
          @prefer_svs = options[:prefer_svs] || false

          @inner = if @mode == 'ivs-or-svs'
                     ForwardTransliterator.new(
                       IvsSvsBaseData.get_base_to_variants_mappings(@charset),
                       @prefer_svs
                     )
                   else
                     ReverseTransliterator.new(
                       IvsSvsBaseData.get_variants_to_base_mappings,
                       @charset,
                       @drop_selectors_altogether
                     )
                   end
        end

        # Handle IVS/SVS sequences
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          @inner.call(input_chars)
        end
      end

      # Factory method to create an IVS/SVS base transliterator
      #
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new IVS/SVS base transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
