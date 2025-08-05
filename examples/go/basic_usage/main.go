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
	r := recipe.NewTransliterationRecipe()
	r.KanjiOldNew = true
	r.ReplaceSpaces = true
	r.ReplaceSuspiciousHyphensToProlongedSoundMarks = true
	r.ReplaceCircledOrSquaredCharacters = recipe.Yes
	r.ReplaceCombinedCharacters = true
	r.ReplaceJapaneseIterationMarks = true // Expand iteration marks
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

	// Demonstrate Japanese iteration marks expansion
	fmt.Println("\n--- Japanese Iteration Marks Examples ---")
	iterationExamples := []string{
		"佐々木", // kanji iteration
		"すゝき", // hiragana iteration
		"いすゞ", // hiragana voiced iteration
		"サヽキ", // katakana iteration
		"ミスヾ", // katakana voiced iteration
	}

	for _, text := range iterationExamples {
		result := transliterator(text)
		fmt.Printf("%s → %s\n", text, result)
	}

	// Demonstrate hiragana to katakana conversion separately
	fmt.Println("\n--- Hiragana to Katakana Conversion ---")
	// Create a separate recipe for just hiragana to katakana conversion
	hiraKataRecipe := recipe.NewTransliterationRecipe()
	hiraKataRecipe.HiraKata = "hira-to-kata" // Convert hiragana to katakana

	hiraKataTransliterator, err := recipe.MakeTransliterator(hiraKataRecipe)
	if err != nil {
		log.Fatal(err)
	}

	hiraKataExamples := []string{
		"ひらがな",      // pure hiragana
		"これはひらがなです", // hiragana sentence
		"ひらがなとカタカナ", // mixed hiragana and katakana
	}

	for _, text := range hiraKataExamples {
		result := hiraKataTransliterator(text)
		fmt.Printf("%s → %s\n", text, result)
	}

	// Also demonstrate katakana to hiragana conversion
	fmt.Println("\n--- Katakana to Hiragana Conversion ---")
	kataHiraRecipe := recipe.NewTransliterationRecipe()
	kataHiraRecipe.HiraKata = "kata-to-hira" // Convert katakana to hiragana

	kataHiraTransliterator, err := recipe.MakeTransliterator(kataHiraRecipe)
	if err != nil {
		log.Fatal(err)
	}

	kataHiraExamples := []string{
		"カタカナ",      // pure katakana
		"コレハカタカナデス", // katakana sentence
		"カタカナとひらがな", // mixed katakana and hiragana
	}

	for _, text := range kataHiraExamples {
		result := kataHiraTransliterator(text)
		fmt.Printf("%s → %s\n", text, result)
	}
}
