package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"path/filepath"

	"github.com/yosina-lib/yosina/go/internal/codegen/data"
	"github.com/yosina-lib/yosina/go/internal/codegen/emitter"
)

type DatasetSourceDefs struct {
	Spaces                    string
	Radicals                  string
	MathematicalAlphanumerics string
	IdeographicAnnotations    string
	KanjiOldNew               string
	Hyphens                   string
	IvsSvsBase                string
	Combined                  string
	CircledOrSquared          string
	RomanNumerals             string
}

type SimpleDataset struct {
	dataRoot string
	defs     *DatasetSourceDefs
}

func writeArtifacts(outputDir string, artifacts []emitter.Artifact) error {
	for _, a := range artifacts {
		outputPath := filepath.Join(outputDir, a.Filename)
		if err := os.MkdirAll(filepath.Dir(outputPath), 0755); err != nil {
			return fmt.Errorf("failed to create directory %s: %w", filepath.Dir(outputPath), err)
		}
		if err := os.WriteFile(outputPath, a.Content, 0644); err != nil {
			return fmt.Errorf("failed to write file %s: %w", outputPath, err)
		}
	}
	return nil
}

func loadSimpleData(path string) (map[data.UCodepoint]data.UCodepoint, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("failed to open data file: %w", err)
	}
	defer f.Close()
	d, err := data.LoadSimple(bufio.NewReader(f))
	if err != nil {
		return nil, fmt.Errorf("failed to load data: %w", err)
	}
	return d, nil
}

func (sd *SimpleDataset) Spaces() (map[data.UCodepoint]data.UCodepoint, error) {
	return loadSimpleData(filepath.Join(sd.dataRoot, sd.defs.Spaces))
}

func (sd *SimpleDataset) Radicals() (map[data.UCodepoint]data.UCodepoint, error) {
	return loadSimpleData(filepath.Join(sd.dataRoot, sd.defs.Radicals))
}

func (sd *SimpleDataset) MathematicalAlphanumerics() (map[data.UCodepoint]data.UCodepoint, error) {
	return loadSimpleData(filepath.Join(sd.dataRoot, sd.defs.MathematicalAlphanumerics))
}

func (sd *SimpleDataset) IdeographicAnnotations() (map[data.UCodepoint]data.UCodepoint, error) {
	return loadSimpleData(filepath.Join(sd.dataRoot, sd.defs.IdeographicAnnotations))
}

func newSimpleDataset(dataRoot string, defs *DatasetSourceDefs) *SimpleDataset {
	return &SimpleDataset{
		dataRoot: dataRoot,
		defs:     defs,
	}
}

// Define data sources
var sources = DatasetSourceDefs{
	Spaces:                    "spaces.json",
	Radicals:                  "radicals.json",
	MathematicalAlphanumerics: "mathematical-alphanumerics.json",
	IdeographicAnnotations:    "ideographic-annotation-marks.json",
	KanjiOldNew:               "kanji-old-new-form.json",
	Hyphens:                   "hyphens.json",
	IvsSvsBase:                "ivs-svs-base-mappings.json",
	Combined:                  "combined-chars.json",
	CircledOrSquared:          "circled-or-squared.json",
	RomanNumerals:             "roman-numerals.json",
}

func (sd *SimpleDataset) KanjiOldNew() (map[data.UCodepointTuple]data.UCodepointTuple, error) {
	dataPath := filepath.Join(sd.dataRoot, sd.defs.KanjiOldNew)
	f, err := os.Open(dataPath)
	if err != nil {
		return nil, fmt.Errorf("failed to open kanji old-new data file: %w", err)
	}
	defer f.Close()
	return data.LoadKanjiOldNewData(bufio.NewReader(f))
}

func (sd *SimpleDataset) Combined() (map[data.UCodepoint][]string, error) {
	dataPath := filepath.Join(sd.dataRoot, sd.defs.Combined)
	f, err := os.Open(dataPath)
	if err != nil {
		return nil, fmt.Errorf("failed to open combined data file: %w", err)
	}
	defer f.Close()
	return data.LoadCombined(bufio.NewReader(f))
}

func (sd *SimpleDataset) CircledOrSquared() (map[data.UCodepoint]data.CircledOrSquaredRecord, error) {
	dataPath := filepath.Join(sd.dataRoot, sd.defs.CircledOrSquared)
	f, err := os.Open(dataPath)
	if err != nil {
		return nil, fmt.Errorf("failed to open circled-or-squared data file: %w", err)
	}
	defer f.Close()
	return data.LoadCircledOrSquared(bufio.NewReader(f))
}

func (sd *SimpleDataset) RomanNumerals() ([]data.RomanNumeralsRecord, error) {
	dataPath := filepath.Join(sd.dataRoot, sd.defs.RomanNumerals)
	f, err := os.Open(dataPath)
	if err != nil {
		return nil, fmt.Errorf("failed to open roman-numerals data file: %w", err)
	}
	defer f.Close()
	return data.LoadRomanNumerals(bufio.NewReader(f))
}

func renderSimpleTransliterators(outputDir string, em *emitter.Emitter, dataset *SimpleDataset) error {
	targets := map[string]func() (map[data.UCodepoint]data.UCodepoint, error){
		"spaces":                     dataset.Spaces,
		"radicals":                   dataset.Radicals,
		"mathematical_alphanumerics": dataset.MathematicalAlphanumerics,
		"ideographic_annotations":    dataset.IdeographicAnnotations,
	}

	for name, fn := range targets {
		fmt.Printf("Generating %s...\n", name)
		d, err := fn()
		if err != nil {
			return fmt.Errorf("failed to load %s: %v", name, err)
		}
		as, err := em.GenerateSimpleTransliterator(name, d)
		if err != nil {
			log.Fatalf("Failed to generate %s: %v", name, err)
		}
		err = writeArtifacts(outputDir, as)
		if err != nil {
			return fmt.Errorf("failed to write artifacts for %s: %v", name, err)
		}
	}
	return nil
}

func renderHyphensTransliterator(outputDir string, em *emitter.Emitter, dataset *SimpleDataset) error {
	fmt.Println("Generating hyphens...")

	// Load hyphens data
	dataPath := filepath.Join(dataset.dataRoot, dataset.defs.Hyphens)
	f, err := os.Open(dataPath)
	if err != nil {
		return fmt.Errorf("failed to open hyphens data file: %w", err)
	}
	defer f.Close()

	records, err := data.LoadHyphens(bufio.NewReader(f))
	if err != nil {
		return fmt.Errorf("failed to load hyphens data: %w", err)
	}

	// Generate hyphens transliterator
	artifacts, err := em.GenerateHyphensTransliterator("hyphens", records)
	if err != nil {
		return fmt.Errorf("failed to generate hyphens transliterator: %w", err)
	}

	// Write artifacts
	err = writeArtifacts(outputDir, artifacts)
	if err != nil {
		return fmt.Errorf("failed to write hyphens artifacts: %w", err)
	}

	return nil
}

func renderKanjiOldNewTransliterator(outputDir string, em *emitter.Emitter, dataset *SimpleDataset) error {
	fmt.Println("Generating kanji_old_new...")

	// Load kanji old-new data
	d, err := dataset.KanjiOldNew()
	if err != nil {
		return fmt.Errorf("failed to load kanji old-new data: %w", err)
	}

	// Generate kanji old-new transliterator
	artifacts, err := em.GenerateKanjiOldNewTransliterator("kanji_old_new", d)
	if err != nil {
		return fmt.Errorf("failed to generate kanji old-new transliterator: %w", err)
	}

	// Write artifacts
	err = writeArtifacts(outputDir, artifacts)
	if err != nil {
		return fmt.Errorf("failed to write kanji old-new artifacts: %w", err)
	}

	return nil
}

func renderIvsSvsBaseTransliterator(outputDir string, em *emitter.Emitter, dataset *SimpleDataset) error {
	fmt.Println("Generating ivs_svs_base...")

	// Load IVS/SVS base data
	dataPath := filepath.Join(dataset.dataRoot, dataset.defs.IvsSvsBase)
	f, err := os.Open(dataPath)
	if err != nil {
		return fmt.Errorf("failed to open IVS/SVS base data file: %w", err)
	}
	defer f.Close()

	records, err := data.LoadIvsSvsBase(bufio.NewReader(f))
	if err != nil {
		return fmt.Errorf("failed to load IVS/SVS base data: %w", err)
	}

	// Generate IVS/SVS base transliterator
	artifacts, err := em.GenerateIvsSvsBaseTransliterator("ivs_svs_base", records)
	if err != nil {
		return fmt.Errorf("failed to generate IVS/SVS base transliterator: %w", err)
	}

	// Write artifacts
	err = writeArtifacts(outputDir, artifacts)
	if err != nil {
		return fmt.Errorf("failed to write IVS/SVS base artifacts: %w", err)
	}

	return nil
}

func renderCombinedTransliterator(outputDir string, em *emitter.Emitter, dataset *SimpleDataset) error {
	fmt.Println("Generating combined...")

	// Load combined data
	d, err := dataset.Combined()
	if err != nil {
		return fmt.Errorf("failed to load combined data: %w", err)
	}

	// Generate combined transliterator
	artifacts, err := em.GenerateCombinedTransliterator("combined", d)
	if err != nil {
		return fmt.Errorf("failed to generate combined transliterator: %w", err)
	}

	// Write artifacts
	err = writeArtifacts(outputDir, artifacts)
	if err != nil {
		return fmt.Errorf("failed to write combined artifacts: %w", err)
	}

	return nil
}

func renderCircledOrSquaredTransliterator(outputDir string, em *emitter.Emitter, dataset *SimpleDataset) error {
	fmt.Println("Generating circled_or_squared...")

	// Load circled or squared data
	d, err := dataset.CircledOrSquared()
	if err != nil {
		return fmt.Errorf("failed to load circled or squared data: %w", err)
	}

	// Generate circled or squared transliterator
	artifacts, err := em.GenerateCircledOrSquaredTransliterator("circled_or_squared", d)
	if err != nil {
		return fmt.Errorf("failed to generate circled or squared transliterator: %w", err)
	}

	// Write artifacts
	err = writeArtifacts(outputDir, artifacts)
	if err != nil {
		return fmt.Errorf("failed to write circled or squared artifacts: %w", err)
	}

	return nil
}

func renderRomanNumeralsTransliterator(outputDir string, em *emitter.Emitter, dataset *SimpleDataset) error {
	fmt.Println("Generating roman_numerals...")

	// Load roman numerals data
	records, err := dataset.RomanNumerals()
	if err != nil {
		return fmt.Errorf("failed to load roman numerals data: %w", err)
	}

	// Generate roman numerals transliterator
	artifacts, err := em.GenerateRomanNumeralsTransliterator("roman_numerals", records)
	if err != nil {
		return fmt.Errorf("failed to generate roman numerals transliterator: %w", err)
	}

	// Write artifacts
	err = writeArtifacts(outputDir, artifacts)
	if err != nil {
		return fmt.Errorf("failed to write roman numerals artifacts: %w", err)
	}

	return nil
}

func main() {
	// Determine paths
	wd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	// Find project root by looking for go.mod
	projectRoot := wd
	for {
		if _, err := os.Stat(filepath.Join(projectRoot, "go.mod")); err == nil {
			break
		}
		parent := filepath.Dir(projectRoot)
		if parent == projectRoot {
			log.Fatal("Could not find project root (go.mod not found)")
		}
		projectRoot = parent
	}

	dataRoot := filepath.Join(filepath.Dir(projectRoot), "data")
	outputDir := filepath.Join(projectRoot, "transliterators")
	em := emitter.New("transliterators")

	fmt.Printf("Data root: %s\n", dataRoot)
	fmt.Printf("Output dir: %s\n", outputDir)

	dataset := newSimpleDataset(dataRoot, &sources)

	err = renderSimpleTransliterators(outputDir, em, dataset)
	if err != nil {
		log.Fatalf("Failed to render simple transliterators: %v", err)
	}

	err = renderHyphensTransliterator(outputDir, em, dataset)
	if err != nil {
		log.Fatalf("Failed to render hyphens transliterator: %v", err)
	}

	err = renderKanjiOldNewTransliterator(outputDir, em, dataset)
	if err != nil {
		log.Fatalf("Failed to render kanji old-new transliterator: %v", err)
	}

	err = renderIvsSvsBaseTransliterator(outputDir, em, dataset)
	if err != nil {
		log.Fatalf("Failed to render IVS/SVS base transliterator: %v", err)
	}

	err = renderCombinedTransliterator(outputDir, em, dataset)
	if err != nil {
		log.Fatalf("Failed to render combined transliterator: %v", err)
	}

	err = renderCircledOrSquaredTransliterator(outputDir, em, dataset)
	if err != nil {
		log.Fatalf("Failed to render circled or squared transliterator: %v", err)
	}

	err = renderRomanNumeralsTransliterator(outputDir, em, dataset)
	if err != nil {
		log.Fatalf("Failed to render roman numerals transliterator: %v", err)
	}

	fmt.Println("Code generation complete!")
}
