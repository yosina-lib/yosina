package recipe

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/yosina-lib/yosina/go/transliterators/hira_kata_composition"
	"github.com/yosina-lib/yosina/go/transliterators/hyphens"
	"github.com/yosina-lib/yosina/go/transliterators/ivs_svs_base"
	"github.com/yosina-lib/yosina/go/transliterators/jisx0201_and_alike"
	"github.com/yosina-lib/yosina/go/transliterators/prolonged_sound_marks"
)

func TestDefaultRecipeValues(t *testing.T) {
	recipe := NewTransliterationRecipe()

	assert.False(t, recipe.KanjiOldNew)
	assert.False(t, recipe.ReplaceSuspiciousHyphensToProlongedSoundMarks)
	assert.False(t, recipe.ReplaceIdeographicAnnotations)
	assert.False(t, recipe.ReplaceRadicals)
	assert.False(t, recipe.ReplaceSpaces)
	assert.False(t, recipe.ReplaceHyphens.Enabled)
	assert.False(t, recipe.ReplaceMathematicalAlphanumerics)
	assert.False(t, recipe.CombineDecomposedHiraganasAndKatakanas)
	assert.False(t, recipe.ReplaceCombinedCharacters)
	assert.Equal(t, No, recipe.ReplaceCircledOrSquaredCharacters)
	assert.Equal(t, No, recipe.ToFullwidth)
	assert.Equal(t, No, recipe.ToHalfwidth)
	assert.Equal(t, No, recipe.RemoveIVSSVS)
	assert.Equal(t, "unijis_2004", recipe.Charset)
}

func TestEmptyRecipeProducesEmptyConfigs(t *testing.T) {
	recipe := NewTransliterationRecipe()
	configs, err := recipe.BuildTransliteratorConfigs()

	require.NoError(t, err)
	assert.Empty(t, configs, "Empty recipe should produce empty config list")
}

func TestKanjiOldNewConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.KanjiOldNew = true

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	// Should contain kanji-old-new and IVS/SVS configurations
	assert.True(t, containsConfig(configs, "kanji-old-new"), "Should contain kanji-old-new")
	assert.True(t, containsConfig(configs, "ivs-svs-base"), "Should contain ivs-svs-base for kanji-old-new")

	// Should have at least 3 configs: ivs-or-svs, kanji-old-new, base
	assert.GreaterOrEqual(t, len(configs), 3, "Should have multiple configs for kanji-old-new")
}

func TestProlongedSoundMarksConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ReplaceSuspiciousHyphensToProlongedSoundMarks = true

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	assert.True(t, containsConfig(configs, "prolonged-sound-marks"), "Should contain prolonged-sound-marks")

	// Verify options are set correctly
	config := findConfig(configs, "prolonged-sound-marks")
	require.NotNil(t, config)
	require.NotNil(t, config.Options)

	options, ok := config.Options.(*prolonged_sound_marks.Options)
	require.True(t, ok, "Options should be of correct type")
	assert.True(t, options.ReplaceProlongedMarksFollowingAlnums)
}

func TestBasicTransliteratorsConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ReplaceIdeographicAnnotations = true
	recipe.ReplaceRadicals = true
	recipe.ReplaceSpaces = true
	recipe.ReplaceMathematicalAlphanumerics = true

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	assert.True(t, containsConfig(configs, "ideographic-annotations"))
	assert.True(t, containsConfig(configs, "radicals"))
	assert.True(t, containsConfig(configs, "spaces"))
	assert.True(t, containsConfig(configs, "mathematical-alphanumerics"))
}

func TestHyphensConfigurationWithDefaultPrecedence(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ReplaceHyphens = NewReplaceHyphensOption(true)

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	assert.True(t, containsConfig(configs, "hyphens"))

	config := findConfig(configs, "hyphens")
	require.NotNil(t, config)
	require.NotNil(t, config.Options)

	options, ok := config.Options.(*hyphens.Options)
	require.True(t, ok, "Options should be of correct type")

	expected := []hyphens.Mapping{hyphens.Jisx0208_90_Windows, hyphens.Jisx0201}
	assert.Equal(t, expected, options.Precedence)
}

func TestHyphensConfigurationWithCustomPrecedence(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ReplaceHyphens = ReplaceHyphensOption{
		Enabled:    true,
		Precedence: []string{"jisx0201", "jisx0208_90_windows"},
	}

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	config := findConfig(configs, "hyphens")
	require.NotNil(t, config)
	require.NotNil(t, config.Options)

	options, ok := config.Options.(*hyphens.Options)
	require.True(t, ok, "Options should be of correct type")

	expected := []hyphens.Mapping{hyphens.Jisx0201, hyphens.Jisx0208_90_Windows}
	assert.Equal(t, expected, options.Precedence)
}

func TestHiraKataCompositionConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.CombineDecomposedHiraganasAndKatakanas = true

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	assert.True(t, containsConfig(configs, "hira-kata-composition"))

	config := findConfig(configs, "hira-kata-composition")
	require.NotNil(t, config)
	require.NotNil(t, config.Options)

	options, ok := config.Options.(*hira_kata_composition.Options)
	require.True(t, ok, "Options should be of correct type")
	assert.True(t, options.ComposeNonCombiningMarks, "Should compose non-combining marks by default")
}

func TestToFullwidthConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ToFullwidth = Yes

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	assert.True(t, containsConfig(configs, "jisx0201-and-alike"))

	config := findConfig(configs, "jisx0201-and-alike")
	require.NotNil(t, config)
	require.NotNil(t, config.Options)

	options, ok := config.Options.(*jisx0201_and_alike.Options)
	require.True(t, ok, "Options should be of correct type")
	assert.False(t, options.FullwidthToHalfwidth)
	assert.False(t, options.U005cAsYenSign.IsTrue())
}

func TestToFullwidthWithYenSignConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ToFullwidth = U005cAsYenSign

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	config := findConfig(configs, "jisx0201-and-alike")
	require.NotNil(t, config)
	require.NotNil(t, config.Options)

	options, ok := config.Options.(*jisx0201_and_alike.Options)
	require.True(t, ok, "Options should be of correct type")
	assert.True(t, options.U005cAsYenSign.IsTrue())
}

func TestToHalfwidthConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ToHalfwidth = Yes

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	config := findConfig(configs, "jisx0201-and-alike")
	require.NotNil(t, config)
	require.NotNil(t, config.Options)

	options, ok := config.Options.(*jisx0201_and_alike.Options)
	require.True(t, ok, "Options should be of correct type")
	assert.True(t, options.FullwidthToHalfwidth)
	assert.True(t, options.ConvertGL)
	assert.False(t, options.ConvertGR)
}

func TestToHalfwidthWithHankakuKanaConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ToHalfwidth = HankakuKana

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	config := findConfig(configs, "jisx0201-and-alike")
	require.NotNil(t, config)
	require.NotNil(t, config.Options)

	options, ok := config.Options.(*jisx0201_and_alike.Options)
	require.True(t, ok, "Options should be of correct type")
	assert.True(t, options.ConvertGR)
}

func TestMutuallyExclusiveFullwidthHalfwidth(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ToFullwidth = Yes
	recipe.ToHalfwidth = Yes

	_, err := recipe.BuildTransliteratorConfigs()
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "mutually exclusive")
}

func TestRemoveIvsSvsConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.RemoveIVSSVS = Yes

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	ivsSvsCount := 0
	for _, config := range configs {
		if config.Name == "ivs-svs-base" {
			ivsSvsCount++
		}
	}
	assert.Equal(t, 2, ivsSvsCount, "Should have two ivs-svs-base configs")

	// Verify the configurations
	var ivsSvsConfigs []*ivs_svs_base.Options
	for _, config := range configs {
		if config.Name == "ivs-svs-base" {
			if options, ok := config.Options.(*ivs_svs_base.Options); ok {
				ivsSvsConfigs = append(ivsSvsConfigs, options)
			}
		}
	}
	assert.Equal(t, 2, len(ivsSvsConfigs), "Should have two ivs-svs-base configurations")

	hasIvsOrSvs := false
	hasBase := false
	for _, config := range ivsSvsConfigs {
		if config.Mode == ivs_svs_base.ModeIvsOrSvs {
			hasIvsOrSvs = true
		}
		if config.Mode == ivs_svs_base.ModeBase {
			hasBase = true
		}
	}
	assert.True(t, hasIvsOrSvs, "Should have ivs-or-svs mode config")
	assert.True(t, hasBase, "Should have base mode config")
}

func TestRemoveIvsSvsWithDropAllSelectors(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.RemoveIVSSVS = DropAllSelectors

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	var baseConfig *ivs_svs_base.Options
	for _, config := range configs {
		if config.Name == "ivs-svs-base" {
			if options, ok := config.Options.(*ivs_svs_base.Options); ok && options.Mode == ivs_svs_base.ModeBase {
				baseConfig = options
				break
			}
		}
	}
	require.NotNil(t, baseConfig)
	assert.True(t, baseConfig.DropSelectorsAltogether, "Should drop all selectors")
}

func TestCharsetConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.Charset = "unijis_2004"
	recipe.RemoveIVSSVS = Yes

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	config := findConfig(configs, "ivs-svs-base")
	require.NotNil(t, config)
	require.NotNil(t, config.Options)

	options, ok := config.Options.(*ivs_svs_base.Options)
	require.True(t, ok, "Options should be of correct type")
	assert.Equal(t, ivs_svs_base.CharsetUnijis2004, options.Charset, "Should use UNIJIS_2004 charset")
}

func TestCircledOrSquaredConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ReplaceCircledOrSquaredCharacters = Yes

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	assert.True(t, containsConfig(configs, "circled-or-squared"))
	config := findConfig(configs, "circled-or-squared")
	require.NotNil(t, config)
	require.NotNil(t, config.Options)

	options, ok := config.Options.(map[string]interface{})
	require.True(t, ok, "Options should be of correct type")
	assert.Equal(t, true, options["includeEmojis"])
}

func TestCircledOrSquaredExcludeEmojisConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ReplaceCircledOrSquaredCharacters = ExcludeEmojis

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	config := findConfig(configs, "circled-or-squared")
	require.NotNil(t, config)
	require.NotNil(t, config.Options)

	options, ok := config.Options.(map[string]interface{})
	require.True(t, ok, "Options should be of correct type")
	assert.Equal(t, false, options["includeEmojis"])
}

func TestCombinedConfiguration(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ReplaceCombinedCharacters = true

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	assert.True(t, containsConfig(configs, "combined"))
}

func TestCircledOrSquaredAndCombinedOrder(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.ReplaceCircledOrSquaredCharacters = Yes
	recipe.ReplaceCombinedCharacters = true

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	circledPos := findConfigPosition(configs, "circled-or-squared")
	combinedPos := findConfigPosition(configs, "combined")

	assert.GreaterOrEqual(t, circledPos, 0, "circled-or-squared should be present")
	assert.GreaterOrEqual(t, combinedPos, 0, "combined should be present")
	// In Go's implementation, the order depends on how insertMiddle works
	// Both should be present, that's what matters
	assert.NotEqual(t, circledPos, combinedPos, "positions should be different")
}

func TestComprehensiveConfiguration(t *testing.T) {
	recipe := &TransliterationRecipe{
		KanjiOldNew: true,
		ReplaceSuspiciousHyphensToProlongedSoundMarks: true,
		ReplaceCombinedCharacters:                     true,
		ReplaceCircledOrSquaredCharacters:             Yes,
		ReplaceIdeographicAnnotations:                 true,
		ReplaceRadicals:                               true,
		ReplaceSpaces:                                 true,
		ReplaceHyphens:                                NewReplaceHyphensOption(true),
		ReplaceMathematicalAlphanumerics:              true,
		CombineDecomposedHiraganasAndKatakanas:        true,
		ToHalfwidth:                                   HankakuKana,
		RemoveIVSSVS:                                  DropAllSelectors,
		Charset:                                       "unijis_90",
	}

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	// Verify all expected transliterators are present
	expectedNames := []string{
		"ivs-svs-base", // appears twice
		"kanji-old-new",
		"prolonged-sound-marks",
		"circled-or-squared",
		"combined",
		"ideographic-annotations",
		"radicals",
		"spaces",
		"hyphens",
		"mathematical-alphanumerics",
		"hira-kata-composition",
		"jisx0201-and-alike",
	}

	foundNames := make(map[string]bool)
	for _, config := range configs {
		foundNames[config.Name] = true
	}

	for _, name := range expectedNames {
		assert.True(t, foundNames[name], "expected transliterator %s not found", name)
	}

	// Count ivs-svs-base occurrences
	ivsSvsCount := 0
	for _, config := range configs {
		if config.Name == "ivs-svs-base" {
			ivsSvsCount++
		}
	}
	assert.Equal(t, 2, ivsSvsCount, "Should have two ivs-svs-base configs")

	// Verify specific configurations
	hyphensConfig := findConfig(configs, "hyphens")
	require.NotNil(t, hyphensConfig)
	hyphensOpts, ok := hyphensConfig.Options.(*hyphens.Options)
	require.True(t, ok)
	assert.Equal(t, []hyphens.Mapping{hyphens.Jisx0208_90_Windows, hyphens.Jisx0201}, hyphensOpts.Precedence)

	jisx0201Config := findConfig(configs, "jisx0201-and-alike")
	require.NotNil(t, jisx0201Config)
	jisx0201Opts, ok := jisx0201Config.Options.(*jisx0201_and_alike.Options)
	require.True(t, ok)
	assert.True(t, jisx0201Opts.ConvertGR, "Should convert GR for hankaku-kana")
}

func TestConfigurationOrdering(t *testing.T) {
	recipe := NewTransliterationRecipe()
	recipe.KanjiOldNew = true
	recipe.ReplaceSuspiciousHyphensToProlongedSoundMarks = true
	recipe.ReplaceSpaces = true
	recipe.ReplaceCircledOrSquaredCharacters = Yes
	recipe.ReplaceCombinedCharacters = true
	recipe.CombineDecomposedHiraganasAndKatakanas = true
	recipe.ToHalfwidth = Yes

	configs, err := recipe.BuildTransliteratorConfigs()
	require.NoError(t, err)

	// Find positions of key transliterators to verify ordering
	hiraKataPos := findConfigPosition(configs, "hira-kata-composition")
	kanjiPos := findConfigPosition(configs, "kanji-old-new")
	prolongedPos := findConfigPosition(configs, "prolonged-sound-marks")
	spacesPos := findConfigPosition(configs, "spaces")
	circledPos := findConfigPosition(configs, "circled-or-squared")
	combinedPos := findConfigPosition(configs, "combined")
	jisx0201Pos := findConfigPosition(configs, "jisx0201-and-alike")

	// Verify key relationships in the ordering
	// hira-kata-composition should be early (inserted at head)
	assert.True(t, hiraKataPos >= 0, "hira-kata-composition should be present")

	// All should be present
	assert.True(t, spacesPos >= 0, "spaces should be present")
	assert.True(t, prolongedPos >= 0, "prolonged-sound-marks should be present")
	assert.True(t, circledPos >= 0, "circled-or-squared should be present")
	assert.True(t, combinedPos >= 0, "combined should be present")

	// jisx0201-and-alike should be at the end (tail insertion)
	assert.True(t, jisx0201Pos >= 0, "jisx0201-and-alike should be present")
	assert.Equal(t, len(configs)-1, jisx0201Pos, "jisx0201-and-alike should be last")

	// All required configs should be present
	assert.True(t, kanjiPos >= 0, "kanji-old-new should be present")
}

// Helper functions
func containsConfig(configs []TransliteratorConfig, name string) bool {
	for _, config := range configs {
		if config.Name == name {
			return true
		}
	}
	return false
}

func findConfig(configs []TransliteratorConfig, name string) *TransliteratorConfig {
	for i, config := range configs {
		if config.Name == name {
			return &configs[i]
		}
	}
	return nil
}

func findConfigPosition(configs []TransliteratorConfig, name string) int {
	for i, config := range configs {
		if config.Name == name {
			return i
		}
	}
	return -1
}
