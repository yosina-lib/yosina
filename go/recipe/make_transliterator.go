package recipe

import (
	"fmt"

	yosina "github.com/yosina-lib/yosina/go"
	"github.com/yosina-lib/yosina/go/transliterators/circled_or_squared"
	"github.com/yosina-lib/yosina/go/transliterators/combined"
	"github.com/yosina-lib/yosina/go/transliterators/hira_kata_composition"
	"github.com/yosina-lib/yosina/go/transliterators/hyphens"
	"github.com/yosina-lib/yosina/go/transliterators/ideographic_annotations"
	"github.com/yosina-lib/yosina/go/transliterators/ivs_svs_base"
	"github.com/yosina-lib/yosina/go/transliterators/japanese_iteration_marks"
	"github.com/yosina-lib/yosina/go/transliterators/jisx0201_and_alike"
	"github.com/yosina-lib/yosina/go/transliterators/kanji_old_new"
	"github.com/yosina-lib/yosina/go/transliterators/mathematical_alphanumerics"
	"github.com/yosina-lib/yosina/go/transliterators/prolonged_sound_marks"
	"github.com/yosina-lib/yosina/go/transliterators/radicals"
	"github.com/yosina-lib/yosina/go/transliterators/spaces"
)

// MakeTransliterator creates a transliterator function from a recipe
func MakeTransliterator(r *TransliterationRecipe) (func(string) string, error) {
	configs, err := r.BuildTransliteratorConfigs()
	if err != nil {
		return nil, err
	}

	// Create transliterators from configs
	var transliterators []yosina.Transliterator
	for _, config := range configs {
		t, err := createTransliteratorFromConfig(config)
		if err != nil {
			return nil, err
		}
		transliterators = append(transliterators, t)
	}

	// If no transliterators, return identity function
	if len(transliterators) == 0 {
		return func(s string) string { return s }, nil
	}

	// Create chained transliterator
	chained := yosina.NewChainedTransliterator(transliterators)

	// Return a function that applies the transliterator chain
	return func(input string) string {
		chars := yosina.BuildCharArray(input)
		iter := yosina.NewCharIteratorFromSlice(chars)
		result, err := chained.Transliterate(iter)
		if err != nil {
			// In case of error, return original string
			return input
		}
		return yosina.StringFromChars(result)
	}, nil
}

// createTransliteratorFromConfig creates a transliterator from a config
func createTransliteratorFromConfig(config TransliteratorConfig) (yosina.Transliterator, error) {
	switch config.Name {
	case "spaces":
		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return spaces.Transliterate(input), nil
		}), nil

	case "kanji-old-new":
		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return kanji_old_new.Transliterate(input), nil
		}), nil

	case "combined":
		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return combined.Transliterate(input), nil
		}), nil

	case "circled-or-squared":
		options := circled_or_squared.Options{
			TemplateForCircled: "（?）",
			TemplateForSquared: "［?］",
			IncludeEmojis:      false,
		}

		// Check if options are provided
		if config.Options != nil {
			if opts, ok := config.Options.(map[string]interface{}); ok {
				if includeEmojis, ok := opts["includeEmojis"].(bool); ok {
					options.IncludeEmojis = includeEmojis
				}
			}
		}

		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return circled_or_squared.Transliterate(input, options), nil
		}), nil

	case "ideographic-annotations":
		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return ideographic_annotations.Transliterate(input), nil
		}), nil

	case "radicals":
		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return radicals.Transliterate(input), nil
		}), nil

	case "mathematical-alphanumerics":
		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return mathematical_alphanumerics.Transliterate(input), nil
		}), nil

	case "hyphens":
		var options hyphens.Options
		if config.Options != nil {
			if opts, ok := config.Options.(*hyphens.Options); ok {
				options = *opts
			}
		}
		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return hyphens.Transliterate(input, options), nil
		}), nil

	case "prolonged-sound-marks":
		var options prolonged_sound_marks.Options
		if config.Options != nil {
			if opts, ok := config.Options.(*prolonged_sound_marks.Options); ok {
				options = *opts
			}
		}
		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return prolonged_sound_marks.Transliterate(input, options), nil
		}), nil

	case "hira-kata-composition":
		var options hira_kata_composition.Options
		if config.Options != nil {
			if opts, ok := config.Options.(*hira_kata_composition.Options); ok {
				options = *opts
			}
		}
		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return hira_kata_composition.Transliterate(input, options), nil
		}), nil

	case "jisx0201-and-alike":
		var options jisx0201_and_alike.Options
		if config.Options != nil {
			if opts, ok := config.Options.(*jisx0201_and_alike.Options); ok {
				options = *opts
			}
		}
		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return jisx0201_and_alike.Transliterate(input, options), nil
		}), nil

	case "ivs-svs-base":
		var options ivs_svs_base.Options
		if config.Options != nil {
			if opts, ok := config.Options.(*ivs_svs_base.Options); ok {
				options = *opts
			}
		}
		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return ivs_svs_base.Transliterate(input, options), nil
		}), nil

	case "japanese-iteration-marks":
		var options japanese_iteration_marks.Options
		if config.Options != nil {
			if opts, ok := config.Options.(*japanese_iteration_marks.Options); ok {
				options = *opts
			}
		}
		return yosina.TransliteratorFunc(func(input yosina.CharIterator) (yosina.CharIterator, error) {
			return japanese_iteration_marks.Transliterate(input, options), nil
		}), nil

	default:
		return nil, fmt.Errorf("unknown transliterator: %s", config.Name)
	}
}
