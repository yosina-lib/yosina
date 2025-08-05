# frozen_string_literal: true

module Yosina
  module Transliterators
    # Handle prolonged sound marks transliterator
    module ProlongedSoundMarks
      # Mix-in for character type checks
      module CharType
        # Hyphen-like characters that can be converted to prolonged sound marks
        HYPHEN_LIKE_CHARS = [
          0x002d,  # HYPHEN-MINUS
          0x2010,  # HYPHEN
          0x2014,  # EM DASH
          0x2015,  # HORIZONTAL BAR
          0x2212,  # MINUS SIGN
          0xff0d,  # FULLWIDTH HYPHEN-MINUS
          0xff70,  # HALFWIDTH KATAKANA-HIRAGANA PROLONGED SOUND MARK (already converted)
          0x30fc   # KATAKANA-HIRAGANA PROLONGED SOUND MARK (already converted)
        ].freeze

        # Check if character is halfwidth Japanese
        def halfwidth?(char_code)
          halfwidth_alphanumeric?(char_code) ||
            (char_code >= 0xff66 && char_code <= 0xff6f) ||
            (char_code >= 0xff70 && char_code <= 0xff9f)
        end

        def hiragana?(char_code)
          (char_code >= 0x3041 && char_code <= 0x309c &&
            char_code != 0x3063 && char_code != 0x3093) ||
            char_code == 0x309f
        end

        def katakana?(char_code)
          (char_code >= 0x30a1 && char_code <= 0x30fa && char_code != 0x30c3 && char_code != 0x30f3) ||
            (char_code >= 0x30fd && char_code <= 0x30ff) ||
            (char_code >= 0xff70 && char_code <= 0xff9f && char_code != 0xff6f && char_code != 0xff9d)
        end

        def halfwidth_alphanumeric?(char_code)
          (char_code >= 0x30 && char_code <= 0x39) ||
            (char_code >= 0x41 && char_code <= 0x5A) ||
            (char_code >= 0x61 && char_code <= 0x7A)
        end

        def fullwidth_alphanumeric?(char_code)
          (char_code >= 0xff10 && char_code <= 0xff19) ||
            (char_code >= 0xff21 && char_code <= 0xff3a) ||
            (char_code >= 0xff41 && char_code <= 0xff5a)
        end

        # Check if character is fullwidth Japanese
        def fullwidth?(char_code)
          char_code == 0x30fc || hiragana?(char_code) || katakana?(char_code) || fullwidth_alphanumeric?(char_code)
        end

        # Check if character is alphanumeric
        def alphanumeric?(char_code)
          halfwidth_alphanumeric?(char_code) || fullwidth_alphanumeric?(char_code)
        end

        def hatsuon?(char_code)
          [0x3093, 0x30f3, 0xff9d].include?(char_code)
        end

        def sokuon?(char_code)
          [0x3063, 0x30c3, 0xff6f].include?(char_code)
        end

        def prolonged_sound_mark?(char_code)
          [0x30fc, 0xff70].include?(char_code)
        end

        def prolongable?(char_code)
          prolonged_sound_mark?(char_code) || hiragana?(char_code) || katakana?(char_code)
        end

        def hyphen_like?(char_code)
          HYPHEN_LIKE_CHARS.include?(char_code)
        end
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
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          offset = 0
          processed_char_in_lookahead = false
          lookahead_buf = []
          last_non_prolonged_char = nil

          Chars.enum do |y|
            input_chars.each do |char|
              unless lookahead_buf.empty?
                if !char.c.empty? && hyphen_like?(char.c.ord)
                  processed_char_in_lookahead = true unless char.source.nil?
                  lookahead_buf << char
                  next
                end
                prev_non_prolonged_char = last_non_prolonged_char
                last_non_prolonged_char = char

                if (prev_non_prolonged_char.nil? || alphanumeric?(prev_non_prolonged_char.c.ord)) && (
                  !@skip_already_transliterated_chars || !processed_char_in_lookahead
                )
                  halfwidth = halfwidth?(
                    prev_non_prolonged_char.nil? ? last_non_prolonged_char.c.ord : prev_non_prolonged_char.c.ord
                  )
                  replacement = halfwidth ? "\u002d" : "\uff0d"
                  lookahead_buf.each do |buffered_char|
                    y << Char.new(c: replacement, offset: offset, source: buffered_char)
                    offset += replacement.length
                  end
                else
                  lookahead_buf.each do |buffered_char|
                    y << buffered_char.with_offset(offset)
                    offset += buffered_char.c.length
                  end
                end

                lookahead_buf.clear
                y << char.with_offset(offset)
                offset += char.c.length
                last_non_prolonged_char = char
                processed_char_in_lookahead = false
                next
              end
              if !char.c.empty? && hyphen_like?(char.c.ord)
                should_procses = !@skip_already_transliterated_chars || !char.transliterated?
                if should_procses && !last_non_prolonged_char.nil?
                  if prolongable_char?(last_non_prolonged_char.c.ord)
                    replacement = halfwidth?(last_non_prolonged_char.c.ord) ? "\uff70" : "\u30fc"
                    y << Char.new(c: replacement, offset: offset, source: char)
                    offset += replacement.length
                    next
                  elsif @replace_prolonged_marks_following_alnums && alphanumeric?(last_non_prolonged_char.c.ord)
                    lookahead_buf << char
                    next
                  end
                end
              else
                last_non_prolonged_char = char
              end
              y << char.with_offset(offset)
              offset += char.c.length
            end
          end
        end

        private

        include CharType

        # Check if a character can be prolonged
        #
        # @param char [String] The character to check
        # @return [Boolean] True if the character can be prolonged
        def prolongable_char?(char_code)
          # Default prolongable characters
          return true if prolongable?(char_code)

          # Hatsuon (if allowed)
          return true if @allow_prolonged_hatsuon && hatsuon?(char_code)

          # Sokuon (if allowed)
          return true if @allow_prolonged_sokuon && sokuon?(char_code)

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
