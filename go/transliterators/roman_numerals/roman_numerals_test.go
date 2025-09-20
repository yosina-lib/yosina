package roman_numerals

import (
	"testing"

	"github.com/stretchr/testify/assert"
	yosina "github.com/yosina-lib/yosina/go"
)

func transliterate(input string) string {
	chars := yosina.BuildCharArray(input)
	iter := yosina.NewCharIteratorFromSlice(chars)
	result := Transliterate(iter)
	return yosina.StringFromChars(result)
}

func TestUppercaseRomanNumerals(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "Roman I",
			input:    "Ⅰ",
			expected: "I",
		},
		{
			name:     "Roman II",
			input:    "Ⅱ",
			expected: "II",
		},
		{
			name:     "Roman III",
			input:    "Ⅲ",
			expected: "III",
		},
		{
			name:     "Roman IV",
			input:    "Ⅳ",
			expected: "IV",
		},
		{
			name:     "Roman V",
			input:    "Ⅴ",
			expected: "V",
		},
		{
			name:     "Roman VI",
			input:    "Ⅵ",
			expected: "VI",
		},
		{
			name:     "Roman VII",
			input:    "Ⅶ",
			expected: "VII",
		},
		{
			name:     "Roman VIII",
			input:    "Ⅷ",
			expected: "VIII",
		},
		{
			name:     "Roman IX",
			input:    "Ⅸ",
			expected: "IX",
		},
		{
			name:     "Roman X",
			input:    "Ⅹ",
			expected: "X",
		},
		{
			name:     "Roman XI",
			input:    "Ⅺ",
			expected: "XI",
		},
		{
			name:     "Roman XII",
			input:    "Ⅻ",
			expected: "XII",
		},
		{
			name:     "Roman L",
			input:    "Ⅼ",
			expected: "L",
		},
		{
			name:     "Roman C",
			input:    "Ⅽ",
			expected: "C",
		},
		{
			name:     "Roman D",
			input:    "Ⅾ",
			expected: "D",
		},
		{
			name:     "Roman M",
			input:    "Ⅿ",
			expected: "M",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := transliterate(tt.input)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestLowercaseRomanNumerals(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "Roman i",
			input:    "ⅰ",
			expected: "i",
		},
		{
			name:     "Roman ii",
			input:    "ⅱ",
			expected: "ii",
		},
		{
			name:     "Roman iii",
			input:    "ⅲ",
			expected: "iii",
		},
		{
			name:     "Roman iv",
			input:    "ⅳ",
			expected: "iv",
		},
		{
			name:     "Roman v",
			input:    "ⅴ",
			expected: "v",
		},
		{
			name:     "Roman vi",
			input:    "ⅵ",
			expected: "vi",
		},
		{
			name:     "Roman vii",
			input:    "ⅶ",
			expected: "vii",
		},
		{
			name:     "Roman viii",
			input:    "ⅷ",
			expected: "viii",
		},
		{
			name:     "Roman ix",
			input:    "ⅸ",
			expected: "ix",
		},
		{
			name:     "Roman x",
			input:    "ⅹ",
			expected: "x",
		},
		{
			name:     "Roman xi",
			input:    "ⅺ",
			expected: "xi",
		},
		{
			name:     "Roman xii",
			input:    "ⅻ",
			expected: "xii",
		},
		{
			name:     "Roman l",
			input:    "ⅼ",
			expected: "l",
		},
		{
			name:     "Roman c",
			input:    "ⅽ",
			expected: "c",
		},
		{
			name:     "Roman d",
			input:    "ⅾ",
			expected: "d",
		},
		{
			name:     "Roman m",
			input:    "ⅿ",
			expected: "m",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := transliterate(tt.input)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestMixedText(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "Year with Roman numeral",
			input:    "Year Ⅻ",
			expected: "Year XII",
		},
		{
			name:     "Chapter with lowercase Roman",
			input:    "Chapter ⅳ",
			expected: "Chapter iv",
		},
		{
			name:     "Section with Roman and period",
			input:    "Section Ⅲ.A",
			expected: "Section III.A",
		},
		{
			name:     "Multiple uppercase Romans",
			input:    "Ⅰ Ⅱ Ⅲ",
			expected: "I II III",
		},
		{
			name:     "Multiple lowercase Romans",
			input:    "ⅰ, ⅱ, ⅲ",
			expected: "i, ii, iii",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := transliterate(tt.input)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestEdgeCases(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "Empty string",
			input:    "",
			expected: "",
		},
		{
			name:     "No Roman numerals",
			input:    "ABC123",
			expected: "ABC123",
		},
		{
			name:     "Consecutive Romans",
			input:    "ⅠⅡⅢ",
			expected: "IIIIII",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := transliterate(tt.input)
			assert.Equal(t, tt.expected, result)
		})
	}
}
