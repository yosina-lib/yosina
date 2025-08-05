package data

import (
	"encoding/json"
	"fmt"
	"io"
)

// CircledOrSquaredRecord represents a circled or squared character mapping
type CircledOrSquaredRecord struct {
	Rendering string `json:"rendering"`
	Type      string `json:"type"`
	Emoji     bool   `json:"emoji"`
}

// LoadCircledOrSquared loads circled or squared character mappings from JSON data
func LoadCircledOrSquared(r io.Reader) (map[UCodepoint]CircledOrSquaredRecord, error) {
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

	mappings := make(map[UCodepoint]CircledOrSquaredRecord)

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

		// Read value object
		t, err = d.Token()
		if err != nil {
			if err == io.EOF {
				err = io.ErrUnexpectedEOF
			}
			return nil, fmt.Errorf("failed to decode value: %w", err)
		}
		delim, ok = t.(json.Delim)
		if !ok || delim != '{' {
			return nil, fmt.Errorf("expected object start for value, got %T", t)
		}

		var record CircledOrSquaredRecord

		// Read object fields
		for d.More() {
			// Read field name
			t, err := d.Token()
			if err != nil {
				return nil, fmt.Errorf("failed to decode field name: %w", err)
			}
			fieldName, ok := t.(string)
			if !ok {
				return nil, fmt.Errorf("expected string field name, got %T", t)
			}

			// Read field value
			switch fieldName {
			case "rendering":
				t, err = d.Token()
				if err != nil {
					return nil, fmt.Errorf("failed to decode rendering: %w", err)
				}
				if record.Rendering, ok = t.(string); !ok {
					return nil, fmt.Errorf("expected string for rendering, got %T", t)
				}
			case "type":
				t, err = d.Token()
				if err != nil {
					return nil, fmt.Errorf("failed to decode type: %w", err)
				}
				if record.Type, ok = t.(string); !ok {
					return nil, fmt.Errorf("expected string for type, got %T", t)
				}
			case "emoji":
				t, err = d.Token()
				if err != nil {
					return nil, fmt.Errorf("failed to decode emoji: %w", err)
				}
				if record.Emoji, ok = t.(bool); !ok {
					return nil, fmt.Errorf("expected bool for emoji, got %T", t)
				}
			default:
				// Skip unknown fields
				var dummy interface{}
				if err := d.Decode(&dummy); err != nil {
					return nil, fmt.Errorf("failed to skip unknown field %s: %w", fieldName, err)
				}
			}
		}

		// Read closing brace
		t, err = d.Token()
		if err != nil {
			return nil, fmt.Errorf("failed to read object end: %w", err)
		}
		delim, ok = t.(json.Delim)
		if !ok || delim != '}' {
			return nil, fmt.Errorf("expected object end, got %T", t)
		}

		mappings[k] = record
	}

	return mappings, nil
}
