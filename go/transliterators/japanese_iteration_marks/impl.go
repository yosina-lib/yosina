package japanese_iteration_marks

import (
	yosina "github.com/yosina-lib/yosina/go"
)

// Iteration mark characters
const (
	hiraganaIterationMark               = '\u309d' // ゝ
	hiraganaVoicedIterationMark         = '\u309e' // ゞ
	verticalHiraganaIterationMark       = '\u3031' // 〱
	verticalHiraganaVoicedIterationMark = '\u3032' // 〲
	katakanaIterationMark               = '\u30fd' // ヽ
	katakanaVoicedIterationMark         = '\u30fe' // ヾ
	verticalKatakanaIterationMark       = '\u3033' // 〳
	verticalKatakanaVoicedIterationMark = '\u3034' // 〴
	kanjiIterationMark                  = '\u3005' // 々
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

// Reverse voicing maps (voiced to unvoiced)
var hiraganaUnvoicingMap = func() map[rune]rune {
	m := make(map[rune]rune)
	for k, v := range hiraganaVoicingMap {
		m[v] = k
	}
	return m
}()

var katakanaUnvoicingMap = func() map[rune]rune {
	m := make(map[rune]rune)
	for k, v := range katakanaVoicingMap {
		m[v] = k
	}
	return m
}()

// Semi-voiced characters map (these have handakuten)
var semiVoicedChars = map[rune]bool{
	// Hiragana semi-voiced
	'ぱ': true, 'ぴ': true, 'ぷ': true, 'ぺ': true, 'ぽ': true,
	// Katakana semi-voiced
	'パ': true, 'ピ': true, 'プ': true, 'ペ': true, 'ポ': true,
}

func getCharType(r [2]rune) charType {
	// Check for invalid value
	if r[0] == yosina.InvalidUnicodeValue {
		return charTypeOther
	}

	if r[1] == yosina.InvalidUnicodeValue {
		// Hatsuon (ん/ン)
		if r[0] == 'ん' || r[0] == 'ン' {
			return charTypeHatsuon
		}

		// Sokuon (っ/ッ)
		if r[0] == 'っ' || r[0] == 'ッ' {
			return charTypeSokuon
		}

		// Check if voiced
		if _, ok := voicedChars[r[0]]; ok {
			return charTypeVoiced
		}

		// Check if semi-voiced
		if semiVoicedChars[r[0]] {
			return charTypeSemiVoiced
		}

		// Hiragana range (excluding small characters and special marks)
		if r[0] >= '\u3041' && r[0] <= '\u3096' {
			return charTypeHiragana
		}

		// Katakana range (excluding small characters and special marks)
		if r[0] >= '\u30a1' && r[0] <= '\u30fa' {
			return charTypeKatakana
		}
	}

	// CJK Unified Ideographs (common kanji range)
	if (r[0] >= '\u4e00' && r[0] <= '\u9fff') ||
		(r[0] >= '\u3400' && r[0] <= '\u4dbf') || // CJK Extension A
		(r[0] >= 0x20000 && r[0] <= 0x2a6df) || // CJK Extension B
		(r[0] >= 0x2a700 && r[0] <= 0x2b73f) || // CJK Extension C
		(r[0] >= 0x2b740 && r[0] <= 0x2b81f) || // CJK Extension D
		(r[0] >= 0x2b820 && r[0] <= 0x2ceaf) || // CJK Extension E
		(r[0] >= 0x2ceb0 && r[0] <= 0x2ebef) || // CJK Extension F
		(r[0] >= 0x30000 && r[0] <= 0x3134f) { // CJK Extension G
		return charTypeKanji
	}

	return charTypeOther
}

func isIterationMark(r [2]rune) bool {
	return r[1] == yosina.InvalidUnicodeValue && (r[0] == hiraganaIterationMark ||
		r[0] == hiraganaVoicedIterationMark ||
		r[0] == verticalHiraganaIterationMark ||
		r[0] == verticalHiraganaVoicedIterationMark ||
		r[0] == katakanaIterationMark ||
		r[0] == katakanaVoicedIterationMark ||
		r[0] == verticalKatakanaIterationMark ||
		r[0] == verticalKatakanaVoicedIterationMark ||
		r[0] == kanjiIterationMark)
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
	if isIterationMark(c.C) {
		// We have an iteration mark, check if we can replace it
		if i.prevChar != nil {
			replacementChar := [2]rune{yosina.InvalidUnicodeValue, yosina.InvalidUnicodeValue}

			switch c.C[0] {
			case hiraganaIterationMark, verticalHiraganaIterationMark:
				// Repeat previous hiragana if valid
				if i.prevType == charTypeHiragana {
					replacementChar = i.prevChar.C
				} else if i.prevType == charTypeVoiced {
					// Voiced character followed by unvoiced iteration mark
					if unvoiced, ok := hiraganaUnvoicingMap[i.prevChar.C[0]]; ok {
						replacementChar = [2]rune{unvoiced, yosina.InvalidUnicodeValue}
					}
				}

			case hiraganaVoicedIterationMark, verticalHiraganaVoicedIterationMark:
				if i.prevType == charTypeHiragana {
					if voiced, ok := hiraganaVoicingMap[i.prevChar.C[0]]; ok {
						replacementChar = [2]rune{voiced, yosina.InvalidUnicodeValue}
					}
				} else if i.prevType == charTypeVoiced {
					// Voiced character followed by voiced iteration mark
					replacementChar = i.prevChar.C
				}

			case katakanaIterationMark, verticalKatakanaIterationMark:
				if i.prevType == charTypeKatakana {
					replacementChar = i.prevChar.C
				} else if i.prevType == charTypeVoiced {
					// Voiced character followed by unvoiced iteration mark
					if unvoiced, ok := katakanaUnvoicingMap[i.prevChar.C[0]]; ok {
						replacementChar = [2]rune{unvoiced, yosina.InvalidUnicodeValue}
					}
				}

			case katakanaVoicedIterationMark, verticalKatakanaVoicedIterationMark:
				if i.prevType == charTypeKatakana {
					if voiced, ok := katakanaVoicingMap[i.prevChar.C[0]]; ok {
						replacementChar = [2]rune{voiced, yosina.InvalidUnicodeValue}
					}
				} else if i.prevType == charTypeVoiced {
					// Voiced character followed by voiced iteration mark
					replacementChar = i.prevChar.C
				}

			case kanjiIterationMark:
				// Repeat previous kanji
				if i.prevType == charTypeKanji {
					replacementChar = i.prevChar.C
				}
			}

			// If we found a valid replacement, create a new character
			if replacementChar[0] != yosina.InvalidUnicodeValue {
				newChar := &yosina.Char{
					C:      replacementChar,
					Offset: i.offset,
					Source: c,
				}
				i.offset += newChar.RuneLen()
				i.prevChar = nil
				return newChar
			}
		}
	}

	// Not an iteration mark or couldn't replace it
	// Create a new character with updated offset
	newChar := c.WithOffset(i.offset)
	i.offset += newChar.RuneLen()

	i.prevChar = c
	i.prevType = getCharType(c.C)

	return newChar
}

func Transliterate(iter yosina.CharIterator, opts Options) yosina.CharIterator {
	return &japaneseIterationMarksCharIterator{
		CharIterator: iter,
		options:      opts,
	}
}
