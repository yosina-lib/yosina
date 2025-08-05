// Configuration-based usage example for Yosina Swift library.
// This example demonstrates using direct transliterator configurations.

import Yosina

@main
struct ConfigBasedUsage {
    static func main() {
        print("=== Yosina Swift Configuration-based Usage Example ===\n")

        // Create transliterator with direct configurations
        let configs: [TransliteratorConfig] = [
            .spaces,
            .prolongedSoundMarks,
            .jisx0201AndAlike(),
        ]

        let transliterator = configs.makeTransliterator()

        print("--- Configuration-based Transliteration ---")

        // Test cases demonstrating different transformations
        let testCases = [
            ("hello　world", "Space normalization"),
            ("カタカナーテスト", "Prolonged sound mark handling"),
            ("ＡＢＣ１２３", "Full-width conversion"),
            ("ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana conversion"),
        ]

        for (testText, description) in testCases {
            let result = transliterator(testText)
            print("\(description):")
            print("  Input:  '\(testText)'")
            print("  Output: '\(result)'")
            print()
        }

        // Demonstrate individual transliterators
        print("--- Individual Transliterator Examples ---")

        // Spaces only
        let spacesConfig: [TransliteratorConfig] = [.spaces]
        let spacesOnly = spacesConfig.makeTransliterator()
        let spaceTest = "hello　world　test" // ideographic spaces
        print("Spaces only: '\(spaceTest)' → '\(spacesOnly(spaceTest))'")

        // Kanji old-new only
        let kanjiConfig: [TransliteratorConfig] = [
            .ivsSvsBase(options: IvsSvsBaseTransliterator.Options(
                mode: .ivsOrSvs,
                charset: .unijis2004
            )),
            .kanjiOldNew,
            .ivsSvsBase(options: IvsSvsBaseTransliterator.Options(
                mode: .base,
                charset: .unijis2004
            )),
        ]
        let kanjiOnly = kanjiConfig.makeTransliterator()
        let kanjiTest = "廣島檜"
        print("Kanji only: '\(kanjiTest)' → '\(kanjiOnly(kanjiTest))'")

        // JIS X 0201 conversion only
        let jisx0201Config: [TransliteratorConfig] = [
            .jisx0201AndAlike(options: Jisx0201AndAlikeTransliterator.Options(
                fullwidthToHalfwidth: false
            )),
        ]
        let jisx0201Only = jisx0201Config.makeTransliterator()
        let jisxTest = "ﾊﾛｰ ﾜｰﾙﾄﾞ"
        print("JIS X 0201 only: '\(jisxTest)' → '\(jisx0201Only(jisxTest))'")
    }
}
