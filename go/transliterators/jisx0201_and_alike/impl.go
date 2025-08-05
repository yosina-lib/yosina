package jisx0201_and_alike

import (
	"sync"

	yosina "github.com/yosina-lib/yosina/go"
)

var jisx0201GLTable = map[rune]rune{
	'\u3000': '\u0020', // 　 -> space
	'\uff01': '\u0021', // ！ -> !
	'\uff02': '\u0022', // ＂ -> "
	'\uff03': '\u0023', // ＃ -> #
	'\uff04': '\u0024', // ＄ -> $
	'\uff05': '\u0025', // ％ -> %
	'\uff06': '\u0026', // ＆ -> &
	'\uff07': '\u0027', // ＇ -> '
	'\uff08': '\u0028', // （ -> (
	'\uff09': '\u0029', // ） -> )
	'\uff0a': '\u002a', // ＊ -> *
	'\uff0b': '\u002b', // ＋ -> +
	'\uff0c': '\u002c', // ， -> ,
	'\uff0d': '\u002d', // － -> -
	'\uff0e': '\u002e', // ． -> .
	'\uff0f': '\u002f', // ／ -> /
	'\uff10': '\u0030', // ０ -> 0
	'\uff11': '\u0031', // １ -> 1
	'\uff12': '\u0032', // ２ -> 2
	'\uff13': '\u0033', // ３ -> 3
	'\uff14': '\u0034', // ４ -> 4
	'\uff15': '\u0035', // ５ -> 5
	'\uff16': '\u0036', // ６ -> 6
	'\uff17': '\u0037', // ７ -> 7
	'\uff18': '\u0038', // ８ -> 8
	'\uff19': '\u0039', // ９ -> 9
	'\uff1a': '\u003a', // ： -> :
	'\uff1b': '\u003b', // ； -> ;
	'\uff1c': '\u003c', // ＜ -> <
	'\uff1d': '\u003d', // ＝ -> =
	'\uff1e': '\u003e', // ＞ -> >
	'\uff1f': '\u003f', // ？ -> ?
	'\uff20': '\u0040', // ＠ -> @
	'\uff21': '\u0041', // Ａ -> A
	'\uff22': '\u0042', // Ｂ -> B
	'\uff23': '\u0043', // Ｃ -> C
	'\uff24': '\u0044', // Ｄ -> D
	'\uff25': '\u0045', // Ｅ -> E
	'\uff26': '\u0046', // Ｆ -> F
	'\uff27': '\u0047', // Ｇ -> G
	'\uff28': '\u0048', // Ｈ -> H
	'\uff29': '\u0049', // Ｉ -> I
	'\uff2a': '\u004a', // Ｊ -> J
	'\uff2b': '\u004b', // Ｋ -> K
	'\uff2c': '\u004c', // Ｌ -> L
	'\uff2d': '\u004d', // Ｍ -> M
	'\uff2e': '\u004e', // Ｎ -> N
	'\uff2f': '\u004f', // Ｏ -> O
	'\uff30': '\u0050', // Ｐ -> P
	'\uff31': '\u0051', // Ｑ -> Q
	'\uff32': '\u0052', // Ｒ -> R
	'\uff33': '\u0053', // Ｓ -> S
	'\uff34': '\u0054', // Ｔ -> T
	'\uff35': '\u0055', // Ｕ -> U
	'\uff36': '\u0056', // Ｖ -> V
	'\uff37': '\u0057', // Ｗ -> W
	'\uff38': '\u0058', // Ｘ -> X
	'\uff39': '\u0059', // Ｙ -> Y
	'\uff3a': '\u005a', // Ｚ -> Z
	'\uff3b': '\u005b', // ［ -> [
	'\uff3d': '\u005d', // ］ -> ]
	'\uff3e': '\u005e', // ＾ -> ^
	'\uff3f': '\u005f', // ＿ -> _
	'\uff40': '\u0060', // ｀ -> `
	'\uff41': '\u0061', // ａ -> a
	'\uff42': '\u0062', // ｂ -> b
	'\uff43': '\u0063', // ｃ -> c
	'\uff44': '\u0064', // ｄ -> d
	'\uff45': '\u0065', // ｅ -> e
	'\uff46': '\u0066', // ｆ -> f
	'\uff47': '\u0067', // ｇ -> g
	'\uff48': '\u0068', // ｈ -> h
	'\uff49': '\u0069', // ｉ -> i
	'\uff4a': '\u006a', // ｊ -> j
	'\uff4b': '\u006b', // ｋ -> k
	'\uff4c': '\u006c', // ｌ -> l
	'\uff4d': '\u006d', // ｍ -> m
	'\uff4e': '\u006e', // ｎ -> n
	'\uff4f': '\u006f', // ｏ -> o
	'\uff50': '\u0070', // ｐ -> p
	'\uff51': '\u0071', // ｑ -> q
	'\uff52': '\u0072', // ｒ -> r
	'\uff53': '\u0073', // ｓ -> s
	'\uff54': '\u0074', // ｔ -> t
	'\uff55': '\u0075', // ｕ -> u
	'\uff56': '\u0076', // ｖ -> v
	'\uff57': '\u0077', // ｗ -> w
	'\uff58': '\u0078', // ｘ -> x
	'\uff59': '\u0079', // ｙ -> y
	'\uff5a': '\u007a', // ｚ -> z
	'\uff5b': '\u007b', // ｛ -> {
	'\uff5c': '\u007c', // ｜ -> |
	'\uff5d': '\u007d', // ｝ -> }
}

var jisx0201GRTable = map[rune]rune{
	'\u3002': '\uff61', // 。 -> ｡
	'\u300c': '\uff62', // 「 -> ｢
	'\u300d': '\uff63', // 」 -> ｣
	'\u3001': '\uff64', // 、 -> ､
	'\u30fb': '\uff65', // ・ -> ･
	'\u30fc': '\uff70', // ー -> ｰ
	'\u309b': '\uff9e', // ゛ -> ﾞ
	'\u309c': '\uff9f', // ゜-> ﾟ

	'\u30a1': '\uff67', // ァ -> ｧ
	'\u30a3': '\uff68', // ィ -> ｨ
	'\u30a5': '\uff69', // ゥ -> ｩ
	'\u30a7': '\uff6a', // ェ -> ｪ
	'\u30a9': '\uff6b', // ォ -> ｫ
	'\u30e3': '\uff6c', // ャ -> ｬ
	'\u30e5': '\uff6d', // ュ -> ｭ
	'\u30e7': '\uff6e', // ョ -> ｮ
	'\u30c3': '\uff6f', // ッ -> ｯ

	'\u30a2': '\uff71', // ア -> ｱ
	'\u30a4': '\uff72', // イ -> ｲ
	'\u30a6': '\uff73', // ウ -> ｳ
	'\u30a8': '\uff74', // エ -> ｴ
	'\u30aa': '\uff75', // オ -> ｵ

	'\u30ab': '\uff76', // カ -> ｶ
	'\u30ad': '\uff77', // キ -> ｷ
	'\u30af': '\uff78', // ク -> ｸ
	'\u30b1': '\uff79', // ケ -> ｹ
	'\u30b3': '\uff7a', // コ -> ｺ

	'\u30b5': '\uff7b', // サ -> ｻ
	'\u30b7': '\uff7c', // シ -> ｼ
	'\u30b9': '\uff7d', // ス -> ｽ
	'\u30bb': '\uff7e', // セ -> ｾ
	'\u30bd': '\uff7f', // ソ -> ｿ

	'\u30bf': '\uff80', // タ -> ﾀ
	'\u30c1': '\uff81', // チ -> ﾁ
	'\u30c4': '\uff82', // ツ -> ﾂ
	'\u30c6': '\uff83', // テ -> ﾃ
	'\u30c8': '\uff84', // ト -> ﾄ

	'\u30ca': '\uff85', // ナ -> ﾅ
	'\u30cb': '\uff86', // ニ -> ﾆ
	'\u30cc': '\uff87', // ヌ -> ﾇ
	'\u30cd': '\uff88', // ネ -> ﾈ
	'\u30ce': '\uff89', // ノ -> ﾉ

	'\u30cf': '\uff8a', // ハ -> ﾊ
	'\u30d2': '\uff8b', // ヒ -> ﾋ
	'\u30d5': '\uff8c', // フ -> ﾌ
	'\u30d8': '\uff8d', // ヘ -> ﾍ
	'\u30db': '\uff8e', // ホ -> ﾎ

	'\u30de': '\uff8f', // マ -> ﾏ
	'\u30df': '\uff90', // ミ -> ﾐ
	'\u30e0': '\uff91', // ム -> ﾑ
	'\u30e1': '\uff92', // メ -> ﾒ
	'\u30e2': '\uff93', // モ -> ﾓ

	'\u30e4': '\uff94', // ヤ -> ﾔ
	'\u30e6': '\uff95', // ユ -> ﾕ
	'\u30e8': '\uff96', // ヨ -> ﾖ

	'\u30e9': '\uff97', // ラ -> ﾗ
	'\u30ea': '\uff98', // リ -> ﾘ
	'\u30eb': '\uff99', // ル -> ﾙ
	'\u30ec': '\uff9a', // レ -> ﾚ
	'\u30ed': '\uff9b', // ロ -> ﾛ

	'\u30ef': '\uff9c', // ワ -> ﾜ
	'\u30f3': '\uff9d', // ン -> ﾝ
	'\u30f2': '\uff66', // ヲ -> ｦ
}

var voicedLettersTable = map[rune][2]rune{
	'\u30f4': {'\uff73', '\uff9e'}, // ヴ -> ｳﾞ
	'\u30ac': {'\uff76', '\uff9e'}, // ガ -> ｶﾞ
	'\u30ae': {'\uff77', '\uff9e'}, // ギ -> ｷﾞ
	'\u30b0': {'\uff78', '\uff9e'}, // グ -> ｸﾞ
	'\u30b2': {'\uff79', '\uff9e'}, // ゲ -> ｹﾞ
	'\u30b4': {'\uff7a', '\uff9e'}, // ゴ -> ｺﾞ
	'\u30b6': {'\uff7b', '\uff9e'}, // ザ -> ｻﾞ
	'\u30b8': {'\uff7c', '\uff9e'}, // ジ -> ｼﾞ
	'\u30ba': {'\uff7d', '\uff9e'}, // ズ -> ｽﾞ
	'\u30bc': {'\uff7e', '\uff9e'}, // ゼ -> ｾﾞ
	'\u30be': {'\uff7f', '\uff9e'}, // ゾ -> ｿﾞ
	'\u30c0': {'\uff80', '\uff9e'}, // ダ -> ﾀﾞ
	'\u30c2': {'\uff81', '\uff9e'}, // ヂ -> ﾁﾞ
	'\u30c5': {'\uff82', '\uff9e'}, // ヅ -> ﾂﾞ
	'\u30c7': {'\uff83', '\uff9e'}, // デ -> ﾃﾞ
	'\u30c9': {'\uff84', '\uff9e'}, // ド -> ﾄﾞ
	'\u30d0': {'\uff8a', '\uff9e'}, // バ -> ﾊﾞ
	'\u30d3': {'\uff8b', '\uff9e'}, // ビ -> ﾋﾞ
	'\u30d6': {'\uff8c', '\uff9e'}, // ブ -> ﾌﾞ
	'\u30d9': {'\uff8d', '\uff9e'}, // ベ -> ﾍﾞ
	'\u30dc': {'\uff8e', '\uff9e'}, // ボ -> ﾎﾞ
	'\u30d1': {'\uff8a', '\uff9f'}, // パ -> ﾊﾟ
	'\u30d4': {'\uff8b', '\uff9f'}, // ピ -> ﾋﾟ
	'\u30d7': {'\uff8c', '\uff9f'}, // プ -> ﾌﾟ
	'\u30da': {'\uff8d', '\uff9f'}, // ペ -> ﾍﾟ
	'\u30dd': {'\uff8e', '\uff9f'}, // ポ -> ﾎﾟ
	'\u30fa': {'\uff66', '\uff9e'}, // ヺ -> ｦﾞ
}

var hiraganaTable = map[rune][2]rune{
	'\u3041': {'\uff67', yosina.InvalidUnicodeValue}, // ぁ -> ｧ
	'\u3043': {'\uff68', yosina.InvalidUnicodeValue}, // ぃ -> ｨ
	'\u3045': {'\uff69', yosina.InvalidUnicodeValue}, // ぅ -> ｩ
	'\u3047': {'\uff6a', yosina.InvalidUnicodeValue}, // ぇ -> ｪ
	'\u3049': {'\uff6b', yosina.InvalidUnicodeValue}, // ぉ -> ｫ
	'\u3083': {'\uff6c', yosina.InvalidUnicodeValue}, // ゃ -> ｬ
	'\u3085': {'\uff6d', yosina.InvalidUnicodeValue}, // ゅ -> ｭ
	'\u3087': {'\uff6e', yosina.InvalidUnicodeValue}, // ょ -> ｮ
	'\u3063': {'\uff6f', yosina.InvalidUnicodeValue}, // っ -> ｯ
	'\u3042': {'\uff71', yosina.InvalidUnicodeValue}, // あ -> ｱ
	'\u3044': {'\uff72', yosina.InvalidUnicodeValue}, // い -> ｲ
	'\u3046': {'\uff73', yosina.InvalidUnicodeValue}, // う -> ｳ
	'\u3048': {'\uff74', yosina.InvalidUnicodeValue}, // え -> ｴ
	'\u304a': {'\uff75', yosina.InvalidUnicodeValue}, // お -> ｵ
	'\u304b': {'\uff76', yosina.InvalidUnicodeValue}, // か -> ｶ
	'\u304d': {'\uff77', yosina.InvalidUnicodeValue}, // き -> ｷ
	'\u304f': {'\uff78', yosina.InvalidUnicodeValue}, // く -> ｸ
	'\u3051': {'\uff79', yosina.InvalidUnicodeValue}, // け -> ｹ
	'\u3053': {'\uff7a', yosina.InvalidUnicodeValue}, // こ -> ｺ
	'\u3055': {'\uff7b', yosina.InvalidUnicodeValue}, // さ -> ｻ
	'\u3057': {'\uff7c', yosina.InvalidUnicodeValue}, // し -> ｼ
	'\u3059': {'\uff7d', yosina.InvalidUnicodeValue}, // す -> ｽ
	'\u305b': {'\uff7e', yosina.InvalidUnicodeValue}, // せ -> ｾ
	'\u305d': {'\uff7f', yosina.InvalidUnicodeValue}, // そ -> ｿ
	'\u305f': {'\uff80', yosina.InvalidUnicodeValue}, // た -> ﾀ
	'\u3061': {'\uff81', yosina.InvalidUnicodeValue}, // ち -> ﾁ
	'\u3064': {'\uff82', yosina.InvalidUnicodeValue}, // つ -> ﾂ
	'\u3066': {'\uff83', yosina.InvalidUnicodeValue}, // て -> ﾃ
	'\u3068': {'\uff84', yosina.InvalidUnicodeValue}, // と -> ﾄ
	'\u306a': {'\uff85', yosina.InvalidUnicodeValue}, // な -> ﾅ
	'\u306b': {'\uff86', yosina.InvalidUnicodeValue}, // に -> ﾆ
	'\u306c': {'\uff87', yosina.InvalidUnicodeValue}, // ぬ -> ﾇ
	'\u306d': {'\uff88', yosina.InvalidUnicodeValue}, // ね -> ﾈ
	'\u306e': {'\uff89', yosina.InvalidUnicodeValue}, // の -> ﾉ
	'\u306f': {'\uff8a', yosina.InvalidUnicodeValue}, // は -> ﾊ
	'\u3072': {'\uff8b', yosina.InvalidUnicodeValue}, // ひ -> ﾋ
	'\u3075': {'\uff8c', yosina.InvalidUnicodeValue}, // ふ -> ﾌ
	'\u3078': {'\uff8d', yosina.InvalidUnicodeValue}, // へ -> ﾍ
	'\u307b': {'\uff8e', yosina.InvalidUnicodeValue}, // ほ -> ﾎ
	'\u307e': {'\uff8f', yosina.InvalidUnicodeValue}, // ま -> ﾏ
	'\u307f': {'\uff90', yosina.InvalidUnicodeValue}, // み -> ﾐ
	'\u3080': {'\uff91', yosina.InvalidUnicodeValue}, // む -> ﾑ
	'\u3081': {'\uff92', yosina.InvalidUnicodeValue}, // め -> ﾒ
	'\u3082': {'\uff93', yosina.InvalidUnicodeValue}, // も -> ﾓ
	'\u3084': {'\uff94', yosina.InvalidUnicodeValue}, // や -> ﾔ
	'\u3086': {'\uff95', yosina.InvalidUnicodeValue}, // ゆ -> ﾕ
	'\u3088': {'\uff96', yosina.InvalidUnicodeValue}, // よ -> ﾖ
	'\u3089': {'\uff97', yosina.InvalidUnicodeValue}, // ら -> ﾗ
	'\u308a': {'\uff98', yosina.InvalidUnicodeValue}, // り -> ﾘ
	'\u308b': {'\uff99', yosina.InvalidUnicodeValue}, // る -> ﾙ
	'\u308c': {'\uff9a', yosina.InvalidUnicodeValue}, // れ -> ﾚ
	'\u308d': {'\uff9b', yosina.InvalidUnicodeValue}, // ろ -> ﾛ
	'\u308f': {'\uff9c', yosina.InvalidUnicodeValue}, // わ -> ﾜ
	'\u3092': {'\uff66', yosina.InvalidUnicodeValue}, // を -> ｦ
	'\u3093': {'\uff9d', yosina.InvalidUnicodeValue}, // ん -> ﾝ
	'\u3094': {'\uff73', '\uff9e'},                   // ゔ -> ｳﾞ
	'\u304c': {'\uff76', '\uff9e'},                   // が -> ｶﾞ
	'\u304e': {'\uff77', '\uff9e'},                   // ぎ -> ｷﾞ
	'\u3050': {'\uff78', '\uff9e'},                   // ぐ -> ｸﾞ
	'\u3052': {'\uff79', '\uff9e'},                   // げ -> ｹﾞ
	'\u3054': {'\uff7a', '\uff9e'},                   // ご -> ｺﾞ
	'\u3056': {'\uff7b', '\uff9e'},                   // ざ -> ｻﾞ
	'\u3058': {'\uff7c', '\uff9e'},                   // じ -> ｼﾞ
	'\u305a': {'\uff7d', '\uff9e'},                   // ず -> ｽﾞ
	'\u305c': {'\uff7e', '\uff9e'},                   // ぜ -> ｾﾞ
	'\u305e': {'\uff7f', '\uff9e'},                   // ぞ -> ｿﾞ
	'\u3060': {'\uff80', '\uff9e'},                   // だ -> ﾀﾞ
	'\u3062': {'\uff81', '\uff9e'},                   // ぢ -> ﾁﾞ
	'\u3065': {'\uff82', '\uff9e'},                   // づ -> ﾂﾞ
	'\u3067': {'\uff83', '\uff9e'},                   // で -> ﾃﾞ
	'\u3069': {'\uff84', '\uff9e'},                   // ど -> ﾄﾞ
	'\u3070': {'\uff8a', '\uff9e'},                   // ば -> ﾊﾞ
	'\u3073': {'\uff8b', '\uff9e'},                   // び -> ﾋﾞ
	'\u3076': {'\uff8c', '\uff9e'},                   // ぶ -> ﾌﾞ
	'\u3079': {'\uff8d', '\uff9e'},                   // べ -> ﾍﾞ
	'\u307c': {'\uff8e', '\uff9e'},                   // ぼ -> ﾎﾞ
	'\u3071': {'\uff8a', '\uff9f'},                   // ぱ -> ﾊﾟ
	'\u3074': {'\uff8b', '\uff9f'},                   // ぴ -> ﾋﾟ
	'\u3077': {'\uff8c', '\uff9f'},                   // ぷ -> ﾌﾟ
	'\u307a': {'\uff8d', '\uff9f'},                   // ぺ -> ﾍﾟ
	'\u307d': {'\uff8e', '\uff9f'},                   // ぽ -> ﾎﾟ
}

var specialPunctuationsTable = map[rune]rune{
	'\u30a0': '\u003d', // ゠ -> =
}

type Ternary int

const (
	TernaryUnknown Ternary = 0
	// TernaryFalse represents a false value in a ternary context.
	TernaryFalse = 2
	// TernaryTrue represents a true value in a ternary context.
	TernaryTrue = 3
)

func (t Ternary) IsValid() bool {
	return t&2 != 0
}

func (t Ternary) IsTrue() bool {
	return t == 3
}

func (t Ternary) UnwrapOr(v bool) bool {
	if t.IsValid() {
		return t.IsTrue()
	}
	return v
}

func (t Ternary) UnwrapOrElse(f func() bool) bool {
	if t.IsValid() {
		return t.IsTrue()
	}
	return f()
}

func TernaryOf(v bool) Ternary {
	if v {
		return TernaryTrue
	}
	return TernaryFalse
}

type Options struct {
	FullwidthToHalfwidth    bool
	ConvertGL               bool
	ConvertGR               bool
	ConvertUnsafeSpecials   Ternary
	ConvertHiraganas        bool
	CombineVoicedSoundMarks bool
	U005cAsYenSign          Ternary
	U005cAsBackslash        Ternary
	U007eAsFullwidthTilde   Ternary
	U007eAsWaveDash         Ternary
	U007eAsOverline         Ternary
	U007eAsFullwidthMacron  Ternary
	U00a5AsYenSign          Ternary
}

func Default() Options {
	return Options{
		FullwidthToHalfwidth:    true,
		ConvertGL:               true,
		ConvertGR:               true,
		ConvertUnsafeSpecials:   TernaryUnknown,
		ConvertHiraganas:        false,
		CombineVoicedSoundMarks: true,
		U005cAsYenSign:          TernaryUnknown,
		U005cAsBackslash:        TernaryUnknown,
		U007eAsFullwidthTilde:   TernaryUnknown,
		U007eAsWaveDash:         TernaryUnknown,
		U007eAsOverline:         TernaryUnknown,
		U007eAsFullwidthMacron:  TernaryUnknown,
		U00a5AsYenSign:          TernaryUnknown,
	}
}

func (o Options) WithFullwidthToHalfwidth(v bool) Options {
	o.FullwidthToHalfwidth = v
	return o
}

func (o Options) WithConvertGL(v bool) Options {
	o.ConvertGL = v
	return o
}

func (o Options) WithConvertGR(v bool) Options {
	o.ConvertGR = v
	return o
}

func (o Options) WithConvertUnsafeSpecials(v bool) Options {
	o.ConvertUnsafeSpecials = TernaryOf(v)
	return o
}

func (o Options) WithConvertHiraganas(v bool) Options {
	o.ConvertHiraganas = v
	return o
}

func (o Options) WithCombineVoicedSoundMarks(v bool) Options {
	o.CombineVoicedSoundMarks = v
	return o
}

func (o Options) WithU005cAsYenSign(v bool) Options {
	o.U005cAsYenSign = TernaryOf(v)
	return o
}

func (o Options) WithU005cAsBackslash(v bool) Options {
	o.U005cAsBackslash = TernaryOf(v)
	return o
}

func (o Options) WithU007eAsFullwidthTilde(v bool) Options {
	o.U007eAsFullwidthTilde = TernaryOf(v)
	return o
}

func (o Options) WithU007eAsWaveDash(v bool) Options {
	o.U007eAsWaveDash = TernaryOf(v)
	return o
}

func (o Options) WithU007eAsOverline(v bool) Options {
	o.U007eAsOverline = TernaryOf(v)
	return o
}

func (o Options) WithU007eAsFullwidthMacron(v bool) Options {
	o.U007eAsFullwidthMacron = TernaryOf(v)
	return o
}

func (o Options) WithU00a5AsYenSign(v bool) Options {
	o.U00a5AsYenSign = TernaryOf(v)
	return o
}

type fwdOptions struct {
	ConvertGL              bool
	ConvertGR              bool
	ConvertUnsafeSpecials  bool
	ConvertHiraganas       bool
	U005cAsYenSign         bool
	U005cAsBackslash       bool
	U007eAsFullwidthTilde  bool
	U007eAsWaveDash        bool
	U007eAsOverline        bool
	U007eAsFullwidthMacron bool
	U00a5AsYenSign         bool
}

type revOptions struct {
	ConvertGL               bool
	ConvertGR               bool
	ConvertUnsafeSpecials   bool
	CombineVoicedSoundMarks bool
	U005cAsYenSign          bool
	U005cAsBackslash        bool
	U007eAsFullwidthTilde   bool
	U007eAsWaveDash         bool
	U007eAsOverline         bool
	U007eAsFullwidthMacron  bool
	U00a5AsYenSign          bool
}

func (o *Options) fwdOptions() fwdOptions {
	return fwdOptions{
		ConvertGL:              o.ConvertGL,
		ConvertGR:              o.ConvertGR,
		ConvertUnsafeSpecials:  o.ConvertUnsafeSpecials.UnwrapOr(true),
		ConvertHiraganas:       o.ConvertHiraganas,
		U005cAsYenSign:         o.U005cAsYenSign.UnwrapOrElse(func() bool { return !o.U00a5AsYenSign.IsValid() }),
		U005cAsBackslash:       o.U005cAsBackslash.UnwrapOr(false),
		U007eAsFullwidthTilde:  o.U007eAsFullwidthTilde.UnwrapOr(true),
		U007eAsWaveDash:        o.U007eAsWaveDash.UnwrapOr(true),
		U007eAsOverline:        o.U007eAsOverline.UnwrapOr(false),
		U007eAsFullwidthMacron: o.U007eAsFullwidthMacron.UnwrapOr(false),
		U00a5AsYenSign:         o.U00a5AsYenSign.UnwrapOr(false),
	}
}

func (o *Options) revOptions() revOptions {
	return revOptions{
		ConvertGL:               o.ConvertGL,
		ConvertGR:               o.ConvertGR,
		ConvertUnsafeSpecials:   o.ConvertUnsafeSpecials.UnwrapOr(false),
		CombineVoicedSoundMarks: o.CombineVoicedSoundMarks,
		U005cAsYenSign:          o.U005cAsYenSign.UnwrapOrElse(func() bool { return !o.U005cAsBackslash.IsValid() }),
		U005cAsBackslash:        o.U005cAsBackslash.UnwrapOr(false),
		U007eAsFullwidthTilde: o.U007eAsFullwidthTilde.UnwrapOrElse(func() bool {
			return !o.U007eAsWaveDash.IsValid() && !o.U007eAsOverline.IsValid() && !o.U007eAsFullwidthMacron.IsValid()
		}),
		U007eAsWaveDash:        o.U007eAsWaveDash.UnwrapOr(false),
		U007eAsOverline:        o.U007eAsOverline.UnwrapOr(false),
		U007eAsFullwidthMacron: o.U007eAsFullwidthMacron.UnwrapOr(false),
		U00a5AsYenSign:         o.U00a5AsYenSign.UnwrapOr(true),
	}
}

// fullwidthToHalfwidthIterator implements yosina.CharIterator for fullwidth to halfwidth conversion.
// It handles multi-character mappings and uses a mapping table for character conversion.
type fullwidthToHalfwidthIterator struct {
	yosina.CharIterator
	options  fwdOptions
	mappings map[rune][2]rune
	offset   int
	pending  rune
	c        *yosina.Char
}

func (i *fullwidthToHalfwidthIterator) Next() *yosina.Char {
	if i.pending != yosina.InvalidUnicodeValue {
		c := &yosina.Char{
			C:      [2]rune{i.pending, yosina.InvalidUnicodeValue},
			Offset: i.offset,
			Source: i.c,
		}
		i.pending = yosina.InvalidUnicodeValue
		i.offset += c.RuneLen()
		return c
	}

	c := i.CharIterator.Next()
	if c == nil {
		return nil
	}
	if c.C[0] == yosina.InvalidUnicodeValue {
		return c.WithOffset(i.offset)
	}

	// Convert fullwidth to halfwidth
	if mapped, ok := i.mappings[c.C[0]]; ok {
		// Multi-character mapping
		if mapped[1] != yosina.InvalidUnicodeValue {
			i.pending = mapped[1]
			i.c = c
		}
		c := &yosina.Char{
			C:      [2]rune{mapped[0], yosina.InvalidUnicodeValue},
			Offset: i.offset,
			Source: c,
		}
		i.offset += c.RuneLen()
		return c
	}

	return c
}

type revMappings struct {
	nonvoiced map[rune]rune
	voiced    map[rune]map[rune]rune
}

// halfwidthToFullwidthIterator implements yosina.CharIterator for halfwidth to fullwidth conversion.
// It handles voiced sound mark combinations and regular character mappings.
type halfwidthToFullwidthIterator struct {
	yosina.CharIterator
	options  revOptions
	mappings revMappings
	offset   int
	pending  *yosina.Char
}

func (i *halfwidthToFullwidthIterator) Next() *yosina.Char {
	var c *yosina.Char
	if i.pending != nil {
		c = i.pending
		i.pending = nil
	} else {
		c = i.CharIterator.Next()
		if c == nil {
			return nil
		}
	}

	if c.C[0] == yosina.InvalidUnicodeValue {
		return c.WithOffset(i.offset)
	}

	// Check for voiced sound mark combination
	if i.options.CombineVoicedSoundMarks && c.C[1] == yosina.InvalidUnicodeValue {
		if markMappings, ok := i.mappings.voiced[c.C[0]]; ok {
			// Look ahead for a voice mark
			next := i.CharIterator.Next()
			if next != nil && next.C[0] != yosina.InvalidUnicodeValue {
				if combined, ok := markMappings[next.C[0]]; ok {
					// Combine the characters
					c := &yosina.Char{
						C:      [2]rune{combined, yosina.InvalidUnicodeValue},
						Offset: i.offset,
						Source: c,
					}
					i.offset += c.RuneLen()
					return c
				}
			}
			// No combination possible, set next as pending
			i.pending = next
		}
	}

	// Regular mapping
	if mapped, ok := i.mappings.nonvoiced[c.C[0]]; ok {
		c := &yosina.Char{
			C:      [2]rune{mapped, yosina.InvalidUnicodeValue},
			Offset: i.offset,
			Source: c,
		}
		i.offset += c.RuneLen()
		return c
	}

	c = c.WithOffset(i.offset)
	i.offset += c.RuneLen()
	return c
}

type GuardedValue[T any] struct {
	sync.Mutex
	value T
}

var fwdMappingCache = GuardedValue[map[fwdOptions]*GuardedValue[map[rune][2]rune]]{
	sync.Mutex{},
	make(map[fwdOptions]*GuardedValue[map[rune][2]rune]),
}

func buildFwdMappings(options fwdOptions) map[rune][2]rune {
	var entry *GuardedValue[map[rune][2]rune]
	{
		fwdMappingCache.Lock()
		entry = fwdMappingCache.value[options]
		if entry != nil {
			fwdMappingCache.Unlock()
			entry.Lock()
			defer entry.Unlock()
			return entry.value
		}
		entry = &GuardedValue[map[rune][2]rune]{
			sync.Mutex{},
			make(map[rune][2]rune),
		}
		entry.Lock()
		fwdMappingCache.value[options] = entry
		fwdMappingCache.Unlock()
	}
	defer entry.Unlock()

	mappings := make(map[rune][2]rune)
	if options.ConvertGL {
		for k, v := range jisx0201GLTable {
			mappings[k] = [2]rune{v, yosina.InvalidUnicodeValue}
		}

		// Handle overrides
		if options.U005cAsYenSign {
			mappings['\uffe5'] = [2]rune{'\u005c', yosina.InvalidUnicodeValue}
		}
		if options.U005cAsBackslash {
			mappings['\uff3c'] = [2]rune{'\u005c', yosina.InvalidUnicodeValue}
		}
		if options.U007eAsFullwidthTilde {
			mappings['\uff5e'] = [2]rune{'\u007e', yosina.InvalidUnicodeValue}
		}
		if options.U007eAsWaveDash {
			mappings['\u301c'] = [2]rune{'\u007e', yosina.InvalidUnicodeValue}
		}
		if options.U007eAsOverline {
			mappings['\u203e'] = [2]rune{'\u007e', yosina.InvalidUnicodeValue}
		}
		if options.U007eAsFullwidthMacron {
			mappings['\uffe3'] = [2]rune{'\u007e', yosina.InvalidUnicodeValue}
		}
		if options.U00a5AsYenSign {
			mappings['\uffe5'] = [2]rune{'\u00a5', yosina.InvalidUnicodeValue}
		}
		if options.ConvertUnsafeSpecials {
			for k, v := range specialPunctuationsTable {
				mappings[k] = [2]rune{v, yosina.InvalidUnicodeValue}
			}
		}
	}

	if options.ConvertGR {
		for k, v := range jisx0201GRTable {
			mappings[k] = [2]rune{v, yosina.InvalidUnicodeValue}
		}
		for k, v := range voicedLettersTable {
			mappings[k] = v
		}
		mappings['\u3099'] = [2]rune{'\uff9e', yosina.InvalidUnicodeValue}
		mappings['\u309a'] = [2]rune{'\uff9f', yosina.InvalidUnicodeValue}
		if options.ConvertHiraganas {
			for k, v := range hiraganaTable {
				mappings[k] = v
			}
		}
	}

	entry.value = mappings
	return mappings
}

var revMappingCache = GuardedValue[map[revOptions]*GuardedValue[revMappings]]{
	sync.Mutex{},
	make(map[revOptions]*GuardedValue[revMappings]),
}

func buildRevMappings(options revOptions) revMappings {
	var entry *GuardedValue[revMappings]
	{
		revMappingCache.Lock()
		entry = revMappingCache.value[options]
		if entry != nil {
			revMappingCache.Unlock()
			entry.Lock()
			defer entry.Unlock()
			return entry.value
		}
		entry = &GuardedValue[revMappings]{
			sync.Mutex{},
			revMappings{
				nonvoiced: make(map[rune]rune),
				voiced:    make(map[rune]map[rune]rune),
			},
		}
		entry.Lock()
		revMappingCache.value[options] = entry
		revMappingCache.Unlock()
	}
	defer entry.Unlock()

	mappings := make(map[rune]rune)
	var voicedMappings map[rune]map[rune]rune

	if options.ConvertGL {
		for k, v := range jisx0201GLTable {
			mappings[v] = k
		}

		// Handle overrides
		if options.U005cAsYenSign {
			mappings['\u005c'] = '\uffe5'
		}
		if options.U005cAsBackslash {
			mappings['\u005c'] = '\uff3c'
		}
		if options.U007eAsFullwidthTilde {
			mappings['\u007e'] = '\uff5e'
		}
		if options.U007eAsWaveDash {
			mappings['\u007e'] = '\u301c'
		}
		if options.U007eAsOverline {
			mappings['\u007e'] = '\u203e'
		}
		if options.U007eAsFullwidthMacron {
			mappings['\u007e'] = '\uffe3'
		}
		if options.U00a5AsYenSign {
			mappings['\u00a5'] = '\uffe5'
		}
		if options.ConvertUnsafeSpecials {
			for k, v := range specialPunctuationsTable {
				mappings[v] = k
			}
		}
	}

	if options.ConvertGR {
		for k, v := range jisx0201GRTable {
			mappings[v] = k
		}
		if options.CombineVoicedSoundMarks {
			voicedMappings = make(map[rune]map[rune]rune)
			for fullwidth, halfwidth := range voicedLettersTable {
				baseRune := halfwidth[0]
				markRune := halfwidth[1]
				inner := voicedMappings[baseRune]
				if inner == nil {
					inner = make(map[rune]rune)
					voicedMappings[baseRune] = inner
				}
				inner[markRune] = fullwidth
			}
		}
	}

	entry.value = revMappings{
		nonvoiced: mappings,
		voiced:    voicedMappings,
	}
	return entry.value
}

func Transliterate(i yosina.CharIterator, opts Options) yosina.CharIterator {
	if opts.FullwidthToHalfwidth {
		opts := opts.fwdOptions()
		mappings := buildFwdMappings(opts)
		return &fullwidthToHalfwidthIterator{
			CharIterator: i,
			options:      opts,
			mappings:     mappings,
			pending:      yosina.InvalidUnicodeValue,
		}
	} else {
		opts := opts.revOptions()
		mappings := buildRevMappings(opts)
		return &halfwidthToFullwidthIterator{
			CharIterator: i,
			options:      opts,
			mappings:     mappings,
		}
	}
}
