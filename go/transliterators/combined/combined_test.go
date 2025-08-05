package combined

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestCombinedTransliterator(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "null symbol to NUL",
			input:    "␀",
			expected: "NUL",
		},
		{
			name:     "start of heading to SOH",
			input:    "␁",
			expected: "SOH",
		},
		{
			name:     "start of text to STX",
			input:    "␂",
			expected: "STX",
		},
		{
			name:     "backspace to BS",
			input:    "␈",
			expected: "BS",
		},
		{
			name:     "horizontal tab to HT",
			input:    "␉",
			expected: "HT",
		},
		{
			name:     "carriage return to CR",
			input:    "␍",
			expected: "CR",
		},
		{
			name:     "space symbol to SP",
			input:    "␠",
			expected: "SP",
		},
		{
			name:     "delete symbol to DEL",
			input:    "␡",
			expected: "DEL",
		},
		{
			name:     "parenthesized number 1",
			input:    "⑴",
			expected: "(1)",
		},
		{
			name:     "parenthesized number 5",
			input:    "⑸",
			expected: "(5)",
		},
		{
			name:     "parenthesized number 10",
			input:    "⑽",
			expected: "(10)",
		},
		{
			name:     "parenthesized number 20",
			input:    "⒇",
			expected: "(20)",
		},
		{
			name:     "period number 1",
			input:    "⒈",
			expected: "1.",
		},
		{
			name:     "period number 10",
			input:    "⒑",
			expected: "10.",
		},
		{
			name:     "period number 20",
			input:    "⒛",
			expected: "20.",
		},
		{
			name:     "parenthesized letter a",
			input:    "⒜",
			expected: "(a)",
		},
		{
			name:     "parenthesized letter z",
			input:    "⒵",
			expected: "(z)",
		},
		{
			name:     "parenthesized kanji ichi",
			input:    "㈠",
			expected: "(一)",
		},
		{
			name:     "parenthesized kanji getsu",
			input:    "㈪",
			expected: "(月)",
		},
		{
			name:     "parenthesized kanji kabu",
			input:    "㈱",
			expected: "(株)",
		},
		{
			name:     "japanese unit apaato",
			input:    "㌀",
			expected: "アパート",
		},
		{
			name:     "japanese unit kiro",
			input:    "㌔",
			expected: "キロ",
		},
		{
			name:     "japanese unit meetoru",
			input:    "㍍",
			expected: "メートル",
		},
		{
			name:     "scientific unit hPa",
			input:    "㍱",
			expected: "hPa",
		},
		{
			name:     "scientific unit kHz",
			input:    "㎑",
			expected: "kHz",
		},
		{
			name:     "scientific unit kg",
			input:    "㎏",
			expected: "kg",
		},
		{
			name:     "combined control and numbers",
			input:    "␉⑴␠⒈",
			expected: "HT(1)SP1.",
		},
		{
			name:     "combined with regular text",
			input:    "Hello ⑴ World ␉",
			expected: "Hello (1) World HT",
		},
		{
			name:     "empty string",
			input:    "",
			expected: "",
		},
		{
			name:     "unmapped characters",
			input:    "hello world 123 abc こんにちは",
			expected: "hello world 123 abc こんにちは",
		},
		{
			name:     "sequence of combined characters",
			input:    "␀␁␂␃␄",
			expected: "NULSOHSTXETXEOT",
		},
		{
			name:     "japanese months",
			input:    "㋀㋁㋂",
			expected: "1月2月3月",
		},
		{
			name:     "japanese units combinations",
			input:    "㌀㌁㌂",
			expected: "アパートアルファアンペア",
		},
		{
			name:     "scientific measurements",
			input:    "\u3378\u3379\u337a",
			expected: "dm2dm3IU",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := yosina.BuildCharArray(tt.input)
			iter := yosina.NewCharIteratorFromSlice(chars)
			transliteratedIter := Transliterate(iter)
			result := yosina.StringFromChars(transliteratedIter)

			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestCombinedTransliteratorEdgeCases(t *testing.T) {
	tests := []struct {
		name        string
		input       string
		expected    string
		description string
	}{
		{
			name:        "empty string",
			input:       "",
			expected:    "",
			description: "Empty string should remain empty",
		},
		{
			name:        "single space",
			input:       " ",
			expected:    " ",
			description: "Single space should be preserved",
		},
		{
			name:        "multiple spaces",
			input:       "   ",
			expected:    "   ",
			description: "Multiple spaces should be preserved",
		},
		{
			name:        "newline character",
			input:       "\n",
			expected:    "\n",
			description: "Newline should be preserved",
		},
		{
			name:        "tab character",
			input:       "\t",
			expected:    "\t",
			description: "Tab should be preserved",
		},
		{
			name:        "unicode characters not in mapping",
			input:       "こんにちは世界",
			expected:    "こんにちは世界",
			description: "Unicode characters not in mapping should be preserved",
		},
		{
			name:        "mixed mapped and unmapped",
			input:       "Hello ⑴ こんにちは ␉ World",
			expected:    "Hello (1) こんにちは HT World",
			description: "Mixed content should preserve unmapped characters",
		},
		{
			name:        "emoji characters",
			input:       "😀⑴😊",
			expected:    "😀(1)😊",
			description: "Emoji should be preserved while mapped characters are translated",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := yosina.BuildCharArray(tt.input)
			iter := yosina.NewCharIteratorFromSlice(chars)
			transliteratedIter := Transliterate(iter)
			result := yosina.StringFromChars(transliteratedIter)

			assert.Equal(t, tt.expected, result, tt.description)
		})
	}
}

func TestCombinedTransliteratorPerformance(t *testing.T) {
	// Test with a large string to ensure performance is acceptable
	largeInput := ""
	for i := 0; i < 1000; i++ {
		largeInput += "text ⑴ with ␉ combined ㈱ characters "
	}

	chars := yosina.BuildCharArray(largeInput)
	iter := yosina.NewCharIteratorFromSlice(chars)
	transliteratedIter := Transliterate(iter)
	result := yosina.StringFromChars(transliteratedIter)

	// Just verify it doesn't crash and produces a result
	assert.NotEmpty(t, result, "Expected non-empty result for large input")

	// Verify some characters were translated
	expectedSubstring := "text (1) with HT combined (株) characters"
	assert.Contains(t, result, expectedSubstring)
}

func BenchmarkCombinedTransliterator(b *testing.B) {
	input := "This is ⑴ test string ␉ with combined ㈱ characters ㍍ and more ㎑ content."
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter)
		_ = yosina.StringFromChars(transliteratedIter)
	}
}

func BenchmarkCombinedTransliteratorLargeInput(b *testing.B) {
	input := ""
	for i := 0; i < 100; i++ {
		input += "text ⑴ with ␉ combined ㈱ characters ㍍ "
	}
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter)
		_ = yosina.StringFromChars(transliteratedIter)
	}
}
