package historical_hirakatas

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func transliterate(input string, opts Options) string {
	chars := yosina.BuildCharArray(input)
	iter := yosina.NewCharIteratorFromSlice(chars)
	result := Transliterate(iter, opts)
	return yosina.StringFromChars(result)
}

func TestSimpleHiraganaDefault(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "basic conversion",
			input:    "ゐゑ",
			expected: "いえ",
		},
		{
			name:     "passthrough",
			input:    "あいう",
			expected: "あいう",
		},
		{
			name:     "mixed input",
			input:    "あゐいゑう",
			expected: "あいいえう",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			assert.Equal(t, tt.expected, transliterate(tt.input, Options{}))
		})
	}
}

func TestDecomposeHiragana(t *testing.T) {
	result := transliterate("ゐゑ", Options{
		Hiraganas: Decompose,
		Katakanas: Skip,
	})
	assert.Equal(t, "うぃうぇ", result)
}

func TestSkipHiragana(t *testing.T) {
	result := transliterate("ゐゑ", Options{
		Hiraganas: Skip,
		Katakanas: Skip,
	})
	assert.Equal(t, "ゐゑ", result)
}

func TestSimpleKatakanaDefault(t *testing.T) {
	result := transliterate("ヰヱ", Options{})
	assert.Equal(t, "イエ", result)
}

func TestDecomposeKatakana(t *testing.T) {
	result := transliterate("ヰヱ", Options{
		Hiraganas: Skip,
		Katakanas: Decompose,
	})
	assert.Equal(t, "ウィウェ", result)
}

func TestVoicedKatakanaDecompose(t *testing.T) {
	result := transliterate("ヷヸヹヺ", Options{
		Hiraganas:       Skip,
		Katakanas:       Skip,
		VoicedKatakanas: Decompose,
	})
	assert.Equal(t, "ヴァヴィヴェヴォ", result)
}

func TestVoicedKatakanaSkipDefault(t *testing.T) {
	result := transliterate("ヷヸヹヺ", Options{
		Hiraganas: Skip,
		Katakanas: Skip,
	})
	assert.Equal(t, "ヷヸヹヺ", result)
}

func TestAllDecompose(t *testing.T) {
	result := transliterate("ゐゑヰヱヷヸヹヺ", Options{
		Hiraganas:       Decompose,
		Katakanas:       Decompose,
		VoicedKatakanas: Decompose,
	})
	assert.Equal(t, "うぃうぇウィウェヴァヴィヴェヴォ", result)
}

func TestAllSkip(t *testing.T) {
	result := transliterate("ゐゑヰヱヷヸヹヺ", Options{
		Hiraganas:       Skip,
		Katakanas:       Skip,
		VoicedKatakanas: Skip,
	})
	assert.Equal(t, "ゐゑヰヱヷヸヹヺ", result)
}

func TestDecomposedVoicedKatakanaDecompose(t *testing.T) {
	// Decomposed ワ+゙ ヰ+゙ ヱ+゙ ヲ+゙ should produce decomposed output
	result := transliterate("ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099", Options{
		Hiraganas:       Skip,
		Katakanas:       Skip,
		VoicedKatakanas: Decompose,
	})
	assert.Equal(t, "ウ\u3099ァウ\u3099ィウ\u3099ェウ\u3099ォ", result)
}

func TestDecomposedVoicedKatakanaSkip(t *testing.T) {
	// Decomposed voiced katakana with skip mode should pass through unchanged
	result := transliterate("ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099", Options{
		Hiraganas:       Skip,
		Katakanas:       Skip,
		VoicedKatakanas: Skip,
	})
	assert.Equal(t, "ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099", result)
}

func TestDecomposedVoicedNotSplitFromBase(t *testing.T) {
	// ヰ+゙ must be treated as ヸ (voiced), not as ヰ (katakana) + separate ゙
	result := transliterate("ヰ\u3099", Options{
		Hiraganas:       Skip,
		Katakanas:       Simple,
		VoicedKatakanas: Skip,
	})
	assert.Equal(t, "ヰ\u3099", result)
}

func TestDecomposedVoicedWithDecompose(t *testing.T) {
	// ヰ+゙ = ヸ, should produce ウ+゙+ィ (decomposed)
	result := transliterate("ヰ\u3099", Options{
		Hiraganas:       Skip,
		Katakanas:       Skip,
		VoicedKatakanas: Decompose,
	})
	assert.Equal(t, "ウ\u3099ィ", result)
}

func TestEmptyInput(t *testing.T) {
	result := transliterate("", Options{})
	assert.Equal(t, "", result)
}
