package circled_or_squared

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestCircledOrSquaredTransliterator(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
		opts     Options
	}{
		{
			name:     "circled number 1",
			input:    "①",
			expected: "(1)",
			opts:     Options{},
		},
		{
			name:     "circled number 2",
			input:    "②",
			expected: "(2)",
			opts:     Options{},
		},
		{
			name:     "circled number 20",
			input:    "⑳",
			expected: "(20)",
			opts:     Options{},
		},
		{
			name:     "circled number 0",
			input:    "⓪",
			expected: "(0)",
			opts:     Options{},
		},
		{
			name:     "circled uppercase A",
			input:    "Ⓐ",
			expected: "(A)",
			opts:     Options{},
		},
		{
			name:     "circled uppercase Z",
			input:    "Ⓩ",
			expected: "(Z)",
			opts:     Options{},
		},
		{
			name:     "circled lowercase a",
			input:    "ⓐ",
			expected: "(a)",
			opts:     Options{},
		},
		{
			name:     "circled lowercase z",
			input:    "ⓩ",
			expected: "(z)",
			opts:     Options{},
		},
		{
			name:     "circled kanji ichi",
			input:    "㊀",
			expected: "(一)",
			opts:     Options{},
		},
		{
			name:     "circled kanji getsu",
			input:    "㊊",
			expected: "(月)",
			opts:     Options{},
		},
		{
			name:     "circled kanji yoru",
			input:    "㊰",
			expected: "(夜)",
			opts:     Options{},
		},
		{
			name:     "circled katakana a",
			input:    "㋐",
			expected: "(ア)",
			opts:     Options{},
		},
		{
			name:     "circled katakana wo",
			input:    "㋾",
			expected: "(ヲ)",
			opts:     Options{},
		},
		{
			name:     "squared letter A",
			input:    "🅰",
			expected: "[A]",
			opts:     Options{},
		},
		{
			name:     "squared letter Z",
			input:    "🆉",
			expected: "[Z]",
			opts:     Options{},
		},
		{
			name:     "regional indicator A",
			input:    "🇦",
			expected: "[A]",
			opts:     Options{},
		},
		{
			name:     "regional indicator Z",
			input:    "🇿",
			expected: "[Z]",
			opts:     Options{},
		},
		{
			name:     "emoji exclusion default",
			input:    "🆂🅾🆂",
			expected: "[S][O][S]",
			opts:     Options{},
		},
		{
			name:     "empty string",
			input:    "",
			expected: "",
			opts:     Options{},
		},
		{
			name:     "unmapped characters",
			input:    "hello world 123 abc こんにちは",
			expected: "hello world 123 abc こんにちは",
			opts:     Options{},
		},
		{
			name:     "mixed content",
			input:    "Hello ① World Ⓐ Test",
			expected: "Hello (1) World (A) Test",
			opts:     Options{},
		},
		{
			name:     "sequence of circled numbers",
			input:    "①②③④⑤",
			expected: "(1)(2)(3)(4)(5)",
			opts:     Options{},
		},
		{
			name:     "sequence of circled letters",
			input:    "ⒶⒷⒸ",
			expected: "(A)(B)(C)",
			opts:     Options{},
		},
		{
			name:     "mixed circles and squares",
			input:    "①🅰②🅱",
			expected: "(1)[A](2)[B]",
			opts:     Options{},
		},
		{
			name:     "circled kanji sequence",
			input:    "㊀㊁㊂㊃㊄",
			expected: "(一)(二)(三)(四)(五)",
			opts:     Options{},
		},
		{
			name:     "japanese text with circled elements",
			input:    "項目①は重要で、項目②は補足です。",
			expected: "項目(1)は重要で、項目(2)は補足です。",
			opts:     Options{},
		},
		{
			name:     "numbered list with circled numbers",
			input:    "①準備\n②実行\n③確認",
			expected: "(1)準備\n(2)実行\n(3)確認",
			opts:     Options{},
		},
		{
			name:     "large circled numbers",
			input:    "㊱㊲㊳",
			expected: "(36)(37)(38)",
			opts:     Options{},
		},
		{
			name:     "circled numbers up to 50",
			input:    "㊿",
			expected: "(50)",
			opts:     Options{},
		},
		{
			name:     "special circled characters",
			input:    "🄴🅂",
			expected: "[E][S]",
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

func TestCircledOrSquaredTransliteratorEmojiOptions(t *testing.T) {
	tests := []struct {
		name         string
		input        string
		includeEmoji bool
		expected     string
		description  string
	}{
		{
			name:         "include emojis true",
			input:        "🆘",
			includeEmoji: true,
			expected:     "[SOS]",
			description:  "Emoji characters should be processed when includeEmojis is true",
		},
		{
			name:         "include emojis false",
			input:        "🆘",
			includeEmoji: false,
			expected:     "🆘",
			description:  "Emoji characters should not be processed when includeEmojis is false",
		},
		{
			name:         "non-emoji with include emojis false",
			input:        "①",
			includeEmoji: false,
			expected:     "(1)",
			description:  "Non-emoji characters should still be processed when includeEmojis is false",
		},
		{
			name:         "mixed emoji and non-emoji with include emojis true",
			input:        "①🆘②",
			includeEmoji: true,
			expected:     "(1)[SOS](2)",
			description:  "Both emoji and non-emoji should be processed when includeEmojis is true",
		},
		{
			name:         "mixed emoji and non-emoji with include emojis false",
			input:        "①🆘②",
			includeEmoji: false,
			expected:     "(1)🆘(2)",
			description:  "Only non-emoji should be processed when includeEmojis is false",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := yosina.BuildCharArray(tt.input)
			iter := yosina.NewCharIteratorFromSlice(chars)

			opts := Options{
				IncludeEmojis: tt.includeEmoji,
			}

			transliteratedIter := Transliterate(iter, opts)
			result := yosina.StringFromChars(transliteratedIter)

			assert.Equal(t, tt.expected, result, tt.description)
		})
	}
}

func TestCircledOrSquaredTransliteratorCustomTemplates(t *testing.T) {
	tests := []struct {
		name        string
		input       string
		opts        Options
		expected    string
		description string
	}{
		{
			name:  "custom circle template",
			input: "①",
			opts: Options{
				TemplateForCircled: "〔?〕",
				TemplateForSquared: "[?]",
			},
			expected:    "〔1〕",
			description: "Custom circle template should be used",
		},
		{
			name:  "custom square template",
			input: "🅰",
			opts: Options{
				TemplateForCircled: "(?)",
				TemplateForSquared: "【?】",
			},
			expected:    "【A】",
			description: "Custom square template should be used",
		},
		{
			name:  "custom templates with kanji",
			input: "㊀",
			opts: Options{
				TemplateForCircled: "〔?〕",
				TemplateForSquared: "[?]",
			},
			expected:    "〔一〕",
			description: "Custom templates should work with kanji",
		},
		{
			name:  "mixed characters with custom templates",
			input: "①🅰②",
			opts: Options{
				TemplateForCircled: "〔?〕",
				TemplateForSquared: "【?】",
			},
			expected:    "〔1〕【A】〔2〕",
			description: "Mixed characters should use appropriate custom templates",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := yosina.BuildCharArray(tt.input)
			iter := yosina.NewCharIteratorFromSlice(chars)

			transliteratedIter := Transliterate(iter, tt.opts)
			result := yosina.StringFromChars(transliteratedIter)

			assert.Equal(t, tt.expected, result, tt.description)
		})
	}
}

func TestCircledOrSquaredTransliteratorEdgeCases(t *testing.T) {
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
			input:       "Hello ① こんにちは 🅰 World",
			expected:    "Hello (1) こんにちは [A] World",
			description: "Mixed content should preserve unmapped characters",
		},
		{
			name:        "other emoji characters",
			input:       "😀①😊",
			expected:    "😀(1)😊",
			description: "Other emoji should be preserved while mapped characters are translated",
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

func TestCircledOrSquaredTransliteratorPerformance(t *testing.T) {
	// Test with a large string to ensure performance is acceptable
	largeInput := ""
	for i := 0; i < 1000; i++ {
		largeInput += "text ① with 🅰 circled ② and 🅱 squared characters "
	}

	chars := yosina.BuildCharArray(largeInput)
	iter := yosina.NewCharIteratorFromSlice(chars)
	transliteratedIter := Transliterate(iter, Options{})
	result := yosina.StringFromChars(transliteratedIter)

	// Just verify it doesn't crash and produces a result
	assert.NotEmpty(t, result, "Expected non-empty result for large input")

	// Verify some characters were translated
	expectedSubstring := "text (1) with [A] circled (2) and [B] squared characters"
	assert.Contains(t, result, expectedSubstring)
}

func BenchmarkCircledOrSquaredTransliterator(b *testing.B) {
	input := "This is ① test string 🅰 with circled ② and 🅱 squared characters ㊀."
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter, Options{})
		_ = yosina.StringFromChars(transliteratedIter)
	}
}

func BenchmarkCircledOrSquaredTransliteratorLargeInput(b *testing.B) {
	input := ""
	for i := 0; i < 100; i++ {
		input += "text ① with 🅰 circled ② and 🅱 squared characters "
	}
	chars := yosina.BuildCharArray(input)

	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		iter := yosina.NewCharIteratorFromSlice(chars)
		transliteratedIter := Transliterate(iter, Options{})
		_ = yosina.StringFromChars(transliteratedIter)
	}
}
