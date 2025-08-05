package hira_kata

import (
	"sync"

	yosina "github.com/yosina-lib/yosina/go"
	"github.com/yosina-lib/yosina/go/transliterators/internal"
)

// Mode represents the conversion direction
type Mode int

const (
	// HiraToKata converts Hiragana to Katakana
	HiraToKata Mode = iota
	// KataToHira converts Katakana to Hiragana
	KataToHira
)

// Options configures the transliterator behavior
type Options struct {
	Mode Mode
}

// mappingCache stores the generated mapping tables
var mappingCache = struct {
	sync.RWMutex
	cache map[Mode]map[rune]rune
}{
	cache: make(map[Mode]map[rune]rune),
}

// buildMappingTable creates a mapping table for the specified mode
func buildMappingTable(mode Mode) map[rune]rune {
	// Check cache first
	mappingCache.RLock()
	if table, ok := mappingCache.cache[mode]; ok {
		mappingCache.RUnlock()
		return table
	}
	mappingCache.RUnlock()

	// Build new table
	mapping := make(map[rune]rune)

	// Main table mappings
	for _, entry := range internal.HiraganaKatakanaTable {
		if entry.Hiragana != nil {
			hira := entry.Hiragana
			kata := entry.Katakana

			if mode == HiraToKata {
				if hira.Base >= 0 && kata.Base >= 0 {
					mapping[hira.Base] = kata.Base
				}
				if hira.Voiced >= 0 && kata.Voiced >= 0 {
					mapping[hira.Voiced] = kata.Voiced
				}
				if hira.Semivoiced >= 0 && kata.Semivoiced >= 0 {
					mapping[hira.Semivoiced] = kata.Semivoiced
				}
			} else {
				if kata.Base >= 0 && hira.Base >= 0 {
					mapping[kata.Base] = hira.Base
				}
				if kata.Voiced >= 0 && hira.Voiced >= 0 {
					mapping[kata.Voiced] = hira.Voiced
				}
				if kata.Semivoiced >= 0 && hira.Semivoiced >= 0 {
					mapping[kata.Semivoiced] = hira.Semivoiced
				}
			}
		}
	}

	// Small character mappings
	for _, entry := range internal.HiraganaKatakanaSmallTable {
		if mode == HiraToKata {
			if entry.Hiragana >= 0 && entry.Katakana >= 0 {
				mapping[entry.Hiragana] = entry.Katakana
			}
		} else {
			if entry.Katakana >= 0 && entry.Hiragana >= 0 {
				mapping[entry.Katakana] = entry.Hiragana
			}
		}
	}

	// Cache the result
	mappingCache.Lock()
	mappingCache.cache[mode] = mapping
	mappingCache.Unlock()

	return mapping
}

type hiraKataCharIterator struct {
	yosina.CharIterator
	table  map[rune]rune
	offset int
}

func (i *hiraKataCharIterator) Next() *yosina.Char {
	c := i.CharIterator.Next()
	if c == nil {
		return nil
	}

	// Only process single-rune characters
	if c.C[1] == yosina.InvalidUnicodeValue {
		if mapped, ok := i.table[c.C[0]]; ok {
			nc := &yosina.Char{
				C:      [2]rune{mapped, yosina.InvalidUnicodeValue},
				Offset: i.offset,
				Source: c,
			}
			i.offset += nc.RuneLen()
			return nc
		}
	}

	// Return unchanged
	nc := c.WithOffset(i.offset)
	i.offset += nc.RuneLen()
	return nc
}

// Transliterate creates a character iterator that converts between hiragana and katakana
func Transliterate(i yosina.CharIterator, opts Options) yosina.CharIterator {
	table := buildMappingTable(opts.Mode)

	return &hiraKataCharIterator{
		CharIterator: i,
		table:        table,
		offset:       0,
	}
}
