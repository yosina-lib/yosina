package data

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestHyphens(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected []HyphensRecord
		wantErr  bool
	}{
		{
			name:  "valid hyphen mapping",
			input: `[{"code":"U+002D","name":"HYPHEN MINUS","ascii":["U+002D"],"jisx0201":["U+002D"],"jisx0208-1978":["U+2212"],"jisx0208-1978-windows":["U+2212"],"jisx0208_verbatim":null}]`,
			expected: []HyphensRecord{
				{
					Code:                0x002D,
					Name:                "HYPHEN MINUS",
					ASCII:               []UCodepoint{0x002D},
					Jisx0201:            []UCodepoint{0x002D},
					Jisx0208_90:         []UCodepoint{0x2212},
					Jisx0208_90_Windows: []UCodepoint{0x2212},
					Jisx0208_Verbatim:   InvalidValue,
				},
			},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := strings.NewReader(tt.input)
			result, err := LoadHyphens(r)
			if (err != nil) != tt.wantErr {
				t.Errorf("LoadHyphens() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			assert.Equal(t, tt.expected, result)
		})
	}
}
