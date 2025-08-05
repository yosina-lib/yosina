package japanese_iteration_marks

import (
	yosina "github.com/yosina-lib/yosina/go"
)

// Iteration mark characters
const (
	hiraganaIterationMark       = '\u309d' // ゝ
	hiraganaVoicedIterationMark = '\u309e' // ゞ
	katakanaIterationMark       = '\u30fd' // ヽ
	katakanaVoicedIterationMark = '\u30fe' // ヾ
	kanjiIterationMark          = '\u3005' // 々
)

// Character type constants
type charType int

const (
	charTypeOther charType = iota
	charTypeHiragana
	charTypeKatakana
	charTypeKanji
	charTypeVoiced
	charTypeSemiVoiced
	charTypeHatsuon
	charTypeSokuon
)

// Voicing map for hiragana
var hiraganaVoicingMap = map[rune]rune{
	'か': 'が', 'き': 'ぎ', 'く': 'ぐ', 'け': 'げ', 'こ': 'ご',
	'さ': 'ざ', 'し': 'じ', 'す': 'ず', 'せ': 'ぜ', 'そ': 'ぞ',
	'た': 'だ', 'ち': 'ぢ', 'つ': 'づ', 'て': 'で', 'と': 'ど',
	'は': 'ば', 'ひ': 'び', 'ふ': 'ぶ', 'へ': 'べ', 'ほ': 'ぼ',
}

// Voicing map for katakana
var katakanaVoicingMap = map[rune]rune{
	'カ': 'ガ', 'キ': 'ギ', 'ク': 'グ', 'ケ': 'ゲ', 'コ': 'ゴ',
	'サ': 'ザ', 'シ': 'ジ', 'ス': 'ズ', 'セ': 'ゼ', 'ソ': 'ゾ',
	'タ': 'ダ', 'チ': 'ヂ', 'ツ': 'ヅ', 'テ': 'デ', 'ト': 'ド',
	'ハ': 'バ', 'ヒ': 'ビ', 'フ': 'ブ', 'ヘ': 'ベ', 'ホ': 'ボ',
	'ウ': 'ヴ',
}

// Derive voiced characters from voicing maps
var voicedChars = func() map[rune]bool {
	chars := make(map[rune]bool)
	for _, v := range hiraganaVoicingMap {
		chars[v] = true
	}
	for _, v := range katakanaVoicingMap {
		chars[v] = true
	}
	return chars
}()

// Semi-voiced characters map (these have handakuten)
var semiVoicedChars = map[rune]bool{
	// Hiragana semi-voiced
	'ぱ': true, 'ぴ': true, 'ぷ': true, 'ぺ': true, 'ぽ': true,
	// Katakana semi-voiced
	'パ': true, 'ピ': true, 'プ': true, 'ペ': true, 'ポ': true,
}

func getCharType(r rune) charType {
	// Check for invalid value
	if r == yosina.InvalidUnicodeValue {
		return charTypeOther
	}

	// Hatsuon (ん/ン)
	if r == 'ん' || r == 'ン' {
		return charTypeHatsuon
	}

	// Sokuon (っ/ッ)
	if r == 'っ' || r == 'ッ' {
		return charTypeSokuon
	}

	// Check if voiced
	if _, ok := voicedChars[r]; ok {
		return charTypeVoiced
	}

	// Check if semi-voiced
	if semiVoicedChars[r] {
		return charTypeSemiVoiced
	}

	// Hiragana range (excluding small characters and special marks)
	if r >= '\u3041' && r <= '\u3096' {
		return charTypeHiragana
	}

	// Katakana range (excluding small characters and special marks)
	if r >= '\u30a1' && r <= '\u30fa' {
		return charTypeKatakana
	}

	// CJK Unified Ideographs (common kanji range)
	if (r >= '\u4e00' && r <= '\u9fff') ||
		(r >= '\u3400' && r <= '\u4dbf') || // CJK Extension A
		(r >= 0x20000 && r <= 0x2a6df) || // CJK Extension B
		(r >= 0x2a700 && r <= 0x2b73f) || // CJK Extension C
		(r >= 0x2b740 && r <= 0x2b81f) || // CJK Extension D
		(r >= 0x2b820 && r <= 0x2ceaf) || // CJK Extension E
		(r >= 0x2ceb0 && r <= 0x2ebef) || // CJK Extension F
		(r >= 0x30000 && r <= 0x3134f) { // CJK Extension G
		return charTypeKanji
	}

	return charTypeOther
}

func isIterationMark(r rune) bool {
	return r == hiraganaIterationMark ||
		r == hiraganaVoicedIterationMark ||
		r == katakanaIterationMark ||
		r == katakanaVoicedIterationMark ||
		r == kanjiIterationMark
}

type Options struct {
	// Currently no options, but keeping structure for consistency
}

type japaneseIterationMarksCharIterator struct {
	yosina.CharIterator
	options  Options
	prevChar *yosina.Char
	prevType charType
	offset   int
}

func (i *japaneseIterationMarksCharIterator) Next() *yosina.Char {
	c := i.CharIterator.Next()
	if c == nil {
		return nil
	}

	// Check if current character is an iteration mark
	if c.C[1] == yosina.InvalidUnicodeValue && isIterationMark(c.C[0]) {
		// We have an iteration mark, check if we can replace it
		if i.prevChar != nil && i.prevChar.C[1] == yosina.InvalidUnicodeValue {
			var replacementChar rune

			switch c.C[0] {
			case hiraganaIterationMark:
				// Repeat previous hiragana if valid
				if i.prevType == charTypeHiragana {
					replacementChar = i.prevChar.C[0]
				}

			case hiraganaVoicedIterationMark:
				// Repeat previous hiragana with voicing if possible
				if i.prevType == charTypeHiragana {
					if voiced, ok := hiraganaVoicingMap[i.prevChar.C[0]]; ok {
						replacementChar = voiced
					}
				}

			case katakanaIterationMark:
				// Repeat previous katakana if valid
				if i.prevType == charTypeKatakana {
					replacementChar = i.prevChar.C[0]
				}

			case katakanaVoicedIterationMark:
				// Repeat previous katakana with voicing if possible
				if i.prevType == charTypeKatakana {
					if voiced, ok := katakanaVoicingMap[i.prevChar.C[0]]; ok {
						replacementChar = voiced
					}
				}

			case kanjiIterationMark:
				// Repeat previous kanji
				if i.prevType == charTypeKanji {
					replacementChar = i.prevChar.C[0]
				}
			}

			// If we found a valid replacement, create a new character
			if replacementChar != 0 {
				newChar := &yosina.Char{
					C:      [2]rune{replacementChar, yosina.InvalidUnicodeValue},
					Offset: i.offset,
					Source: c,
				}
				i.offset += newChar.RuneLen()

				// Don't update previous character - keep the original one
				// This ensures consecutive iteration marks work correctly

				return newChar
			}
		}
	}

	// Not an iteration mark or couldn't replace it
	// Create a new character with updated offset
	newChar := &yosina.Char{
		C:      c.C,
		Offset: i.offset,
		Source: c.Source,
	}
	i.offset += newChar.RuneLen()

	// Update previous character info
	// If we replaced an iteration mark, the previous character is already set correctly
	// If it's not an iteration mark, update the previous character
	if !isIterationMark(c.C[0]) {
		i.prevChar = newChar
		i.prevType = getCharType(c.C[0])
	}

	return newChar
}

func Transliterate(iter yosina.CharIterator, opts Options) yosina.CharIterator {
	return &japaneseIterationMarksCharIterator{
		CharIterator: iter,
		options:      opts,
	}
}
