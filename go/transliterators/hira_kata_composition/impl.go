package hira_kata_composition

import (
	yosina "github.com/yosina-lib/yosina/go"
	"github.com/yosina-lib/yosina/go/transliterators/internal"
)

// generateVoicedCharacters generates voiced character mappings from the table
func generateVoicedCharacters() [][2]rune {
	var result [][2]rune

	for _, entry := range internal.HiraganaKatakanaTable {
		if entry.Hiragana != nil {
			if entry.Hiragana.Base >= 0 && entry.Hiragana.Voiced >= 0 {
				result = append(result, [2]rune{entry.Hiragana.Base, entry.Hiragana.Voiced})
			}
		}
		if entry.Katakana.Base >= 0 && entry.Katakana.Voiced >= 0 {
			result = append(result, [2]rune{entry.Katakana.Base, entry.Katakana.Voiced})
		}
	}

	// Add iteration marks
	result = append(result, [2]rune{'\u309d', '\u309e'}) // ゝ -> ゞ
	result = append(result, [2]rune{'\u30fd', '\u30fe'}) // ヽ -> ヾ
	result = append(result, [2]rune{'\u3031', '\u3032'}) // 〱 -> 〲 (vertical hiragana)
	result = append(result, [2]rune{'\u3033', '\u3034'}) // 〳 -> 〴 (vertical katakana)

	return result
}

// generateSemiVoicedCharacters generates semi-voiced character mappings from the table
func generateSemiVoicedCharacters() [][2]rune {
	var result [][2]rune

	for _, entry := range internal.HiraganaKatakanaTable {
		if entry.Hiragana != nil {
			if entry.Hiragana.Base >= 0 && entry.Hiragana.Semivoiced >= 0 {
				result = append(result, [2]rune{entry.Hiragana.Base, entry.Hiragana.Semivoiced})
			}
		}
		if entry.Katakana.Base >= 0 && entry.Katakana.Semivoiced >= 0 {
			result = append(result, [2]rune{entry.Katakana.Base, entry.Katakana.Semivoiced})
		}
	}

	return result
}

// voicedCharacters is generated from the shared table
var voicedCharacters = generateVoicedCharacters()

// semiVoicedCharacters is generated from the shared table
var semiVoicedCharacters = generateSemiVoicedCharacters()

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
