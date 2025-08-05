package data

import (
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
)

type UCodepoint rune

const InvalidValue = UCodepoint(0x7fffffff)

func parseUnicodeString(s string) (UCodepoint, error) {
	if !strings.HasPrefix(s, "U+") {
		return 0, nil
	}

	// Parse U+XXXX format
	hexStr := s[2:]
	codepoint, err := strconv.ParseInt(hexStr, 16, 32)
	if err != nil {
		return 0, fmt.Errorf("invalid Unicode codepoint: %s", s)
	}

	return UCodepoint(codepoint), nil
}

func (u *UCodepoint) UnmarshalJSON(b []byte) error {
	var v string
	err := json.Unmarshal(b, &v)
	if err != nil {
		return err
	}
	*u, err = parseUnicodeString(v)
	return err
}

type UCodepointTuple [2]UCodepoint

func ToUCodepointTuple(s []UCodepoint) (r UCodepointTuple, err error) {
	switch len(s) {
	case 0:
		r = UCodepointTuple{InvalidValue, InvalidValue}
	case 1:
		r = UCodepointTuple{s[0], InvalidValue}
	case 2:
		r = UCodepointTuple{s[0], s[1]}
	default:
		err = fmt.Errorf("too many UCodepoint elements: %d", len(s))
	}
	return
}

func (u *UCodepointTuple) UnmarshalJSON(b []byte) error {
	var s []UCodepoint
	err := json.Unmarshal(b, &s)
	if err != nil {
		return err
	}
	*u, err = ToUCodepointTuple(s)
	return err
}
