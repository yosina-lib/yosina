package data

import (
	"encoding/json"
	"io"
)

// IvsSvsBaseRecord represents an IVS/SVS base mapping record
type IvsSvsBaseRecord struct {
	IVS      UCodepointTuple `json:"ivs"`
	SVS      UCodepointTuple `json:"svs,omitempty"`
	Base90   UCodepoint      `json:"base90,omitempty"`
	Base2004 UCodepoint      `json:"base2004,omitempty"`
}

func LoadIvsSvsBase(r io.Reader) ([]IvsSvsBaseRecord, error) {
	d := json.NewDecoder(r)
	var records []IvsSvsBaseRecord
	err := d.Decode(&records)
	for i := range records {
		if records[i].Base90 == 0 {
			records[i].Base90 = InvalidValue
		}
		if records[i].Base2004 == 0 {
			records[i].Base2004 = InvalidValue
		}
	}
	return records, err
}
