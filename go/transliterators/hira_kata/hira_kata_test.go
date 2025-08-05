package hira_kata

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestHiraToKata(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "basic hiragana to katakana",
			input:    "あいうえお",
			expected: "アイウエオ",
		},
		{
			name:     "voiced hiragana to katakana",
			input:    "がぎぐげご",
			expected: "ガギグゲゴ",
		},
		{
			name:     "semi-voiced hiragana to katakana",
			input:    "ぱぴぷぺぽ",
			expected: "パピプペポ",
		},
		{
			name:     "small hiragana to katakana",
			input:    "ぁぃぅぇぉっゃゅょ",
			expected: "ァィゥェォッャュョ",
		},
		{
			name:     "mixed text with numbers and latin",
			input:    "あいうえお123ABCアイウエオ",
			expected: "アイウエオ123ABCアイウエオ",
		},
		{
			name:     "phrase with punctuation",
			input:    "こんにちは、世界！",
			expected: "コンニチハ、世界！",
		},
		{
			name:     "all hiragana characters",
			input:    "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゔ",
			expected: "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴ",
		},
		{
			name:     "wi and we characters",
			input:    "ゐゑ",
			expected: "ヰヱ",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := yosina.BuildCharArray(tt.input)
			iter := yosina.NewCharIteratorFromSlice(chars)
			result := Transliterate(iter, Options{Mode: HiraToKata})
			assert.Equal(t, tt.expected, yosina.StringFromChars(result))
		})
	}
}

func TestKataToHira(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "basic katakana to hiragana",
			input:    "アイウエオ",
			expected: "あいうえお",
		},
		{
			name:     "voiced katakana to hiragana",
			input:    "ガギグゲゴ",
			expected: "がぎぐげご",
		},
		{
			name:     "semi-voiced katakana to hiragana",
			input:    "パピプペポ",
			expected: "ぱぴぷぺぽ",
		},
		{
			name:     "small katakana to hiragana",
			input:    "ァィゥェォッャュョ",
			expected: "ぁぃぅぇぉっゃゅょ",
		},
		{
			name:     "mixed text with numbers and latin",
			input:    "アイウエオ123ABCあいうえお",
			expected: "あいうえお123ABCあいうえお",
		},
		{
			name:     "phrase with punctuation",
			input:    "コンニチハ、世界！",
			expected: "こんにちは、世界！",
		},
		{
			name:     "vu character",
			input:    "ヴ",
			expected: "ゔ",
		},
		{
			name:     "special katakana without hiragana equivalents",
			input:    "ヷヸヹヺ",
			expected: "ヷヸヹヺ",
		},
		{
			name:     "all katakana characters",
			input:    "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴ",
			expected: "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゔ",
		},
		{
			name:     "wi and we characters",
			input:    "ヰヱ",
			expected: "ゐゑ",
		},
		{
			name:     "small wa, ka, ke",
			input:    "ヮヵヶ",
			expected: "ゎゕゖ",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := yosina.BuildCharArray(tt.input)
			iter := yosina.NewCharIteratorFromSlice(chars)
			result := Transliterate(iter, Options{Mode: KataToHira})
			assert.Equal(t, tt.expected, yosina.StringFromChars(result))
		})
	}
}

func TestDefaultMode(t *testing.T) {
	// Test that default options use HiraToKata mode
	input := "あいうえお"
	expected := "アイウエオ"

	chars := yosina.BuildCharArray(input)
	iter := yosina.NewCharIteratorFromSlice(chars)
	result := Transliterate(iter, Options{})
	assert.Equal(t, expected, yosina.StringFromChars(result))
}

func TestCachingBehavior(t *testing.T) {
	// Test that mapping tables are properly cached
	// First call builds the cache
	input1 := "あいうえお"
	chars1 := yosina.BuildCharArray(input1)
	iter1 := yosina.NewCharIteratorFromSlice(chars1)
	result1 := Transliterate(iter1, Options{Mode: HiraToKata})
	assert.Equal(t, "アイウエオ", yosina.StringFromChars(result1))

	// Second call should use cached table
	input2 := "かきくけこ"
	chars2 := yosina.BuildCharArray(input2)
	iter2 := yosina.NewCharIteratorFromSlice(chars2)
	result2 := Transliterate(iter2, Options{Mode: HiraToKata})
	assert.Equal(t, "カキクケコ", yosina.StringFromChars(result2))

	// Test kata to hira mode caching
	input3 := "アイウエオ"
	chars3 := yosina.BuildCharArray(input3)
	iter3 := yosina.NewCharIteratorFromSlice(chars3)
	result3 := Transliterate(iter3, Options{Mode: KataToHira})
	assert.Equal(t, "あいうえお", yosina.StringFromChars(result3))
}

func BenchmarkHiraToKata(b *testing.B) {
	input := "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"
	opts := Options{Mode: HiraToKata}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		chars := yosina.BuildCharArray(input)
		iter := yosina.NewCharIteratorFromSlice(chars)
		result := Transliterate(iter, opts)
		yosina.StringFromChars(result)
	}
}

func BenchmarkKataToHira(b *testing.B) {
	input := "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
	opts := Options{Mode: KataToHira}

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		chars := yosina.BuildCharArray(input)
		iter := yosina.NewCharIteratorFromSlice(chars)
		result := Transliterate(iter, opts)
		yosina.StringFromChars(result)
	}
}
