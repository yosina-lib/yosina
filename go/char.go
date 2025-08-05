package yosina

import (
	"strings"
	"unicode/utf8"
)

const (
	InvalidUnicodeValue = rune(0x7fffffff)
)

// Char represents a character with metadata for transliteration.
type Char struct {
	// C is the character string (may be multiple Unicode code points).
	C [2]rune
	// Offset is the byte offset in the original string.
	Offset int
	// Source is the original character this was derived from (for tracking transformations).
	Source *Char
}

// IsSentinel returns true if this is a sentinel character (empty string).
func (c *Char) IsSentinel() bool {
	return c.C[0] == InvalidUnicodeValue
}

// RuneLen returns the length of the character in runes.
func (c *Char) RuneLen() int {
	if c.C[0] == InvalidUnicodeValue {
		return 0
	}
	l := utf8.RuneLen(c.C[0])
	if c.C[1] != InvalidUnicodeValue {
		l += utf8.RuneLen(c.C[1])
	}
	return l
}

// IsTransliterated returns true if this character has been transliterated.
func (c *Char) IsTransliterated() bool {
	for {
		s := c.Source
		if s == nil {
			break
		}
		if c.C != s.C {
			return true
		}
		c = s
	}
	return false
}

func (c *Char) WithOffset(offset int) *Char {
	return &Char{
		C:      c.C,
		Offset: offset,
		Source: c,
	}
}

// BuildCharArray converts a text string into an array of Char objects,
// properly handling Ideographic Variation Sequences (IVS) and
// Standardized Variation Sequences (SVS).
func BuildCharArray(text string) []*Char {
	result := make([]*Char, 0, len(text)/3+1)
	pr := InvalidUnicodeValue
	po := -1
	for o, r := range text {
		if pr != InvalidUnicodeValue {
			// Variation Selector-1 to Variation Selector-16 (U+FE00–U+FE0F)
			// Variation Selector-17 to Variation Selector-256 (U+E0100–U+E01EF)
			if (r >= 0xFE00 && r <= 0xFE0F) || (r >= 0xE0100 && r <= 0xE01EF) {
				// Combine base character with variation selector
				result = append(result, &Char{
					C:      [2]rune{pr, r},
					Offset: po,
					Source: nil,
				})
				pr = InvalidUnicodeValue
				continue
			}
			// Regular character, reset lookahead
			result = append(result, &Char{
				C:      [2]rune{pr, InvalidUnicodeValue},
				Offset: po,
				Source: nil,
			})
		}
		pr = r
		po = o
	}
	if pr != InvalidUnicodeValue {
		// Last character without variation selector
		result = append(result, &Char{
			C:      [2]rune{pr, InvalidUnicodeValue},
			Offset: po,
			Source: nil,
		})
	}

	// Add sentinel
	result = append(result, &Char{
		C:      [2]rune{InvalidUnicodeValue, InvalidUnicodeValue},
		Offset: len(text),
		Source: nil,
	})

	return result
}

// CharIterator provides iteration over Char slices
type CharIterator interface {
	// Next returns the next character or nil if no more characters
	Next() *Char
	// Count returns the number of characters in the iterator if known, or -1 if unknown
	Count() int
}

type sliceCharIterator struct {
	chars []*Char
	index int
}

// Next returns the next character or nil if no more characters
func (it *sliceCharIterator) Next() *Char {
	if it.index >= len(it.chars) {
		return nil
	}
	char := it.chars[it.index]
	it.index++
	return char
}

// Count returns the number of characters
func (it *sliceCharIterator) Count() int {
	return len(it.chars)
}

// NewCharIteratorFromSlice creates a new iterator from a slice of Chars
func NewCharIteratorFromSlice(chars []*Char) CharIterator {
	return &sliceCharIterator{
		chars: chars,
		index: 0,
	}
}

// FromChars converts an array of Char objects back to a string,
// filtering out sentinel characters.
func StringFromChars(i CharIterator) string {
	var builder strings.Builder
	count := i.Count()
	if count >= 0 {
		builder.Grow(count * 3)
	}
	for {
		c := i.Next()
		if c == nil {
			break
		}
		if !c.IsSentinel() {
			builder.WriteRune(c.C[0])
			if c.C[1] != InvalidUnicodeValue {
				builder.WriteRune(c.C[1])
			}
		}
	}
	return builder.String()
}
