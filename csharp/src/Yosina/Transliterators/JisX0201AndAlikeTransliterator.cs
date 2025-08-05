// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Transliterators;

/// <summary>
/// Transliterator for fullwidth/halfwidth character conversion.
/// Handles conversion between JIS X 0201 and alike character sets.
/// </summary>
[RegisteredTransliterator("jisx0201-and-alike")]
public class JisX0201AndAlikeTransliterator : ITransliterator
{
    // JIS X 0201 GL (Graphics Left) table - fullwidth to halfwidth alphanumerics and symbols
    private static readonly Dictionary<int, int> Jisx0201GLTable = new()
    {
        { 0x3000, 0x0020 }, // 　 -> space
        { 0xff01, 0x0021 }, // ！ -> !
        { 0xff02, 0x0022 }, // ＂ -> "
        { 0xff03, 0x0023 }, // ＃ -> #
        { 0xff04, 0x0024 }, // ＄ -> $
        { 0xff05, 0x0025 }, // ％ -> %
        { 0xff06, 0x0026 }, // ＆ -> &
        { 0xff07, 0x0027 }, // ＇ -> '
        { 0xff08, 0x0028 }, // （ -> (
        { 0xff09, 0x0029 }, // ） -> )
        { 0xff0a, 0x002a }, // ＊ -> *
        { 0xff0b, 0x002b }, // ＋ -> +
        { 0xff0c, 0x002c }, // ， -> ,
        { 0xff0d, 0x002d }, // － -> -
        { 0xff0e, 0x002e }, // ． -> .
        { 0xff0f, 0x002f }, // ／ -> /
        { 0xff10, 0x0030 }, // ０ -> 0
        { 0xff11, 0x0031 }, // １ -> 1
        { 0xff12, 0x0032 }, // ２ -> 2
        { 0xff13, 0x0033 }, // ３ -> 3
        { 0xff14, 0x0034 }, // ４ -> 4
        { 0xff15, 0x0035 }, // ５ -> 5
        { 0xff16, 0x0036 }, // ６ -> 6
        { 0xff17, 0x0037 }, // ７ -> 7
        { 0xff18, 0x0038 }, // ８ -> 8
        { 0xff19, 0x0039 }, // ９ -> 9
        { 0xff1a, 0x003a }, // ： -> :
        { 0xff1b, 0x003b }, // ； -> ;
        { 0xff1c, 0x003c }, // ＜ -> <
        { 0xff1d, 0x003d }, // ＝ -> =
        { 0xff1e, 0x003e }, // ＞ -> >
        { 0xff1f, 0x003f }, // ？ -> ?
        { 0xff20, 0x0040 }, // ＠ -> @
        { 0xff21, 0x0041 }, // Ａ -> A
        { 0xff22, 0x0042 }, // Ｂ -> B
        { 0xff23, 0x0043 }, // Ｃ -> C
        { 0xff24, 0x0044 }, // Ｄ -> D
        { 0xff25, 0x0045 }, // Ｅ -> E
        { 0xff26, 0x0046 }, // Ｆ -> F
        { 0xff27, 0x0047 }, // Ｇ -> G
        { 0xff28, 0x0048 }, // Ｈ -> H
        { 0xff29, 0x0049 }, // Ｉ -> I
        { 0xff2a, 0x004a }, // Ｊ -> J
        { 0xff2b, 0x004b }, // Ｋ -> K
        { 0xff2c, 0x004c }, // Ｌ -> L
        { 0xff2d, 0x004d }, // Ｍ -> M
        { 0xff2e, 0x004e }, // Ｎ -> N
        { 0xff2f, 0x004f }, // Ｏ -> O
        { 0xff30, 0x0050 }, // Ｐ -> P
        { 0xff31, 0x0051 }, // Ｑ -> Q
        { 0xff32, 0x0052 }, // Ｒ -> R
        { 0xff33, 0x0053 }, // Ｓ -> S
        { 0xff34, 0x0054 }, // Ｔ -> T
        { 0xff35, 0x0055 }, // Ｕ -> U
        { 0xff36, 0x0056 }, // Ｖ -> V
        { 0xff37, 0x0057 }, // Ｗ -> W
        { 0xff38, 0x0058 }, // Ｘ -> X
        { 0xff39, 0x0059 }, // Ｙ -> Y
        { 0xff3a, 0x005a }, // Ｚ -> Z
        { 0xff3b, 0x005b }, // ［ -> [
        { 0xff3d, 0x005d }, // ］ -> ]
        { 0xff3e, 0x005e }, // ＾ -> ^
        { 0xff3f, 0x005f }, // ＿ -> _
        { 0xff40, 0x0060 }, // ｀ -> `
        { 0xff41, 0x0061 }, // ａ -> a
        { 0xff42, 0x0062 }, // ｂ -> b
        { 0xff43, 0x0063 }, // ｃ -> c
        { 0xff44, 0x0064 }, // ｄ -> d
        { 0xff45, 0x0065 }, // ｅ -> e
        { 0xff46, 0x0066 }, // ｆ -> f
        { 0xff47, 0x0067 }, // ｇ -> g
        { 0xff48, 0x0068 }, // ｈ -> h
        { 0xff49, 0x0069 }, // ｉ -> i
        { 0xff4a, 0x006a }, // ｊ -> j
        { 0xff4b, 0x006b }, // ｋ -> k
        { 0xff4c, 0x006c }, // ｌ -> l
        { 0xff4d, 0x006d }, // ｍ -> m
        { 0xff4e, 0x006e }, // ｎ -> n
        { 0xff4f, 0x006f }, // ｏ -> o
        { 0xff50, 0x0070 }, // ｐ -> p
        { 0xff51, 0x0071 }, // ｑ -> q
        { 0xff52, 0x0072 }, // ｒ -> r
        { 0xff53, 0x0073 }, // ｓ -> s
        { 0xff54, 0x0074 }, // ｔ -> t
        { 0xff55, 0x0075 }, // ｕ -> u
        { 0xff56, 0x0076 }, // ｖ -> v
        { 0xff57, 0x0077 }, // ｗ -> w
        { 0xff58, 0x0078 }, // ｘ -> x
        { 0xff59, 0x0079 }, // ｙ -> y
        { 0xff5a, 0x007a }, // ｚ -> z
        { 0xff5b, 0x007b }, // ｛ -> {
        { 0xff5c, 0x007c }, // ｜ -> |
        { 0xff5d, 0x007d }, // ｝ -> }
    };

    // JIS X 0201 GR (Graphics Right) table - fullwidth katakana to halfwidth
    private static readonly Dictionary<int, int> Jisx0201GRTable = new()
    {
        { 0x3002, 0xff61 }, // 。 -> ｡
        { 0x300c, 0xff62 }, // 「 -> ｢
        { 0x300d, 0xff63 }, // 」 -> ｣
        { 0x3001, 0xff64 }, // 、 -> ､
        { 0x30fb, 0xff65 }, // ・ -> ･
        { 0x30fc, 0xff70 }, // ー -> ｰ
        { 0x309b, 0xff9e }, // ゛ -> ﾞ
        { 0x309c, 0xff9f }, // ゜-> ﾟ
        { 0x30a1, 0xff67 }, // ァ -> ｧ
        { 0x30a3, 0xff68 }, // ィ -> ｨ
        { 0x30a5, 0xff69 }, // ゥ -> ｩ
        { 0x30a7, 0xff6a }, // ェ -> ｪ
        { 0x30a9, 0xff6b }, // ォ -> ｫ
        { 0x30e3, 0xff6c }, // ャ -> ｬ
        { 0x30e5, 0xff6d }, // ュ -> ｭ
        { 0x30e7, 0xff6e }, // ョ -> ｮ
        { 0x30c3, 0xff6f }, // ッ -> ｯ
        { 0x30a2, 0xff71 }, // ア -> ｱ
        { 0x30a4, 0xff72 }, // イ -> ｲ
        { 0x30a6, 0xff73 }, // ウ -> ｳ
        { 0x30a8, 0xff74 }, // エ -> ｴ
        { 0x30aa, 0xff75 }, // オ -> ｵ
        { 0x30ab, 0xff76 }, // カ -> ｶ
        { 0x30ad, 0xff77 }, // キ -> ｷ
        { 0x30af, 0xff78 }, // ク -> ｸ
        { 0x30b1, 0xff79 }, // ケ -> ｹ
        { 0x30b3, 0xff7a }, // コ -> ｺ
        { 0x30b5, 0xff7b }, // サ -> ｻ
        { 0x30b7, 0xff7c }, // シ -> ｼ
        { 0x30b9, 0xff7d }, // ス -> ｽ
        { 0x30bb, 0xff7e }, // セ -> ｾ
        { 0x30bd, 0xff7f }, // ソ -> ｿ
        { 0x30bf, 0xff80 }, // タ -> ﾀ
        { 0x30c1, 0xff81 }, // チ -> ﾁ
        { 0x30c4, 0xff82 }, // ツ -> ﾂ
        { 0x30c6, 0xff83 }, // テ -> ﾃ
        { 0x30c8, 0xff84 }, // ト -> ﾄ
        { 0x30ca, 0xff85 }, // ナ -> ﾅ
        { 0x30cb, 0xff86 }, // ニ -> ﾆ
        { 0x30cc, 0xff87 }, // ヌ -> ﾇ
        { 0x30cd, 0xff88 }, // ネ -> ﾈ
        { 0x30ce, 0xff89 }, // ノ -> ﾉ
        { 0x30cf, 0xff8a }, // ハ -> ﾊ
        { 0x30d2, 0xff8b }, // ヒ -> ﾋ
        { 0x30d5, 0xff8c }, // フ -> ﾌ
        { 0x30d8, 0xff8d }, // ヘ -> ﾍ
        { 0x30db, 0xff8e }, // ホ -> ﾎ
        { 0x30de, 0xff8f }, // マ -> ﾏ
        { 0x30df, 0xff90 }, // ミ -> ﾐ
        { 0x30e0, 0xff91 }, // ム -> ﾑ
        { 0x30e1, 0xff92 }, // メ -> ﾒ
        { 0x30e2, 0xff93 }, // モ -> ﾓ
        { 0x30e4, 0xff94 }, // ヤ -> ﾔ
        { 0x30e6, 0xff95 }, // ユ -> ﾕ
        { 0x30e8, 0xff96 }, // ヨ -> ﾖ
        { 0x30e9, 0xff97 }, // ラ -> ﾗ
        { 0x30ea, 0xff98 }, // リ -> ﾘ
        { 0x30eb, 0xff99 }, // ル -> ﾙ
        { 0x30ec, 0xff9a }, // レ -> ﾚ
        { 0x30ed, 0xff9b }, // ロ -> ﾛ
        { 0x30ef, 0xff9c }, // ワ -> ﾜ
        { 0x30f3, 0xff9d }, // ン -> ﾝ
        { 0x30f2, 0xff66 }, // ヲ -> ｦ
    };

    // Voiced letters table - voiced katakana to halfwidth katakana + sound mark
    private static readonly Dictionary<int, int[]> VoicedLettersTable = new()
    {
        { 0x30f4, new[] { 0xff73, 0xff9e } }, // ヴ -> ｳﾞ
        { 0x30ac, new[] { 0xff76, 0xff9e } }, // ガ -> ｶﾞ
        { 0x30ae, new[] { 0xff77, 0xff9e } }, // ギ -> ｷﾞ
        { 0x30b0, new[] { 0xff78, 0xff9e } }, // グ -> ｸﾞ
        { 0x30b2, new[] { 0xff79, 0xff9e } }, // ゲ -> ｹﾞ
        { 0x30b4, new[] { 0xff7a, 0xff9e } }, // ゴ -> ｺﾞ
        { 0x30b6, new[] { 0xff7b, 0xff9e } }, // ザ -> ｻﾞ
        { 0x30b8, new[] { 0xff7c, 0xff9e } }, // ジ -> ｼﾞ
        { 0x30ba, new[] { 0xff7d, 0xff9e } }, // ズ -> ｽﾞ
        { 0x30bc, new[] { 0xff7e, 0xff9e } }, // ゼ -> ｾﾞ
        { 0x30be, new[] { 0xff7f, 0xff9e } }, // ゾ -> ｿﾞ
        { 0x30c0, new[] { 0xff80, 0xff9e } }, // ダ -> ﾀﾞ
        { 0x30c2, new[] { 0xff81, 0xff9e } }, // ヂ -> ﾁﾞ
        { 0x30c5, new[] { 0xff82, 0xff9e } }, // ヅ -> ﾂﾞ
        { 0x30c7, new[] { 0xff83, 0xff9e } }, // デ -> ﾃﾞ
        { 0x30c9, new[] { 0xff84, 0xff9e } }, // ド -> ﾄﾞ
        { 0x30d0, new[] { 0xff8a, 0xff9e } }, // バ -> ﾊﾞ
        { 0x30d3, new[] { 0xff8b, 0xff9e } }, // ビ -> ﾋﾞ
        { 0x30d6, new[] { 0xff8c, 0xff9e } }, // ブ -> ﾌﾞ
        { 0x30d9, new[] { 0xff8d, 0xff9e } }, // ベ -> ﾍﾞ
        { 0x30dc, new[] { 0xff8e, 0xff9e } }, // ボ -> ﾎﾞ
        { 0x30d1, new[] { 0xff8a, 0xff9f } }, // パ -> ﾊﾟ
        { 0x30d4, new[] { 0xff8b, 0xff9f } }, // ピ -> ﾋﾟ
        { 0x30d7, new[] { 0xff8c, 0xff9f } }, // プ -> ﾌﾟ
        { 0x30da, new[] { 0xff8d, 0xff9f } }, // ペ -> ﾍﾟ
        { 0x30dd, new[] { 0xff8e, 0xff9f } }, // ポ -> ﾎﾟ
        { 0x30fa, new[] { 0xff66, 0xff9e } }, // ヺ -> ｦﾞ
    };

    // Hiragana table - hiragana to halfwidth katakana
    private static readonly Dictionary<int, int[]> HiraganaTable = new()
    {
        { 0x3041, new[] { 0xff67 } }, // ぁ -> ｧ
        { 0x3043, new[] { 0xff68 } }, // ぃ -> ｨ
        { 0x3045, new[] { 0xff69 } }, // ぅ -> ｩ
        { 0x3047, new[] { 0xff6a } }, // ぇ -> ｪ
        { 0x3049, new[] { 0xff6b } }, // ぉ -> ｫ
        { 0x3083, new[] { 0xff6c } }, // ゃ -> ｬ
        { 0x3085, new[] { 0xff6d } }, // ゅ -> ｭ
        { 0x3087, new[] { 0xff6e } }, // ょ -> ｮ
        { 0x3063, new[] { 0xff6f } }, // っ -> ｯ
        { 0x3042, new[] { 0xff71 } }, // あ -> ｱ
        { 0x3044, new[] { 0xff72 } }, // い -> ｲ
        { 0x3046, new[] { 0xff73 } }, // う -> ｳ
        { 0x3048, new[] { 0xff74 } }, // え -> ｴ
        { 0x304a, new[] { 0xff75 } }, // お -> ｵ
        { 0x304b, new[] { 0xff76 } }, // か -> ｶ
        { 0x304d, new[] { 0xff77 } }, // き -> ｷ
        { 0x304f, new[] { 0xff78 } }, // く -> ｸ
        { 0x3051, new[] { 0xff79 } }, // け -> ｹ
        { 0x3053, new[] { 0xff7a } }, // こ -> ｺ
        { 0x3055, new[] { 0xff7b } }, // さ -> ｻ
        { 0x3057, new[] { 0xff7c } }, // し -> ｼ
        { 0x3059, new[] { 0xff7d } }, // す -> ｽ
        { 0x305b, new[] { 0xff7e } }, // せ -> ｾ
        { 0x305d, new[] { 0xff7f } }, // そ -> ｿ
        { 0x305f, new[] { 0xff80 } }, // た -> ﾀ
        { 0x3061, new[] { 0xff81 } }, // ち -> ﾁ
        { 0x3064, new[] { 0xff82 } }, // つ -> ﾂ
        { 0x3066, new[] { 0xff83 } }, // て -> ﾃ
        { 0x3068, new[] { 0xff84 } }, // と -> ﾄ
        { 0x306a, new[] { 0xff85 } }, // な -> ﾅ
        { 0x306b, new[] { 0xff86 } }, // に -> ﾆ
        { 0x306c, new[] { 0xff87 } }, // ぬ -> ﾇ
        { 0x306d, new[] { 0xff88 } }, // ね -> ﾈ
        { 0x306e, new[] { 0xff89 } }, // の -> ﾉ
        { 0x306f, new[] { 0xff8a } }, // は -> ﾊ
        { 0x3072, new[] { 0xff8b } }, // ひ -> ﾋ
        { 0x3075, new[] { 0xff8c } }, // ふ -> ﾌ
        { 0x3078, new[] { 0xff8d } }, // へ -> ﾍ
        { 0x307b, new[] { 0xff8e } }, // ほ -> ﾎ
        { 0x307e, new[] { 0xff8f } }, // ま -> ﾏ
        { 0x307f, new[] { 0xff90 } }, // み -> ﾐ
        { 0x3080, new[] { 0xff91 } }, // む -> ﾑ
        { 0x3081, new[] { 0xff92 } }, // め -> ﾒ
        { 0x3082, new[] { 0xff93 } }, // も -> ﾓ
        { 0x3084, new[] { 0xff94 } }, // や -> ﾔ
        { 0x3086, new[] { 0xff95 } }, // ゆ -> ﾕ
        { 0x3088, new[] { 0xff96 } }, // よ -> ﾖ
        { 0x3089, new[] { 0xff97 } }, // ら -> ﾗ
        { 0x308a, new[] { 0xff98 } }, // り -> ﾘ
        { 0x308b, new[] { 0xff99 } }, // る -> ﾙ
        { 0x308c, new[] { 0xff9a } }, // れ -> ﾚ
        { 0x308d, new[] { 0xff9b } }, // ろ -> ﾛ
        { 0x308f, new[] { 0xff9c } }, // わ -> ﾜ
        { 0x3093, new[] { 0xff9d } }, // ん -> ﾝ
        { 0x3092, new[] { 0xff66 } }, // を -> ｦ
        { 0x3094, new[] { 0xff73, 0xff9e } }, // ゔ -> ｳﾞ
        { 0x304c, new[] { 0xff76, 0xff9e } }, // が -> ｶﾞ
        { 0x304e, new[] { 0xff77, 0xff9e } }, // ぎ -> ｷﾞ
        { 0x3050, new[] { 0xff78, 0xff9e } }, // ぐ -> ｸﾞ
        { 0x3052, new[] { 0xff79, 0xff9e } }, // げ -> ｹﾞ
        { 0x3054, new[] { 0xff7a, 0xff9e } }, // ご -> ｺﾞ
        { 0x3056, new[] { 0xff7b, 0xff9e } }, // ざ -> ｻﾞ
        { 0x3058, new[] { 0xff7c, 0xff9e } }, // じ -> ｼﾞ
        { 0x305a, new[] { 0xff7d, 0xff9e } }, // ず -> ｽﾞ
        { 0x305c, new[] { 0xff7e, 0xff9e } }, // ぜ -> ｾﾞ
        { 0x305e, new[] { 0xff7f, 0xff9e } }, // ぞ -> ｿﾞ
        { 0x3060, new[] { 0xff80, 0xff9e } }, // だ -> ﾀﾞ
        { 0x3062, new[] { 0xff81, 0xff9e } }, // ぢ -> ﾁﾞ
        { 0x3065, new[] { 0xff82, 0xff9e } }, // づ -> ﾂﾞ
        { 0x3067, new[] { 0xff83, 0xff9e } }, // で -> ﾃﾞ
        { 0x3069, new[] { 0xff84, 0xff9e } }, // ど -> ﾄﾞ
        { 0x3070, new[] { 0xff8a, 0xff9e } }, // ば -> ﾊﾞ
        { 0x3073, new[] { 0xff8b, 0xff9e } }, // び -> ﾋﾞ
        { 0x3076, new[] { 0xff8c, 0xff9e } }, // ぶ -> ﾌﾞ
        { 0x3079, new[] { 0xff8d, 0xff9e } }, // べ -> ﾍﾞ
        { 0x307c, new[] { 0xff8e, 0xff9e } }, // ぼ -> ﾎﾞ
        { 0x3071, new[] { 0xff8a, 0xff9f } }, // ぱ -> ﾊﾟ
        { 0x3074, new[] { 0xff8b, 0xff9f } }, // ぴ -> ﾋﾟ
        { 0x3077, new[] { 0xff8c, 0xff9f } }, // ぷ -> ﾌﾟ
        { 0x307a, new[] { 0xff8d, 0xff9f } }, // ぺ -> ﾍﾟ
        { 0x307d, new[] { 0xff8e, 0xff9f } }, // ぽ -> ﾎﾟ
    };

    // Special punctuations table
    private static readonly Dictionary<int, int> SpecialPunctuationsTable = new()
    {
        { 0x30a0, 0x003d }, // ゠ -> =
    };

    public class Options
    {
        public bool FullwidthToHalfwidth { get; set; } = true;

        public bool ConvertGL { get; set; } = true;

        public bool ConvertGR { get; set; } = true;

        public bool? ConvertUnsafeSpecials { get; set; }

        public bool ConvertHiraganas { get; set; }

        public bool CombineVoicedSoundMarks { get; set; } = true;

        public bool? U005cAsYenSign { get; set; }

        public bool? U005cAsBackslash { get; set; }

        public bool? U007eAsFullwidthTilde { get; set; }

        public bool? U007eAsWaveDash { get; set; }

        public bool? U007eAsOverline { get; set; }

        public bool? U007eAsFullwidthMacron { get; set; }

        public bool? U00a5AsYenSign { get; set; }

        internal ForwardOptions BuildForwardOptions()
        {
            return new ForwardOptions
            {
                ConvertGL = this.ConvertGL,
                ConvertGR = this.ConvertGR,
                ConvertUnsafeSpecials = this.ConvertUnsafeSpecials ?? true,
                ConvertHiraganas = this.ConvertHiraganas,
                U005cAsYenSign = this.U005cAsYenSign ?? this.U00a5AsYenSign == null,
                U005cAsBackslash = this.U005cAsBackslash ?? false,
                U007eAsFullwidthTilde = this.U007eAsFullwidthTilde ?? true,
                U007eAsWaveDash = this.U007eAsWaveDash ?? true,
                U007eAsOverline = this.U007eAsOverline ?? false,
                U007eAsFullwidthMacron = this.U007eAsFullwidthMacron ?? false,
                U00a5AsYenSign = this.U00a5AsYenSign ?? false,
            };
        }

        internal ReverseOptions BuildReverseOptions()
        {
            return new ReverseOptions
            {
                ConvertGL = this.ConvertGL,
                ConvertGR = this.ConvertGR,
                ConvertUnsafeSpecials = this.ConvertUnsafeSpecials ?? false,
                CombineVoicedSoundMarks = this.CombineVoicedSoundMarks,
                U005cAsYenSign = this.U005cAsYenSign ?? this.U005cAsBackslash == null,
                U005cAsBackslash = this.U005cAsBackslash ?? false,
                U007eAsFullwidthTilde = this.U007eAsFullwidthTilde ?? this.U007eAsWaveDash == null && this.U007eAsOverline == null && this.U007eAsFullwidthMacron == null,
                U007eAsWaveDash = this.U007eAsWaveDash ?? false,
                U007eAsOverline = this.U007eAsOverline ?? false,
                U007eAsFullwidthMacron = this.U007eAsFullwidthMacron ?? false,
                U00a5AsYenSign = this.U00a5AsYenSign ?? true,
            };
        }
    }

    internal class ForwardOptions
    {
        public bool ConvertGL { get; set; } = true;

        public bool ConvertGR { get; set; } = true;

        public bool ConvertUnsafeSpecials { get; set; }

        public bool ConvertHiraganas { get; set; }

        public bool U005cAsYenSign { get; set; } = true;

        public bool U005cAsBackslash { get; set; }

        public bool U007eAsFullwidthTilde { get; set; }

        public bool U007eAsWaveDash { get; set; }

        public bool U007eAsOverline { get; set; }

        public bool U007eAsFullwidthMacron { get; set; }

        public bool U00a5AsYenSign { get; set; }
    }

    internal class ReverseOptions
    {
        public bool ConvertGL { get; set; } = true;

        public bool ConvertGR { get; set; } = true;

        public bool ConvertUnsafeSpecials { get; set; }

        public bool CombineVoicedSoundMarks { get; set; } = true;

        public bool U005cAsYenSign { get; set; } = true;

        public bool U005cAsBackslash { get; set; }

        public bool U007eAsFullwidthTilde { get; set; }

        public bool U007eAsWaveDash { get; set; }

        public bool U007eAsOverline { get; set; }

        public bool U007eAsFullwidthMacron { get; set; }

        public bool U00a5AsYenSign { get; set; }
    }

    private readonly ReverseOptions? reverseOptions;
    private readonly ForwardOptions? forwardOptions;

    public JisX0201AndAlikeTransliterator()
        : this(new Options())
    {
    }

    public JisX0201AndAlikeTransliterator(Options options)
    {
        if (options.FullwidthToHalfwidth)
        {
            this.forwardOptions = options.BuildForwardOptions();
        }
        else
        {
            this.reverseOptions = options.BuildReverseOptions();
        }
    }

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        return this.forwardOptions != null ? new ForwardCharEnumerator(this.BuildForwardMappings(), input.GetEnumerator()) : new ReverseCharEnumerator(this.BuildReverseMappings(), input.GetEnumerator(), this.reverseOptions!);
    }

    private Dictionary<int, int[]> BuildForwardMappings()
    {
        var mappings = new Dictionary<int, int[]>();

        if (this.forwardOptions is ForwardOptions forwardOptions)
        {
            if (forwardOptions.ConvertGL)
            {
                foreach (var kvp in Jisx0201GLTable)
                {
                    mappings[kvp.Key] = new[] { kvp.Value };
                }

                // Handle overrides
                if (forwardOptions.U005cAsYenSign)
                {
                    mappings[0xffe5] = new[] { 0x005c };
                }

                if (forwardOptions.U005cAsBackslash)
                {
                    mappings[0xff3c] = new[] { 0x005c };
                }

                if (forwardOptions.U007eAsFullwidthTilde)
                {
                    mappings[0xff5e] = new[] { 0x007e };
                }

                if (forwardOptions.U007eAsWaveDash)
                {
                    mappings[0x301c] = new[] { 0x007e };
                }

                if (forwardOptions.U007eAsOverline)
                {
                    mappings[0x203e] = new[] { 0x007e };
                }

                if (forwardOptions.U007eAsFullwidthMacron)
                {
                    mappings[0xffe3] = new[] { 0x007e };
                }

                if (forwardOptions.U00a5AsYenSign)
                {
                    mappings[0xffe5] = new[] { 0x00a5 };
                }

                if (forwardOptions.ConvertUnsafeSpecials)
                {
                    foreach (var kvp in SpecialPunctuationsTable)
                    {
                        mappings[kvp.Key] = new[] { kvp.Value };
                    }
                }
            }

            if (forwardOptions.ConvertGR)
            {
                foreach (var kvp in Jisx0201GRTable)
                {
                    mappings[kvp.Key] = new[] { kvp.Value };
                }

                foreach (var kvp in VoicedLettersTable)
                {
                    mappings[kvp.Key] = kvp.Value;
                }

                mappings[0x3099] = new[] { 0xff9e };
                mappings[0x309a] = new[] { 0xff9f };

                if (forwardOptions.ConvertHiraganas)
                {
                    foreach (var kvp in HiraganaTable)
                    {
                        mappings[kvp.Key] = kvp.Value;
                    }
                }
            }
        }

        return mappings;
    }

    private Dictionary<int, int> BuildReverseMappings()
    {
        var mappings = new Dictionary<int, int>();

        if (this.reverseOptions is ReverseOptions reverseOptions)
        {
            if (reverseOptions.ConvertGL)
            {
                foreach (var kvp in Jisx0201GLTable)
                {
                    mappings[kvp.Value] = kvp.Key;
                }

                // Handle overrides
                if (reverseOptions.U005cAsYenSign)
                {
                    mappings[0x005c] = 0xffe5;
                }

                if (reverseOptions.U005cAsBackslash)
                {
                    mappings[0x005c] = 0xff3c;
                }

                if (reverseOptions.U007eAsFullwidthTilde)
                {
                    mappings[0x007e] = 0xff5e;
                }

                if (reverseOptions.U007eAsWaveDash)
                {
                    mappings[0x007e] = 0x301c;
                }

                if (reverseOptions.U007eAsOverline)
                {
                    mappings[0x007e] = 0x203e;
                }

                if (reverseOptions.U007eAsFullwidthMacron)
                {
                    mappings[0x007e] = 0xffe3;
                }

                if (reverseOptions.U00a5AsYenSign)
                {
                    mappings[0x00a5] = 0xffe5;
                }

                if (reverseOptions.ConvertUnsafeSpecials)
                {
                    foreach (var kvp in SpecialPunctuationsTable)
                    {
                        mappings[kvp.Value] = kvp.Key;
                    }
                }
            }

            if (reverseOptions.ConvertGR)
            {
                foreach (var kvp in Jisx0201GRTable)
                {
                    mappings[kvp.Value] = kvp.Key;
                }
            }
        }

        return mappings;
    }

    private class ForwardCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {
        private readonly Dictionary<int, int[]> forwardMappings;
        private readonly IEnumerator<Character> input;
        private readonly Queue<Character> pending = new();
        private int offset;
        private bool disposed;

        public ForwardCharEnumerator(Dictionary<int, int[]> mappings, IEnumerator<Character> input)
        {
            this.forwardMappings = mappings;
            this.input = input;
        }

        public Character Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => this.Current;

        public bool MoveNext()
        {
            if (this.disposed)
            {
                return false;
            }

            // Handle pending characters first
            if (this.pending.Count > 0)
            {
                this.Current = this.pending.Dequeue().WithOffset(this.offset);
                this.offset += this.Current.CharCount;
                return true;
            }

            if (!this.input.MoveNext())
            {
                return false;
            }

            var c = this.input.Current;

            if (c.IsSentinel)
            {
                this.Current = c.WithOffset(this.offset);
                return true;
            }

            if (c.CodePoint.Size() != 1)
            {
                this.Current = c.WithOffset(this.offset);
                this.offset += this.Current.CharCount;
                return true;
            }

            int codePoint = c.CodePoint.First;

            // Convert fullwidth to halfwidth
            if (this.forwardMappings!.TryGetValue(codePoint, out var mapped))
            {
                if (mapped.Length == 1)
                {
                    this.Current = new Character((mapped[0], -1), this.offset, c);
                    this.offset += this.Current.CharCount;
                    return true;
                }

                // Multi-character mapping
                for (int i = 0; i < mapped.Length; i++)
                {
                    var newChar = new Character((mapped[i], -1), 0, c);
                    if (i == 0)
                    {
                        this.Current = newChar.WithOffset(this.offset);
                        this.offset += this.Current.CharCount;
                    }
                    else
                    {
                        this.pending.Enqueue(newChar);
                    }
                }

                return true;
            }

            // No mapping found, return original
            this.Current = c.WithOffset(this.offset);
            this.offset += this.Current.CharCount;
            return true;
        }

        public void Reset()
        {
            this.input.Reset();
            this.pending.Clear();
            this.offset = 0;
        }

        public void Dispose()
        {
            if (!this.disposed)
            {
                this.input?.Dispose();
                this.disposed = true;
            }
        }

        public IEnumerator<Character> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }

    private class ReverseCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {
        private readonly Dictionary<int, int> reverseMappings;
        private readonly IEnumerator<Character> input;
        private readonly ReverseOptions options;
        private Character? pending;
        private int offset;
        private bool disposed;

        public ReverseCharEnumerator(Dictionary<int, int> reverseMappings, IEnumerator<Character> input, ReverseOptions options)
        {
            this.reverseMappings = reverseMappings;
            this.input = input;
            this.options = options;
        }

        public Character Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => this.Current;

        public bool MoveNext()
        {
            if (this.disposed)
            {
                return false;
            }

            Character c;
            if (this.pending != null)
            {
                c = this.pending!;
                this.pending = null;
            }
            else
            {
                if (!this.input.MoveNext())
                {
                    return false;
                }

                c = this.input.Current;
            }

            if (c.IsSentinel)
            {
                this.Current = c.WithOffset(this.offset);
                return true;
            }

            if (c.CodePoint.Size() != 1)
            {
                this.Current = c.WithOffset(this.offset);
                this.offset += this.Current.CharCount;
                return true;
            }

            int codePoint = c.CodePoint.First;

            // Check for potential voice mark combination (halfwidth to fullwidth)
            if (this.options.CombineVoicedSoundMarks && this.TryHandleVoiceMarkCombination(c, codePoint))
            {
                return true;
            }

            // Convert halfwidth to fullwidth
            if (this.reverseMappings!.TryGetValue(codePoint, out var mapped))
            {
                this.Current = new Character((mapped, -1), this.offset, c);
                this.offset += this.Current.CharCount;
                return true;
            }

            // No mapping found, return original
            this.Current = c.WithOffset(this.offset);
            this.offset += this.Current.CharCount;
            return true;
        }

        private bool TryHandleVoiceMarkCombination(Character c, int codePoint)
        {
            // Check if this is a halfwidth katakana that can take voice marks
            if (!this.IsHalfwidthKatakanaBase(codePoint))
            {
                return false;
            }

            // Look ahead for voice marks
            if (this.input.MoveNext())
            {
                var nextChar = this.input.Current;
                if (nextChar.CodePoint.Size() == 1)
                {
                    int nextCodePoint = nextChar.CodePoint.First;

                    // Check for voice marks
                    if (nextCodePoint == 0xff9e || nextCodePoint == 0xff9f) // ﾞ or ﾟ
                    {
                        // Combine them into voiced/semi-voiced form
                        int combinedCodePoint = this.GetVoicedForm(codePoint, nextCodePoint);
                        if (combinedCodePoint != 0)
                        {
                            this.Current = new Character((combinedCodePoint, -1), this.offset, c);
                            this.offset += this.Current.CharCount;
                            return true;
                        }
                    }
                }

                // No combination possible, put back the next character
                this.pending = nextChar;
            }

            return false;
        }

        private bool IsHalfwidthKatakanaBase(int codePoint)
        {
            return (codePoint >= 0xff76 && codePoint <= 0xff84) || // カ-ト
                   (codePoint >= 0xff8a && codePoint <= 0xff8e) || // ハ-ホ
                   codePoint == 0xff73; // ウ
        }

        private int GetVoicedForm(int baseCodePoint, int voiceMarkCodePoint)
        {
            // Map halfwidth katakana + voice mark to fullwidth voiced form
            if (voiceMarkCodePoint == 0xff9e) // ﾞ (voiced)
            {
                return baseCodePoint switch
                {
                    0xff76 => 0x30ac, // ｶ + ﾞ -> ガ
                    0xff77 => 0x30ae, // ｷ + ﾞ -> ギ
                    0xff78 => 0x30b0, // ｸ + ﾞ -> グ
                    0xff79 => 0x30b2, // ｹ + ﾞ -> ゲ
                    0xff7a => 0x30b4, // ｺ + ﾞ -> ゴ
                    0xff7b => 0x30b6, // ｻ + ﾞ -> ザ
                    0xff7c => 0x30b8, // ｼ + ﾞ -> ジ
                    0xff7d => 0x30ba, // ｽ + ﾞ -> ズ
                    0xff7e => 0x30bc, // ｾ + ﾞ -> ゼ
                    0xff7f => 0x30be, // ｿ + ﾞ -> ゾ
                    0xff80 => 0x30c0, // ﾀ + ﾞ -> ダ
                    0xff81 => 0x30c2, // ﾁ + ﾞ -> ヂ
                    0xff82 => 0x30c5, // ﾂ + ﾞ -> ヅ
                    0xff83 => 0x30c7, // ﾃ + ﾞ -> デ
                    0xff84 => 0x30c9, // ﾄ + ﾞ -> ド
                    0xff8a => 0x30d0, // ﾊ + ﾞ -> バ
                    0xff8b => 0x30d3, // ﾋ + ﾞ -> ビ
                    0xff8c => 0x30d6, // ﾌ + ﾞ -> ブ
                    0xff8d => 0x30d9, // ﾍ + ﾞ -> ベ
                    0xff8e => 0x30dc, // ﾎ + ﾞ -> ボ
                    0xff73 => 0x30f4, // ｳ + ﾞ -> ヴ
                    _ => 0,
                };
            }
            else if (voiceMarkCodePoint == 0xff9f) // ﾟ (semi-voiced)
            {
                return baseCodePoint switch
                {
                    0xff8a => 0x30d1, // ﾊ + ﾟ -> パ
                    0xff8b => 0x30d4, // ﾋ + ﾟ -> ピ
                    0xff8c => 0x30d7, // ﾌ + ﾟ -> プ
                    0xff8d => 0x30da, // ﾍ + ﾟ -> ペ
                    0xff8e => 0x30dd, // ﾎ + ﾟ -> ポ
                    _ => 0,
                };
            }

            return 0;
        }

        public void Reset()
        {
            this.input.Reset();
            this.pending = null;
            this.offset = 0;
        }

        public void Dispose()
        {
            if (!this.disposed)
            {
                this.input?.Dispose();
                this.disposed = true;
            }
        }

        public IEnumerator<Character> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }
}
