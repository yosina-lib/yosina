package data

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLoadIvsSvsBase(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected []IvsSvsBaseRecord
		wantErr  bool
	}{
		{
			name:  "valid IVS/SVS base mapping",
			input: `[{"ivs":["U+4E9E", "U+E0100"],"svs":["U+4E9E"],"base90":"U+4E9F","base2004":"U+4EA0"}]`,
			expected: []IvsSvsBaseRecord{
				{
					IVS:      UCodepointTuple{0x4E9E, 0xE0100},
					SVS:      UCodepointTuple{0x4E9E, InvalidValue},
					Base90:   0x4E9F,
					Base2004: 0x4EA0,
				},
			},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := strings.NewReader(tt.input)
			result, err := LoadIvsSvsBase(r)
			if (err != nil) != tt.wantErr {
				t.Errorf("LoadIvsSvsBase() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			assert.Equal(t, tt.expected, result)
		})
	}
}
