// Configuration-based usage example for Yosina Go library.
// This example demonstrates using recipe configurations.

package main

import (
	"fmt"
	"log"

	"github.com/yosina-lib/yosina/go/recipe"
)

func main() {
	fmt.Println("=== Yosina Go Configuration-based Usage Example ===\n")

	// Create a recipe with desired transformations
	r := recipe.NewTransliterationRecipe()

	// Enable various transformations
	r.ReplaceSpaces = true
	r.KanjiOldNew = true
	r.ReplaceSuspiciousHyphensToProlongedSoundMarks = true
	r.ReplaceCircledOrSquaredCharacters = recipe.Yes
	r.ReplaceCombinedCharacters = true
	r.ToFullwidth = recipe.Yes

	// Build the configuration list
	configs, err := r.BuildTransliteratorConfigs()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("--- Generated Configurations ---")
	fmt.Printf("Total configurations: %d\n\n", len(configs))

	for i, config := range configs {
		fmt.Printf("%d. Name: %s\n", i+1, config.Name)
		if config.Options != nil {
			fmt.Printf("   Options: %T\n", config.Options)
		}
		fmt.Println()
	}

	// Create another recipe with different settings
	fmt.Println("--- Recipe for Half-width Conversion ---")
	r2 := recipe.NewTransliterationRecipe()
	r2.ToHalfwidth = recipe.HankakuKana
	r2.ReplaceSpaces = true

	configs2, err := r2.BuildTransliteratorConfigs()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Total configurations: %d\n", len(configs2))
	for i, config := range configs2 {
		fmt.Printf("%d. %s\n", i+1, config.Name)
	}

	// Demonstrate recipe validation
	fmt.Println("\n--- Recipe Validation ---")
	r3 := recipe.NewTransliterationRecipe()
	r3.ToFullwidth = recipe.Yes
	r3.ToHalfwidth = recipe.Yes // This should cause an error

	_, err = r3.BuildTransliteratorConfigs()
	if err != nil {
		fmt.Printf("Expected error: %v\n", err)
	}

	// Show how to use different options
	fmt.Println("\n--- Recipe Options ---")
	r4 := recipe.NewTransliterationRecipe()
	r4.ReplaceHyphens = recipe.NewReplaceHyphensOption(true)
	r4.RemoveIVSSVS = recipe.DropAllSelectors
	r4.Charset = "unijis_90"

	configs4, err := r4.BuildTransliteratorConfigs()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("Configurations with special options: %d\n", len(configs4))
	for _, config := range configs4 {
		fmt.Printf("- %s\n", config.Name)
	}
}
