# frozen_string_literal: true

module Yosina
  module Transliterators
    # Hiragana/katakana composition transliterator
    module HiraKataComposition
      # Combining mark mappings for hiragana and katakana
      COMBINING_MARKS = {
        # Combining voiced sound mark (゙) U+3099
        "\u3099" => {
          # Hiragana voiceless → voiced
          'か' => 'が', 'き' => 'ぎ', 'く' => 'ぐ', 'け' => 'げ', 'こ' => 'ご',
          'さ' => 'ざ', 'し' => 'じ', 'す' => 'ず', 'せ' => 'ぜ', 'そ' => 'ぞ',
          'た' => 'だ', 'ち' => 'ぢ', 'つ' => 'づ', 'て' => 'で', 'と' => 'ど',
          'は' => 'ば', 'ひ' => 'び', 'ふ' => 'ぶ', 'へ' => 'べ', 'ほ' => 'ぼ',
          'う' => 'ゔ',
          # Katakana voiceless → voiced
          'カ' => 'ガ', 'キ' => 'ギ', 'ク' => 'グ', 'ケ' => 'ゲ', 'コ' => 'ゴ',
          'サ' => 'ザ', 'シ' => 'ジ', 'ス' => 'ズ', 'セ' => 'ゼ', 'ソ' => 'ゾ',
          'タ' => 'ダ', 'チ' => 'ヂ', 'ツ' => 'ヅ', 'テ' => 'デ', 'ト' => 'ド',
          'ハ' => 'バ', 'ヒ' => 'ビ', 'フ' => 'ブ', 'ヘ' => 'ベ', 'ホ' => 'ボ',
          'ウ' => 'ヴ',
          # Special katakana combinations
          'ワ' => 'ヷ', 'ヰ' => 'ヸ', 'ヱ' => 'ヹ', 'ヲ' => 'ヺ'
        }.freeze,

        # Combining semi-voiced sound mark (゚) U+309A
        "\u309A" => {
          # Hiragana h-series → p-series
          'は' => 'ぱ', 'ひ' => 'ぴ', 'ふ' => 'ぷ', 'へ' => 'ぺ', 'ほ' => 'ぽ',
          # Katakana h-series → p-series
          'ハ' => 'パ', 'ヒ' => 'ピ', 'フ' => 'プ', 'ヘ' => 'ペ', 'ホ' => 'ポ'
        }.freeze
      }.freeze

      # Non-combining mark mappings (゛ and ゜)
      NON_COMBINING_MARKS = {
        # Non-combining voiced sound mark (゛) U+309B
        "\u309B" => COMBINING_MARKS["\u3099"],
        # Non-combining semi-voiced sound mark (゜) U+309C
        "\u309C" => COMBINING_MARKS["\u309A"]
      }.freeze

      # Transliterator for hiragana/katakana composition
      class Transliterator < Yosina::BaseTransliterator
        attr_reader :compose_non_combining_marks

        # Initialize the transliterator with options
        #
        # @param options [Hash] Configuration options
        # @option options [Boolean] :compose_non_combining_marks Whether to compose non-combining
        #     marks (゛ and ゜) too. Defaults to false.
        def initialize(options = {})
          super()
          @compose_non_combining_marks = options[:compose_non_combining_marks] || false
        end

        # Combine decomposed hiragana and katakana characters with their marks
        #
        # @param input_chars [Array<Char>] The characters to transliterate
        # @return [Array<Char>] The transliterated characters
        def call(input_chars)
          offset = 0
          result = []
          i = 0

          while i < input_chars.length
            char = input_chars[i]

            # Look ahead for combining marks
            if i + 1 < input_chars.length
              next_char = input_chars[i + 1]

              # Check for combining marks
              mark_mapping = COMBINING_MARKS[next_char.c]
              if mark_mapping && mark_mapping[char.c]
                # Found a composable combination
                composed = mark_mapping[char.c]
                result << Char.new(c: composed, offset: offset, source: char)
                offset += composed.length
                i += 2 # Skip both characters
                next
              end

              # Check for non-combining marks if enabled
              if @compose_non_combining_marks
                mark_mapping = NON_COMBINING_MARKS[next_char.c]
                if mark_mapping && mark_mapping[char.c]
                  # Found a composable combination
                  composed = mark_mapping[char.c]
                  result << Char.new(c: composed, offset: offset, source: char)
                  offset += composed.length
                  i += 2 # Skip both characters
                  next
                end
              end
            end

            # No composition possible, keep original character
            result << Char.new(c: char.c, offset: offset, source: char.source)
            offset += char.c.length
            i += 1
          end

          result
        end
      end

      # Factory method to create a hiragana/katakana composition transliterator
      #
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new composition transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
