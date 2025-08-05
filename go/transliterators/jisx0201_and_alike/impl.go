package jisx0201_and_alike

import (
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
	'\u309c': '\uff9f', // ゜ -> ﾟ

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

var voicedLettersTable = map[rune]string{
	'\u30f4': "\uff73\uff9e", // ヴ -> ｳﾞ

	'\u30ac': "\uff76\uff9e", // ガ -> ｶﾞ
	'\u30ae': "\uff77\uff9e", // ギ -> ｷﾞ
	'\u30b0': "\uff78\uff9e", // グ -> ｸﾞ
	'\u30b2': "\uff79\uff9e", // ゲ -> ｹﾞ
	'\u30b4': "\uff7a\uff9e", // ゴ -> ｺﾞ

	'\u30b6': "\uff7b\uff9e", // ザ -> ｻﾞ
	'\u30b8': "\uff7c\uff9e", // ジ -> ｼﾞ
	'\u30ba': "\uff7d\uff9e", // ズ -> ｽﾞ
	'\u30bc': "\uff7e\uff9e", // ゼ -> ｾﾞ
	'\u30be': "\uff7f\uff9e", // ゾ -> ｿﾞ

	'\u30c0': "\uff80\uff9e", // ダ -> ﾀﾞ
	'\u30c2': "\uff81\uff9e", // ヂ -> ﾁﾞ
	'\u30c5': "\uff82\uff9e", // ヅ -> ﾂﾞ
	'\u30c7': "\uff83\uff9e", // デ -> ﾃﾞ
	'\u30c9': "\uff84\uff9e", // ド -> ﾄﾞ

	'\u30d0': "\uff8a\uff9e", // バ -> ﾊﾞ
	'\u30d3': "\uff8b\uff9e", // ビ -> ﾋﾞ
	'\u30d6': "\uff8c\uff9e", // ブ -> ﾌﾞ
	'\u30d9': "\uff8d\uff9e", // ベ -> ﾍﾞ
	'\u30dc': "\uff8e\uff9e", // ボ -> ﾎﾞ

	'\u30d1': "\uff8a\uff9f", // パ -> ﾊﾟ
	'\u30d4': "\uff8b\uff9f", // ピ -> ﾋﾟ
	'\u30d7': "\uff8c\uff9f", // プ -> ﾌﾟ
	'\u30da': "\uff8d\uff9f", // ペ -> ﾍﾟ
	'\u30dd': "\uff8e\uff9f", // ポ -> ﾎﾟ

	'\u30fa': "\uff66\uff9e", // ヺ -> ｦﾞ
}

var hiraganaTable = map[rune]string{
	'\u3041': "\uff67", // ぁ -> ｧ
	'\u3043': "\uff68", // ぃ -> ｨ
	'\u3045': "\uff69", // ぅ -> ｩ
	'\u3047': "\uff6a", // ぇ -> ｪ
	'\u3049': "\uff6b", // ぉ -> ｫ
	'\u3083': "\uff6c", // ゃ -> ｬ
	'\u3085': "\uff6d", // ゅ -> ｭ
	'\u3087': "\uff6e", // ょ -> ｮ
	'\u3063': "\uff6f", // っ -> ｯ

	'\u3042': "\uff71", // あ -> ｱ
	'\u3044': "\uff72", // い -> ｲ
	'\u3046': "\uff73", // う -> ｳ
	'\u3048': "\uff74", // え -> ｴ
	'\u304a': "\uff75", // お -> ｵ

	'\u304b': "\uff76", // か -> ｶ
	'\u304d': "\uff77", // き -> ｷ
	'\u304f': "\uff78", // く -> ｸ
	'\u3051': "\uff79", // け -> ｹ
	'\u3053': "\uff7a", // こ -> ｺ

	'\u3055': "\uff7b", // さ -> ｻ
	'\u3057': "\uff7c", // し -> ｼ
	'\u3059': "\uff7d", // す -> ｽ
	'\u305b': "\uff7e", // せ -> ｾ
	'\u305d': "\uff7f", // そ -> ｿ

	'\u305f': "\uff80", // た -> ﾀ
	'\u3061': "\uff81", // ち -> ﾁ
	'\u3064': "\uff82", // つ -> ﾂ
	'\u3066': "\uff83", // て -> ﾃ
	'\u3068': "\uff84", // と -> ﾄ

	'\u306a': "\uff85", // な -> ﾅ
	'\u306b': "\uff86", // に -> ﾆ
	'\u306c': "\uff87", // ぬ -> ﾇ
	'\u306d': "\uff88", // ね -> ﾈ
	'\u306e': "\uff89", // の -> ﾉ

	'\u306f': "\uff8a", // は -> ﾊ
	'\u3072': "\uff8b", // ひ -> ﾋ
	'\u3075': "\uff8c", // ふ -> ﾌ
	'\u3078': "\uff8d", // へ -> ﾍ
	'\u307b': "\uff8e", // ほ -> ﾎ

	'\u307e': "\uff8f", // ま -> ﾏ
	'\u307f': "\uff90", // み -> ﾐ
	'\u3080': "\uff91", // む -> ﾑ
	'\u3081': "\uff92", // め -> ﾒ
	'\u3082': "\uff93", // も -> ﾓ

	'\u3084': "\uff94", // や -> ﾔ
	'\u3086': "\uff95", // ゆ -> ﾕ
	'\u3088': "\uff96", // よ -> ﾖ

	'\u3089': "\uff97", // ら -> ﾗ
	'\u308a': "\uff98", // り -> ﾘ
	'\u308b': "\uff99", // る -> ﾙ
	'\u308c': "\uff9a", // れ -> ﾚ
	'\u308d': "\uff9b", // ろ -> ﾛ

	'\u308f': "\uff9c", // わ -> ﾜ
	'\u3093': "\uff9d", // ん -> ﾝ
	'\u3092': "\uff66", // を -> ｦ

	'\u3094': "\uff73\uff9e", // ゔ -> ｳﾞ

	'\u304c': "\uff76\uff9e", // が -> ｶﾞ
	'\u304e': "\uff77\uff9e", // ぎ -> ｷﾞ
	'\u3050': "\uff78\uff9e", // ぐ -> ｸﾞ
	'\u3052': "\uff79\uff9e", // げ -> ｹﾞ
	'\u3054': "\uff7a\uff9e", // ご -> ｺﾞ

	'\u3056': "\uff7b\uff9e", // ざ -> ｻﾞ
	'\u3058': "\uff7c\uff9e", // じ -> ｼﾞ
	'\u305a': "\uff7d\uff9e", // ず -> ｽﾞ
	'\u305c': "\uff7e\uff9e", // ぜ -> ｾﾞ
	'\u305e': "\uff7f\uff9e", // ぞ -> ｿﾞ

	'\u3060': "\uff80\uff9e", // だ -> ﾀﾞ
	'\u3062': "\uff81\uff9e", // ぢ -> ﾁﾞ
	'\u3065': "\uff82\uff9e", // づ -> ﾂﾞ
	'\u3067': "\uff83\uff9e", // で -> ﾃﾞ
	'\u3069': "\uff84\uff9e", // ど -> ﾄﾞ

	'\u3070': "\uff8a\uff9e", // ば -> ﾊﾞ
	'\u3073': "\uff8b\uff9e", // び -> ﾋﾞ
	'\u3076': "\uff8c\uff9e", // ぶ -> ﾌﾞ
	'\u3079': "\uff8d\uff9e", // べ -> ﾍﾞ
	'\u307c': "\uff8e\uff9e", // ぼ -> ﾎﾞ

	'\u3071': "\uff8a\uff9f", // ぱ -> ﾊﾟ
	'\u3074': "\uff8b\uff9f", // ぴ -> ﾋﾟ
	'\u3077': "\uff8c\uff9f", // ぷ -> ﾌﾟ
	'\u307a': "\uff8d\uff9f", // ぺ -> ﾍﾟ
	'\u307d': "\uff8e\uff9f", // ぽ -> ﾎﾟ
}

var specialPunctuationsTable = map[rune]rune{
	'\u30a0': '\u003d', // ゠ -> =
}

type Options struct {
	FullwidthToHalfwidth    bool
	ConvertGL               bool
	ConvertGR               bool
	ConvertUnsafeSpecials   bool
	ConvertHiraganas        bool
	CombineVoicedSoundMarks bool
	U005cAsYenSign          bool
	U005cAsBackslash        bool
	U007eAsFullwidthTilde   bool
	U007eAsWaveDash         bool
	U007eAsOverline         bool
	U007eAsFullwidthMacron  bool
	U00a5AsYenSign          bool
}

type jisx0201CharIterator struct {
	yosina.CharIterator
	options           Options
	fwdMappings       map[rune]string
	revMappings       map[rune]rune
	voicedRevMappings map[rune]map[rune]rune
	pending           []rune
	pendingOffset     int
	pendingChar       *yosina.Char
	offset            int
}

func (i *jisx0201CharIterator) Next() *yosina.Char {
	if i.pendingOffset < len(i.pending) {
		r := i.pending[i.pendingOffset]
		i.pendingOffset++
		return &yosina.Char{
			C:      [2]rune{r, yosina.InvalidUnicodeValue},
			Offset: i.offset,
		}
	}

	var c *yosina.Char
	if i.pendingChar != nil {
		c = i.pendingChar
		i.pendingChar = nil
	} else {
		c = i.CharIterator.Next()
		if c == nil {
			return nil
		}
	}

	if c.C[0] == yosina.InvalidUnicodeValue {
		return c
	}

	if i.options.FullwidthToHalfwidth {
		// Convert fullwidth to halfwidth
		if mapped, ok := i.fwdMappings[c.C[0]]; ok {
			if len(mapped) == 1 {
				return &yosina.Char{
					C:      [2]rune{rune(mapped[0]), yosina.InvalidUnicodeValue},
					Offset: c.Offset,
					Source: c,
				}
			}
			// Multi-character mapping
			i.pending = []rune(mapped)
			i.pendingOffset = 1
			return &yosina.Char{
				C:      [2]rune{i.pending[0], yosina.InvalidUnicodeValue},
				Offset: c.Offset,
				Source: c,
			}
		}
	} else {
		// Convert halfwidth to fullwidth

		// Check for voiced sound mark combination
		if i.options.CombineVoicedSoundMarks {
			if markMappings, ok := i.voicedRevMappings[c.C[0]]; ok {
				// Look ahead for a voice mark
				next := i.CharIterator.Next()
				if next != nil && next.C[0] != yosina.InvalidUnicodeValue {
					if combined, ok := markMappings[next.C[0]]; ok {
						// Combine the characters
						return &yosina.Char{
							C:      [2]rune{combined, yosina.InvalidUnicodeValue},
							Offset: c.Offset,
							Source: c,
						}
					}
				}
				// No combination possible, set next as pending
				i.pendingChar = next
			}
		}

		// Regular mapping
		if mapped, ok := i.revMappings[c.C[0]]; ok {
			return &yosina.Char{
				C:      [2]rune{mapped, yosina.InvalidUnicodeValue},
				Offset: c.Offset,
				Source: c,
			}
		}
	}

	return c
}

func buildFwdMappings(options Options) map[rune]string {
	mappings := make(map[rune]string)

	if options.ConvertGL {
		for k, v := range jisx0201GLTable {
			mappings[k] = string(v)
		}

		// Handle overrides
		if options.U005cAsYenSign {
			mappings['\uffe5'] = "\u005c"
		}
		if options.U005cAsBackslash {
			mappings['\uff3c'] = "\u005c"
		}
		if options.U007eAsFullwidthTilde {
			mappings['\uff5e'] = "\u007e"
		}
		if options.U007eAsWaveDash {
			mappings['\u301c'] = "\u007e"
		}
		if options.U007eAsOverline {
			mappings['\u203e'] = "\u007e"
		}
		if options.U007eAsFullwidthMacron {
			mappings['\uffe3'] = "\u007e"
		}
		if options.U00a5AsYenSign {
			mappings['\uffe5'] = "\u00a5"
		}
	}

	if options.ConvertGR {
		for k, v := range jisx0201GRTable {
			mappings[k] = string(v)
		}
		for k, v := range voicedLettersTable {
			mappings[k] = v
		}
		mappings['\u3099'] = "\uff9e"
		mappings['\u309a'] = "\uff9f"
	}

	if options.ConvertUnsafeSpecials {
		for k, v := range specialPunctuationsTable {
			mappings[k] = string(v)
		}
	}

	if options.ConvertHiraganas {
		for k, v := range hiraganaTable {
			mappings[k] = v
		}
	}

	return mappings
}

func buildRevMappings(options Options) map[rune]rune {
	mappings := make(map[rune]rune)

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
	}

	if options.ConvertGR {
		for k, v := range jisx0201GRTable {
			mappings[v] = k
		}
	}

	if options.ConvertUnsafeSpecials {
		for k, v := range specialPunctuationsTable {
			mappings[v] = k
		}
	}

	return mappings
}

func buildVoicedRevMappings(options Options) map[rune]map[rune]rune {
	mappings := make(map[rune]map[rune]rune)

	if options.ConvertGR && options.CombineVoicedSoundMarks {
		for fullwidth, halfwidth := range voicedLettersTable {
			runes := []rune(halfwidth)
			if len(runes) == 2 {
				baseRune := runes[0]
				markRune := runes[1]

				if mappings[baseRune] == nil {
					mappings[baseRune] = make(map[rune]rune)
				}
				mappings[baseRune][markRune] = fullwidth
			}
		}
	}

	return mappings
}

func Transliterate(i yosina.CharIterator, opts Options) yosina.CharIterator {
	// Set defaults
	if opts.ConvertGL && !opts.U005cAsYenSign && !opts.U005cAsBackslash && !opts.U00a5AsYenSign {
		opts.U005cAsYenSign = true
		opts.U005cAsBackslash = true
	}
	if opts.ConvertGL && !opts.U007eAsFullwidthTilde && !opts.U007eAsWaveDash && !opts.U007eAsOverline && !opts.U007eAsFullwidthMacron {
		opts.U007eAsFullwidthTilde = true
		opts.U007eAsWaveDash = true
	}

	var fwdMappings map[rune]string
	var revMappings map[rune]rune
	var voicedRevMappings map[rune]map[rune]rune

	if opts.FullwidthToHalfwidth {
		fwdMappings = buildFwdMappings(opts)
	} else {
		revMappings = buildRevMappings(opts)
		voicedRevMappings = buildVoicedRevMappings(opts)
	}

	return &jisx0201CharIterator{
		CharIterator:      i,
		options:           opts,
		fwdMappings:       fwdMappings,
		revMappings:       revMappings,
		voicedRevMappings: voicedRevMappings,
		pending:           make([]rune, 0),
	}
}
