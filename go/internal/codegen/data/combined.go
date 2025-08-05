package data

import (
	"encoding/json"
	"fmt"
	"io"
)

// LoadCombined loads combined character mappings from JSON data
func LoadCombined(r io.Reader) (map[UCodepoint][]string, error) {
	d := json.NewDecoder(r)

	// Read the opening brace
	t, err := d.Token()
	if err != nil {
		if err == io.EOF {
			err = io.ErrUnexpectedEOF
		}
		return nil, err
	}
	delim, ok := t.(json.Delim)
	if !ok {
		return nil, fmt.Errorf("expected JSON object start, got %T", t)
	}
	if delim != '{' {
		return nil, fmt.Errorf("expected JSON object start, got %q", delim)
	}

	mappings := make(map[UCodepoint][]string)

	for d.More() {
		var k UCodepoint

		// Read key
		t, err := d.Token()
		if err != nil {
			if err == io.EOF {
				err = io.ErrUnexpectedEOF
			}
			return nil, fmt.Errorf("failed to decode key: %w", err)
		}
		s, ok := t.(string)
		if !ok {
			return nil, fmt.Errorf("expected string key, got %T", t)
		}
		k, err = parseUnicodeString(s)
		if err != nil {
			return nil, fmt.Errorf("invalid key %q: %w", s, err)
		}

		// Read value
		t, err = d.Token()
		if err != nil {
			if err == io.EOF {
				err = io.ErrUnexpectedEOF
			}
			return nil, fmt.Errorf("failed to decode value: %w", err)
		}
		valueStr, ok := t.(string)
		if !ok {
			return nil, fmt.Errorf("expected string value, got %T", t)
		}

		// Split the value string into individual characters
		charList := make([]string, 0, len(valueStr))
		for _, char := range valueStr {
			charList = append(charList, string(char))
		}

		mappings[k] = charList
	}

	return mappings, nil
}
