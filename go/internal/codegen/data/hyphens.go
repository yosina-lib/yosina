package data

import (
	"encoding/json"
	"io"
)

// HyphensRecord represents a hyphen mapping record
type HyphensRecord struct {
	Code                UCodepoint   `json:"code"`
	Name                string       `json:"name"`
	ASCII               []UCodepoint `json:"ascii"`
	Jisx0201            []UCodepoint `json:"jisx0201"`
	Jisx0208_90         []UCodepoint `json:"jisx0208-1978"`
	Jisx0208_90_Windows []UCodepoint `json:"jisx0208-1978-windows"`
	Jisx0208_Verbatim   UCodepoint   `json:"jisx0208-verbatim,omitempty"`
}

// LoadHyphens loads hyphen mappings from the given reader
func LoadHyphens(r io.Reader) ([]HyphensRecord, error) {
	d := json.NewDecoder(r)
	var records []HyphensRecord
	err := d.Decode(&records)
	if err != nil {
		return nil, err
	}
	for i := range records {
		if records[i].Jisx0208_Verbatim == 0 {
			records[i].Jisx0208_Verbatim = InvalidValue
		}
	}
	return records, nil
}
