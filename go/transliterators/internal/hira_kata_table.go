package internal

// HiraKata represents a hiragana or katakana character with its forms
type HiraKata struct {
	Base       rune
	Voiced     rune
	Semivoiced rune
}

// HiraKataEntry represents an entry in the hiragana-katakana table
type HiraKataEntry struct {
	Hiragana  *HiraKata
	Katakana  HiraKata
	Halfwidth rune
}

// SmallKanaEntry represents a small kana entry
type SmallKanaEntry struct {
	Hiragana  rune
	Katakana  rune
	Halfwidth rune
}

// HiraganaKatakanaTable is the main table containing all mappings
var HiraganaKatakanaTable = []HiraKataEntry{
	// Vowels
	{&HiraKata{'あ', -1, -1}, HiraKata{'ア', -1, -1}, 'ｱ'},
	{&HiraKata{'い', -1, -1}, HiraKata{'イ', -1, -1}, 'ｲ'},
	{&HiraKata{'う', 'ゔ', -1}, HiraKata{'ウ', 'ヴ', -1}, 'ｳ'},
	{&HiraKata{'え', -1, -1}, HiraKata{'エ', -1, -1}, 'ｴ'},
	{&HiraKata{'お', -1, -1}, HiraKata{'オ', -1, -1}, 'ｵ'},
	// K-row
	{&HiraKata{'か', 'が', -1}, HiraKata{'カ', 'ガ', -1}, 'ｶ'},
	{&HiraKata{'き', 'ぎ', -1}, HiraKata{'キ', 'ギ', -1}, 'ｷ'},
	{&HiraKata{'く', 'ぐ', -1}, HiraKata{'ク', 'グ', -1}, 'ｸ'},
	{&HiraKata{'け', 'げ', -1}, HiraKata{'ケ', 'ゲ', -1}, 'ｹ'},
	{&HiraKata{'こ', 'ご', -1}, HiraKata{'コ', 'ゴ', -1}, 'ｺ'},
	// S-row
	{&HiraKata{'さ', 'ざ', -1}, HiraKata{'サ', 'ザ', -1}, 'ｻ'},
	{&HiraKata{'し', 'じ', -1}, HiraKata{'シ', 'ジ', -1}, 'ｼ'},
	{&HiraKata{'す', 'ず', -1}, HiraKata{'ス', 'ズ', -1}, 'ｽ'},
	{&HiraKata{'せ', 'ぜ', -1}, HiraKata{'セ', 'ゼ', -1}, 'ｾ'},
	{&HiraKata{'そ', 'ぞ', -1}, HiraKata{'ソ', 'ゾ', -1}, 'ｿ'},
	// T-row
	{&HiraKata{'た', 'だ', -1}, HiraKata{'タ', 'ダ', -1}, 'ﾀ'},
	{&HiraKata{'ち', 'ぢ', -1}, HiraKata{'チ', 'ヂ', -1}, 'ﾁ'},
	{&HiraKata{'つ', 'づ', -1}, HiraKata{'ツ', 'ヅ', -1}, 'ﾂ'},
	{&HiraKata{'て', 'で', -1}, HiraKata{'テ', 'デ', -1}, 'ﾃ'},
	{&HiraKata{'と', 'ど', -1}, HiraKata{'ト', 'ド', -1}, 'ﾄ'},
	// N-row
	{&HiraKata{'な', -1, -1}, HiraKata{'ナ', -1, -1}, 'ﾅ'},
	{&HiraKata{'に', -1, -1}, HiraKata{'ニ', -1, -1}, 'ﾆ'},
	{&HiraKata{'ぬ', -1, -1}, HiraKata{'ヌ', -1, -1}, 'ﾇ'},
	{&HiraKata{'ね', -1, -1}, HiraKata{'ネ', -1, -1}, 'ﾈ'},
	{&HiraKata{'の', -1, -1}, HiraKata{'ノ', -1, -1}, 'ﾉ'},
	// H-row
	{&HiraKata{'は', 'ば', 'ぱ'}, HiraKata{'ハ', 'バ', 'パ'}, 'ﾊ'},
	{&HiraKata{'ひ', 'び', 'ぴ'}, HiraKata{'ヒ', 'ビ', 'ピ'}, 'ﾋ'},
	{&HiraKata{'ふ', 'ぶ', 'ぷ'}, HiraKata{'フ', 'ブ', 'プ'}, 'ﾌ'},
	{&HiraKata{'へ', 'べ', 'ぺ'}, HiraKata{'ヘ', 'ベ', 'ペ'}, 'ﾍ'},
	{&HiraKata{'ほ', 'ぼ', 'ぽ'}, HiraKata{'ホ', 'ボ', 'ポ'}, 'ﾎ'},
	// M-row
	{&HiraKata{'ま', -1, -1}, HiraKata{'マ', -1, -1}, 'ﾏ'},
	{&HiraKata{'み', -1, -1}, HiraKata{'ミ', -1, -1}, 'ﾐ'},
	{&HiraKata{'む', -1, -1}, HiraKata{'ム', -1, -1}, 'ﾑ'},
	{&HiraKata{'め', -1, -1}, HiraKata{'メ', -1, -1}, 'ﾒ'},
	{&HiraKata{'も', -1, -1}, HiraKata{'モ', -1, -1}, 'ﾓ'},
	// Y-row
	{&HiraKata{'や', -1, -1}, HiraKata{'ヤ', -1, -1}, 'ﾔ'},
	{&HiraKata{'ゆ', -1, -1}, HiraKata{'ユ', -1, -1}, 'ﾕ'},
	{&HiraKata{'よ', -1, -1}, HiraKata{'ヨ', -1, -1}, 'ﾖ'},
	// R-row
	{&HiraKata{'ら', -1, -1}, HiraKata{'ラ', -1, -1}, 'ﾗ'},
	{&HiraKata{'り', -1, -1}, HiraKata{'リ', -1, -1}, 'ﾘ'},
	{&HiraKata{'る', -1, -1}, HiraKata{'ル', -1, -1}, 'ﾙ'},
	{&HiraKata{'れ', -1, -1}, HiraKata{'レ', -1, -1}, 'ﾚ'},
	{&HiraKata{'ろ', -1, -1}, HiraKata{'ロ', -1, -1}, 'ﾛ'},
	// W-row
	{&HiraKata{'わ', -1, -1}, HiraKata{'ワ', 'ヷ', -1}, 'ﾜ'},
	{&HiraKata{'ゐ', -1, -1}, HiraKata{'ヰ', 'ヸ', -1}, -1},
	{&HiraKata{'ゑ', -1, -1}, HiraKata{'ヱ', 'ヹ', -1}, -1},
	{&HiraKata{'を', -1, -1}, HiraKata{'ヲ', 'ヺ', -1}, 'ｦ'},
	{&HiraKata{'ん', -1, -1}, HiraKata{'ン', -1, -1}, 'ﾝ'},
}

// HiraganaKatakanaSmallTable contains small kana mappings
var HiraganaKatakanaSmallTable = []SmallKanaEntry{
	{'ぁ', 'ァ', 'ｧ'},
	{'ぃ', 'ィ', 'ｨ'},
	{'ぅ', 'ゥ', 'ｩ'},
	{'ぇ', 'ェ', 'ｪ'},
	{'ぉ', 'ォ', 'ｫ'},
	{'っ', 'ッ', 'ｯ'},
	{'ゃ', 'ャ', 'ｬ'},
	{'ゅ', 'ュ', 'ｭ'},
	{'ょ', 'ョ', 'ｮ'},
	{'ゎ', 'ヮ', -1},
	{'ゕ', 'ヵ', -1},
	{'ゖ', 'ヶ', -1},
}
