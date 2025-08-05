# frozen_string_literal: true

module Yosina
  module Transliterators
    # Handle prolonged sound marks transliterator
    module ProlongedSoundMarks
      # Hyphen-like characters that can be converted to prolonged sound marks
      HYPHEN_LIKE_CHARS = [
        "\u002d",  # HYPHEN-MINUS
        "\u2010",  # HYPHEN
        "\u2014",  # EM DASH
        "\u2015",  # HORIZONTAL BAR
        "\u2212",  # MINUS SIGN
        "\uff0d",  # FULLWIDTH HYPHEN-MINUS
        "\uff70",  # HALFWIDTH KATAKANA-HIRAGANA PROLONGED SOUND MARK (already converted)
        "\u30fc"   # KATAKANA-HIRAGANA PROLONGED SOUND MARK (already converted)
      ].freeze

      # Fullwidth prolonged sound mark
      FULLWIDTH_PROLONGED_MARK = "\u30fc" # ー

      # Halfwidth prolonged sound mark
      HALFWIDTH_PROLONGED_MARK = "\uff70" # ｰ

      # Hatsuon characters (ん/ン/ﾝ)
      HATSUON_CHARS = %w[ん ン ﾝ].freeze

      # Sokuon characters (っ/ッ/ｯ)
      SOKUON_CHARS = %w[っ ッ ｯ].freeze

      # Characters that can be prolonged by default:
      # - All hiragana characters (U+3041-U+309C, U+309F) except hatsuon/sokuon
      # - All katakana characters (U+30A1-U+30FA, U+30FD-U+30FF) except hatsuon/sokuon
      # - All halfwidth katakana characters (U+FF66-U+FF6F, U+FF71-U+FF9F) except hatsuon/sokuon
      # - Prolonged sound marks themselves (ー, ｰ)
      # This matches the behavior in other language implementations where all
      # Japanese characters are considered "vowel-ended" and thus prolongable
      def self.default_prolongable_chars
        chars = []

        # Hiragana range (U+3041-U+309C, U+309F)
        (0x3041..0x309C).each { |cp| chars << cp.chr('UTF-8') }
        chars << 0x309F.chr('UTF-8')

        # Katakana range (U+30A1-U+30FA, U+30FD-U+30FF)
        (0x30A1..0x30FA).each { |cp| chars << cp.chr('UTF-8') }
        (0x30FD..0x30FF).each { |cp| chars << cp.chr('UTF-8') }

        # Halfwidth katakana range (U+FF66-U+FF6F, U+FF71-U+FF9F)
        (0xFF66..0xFF6F).each { |cp| chars << cp.chr('UTF-8') }
        (0xFF71..0xFF9F).each { |cp| chars << cp.chr('UTF-8') }

        # Add prolonged sound marks explicitly
        chars << FULLWIDTH_PROLONGED_MARK  # ー
        chars << HALFWIDTH_PROLONGED_MARK  # ｰ

        # Remove special characters (hatsuon, sokuon) as they're handled separately
        chars - HATSUON_CHARS - SOKUON_CHARS
      end

      # Cache the result since it's expensive to compute each time
      DEFAULT_PROLONGABLE_CHARS = default_prolongable_chars.freeze

      # Check if character is halfwidth Japanese
      def self.halfwidth_japanese?(char)
        # Halfwidth katakana range U+FF65-U+FF9F
        char_code = char.ord
        char_code >= 0xFF65 && char_code <= 0xFF9F
      end

      # Check if character is fullwidth Japanese
      def self.fullwidth_japanese?(char)
        char_code = char.ord
        # Hiragana: U+3040-U+309F
        # Katakana: U+30A0-U+30FF
        (char_code >= 0x3040 && char_code <= 0x309F) ||
          (char_code >= 0x30A0 && char_code <= 0x30FF)
      end

      # Check if character is alphanumeric
      def self.alphanumeric?(char)
        char.match?(/[a-zA-Z0-9]/)
      end

      # Check if character is fullwidth alphanumeric
      def self.fullwidth_alphanumeric?(char)
        char_code = char.ord
        # Fullwidth ASCII: U+FF00-U+FF5E
        char_code >= 0xFF00 && char_code <= 0xFF5E
      end

      # Transliterator for prolonged sound marks
      class Transliterator < Yosina::BaseTransliterator
        attr_reader :skip_already_transliterated_chars, :allow_prolonged_hatsuon,
                    :allow_prolonged_sokuon, :replace_prolonged_marks_following_alnums

        # Initialize the transliterator with options
        #
        # @param options [Hash] Configuration options
        # @option options [Boolean] :skip_already_transliterated_chars Skip chars that were already processed.
        #     Default: false.
        # @option options [Boolean] :allow_prolonged_hatsuon Allow prolonging ん/ン/ﾝ.
        #     Default: false.
        # @option options [Boolean] :allow_prolonged_sokuon Allow prolonging っ/ッ/ｯ.
        #     Default: false.
        # @option options [Boolean] :replace_prolonged_marks_following_alnums Replace prolonged marks after alphanum
        #    with hyphens. Default: false.
        def initialize(options = {})
          super()
          @skip_already_transliterated_chars = options.fetch(:skip_already_transliterated_chars, false)
          @allow_prolonged_hatsuon = options.fetch(:allow_prolonged_hatsuon, false)
          @allow_prolonged_sokuon = options.fetch(:allow_prolonged_sokuon, false)
          @replace_prolonged_marks_following_alnums = options.fetch(:replace_prolonged_marks_following_alnums, false)
        end

        # Convert hyphen-like characters to appropriate prolonged sound marks
        #
        # @param input_chars [Array<Char>] The characters to transliterate
        # @return [Array<Char>] The transliterated characters
        def call(input_chars)
          offset = 0
          result = []
          i = 0

          while i < input_chars.length
            char = input_chars[i]

            # Skip if we should skip already transliterated chars and this char was processed
            if @skip_already_transliterated_chars && char.source
              result << Char.new(c: char.c, offset: offset, source: char.source)
              offset += char.c.length
              i += 1
              next
            end

            # Check if current character is a hyphen-like character
            if HYPHEN_LIKE_CHARS.include?(char.c)
              replacement = get_prolonged_mark_replacement(result.last)

              if replacement
                result << Char.new(c: replacement, offset: offset, source: char)
                offset += replacement.length
              else
                # No replacement, keep original
                result << Char.new(c: char.c, offset: offset, source: char.source)
                offset += char.c.length
              end
            else
              # Not a hyphen-like character, keep as is
              result << Char.new(c: char.c, offset: offset, source: char.source)
              offset += char.c.length
            end

            i += 1
          end

          result
        end

        private

        # Get replacement for hyphen-like character based on context
        #
        # @param prev_char [Char, nil] The previous character for context
        # @return [String, nil] The replacement character or nil if no replacement
        def get_prolonged_mark_replacement(prev_char)
          # If no previous character, can't determine context
          return nil unless prev_char

          prev_char_str = prev_char.c

          # Check if previous character is prolongable
          if prolongable_char?(prev_char_str)
            # Determine appropriate prolonged mark based on character width
            if ProlongedSoundMarks.halfwidth_japanese?(prev_char_str)
              return HALFWIDTH_PROLONGED_MARK
            elsif ProlongedSoundMarks.fullwidth_japanese?(prev_char_str)
              return FULLWIDTH_PROLONGED_MARK
            end
          end

          # Handle alphanumeric replacement option
          if @replace_prolonged_marks_following_alnums
            if ProlongedSoundMarks.alphanumeric?(prev_char_str)
              return "\u002d"  # Regular hyphen
            elsif ProlongedSoundMarks.fullwidth_alphanumeric?(prev_char_str)
              return "\uff0d"  # Fullwidth hyphen
            end
          end

          # No replacement appropriate
          nil
        end

        # Check if a character can be prolonged
        #
        # @param char [String] The character to check
        # @return [Boolean] True if the character can be prolonged
        def prolongable_char?(char)
          # Default prolongable characters
          return true if DEFAULT_PROLONGABLE_CHARS.include?(char)

          # Hatsuon (if allowed)
          return true if @allow_prolonged_hatsuon && HATSUON_CHARS.include?(char)

          # Sokuon (if allowed)
          return true if @allow_prolonged_sokuon && SOKUON_CHARS.include?(char)

          false
        end
      end

      # Factory method to create a prolonged sound marks transliterator
      #
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new prolonged sound marks transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
