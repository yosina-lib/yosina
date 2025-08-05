# frozen_string_literal: true

module Yosina
  module Transliterators
    # Handle Japanese iteration marks transliterator
    module JapaneseIterationMarks
      # Iteration mark characters
      HIRAGANA_ITERATION_MARK = "\u{309d}" # ゝ
      HIRAGANA_VOICED_ITERATION_MARK = "\u{309e}" # ゞ
      VERTICAL_HIRAGANA_ITERATION_MARK = "\u{3031}" # 〱
      VERTICAL_HIRAGANA_VOICED_ITERATION_MARK = "\u{3032}" # 〲
      KATAKANA_ITERATION_MARK = "\u{30fd}" # ヽ
      KATAKANA_VOICED_ITERATION_MARK = "\u{30fe}" # ヾ
      VERTICAL_KATAKANA_ITERATION_MARK = "\u{3033}" # 〳
      VERTICAL_KATAKANA_VOICED_ITERATION_MARK = "\u{3034}" # 〴
      KANJI_ITERATION_MARK = "\u{3005}" # 々

      # Mix-in for character type checks
      module CharType
        # Check if character is hiragana (excluding small forms and special marks)
        def hiragana?(char_code)
          char_code >= 0x3041 && char_code <= 0x3096
        end

        # Check if character is katakana (including halfwidth)
        def katakana?(char_code)
          (char_code >= 0x30a1 && char_code <= 0x30fa) ||
            (char_code >= 0xff66 && char_code <= 0xff9f)
        end

        # Check if character is kanji
        def kanji?(char_code)
          # CJK Unified Ideographs (common kanji ranges)
          (char_code >= 0x4e00 && char_code <= 0x9fff) ||
            (char_code >= 0x3400 && char_code <= 0x4dbf) ||
            (char_code >= 0x20000 && char_code <= 0x2a6df) ||
            (char_code >= 0x2a700 && char_code <= 0x2b73f) ||
            (char_code >= 0x2b740 && char_code <= 0x2b81f) ||
            (char_code >= 0x2b820 && char_code <= 0x2ceaf) ||
            (char_code >= 0x2ceb0 && char_code <= 0x2ebef) ||
            (char_code >= 0x30000 && char_code <= 0x3134f)
        end

        # Check if character is hatsuon (ん/ン)
        def hatsuon?(char_code)
          [0x3093, 0x30f3, 0xff9d].include?(char_code)
        end

        # Check if character is sokuon (っ/ッ)
        def sokuon?(char_code)
          [0x3063, 0x30c3, 0xff6f].include?(char_code)
        end

        # Check if character is an iteration mark
        def iteration_mark?(char)
          [
            HIRAGANA_ITERATION_MARK,
            HIRAGANA_VOICED_ITERATION_MARK,
            VERTICAL_HIRAGANA_ITERATION_MARK,
            VERTICAL_HIRAGANA_VOICED_ITERATION_MARK,
            KATAKANA_ITERATION_MARK,
            KATAKANA_VOICED_ITERATION_MARK,
            VERTICAL_KATAKANA_ITERATION_MARK,
            VERTICAL_KATAKANA_VOICED_ITERATION_MARK,
            KANJI_ITERATION_MARK
          ].include?(char)
        end

        # Check if character is voiced (has dakuten)
        def voiced?(char)
          VOICED_CHARS.include?(char)
        end

        # Check if character is semi-voiced (has handakuten)
        def semi_voiced?(char)
          # Hiragana semi-voiced
          %w[ぱ ぴ ぷ ぺ ぽ].include?(char) ||
            # Katakana semi-voiced
            %w[パ ピ プ ペ ポ].include?(char)
        end
      end

      # Voicing mappings for hiragana
      HIRAGANA_VOICING = {
        'か' => 'が', 'き' => 'ぎ', 'く' => 'ぐ', 'け' => 'げ', 'こ' => 'ご',
        'さ' => 'ざ', 'し' => 'じ', 'す' => 'ず', 'せ' => 'ぜ', 'そ' => 'ぞ',
        'た' => 'だ', 'ち' => 'ぢ', 'つ' => 'づ', 'て' => 'で', 'と' => 'ど',
        'は' => 'ば', 'ひ' => 'び', 'ふ' => 'ぶ', 'へ' => 'べ', 'ほ' => 'ぼ'
      }.freeze

      # Voicing mappings for katakana
      KATAKANA_VOICING = {
        'カ' => 'ガ', 'キ' => 'ギ', 'ク' => 'グ', 'ケ' => 'ゲ', 'コ' => 'ゴ',
        'サ' => 'ザ', 'シ' => 'ジ', 'ス' => 'ズ', 'セ' => 'ゼ', 'ソ' => 'ゾ',
        'タ' => 'ダ', 'チ' => 'ヂ', 'ツ' => 'ヅ', 'テ' => 'デ', 'ト' => 'ド',
        'ハ' => 'バ', 'ヒ' => 'ビ', 'フ' => 'ブ', 'ヘ' => 'ベ', 'ホ' => 'ボ',
        'ウ' => 'ヴ',
        # Halfwidth katakana
        'ｶ' => 'ｶﾞ', 'ｷ' => 'ｷﾞ', 'ｸ' => 'ｸﾞ', 'ｹ' => 'ｹﾞ', 'ｺ' => 'ｺﾞ',
        'ｻ' => 'ｻﾞ', 'ｼ' => 'ｼﾞ', 'ｽ' => 'ｽﾞ', 'ｾ' => 'ｾﾞ', 'ｿ' => 'ｿﾞ',
        'ﾀ' => 'ﾀﾞ', 'ﾁ' => 'ﾁﾞ', 'ﾂ' => 'ﾂﾞ', 'ﾃ' => 'ﾃﾞ', 'ﾄ' => 'ﾄﾞ',
        'ﾊ' => 'ﾊﾞ', 'ﾋ' => 'ﾋﾞ', 'ﾌ' => 'ﾌﾞ', 'ﾍ' => 'ﾍﾞ', 'ﾎ' => 'ﾎﾞ',
        'ｳ' => 'ｳﾞ'
      }.freeze

      # Derive voiced characters from voicing mappings
      VOICED_CHARS = (HIRAGANA_VOICING.values + KATAKANA_VOICING.values).freeze

      # Reverse voicing mappings (voiced to unvoiced)
      HIRAGANA_UNVOICING = HIRAGANA_VOICING.invert.freeze
      KATAKANA_UNVOICING = KATAKANA_VOICING.invert.freeze

      # Transliterator for Japanese iteration marks
      class Transliterator < Yosina::BaseTransliterator
        include CharType

        # Initialize the transliterator with options
        #
        # @param options [Hash] Configuration options (currently unused but kept for consistency)
        def initialize(_options = {})
          super()
        end

        # Replace iteration marks with appropriate repeated characters
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          offset = 0
          prev_char_info = nil
          prev_was_iteration_mark = false

          Chars.enum do |y|
            input_chars.each do |char|
              # Skip empty/sentinel characters
              if char.c.empty?
                y << char
                next
              end

              current_char = char.c

              if iteration_mark?(current_char)
                # Check if previous character was also an iteration mark
                if prev_was_iteration_mark
                  # Don't replace consecutive iteration marks
                  y << char.with_offset(offset)
                  offset += char.c.length
                  prev_was_iteration_mark = true
                  next
                end

                # We have an iteration mark, check if we can replace it
                replacement = nil
                if prev_char_info
                  case current_char
                  when HIRAGANA_ITERATION_MARK, VERTICAL_HIRAGANA_ITERATION_MARK
                    # Repeat previous hiragana if valid
                    if prev_char_info[:type] == :hiragana
                      replacement = prev_char_info[:char]
                    elsif prev_char_info[:type] == :hiragana_voiced
                      # Voiced character with unvoiced mark: unvoice it
                      replacement = HIRAGANA_UNVOICING[prev_char_info[:char]]
                    end
                  when HIRAGANA_VOICED_ITERATION_MARK, VERTICAL_HIRAGANA_VOICED_ITERATION_MARK
                    # Repeat previous hiragana with voicing if possible
                    if prev_char_info[:type] == :hiragana
                      replacement = HIRAGANA_VOICING[prev_char_info[:char]]
                    elsif prev_char_info[:type] == :hiragana_voiced
                      # Voiced character with voiced mark: keep it voiced
                      replacement = prev_char_info[:char]
                    end
                  when KATAKANA_ITERATION_MARK, VERTICAL_KATAKANA_ITERATION_MARK
                    # Repeat previous katakana if valid
                    if prev_char_info[:type] == :katakana
                      replacement = prev_char_info[:char]
                    elsif prev_char_info[:type] == :katakana_voiced
                      # Voiced character with unvoiced mark: unvoice it
                      replacement = KATAKANA_UNVOICING[prev_char_info[:char]]
                    end
                  when KATAKANA_VOICED_ITERATION_MARK, VERTICAL_KATAKANA_VOICED_ITERATION_MARK
                    # Repeat previous katakana with voicing if possible
                    if prev_char_info[:type] == :katakana
                      replacement = KATAKANA_VOICING[prev_char_info[:char]]
                    elsif prev_char_info[:type] == :katakana_voiced
                      # Voiced character with voiced mark: keep it voiced
                      replacement = prev_char_info[:char]
                    end
                  when KANJI_ITERATION_MARK
                    # Repeat previous kanji
                    replacement = prev_char_info[:char] if prev_char_info[:type] == :kanji
                  end
                end

                if replacement
                  # Create a new character with the replacement
                  y << Char.new(c: replacement, offset: offset, source: char)
                  offset += replacement.length
                  # Don't update prev_char_info - keep the original one
                  # This ensures consecutive iteration marks work correctly
                else
                  # Couldn't replace the iteration mark
                  y << char.with_offset(offset)
                  offset += char.c.length
                end
                prev_was_iteration_mark = true
                next
              else
                # Not an iteration mark
                y << char.with_offset(offset)
                offset += char.c.length

                # Update previous character info
                char_code = current_char.ord
                char_type = get_char_type(current_char, char_code)

                # Only update prev_char_info if it's a repeatable character
                prev_char_info = ({ char: current_char, type: char_type } if char_type && char_type != :other)

                prev_was_iteration_mark = false
              end
            end
          end
        end

        private

        # Get the character type
        def get_char_type(char, char_code)
          # Check special cases first
          return :other if hatsuon?(char_code) || sokuon?(char_code)
          return :other if semi_voiced?(char)

          # Check if it's a voiced character
          if voiced?(char)
            if hiragana?(char_code)
              return :hiragana_voiced
            elsif katakana?(char_code)
              return :katakana_voiced
            end
          end

          # Check character type
          return :hiragana if hiragana?(char_code)
          return :katakana if katakana?(char_code)
          return :kanji if kanji?(char_code)

          :other
        end
      end

      # Factory method to create a Japanese iteration marks transliterator
      #
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new Japanese iteration marks transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
