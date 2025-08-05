package hira_kata_composition

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestHiraKataComposition(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
		opts     Options
	}{
		{
			name:     "katakana with combining voiced mark",
			input:    "\u30ab\u3099\u30ac\u30ad\u30ad\u3099\u30af",
			expected: "\u30ac\u30ac\u30ad\u30ae\u30af",
			opts:     Options{},
		},
		{
			name:     "katakana with combining voiced and semi-voiced marks",
			input:    "\u30cf\u30cf\u3099\u30cf\u309a\u30d2\u30d5\u30d8\u30db",
			expected: "\u30cf\u30d0\u30d1\u30d2\u30d5\u30d8\u30db",
			opts:     Options{},
		},
		{
			name:     "hiragana with combining voiced mark",
			input:    "\u304b\u3099\u304c\u304d\u304d\u3099\u304f",
			expected: "\u304c\u304c\u304d\u304e\u304f",
			opts:     Options{},
		},
		{
			name:     "hiragana with combining voiced and semi-voiced marks",
			input:    "\u306f\u306f\u3099\u306f\u309a\u3072\u3075\u3078\u307b",
			expected: "\u306f\u3070\u3071\u3072\u3075\u3078\u307b",
			opts:     Options{},
		},
		{
			name:     "katakana with non-combining marks when ComposeNonCombiningMarks is true",
			input:    "\u30cf\u30cf\u309b\u30cf\u309c\u30d2\u30d5\u30d8\u30db",
			expected: "\u30cf\u30d0\u30d1\u30d2\u30d5\u30d8\u30db",
			opts:     Options{ComposeNonCombiningMarks: true},
		},
		{
			name:     "katakana with non-combining marks when ComposeNonCombiningMarks is false",
			input:    "\u30cf\u30cf\u309b\u30cf\u309c\u30d2\u30d5\u30d8\u30db",
			expected: "\u30cf\u30cf\u309b\u30cf\u309c\u30d2\u30d5\u30d8\u30db",
			opts:     Options{ComposeNonCombiningMarks: false},
		},
		{
			name:     "empty string",
			input:    "",
			expected: "",
			opts:     Options{},
		},
		{
			name:     "string with no composable characters",
			input:    "hello world 123",
			expected: "hello world 123",
			opts:     Options{},
		},
		{
			name:     "mixed text with hiragana and katakana",
			input:    "こんにちは\u304b\u3099世界\u30ab\u3099",
			expected: "こんにちは\u304c世界\u30ac",
			opts:     Options{},
		},
		{
			name:     "combining marks without base character",
			input:    "\u3099\u309a\u309b\u309c",
			expected: "\u3099\u309a\u309b\u309c",
			opts:     Options{},
		},
		{
			name:     "hiragana u with dakuten",
			input:    "\u3046\u3099",
			expected: "\u3094",
			opts:     Options{},
		},
		{
			name:     "katakana u with dakuten",
			input:    "\u30a6\u3099",
			expected: "\u30f4",
			opts:     Options{},
		},
		{
			name:     "hiragana iteration mark with dakuten",
			input:    "\u309d\u3099",
			expected: "\u309e",
			opts:     Options{},
		},
		{
			name:     "katakana wa with dakuten",
			input:    "\u30ef\u3099",
			expected: "\u30f7",
			opts:     Options{},
		},
		{
			name:     "katakana iteration mark with dakuten",
			input:    "\u30fd\u3099", // ヽ + ゛ → ヾ
			expected: "\u30fe",
			opts:     Options{},
		},
		{
			name:     "multiple compositions in sequence",
			input:    "\u304b\u3099\u304d\u3099\u304f\u3099\u3051\u3099\u3053\u3099",
			expected: "\u304c\u304e\u3050\u3052\u3054",
			opts:     Options{},
		},
		{
			name:     "non-composable character followed by combining mark",
			input:    "\u3042\u3099",
			expected: "\u3042\u3099",
			opts:     Options{},
		},
		{
			name:     "katakana wi with dakuten",
			input:    "\u30f0\u3099", // ヰ + ゛ → ヸ
			expected: "\u30f8",
			opts:     Options{},
		},
		{
			name:     "katakana we with dakuten",
			input:    "\u30f1\u3099", // ヱ + ゛ → ヹ
			expected: "\u30f9",
			opts:     Options{},
		},
		{
			name:     "katakana wo with dakuten",
			input:    "\u30f2\u3099", // ヲ + ゛ → ヺ
			expected: "\u30fa",
			opts:     Options{},
		},
		{
			name:     "hiragana iteration mark with non-combining voiced mark",
			input:    "\u309d\u309b", // ゝ + ゛ (non-combining)
			expected: "\u309e",       // ゞ
			opts:     Options{ComposeNonCombiningMarks: true},
		},
		{
			name:     "katakana iteration mark with non-combining voiced mark",
			input:    "\u30fd\u309b", // ヽ + ゛ (non-combining)
			expected: "\u30fe",       // ヾ
			opts:     Options{ComposeNonCombiningMarks: true},
		},
		{
			name:     "mixed text with iteration marks",
			input:    "テスト\u309d\u3099カタカナ\u30fd\u3099",
			expected: "テスト\u309eカタカナ\u30fe",
			opts:     Options{},
		},
		{
			name:     "vertical hiragana iteration mark with dakuten",
			input:    "\u3031\u3099", // 〱 + ゛ → 〲
			expected: "\u3032",
			opts:     Options{},
		},
		{
			name:     "vertical katakana iteration mark with dakuten",
			input:    "\u3033\u3099", // 〳 + ゛ → 〴
			expected: "\u3034",
			opts:     Options{},
		},
		{
			name:     "vertical hiragana iteration mark with non-combining voiced mark",
			input:    "\u3031\u309b", // 〱 + ゛ (non-combining)
			expected: "\u3032",       // 〲
			opts:     Options{ComposeNonCombiningMarks: true},
		},
		{
			name:     "vertical katakana iteration mark with non-combining voiced mark",
			input:    "\u3033\u309b", // 〳 + ゛ (non-combining)
			expected: "\u3034",       // 〴
			opts:     Options{ComposeNonCombiningMarks: true},
		},
		{
			name:     "mixed vertical and regular iteration marks",
			input:    "\u309d\u3099\u3031\u3099\u30fd\u3099\u3033\u3099",
			expected: "\u309e\u3032\u30fe\u3034",
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

func TestHiraKataCompositionWithNonCombiningMarks(t *testing.T) {
	tests := []struct {
		name                     string
		input                    string
		expected                 string
		composeNonCombiningMarks bool
	}{
		{
			name:                     "non-combining voiced mark with composition enabled",
			input:                    "\u30ab\u309b",
			expected:                 "\u30ac",
			composeNonCombiningMarks: true,
		},
		{
			name:                     "non-combining voiced mark with composition disabled",
			input:                    "\u30ab\u309b",
			expected:                 "\u30ab\u309b",
			composeNonCombiningMarks: false,
		},
		{
			name:                     "non-combining semi-voiced mark with composition enabled",
			input:                    "\u30cf\u309c",
			expected:                 "\u30d1",
			composeNonCombiningMarks: true,
		},
		{
			name:                     "non-combining semi-voiced mark with composition disabled",
			input:                    "\u30cf\u309c",
			expected:                 "\u30cf\u309c",
			composeNonCombiningMarks: false,
		},
		{
			name:                     "mixed combining and non-combining marks",
			input:                    "\u30ab\u3099\u30ad\u309b\u30cf\u309a\u30d2\u309c",
			expected:                 "\u30ac\u30ae\u30d1\u30d4",
			composeNonCombiningMarks: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := yosina.BuildCharArray(tt.input)
			iter := yosina.NewCharIteratorFromSlice(chars)
			opts := Options{
				ComposeNonCombiningMarks: tt.composeNonCombiningMarks,
			}
			transliteratedIter := Transliterate(iter, opts)
			result := yosina.StringFromChars(transliteratedIter)

			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestHiraKataCompositionEdgeCases(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
		opts     Options
	}{
		{
			name:     "combining mark at end of string",
			input:    "\u304b\u3099",
			expected: "\u304c",
			opts:     Options{},
		},
		{
			name:     "multiple combining marks in a row",
			input:    "\u304b\u3099\u3099",
			expected: "\u304c\u3099",
			opts:     Options{},
		},
		{
			name:     "combining mark without preceding character",
			input:    "\u3099\u304b",
			expected: "\u3099\u304b",
			opts:     Options{},
		},
		{
			name:     "emoji with combining marks",
			input:    "😀\u3099😊\u309a",
			expected: "😀\u3099😊\u309a",
			opts:     Options{},
		},
		{
			name:     "newline and tab characters",
			input:    "\n\u304b\u3099\t\u30cf\u309a",
			expected: "\n\u304c\t\u30d1",
			opts:     Options{},
		},
		{
			name:     "unicode surrogates",
			input:    "\U0001f600\u304b\u3099\U0001f601",
			expected: "\U0001f600\u304c\U0001f601",
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

func BenchmarkHiraKataComposition(b *testing.B) {
	input := "\u304b\u3099\u304d\u3099\u304f\u3099\u3051\u3099\u3053\u3099"
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter, Options{})
		_ = yosina.StringFromChars(transliteratedIter)
	}
}

func BenchmarkHiraKataCompositionLargeInput(b *testing.B) {
	input := ""
	for i := 0; i < 100; i++ {
		input += "テキスト\u304b\u3099\u304d\u3099\u304f\u3099文字列\u30ab\u3099\u30ad\u3099\u30af\u3099"
	}
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter, Options{})
		_ = yosina.StringFromChars(transliteratedIter)
	}
}
