package data

import (
	"encoding/json"
	"io"
)

// RomanNumeralsRecord represents a roman numeral mapping record
type RomanNumeralsRecord struct {
	Value int `json:"value"`
	Codes struct {
		Upper UCodepoint `json:"upper"`
		Lower UCodepoint `json:"lower"`
	} `json:"codes"`
	ShiftJIS struct {
		Upper []int `json:"upper"`
		Lower []int `json:"lower"`
	} `json:"shift_jis"`
	Decomposed struct {
		Upper []UCodepoint `json:"upper"`
		Lower []UCodepoint `json:"lower"`
	} `json:"decomposed"`
}

// LoadRomanNumerals loads roman numeral mappings from the given reader
func LoadRomanNumerals(r io.Reader) ([]RomanNumeralsRecord, error) {
	d := json.NewDecoder(r)
	var records []RomanNumeralsRecord
	err := d.Decode(&records)
	if err != nil {
		return nil, err
	}
	return records, nil
}
