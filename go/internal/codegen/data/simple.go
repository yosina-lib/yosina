package data

import (
	"encoding/json"
	"fmt"
	"io"
)

func LoadSimple(r io.Reader) (map[UCodepoint]UCodepoint, error) {
	d := json.NewDecoder(r)
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
	mappings := make(map[UCodepoint]UCodepoint)
	for d.More() {
		var k UCodepoint
		v := InvalidValue
		t, err := d.Token()
		if err != nil {
			if err == io.EOF {
				err = io.ErrUnexpectedEOF
			}
			return nil, fmt.Errorf("failed to decode value: %w", err)
		}
		s, ok := t.(string)
		if !ok {
			return nil, fmt.Errorf("expected string key, got %T", t)
		}
		k, err = parseUnicodeString(s)
		if err != nil {
			return nil, fmt.Errorf("invalid key %q: %w", s, err)
		}
		t, err = d.Token()
		if err != nil {
			if err == io.EOF {
				err = io.ErrUnexpectedEOF
			}
			return nil, fmt.Errorf("failed to decode value: %w", err)
		}
		if t != nil {
			s, ok = t.(string)
			if !ok {
				return nil, fmt.Errorf("expected string value, got %T", t)
			}
			v, err = parseUnicodeString(s)
			if err != nil {
				return nil, fmt.Errorf("invalid value %q for key %q: %w", s, k, err)
			}
		}
		mappings[k] = v
	}
	return mappings, nil
}
