package ivs_svs_base

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestIvsSvsBaseTransliterator(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
		opts     Options
	}{
		// Base mode tests (IVS/SVS -> base)
		{
			name:     "IVS to base character - unijis2004",
			input:    "葛\U000E0100", // 葛 + VS17
			expected: "葛\U000E0100",
			opts: Options{
				Mode:    ModeBase,
				Charset: CharsetUnijis2004,
			},
		},
		{
			name:     "SVS to base character - unijis2004",
			input:    "葛\uFE00", // 葛 + VS1
			expected: "葛\uFE00",
			opts: Options{
				Mode:    ModeBase,
				Charset: CharsetUnijis2004,
			},
		},
		{
			name:     "IVS to base character - unijis90",
			input:    "葛\U000E0100", // 葛 + VS17
			expected: "葛",
			opts: Options{
				Mode:    ModeBase,
				Charset: CharsetUnijis90,
			},
		},
		{
			name:     "SVS to base character - unijis90",
			input:    "\u559d\uFE00", // 葛 + VS1
			expected: "\uFA36",
			opts: Options{
				Mode:    ModeBase,
				Charset: CharsetUnijis90,
			},
		},
		{
			name:     "Drop variation selector altogether",
			input:    "葛\U000E0100", // 葛 + VS17
			expected: "葛",
			opts: Options{
				Mode:                    ModeBase,
				DropSelectorsAltogether: true,
				Charset:                 CharsetUnijis2004,
			},
		},
		{
			name:     "Unknown variation selector - drop if DropSelectorsAltogether",
			input:    "A\uFE0F", // A + VS16
			expected: "A",
			opts: Options{
				Mode:                    ModeBase,
				DropSelectorsAltogether: true,
				Charset:                 CharsetUnijis2004,
			},
		},
		{
			name:     "Unknown variation selector - keep if not DropSelectorsAltogether",
			input:    "A\uFE0F", // A + VS16
			expected: "A\uFE0F",
			opts: Options{
				Mode:                    ModeBase,
				DropSelectorsAltogether: false,
				Charset:                 CharsetUnijis2004,
			},
		},

		// IvsOrSvs mode tests (base -> IVS/SVS)
		{
			name:     "Base to IVS - unijis2004",
			input:    "\uFA36",
			expected: "\u559d\U000E0101", // 喝󠄀 + VS17
			opts: Options{
				Mode:      ModeIvsOrSvs,
				Charset:   CharsetUnijis2004,
				PreferSvs: false,
			},
		},
		{
			name:     "Base to SVS - unijis2004 with PreferSvs",
			input:    "\ufa36",
			expected: "\u559d\ufe00", // 喝󠄀 + VS1
			opts: Options{
				Mode:      ModeIvsOrSvs,
				Charset:   CharsetUnijis2004,
				PreferSvs: true,
			},
		},
		{
			name:     "Base to IVS - unijis90",
			input:    "\ufa36",
			expected: "\u559d\U000E0101", // 喝󠄀 + VS17
			opts: Options{
				Mode:      ModeIvsOrSvs,
				Charset:   CharsetUnijis90,
				PreferSvs: false,
			},
		},
		{
			name:     "Base to SVS - unijis90 with PreferSvs",
			input:    "\ufa36",
			expected: "\u559d\ufe00", // 喝󠄀 + VS17
			opts: Options{
				Mode:      ModeIvsOrSvs,
				Charset:   CharsetUnijis90,
				PreferSvs: true,
			},
		},

		// Edge cases
		{
			name:     "Empty string",
			input:    "",
			expected: "",
			opts:     DefaultOptions,
		},
		{
			name:     "String with no IVS/SVS characters",
			input:    "Hello, World!",
			expected: "Hello, World!",
			opts:     DefaultOptions,
		},
		{
			name:     "Mixed content with IVS",
			input:    "Text 葛\U000E0100 more text",
			expected: "Text 葛 more text",
			opts: Options{
				Mode:    ModeBase,
				Charset: CharsetUnijis90,
			},
		},
		{
			name:     "Multiple variation selectors",
			input:    "葛\U000E0101辻\U000E0101",
			expected: "葛辻",
			opts: Options{
				Mode:    ModeBase,
				Charset: CharsetUnijis2004,
			},
		},
		{
			name:     "Variation selector at start of string",
			input:    "\uFE00text",
			expected: "\uFE00text", // Should not affect standalone VS
			opts:     DefaultOptions,
		},
		{
			name:     "Consecutive variation selectors",
			input:    "葛\U000E0101\uFE00",
			expected: "葛\uFE00", // Only first VS should be processed with base char
			opts: Options{
				Mode:    ModeBase,
				Charset: CharsetUnijis2004,
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := yosina.BuildCharArray(tt.input)
			iter := yosina.NewCharIteratorFromSlice(chars)
			transliteratedIter := Transliterate(iter, tt.opts)
			result := yosina.StringFromChars(transliteratedIter)

			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestIvsSvsBaseDefaultOptions(t *testing.T) {
	expected := Options{
		Mode:                    ModeBase,
		DropSelectorsAltogether: false,
		Charset:                 CharsetUnijis2004,
		PreferSvs:               false,
	}

	assert.Equal(t, expected, DefaultOptions)
}

func TestIvsSvsBaseConstants(t *testing.T) {
	// Test Mode constants
	assert.Equal(t, Mode("ivs-or-svs"), ModeIvsOrSvs)
	assert.Equal(t, Mode("base"), ModeBase)
}

func TestIvsSvsBaseVariationSelectorRanges(t *testing.T) {
	tests := []struct {
		name       string
		input      string
		expected   string
		shouldDrop bool
	}{
		{
			name:       "VS1 (U+FE00)",
			input:      "A\uFE00",
			expected:   "A",
			shouldDrop: true,
		},
		{
			name:       "VS16 (U+FE0F)",
			input:      "A\uFE0F",
			expected:   "A",
			shouldDrop: true,
		},
		{
			name:       "IVS VS17 (U+E0100)",
			input:      "A\U000E0100",
			expected:   "A",
			shouldDrop: true,
		},
		{
			name:       "IVS VS256 (U+E01EF)",
			input:      "A\U000E01EF",
			expected:   "A",
			shouldDrop: true,
		},
		{
			name:       "Non-VS character after base",
			input:      "AB",
			expected:   "AB",
			shouldDrop: false,
		},
		{
			name:       "Character just before VS range",
			input:      "A\uFDFF",
			expected:   "A\uFDFF",
			shouldDrop: false,
		},
		{
			name:       "Character just after VS range",
			input:      "A\uFE10",
			expected:   "A\uFE10",
			shouldDrop: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := yosina.BuildCharArray(tt.input)
			iter := yosina.NewCharIteratorFromSlice(chars)
			opts := Options{
				Mode:                    ModeBase,
				DropSelectorsAltogether: true,
				Charset:                 CharsetUnijis2004,
			}
			transliteratedIter := Transliterate(iter, opts)
			result := yosina.StringFromChars(transliteratedIter)

			if tt.shouldDrop {
				assert.Equal(t, tt.expected, result)
			} else {
				assert.Equal(t, tt.input, result)
			}
		})
	}
}

func TestIvsSvsBasePerformance(t *testing.T) {
	// Test with a large string containing various IVS/SVS characters
	largeInput := ""
	for i := 0; i < 1000; i++ {
		largeInput += "Text 葛\U000E0101 and 辻\U000E0101 mixed "
	}

	chars := yosina.BuildCharArray(largeInput)
	iter := yosina.NewCharIteratorFromSlice(chars)
	transliteratedIter := Transliterate(iter, DefaultOptions)
	result := yosina.StringFromChars(transliteratedIter)

	assert.NotEmpty(t, result, "Expected non-empty result for large input")
	assert.Contains(t, result, "葛", "Should contain base characters")
	assert.NotContains(t, result, "\U000E0101", "Should not contain IVS in base mode")
}

func TestIvsSvsBaseNilIterator(t *testing.T) {
	// Test behavior with empty iterator
	chars := yosina.BuildCharArray("")
	iter := yosina.NewCharIteratorFromSlice(chars)
	transliteratedIter := Transliterate(iter)

	assert.True(t, transliteratedIter.Next().IsSentinel())
	assert.Nil(t, transliteratedIter.Next())
}

func TestIvsSvsBaseUnicodeNormalization(t *testing.T) {
	// Test that the transliterator handles pre-composed vs decomposed forms correctly
	tests := []struct {
		name     string
		input    string
		expected string
		opts     Options
	}{
		{
			name:     "Precomposed character with VS",
			input:    "é\uFE00", // é (U+00E9) + VS1
			expected: "é",
			opts: Options{
				Mode:                    ModeBase,
				DropSelectorsAltogether: true,
				Charset:                 CharsetUnijis2004,
			},
		},
		{
			name:     "Surrogate pair handling",
			input:    "𠮷\uFE00", // 𠮷 (U+20BB7) + VS1
			expected: "𠮷",
			opts: Options{
				Mode:                    ModeBase,
				DropSelectorsAltogether: true,
				Charset:                 CharsetUnijis2004,
			},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := yosina.BuildCharArray(tt.input)
			iter := yosina.NewCharIteratorFromSlice(chars)
			transliteratedIter := Transliterate(iter, tt.opts)
			result := yosina.StringFromChars(transliteratedIter)

			assert.Equal(t, tt.expected, result)
		})
	}
}

func BenchmarkIvsSvsBaseTransliterator(b *testing.B) {
	input := "This is a test string with 葛\U000E0100 and 辻\uFE00 characters."
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter, DefaultOptions)
		_ = yosina.StringFromChars(transliteratedIter)
	}
}

func BenchmarkIvsSvsBaseTransliteratorLargeInput(b *testing.B) {
	input := ""
	for i := 0; i < 100; i++ {
		input += "Text with 葛\U000E0100 IVS and 辻\uFE00 SVS characters "
	}
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter, DefaultOptions)
		_ = yosina.StringFromChars(transliteratedIter)
	}
}

func BenchmarkIvsSvsBaseModeComparison(b *testing.B) {
	input := "葛\U000E0100辻\uFE00"
	chars := yosina.BuildCharArray(input)

	b.Run("ModeBase", func(b *testing.B) {
		opts := Options{
			Mode:    ModeBase,
			Charset: CharsetUnijis2004,
		}
		for i := 0; i < b.N; i++ {
			iter := yosina.NewCharIteratorFromSlice(chars)
			transliteratedIter := Transliterate(iter, opts)
			_ = yosina.StringFromChars(transliteratedIter)
		}
	})

	b.Run("ModeIvsOrSvs", func(b *testing.B) {
		opts := Options{
			Mode:    ModeIvsOrSvs,
			Charset: CharsetUnijis2004,
		}
		for i := 0; i < b.N; i++ {
			iter := yosina.NewCharIteratorFromSlice(chars)
			transliteratedIter := Transliterate(iter, opts)
			_ = yosina.StringFromChars(transliteratedIter)
		}
	})
}
