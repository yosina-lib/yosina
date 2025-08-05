# frozen_string_literal: true

module Yosina
  module Transliterators
    # Hiragana/katakana composition transliterator
    module HiraKataComposition
      VOICED_SOUND_MARK_MAPPINGS = {
        # Hiragana voiceless → voiced
        'か' => 'が', 'き' => 'ぎ', 'く' => 'ぐ', 'け' => 'げ', 'こ' => 'ご',
        'さ' => 'ざ', 'し' => 'じ', 'す' => 'ず', 'せ' => 'ぜ', 'そ' => 'ぞ',
        'た' => 'だ', 'ち' => 'ぢ', 'つ' => 'づ', 'て' => 'で', 'と' => 'ど',
        'は' => 'ば', 'ひ' => 'び', 'ふ' => 'ぶ', 'へ' => 'べ', 'ほ' => 'ぼ',
        'う' => 'ゔ', 'ゝ' => 'ゞ',
        # Katakana voiceless → voiced
        'カ' => 'ガ', 'キ' => 'ギ', 'ク' => 'グ', 'ケ' => 'ゲ', 'コ' => 'ゴ',
        'サ' => 'ザ', 'シ' => 'ジ', 'ス' => 'ズ', 'セ' => 'ゼ', 'ソ' => 'ゾ',
        'タ' => 'ダ', 'チ' => 'ヂ', 'ツ' => 'ヅ', 'テ' => 'デ', 'ト' => 'ド',
        'ハ' => 'バ', 'ヒ' => 'ビ', 'フ' => 'ブ', 'ヘ' => 'ベ', 'ホ' => 'ボ',
        'ウ' => 'ヴ',
        # Special katakana combinations
        'ワ' => 'ヷ', 'ヰ' => 'ヸ', 'ヱ' => 'ヹ', 'ヲ' => 'ヺ', 'ヽ' => 'ヾ'
      }.freeze

      SEMI_VOICED_SOUND_MARK_MAPPINGS = {
        # Hiragana h-series → p-series
        'は' => 'ぱ', 'ひ' => 'ぴ', 'ふ' => 'ぷ', 'へ' => 'ぺ', 'ほ' => 'ぽ',
        # Katakana h-series → p-series
        'ハ' => 'パ', 'ヒ' => 'ピ', 'フ' => 'プ', 'ヘ' => 'ペ', 'ホ' => 'ポ'
      }.freeze

      # Combining mark mappings for hiragana and katakana
      COMBINING_MARKS = {
        "\u3099" => VOICED_SOUND_MARK_MAPPINGS,
        "\u309A" => SEMI_VOICED_SOUND_MARK_MAPPINGS
      }.freeze

      # Non-combining mark mappings
      NON_COMBINING_MARKS = {
        "\u3099" => VOICED_SOUND_MARK_MAPPINGS,
        "\u309A" => SEMI_VOICED_SOUND_MARK_MAPPINGS,
        "\u309B" => VOICED_SOUND_MARK_MAPPINGS,
        "\u309C" => SEMI_VOICED_SOUND_MARK_MAPPINGS
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
          @mappings = @compose_non_combining_marks ? NON_COMBINING_MARKS : COMBINING_MARKS
        end

        # Combine decomposed hiragana and katakana characters with their marks
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          e = input_chars.each
          offset = 0

          Chars.enum do |y|
            begin
              prev = e.next
            rescue StopIteration
              break
            end

            if prev.sentinel?
              y << prev
              break
            end

            loop do
              begin
                char = e.next
              rescue StopIteration
                break
              end

              if prev
                # Check for combining marks
                if (mark_mapping = @mappings[char.c]) && (composed = mark_mapping[prev.c])
                  # Found a composable combination
                  y << Char.new(c: composed, offset: offset, source: char)
                  offset += composed.length
                  prev = nil
                  next
                end

                # No composition possible, keep original character
                y << prev.with_offset(offset)
                offset += prev.c.length
              end
              prev = char
            end
            if prev
              y << prev.with_offset(offset)
              offset += prev.c.length
            end
          end
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
