// Advanced usage examples for Yosina Swift library.
// This example demonstrates various real-world use cases and techniques.

import Yosina

@main
struct AdvancedUsage {
    static func main() throws {
        print("=== Advanced Yosina Swift Usage Examples ===\n")

        // 1. Web scraping text normalization
        do {
            print("1. Web Scraping Text Normalization")
            print("   (Typical use case: cleaning scraped Japanese web content)")

            var webScrapingRecipe = TransliterationRecipe()
            webScrapingRecipe.kanjiOldNew = true
            webScrapingRecipe.replaceSpaces = true
            webScrapingRecipe.replaceSuspiciousHyphensToProlongedSoundMarks = true
            webScrapingRecipe.replaceIdeographicAnnotations = true
            webScrapingRecipe.replaceRadicals = true
            webScrapingRecipe.combineDecomposedHiraganasAndKatakanas = true

            let normalizer = try webScrapingRecipe.makeTransliterator()

            // Simulate messy web content
            let messyContent = [
                ("これは　テスト です。", "Mixed spaces from different sources"),
                ("コンピューター-プログラム", "Suspicious hyphens in katakana"),
                ("古い漢字：廣島、檜、國", "Old-style kanji forms"),
                ("部首：⺅⻌⽊", "CJK radicals instead of regular kanji"),
            ]

            for (text, description) in messyContent {
                let cleaned = normalizer(text)
                print("  \(description):")
                print("    Before: '\(text)'")
                print("    After:  '\(cleaned)'")
                print()
            }
        }

        // 2. Document standardization
        do {
            print("2. Document Standardization")
            print("   (Use case: preparing documents for consistent formatting)")

            var documentRecipe = TransliterationRecipe()
            documentRecipe.toFullwidth = .enabled
            documentRecipe.replaceSpaces = true
            documentRecipe.kanjiOldNew = true
            documentRecipe.combineDecomposedHiraganasAndKatakanas = true

            let documentStandardizer = try documentRecipe.makeTransliterator()

            let documentSamples = [
                ("Hello World 123", "ASCII text to full-width"),
                ("カ゛", "Decomposed katakana with combining mark"),
                ("檜原村", "Old kanji in place names"),
            ]

            for (text, description) in documentSamples {
                let standardized = documentStandardizer(text)
                print("  \(description):")
                print("    Input:  '\(text)'")
                print("    Output: '\(standardized)'")
                print()
            }
        }

        // 3. Search index preparation
        do {
            print("3. Search Index Preparation")
            print("   (Use case: normalizing text for search engines)")

            var searchRecipe = TransliterationRecipe()
            searchRecipe.kanjiOldNew = true
            searchRecipe.replaceSpaces = true
            searchRecipe.toHalfwidth = .enabled
            searchRecipe.replaceSuspiciousHyphensToProlongedSoundMarks = true

            let searchNormalizer = try searchRecipe.makeTransliterator()

            let searchSamples = [
                ("東京スカイツリー", "Famous landmark name"),
                ("プログラミング言語", "Technical terms"),
                ("コンピューター-サイエンス", "Academic field with suspicious hyphen"),
            ]

            for (text, description) in searchSamples {
                let normalized = searchNormalizer(text)
                print("  \(description):")
                print("    Original:   '\(text)'")
                print("    Normalized: '\(normalized)'")
                print()
            }
        }

        // 4. Custom pipeline example
        do {
            print("4. Custom Processing Pipeline")
            print("   (Use case: step-by-step text transformation)")

            // Create multiple transliterators for pipeline processing
            let steps: [(String, [TransliteratorConfig])] = [
                ("Spaces", [.spaces]),
                ("Old Kanji", [
                    .ivsSvsBase(
                        options: IvsSvsBaseTransliterator.Options(
                            mode: .ivsOrSvs,
                            charset: .unijis2004
                        )
                    ),
                    .kanjiOldNew,
                    .ivsSvsBase(
                        options: IvsSvsBaseTransliterator.Options(
                            mode: .base,
                            charset: .unijis2004
                        )
                    ),
                ]),
                ("Width", [
                    .jisx0201AndAlike(
                        options: Jisx0201AndAlikeTransliterator.Options(
                            u005cAsYenSign: false
                        )
                    ),
                ]),
                ("ProlongedSoundMarks", [.prolongedSoundMarks]),
            ]

            var transliterators: [(String, (String) -> String)] = []
            for (name, config) in steps {
                let t = config.makeTransliterator().callAsFunction
                transliterators.append((name, t))
            }

            let pipelineText = "hello　world ﾃｽﾄ 檜-システム"
            var currentText = pipelineText

            print("  Starting text: '\(currentText)'")

            for (stepName, transliterator) in transliterators {
                let previousText = currentText
                currentText = transliterator(currentText)
                if previousText != currentText {
                    print("  After \(stepName): '\(currentText)'")
                }
            }

            print("  Final result: '\(currentText)'")
        }

        // 5. Unicode normalization showcase
        do {
            print("\n5. Unicode Normalization Showcase")
            print("   (Demonstrating various Unicode edge cases)")

            var unicodeRecipe = TransliterationRecipe()
            unicodeRecipe.replaceSpaces = true
            unicodeRecipe.replaceMathematicalAlphanumerics = true
            unicodeRecipe.replaceRadicals = true

            let unicodeNormalizer = try unicodeRecipe.makeTransliterator()

            let unicodeSamples = [
                ("\u{2003}\u{2002}\u{2000}", "Various em/en spaces"),
                ("\u{3000}\u{00A0}\u{202F}", "Ideographic and narrow spaces"),
                ("⺅⻌⽊", "CJK radicals"),
                ("\u{1D400}\u{1D401}\u{1D402}", "Mathematical bold letters"),
            ]

            print("\n   Processing text samples with character codes:\n")
            for (text, description) in unicodeSamples {
                print("   \(description):")
                print("     Original: '\(text)'")

                // Show character codes for clarity
                let codes = text.unicodeScalars.map { scalar in
                    "U+\(String(scalar.value, radix: 16).uppercased().padding(toLength: 4, withPad: "0", startingAt: 0))"
                }
                print("     Codes:    \(codes.joined(separator: " "))")

                let transliterated = unicodeNormalizer(text)
                print("     Result:   '\(transliterated)'\n")
            }
        }

        // 6. Performance considerations
        do {
            print("6. Performance Considerations")
            print("   (Reusing transliterators for better performance)")

            var perfRecipe = TransliterationRecipe()
            perfRecipe.kanjiOldNew = true
            perfRecipe.replaceSpaces = true

            let perfTransliterator = try perfRecipe.makeTransliterator()

            // Simulate processing multiple texts
            let texts = [
                "これはテストです",
                "檜原村は美しい",
                "hello　world",
                "プログラミング",
            ]

            print("  Processing \(texts.count) texts with the same transliterator:")
            for (i, text) in texts.enumerated() {
                let result = perfTransliterator(text)
                print("    \(i + 1): '\(text)' → '\(result)'")
            }
        }

        print("\n=== Advanced Examples Complete ===")
    }
}
