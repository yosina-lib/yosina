package data

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLoadSimple(t *testing.T) {
	data := `{
		"U+0041": "U+0042",
		"U+0042": "U+0043"
	}`

	r := strings.NewReader(data)
	mappings, err := LoadSimple(r)
	if !assert.NoError(t, err) {
		return
	}
	assert.Equal(t, map[UCodepoint]UCodepoint{
		'A': 'B',
		'B': 'C',
	}, mappings)
}
