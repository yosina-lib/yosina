// Basic usage example for Yosina Swift library.
// This example demonstrates the fundamental transliteration functionality
// as shown in the README documentation.

import Yosina

@main
struct BasicUsage {
    static func main() throws {
        print("=== Yosina Swift Basic Usage Example ===\n")

        // Create a recipe with desired transformations (matching README example)
        var recipe = TransliterationRecipe()
        recipe.kanjiOldNew = true
        recipe.replaceSpaces = true
        recipe.replaceSuspiciousHyphensToProlongedSoundMarks = true
        recipe.replaceCircledOrSquaredCharacters = .enabled
        recipe.replaceCombinedCharacters = true
        recipe.replaceJapaneseIterationMarks = true // Expand iteration marks
        recipe.toFullwidth = .enabled

        // Create the transliterator
        let transliterator = try recipe.makeTransliterator()

        // Use it with various special characters (matching README example)
        let input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿" // circled numbers, letters, space, combined characters
        let result = transliterator(input)

        print("Input:  \(input)")
        print("Output: \(result)")
        print("Expected: （１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和")

        // Convert old kanji to new
        print("\n--- Old Kanji to New ---")
        let oldKanji = "舊字體"
        let kanjiResult = transliterator(oldKanji)
        print("Input:  \(oldKanji)")
        print("Output: \(kanjiResult)")
        print("Expected: 旧字体")

        // Convert half-width katakana to full-width
        print("\n--- Half-width to Full-width ---")
        let halfWidth = "ﾃｽﾄﾓｼﾞﾚﾂ"
        let fullWidthResult = transliterator(halfWidth)
        print("Input:  \(halfWidth)")
        print("Output: \(fullWidthResult)")
        print("Expected: テストモジレツ")

        // Demonstrate Japanese iteration marks expansion
        print("\n--- Japanese Iteration Marks Examples ---")
        let iterationExamples = [
            "佐々木", // kanji iteration
            "すゝき", // hiragana iteration
            "いすゞ", // hiragana voiced iteration
            "サヽキ", // katakana iteration
            "ミスヾ", // katakana voiced iteration
        ]

        for text in iterationExamples {
            let result = transliterator(text)
            print("\(text) → \(result)")
        }

        // Demonstrate hiragana to katakana conversion separately
        print("\n--- Hiragana to Katakana Conversion ---")
        // Create a separate recipe for just hiragana to katakana conversion
        var hiraKataRecipe = TransliterationRecipe()
        hiraKataRecipe.hiraKata = .hiraToKata // Convert hiragana to katakana

        let hiraKataTransliterator = try hiraKataRecipe.makeTransliterator()

        let hiraKataExamples = [
            "ひらがな", // pure hiragana
            "これはひらがなです", // hiragana sentence
            "ひらがなとカタカナ", // mixed hiragana and katakana
        ]

        for text in hiraKataExamples {
            let result = hiraKataTransliterator.transliterate(text)
            print("\(text) → \(result)")
        }

        // Also demonstrate katakana to hiragana conversion
        print("\n--- Katakana to Hiragana Conversion ---")
        var kataHiraRecipe = TransliterationRecipe()
        kataHiraRecipe.hiraKata = .kataToHira // Convert katakana to hiragana

        let kataHiraTransliterator = try kataHiraRecipe.makeTransliterator()

        let kataHiraExamples = [
            "カタカナ", // pure katakana
            "コレハカタカナデス", // katakana sentence
            "カタカナとひらがな", // mixed katakana and hiragana
        ]

        for text in kataHiraExamples {
            let result = kataHiraTransliterator(text)
            print("\(text) → \(result)")
        }
    }
}
