package emitter

import (
	"github.com/yosina-lib/yosina/go/internal/codegen/data"
)

// GenerateRomanNumeralsTransliterator generates a roman numerals transliterator
func (em *Emitter) GenerateRomanNumeralsTransliterator(name string, records []data.RomanNumeralsRecord) ([]Artifact, error) {
	// For now, create simple mappings for upper to decomposed upper and lower to decomposed lower
	// This will convert roman numeral characters to their ASCII equivalents
	upperToDecomposed := make(map[data.UCodepoint][]string)
	lowerToDecomposed := make(map[data.UCodepoint][]string)

	for _, record := range records {
		// Map upper roman numeral to its decomposed form
		if len(record.Decomposed.Upper) > 0 {
			decomposed := make([]string, len(record.Decomposed.Upper))
			for i, cp := range record.Decomposed.Upper {
				decomposed[i] = string(rune(cp))
			}
			upperToDecomposed[record.Codes.Upper] = decomposed
		}

		// Map lower roman numeral to its decomposed form
		if len(record.Decomposed.Lower) > 0 {
			decomposed := make([]string, len(record.Decomposed.Lower))
			for i, cp := range record.Decomposed.Lower {
				decomposed[i] = string(rune(cp))
			}
			lowerToDecomposed[record.Codes.Lower] = decomposed
		}
	}

	// Combine both mappings
	allMappings := make(map[data.UCodepoint][]string)
	for k, v := range upperToDecomposed {
		allMappings[k] = v
	}
	for k, v := range lowerToDecomposed {
		allMappings[k] = v
	}

	// Generate as a combined transliterator since it maps single chars to multiple chars
	return em.GenerateCombinedTransliterator(name, allMappings)
}
