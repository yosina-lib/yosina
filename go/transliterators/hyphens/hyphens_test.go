package hyphens

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestHyphensTransliterator(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
		opts     Options
	}{
		{
			name:     "hyphen minus with default precedence",
			input:    "-",
			expected: "−", // U+2212 MINUS SIGN
			opts:     Options{},
		},
		{
			name:     "hyphen minus with ASCII precedence",
			input:    "-",
			expected: "-", // U+002D HYPHEN-MINUS
			opts: Options{
				Precedence: []Mapping{ASCII},
			},
		},
		{
			name:     "hyphen minus with JIS X 0201 precedence",
			input:    "-",
			expected: "-", // U+002D HYPHEN-MINUS
			opts: Options{
				Precedence: []Mapping{Jisx0201},
			},
		},
		{
			name:     "hyphen minus with JIS X 0208-90 precedence",
			input:    "-",
			expected: "−", // U+2212 MINUS SIGN
			opts: Options{
				Precedence: []Mapping{Jisx0208_90},
			},
		},
		{
			name:     "hyphen minus with JIS X 0208-90 Windows precedence",
			input:    "-",
			expected: "−", // U+2212 MINUS SIGN
			opts: Options{
				Precedence: []Mapping{Jisx0208_90_Windows},
			},
		},
		{
			name:     "hyphen minus with multiple precedence order",
			input:    "-",
			expected: "-", // U+002D HYPHEN-MINUS (ASCII comes first)
			opts: Options{
				Precedence: []Mapping{ASCII, Jisx0208_90},
			},
		},
		{
			name:     "vertical line with default precedence",
			input:    "|",
			expected: "｜", // Should be replaced according to JIS X 0208-90
			opts:     Options{},
		},
		{
			name:     "tilde with default precedence",
			input:    "~",
			expected: "〜", // Should be replaced according to JIS X 0208-90
			opts:     Options{},
		},
		{
			name:     "cent sign with default precedence",
			input:    "¢",
			expected: "¢", // Should not be replaced as it's not part of JIS X 0208-90
			opts:     Options{},
		},
		{
			name:     "cent sign with JIS X 0208-Windows",
			input:    "¢",
			expected: "￠", // Should not be replaced as it's not part of JIS X 0208-90
			opts: Options{
				Precedence: []Mapping{Jisx0208_90_Windows},
			},
		},
		{
			name:     "pound sign with JIS X 0208-Windows",
			input:    "£",
			expected: "￡", // Should not be replaced as it's not part of JIS X 0208-90
			opts: Options{
				Precedence: []Mapping{Jisx0208_90_Windows},
			},
		},
		{
			name:     "broken bar with default precedence",
			input:    "¦",
			expected: "｜", // Should be replaced according to JIS X 0208-90
			opts:     Options{},
		},
		{
			name:     "unmapped character remains unchanged",
			input:    "a",
			expected: "a",
			opts:     Options{},
		},
		{
			name:     "mixed text with hyphens",
			input:    "hello-world|test~end",
			expected: "hello−world｜test〜end",
			opts:     Options{},
		},
		{
			name:     "empty string",
			input:    "",
			expected: "",
			opts:     Options{},
		},
		{
			name:     "string with no hyphens",
			input:    "hello world",
			expected: "hello world",
			opts:     Options{},
		},
		{
			name:     "multiple hyphens in sequence",
			input:    "---",
			expected: "−−−",
			opts:     Options{},
		},
		{
			name:     "precedence fallback test",
			input:    "-",
			expected: "−", // Falls back to JIS X 0208-90 when verbatim not available
			opts: Options{
				Precedence: []Mapping{Jisx0208_Verbatim, Jisx0208_90},
			},
		},
		{
			name:     "unicode characters mixed with hyphens",
			input:    "こんにちは-世界",
			expected: "こんにちは−世界",
			opts:     Options{},
		},
		{
			name:     "emoji with hyphens",
			input:    "😀-😊",
			expected: "😀−😊",
			opts:     Options{},
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

func TestHyphensTransliteratorOptions(t *testing.T) {
	tests := []struct {
		name        string
		input       string
		precedence  []Mapping
		expected    string
		description string
	}{
		{
			name:        "default precedence",
			input:       "-",
			precedence:  nil, // Use default
			expected:    "−",
			description: "Default precedence should use JIS X 0208-90",
		},
		{
			name:        "ASCII first",
			input:       "-",
			precedence:  []Mapping{ASCII},
			expected:    "-",
			description: "ASCII precedence should preserve ASCII hyphen",
		},
		{
			name:        "JIS X 0201 first",
			input:       "-",
			precedence:  []Mapping{Jisx0201},
			expected:    "-",
			description: "JIS X 0201 precedence should use JIS X 0201 mapping",
		},
		{
			name:        "JIS X 0208-90 first",
			input:       "-",
			precedence:  []Mapping{Jisx0208_90},
			expected:    "−",
			description: "JIS X 0208-90 precedence should use JIS X 0208-90 mapping",
		},
		{
			name:        "JIS X 0208-90 Windows first",
			input:       "-",
			precedence:  []Mapping{Jisx0208_90_Windows},
			expected:    "−",
			description: "JIS X 0208-90 Windows precedence should use JIS X 0208-90 Windows mapping",
		},
		{
			name:        "multiple precedence order matters",
			input:       "-",
			precedence:  []Mapping{ASCII, Jisx0208_90},
			expected:    "-",
			description: "First matching precedence should be used",
		},
		{
			name:        "fallback to second precedence",
			input:       "-",
			precedence:  []Mapping{Jisx0208_Verbatim, Jisx0208_90},
			expected:    "−",
			description: "Should fallback to second precedence when first is not available",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := yosina.BuildCharArray(tt.input)
			iter := yosina.NewCharIteratorFromSlice(chars)

			opts := Options{
				Precedence: tt.precedence,
			}

			transliteratedIter := Transliterate(iter, opts)
			result := yosina.StringFromChars(transliteratedIter)

			assert.Equal(t, tt.expected, result, tt.description)
		})
	}
}

func TestHyphensTransliteratorEdgeCases(t *testing.T) {
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
			name:        "unicode combining characters",
			input:       "é-à",
			expected:    "é−à",
			description: "Unicode combining characters should be preserved",
		},
		{
			name:        "very long string with hyphens",
			input:       "a-" + "bcdefghijklmnopqrstuvwxyz" + "-b",
			expected:    "a−" + "bcdefghijklmnopqrstuvwxyz" + "−b",
			description: "Long strings should be handled correctly",
		},
		{
			name:        "repeated hyphens",
			input:       "----------",
			expected:    "−−−−−−−−−−",
			description: "Repeated hyphens should all be translated",
		},
		{
			name:        "mixed punctuation",
			input:       "!@#$%^&*()-_=+",
			expected:    "!@#$%^&*()−_=+",
			description: "Only mapped characters should be translated",
		},
		{
			name:        "hyphens at start and end",
			input:       "-middle-",
			expected:    "−middle−",
			description: "Hyphens at start and end should be translated",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := yosina.BuildCharArray(tt.input)
			iter := yosina.NewCharIteratorFromSlice(chars)
			transliteratedIter := Transliterate(iter, Options{})
			result := yosina.StringFromChars(transliteratedIter)

			assert.Equal(t, tt.expected, result, tt.description)
		})
	}
}

func TestHyphensTransliteratorPerformance(t *testing.T) {
	// Test with a large string to ensure performance is acceptable
	largeInput := ""
	for i := 0; i < 1000; i++ {
		largeInput += "text-with-hyphens|and|vertical|bars~tilde "
	}

	chars := yosina.BuildCharArray(largeInput)
	iter := yosina.NewCharIteratorFromSlice(chars)
	transliteratedIter := Transliterate(iter, Options{})
	result := yosina.StringFromChars(transliteratedIter)

	// Just verify it doesn't crash and produces a result
	assert.NotEmpty(t, result, "Expected non-empty result for large input")

	// Verify some characters were translated
	expectedSubstring := "text−with−hyphens｜and｜vertical｜bars〜tilde"
	assert.Contains(t, result, expectedSubstring)
}

func TestHyphensConstants(t *testing.T) {
	// Test that the mapping constants are correctly defined
	tests := []struct {
		name     string
		mapping  Mapping
		expected int
	}{
		{"ASCII", ASCII, 0},
		{"Jisx0201", Jisx0201, 1},
		{"Jisx0208_90", Jisx0208_90, 2},
		{"Jisx0208_90_Windows", Jisx0208_90_Windows, 3},
		{"Jisx0208_Verbatim", Jisx0208_Verbatim, 4},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			assert.Equal(t, tt.expected, int(tt.mapping))
		})
	}
}

func TestHyphensDefaultPrecedence(t *testing.T) {
	// Test that default precedence is correctly set
	expected := []Mapping{Jisx0208_90}

	assert.Equal(t, expected, DefaultPrecedence)
}

func BenchmarkHyphensTransliterator(b *testing.B) {
	input := "This is a test-string with-multiple-hyphens|and|vertical|bars~and~tildes."
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter, Options{})
		_ = yosina.StringFromChars(transliteratedIter)
	}
}

func BenchmarkHyphensTransliteratorLargeInput(b *testing.B) {
	input := ""
	for i := 0; i < 100; i++ {
		input += "text-with-hyphens|and|vertical|bars~tilde "
	}
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter, Options{})
		_ = yosina.StringFromChars(transliteratedIter)
	}
}
