package recipe

import (
	"errors"
	"strings"

	"github.com/yosina-lib/yosina/go/transliterators/hira_kata_composition"
	"github.com/yosina-lib/yosina/go/transliterators/hyphens"
	"github.com/yosina-lib/yosina/go/transliterators/ivs_svs_base"
	"github.com/yosina-lib/yosina/go/transliterators/jisx0201_and_alike"
	"github.com/yosina-lib/yosina/go/transliterators/prolonged_sound_marks"
)

// TransliteratorConfig represents a configuration for a transliterator
type TransliteratorConfig struct {
	Name    string
	Options interface{} // Will hold specific option structs for each transliterator
}

// TransliteratorRecipeOptionValue is an enum for transliterator recipe options
type TransliteratorRecipeOptionValue int

const (
	No TransliteratorRecipeOptionValue = iota
	Yes
	U005cAsYenSign
	HankakuKana
	DropAllSelectors
	ExcludeEmojis
)

// ReplaceHyphensOption represents hyphen replacement options
type ReplaceHyphensOption struct {
	Enabled    bool
	Precedence []string
}

// NewReplaceHyphensOption creates a ReplaceHyphensOption with default precedence
func NewReplaceHyphensOption(enabled bool) ReplaceHyphensOption {
	if !enabled {
		return ReplaceHyphensOption{Enabled: false}
	}
	return ReplaceHyphensOption{
		Enabled:    true,
		Precedence: []string{"jisx0208_90_windows", "jisx0201"},
	}
}

// TransliteratorRecipe provides a high-level interface for configuring transliterators
type TransliteratorRecipe struct {
	// KanjiOldNew replaces old-style kanji glyphs (旧字体) with modern equivalents (新字体)
	// Example:
	//   Input:  "舊字體の變換"
	//   Output: "旧字体の変換"
	KanjiOldNew bool

	// ReplaceSuspiciousHyphensToProlongedSoundMarks replaces "suspicious" hyphens with prolonged sound marks
	// Example:
	//   Input:  "スーパ-" (with hyphen-minus)
	//   Output: "スーパー" (becomes prolonged sound mark)
	ReplaceSuspiciousHyphensToProlongedSoundMarks bool

	// ReplaceCombinedCharacters replaces combined characters with their corresponding characters
	// Example:
	//   Input:  "㍻" (single character for Heisei era)
	//   Output: "平成"
	//   Input:  "㈱"
	//   Output: "(株)"
	ReplaceCombinedCharacters bool

	// ReplaceCircledOrSquaredCharacters replaces circled or squared characters with templates
	// Example:
	//   Input:  "①②③"
	//   Output: "(1)(2)(3)"
	//   Input:  "㊙㊗"
	//   Output: "(秘)(祝)"
	ReplaceCircledOrSquaredCharacters TransliteratorRecipeOptionValue

	// ReplaceIdeographicAnnotations replaces ideographic annotations used in traditional Chinese-to-Japanese translation
	// Example:
	//   Input:  "㆖㆘" (ideographic annotations)
	//   Output: "上下"
	ReplaceIdeographicAnnotations bool

	// ReplaceRadicals replaces Kangxi radicals with CJK ideograph counterparts
	// Example:
	//   Input:  "⾔⾨⾷" (Kangxi radicals)
	//   Output: "言門食" (CJK ideographs)
	ReplaceRadicals bool

	// ReplaceSpaces replaces various space characters with plain whitespaces
	// Example:
	//   Input:  "A　B" (ideographic space U+3000)
	//   Output: "A B" (half-width space)
	//   Input:  "A B" (non-breaking space U+00A0)
	//   Output: "A B" (regular space)
	ReplaceSpaces bool

	// ReplaceHyphens replaces various dash or hyphen symbols
	// Example:
	//   Input:  "2019—2020" (em dash)
	//   Output: "2019-2020" (hyphen-minus)
	//   Input:  "A–B" (en dash)
	//   Output: "A-B"
	ReplaceHyphens ReplaceHyphensOption

	// ReplaceMathematicalAlphanumerics replaces mathematical alphanumerics with ASCII equivalents
	// Example:
	//   Input:  "𝐀𝐁𝐂" (mathematical bold)
	//   Output: "ABC"
	//   Input:  "𝟏𝟐𝟑" (mathematical bold digits)
	//   Output: "123"
	ReplaceMathematicalAlphanumerics bool

	// CombineDecomposedHiraganasAndKatakanas combines decomposed hiraganas and katakanas
	// Example:
	//   Input:  "が" (か + ゙)
	//   Output: "が" (single character)
	//   Input:  "ペ" (ヘ + ゚)
	//   Output: "ペ" (single character)
	CombineDecomposedHiraganasAndKatakanas bool

	// ToFullwidth replaces half-width characters with fullwidth equivalents
	// Can be bool or "u005c-as-yen-sign"
	// Example:
	//   Input:  "ABC123"
	//   Output: "ＡＢＣ１２３"
	//   Input:  "ｶﾀｶﾅ"
	//   Output: "カタカナ"
	ToFullwidth TransliteratorRecipeOptionValue

	// ToHalfwidth replaces full-width characters with half-width equivalents
	// Can be bool or "hankaku-kana"
	// Example:
	//   Input:  "ＡＢＣ１２３"
	//   Output: "ABC123"
	//   Input:  "カタカナ" (with hankaku-kana)
	//   Output: "ｶﾀｶﾅ"
	ToHalfwidth TransliteratorRecipeOptionValue

	// RemoveIVSSVS replaces CJK ideographs with IVS/SVS with those without selectors
	// Can be bool or "drop-all-selectors"
	// Example:
	//   Input:  "葛󠄀" (葛 + IVS U+E0100)
	//   Output: "葛" (without selector)
	//   Input:  "辻󠄀" (辻 + IVS)
	//   Output: "辻"
	RemoveIVSSVS TransliteratorRecipeOptionValue

	// Charset for IVS/SVS transliteration (default: "unijis_2004")
	Charset string
}

// NewTransliteratorRecipe creates a new TransliteratorRecipe with default values
func NewTransliteratorRecipe() *TransliteratorRecipe {
	return &TransliteratorRecipe{
		Charset: "unijis_2004",
	}
}

// transliteratorConfigListBuilder helps build the transliterator configuration list
type transliteratorConfigListBuilder struct {
	head []TransliteratorConfig
	tail []TransliteratorConfig
}

// insertHead inserts a config at the head of the chain
func (b *transliteratorConfigListBuilder) insertHead(config TransliteratorConfig, forceReplace bool) {
	for i, c := range b.head {
		if c.Name == config.Name {
			if forceReplace {
				b.head[i] = config
			}
			return
		}
	}
	b.head = append([]TransliteratorConfig{config}, b.head...)
}

// insertMiddle inserts a config in the middle (tail list, at beginning)
func (b *transliteratorConfigListBuilder) insertMiddle(config TransliteratorConfig, forceReplace bool) {
	for i, c := range b.tail {
		if c.Name == config.Name {
			if forceReplace {
				b.tail[i] = config
			}
			return
		}
	}
	b.tail = append([]TransliteratorConfig{config}, b.tail...)
}

// insertTail inserts a config at the tail of the chain
func (b *transliteratorConfigListBuilder) insertTail(config TransliteratorConfig, forceReplace bool) {
	for i, c := range b.tail {
		if c.Name == config.Name {
			if forceReplace {
				b.tail[i] = config
			}
			return
		}
	}
	b.tail = append(b.tail, config)
}

// build returns the final configuration list
func (b *transliteratorConfigListBuilder) build() []TransliteratorConfig {
	result := make([]TransliteratorConfig, 0, len(b.head)+len(b.tail))
	result = append(result, b.head...)
	result = append(result, b.tail...)
	return result
}

// removeIVSSVSHelper adds IVS/SVS removal configurations
func (r *TransliteratorRecipe) removeIVSSVSHelper(ctx *transliteratorConfigListBuilder, dropAllSelectors bool) {
	// Parse charset
	var charset ivs_svs_base.Charset
	switch r.Charset {
	case "unijis_90":
		charset = ivs_svs_base.CharsetUnijis90
	default:
		charset = ivs_svs_base.CharsetUnijis2004
	}

	// First insert IVS-or-SVS mode at head
	ctx.insertHead(TransliteratorConfig{
		Name: "ivs-svs-base",
		Options: &ivs_svs_base.Options{
			Mode:    ivs_svs_base.ModeIvsOrSvs,
			Charset: charset,
		},
	}, true)

	// Then insert base mode at tail
	ctx.insertTail(TransliteratorConfig{
		Name: "ivs-svs-base",
		Options: &ivs_svs_base.Options{
			Mode:                    ivs_svs_base.ModeBase,
			DropSelectorsAltogether: dropAllSelectors,
			Charset:                 charset,
		},
	}, true)
}

// BuildTransliteratorConfigs builds transliterator configurations from this recipe
func (r *TransliteratorRecipe) BuildTransliteratorConfigs() ([]TransliteratorConfig, error) {
	// Check for mutually exclusive options
	var errorList []string
	if (r.ToFullwidth == Yes || r.ToFullwidth == U005cAsYenSign) &&
		(r.ToHalfwidth == Yes || r.ToHalfwidth == HankakuKana) {
		errorList = append(errorList, "toFullwidth and toHalfwidth are mutually exclusive")
	}

	if len(errorList) > 0 {
		return nil, errors.New(strings.Join(errorList, "; "))
	}

	ctx := &transliteratorConfigListBuilder{}

	// Apply transformations in the specified order
	r.applyKanjiOldNew(ctx)
	r.applyReplaceSuspiciousHyphensToProlongedSoundMarks(ctx)
	r.applyReplaceCircledOrSquaredCharacters(ctx)
	r.applyReplaceCombinedCharacters(ctx)
	r.applyReplaceIdeographicAnnotations(ctx)
	r.applyReplaceRadicals(ctx)
	r.applyReplaceSpaces(ctx)
	r.applyReplaceHyphens(ctx)
	r.applyReplaceMathematicalAlphanumerics(ctx)
	r.applyCombineDecomposedHiraganasAndKatakanas(ctx)
	r.applyToFullwidth(ctx)
	r.applyToHalfwidth(ctx)
	r.applyRemoveIVSSVS(ctx)

	return ctx.build(), nil
}

func (r *TransliteratorRecipe) applyKanjiOldNew(ctx *transliteratorConfigListBuilder) {
	if r.KanjiOldNew {
		r.removeIVSSVSHelper(ctx, false)
		ctx.insertMiddle(TransliteratorConfig{Name: "kanji-old-new"}, false)
	}
}

func (r *TransliteratorRecipe) applyReplaceSuspiciousHyphensToProlongedSoundMarks(ctx *transliteratorConfigListBuilder) {
	if r.ReplaceSuspiciousHyphensToProlongedSoundMarks {
		ctx.insertMiddle(TransliteratorConfig{
			Name: "prolonged-sound-marks",
			Options: &prolonged_sound_marks.Options{
				ReplaceProlongedMarksFollowingAlnums: true,
			},
		}, false)
	}
}

func (r *TransliteratorRecipe) applyReplaceCombinedCharacters(ctx *transliteratorConfigListBuilder) {
	if r.ReplaceCombinedCharacters {
		ctx.insertMiddle(TransliteratorConfig{Name: "combined"}, false)
	}
}

func (r *TransliteratorRecipe) applyReplaceCircledOrSquaredCharacters(ctx *transliteratorConfigListBuilder) {
	if r.ReplaceCircledOrSquaredCharacters == Yes || r.ReplaceCircledOrSquaredCharacters == ExcludeEmojis {
		includeEmojis := r.ReplaceCircledOrSquaredCharacters != ExcludeEmojis
		ctx.insertMiddle(TransliteratorConfig{
			Name: "circled-or-squared",
			Options: map[string]interface{}{
				"includeEmojis": includeEmojis,
			},
		}, false)
	}
}

func (r *TransliteratorRecipe) applyReplaceIdeographicAnnotations(ctx *transliteratorConfigListBuilder) {
	if r.ReplaceIdeographicAnnotations {
		ctx.insertMiddle(TransliteratorConfig{Name: "ideographic-annotations"}, false)
	}
}

func (r *TransliteratorRecipe) applyReplaceRadicals(ctx *transliteratorConfigListBuilder) {
	if r.ReplaceRadicals {
		ctx.insertMiddle(TransliteratorConfig{Name: "radicals"}, false)
	}
}

func (r *TransliteratorRecipe) applyReplaceSpaces(ctx *transliteratorConfigListBuilder) {
	if r.ReplaceSpaces {
		ctx.insertMiddle(TransliteratorConfig{Name: "spaces"}, false)
	}
}

func (r *TransliteratorRecipe) applyReplaceHyphens(ctx *transliteratorConfigListBuilder) {
	if r.ReplaceHyphens.Enabled {
		// Convert string precedence to Mapping enum values
		var precedence []hyphens.Mapping
		for _, p := range r.ReplaceHyphens.Precedence {
			switch p {
			case "ascii":
				precedence = append(precedence, hyphens.ASCII)
			case "jisx0201":
				precedence = append(precedence, hyphens.Jisx0201)
			case "jisx0208_90":
				precedence = append(precedence, hyphens.Jisx0208_90)
			case "jisx0208_90_windows":
				precedence = append(precedence, hyphens.Jisx0208_90_Windows)
			case "jisx0208_verbatim":
				precedence = append(precedence, hyphens.Jisx0208_Verbatim)
			}
		}

		ctx.insertMiddle(TransliteratorConfig{
			Name: "hyphens",
			Options: &hyphens.Options{
				Precedence: precedence,
			},
		}, false)
	}
}

func (r *TransliteratorRecipe) applyReplaceMathematicalAlphanumerics(ctx *transliteratorConfigListBuilder) {
	if r.ReplaceMathematicalAlphanumerics {
		ctx.insertMiddle(TransliteratorConfig{Name: "mathematical-alphanumerics"}, false)
	}
}

func (r *TransliteratorRecipe) applyCombineDecomposedHiraganasAndKatakanas(ctx *transliteratorConfigListBuilder) {
	if r.CombineDecomposedHiraganasAndKatakanas {
		ctx.insertHead(TransliteratorConfig{
			Name: "hira-kata-composition",
			Options: &hira_kata_composition.Options{
				ComposeNonCombiningMarks: true,
			},
		}, false)
	}
}

func (r *TransliteratorRecipe) applyToFullwidth(ctx *transliteratorConfigListBuilder) {
	if r.ToFullwidth == Yes || r.ToFullwidth == U005cAsYenSign {
		u005cAsYenSign := r.ToFullwidth == U005cAsYenSign
		ctx.insertTail(TransliteratorConfig{
			Name: "jisx0201-and-alike",
			Options: &jisx0201_and_alike.Options{
				FullwidthToHalfwidth: false,
				U005cAsYenSign:       u005cAsYenSign,
			},
		}, false)
	}
}

func (r *TransliteratorRecipe) applyToHalfwidth(ctx *transliteratorConfigListBuilder) {
	if r.ToHalfwidth == Yes || r.ToHalfwidth == HankakuKana {
		convertGR := r.ToHalfwidth == HankakuKana
		ctx.insertTail(TransliteratorConfig{
			Name: "jisx0201-and-alike",
			Options: &jisx0201_and_alike.Options{
				FullwidthToHalfwidth: true,
				ConvertGL:            true,
				ConvertGR:            convertGR,
			},
		}, false)
	}
}

func (r *TransliteratorRecipe) applyRemoveIVSSVS(ctx *transliteratorConfigListBuilder) {
	if r.RemoveIVSSVS == Yes || r.RemoveIVSSVS == DropAllSelectors {
		dropAllSelectors := r.RemoveIVSSVS == DropAllSelectors
		r.removeIVSSVSHelper(ctx, dropAllSelectors)
	}
}
