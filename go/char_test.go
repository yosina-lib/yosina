package yosina

import (
	"testing"
)

func TestBuildCharArrayOffsets(t *testing.T) {
	tests := []struct {
		name     string
		text     string
		expected []int // expected byte offsets
	}{
		{
			name:     "ASCII only",
			text:     "abc",
			expected: []int{0, 1, 2, 3}, // 3 chars + sentinel
		},
		{
			name:     "Japanese hiragana",
			text:     "あいう",             // 3 bytes per char in UTF-8
			expected: []int{0, 3, 6, 9}, // 3 chars + sentinel
		},
		{
			name:     "Mixed ASCII and Japanese",
			text:     "aあb",
			expected: []int{0, 1, 4, 5}, // 'a' at 0, 'あ' at 1, 'b' at 4, sentinel at 5
		},
		{
			name:     "Emoji (4-byte UTF-8)",
			text:     "😀😁",           // 4 bytes per emoji in UTF-8
			expected: []int{0, 4, 8}, // 2 emojis + sentinel
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			chars := BuildCharArray(tt.text)
			if len(chars) != len(tt.expected) {
				t.Errorf("expected %d chars, got %d", len(tt.expected), len(chars))
				return
			}
			for i, c := range chars {
				if c.Offset != tt.expected[i] {
					t.Errorf("char %d: expected offset %d, got %d", i, tt.expected[i], c.Offset)
				}
			}
		})
	}
}

func TestRuneLen(t *testing.T) {
	tests := []struct {
		name     string
		char     *Char
		expected int
	}{
		{
			name:     "ASCII char",
			char:     &Char{C: [2]rune{'a', InvalidUnicodeValue}},
			expected: 1,
		},
		{
			name:     "Japanese char",
			char:     &Char{C: [2]rune{'あ', InvalidUnicodeValue}},
			expected: 3,
		},
		{
			name:     "Emoji",
			char:     &Char{C: [2]rune{'😀', InvalidUnicodeValue}},
			expected: 4,
		},
		{
			name:     "IVS sequence",
			char:     &Char{C: [2]rune{'葛', 0xE0100}}, // Kanji with variation selector
			expected: 7,                               // 3 bytes for '葛' + 4 bytes for U+E0100
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := tt.char.RuneLen()
			if got != tt.expected {
				t.Errorf("expected byte length %d, got %d", tt.expected, got)
			}
		})
	}
}
