# frozen_string_literal: true

require_relative '../transliterator'
require_relative 'hira_kata_table'

module Yosina
  module Transliterators
    # JIS X 0201 and alike transliterator for fullwidth/halfwidth conversion
    module Jisx0201AndAlike
      include HiraKataTable

      # GL area mapping table (fullwidth to halfwidth)
      JISX0201_GL_TABLE = [
        ["\u3000", "\u0020"], # Ideographic space to space
        ["\uff01", "\u0021"], # ！ to !
        ["\uff02", "\u0022"], # ＂ to "
        ["\uff03", "\u0023"], # ＃ to #
        ["\uff04", "\u0024"], # ＄ to $
        ["\uff05", "\u0025"], # ％ to %
        ["\uff06", "\u0026"], # ＆ to &
        ["\uff07", "\u0027"], # ＇ to '
        ["\uff08", "\u0028"], # （ to (
        ["\uff09", "\u0029"], # ） to )
        ["\uff0a", "\u002a"], # ＊ to *
        ["\uff0b", "\u002b"], # ＋ to +
        ["\uff0c", "\u002c"], # ， to ,
        ["\uff0d", "\u002d"], # － to -
        ["\uff0e", "\u002e"], # ． to .
        ["\uff0f", "\u002f"], # ／ to /
        ["\uff10", "\u0030"], # ０ to 0
        ["\uff11", "\u0031"], # １ to 1
        ["\uff12", "\u0032"], # ２ to 2
        ["\uff13", "\u0033"], # ３ to 3
        ["\uff14", "\u0034"], # ４ to 4
        ["\uff15", "\u0035"], # ５ to 5
        ["\uff16", "\u0036"], # ６ to 6
        ["\uff17", "\u0037"], # ７ to 7
        ["\uff18", "\u0038"], # ８ to 8
        ["\uff19", "\u0039"], # ９ to 9
        ["\uff1a", "\u003a"], # ： to :
        ["\uff1b", "\u003b"], # ； to ;
        ["\uff1c", "\u003c"], # ＜ to <
        ["\uff1d", "\u003d"], # ＝ to =
        ["\uff1e", "\u003e"], # ＞ to >
        ["\uff1f", "\u003f"], # ？ to ?
        ["\uff20", "\u0040"], # ＠ to @
        ["\uff21", "\u0041"], # Ａ to A
        ["\uff22", "\u0042"], # Ｂ to B
        ["\uff23", "\u0043"], # Ｃ to C
        ["\uff24", "\u0044"], # Ｄ to D
        ["\uff25", "\u0045"], # Ｅ to E
        ["\uff26", "\u0046"], # Ｆ to F
        ["\uff27", "\u0047"], # Ｇ to G
        ["\uff28", "\u0048"], # Ｈ to H
        ["\uff29", "\u0049"], # Ｉ to I
        ["\uff2a", "\u004a"], # Ｊ to J
        ["\uff2b", "\u004b"], # Ｋ to K
        ["\uff2c", "\u004c"], # Ｌ to L
        ["\uff2d", "\u004d"], # Ｍ to M
        ["\uff2e", "\u004e"], # Ｎ to N
        ["\uff2f", "\u004f"], # Ｏ to O
        ["\uff30", "\u0050"], # Ｐ to P
        ["\uff31", "\u0051"], # Ｑ to Q
        ["\uff32", "\u0052"], # Ｒ to R
        ["\uff33", "\u0053"], # Ｓ to S
        ["\uff34", "\u0054"], # Ｔ to T
        ["\uff35", "\u0055"], # Ｕ to U
        ["\uff36", "\u0056"], # Ｖ to V
        ["\uff37", "\u0057"], # Ｗ to W
        ["\uff38", "\u0058"], # Ｘ to X
        ["\uff39", "\u0059"], # Ｙ to Y
        ["\uff3a", "\u005a"], # Ｚ to Z
        ["\uff3b", "\u005b"], # ［ to [
        ["\uff3d", "\u005d"], # ］ to ]
        ["\uff3e", "\u005e"], # ＾ to ^
        ["\uff3f", "\u005f"], # ＿ to _
        ["\uff40", "\u0060"], # ｀ to `
        ["\uff41", "\u0061"], # ａ to a
        ["\uff42", "\u0062"], # ｂ to b
        ["\uff43", "\u0063"], # ｃ to c
        ["\uff44", "\u0064"], # ｄ to d
        ["\uff45", "\u0065"], # ｅ to e
        ["\uff46", "\u0066"], # ｆ to f
        ["\uff47", "\u0067"], # ｇ to g
        ["\uff48", "\u0068"], # ｈ to h
        ["\uff49", "\u0069"], # ｉ to i
        ["\uff4a", "\u006a"], # ｊ to j
        ["\uff4b", "\u006b"], # ｋ to k
        ["\uff4c", "\u006c"], # ｌ to l
        ["\uff4d", "\u006d"], # ｍ to m
        ["\uff4e", "\u006e"], # ｎ to n
        ["\uff4f", "\u006f"], # ｏ to o
        ["\uff50", "\u0070"], # ｐ to p
        ["\uff51", "\u0071"], # ｑ to q
        ["\uff52", "\u0072"], # ｒ to r
        ["\uff53", "\u0073"], # ｓ to s
        ["\uff54", "\u0074"], # ｔ to t
        ["\uff55", "\u0075"], # ｕ to u
        ["\uff56", "\u0076"], # ｖ to v
        ["\uff57", "\u0077"], # ｗ to w
        ["\uff58", "\u0078"], # ｘ to x
        ["\uff59", "\u0079"], # ｙ to y
        ["\uff5a", "\u007a"], # ｚ to z
        ["\uff5b", "\u007b"], # ｛ to {
        ["\uff5c", "\u007c"], # ｜ to |
        ["\uff5d", "\u007d"] # ｝ to }
      ].freeze

      # Special GL overrides
      JISX0201_GL_OVERRIDES = {
        u005c_as_yen_sign: [["\uffe5", "\u005c"]], # ￥ to \
        u005c_as_backslash: [["\uff3c", "\u005c"]], # ＼ to \
        u007e_as_fullwidth_tilde: [["\uff5e", "\u007e"]], # ～ to ~
        u007e_as_wave_dash: [["\u301c", "\u007e"]], # 〜 to ~
        u007e_as_overline: [["\u203e", "\u007e"]], # ‾ to ~
        u007e_as_fullwidth_macron: [["\uffe3", "\u007e"]], # ￣ to ~
        u00a5_as_yen_sign: [["\uffe5", "\u00a5"]] # ￥ to ¥
      }.freeze

      # Generate GR table from shared table
      def self.generate_gr_table
        result = [
          ["\u3002", "\uff61"], # 。 to ｡
          ["\u300c", "\uff62"], # 「 to ｢
          ["\u300d", "\uff63"], # 」 to ｣
          ["\u3001", "\uff64"], # 、 to ､
          ["\u30fb", "\uff65"], # ・ to ･
          ["\u30fc", "\uff70"], # ー to ｰ
          ["\u309b", "\uff9e"], # ゛ to ﾞ
          ["\u309c", "\uff9f"] # ゜to ﾟ
        ]
        # Add katakana mappings from main table
        HIRAGANA_KATAKANA_TABLE.each do |_, katakana, halfwidth|
          result << [katakana[0], halfwidth] if halfwidth
        end
        # Add small kana mappings
        HIRAGANA_KATAKANA_SMALL_TABLE.each do |_, katakana, halfwidth|
          result << [katakana, halfwidth] if halfwidth
        end
        result
      end

      # GR area mapping table (fullwidth to halfwidth)
      JISX0201_GR_TABLE = generate_gr_table.freeze

      # Special punctuations
      SPECIAL_PUNCTUATIONS_TABLE = [["\u30a0", "\u003d"]].freeze # ゠ to =

      # Generate voiced letters table from shared table
      def self.generate_voiced_letters_table
        result = []
        HIRAGANA_KATAKANA_TABLE.each do |_, katakana, halfwidth|
          next unless halfwidth

          result << [katakana[1], "#{halfwidth}\uff9e"] if katakana[1] # Has voiced form
          result << [katakana[2], "#{halfwidth}\uff9f"] if katakana[2] # Has semi-voiced form
        end
        result
      end

      # Voiced letters table
      VOICED_LETTERS_TABLE = generate_voiced_letters_table.freeze

      # Generate hiragana mappings from shared table
      def self.generate_hiragana_mappings
        result = []
        # Add main table hiragana mappings
        HIRAGANA_KATAKANA_TABLE.each do |hiragana, _, halfwidth|
          next unless hiragana[0] && halfwidth

          result << [hiragana[0], halfwidth]
          result << [hiragana[1], "#{halfwidth}\uff9e"] if hiragana[1] # Has voiced form
          result << [hiragana[2], "#{halfwidth}\uff9f"] if hiragana[2] # Has semi-voiced form
        end
        # Add small kana mappings
        HIRAGANA_KATAKANA_SMALL_TABLE.each do |hiragana, _, halfwidth|
          result << [hiragana, halfwidth] if halfwidth
        end
        result
      end

      # Hiragana mappings
      HIRAGANA_MAPPINGS = generate_hiragana_mappings.freeze

      # Transliterator for JIS X 0201 and alike
      class Transliterator < Yosina::BaseTransliterator
        attr_reader :fullwidth_to_halfwidth, :convert_gl, :convert_gr, :convert_unsafe_specials,
                    :convert_hiraganas, :combine_voiced_sound_marks,
                    :u005c_as_yen_sign, :u005c_as_backslash,
                    :u007e_as_fullwidth_tilde, :u007e_as_wave_dash,
                    :u007e_as_overline, :u007e_as_fullwidth_macron,
                    :u00a5_as_yen_sign

        # Initialize the transliterator with options
        #
        # @param options [Hash] Configuration options
        # @option options [Boolean] :fullwidth_to_halfwidth Convert fullwidth to halfwidth (default: true)
        # @option options [Boolean] :convert_gl Convert GL characters (default: true)
        # @option options [Boolean] :convert_gr Convert GR characters (default: true)
        # @option options [Boolean] :convert_unsafe_specials Convert unsafe special characters
        # @option options [Boolean] :convert_hiraganas Convert hiraganas (default: false)
        # @option options [Boolean] :combine_voiced_sound_marks Combine voiced sound marks (default: true)
        # @option options [Boolean] :u005c_as_yen_sign Treat backslash as yen sign
        # @option options [Boolean] :u005c_as_backslash Treat backslash verbatim
        # @option options [Boolean] :u007e_as_fullwidth_tilde Convert tilde to fullwidth tilde
        # @option options [Boolean] :u007e_as_wave_dash Convert tilde to wave dash
        # @option options [Boolean] :u007e_as_overline Convert tilde to overline
        # @option options [Boolean] :u007e_as_fullwidth_macron Convert tilde to fullwidth macron
        # @option options [Boolean] :u00a5_as_yen_sign Convert yen sign to backslash
        def initialize(options = {})
          super()
          @fullwidth_to_halfwidth = options.fetch(:fullwidth_to_halfwidth, true)
          @convert_gl = options.fetch(:convert_gl, true)
          @convert_gr = options.fetch(:convert_gr, true)
          @convert_hiraganas = options.fetch(:convert_hiraganas, false)
          @combine_voiced_sound_marks = options.fetch(:combine_voiced_sound_marks, true)

          # Set defaults based on direction
          if @fullwidth_to_halfwidth
            @convert_unsafe_specials = options.fetch(:convert_unsafe_specials, true)
            @u005c_as_yen_sign = options.fetch(:u005c_as_yen_sign) { !options.key?(:u00a5_as_yen_sign) }
            @u005c_as_backslash = options.fetch(:u005c_as_backslash, false)
            @u007e_as_fullwidth_tilde = options.fetch(:u007e_as_fullwidth_tilde, true)
            @u007e_as_wave_dash = options.fetch(:u007e_as_wave_dash, true)
            @u007e_as_overline = options.fetch(:u007e_as_overline, false)
            @u007e_as_fullwidth_macron = options.fetch(:u007e_as_fullwidth_macron, false)
            @u00a5_as_yen_sign = options.fetch(:u00a5_as_yen_sign, false)
          else
            @convert_unsafe_specials = options.fetch(:convert_unsafe_specials, false)
            @u005c_as_yen_sign = options.fetch(:u005c_as_yen_sign) { !options.key?(:u005c_as_backslash) }
            @u005c_as_backslash = options.fetch(:u005c_as_backslash, false)
            @u007e_as_fullwidth_tilde = options.fetch(:u007e_as_fullwidth_tilde) do
              !options.key?(:u007e_as_wave_dash) &&
                !options.key?(:u007e_as_overline) &&
                !options.key?(:u007e_as_fullwidth_macron)
            end
            @u007e_as_wave_dash = options.fetch(:u007e_as_wave_dash, false)
            @u007e_as_overline = options.fetch(:u007e_as_overline, false)
            @u007e_as_fullwidth_macron = options.fetch(:u007e_as_fullwidth_macron, false)
            @u00a5_as_yen_sign = options.fetch(:u00a5_as_yen_sign, true)
          end

          validate_options!
          build_mappings!
        end

        # Transliterate characters
        #
        # @param input_chars [Enumerable<Char>] The characters to transliterate
        # @return [Enumerable<Char>] The transliterated characters
        def call(input_chars)
          if @fullwidth_to_halfwidth
            convert_fullwidth_to_halfwidth(input_chars)
          else
            convert_halfwidth_to_fullwidth(input_chars)
          end
        end

        private

        def validate_options!
          if @fullwidth_to_halfwidth
            # For forward direction, only check this specific combination
            if @u005c_as_yen_sign && @u00a5_as_yen_sign
              raise ArgumentError,
                    'u005c_as_yen_sign and u00a5_as_yen_sign are mutually exclusive,' \
                    ' and cannot be set to true at the same time.'
            end
          else
            # For reverse direction, group overrides by their target character and validate
            # Build groups of options that map to the same character
            groups = {}
            JISX0201_GL_OVERRIDES.each do |key, pairs|
              next unless instance_variable_get("@#{key}")

              pairs.each do |hw|
                groups[hw] ||= []
                groups[hw] << key
              end
            end

            # Check if multiple options in the same group are set
            groups.each_value do |keys|
              next unless keys.size > 1

              names = keys.map(&:to_s)
              last = names.pop
              raise ArgumentError,
                    "#{names.join(', ')} and #{last} are mutually exclusive," \
                    'and cannot be set to true at the same time.'
            end
          end
        end

        def build_mappings!
          if @fullwidth_to_halfwidth
            build_forward_mappings!
          else
            build_reverse_mappings!
            build_voiced_reverse_mappings! if @combine_voiced_sound_marks && @convert_gr
          end
        end

        def build_forward_mappings!
          @fwd_mappings = {}

          if @convert_gl
            # Add basic GL mappings
            JISX0201_GL_TABLE.each { |fw, hw| @fwd_mappings[fw] = hw }

            # Add override mappings
            add_override_mappings(@fwd_mappings, false)

            # Add special punctuations if enabled
            SPECIAL_PUNCTUATIONS_TABLE.each { |fw, hw| @fwd_mappings[fw] = hw } if @convert_unsafe_specials
          end

          return unless @convert_gr

          # Add basic GR mappings
          JISX0201_GR_TABLE.each { |fw, hw| @fwd_mappings[fw] = hw }
          VOICED_LETTERS_TABLE.each { |fw, hw| @fwd_mappings[fw] = hw }

          # Add combining marks
          @fwd_mappings["\u3099"] = "\uff9e" # combining dakuten
          @fwd_mappings["\u309a"] = "\uff9f" # combining handakuten

          # Add hiragana mappings if enabled
          return unless @convert_hiraganas

          HIRAGANA_MAPPINGS.each do |fw, hw|
            @fwd_mappings[fw] = hw
          end
        end

        def build_reverse_mappings!
          @rev_mappings = {}

          if @convert_gl
            # Add basic GL reverse mappings
            JISX0201_GL_TABLE.each { |fw, hw| @rev_mappings[hw] = fw }

            # Add override reverse mappings
            add_override_mappings(@rev_mappings, true)

            # Add special punctuations if enabled
            SPECIAL_PUNCTUATIONS_TABLE.each { |fw, hw| @rev_mappings[hw] = fw } if @convert_unsafe_specials
          end

          return unless @convert_gr

          # Add basic GR reverse mappings
          JISX0201_GR_TABLE.each { |fw, hw| @rev_mappings[hw] = fw }
        end

        def build_voiced_reverse_mappings!
          @voiced_rev_mappings = {}
          VOICED_LETTERS_TABLE.each do |fw, hw|
            @voiced_rev_mappings[hw[0]] ||= {}
            @voiced_rev_mappings[hw[0]][hw[1]] = fw
          end
        end

        def add_override_mappings(mappings, reverse)
          JISX0201_GL_OVERRIDES.each do |key, pairs|
            next unless instance_variable_get("@#{key}")

            pairs.each do |fw, hw|
              if reverse
                mappings[hw] = fw
              else
                mappings[fw] = hw
              end
            end
          end
        end

        def convert_fullwidth_to_halfwidth(input_chars)
          offset = 0
          Chars.enum do |y|
            input_chars.each do |char|
              if (mapped = @fwd_mappings[char.c])
                mapped.each_char do |c|
                  y << Char.new(c: c, offset: offset, source: char)
                  offset += c.length
                end
              else
                y << char.with_offset(offset)
                offset += char.c.length
              end
            end
          end
        end

        def convert_halfwidth_to_fullwidth(input_chars)
          offset = 0
          pending = nil

          Chars.enum do |y|
            e = input_chars.each
            loop do
              if pending
                char = pending
                pending = nil
              else
                begin
                  char = e.next
                rescue StopIteration
                  break
                end
              end
              if char.sentinel?
                y << char.with_offset(offset)
                next
              end
              # Check if this character might start a combination
              if @voiced_rev_mappings && (inner = @voiced_rev_mappings[char.c])
                next_char = e.next
                if (combined = inner[next_char.c])
                  y << Char.new(c: combined, offset: offset, source: char)
                  offset += combined.length
                  next
                else
                  pending = next_char
                end
              end

              # Normal mapping
              mapped = @rev_mappings[char.c]
              if mapped
                y << Char.new(c: mapped, offset: offset, source: char)
                offset += mapped.length
              else
                y << char.with_offset(offset)
                offset += char.c.length
              end
            end
          end
        end
      end

      # Factory method to create a JIS X 0201 and alike transliterator
      #
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new JIS X 0201 and alike transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
