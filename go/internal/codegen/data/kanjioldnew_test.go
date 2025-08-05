package data

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLoadKanjiOldNew(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected map[UCodepointTuple]UCodepointTuple
		wantErr  bool
	}{
		{
			name:  "single mapping with IVS to single IVS",
			input: `[[{"ivs":["U+4E9E", "U+E0100"],"svs":null},{"ivs":["U+4E9E"],"svs":["U+4E9E"]}]]`,
			expected: map[UCodepointTuple]UCodepointTuple{
				{0x4E9E, 0xE0100}: {0x4E9E, InvalidValue},
			},
			wantErr: false,
		},
		{
			name:  "mapping with both IVS and SVS in source",
			input: `[[{"ivs":["U+4E9E", "U+E0100"],"svs":["U+4E9E"]},{"ivs":["U+4E9C"],"svs":null}]]`,
			expected: map[UCodepointTuple]UCodepointTuple{
				{0x4E9E, 0xE0100}:      {0x4E9C, InvalidValue},
				{0x4E9E, InvalidValue}: {0x4E9C, InvalidValue},
			},
			wantErr: false,
		},
		{
			name:  "mapping with SVS only in source",
			input: `[[{"ivs":null,"svs":["U+4E9E"]},{"ivs":["U+4E9C"],"svs":null}]]`,
			expected: map[UCodepointTuple]UCodepointTuple{
				{0x4E9E, InvalidValue}: {0x4E9C, InvalidValue},
			},
			wantErr: false,
		},
		{
			name:  "mapping to SVS target",
			input: `[[{"ivs":["U+4E9E"],"svs":null},{"ivs":null,"svs":["U+4E9C"]}]]`,
			expected: map[UCodepointTuple]UCodepointTuple{
				{0x4E9E, InvalidValue}: {0x4E9C, InvalidValue},
			},
			wantErr: false,
		},
		{
			name:  "mapping with two-codepoint IVS",
			input: `[[{"ivs":["U+4E9E", "U+E0100"],"svs":null},{"ivs":["U+4E9C", "U+E0101"],"svs":null}]]`,
			expected: map[UCodepointTuple]UCodepointTuple{
				{0x4E9E, 0xE0100}: {0x4E9C, 0xE0101},
			},
			wantErr: false,
		},
		{
			name: "multiple mappings",
			input: `[
				[{"ivs":["U+4E9E"],"svs":null},{"ivs":["U+4E9C"],"svs":null}],
				[{"ivs":["U+4E00"],"svs":null},{"ivs":["U+4E01"],"svs":null}]
			]`,
			expected: map[UCodepointTuple]UCodepointTuple{
				{0x4E9E, InvalidValue}: {0x4E9C, InvalidValue},
				{0x4E00, InvalidValue}: {0x4E01, InvalidValue},
			},
			wantErr: false,
		},
		{
			name:    "empty source IVS and SVS should error",
			input:   `[[{"ivs":null,"svs":null},{"ivs":["U+4E9C"],"svs":null}]]`,
			wantErr: true,
		},
		{
			name:    "empty target IVS and SVS should error",
			input:   `[[{"ivs":["U+4E9E"],"svs":null},{"ivs":null,"svs":null}]]`,
			wantErr: true,
		},
		{
			name:    "invalid JSON should error",
			input:   `invalid json`,
			wantErr: true,
		},
		{
			name:    "too many codepoints in IVS should error",
			input:   `[[{"ivs":["U+4E9E", "U+E0100", "U+E0101"],"svs":null},{"ivs":["U+4E9C"],"svs":null}]]`,
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			r := strings.NewReader(tt.input)
			mappings, err := LoadKanjiOldNewData(r)

			if tt.wantErr {
				assert.Error(t, err)
				return
			}

			if !assert.NoError(t, err) {
				return
			}
			assert.Equal(t, tt.expected, mappings)
		})
	}
}
