package prolonged_sound_marks

import (
	yosina "github.com/yosina-lib/yosina/go"
)

type charType int

const (
	charTypeOther    charType = 0
	charTypeHiragana charType = 0x20
	charTypeKatakana charType = 0x40
	charTypeAlphabet charType = 0x60
	charTypeDigit    charType = 0x80
	charTypeEither   charType = 0xa0
)

const (
	charTypeHalfwidth charType = 1 << iota
	charTypeVowelEnded
	charTypeHatsuon
	charTypeSokuon
	charTypeProlongedSoundMark
)

var specialChars = map[rune]charType{
	'\uff70': charTypeKatakana | charTypeProlongedSoundMark | charTypeHalfwidth,
	'\u30fc': charTypeEither | charTypeProlongedSoundMark,
	'\u3063': charTypeHiragana | charTypeSokuon,
	'\u3093': charTypeHiragana | charTypeHatsuon,
	'\u30c3': charTypeKatakana | charTypeSokuon,
	'\u30f3': charTypeKatakana | charTypeHatsuon,
	'\uff6f': charTypeKatakana | charTypeSokuon | charTypeHalfwidth,
	'\uff9d': charTypeKatakana | charTypeHatsuon | charTypeHalfwidth,
}

func getCharType(c [2]rune) charType {
	if c[1] != yosina.InvalidUnicodeValue {
		return charTypeOther
	}
	if c[0] == yosina.InvalidUnicodeValue {
		return charTypeHalfwidth
	}
	if c[0] >= '0' && c[0] <= '9' {
		return charTypeDigit | charTypeHalfwidth
	}
	if c[0] >= '\uff10' && c[0] <= '\uff19' {
		return charTypeDigit
	}
	if (c[0] >= 'A' && c[0] <= 'Z') || (c[0] >= 'a' && c[0] <= 'z') {
		return charTypeAlphabet | charTypeHalfwidth
	}
	if (c[0] >= '\uff21' && c[0] <= '\uff3a') || (c[0] >= '\uff41' && c[0] <= '\uff5a') {
		return charTypeAlphabet
	}

	if t, ok := specialChars[c[0]]; ok {
		return t
	}

	if (c[0] >= '\u3041' && c[0] <= '\u309c') || c[0] == '\u309f' {
		return charTypeHiragana | charTypeVowelEnded
	}
	if (c[0] >= '\u30a1' && c[0] <= '\u30fa') || (c[0] >= '\u30fd' && c[0] <= '\u30ff') {
		return charTypeKatakana | charTypeVowelEnded
	}
	if (c[0] >= '\uff66' && c[0] <= '\uff6f') || (c[0] >= '\uff71' && c[0] <= '\uff9f') {
		return charTypeKatakana | charTypeVowelEnded | charTypeHalfwidth
	}
	return charTypeOther
}

func (ct charType) isAlnum() bool {
	masked := ct & 0xe0
	return masked == charTypeAlphabet || masked == charTypeDigit
}

func (ct charType) isHalfwidth() bool {
	return (ct & charTypeHalfwidth) != 0
}

func isHyphenLike(c [2]rune) bool {
	return c[1] == yosina.InvalidUnicodeValue && (c[0] == 0x002d ||
		c[0] == 0x2010 ||
		c[0] == 0x2014 ||
		c[0] == 0x2015 ||
		c[0] == 0x2212 ||
		c[0] == 0xff0d ||
		c[0] == 0xff70 ||
		c[0] == 0x30fc)
}

type Options struct {
	SkipAlreadyTransliteratedChars       bool
	AllowProlongedHatsuon                bool
	AllowProlongedSokuon                 bool
	ReplaceProlongedMarksFollowingAlnums bool
}

type charTypePair struct {
	c *yosina.Char
	t charType
}

func (cp charTypePair) isValid() bool {
	return cp.c != nil
}

type prolongedSoundMarksCharIterator struct {
	yosina.CharIterator
	options              Options
	prolongables         charType
	lookaheadBuf         []*yosina.Char
	lookaheadBufIndex    int
	lastNonProlongedChar charTypePair
	offset               int
	eoi                  bool
}

func (i *prolongedSoundMarksCharIterator) Next() *yosina.Char {
reenter:
	if len(i.lookaheadBuf) >= 0 {
		if i.lookaheadBufIndex >= len(i.lookaheadBuf) {
			i.lookaheadBuf = i.lookaheadBuf[:0]
			i.lookaheadBufIndex = 0
		} else {
			c := i.lookaheadBuf[i.lookaheadBufIndex]
			i.lookaheadBufIndex++
			return c
		}
	}
	if i.eoi {
		return nil
	}
	c := i.CharIterator.Next()
	if c == nil {
		return nil
	}
	if isHyphenLike(c.C) {
		if (!i.options.SkipAlreadyTransliteratedChars || !c.IsTransliterated()) && i.lastNonProlongedChar.isValid() {
			if (i.lastNonProlongedChar.t & i.prolongables) != 0 {
				var tc rune
				if i.lastNonProlongedChar.t.isHalfwidth() {
					tc = 0xff70 // FULLWIDTH KATAKANA-HIRAGANA PROLONGED SOUND MARK
				} else {
					tc = 0x30fc // KATAKANA-HIRAGANA PROLONG SOUND MARK
				}
				cc := &yosina.Char{
					C:      [2]rune{tc, yosina.InvalidUnicodeValue},
					Offset: i.offset,
					Source: c,
				}
				i.offset += cc.RuneLen()
				return cc
			}
			if i.options.ReplaceProlongedMarksFollowingAlnums && i.lastNonProlongedChar.t.isAlnum() {
				prevNonProlongedChar := i.lastNonProlongedChar
				for {
					i.lookaheadBuf = append(i.lookaheadBuf, c)
					c = i.CharIterator.Next()
					if c == nil {
						break
					}
					if !isHyphenLike(c.C) {
						break
					}
				}
				if c == nil {
					i.eoi = true
				} else {
					i.lookaheadBuf = append(i.lookaheadBuf, c)
					i.lastNonProlongedChar = charTypePair{c, getCharType(c.C)}
				}
				var halfwidth bool
				if prevNonProlongedChar.isValid() {
					halfwidth = prevNonProlongedChar.t.isHalfwidth()
				} else {
					halfwidth = i.lastNonProlongedChar.t.isHalfwidth()
				}
				var tc rune
				if halfwidth {
					tc = 0x002d // HYPHEN-MINUS
				} else {
					tc = 0xff0d // FULLWIDTH HYPHEN-MINUS
				}
				for j := 0; j < len(i.lookaheadBuf)-1; j++ {
					cc := &yosina.Char{
						C:      [2]rune{tc, yosina.InvalidUnicodeValue},
						Offset: i.offset,
						Source: i.lookaheadBuf[j],
					}
					i.lookaheadBuf[j] = cc
					i.offset += cc.RuneLen()
				}
				i.lookaheadBufIndex = 0
				goto reenter
			}
		}
	} else {
		i.lastNonProlongedChar = charTypePair{c, getCharType(c.C)}
	}
	c = &yosina.Char{
		C:      c.C,
		Offset: i.offset,
		Source: c.Source,
	}
	i.offset += c.RuneLen()
	return c
}

func Transliterate(iter yosina.CharIterator, opts Options) yosina.CharIterator {
	prolongables := charTypeVowelEnded | charTypeProlongedSoundMark
	if opts.AllowProlongedHatsuon {
		prolongables |= charTypeHatsuon
	}
	if opts.AllowProlongedSokuon {
		prolongables |= charTypeSokuon
	}

	return &prolongedSoundMarksCharIterator{
		CharIterator: iter,
		options:      opts,
		prolongables: prolongables,
		lookaheadBuf: make([]*yosina.Char, 0),
	}
}
