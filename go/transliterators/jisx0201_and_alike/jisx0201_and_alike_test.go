package jisx0201_and_alike

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestJisx0201AndAlikeFullwidthToHalfwidth(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
		opts     Options
	}{
		{
			name:     "fullwidth ascii letters",
			input:    "ＡＢＣＤＥａｂｃｄｅ",
			expected: "ABCDEabcde",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGL: true},
		},
		{
			name:     "fullwidth digits",
			input:    "０１２３４５６７８９",
			expected: "0123456789",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGL: true},
		},
		{
			name:     "fullwidth punctuation",
			input:    "！＂＃＄％＆'（）＊",
			expected: "!\"#$%&'()*",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGL: true},
		},
		{
			name:     "fullwidth katakana basic",
			input:    "アイウエオカキクケコ",
			expected: "ｱｲｳｴｵｶｷｸｹｺ",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGR: true},
		},
		{
			name:     "fullwidth katakana with voiced marks",
			input:    "ガギグゲゴザジズゼゾ",
			expected: "ｶﾞｷﾞｸﾞｹﾞｺﾞｻﾞｼﾞｽﾞｾﾞｿﾞ",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGR: true},
		},
		{
			name:     "fullwidth katakana with semi-voiced marks",
			input:    "パピプペポ",
			expected: "ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGR: true},
		},
		{
			name:     "mixed fullwidth content",
			input:    "Ｈｅｌｌｏ　世界！　カタカナ　１２３",
			expected: "Hello 世界! ｶﾀｶﾅ 123",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGL: true, ConvertGR: true},
		},
		{
			name:     "fullwidth space",
			input:    "Ａ　Ｂ　Ｃ",
			expected: "A B C",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGL: true},
		},
		{
			name:     "no conversion when disabled",
			input:    "ＡＢＣアイウ",
			expected: "ＡＢＣアイウ",
			opts:     Options{FullwidthToHalfwidth: false},
		},
		{
			name:     "convert GL only",
			input:    "ＡＢＣアイウ",
			expected: "ABCアイウ",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGL: true, ConvertGR: false},
		},
		{
			name:     "convert GR only",
			input:    "ＡＢＣアイウ",
			expected: "ＡＢＣｱｲｳ",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGL: false, ConvertGR: true},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := yosina.StringFromChars(
				Transliterate(yosina.NewCharIteratorFromSlice(yosina.BuildCharArray(tt.input)), tt.opts),
			)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestJisx0201AndAlikeHalfwidthToFullwidth(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
		opts     Options
	}{
		{
			name:     "halfwidth ascii letters",
			input:    "ABCDEabcde",
			expected: "ＡＢＣＤＥａｂｃｄｅ",
			opts:     Options{FullwidthToHalfwidth: false, ConvertGL: true},
		},
		{
			name:     "halfwidth digits",
			input:    "0123456789",
			expected: "０１２３４５６７８９",
			opts:     Options{FullwidthToHalfwidth: false, ConvertGL: true},
		},
		{
			name:     "halfwidth katakana basic",
			input:    "ｱｲｳｴｵｶｷｸｹｺ",
			expected: "アイウエオカキクケコ",
			opts:     Options{FullwidthToHalfwidth: false, ConvertGR: true},
		},
		{
			name:     "halfwidth katakana with voiced marks (no combining)",
			input:    "ｶﾞｷﾞｸﾞｹﾞｺﾞ",
			expected: "カ゛キ゛ク゛ケ゛コ゛",
			opts:     Options{FullwidthToHalfwidth: false, ConvertGR: true, CombineVoicedSoundMarks: false},
		},
		{
			name:     "halfwidth katakana with semi-voiced marks (no combining)",
			input:    "ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ",
			expected: "ハ゜ヒ゜フ゜ヘ゜ホ゜",
			opts:     Options{FullwidthToHalfwidth: false, ConvertGR: true, CombineVoicedSoundMarks: false},
		},
		{
			name:     "halfwidth katakana with voiced marks (with combining)",
			input:    "ｶﾞｷﾞｸﾞｹﾞｺﾞ",
			expected: "ガギグゲゴ",
			opts:     Options{FullwidthToHalfwidth: false, ConvertGR: true, CombineVoicedSoundMarks: true},
		},
		{
			name:     "halfwidth katakana with semi-voiced marks (with combining)",
			input:    "ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ",
			expected: "パピプペポ",
			opts:     Options{FullwidthToHalfwidth: false, ConvertGR: true, CombineVoicedSoundMarks: true},
		},
		{
			name:     "halfwidth katakana mixed voiced marks (with combining)",
			input:    "ｳﾞｻﾞｼﾞﾀﾞﾊﾞ",
			expected: "ヴザジダバ",
			opts:     Options{FullwidthToHalfwidth: false, ConvertGR: true, CombineVoicedSoundMarks: true},
		},
		{
			name:     "mixed halfwidth content",
			input:    "Hello ｶﾀｶﾅ 123",
			expected: "Ｈｅｌｌｏ　カタカナ　１２３",
			opts:     Options{FullwidthToHalfwidth: false, ConvertGL: true, ConvertGR: true},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := yosina.StringFromChars(
				Transliterate(yosina.NewCharIteratorFromSlice(yosina.BuildCharArray(tt.input)), tt.opts),
			)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestJisx0201AndAlikeSpecialOptions(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
		opts     Options
	}{
		{
			name:     "u005c with GL conversion",
			input:    "\\",
			expected: "＼",
			opts:     Options{ConvertGL: true},
		},
		{
			name:     "hiragana conversion enabled",
			input:    "あいうえお",
			expected: "ｱｲｳｴｵ",
			opts:     Options{FullwidthToHalfwidth: true, ConvertHiraganas: true, ConvertGR: true},
		},
		{
			name:     "hiragana with voiced marks",
			input:    "がぎぐげご",
			expected: "ｶﾞｷﾞｸﾞｹﾞｺﾞ",
			opts:     Options{FullwidthToHalfwidth: true, ConvertHiraganas: true, ConvertGR: true},
		},
		{
			name:     "tilde with GL conversion",
			input:    "~",
			expected: "〜",
			opts:     Options{ConvertGL: true},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := yosina.StringFromChars(
				Transliterate(yosina.NewCharIteratorFromSlice(yosina.BuildCharArray(tt.input)), tt.opts),
			)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestJisx0201AndAlikeEdgeCases(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
		opts     Options
	}{
		{
			name:     "empty string",
			input:    "",
			expected: "",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGL: true, ConvertGR: true},
		},
		{
			name:     "no convertible characters",
			input:    "漢字ひらがな",
			expected: "漢字ひらがな",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGL: true, ConvertGR: true},
		},
		{
			name:     "preserve emoji and symbols",
			input:    "🎌ＡＢＣ🌸",
			expected: "🎌ABC🌸",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGL: true},
		},
		{
			name:     "newlines and tabs",
			input:    "Ａ\nＢ\tＣ",
			expected: "A\nB\tC",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGL: true},
		},
		{
			name:     "unicode surrogates",
			input:    "𝓐Ａ𝓑Ｂ",
			expected: "𝓐A𝓑B",
			opts:     Options{FullwidthToHalfwidth: true, ConvertGL: true},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := yosina.StringFromChars(
				Transliterate(yosina.NewCharIteratorFromSlice(yosina.BuildCharArray(tt.input)), tt.opts),
			)
			assert.Equal(t, tt.expected, result)
		})
	}
}
