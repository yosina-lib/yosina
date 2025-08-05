// Advanced usage example for Yosina Go library.
// This example demonstrates low-level transliterator usage and composition.

package main

import (
	"fmt"
	"strings"

	yosina "github.com/yosina-lib/yosina/go"
	"github.com/yosina-lib/yosina/go/recipe"
	"github.com/yosina-lib/yosina/go/transliterators/combined"
	"github.com/yosina-lib/yosina/go/transliterators/kanji_old_new"
	"github.com/yosina-lib/yosina/go/transliterators/spaces"
)

// Helper function to apply a transliterator function to a string
func applyTransliterator(input string, transliteratorFunc func(yosina.CharIterator) yosina.CharIterator) string {
	chars := yosina.BuildCharArray(input)
	iter := transliteratorFunc(yosina.NewCharIteratorFromSlice(chars))
	return yosina.StringFromChars(iter)
}

// Helper function to collect CharIterator into slice
func collectChars(iter yosina.CharIterator) []*yosina.Char {
	var result []*yosina.Char
	for {
		c := iter.Next()
		if c == nil {
			break
		}
		result = append(result, c)
	}
	return result
}

func main() {
	fmt.Println("=== Advanced Yosina Go Usage Examples ===\n")

	// 1. Working with CharIterator directly
	fmt.Println("1. Low-level CharIterator Usage")
	input := "hello　world"
	chars := yosina.BuildCharArray(input)

	fmt.Printf("Input: '%s'\n", input)
	fmt.Println("Character analysis:")
	for i, char := range chars {
		if !char.IsSentinel() {
			fmt.Printf("  [%d] Rune: U+%04X '%c', Offset: %d\n",
				i, char.C[0], char.C[0], char.Offset)
			if char.C[1] != yosina.InvalidUnicodeValue {
				fmt.Printf("      Second rune: U+%04X '%c'\n", char.C[1], char.C[1])
			}
		}
	}
	fmt.Println()

	// 2. Building a custom transliterator chain
	fmt.Println("2. Custom Transliterator Chain")

	// Create a chain that applies multiple transformations
	chainedTransform := func(input string) string {
		// Convert to char array
		chars := yosina.BuildCharArray(input)

		// Apply spaces transformation
		iter1 := spaces.Transliterate(yosina.NewCharIteratorFromSlice(chars))
		chars1 := collectChars(iter1)

		// Apply kanji old-new transformation
		iter2 := kanji_old_new.Transliterate(yosina.NewCharIteratorFromSlice(chars1))
		chars2 := collectChars(iter2)

		// Apply combined transformation
		iter3 := combined.Transliterate(yosina.NewCharIteratorFromSlice(chars2))

		// Convert back to string
		return yosina.StringFromChars(iter3)
	}

	testInput := "廣島　檜原村　㍿会社"
	fmt.Printf("Input:  '%s'\n", testInput)
	fmt.Printf("Output: '%s'\n", chainedTransform(testInput))
	fmt.Println()

	// 3. Analyzing transformation steps
	fmt.Println("3. Step-by-Step Transformation Analysis")

	input3 := "舊字體　㍿㍑"
	fmt.Printf("Original: '%s'\n", input3)

	// Step 1: Spaces
	step1 := applyTransliterator(input3, spaces.Transliterate)
	fmt.Printf("After spaces: '%s'\n", step1)

	// Step 2: Kanji old-new
	chars2 := yosina.BuildCharArray(step1)
	step2 := yosina.StringFromChars(kanji_old_new.Transliterate(yosina.NewCharIteratorFromSlice(chars2)))
	fmt.Printf("After kanji-old-new: '%s'\n", step2)

	// Step 3: Combined
	chars3 := yosina.BuildCharArray(step2)
	step3 := yosina.StringFromChars(combined.Transliterate(yosina.NewCharIteratorFromSlice(chars3)))
	fmt.Printf("After combined: '%s'\n", step3)
	fmt.Println()

	// 4. Performance considerations
	fmt.Println("4. Performance Considerations")

	// Show how recipe configurations can be reused
	r := recipe.NewTransliterationRecipe()
	r.ReplaceSpaces = true
	r.KanjiOldNew = true
	r.ReplaceCombinedCharacters = true

	configs, _ := r.BuildTransliteratorConfigs()
	fmt.Printf("Recipe generates %d configurations that can be cached\n", len(configs))

	// Simulate processing multiple texts with the same configuration
	texts := []string{
		"これは　テストです",
		"檜原村は　美しい",
		"㍿東京　会社",
	}

	fmt.Println("\nProcessing multiple texts:")
	for i, text := range texts {
		// In a real application, you would cache and reuse transliterators
		result := chainedTransform(text)
		fmt.Printf("  %d: '%s' → '%s'\n", i+1, text, result)
	}
	fmt.Println()

	// 5. Working with IVS (Ideographic Variation Sequences)
	fmt.Println("5. IVS/SVS Handling")

	// Example with variation selectors
	ivsText := "葛\U000E0100飾区" // 葛 with IVS
	ivsChars := yosina.BuildCharArray(ivsText)

	fmt.Printf("Input with IVS: '%s'\n", ivsText)
	fmt.Println("Character breakdown:")
	for i, char := range ivsChars {
		if !char.IsSentinel() {
			var desc string
			if char.C[1] != yosina.InvalidUnicodeValue && char.C[1] >= 0xE0100 && char.C[1] <= 0xE01EF {
				desc = fmt.Sprintf("Base: U+%04X, VS: U+%06X", char.C[0], char.C[1])
			} else {
				desc = fmt.Sprintf("U+%04X", char.C[0])
			}
			fmt.Printf("  [%d] %s\n", i, desc)
		}
	}
	fmt.Println()

	// 6. Unicode edge cases
	fmt.Println("6. Unicode Edge Cases")

	edgeCases := []struct {
		name  string
		input string
	}{
		{"Mixed scripts", "Hello世界мир🌍"},
		{"Emoji with ZWJ", "👨‍👩‍👧‍👦"},
		{"Mathematical symbols", "∑∏∫∂"},
		{"Combining marks", "が゙ぱ゜"},
		{"Surrogates", "𝐀𝐁𝐂"},
	}

	for _, tc := range edgeCases {
		chars := yosina.BuildCharArray(tc.input)
		nonSentinel := 0
		for _, c := range chars {
			if !c.IsSentinel() {
				nonSentinel++
			}
		}
		fmt.Printf("%s: '%s' → %d characters\n", tc.name, tc.input, nonSentinel)
	}

	fmt.Println("\n=== Advanced Examples Complete ===")
}

// Additional helper functions that could be useful in a real application

// ChainTransliterators creates a function that applies multiple transliterators in sequence
func ChainTransliterators(transliterators ...func(yosina.CharIterator) yosina.CharIterator) func(string) string {
	return func(input string) string {
		chars := yosina.BuildCharArray(input)
		iter := yosina.CharIterator(yosina.NewCharIteratorFromSlice(chars))

		for _, t := range transliterators {
			collected := collectChars(t(iter))
			iter = yosina.NewCharIteratorFromSlice(collected)
		}

		return yosina.StringFromChars(iter)
	}
}

// AnalyzeString provides detailed information about a string's characters
func AnalyzeString(s string) {
	fmt.Printf("String: '%s'\n", s)
	fmt.Printf("Byte length: %d\n", len(s))
	fmt.Printf("Rune count: %d\n", len([]rune(s)))

	chars := yosina.BuildCharArray(s)
	charCount := 0
	for _, c := range chars {
		if !c.IsSentinel() {
			charCount++
		}
	}
	fmt.Printf("Yosina character count: %d\n", charCount)

	var details []string
	for _, c := range chars {
		if !c.IsSentinel() {
			if c.C[1] != yosina.InvalidUnicodeValue {
				details = append(details, fmt.Sprintf("U+%04X+U+%04X", c.C[0], c.C[1]))
			} else {
				details = append(details, fmt.Sprintf("U+%04X", c.C[0]))
			}
		}
	}
	fmt.Printf("Characters: %s\n", strings.Join(details, " "))
}
