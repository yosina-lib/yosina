# frozen_string_literal: true

module Yosina
  module Transliterators
    # Convert historical hiragana/katakana characters to their modern equivalents
    module HistoricalHirakatas
      # Historical hiragana mappings: source => { simple:, decompose: }
      HISTORICAL_HIRAGANA_MAPPINGS = {
        "\u{3090}" => { simple: "\u{3044}", decompose: "\u{3046}\u{3043}" }, # ゐ → い / うぃ
        "\u{3091}" => { simple: "\u{3048}", decompose: "\u{3046}\u{3047}" }  # ゑ → え / うぇ
      }.freeze

      # Historical katakana mappings: source => { simple:, decompose: }
      HISTORICAL_KATAKANA_MAPPINGS = {
        "\u{30F0}" => { simple: "\u{30A4}", decompose: "\u{30A6}\u{30A3}" }, # ヰ → イ / ウィ
        "\u{30F1}" => { simple: "\u{30A8}", decompose: "\u{30A6}\u{30A7}" }  # ヱ → エ / ウェ
      }.freeze

      # Voiced historical katakana mappings: source => small vowel suffix
      VOICED_HISTORICAL_KANA_MAPPINGS = {
        "\u{30F7}" => "\u{30A1}", # ヷ → ァ
        "\u{30F8}" => "\u{30A3}", # ヸ → ィ
        "\u{30F9}" => "\u{30A7}", # ヹ → ェ
        "\u{30FA}" => "\u{30A9}"  # ヺ → ォ
      }.freeze

      VOICED_HISTORICAL_KANA_DECOMPOSED_MAPPINGS = {
        "\u{30EF}" => "\u{30A1}", # ヷ → ァ
        "\u{30F0}" => "\u{30A3}", # ヸ → ィ
        "\u{30F1}" => "\u{30A7}", # ヹ → ェ
        "\u{30F2}" => "\u{30A9}"  # ヺ → ォ
      }.freeze

      COMBINING_DAKUTEN = "\u{3099}"
      VU = "\u{30F4}"
      U = "\u{30A6}"

      # Transliterator for historical hiragana/katakana conversion
      class Transliterator < Yosina::BaseTransliterator
        # Initialize the transliterator with options
        #
        # @param options [Hash] Configuration options
        # @option options [String] :hiraganas "simple" (default), "decompose", or "skip"
        # @option options [String] :katakanas "simple" (default), "decompose", or "skip"
        # @option options [String] :voiced_katakanas "decompose" or "skip" (default)
        def initialize(options = {})
          super()
          @hiraganas = (options[:hiraganas] || :simple).to_sym
          @katakanas = (options[:katakanas] || :simple).to_sym
          @voiced_katakanas = (options[:voiced_katakanas] || :skip).to_sym
        end

        # Convert historical hiragana/katakana characters to modern equivalents
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          Chars.enum do |y|
            offset = 0
            pending = nil
            input_chars.each do |char|
              if char.sentinel?
                offset = emit_char(y, pending, offset) if pending
                pending = nil
                y << char
                break
              end

              if pending.nil?
                pending = char
                next
              end

              if char.c == COMBINING_DAKUTEN
                # Check if pending char could be a decomposed voiced base
                decomposed = VOICED_HISTORICAL_KANA_DECOMPOSED_MAPPINGS[pending.c]
                if @voiced_katakanas == :skip || decomposed.nil?
                  y << pending.with_offset(offset)
                  offset += pending.c.length
                  pending = char
                  next
                end
                y << Char.new(c: U, offset: offset, source: pending)
                offset += U.length
                y << char.with_offset(offset)
                offset += char.c.length
                y << Char.new(c: decomposed, offset: offset, source: pending)
                offset += decomposed.length
                pending = nil
                next
              end

              offset = emit_char(y, pending, offset)
              pending = char
            end
            # Flush any remaining pending char
            emit_char(y, pending, offset) if pending
          end
        end

        private

        # Emit a single char through the normal mapping logic
        #
        # @param y [Enumerator::Yielder] The yielder
        # @param char [Char] The character to emit
        # @param offset [Integer] The current offset
        # @return [Integer] The new offset after emitting
        # rubocop:disable Naming/MethodParameterName
        def emit_char(y, char, offset)
          # Historical hiragana
          hira_mapping = HISTORICAL_HIRAGANA_MAPPINGS[char.c]
          if hira_mapping && @hiraganas != :skip
            replacement = hira_mapping[@hiraganas]
            y << Char.new(c: replacement, offset: offset, source: char)
            return offset + replacement.length
          end

          # Historical katakana
          kata_mapping = HISTORICAL_KATAKANA_MAPPINGS[char.c]
          if kata_mapping && @katakanas != :skip
            replacement = kata_mapping[@katakanas]
            y << Char.new(c: replacement, offset: offset, source: char)
            return offset + replacement.length
          end

          # Voiced historical katakana
          if @voiced_katakanas == :decompose
            decomposed = VOICED_HISTORICAL_KANA_MAPPINGS[char.c]
            if decomposed
              y << Char.new(c: VU, offset: offset, source: char)
              offset += VU.length
              y << Char.new(c: decomposed, offset: offset, source: char)
              return offset + decomposed.length
            end
          end

          y << char.with_offset(offset)
          offset + char.c.length
        end
      end
      # rubocop:enable Naming/MethodParameterName

      # Factory method to create a historical hirakatas transliterator
      #
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new historical hirakatas transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
