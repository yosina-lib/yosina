package historical_hirakatas

import (
	yosina "github.com/yosina-lib/yosina/go"
)

// ConversionMode represents the conversion strategy for historical kana
type ConversionMode int

const (
	// Simple replaces the character with its modern single-character equivalent
	Simple ConversionMode = iota
	// Decompose replaces the character with a multi-character decomposition
	Decompose
	// Skip leaves the character unchanged
	Skip
)

// Options configures the transliterator behavior
type Options struct {
	// Hiraganas controls how historical hiragana (ゐ, ゑ) are converted.
	// Default: Simple (zero value)
	Hiraganas ConversionMode
	// Katakanas controls how historical katakana (ヰ, ヱ) are converted.
	// Default: Simple (zero value)
	Katakanas ConversionMode
	// VoicedKatakanas controls how voiced historical katakana (ヷ, ヸ, ヹ, ヺ) are converted.
	// Default: Skip (use DefaultOptions() to get correct defaults)
	VoicedKatakanas ConversionMode
}

// DefaultOptions returns Options with the correct defaults:
// Hiraganas=Simple, Katakanas=Simple, VoicedKatakanas=Skip.
func DefaultOptions() Options {
	return Options{
		Hiraganas:       Simple,
		Katakanas:       Simple,
		VoicedKatakanas: Skip,
	}
}

// historicalMapping holds the simple and decomposed replacements for a character
type historicalMapping struct {
	simple    []rune
	decompose []rune
}

// Historical hiragana mappings
var historicalHiraganaMappings = map[rune]historicalMapping{
	'\u3090': {simple: []rune{'\u3044'}, decompose: []rune{'\u3046', '\u3043'}}, // ゐ → い / うぃ
	'\u3091': {simple: []rune{'\u3048'}, decompose: []rune{'\u3046', '\u3047'}}, // ゑ → え / うぇ
}

// Historical katakana mappings
var historicalKatakanaMappings = map[rune]historicalMapping{
	'\u30F0': {simple: []rune{'\u30A4'}, decompose: []rune{'\u30A6', '\u30A3'}}, // ヰ → イ / ウィ
	'\u30F1': {simple: []rune{'\u30A8'}, decompose: []rune{'\u30A6', '\u30A7'}}, // ヱ → エ / ウェ
}

// Voiced historical kana mappings: source → small vowel suffix
var voicedHistoricalKanaMappings = map[rune]rune{
	'\u30F7': '\u30A1', // ヷ → ァ
	'\u30F8': '\u30A3', // ヸ → ィ
	'\u30F9': '\u30A7', // ヹ → ェ
	'\u30FA': '\u30A9', // ヺ → ォ
}

// Voiced historical kana decomposed mappings (keyed by base kana, value is small vowel suffix)
var voicedHistoricalKanaDecomposedMappings = map[rune]rune{
	'\u30EF': '\u30A1', // ヷ → ァ
	'\u30F0': '\u30A3', // ヸ → ィ
	'\u30F1': '\u30A7', // ヹ → ェ
	'\u30F2': '\u30A9', // ヺ → ォ
}

const combiningDakuten = '\u3099'
const vu = '\u30F4'
const u = '\u30A6'

type historicalHirakatasCharIterator struct {
	yosina.CharIterator
	opts    Options
	offset  int
	queue   []rune
	source  *yosina.Char
	pending *yosina.Char
}

func (i *historicalHirakatasCharIterator) emitRunes(runes []rune, source *yosina.Char) *yosina.Char {
	firstChar := &yosina.Char{
		C:      [2]rune{runes[0], yosina.InvalidUnicodeValue},
		Offset: i.offset,
		Source: source,
	}
	i.offset += firstChar.RuneLen()

	if len(runes) > 1 {
		i.queue = runes[1:]
		i.source = source
	}

	return firstChar
}

func (i *historicalHirakatasCharIterator) Next() *yosina.Char {
	// If we have queued characters from a previous expansion, return them first
	if len(i.queue) > 0 {
		c := i.queue[0]
		i.queue = i.queue[1:]
		char := &yosina.Char{
			C:      [2]rune{c, yosina.InvalidUnicodeValue},
			Offset: i.offset,
			Source: i.source,
		}
		i.offset += char.RuneLen()
		return char
	}

	var c *yosina.Char
	if i.pending != nil {
		c = i.pending
		i.pending = nil
	} else {
		c = i.CharIterator.Next()
	}
	if c == nil {
		return nil
	}
	if c.IsSentinel() {
		return c
	}

	// Only process single-rune characters
	if c.C[1] == yosina.InvalidUnicodeValue {
		r := c.C[0]

		// Lookahead: peek at next char for combining dakuten
		next := i.CharIterator.Next()
		if next != nil && !next.IsSentinel() &&
			next.C[1] == yosina.InvalidUnicodeValue &&
			next.C[0] == combiningDakuten {
			// Check if current char is a decomposed voiced base
			decomposed, ok := voicedHistoricalKanaDecomposedMappings[r]
			if i.opts.VoicedKatakanas != Decompose || !ok {
				// Pass through base unchanged, keep dakuten as pending
				nc := c.WithOffset(i.offset)
				i.offset += nc.RuneLen()
				i.pending = next
				return nc
			}
			// Emit U + dakuten + small vowel
			return i.emitRunes([]rune{u, combiningDakuten, decomposed}, c)
		}
		// Next char was not a combining dakuten; store it and fall through
		i.pending = next

		// Historical hiragana
		if i.opts.Hiraganas != Skip {
			if m, ok := historicalHiraganaMappings[r]; ok {
				if i.opts.Hiraganas == Decompose {
					return i.emitRunes(m.decompose, c)
				}
				return i.emitRunes(m.simple, c)
			}
		}

		// Historical katakana
		if i.opts.Katakanas != Skip {
			if m, ok := historicalKatakanaMappings[r]; ok {
				if i.opts.Katakanas == Decompose {
					return i.emitRunes(m.decompose, c)
				}
				return i.emitRunes(m.simple, c)
			}
		}

		// Voiced historical kana (composed form)
		if i.opts.VoicedKatakanas == Decompose {
			if vowel, ok := voicedHistoricalKanaMappings[r]; ok {
				return i.emitRunes([]rune{vu, vowel}, c)
			}
		}
	}

	// Return unchanged
	nc := c.WithOffset(i.offset)
	i.offset += nc.RuneLen()
	return nc
}

// Transliterate creates a character iterator that converts historical hiragana/katakana
func Transliterate(i yosina.CharIterator, opts Options) yosina.CharIterator {
	return &historicalHirakatasCharIterator{
		CharIterator: i,
		opts:         opts,
		offset:       0,
	}
}
