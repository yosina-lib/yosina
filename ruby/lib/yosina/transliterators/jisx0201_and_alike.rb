# frozen_string_literal: true

module Yosina
  module Transliterators
    # Handle JIS X 0201 and alike character conversions
    module JisX0201AndAlike
      # GL (Graphics Left) mappings - ASCII-like characters
      GL_MAPPINGS_FW_TO_HW = {
        '　' => ' ', # U+3000 → U+0020 (Ideographic space → space)
        '！' => '!',   '＂' => '"',   '＃' => '#',   '＄' => '$',   '％' => '%',
        '＆' => '&',   '＇' => "'",   '（' => '(',   '）' => ')',   '＊' => '*',
        '＋' => '+',   '，' => ',',   '－' => '-',   '．' => '.',   '／' => '/',
        '０' => '0',   '１' => '1',   '２' => '2',   '３' => '3',   '４' => '4',
        '５' => '5',   '６' => '6',   '７' => '7',   '８' => '8',   '９' => '9',
        '：' => ':',   '；' => ';',   '＜' => '<',   '＝' => '=',   '＞' => '>',
        '？' => '?',   '＠' => '@',
        'Ａ' => 'A',   'Ｂ' => 'B',   'Ｃ' => 'C',   'Ｄ' => 'D',   'Ｅ' => 'E',
        'Ｆ' => 'F',   'Ｇ' => 'G',   'Ｈ' => 'H',   'Ｉ' => 'I',   'Ｊ' => 'J',
        'Ｋ' => 'K',   'Ｌ' => 'L',   'Ｍ' => 'M',   'Ｎ' => 'N',   'Ｏ' => 'O',
        'Ｐ' => 'P',   'Ｑ' => 'Q',   'Ｒ' => 'R',   'Ｓ' => 'S',   'Ｔ' => 'T',
        'Ｕ' => 'U',   'Ｖ' => 'V',   'Ｗ' => 'W',   'Ｘ' => 'X',   'Ｙ' => 'Y',
        'Ｚ' => 'Z',
        '［' => '[', '＼' => '\\', '］' => ']', '＾' => '^', '＿' => '_',
        '｀' => '`',
        'ａ' => 'a',   'ｂ' => 'b',   'ｃ' => 'c',   'ｄ' => 'd',   'ｅ' => 'e',
        'ｆ' => 'f',   'ｇ' => 'g',   'ｈ' => 'h',   'ｉ' => 'i',   'ｊ' => 'j',
        'ｋ' => 'k',   'ｌ' => 'l',   'ｍ' => 'm',   'ｎ' => 'n',   'ｏ' => 'o',
        'ｐ' => 'p',   'ｑ' => 'q',   'ｒ' => 'r',   'ｓ' => 's',   'ｔ' => 't',
        'ｕ' => 'u',   'ｖ' => 'v',   'ｗ' => 'w',   'ｘ' => 'x',   'ｙ' => 'y',
        'ｚ' => 'z',
        '｛' => '{',   '｜' => '|',   '｝' => '}',   '～' => '~'
      }.freeze

      # Reverse GL mappings (halfwidth to fullwidth)
      GL_MAPPINGS_HW_TO_FW = GL_MAPPINGS_FW_TO_HW.invert.freeze

      # GR (Graphics Right) mappings - Katakana characters (fullwidth to halfwidth)
      GR_MAPPINGS_FW_TO_HW = {
        'ア' => 'ｱ',   'イ' => 'ｲ',   'ウ' => 'ｳ',   'エ' => 'ｴ',   'オ' => 'ｵ',
        'カ' => 'ｶ',   'キ' => 'ｷ',   'ク' => 'ｸ',   'ケ' => 'ｹ',   'コ' => 'ｺ',
        'サ' => 'ｻ',   'シ' => 'ｼ',   'ス' => 'ｽ',   'セ' => 'ｾ',   'ソ' => 'ｿ',
        'タ' => 'ﾀ',   'チ' => 'ﾁ',   'ツ' => 'ﾂ',   'テ' => 'ﾃ',   'ト' => 'ﾄ',
        'ナ' => 'ﾅ',   'ニ' => 'ﾆ',   'ヌ' => 'ﾇ',   'ネ' => 'ﾈ',   'ノ' => 'ﾉ',
        'ハ' => 'ﾊ',   'ヒ' => 'ﾋ',   'フ' => 'ﾌ',   'ヘ' => 'ﾍ',   'ホ' => 'ﾎ',
        'マ' => 'ﾏ',   'ミ' => 'ﾐ',   'ム' => 'ﾑ',   'メ' => 'ﾒ',   'モ' => 'ﾓ',
        'ヤ' => 'ﾔ',   'ユ' => 'ﾕ',   'ヨ' => 'ﾖ',
        'ラ' => 'ﾗ',   'リ' => 'ﾘ',   'ル' => 'ﾙ', 'レ' => 'ﾚ', 'ロ' => 'ﾛ',
        'ワ' => 'ﾜ',   'ヲ' => 'ｦ',   'ン' => 'ﾝ',
        'ァ' => 'ｧ',   'ィ' => 'ｨ',   'ゥ' => 'ｩ',   'ェ' => 'ｪ', 'ォ' => 'ｫ',
        'ッ' => 'ｯ',   'ャ' => 'ｬ',   'ュ' => 'ｭ',   'ョ' => 'ｮ',
        'ー' => 'ｰ',   '・' => '･',   '「' => '｢',   '」' => '｣',
        # Voiced katakana (fullwidth) → base + voice mark (halfwidth)
        'ガ' => 'ｶﾞ',  'ギ' => 'ｷﾞ',  'グ' => 'ｸﾞ',  'ゲ' => 'ｹﾞ',  'ゴ' => 'ｺﾞ',
        'ザ' => 'ｻﾞ',  'ジ' => 'ｼﾞ',  'ズ' => 'ｽﾞ',  'ゼ' => 'ｾﾞ',  'ゾ' => 'ｿﾞ',
        'ダ' => 'ﾀﾞ',  'ヂ' => 'ﾁﾞ',  'ヅ' => 'ﾂﾞ',  'デ' => 'ﾃﾞ',  'ド' => 'ﾄﾞ',
        'バ' => 'ﾊﾞ',  'ビ' => 'ﾋﾞ',  'ブ' => 'ﾌﾞ',  'ベ' => 'ﾍﾞ',  'ボ' => 'ﾎﾞ',
        'ヴ' => 'ｳﾞ',
        # Semi-voiced katakana (fullwidth) → base + semi-voice mark (halfwidth)
        'パ' => 'ﾊﾟ',  'ピ' => 'ﾋﾟ',  'プ' => 'ﾌﾟ',  'ペ' => 'ﾍﾟ',  'ポ' => 'ﾎﾟ'
      }.freeze

      # Reverse GR mappings (halfwidth to fullwidth) - simple cases
      GR_MAPPINGS_HW_TO_FW_SIMPLE = GR_MAPPINGS_FW_TO_HW.select { |_k, v| v.length == 1 }.invert.freeze

      # Hiragana to halfwidth katakana mappings
      HIRAGANA_TO_HW_KATAKANA = {
        'あ' => 'ｱ',   'い' => 'ｲ',   'う' => 'ｳ',   'え' => 'ｴ',   'お' => 'ｵ',
        'か' => 'ｶ',   'き' => 'ｷ',   'く' => 'ｸ',   'け' => 'ｹ',   'こ' => 'ｺ',
        'さ' => 'ｻ',   'し' => 'ｼ',   'す' => 'ｽ',   'せ' => 'ｾ',   'そ' => 'ｿ',
        'た' => 'ﾀ',   'ち' => 'ﾁ',   'つ' => 'ﾂ',   'て' => 'ﾃ',   'と' => 'ﾄ',
        'な' => 'ﾅ',   'に' => 'ﾆ',   'ぬ' => 'ﾇ',   'ね' => 'ﾈ',   'の' => 'ﾉ',
        'は' => 'ﾊ',   'ひ' => 'ﾋ',   'ふ' => 'ﾌ',   'へ' => 'ﾍ',   'ほ' => 'ﾎ',
        'ま' => 'ﾏ',   'み' => 'ﾐ',   'む' => 'ﾑ',   'め' => 'ﾒ',   'も' => 'ﾓ',
        'や' => 'ﾔ',   'ゆ' => 'ﾕ',   'よ' => 'ﾖ',
        'ら' => 'ﾗ',   'り' => 'ﾘ',   'る' => 'ﾙ', 'れ' => 'ﾚ', 'ろ' => 'ﾛ',
        'わ' => 'ﾜ',   'を' => 'ｦ',   'ん' => 'ﾝ',
        'ぁ' => 'ｧ',   'ぃ' => 'ｨ',   'ぅ' => 'ｩ',   'ぇ' => 'ｪ', 'ぉ' => 'ｫ',
        'っ' => 'ｯ',   'ゃ' => 'ｬ',   'ゅ' => 'ｭ',   'ょ' => 'ｮ',
        # Voiced hiragana → halfwidth katakana + voice mark
        'が' => 'ｶﾞ',  'ぎ' => 'ｷﾞ',  'ぐ' => 'ｸﾞ',  'げ' => 'ｹﾞ',  'ご' => 'ｺﾞ',
        'ざ' => 'ｻﾞ',  'じ' => 'ｼﾞ',  'ず' => 'ｽﾞ',  'ぜ' => 'ｾﾞ',  'ぞ' => 'ｿﾞ',
        'だ' => 'ﾀﾞ',  'ぢ' => 'ﾁﾞ',  'づ' => 'ﾂﾞ',  'で' => 'ﾃﾞ',  'ど' => 'ﾄﾞ',
        'ば' => 'ﾊﾞ',  'び' => 'ﾋﾞ',  'ぶ' => 'ﾌﾞ',  'べ' => 'ﾍﾞ',  'ぼ' => 'ﾎﾞ',
        'ゔ' => 'ｳﾞ',
        # Semi-voiced hiragana → halfwidth katakana + semi-voice mark
        'ぱ' => 'ﾊﾟ', 'ぴ' => 'ﾋﾟ', 'ぷ' => 'ﾌﾟ', 'ぺ' => 'ﾍﾟ', 'ぽ' => 'ﾎﾟ'
      }.freeze

      # Voice mark combinations for halfwidth to fullwidth conversion
      VOICE_MARK_COMBINATIONS = {
        'ｶﾞ' => 'ガ', 'ｷﾞ' => 'ギ', 'ｸﾞ' => 'グ', 'ｹﾞ' => 'ゲ', 'ｺﾞ' => 'ゴ',
        'ｻﾞ' => 'ザ', 'ｼﾞ' => 'ジ', 'ｽﾞ' => 'ズ', 'ｾﾞ' => 'ゼ', 'ｿﾞ' => 'ゾ',
        'ﾀﾞ' => 'ダ', 'ﾁﾞ' => 'ヂ', 'ﾂﾞ' => 'ヅ', 'ﾃﾞ' => 'デ', 'ﾄﾞ' => 'ド',
        'ﾊﾞ' => 'バ', 'ﾋﾞ' => 'ビ', 'ﾌﾞ' => 'ブ', 'ﾍﾞ' => 'ベ', 'ﾎﾞ' => 'ボ',
        'ｳﾞ' => 'ヴ',
        'ﾊﾟ' => 'パ', 'ﾋﾟ' => 'ピ', 'ﾌﾟ' => 'プ', 'ﾍﾟ' => 'ペ', 'ﾎﾟ' => 'ポ'
      }.freeze

      # Halfwidth voice marks
      HALFWIDTH_VOICED_MARK = 'ﾞ'      # U+FF9E
      HALFWIDTH_SEMI_VOICED_MARK = 'ﾟ' # U+FF9F

      # Special character mappings
      SPECIAL_MAPPINGS = {
        '゠' => '=',  # Katakana-hiragana double hyphen → equals sign
        '=' => '゠'   # Reverse mapping
      }.freeze

      # Transliterator for JIS X 0201 and alike characters
      class Transliterator < Yosina::BaseTransliterator
        attr_reader :fullwidth_to_halfwidth, :convert_gl, :convert_gr, :convert_hiraganas,
                    :combine_voiced_sound_marks, :convert_unsafe_specials, :u005c_as_yen_sign

        # Initialize the transliterator with options
        #
        # @param options [Hash] Configuration options
        # @option options [Boolean] :fullwidth_to_halfwidth Direction of conversion. Default: true (fw→hw).
        # @option options [Boolean] :convert_gl Convert ASCII-like characters. Default: true.
        # @option options [Boolean] :convert_gr Convert katakana characters. Default: true.
        # @option options [Boolean] :convert_hiraganas Convert hiragana to halfwidth katakana. Default: false.
        # @option options [Boolean] :combine_voiced_sound_marks Combine voice marks in hw→fw conversion.
        #     Default: false for fw→hw, true for hw→fw.
        # @option options [Boolean] :convert_unsafe_specials Convert unsafe special characters like ゠↔=. Default: false.
        # @option options [Boolean] :u005c_as_yen_sign Treat U+005C as yen sign instead of backslash. Default: false.
        def initialize(options = {})
          super()
          @fullwidth_to_halfwidth = options.fetch(:fullwidth_to_halfwidth, true)
          @convert_gl = options.fetch(:convert_gl, true)
          @convert_gr = options.fetch(:convert_gr, true)
          @convert_hiraganas = options.fetch(:convert_hiraganas, false)
          @convert_unsafe_specials = options.fetch(:convert_unsafe_specials, false)
          @u005c_as_yen_sign = options.fetch(:u005c_as_yen_sign, false)

          # Default combine_voiced_sound_marks based on direction
          @combine_voiced_sound_marks = if options.key?(:combine_voiced_sound_marks)
                                          options[:combine_voiced_sound_marks]
                                        else
                                          !@fullwidth_to_halfwidth
                                        end
        end

        # Convert between fullwidth and halfwidth characters
        #
        # @param input_chars [Array<Char>] The characters to transliterate
        # @return [Array<Char>] The transliterated characters
        def call(input_chars)
          offset = 0
          result = []
          i = 0

          while i < input_chars.length
            char = input_chars[i]
            replacement = nil

            if @fullwidth_to_halfwidth
              replacement = convert_fullwidth_to_halfwidth(char.c)
            else
              # Halfwidth to fullwidth conversion
              if @combine_voiced_sound_marks && i + 1 < input_chars.length
                # Look ahead for voice mark combinations
                next_char = input_chars[i + 1]
                two_char = char.c + next_char.c
                if VOICE_MARK_COMBINATIONS[two_char]
                  replacement = VOICE_MARK_COMBINATIONS[two_char]
                  result << Char.new(c: replacement, offset: offset, source: char)
                  offset += replacement.length
                  i += 2 # Skip both characters
                  next
                end
              end

              replacement = convert_halfwidth_to_fullwidth(char.c)
            end

            if replacement && replacement != char.c
              result << Char.new(c: replacement, offset: offset, source: char)
              offset += replacement.length
            else
              result << Char.new(c: char.c, offset: offset, source: char.source)
              offset += char.c.length
            end

            i += 1
          end

          result
        end

        private

        # Convert fullwidth character to halfwidth
        #
        # @param char [String] The character to convert
        # @return [String, nil] The converted character or nil if no conversion
        def convert_fullwidth_to_halfwidth(char)
          # Special character conversions (check first to override GL mappings)
          return SPECIAL_MAPPINGS[char] if @convert_unsafe_specials && SPECIAL_MAPPINGS[char]

          # GL conversions (ASCII-like)
          return GL_MAPPINGS_FW_TO_HW[char] if @convert_gl && GL_MAPPINGS_FW_TO_HW[char]

          # GR conversions (katakana)
          return GR_MAPPINGS_FW_TO_HW[char] if @convert_gr && GR_MAPPINGS_FW_TO_HW[char]

          # Hiragana conversions
          return HIRAGANA_TO_HW_KATAKANA[char] if @convert_hiraganas && HIRAGANA_TO_HW_KATAKANA[char]

          nil
        end

        # Convert halfwidth character to fullwidth
        #
        # @param char [String] The character to convert
        # @return [String, nil] The converted character or nil if no conversion
        def convert_halfwidth_to_fullwidth(char)
          # Special character conversions (check first to override GL mappings)
          return SPECIAL_MAPPINGS[char] if @convert_unsafe_specials && SPECIAL_MAPPINGS[char]

          # GL conversions (ASCII-like)
          if @convert_gl && GL_MAPPINGS_HW_TO_FW[char]
            # Special handling for backslash/yen sign
            return '￥' if char == '\\' && @u005c_as_yen_sign

            return GL_MAPPINGS_HW_TO_FW[char]
          end

          # GR conversions (katakana) - only simple ones
          return GR_MAPPINGS_HW_TO_FW_SIMPLE[char] if @convert_gr && GR_MAPPINGS_HW_TO_FW_SIMPLE[char]

          nil
        end
      end

      # Factory method to create a JIS X 0201 transliterator
      #
      # @param options [Hash] Configuration options
      # @return [Transliterator] A new JIS X 0201 transliterator instance
      def self.call(options = {})
        Transliterator.new(options)
      end
    end
  end
end
