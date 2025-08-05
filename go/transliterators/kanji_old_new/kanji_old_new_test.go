package kanji_old_new

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestKanjiOldNew(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "preserve unmapped kanji",
			input:    "檜",
			expected: "檜",
		},
		{
			name:     "preserve multiple kanji",
			input:    "檜辻",
			expected: "檜辻",
		},
		{
			name:     "preserve mixed content",
			input:    "新檜字",
			expected: "新檜字",
		},
		{
			name:     "preserve sentence context",
			input:    "檜の木材を使用しています",
			expected: "檜の木材を使用しています",
		},
		{
			name:     "no change for regular kanji",
			input:    "普通の漢字です",
			expected: "普通の漢字です",
		},
		{
			name:     "empty string",
			input:    "",
			expected: "",
		},
		{
			name:     "mixed content with latin",
			input:    "Hello 檜 World",
			expected: "Hello 檜 World",
		},
		{
			name:     "preserve other characters",
			input:    "🎌檜🌸新🗾",
			expected: "🎌檜🌸新🗾",
		},
		{
			name:     "hiragana and katakana preservation",
			input:    "ひらがな檜カタカナ",
			expected: "ひらがな檜カタカナ",
		},
		{
			name:     "numbers and punctuation",
			input:    "檜123！？",
			expected: "檜123！？",
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

func TestKanjiOldNewWithIVS(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "kanji with IVS selector preserved",
			input:    "檜\U000E0100",
			expected: "檜\U000E0100",
		},
		{
			name:     "kanji with different IVS selector preserved",
			input:    "辻\U000E0101",
			expected: "辻\U000E0101",
		},
		{
			name:     "mixed content with IVS preserved",
			input:    "Hello 檜\U000E0100 World",
			expected: "Hello 檜\U000E0100 World",
		},
		{
			name:     "multiple kanji with IVS preserved",
			input:    "檜\U000E0100辻\U000E0101",
			expected: "檜\U000E0100辻\U000E0101",
		},
		{
			name:     "sentence with IVS kanji preserved",
			input:    "檜\U000E0100の木は美しい",
			expected: "檜\U000E0100の木は美しい",
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

func TestKanjiOldNewEdgeCases(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "kanji at string start",
			input:    "檜が好き",
			expected: "檜が好き",
		},
		{
			name:     "kanji at string end",
			input:    "これは檜",
			expected: "これは檜",
		},
		{
			name:     "consecutive kanji",
			input:    "檜檜檜",
			expected: "檜檜檜",
		},
		{
			name:     "kanji between non-cjk",
			input:    "A檜B檜C",
			expected: "A檜B檜C",
		},
		{
			name:     "newlines and whitespace",
			input:    "檜\n木\t材",
			expected: "檜\n木\t材",
		},
		{
			name:     "unicode surrogates preservation",
			input:    "𝓗檜𝓮𝓵𝓵𝓸",
			expected: "𝓗檜𝓮𝓵𝓵𝓸",
		},
		{
			name:     "mixed scripts",
			input:    "English檜日本語카타나hiraganaひらがな",
			expected: "English檜日本語카타나hiraganaひらがな",
		},
		{
			name:     "punctuation around kanji",
			input:    "(檜)、[檜]、「檜」",
			expected: "(檜)、[檜]、「檜」",
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
