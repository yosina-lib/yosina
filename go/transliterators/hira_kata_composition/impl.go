package hira_kata_composition

import (
	yosina "github.com/yosina-lib/yosina/go"
)

var compositionTable = map[[2]rune]rune{
	// Hiragana + voiced sound mark
	{'\u304b', '\u3099'}: '\u304c', // か + ゙ = が
	{'\u304d', '\u3099'}: '\u304e', // き + ゙ = ぎ
	{'\u304f', '\u3099'}: '\u3050', // く + ゙ = ぐ
	{'\u3051', '\u3099'}: '\u3052', // け + ゙ = げ
	{'\u3053', '\u3099'}: '\u3054', // こ + ゙ = ご

	{'\u3055', '\u3099'}: '\u3056', // さ + ゙ = ざ
	{'\u3057', '\u3099'}: '\u3058', // し + ゙ = じ
	{'\u3059', '\u3099'}: '\u305a', // す + ゙ = ず
	{'\u305b', '\u3099'}: '\u305c', // せ + ゙ = ぜ
	{'\u305d', '\u3099'}: '\u305e', // そ + ゙ = ぞ

	{'\u305f', '\u3099'}: '\u3060', // た + ゙ = だ
	{'\u3061', '\u3099'}: '\u3062', // ち + ゙ = ぢ
	{'\u3064', '\u3099'}: '\u3065', // つ + ゙ = づ
	{'\u3066', '\u3099'}: '\u3067', // て + ゙ = で
	{'\u3068', '\u3099'}: '\u3069', // と + ゙ = ど

	{'\u306f', '\u3099'}: '\u3070', // は + ゙ = ば
	{'\u3072', '\u3099'}: '\u3073', // ひ + ゙ = び
	{'\u3075', '\u3099'}: '\u3076', // ふ + ゙ = ぶ
	{'\u3078', '\u3099'}: '\u3079', // へ + ゙ = べ
	{'\u307b', '\u3099'}: '\u307c', // ほ + ゙ = ぼ

	// Hiragana + semi-voiced sound mark
	{'\u306f', '\u309a'}: '\u3071', // は + ゚ = ぱ
	{'\u3072', '\u309a'}: '\u3074', // ひ + ゚ = ぴ
	{'\u3075', '\u309a'}: '\u3077', // ふ + ゚ = ぷ
	{'\u3078', '\u309a'}: '\u307a', // へ + ゚ = ぺ
	{'\u307b', '\u309a'}: '\u307d', // ほ + ゚ = ぽ

	{'\u3046', '\u3099'}: '\u3094', // う + ゙ = ゔ
	{'\u309d', '\u3099'}: '\u309e', // ゝ + ゙ = ゞ

	// Katakana + voiced sound mark
	{'\u30ab', '\u3099'}: '\u30ac', // カ + ゙ = ガ
	{'\u30ad', '\u3099'}: '\u30ae', // キ + ゙ = ギ
	{'\u30af', '\u3099'}: '\u30b0', // ク + ゙ = グ
	{'\u30b1', '\u3099'}: '\u30b2', // ケ + ゙ = ゲ
	{'\u30b3', '\u3099'}: '\u30b4', // コ + ゙ = ゴ

	{'\u30b5', '\u3099'}: '\u30b6', // サ + ゙ = ザ
	{'\u30b7', '\u3099'}: '\u30b8', // シ + ゙ = ジ
	{'\u30b9', '\u3099'}: '\u30ba', // ス + ゙ = ズ
	{'\u30bb', '\u3099'}: '\u30bc', // セ + ゙ = ゼ
	{'\u30bd', '\u3099'}: '\u30be', // ソ + ゙ = ゾ

	{'\u30bf', '\u3099'}: '\u30c0', // タ + ゙ = ダ
	{'\u30c1', '\u3099'}: '\u30c2', // チ + ゙ = ヂ
	{'\u30c4', '\u3099'}: '\u30c5', // ツ + ゙ = ヅ
	{'\u30c6', '\u3099'}: '\u30c7', // テ + ゙ = デ
	{'\u30c8', '\u3099'}: '\u30c9', // ト + ゙ = ド

	{'\u30cf', '\u3099'}: '\u30d0', // ハ + ゙ = バ
	{'\u30d2', '\u3099'}: '\u30d3', // ヒ + ゙ = ビ
	{'\u30d5', '\u3099'}: '\u30d6', // フ + ゙ = ブ
	{'\u30d8', '\u3099'}: '\u30d9', // ヘ + ゙ = ベ
	{'\u30db', '\u3099'}: '\u30dc', // ホ + ゙ = ボ

	// Katakana + semi-voiced sound mark
	{'\u30cf', '\u309a'}: '\u30d1', // ハ + ゚ = パ
	{'\u30d2', '\u309a'}: '\u30d4', // ヒ + ゚ = ピ
	{'\u30d5', '\u309a'}: '\u30d7', // フ + ゚ = プ
	{'\u30d8', '\u309a'}: '\u30da', // ヘ + ゚ = ペ
	{'\u30db', '\u309a'}: '\u30dd', // ホ + ゚ = ポ

	{'\u30a6', '\u3099'}: '\u30f4', // ウ + ゙ = ヴ
	{'\u30ef', '\u3099'}: '\u30f7', // ワ + ゙ = ヷ
	{'\u30f0', '\u3099'}: '\u30f8', // ヰ + ゙ = ヸ
	{'\u30f1', '\u3099'}: '\u30f9', // ヱ + ゙ = ヹ
	{'\u30f2', '\u3099'}: '\u30fa', // ヲ + ゙ = ヺ
}

type Options struct {
	ComposeNonCombiningMarks bool
}

type hiraKataCompositionCharIterator struct {
	yosina.CharIterator
	composeNonCombiningMarks bool
	pendingChar              *yosina.Char
	offset                   int
}

func (i *hiraKataCompositionCharIterator) Next() *yosina.Char {
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

	if c.IsSentinel() {
		return c
	}

	// Check if current character can be the first part of a composition
	if i.canBeComposed(c.C[0]) {
		// Look ahead for the combining mark
		next := i.CharIterator.Next()
		if next == nil {
			return c
		}

		// Check for composition
		if composed := i.tryCompose(c.C[0], next.C[0]); composed != yosina.InvalidUnicodeValue {
			nc := &yosina.Char{
				C:      [2]rune{composed, yosina.InvalidUnicodeValue},
				Offset: i.offset,
				Source: c,
			}
			i.offset += nc.RuneLen()
			return nc
		}

		// No composition found, return current char and set next as pending
		i.pendingChar = next
	}
	nc := c.WithOffset(i.offset)
	i.offset += nc.RuneLen()
	return nc
}

func (i *hiraKataCompositionCharIterator) canBeComposed(r rune) bool {
	// Check if this character can be the first part of a composition
	for key := range compositionTable {
		if key[0] == r {
			return true
		}
	}
	return false
}

func (i *hiraKataCompositionCharIterator) tryCompose(base, mark rune) rune {
	// Try direct composition
	if composed, ok := compositionTable[[2]rune{base, mark}]; ok {
		return composed
	}

	// Try with non-combining marks if enabled
	if i.composeNonCombiningMarks {
		var convertedMark rune
		switch mark {
		case '\u309b': // ゛ (non-combining voiced sound mark)
			convertedMark = '\u3099' // ゙ (combining voiced sound mark)
		case '\u309c': // ゜ (non-combining semi-voiced sound mark)
			convertedMark = '\u309a' // ゚ (combining semi-voiced sound mark)
		default:
			return yosina.InvalidUnicodeValue
		}

		if composed, ok := compositionTable[[2]rune{base, convertedMark}]; ok {
			return composed
		}
	}

	return yosina.InvalidUnicodeValue
}

func Transliterate(i yosina.CharIterator, opts Options) yosina.CharIterator {
	return &hiraKataCompositionCharIterator{
		CharIterator:             i,
		composeNonCombiningMarks: opts.ComposeNonCombiningMarks,
	}
}
