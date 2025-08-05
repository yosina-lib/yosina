package mathematical_alphanumerics

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestSimpleTransliteratorMathematicalAlphanumerics(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{
			name:     "Test Case 1",
			input:    "plain",
			expected: "plain",
		},
		{
			name:     "Test Case 2",
			input:    "𝕋𝔼𝕊𝕋",
			expected: "TEST",
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
