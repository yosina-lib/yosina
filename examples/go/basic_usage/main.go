// Basic usage example for Yosina Go library.
// This example demonstrates the fundamental transliteration functionality
// as shown in the README documentation.

package main

import (
	"fmt"
	"log"

	"github.com/yosina-lib/yosina/go/recipe"
)

func main() {
	fmt.Println("=== Yosina Go Basic Usage Example ===\n")

	// Create a recipe with desired transformations (matching README example)
	r := recipe.NewTransliteratorRecipe()
	r.KanjiOldNew = true
	r.ReplaceSpaces = true
	r.ReplaceSuspiciousHyphensToProlongedSoundMarks = true
	r.ReplaceCircledOrSquaredCharacters = recipe.Yes
	r.ReplaceCombinedCharacters = true
	r.ToFullwidth = recipe.Yes
	
	// Create the transliterator
	transliterator, err := recipe.MakeTransliterator(r)
	if err != nil {
		log.Fatal(err)
	}
	
	// Use it with various special characters (matching README example)
	input := "①②③　ⒶⒷⒸ　㍿㍑㌠㋿" // circled numbers, letters, space, combined characters
	result := transliterator(input)
	
	fmt.Printf("Input:  %s\n", input)
	fmt.Printf("Output: %s\n", result)
	fmt.Println("Expected: （１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和")
	
	// Convert old kanji to new
	fmt.Println("\n--- Old Kanji to New ---")
	oldKanji := "舊字體"
	result = transliterator(oldKanji)
	fmt.Printf("Input:  %s\n", oldKanji)
	fmt.Printf("Output: %s\n", result)
	fmt.Println("Expected: 旧字体")
	
	// Convert half-width katakana to full-width
	fmt.Println("\n--- Half-width to Full-width ---")
	halfWidth := "ﾃｽﾄﾓｼﾞﾚﾂ"
	result = transliterator(halfWidth)
	fmt.Printf("Input:  %s\n", halfWidth)
	fmt.Printf("Output: %s\n", result)
	fmt.Println("Expected: テストモジレツ")
}