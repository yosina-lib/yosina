# frozen_string_literal: true

require_relative '../transliterator'

module Yosina
  module Transliterators
    # JIS X 0201 and alike transliterator for fullwidth/halfwidth conversion
    module JisX0201AndAlike
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

      # GR area mapping table (fullwidth to halfwidth)
      JISX0201_GR_TABLE = [
        ["\u3002", "\uff61"], # 。 to ｡
        ["\u300c", "\uff62"], # 「 to ｢
        ["\u300d", "\uff63"], # 」 to ｣
        ["\u3001", "\uff64"], # 、 to ､
        ["\u30fb", "\uff65"], # ・ to ･
        ["\u30fc", "\uff70"], # ー to ｰ
        ["\u309b", "\uff9e"], # ゛ to ﾞ
        ["\u309c", "\uff9f"], # ゜to ﾟ
        # Small kana
        ["\u30a1", "\uff67"], # ァ to ｧ
        ["\u30a3", "\uff68"], # ィ to ｨ
        ["\u30a5", "\uff69"], # ゥ to ｩ
        ["\u30a7", "\uff6a"], # ェ to ｪ
        ["\u30a9", "\uff6b"], # ォ to ｫ
        ["\u30e3", "\uff6c"], # ャ to ｬ
        ["\u30e5", "\uff6d"], # ュ to ｭ
        ["\u30e7", "\uff6e"], # ョ to ｮ
        ["\u30c3", "\uff6f"], # ッ to ｯ
        # Vowels
        ["\u30a2", "\uff71"], # ア to ｱ
        ["\u30a4", "\uff72"], # イ to ｲ
        ["\u30a6", "\uff73"], # ウ to ｳ
        ["\u30a8", "\uff74"], # エ to ｴ
        ["\u30aa", "\uff75"], # オ to ｵ
        # K-row
        ["\u30ab", "\uff76"], # カ to ｶ
        ["\u30ad", "\uff77"], # キ to ｷ
        ["\u30af", "\uff78"], # ク to ｸ
        ["\u30b1", "\uff79"], # ケ to ｹ
        ["\u30b3", "\uff7a"], # コ to ｺ
        # S-row
        ["\u30b5", "\uff7b"], # サ to ｻ
        ["\u30b7", "\uff7c"], # シ to ｼ
        ["\u30b9", "\uff7d"], # ス to ｽ
        ["\u30bb", "\uff7e"], # セ to ｾ
        ["\u30bd", "\uff7f"], # ソ to ｿ
        # T-row
        ["\u30bf", "\uff80"], # タ to ﾀ
        ["\u30c1", "\uff81"], # チ to ﾁ
        ["\u30c4", "\uff82"], # ツ to ﾂ
        ["\u30c6", "\uff83"], # テ to ﾃ
        ["\u30c8", "\uff84"], # ト to ﾄ
        # N-row
        ["\u30ca", "\uff85"], # ナ to ﾅ
        ["\u30cb", "\uff86"], # ニ to ﾆ
        ["\u30cc", "\uff87"], # ヌ to ﾇ
        ["\u30cd", "\uff88"], # ネ to ﾈ
        ["\u30ce", "\uff89"], # ノ to ﾉ
        # H-row
        ["\u30cf", "\uff8a"], # ハ to ﾊ
        ["\u30d2", "\uff8b"], # ヒ to ﾋ
        ["\u30d5", "\uff8c"], # フ to ﾌ
        ["\u30d8", "\uff8d"], # ヘ to ﾍ
        ["\u30db", "\uff8e"], # ホ to ﾎ
        # M-row
        ["\u30de", "\uff8f"], # マ to ﾏ
        ["\u30df", "\uff90"], # ミ to ﾐ
        ["\u30e0", "\uff91"], # ム to ﾑ
        ["\u30e1", "\uff92"], # メ to ﾒ
        ["\u30e2", "\uff93"], # モ to ﾓ
        # Y-row
        ["\u30e4", "\uff94"], # ヤ to ﾔ
        ["\u30e6", "\uff95"], # ユ to ﾕ
        ["\u30e8", "\uff96"], # ヨ to ﾖ
        # R-row
        ["\u30e9", "\uff97"], # ラ to ﾗ
        ["\u30ea", "\uff98"], # リ to ﾘ
        ["\u30eb", "\uff99"], # ル to ﾙ
        ["\u30ec", "\uff9a"], # レ to ﾚ
        ["\u30ed", "\uff9b"], # ロ to ﾛ
        # W-row
        ["\u30ef", "\uff9c"], # ワ to ﾜ
        ["\u30f3", "\uff9d"], # ン to ﾝ
        ["\u30f2", "\uff66"] # ヲ to ｦ
      ].freeze

      # Special punctuations
      SPECIAL_PUNCTUATIONS_TABLE = [["\u30a0", "\u003d"]].freeze # ゠ to =

      # Voiced letters table
      VOICED_LETTERS_TABLE = [
        ["\u30f4", "\uff73\uff9e"], # ヴ to ｳﾞ
        # G-row [voiced K]
        ["\u30ac", "\uff76\uff9e"],  # ガ to ｶﾞ
        ["\u30ae", "\uff77\uff9e"],  # ギ to ｷﾞ
        ["\u30b0", "\uff78\uff9e"],  # グ to ｸﾞ
        ["\u30b2", "\uff79\uff9e"],  # ゲ to ｹﾞ
        ["\u30b4", "\uff7a\uff9e"],  # ゴ to ｺﾞ
        # Z-row [voiced S]
        ["\u30b6", "\uff7b\uff9e"],  # ザ to ｻﾞ
        ["\u30b8", "\uff7c\uff9e"],  # ジ to ｼﾞ
        ["\u30ba", "\uff7d\uff9e"],  # ズ to ｽﾞ
        ["\u30bc", "\uff7e\uff9e"],  # ゼ to ｾﾞ
        ["\u30be", "\uff7f\uff9e"],  # ゾ to ｿﾞ
        # D-row [voiced T]
        ["\u30c0", "\uff80\uff9e"],  # ダ to ﾀﾞ
        ["\u30c2", "\uff81\uff9e"],  # ヂ to ﾁﾞ
        ["\u30c5", "\uff82\uff9e"],  # ヅ to ﾂﾞ
        ["\u30c7", "\uff83\uff9e"],  # デ to ﾃﾞ
        ["\u30c9", "\uff84\uff9e"],  # ド to ﾄﾞ
        # B-row [voiced H]
        ["\u30d0", "\uff8a\uff9e"],  # バ to ﾊﾞ
        ["\u30d3", "\uff8b\uff9e"],  # ビ to ﾋﾞ
        ["\u30d6", "\uff8c\uff9e"],  # ブ to ﾌﾞ
        ["\u30d9", "\uff8d\uff9e"],  # ベ to ﾍﾞ
        ["\u30dc", "\uff8e\uff9e"],  # ボ to ﾎﾞ
        # P-row [half-voiced H]
        ["\u30d1", "\uff8a\uff9f"],  # パ to ﾊﾟ
        ["\u30d4", "\uff8b\uff9f"],  # ピ to ﾋﾟ
        ["\u30d7", "\uff8c\uff9f"],  # プ to ﾌﾟ
        ["\u30da", "\uff8d\uff9f"],  # ペ to ﾍﾟ
        ["\u30dd", "\uff8e\uff9f"],  # ポ to ﾎﾟ
        # Special
        ["\u30fa", "\uff66\uff9e"] # ヺ to ｦﾞ
      ].freeze

      # Hiragana mappings
      HIRAGANA_MAPPINGS = [
        # Small hiragana
        ["\u3041", "\uff67"], # ぁ to ｧ
        ["\u3043", "\uff68"], # ぃ to ｨ
        ["\u3045", "\uff69"], # ぅ to ｩ
        ["\u3047", "\uff6a"], # ぇ to ｪ
        ["\u3049", "\uff6b"], # ぉ to ｫ
        ["\u3083", "\uff6c"], # ゃ to ｬ
        ["\u3085", "\uff6d"], # ゅ to ｭ
        ["\u3087", "\uff6e"], # ょ to ｮ
        ["\u3063", "\uff6f"], # っ to ｯ
        # Vowels
        ["\u3042", "\uff71"], # あ to ｱ
        ["\u3044", "\uff72"], # い to ｲ
        ["\u3046", "\uff73"], # う to ｳ
        ["\u3048", "\uff74"], # え to ｴ
        ["\u304a", "\uff75"], # お to ｵ
        # K-row
        ["\u304b", "\uff76"], # か to ｶ
        ["\u304d", "\uff77"], # き to ｷ
        ["\u304f", "\uff78"], # く to ｸ
        ["\u3051", "\uff79"], # け to ｹ
        ["\u3053", "\uff7a"], # こ to ｺ
        # S-row
        ["\u3055", "\uff7b"], # さ to ｻ
        ["\u3057", "\uff7c"], # し to ｼ
        ["\u3059", "\uff7d"], # す to ｽ
        ["\u305b", "\uff7e"], # せ to ｾ
        %w[そ ｿ], # そ to ｿ
        # T-row
        ["\u305f", "\uff80"], # た to ﾀ
        ["\u3061", "\uff81"], # ち to ﾁ
        ["\u3064", "\uff82"], # つ to ﾂ
        ["\u3066", "\uff83"], # て to ﾃ
        ["\u3068", "\uff84"], # と to ﾄ
        # N-row
        ["\u306a", "\uff85"], # な to ﾅ
        ["\u306b", "\uff86"], # に to ﾆ
        ["\u306c", "\uff87"], # ぬ to ﾇ
        ["\u306d", "\uff88"], # ね to ﾈ
        ["\u306e", "\uff89"], # の to ﾉ
        # H-row
        ["\u306f", "\uff8a"], # は to ﾊ
        ["\u3072", "\uff8b"], # ひ to ﾋ
        ["\u3075", "\uff8c"], # ふ to ﾌ
        ["\u3078", "\uff8d"], # へ to ﾍ
        ["\u307b", "\uff8e"], # ほ to ﾎ
        # M-row
        ["\u307e", "\uff8f"], # ま to ﾏ
        ["\u307f", "\uff90"], # み to ﾐ
        ["\u3080", "\uff91"], # む to ﾑ
        ["\u3081", "\uff92"], # め to ﾒ
        ["\u3082", "\uff93"], # も to ﾓ
        # Y-row
        ["\u3084", "\uff94"], # や to ﾔ
        ["\u3086", "\uff95"], # ゆ to ﾕ
        ["\u3088", "\uff96"], # よ to ﾖ
        # R-row
        ["\u3089", "\uff97"], # ら to ﾗ
        ["\u308a", "\uff98"], # り to ﾘ
        ["\u308b", "\uff99"], # る to ﾙ
        ["\u308c", "\uff9a"], # れ to ﾚ
        ["\u308d", "\uff9b"], # ろ to ﾛ
        # W-row
        ["\u308f", "\uff9c"], # わ to ﾜ
        ["\u3093", "\uff9d"], # ん to ﾝ
        ["\u3092", "\uff66"], # を to ｦ
        # Voiced
        ["\u3094", "\uff73\uff9e"], # ゔ to ｳﾞ
        # Voiced K (G)
        ["\u304c", "\uff76\uff9e"], # が to ｶﾞ
        ["\u304e", "\uff77\uff9e"], # ぎ to ｷﾞ
        ["\u3050", "\uff78\uff9e"], # ぐ to ｸﾞ
        ["\u3052", "\uff79\uff9e"], # げ to ｹﾞ
        ["\u3054", "\uff7a\uff9e"], # ご to ｺﾞ
        # Voiced S (Z)
        ["\u3056", "\uff7b\uff9e"], # ざ to ｻﾞ
        ["\u3058", "\uff7c\uff9e"], # じ to ｼﾞ
        ["\u305a", "\uff7d\uff9e"], # ず to ｽﾞ
        ["\u305c", "\uff7e\uff9e"], # ぜ to ｾﾞ
        ["\u305e", "\uff7f\uff9e"], # ぞ to ｿﾞ
        # Voiced T (D)
        ["\u3060", "\uff80\uff9e"], # だ to ﾀﾞ
        ["\u3062", "\uff81\uff9e"], # ぢ to ﾁﾞ
        ["\u3065", "\uff82\uff9e"], # づ to ﾂﾞ
        ["\u3067", "\uff83\uff9e"], # で to ﾃﾞ
        ["\u3069", "\uff84\uff9e"], # ど to ﾄﾞ
        # Voiced H (B)
        ["\u3070", "\uff8a\uff9e"], # ば to ﾊﾞ
        ["\u3073", "\uff8b\uff9e"], # び to ﾋﾞ
        ["\u3076", "\uff8c\uff9e"], # ぶ to ﾌﾞ
        ["\u3079", "\uff8d\uff9e"], # べ to ﾍﾞ
        ["\u307c", "\uff8e\uff9e"], # ぼ to ﾎﾞ
        # Half-voiced H (P)
        ["\u3071", "\uff8a\uff9f"], # ぱ to ﾊﾟ
        ["\u3074", "\uff8b\uff9f"], # ぴ to ﾋﾟ
        ["\u3077", "\uff8c\uff9f"], # ぷ to ﾌﾟ
        ["\u307a", "\uff8d\uff9f"], # ぺ to ﾍﾟ
        ["\u307d", "\uff8e\uff9f"] # ぽ to ﾎﾟ
      ].freeze

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
