package hira_kata_composition

import (
	yosina "github.com/yosina-lib/yosina/go"
)

// voicedCharacters contains base character to voiced character mappings
var voicedCharacters = [][2]rune{
	{'\u304b', '\u304c'}, // か -> が
	{'\u304d', '\u304e'}, // き -> ぎ
	{'\u304f', '\u3050'}, // く -> ぐ
	{'\u3051', '\u3052'}, // け -> げ
	{'\u3053', '\u3054'}, // こ -> ご

	{'\u3055', '\u3056'}, // さ -> ざ
	{'\u3057', '\u3058'}, // し -> じ
	{'\u3059', '\u305a'}, // す -> ず
	{'\u305b', '\u305c'}, // せ -> ぜ
	{'\u305d', '\u305e'}, // そ -> ぞ

	{'\u305f', '\u3060'}, // た -> だ
	{'\u3061', '\u3062'}, // ち -> ぢ
	{'\u3064', '\u3065'}, // つ -> づ
	{'\u3066', '\u3067'}, // て -> で
	{'\u3068', '\u3069'}, // と -> ど

	{'\u306f', '\u3070'}, // は -> ば
	{'\u3072', '\u3073'}, // ひ -> び
	{'\u3075', '\u3076'}, // ふ -> ぶ
	{'\u3078', '\u3079'}, // へ -> べ
	{'\u307b', '\u307c'}, // ほ -> ぼ

	{'\u3046', '\u3094'}, // う -> ゔ
	{'\u309d', '\u309e'}, // ゝ -> ゞ

	// Katakana
	{'\u30ab', '\u30ac'}, // カ -> ガ
	{'\u30ad', '\u30ae'}, // キ -> ギ
	{'\u30af', '\u30b0'}, // ク -> グ
	{'\u30b1', '\u30b2'}, // ケ -> ゲ
	{'\u30b3', '\u30b4'}, // コ -> ゴ

	{'\u30b5', '\u30b6'}, // サ -> ザ
	{'\u30b7', '\u30b8'}, // シ -> ジ
	{'\u30b9', '\u30ba'}, // ス -> ズ
	{'\u30bb', '\u30bc'}, // セ -> ゼ
	{'\u30bd', '\u30be'}, // ソ -> ゾ

	{'\u30bf', '\u30c0'}, // タ -> ダ
	{'\u30c1', '\u30c2'}, // チ -> ヂ
	{'\u30c4', '\u30c5'}, // ツ -> ヅ
	{'\u30c6', '\u30c7'}, // テ -> デ
	{'\u30c8', '\u30c9'}, // ト -> ド

	{'\u30cf', '\u30d0'}, // ハ -> バ
	{'\u30d2', '\u30d3'}, // ヒ -> ビ
	{'\u30d5', '\u30d6'}, // フ -> ブ
	{'\u30d8', '\u30d9'}, // ヘ -> ベ
	{'\u30db', '\u30dc'}, // ホ -> ボ

	{'\u30a6', '\u30f4'}, // ウ -> ヴ
	{'\u30ef', '\u30f7'}, // ワ -> ヷ
	{'\u30f0', '\u30f8'}, // ヰ -> ヸ
	{'\u30f1', '\u30f9'}, // ヱ -> ヹ
	{'\u30f2', '\u30fa'}, // ヲ -> ヺ
	{'\u30fd', '\u30fe'}, // ヽ -> ヾ
}

// semiVoicedCharacters contains base character to semi-voiced character mappings
var semiVoicedCharacters = [][2]rune{
	{'\u306f', '\u3071'}, // は -> ぱ
	{'\u3072', '\u3074'}, // ひ -> ぴ
	{'\u3075', '\u3077'}, // ふ -> ぷ
	{'\u3078', '\u307a'}, // へ -> ぺ
	{'\u307b', '\u307d'}, // ほ -> ぽ

	// Katakana
	{'\u30cf', '\u30d1'}, // ハ -> パ
	{'\u30d2', '\u30d4'}, // ヒ -> ピ
	{'\u30d5', '\u30d7'}, // フ -> プ
	{'\u30d8', '\u30da'}, // ヘ -> ペ
	{'\u30db', '\u30dd'}, // ホ -> ポ
}

type Options struct {
	ComposeNonCombiningMarks bool
}

type hiraKataCompositionCharIterator struct {
	yosina.CharIterator
	table  map[[2]rune]rune
	prev   *yosina.Char
	eoi    bool
	offset int
}

// buildTable constructs the lookup table from the character arrays
func (o *Options) buildTable() map[[2]rune]rune {
	table := make(map[[2]rune]rune)
	for _, pair := range voicedCharacters {
		table[[2]rune{pair[0], '\u3099'}] = pair[1]
	}
	for _, pair := range semiVoicedCharacters {
		table[[2]rune{pair[0], '\u309a'}] = pair[1]
	}
	if o.ComposeNonCombiningMarks {
		for _, pair := range voicedCharacters {
			table[[2]rune{pair[0], '\u309b'}] = pair[1] // non-combining voiced mark
		}
		for _, pair := range semiVoicedCharacters {
			table[[2]rune{pair[0], '\u309c'}] = pair[1] // non-combining semi-voiced mark
		}
	}
	return table
}

func (i *hiraKataCompositionCharIterator) Next() *yosina.Char {
	if i.eoi {
		return nil
	}
	for {
		c := i.CharIterator.Next()
		if c == nil {
			i.eoi = true
			if i.prev != nil {
				return i.prev.WithOffset(i.offset)

			}
			return nil
		}
		if i.prev == nil {
			i.prev = c
			continue
		}
		if composed, ok := i.table[[2]rune{i.prev.C[0], c.C[0]}]; ok {
			nc := &yosina.Char{
				C:      [2]rune{composed, yosina.InvalidUnicodeValue},
				Offset: i.offset,
				Source: i.prev,
			}
			i.offset += nc.RuneLen()
			i.prev = nil
			return nc
		}
		// No composition, return c and save next as pending
		nc := i.prev.WithOffset(i.offset)
		i.offset += nc.RuneLen()
		i.prev = c
		return nc
	}
}

func Transliterate(i yosina.CharIterator, opts Options) yosina.CharIterator {
	table := opts.buildTable()

	return &hiraKataCompositionCharIterator{
		CharIterator: i,
		table:        table,
		offset:       0,
	}
}
