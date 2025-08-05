package spaces

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestSpacesBasic(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "ideographic space",
			input:    "　",
			expected: " ",
		},
		{
			name:     "halfwidth ideographic space",
			input:    "ﾠ",
			expected: " ",
		},
		{
			name:     "en quad",
			input:    " ",
			expected: " ",
		},
		{
			name:     "em quad",
			input:    " ",
			expected: " ",
		},
		{
			name:     "en space",
			input:    " ",
			expected: " ",
		},
		{
			name:     "em space",
			input:    " ",
			expected: " ",
		},
		{
			name:     "three-per-em space",
			input:    " ",
			expected: " ",
		},
		{
			name:     "four-per-em space",
			input:    " ",
			expected: " ",
		},
		{
			name:     "six-per-em space",
			input:    " ",
			expected: " ",
		},
		{
			name:     "figure space",
			input:    " ",
			expected: " ",
		},
		{
			name:     "punctuation space",
			input:    " ",
			expected: " ",
		},
		{
			name:     "thin space",
			input:    " ",
			expected: " ",
		},
		{
			name:     "hair space",
			input:    " ",
			expected: " ",
		},
		{
			name:     "zero width space",
			input:    "​",
			expected: " ",
		},
		{
			name:     "hangul filler",
			input:    "ㅤ",
			expected: " ",
		},
		{
			name:     "narrow no-break space",
			input:    " ",
			expected: " ",
		},
		{
			name:     "medium mathematical space",
			input:    " ",
			expected: " ",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := yosina.StringFromChars(
				Transliterate(yosina.NewCharIteratorFromSlice(yosina.BuildCharArray(tt.input))),
			)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestSpacesInText(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "japanese text with ideographic spaces",
			input:    "こんにちは　世界　です",
			expected: "こんにちは 世界 です",
		},
		{
			name:     "english text with various spaces",
			input:    "hello　world test　data",
			expected: "hello world test data",
		},
		{
			name:     "mixed content with different spaces",
			input:    "Word　Word Word　Word",
			expected: "Word Word Word Word",
		},
		{
			name:     "zero width space in words",
			input:    "word​word​test",
			expected: "word word test",
		},
		{
			name:     "consecutive different spaces",
			input:    "word　　　word",
			expected: "word   word",
		},
		{
			name:     "mixed space types",
			input:    "a　b c d　e",
			expected: "a b c d e",
		},
		{
			name:     "spaces at boundaries",
			input:    "　start middle end　",
			expected: " start middle end ",
		},
		{
			name:     "hangul filler in korean context",
			input:    "한국어ㅤ텍스트ㅤ입니다",
			expected: "한국어 텍스트 입니다",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := yosina.StringFromChars(
				Transliterate(yosina.NewCharIteratorFromSlice(yosina.BuildCharArray(tt.input))),
			)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestSpacesEdgeCases(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "empty string",
			input:    "",
			expected: "",
		},
		{
			name:     "only spaces",
			input:    "　　　",
			expected: "   ",
		},
		{
			name:     "no special spaces",
			input:    "regular text with normal spaces",
			expected: "regular text with normal spaces",
		},
		{
			name:     "space at start",
			input:    "　start",
			expected: " start",
		},
		{
			name:     "space at end",
			input:    "end　",
			expected: "end ",
		},
		{
			name:     "consecutive mixed spaces",
			input:    "a　 　b",
			expected: "a   b",
		},
		{
			name:     "preserve emoji and symbols",
			input:    "🎌　🌸　🗾",
			expected: "🎌 🌸 🗾",
		},
		{
			name:     "newlines and tabs preservation",
			input:    "a　\nb\t　c",
			expected: "a \nb\t c",
		},
		{
			name:     "unicode surrogates preservation",
			input:    "𝓗　𝓮　𝓵",
			expected: "𝓗 𝓮 𝓵",
		},
		{
			name:     "mixed cjk characters",
			input:    "漢字　ひらがな　カタカナ",
			expected: "漢字 ひらがな カタカナ",
		},
		{
			name:     "punctuation with spaces",
			input:    "word　,　word　。",
			expected: "word , word 。",
		},
		{
			name:     "numbers with spaces",
			input:    "123　456　789",
			expected: "123 456 789",
		},
		{
			name:     "all space types mixed",
			input:    "a　b c　d ​e　f",
			expected: "a b c d  e f",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := yosina.StringFromChars(
				Transliterate(yosina.NewCharIteratorFromSlice(yosina.BuildCharArray(tt.input))),
			)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestSpacesSpecialCases(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "multiple consecutive ideographic spaces",
			input:    "word　　　　word",
			expected: "word    word",
		},
		{
			name:     "mixed zero-width and regular spaces",
			input:    "a​b　c​d",
			expected: "a b c d",
		},
		{
			name:     "spaces in japanese sentence",
			input:    "私は　学生です　今日は　いい天気ですね",
			expected: "私は 学生です 今日は いい天気ですね",
		},
		{
			name:     "spaces around punctuation",
			input:    "Hello　,　World　!",
			expected: "Hello , World !",
		},
		{
			name:     "mathematical spaces in equation",
			input:    "x　+　y　=　z",
			expected: "x + y = z",
		},
		{
			name:     "url with spaces",
			input:    "https://example.com　/　path",
			expected: "https://example.com / path",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := yosina.StringFromChars(
				Transliterate(yosina.NewCharIteratorFromSlice(yosina.BuildCharArray(tt.input))),
			)
			assert.Equal(t, tt.expected, result)
		})
	}
}
