package ideographic_annotations

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestIdeographicAnnotations(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "single ideographic annotation one",
			input:    "㆒",
			expected: "一",
		},
		{
			name:     "single ideographic annotation two",
			input:    "㆓",
			expected: "二",
		},
		{
			name:     "single ideographic annotation three",
			input:    "㆔",
			expected: "三",
		},
		{
			name:     "single ideographic annotation four",
			input:    "㆕",
			expected: "四",
		},
		{
			name:     "directional annotations",
			input:    "㆖㆗㆘",
			expected: "上中下",
		},
		{
			name:     "elemental annotations",
			input:    "㆝㆞㆟",
			expected: "天地人",
		},
		{
			name:     "cyclical annotations",
			input:    "㆙㆚㆛㆜",
			expected: "甲乙丙丁",
		},
		{
			name:     "consecutive numbers",
			input:    "㆒㆓㆔㆕",
			expected: "一二三四",
		},
		{
			name:     "mixed content with japanese",
			input:    "数字㆒は一、㆓は二です",
			expected: "数字一は一、二は二です",
		},
		{
			name:     "chapter references",
			input:    "第㆒章から第㆓章まで",
			expected: "第一章から第二章まで",
		},
		{
			name:     "all annotation positions",
			input:    "㆖㆗㆘㆒㆓㆔㆕㆙㆚㆛㆜㆝㆞㆟",
			expected: "上中下一二三四甲乙丙丁天地人",
		},
		{
			name:     "empty string",
			input:    "",
			expected: "",
		},
		{
			name:     "string with no annotations",
			input:    "普通の文字列です",
			expected: "普通の文字列です",
		},
		{
			name:     "mixed content with latin",
			input:    "Section ㆒: Introduction",
			expected: "Section 一: Introduction",
		},
		{
			name:     "preserve other unicode",
			input:    "🎌㆒🌸㆓🗾",
			expected: "🎌一🌸二🗾",
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

func TestIdeographicAnnotationsEdgeCases(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "annotation at start",
			input:    "㆒番目",
			expected: "一番目",
		},
		{
			name:     "annotation at end",
			input:    "第㆒",
			expected: "第一",
		},
		{
			name:     "multiple consecutive annotations",
			input:    "㆒㆓㆔㆕㆖㆗㆘",
			expected: "一二三四上中下",
		},
		{
			name:     "annotation between non-cjk characters",
			input:    "A㆒B㆓C",
			expected: "A一B二C",
		},
		{
			name:     "newlines and whitespace",
			input:    "㆒\n㆓\t㆔ ㆕",
			expected: "一\n二\t三 四",
		},
		{
			name:     "unicode surrogates preservation",
			input:    "𝓗㆒𝓮㆓𝓵㆔𝓵㆕𝓸",
			expected: "𝓗一𝓮二𝓵三𝓵四𝓸",
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
