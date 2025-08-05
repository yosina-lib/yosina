package japanese_iteration_marks

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestJapaneseIterationMarks(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
		opts     Options
	}{
		// Hiragana iteration marks
		{
			name:     "hiragana repetition basic",
			input:    "さゝ",
			expected: "ささ",
			opts:     Options{},
		},
		{
			name:     "hiragana voiced repetition",
			input:    "はゞ",
			expected: "はば",
			opts:     Options{},
		},
		{
			name:     "hiragana repetition multiple",
			input:    "みゝこゝろ",
			expected: "みみこころ",
			opts:     Options{},
		},
		{
			name:     "hiragana voiced repetition multiple",
			input:    "たゞしゞま",
			expected: "ただしじま",
			opts:     Options{},
		},

		// Katakana iteration marks
		{
			name:     "katakana repetition basic",
			input:    "サヽ",
			expected: "ササ",
			opts:     Options{},
		},
		{
			name:     "katakana voiced repetition",
			input:    "ハヾ",
			expected: "ハバ",
			opts:     Options{},
		},
		{
			name:     "katakana repetition with ウ voicing",
			input:    "ウヾ",
			expected: "ウヴ",
			opts:     Options{},
		},

		// Kanji iteration marks
		{
			name:     "kanji repetition basic",
			input:    "人々",
			expected: "人人",
			opts:     Options{},
		},
		{
			name:     "kanji repetition multiple",
			input:    "日々月々年々",
			expected: "日日月月年年",
			opts:     Options{},
		},
		{
			name:     "kanji in compound words",
			input:    "色々",
			expected: "色色",
			opts:     Options{},
		},

		// Invalid combinations
		{
			name:     "hiragana mark after katakana",
			input:    "カゝ",
			expected: "カゝ",
			opts:     Options{},
		},
		{
			name:     "katakana mark after hiragana",
			input:    "かヽ",
			expected: "かヽ",
			opts:     Options{},
		},
		{
			name:     "kanji mark after hiragana",
			input:    "か々",
			expected: "か々",
			opts:     Options{},
		},
		{
			name:     "iteration mark at start",
			input:    "ゝあ",
			expected: "ゝあ",
			opts:     Options{},
		},
		{
			name:     "consecutive iteration marks",
			input:    "さゝゝ",
			expected: "ささゝ",
			opts:     Options{},
		},

		// Characters that can't be repeated
		{
			name:     "hiragana hatsuon can't repeat",
			input:    "んゝ",
			expected: "んゝ",
			opts:     Options{},
		},
		{
			name:     "hiragana sokuon can't repeat",
			input:    "っゝ",
			expected: "っゝ",
			opts:     Options{},
		},
		{
			name:     "katakana hatsuon can't repeat",
			input:    "ンヽ",
			expected: "ンヽ",
			opts:     Options{},
		},
		{
			name:     "katakana sokuon can't repeat",
			input:    "ッヽ",
			expected: "ッヽ",
			opts:     Options{},
		},
		{
			name:     "voiced character can't voice again",
			input:    "がゞ",
			expected: "がゞ",
			opts:     Options{},
		},
		{
			name:     "semi-voiced character can't voice",
			input:    "ぱゞ",
			expected: "ぱゞ",
			opts:     Options{},
		},

		// Mixed text
		{
			name:     "mixed hiragana katakana kanji",
			input:    "こゝろ、コヽロ、其々",
			expected: "こころ、ココロ、其其",
			opts:     Options{},
		},
		{
			name:     "iteration marks in sentence",
			input:    "日々の暮らしはさゝやか",
			expected: "日日の暮らしはささやか",
			opts:     Options{},
		},
		{
			name:     "halfwidth katakana",
			input:    "ｻヽ",
			expected: "ｻヽ",
			opts:     Options{},
		},

		// Voicing edge cases
		{
			name:     "no voicing possible",
			input:    "あゞ",
			expected: "あゞ",
			opts:     Options{},
		},
		{
			name:     "voicing all consonants",
			input:    "かゞたゞはゞさゞ",
			expected: "かがただはばさざ",
			opts:     Options{},
		},

		// Complex scenarios
		{
			name:     "multiple types in sequence",
			input:    "思々にこゝろサヾめく",
			expected: "思思にこころサザめく",
			opts:     Options{},
		},
		{
			name:     "empty string",
			input:    "",
			expected: "",
			opts:     Options{},
		},
		{
			name:     "no iteration marks",
			input:    "これはテストです",
			expected: "これはテストです",
			opts:     Options{},
		},
		{
			name:     "iteration mark after space",
			input:    "さ ゝ",
			expected: "さ ゝ",
			opts:     Options{},
		},
		{
			name:     "iteration mark after punctuation",
			input:    "さ、ゝ",
			expected: "さ、ゝ",
			opts:     Options{},
		},
		{
			name:     "iteration mark after ASCII",
			input:    "Aゝ",
			expected: "Aゝ",
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

func TestJapaneseIterationMarksEdgeCases(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
		opts     Options
	}{
		// Unicode edge cases
		{
			name:     "CJK Extension A kanji",
			input:    "㐀々",
			expected: "㐀㐀",
			opts:     Options{},
		},
		{
			name:     "emoji with iteration mark",
			input:    "😀ゝ",
			expected: "😀ゝ",
			opts:     Options{},
		},
		{
			name:     "surrogate pair handling",
			input:    "\U00020000々",
			expected: "\U00020000\U00020000",
			opts:     Options{},
		},

		// Offset tracking
		{
			name:     "correct offset with replacements",
			input:    "あゝいゞ",
			expected: "ああいゞ",
			opts:     Options{},
		},

		// IVS/SVS handling
		{
			name:     "kanji with IVS and iteration mark",
			input:    "葛\U000E0100々",
			expected: "葛\U000E0100々", // IVS prevents iteration
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

func TestJapaneseIterationMarksCharacterTypes(t *testing.T) {
	tests := []struct {
		name     string
		char     rune
		expected charType
	}{
		// Hiragana
		{"hiragana a", 'あ', charTypeHiragana},
		{"hiragana ka", 'か', charTypeHiragana},
		{"hiragana ga voiced", 'が', charTypeVoiced},
		{"hiragana pa semi-voiced", 'ぱ', charTypeSemiVoiced},
		{"hiragana n hatsuon", 'ん', charTypeHatsuon},
		{"hiragana small tsu sokuon", 'っ', charTypeSokuon},

		// Katakana
		{"katakana a", 'ア', charTypeKatakana},
		{"katakana ka", 'カ', charTypeKatakana},
		{"katakana ga voiced", 'ガ', charTypeVoiced},
		{"katakana pa semi-voiced", 'パ', charTypeSemiVoiced},
		{"katakana n hatsuon", 'ン', charTypeHatsuon},
		{"katakana small tsu sokuon", 'ッ', charTypeSokuon},
		{"katakana vu voiced", 'ヴ', charTypeVoiced},

		// Halfwidth katakana
		{"halfwidth katakana a", 'ｱ', charTypeOther},

		// Kanji
		{"basic kanji", '人', charTypeKanji},
		{"complex kanji", '鬱', charTypeKanji},
		{"CJK Extension", '\u3400', charTypeKanji},

		// Others
		{"ASCII letter", 'A', charTypeOther},
		{"number", '1', charTypeOther},
		{"space", ' ', charTypeOther},
		{"emoji", '😀', charTypeOther},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := getCharType(tt.char)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func BenchmarkJapaneseIterationMarks(b *testing.B) {
	input := "日々月々年々、ここゝろ、ココヽロ"
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter, Options{})
		_ = yosina.StringFromChars(transliteratedIter)
	}
}

func BenchmarkJapaneseIterationMarksLargeInput(b *testing.B) {
	input := ""
	for i := 0; i < 100; i++ {
		input += "日々の暮らしはさゝやかでココヽロ温まる思々"
	}
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter, Options{})
		_ = yosina.StringFromChars(transliteratedIter)
	}
}

func BenchmarkJapaneseIterationMarksNoReplacements(b *testing.B) {
	input := ""
	for i := 0; i < 100; i++ {
		input += "これはテストですがイテレーションマークは含まれていません"
	}
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter, Options{})
		_ = yosina.StringFromChars(transliteratedIter)
	}
}
