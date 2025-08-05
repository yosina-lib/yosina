package data

import (
	"encoding/json"
	"fmt"
	"io"
)

// LoadKanjiOldNewData loads the kanji old-new data from a JSON file.
func LoadKanjiOldNewData(r io.Reader) (map[UCodepointTuple]UCodepointTuple, error) {
	type ivsSvsPairRecord struct {
		Ivs []UCodepoint `json:"ivs,omitempty"`
		Svs []UCodepoint `json:"svs,omitempty"`
	}
	type kanjiOldNewRecord [2]ivsSvsPairRecord
	var records []kanjiOldNewRecord
	err := json.NewDecoder(r).Decode(&records)
	if err != nil {
		return nil, err
	}
	mappings := make(map[UCodepointTuple]UCodepointTuple)
	for i, record := range records {
		var to UCodepointTuple
		if len(record[1].Ivs) == 0 {
			if len(record[1].Svs) == 0 {
				return nil, fmt.Errorf("invalid record at index %d: empty IVS and SVS", i)
			}
			to, err = ToUCodepointTuple(record[1].Svs)
			if err != nil {
				return nil, fmt.Errorf("invalid SVS at index %d: %w", i, err)
			}
		} else {
			to, err = ToUCodepointTuple(record[1].Ivs)
			if err != nil {
				return nil, fmt.Errorf("invalid SVS at index %d: %w", i, err)
			}
		}

		if len(record[0].Ivs) == 0 {
			if len(record[0].Svs) == 0 {
				return nil, fmt.Errorf("invalid record at index %d: empty IVS and SVS", i)
			}
			from, err := ToUCodepointTuple(record[0].Svs)
			if err != nil {
				return nil, fmt.Errorf("invalid SVS at index %d: %w", i, err)
			}
			mappings[from] = to
		} else {
			from, err := ToUCodepointTuple(record[0].Ivs)
			if err != nil {
				return nil, fmt.Errorf("invalid IVS at index %d: %w", i, err)
			}
			mappings[from] = to
			if len(record[0].Svs) > 0 {
				from, err = ToUCodepointTuple(record[0].Svs)
				if err != nil {
					return nil, fmt.Errorf("invalid SVS at index %d: %w", i, err)
				}
				mappings[from] = to
			}
		}
	}
	return mappings, nil
}
