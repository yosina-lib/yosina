import XCTest
@testable import Yosina

final class TransliteratorRecipeTests: XCTestCase {
    // MARK: - Basic Recipe Functionality Tests

    func testEmptyRecipe() throws {
        let recipe = TransliteratorRecipe()
        let config = try recipe.buildTransliteratorConfig()

        // An empty recipe should produce an empty config
        let transliterators = config.build()
        XCTAssertEqual(transliterators.count, 0)
    }

    func testDefaultValues() {
        let recipe = TransliteratorRecipe()

        XCTAssertFalse(recipe.kanjiOldNew)
        XCTAssertFalse(recipe.replaceSuspiciousHyphensToProlongedSoundMarks)
        XCTAssertFalse(recipe.replaceCombinedCharacters)
        XCTAssertFalse(recipe.replaceCircledOrSquaredCharacters.isEnabled)
        XCTAssertFalse(recipe.replaceIdeographicAnnotations)
        XCTAssertFalse(recipe.replaceRadicals)
        XCTAssertFalse(recipe.replaceSpaces)
        XCTAssertFalse(recipe.replaceHyphens.isEnabled)
        XCTAssertFalse(recipe.replaceMathematicalAlphanumerics)
        XCTAssertFalse(recipe.combineDecomposedHiraganasAndKatakanas)
        XCTAssertFalse(recipe.toFullwidth.isEnabled)
        XCTAssertFalse(recipe.toHalfwidth.isEnabled)
        XCTAssertFalse(recipe.removeIvsSvs.isEnabled)
        XCTAssertEqual(recipe.charset, .unijis2004)
    }

    // MARK: - Individual Transliterator Configuration Tests

    func testKanjiOldNew() throws {
        let recipe = TransliteratorRecipe().withKanjiOldNew(true)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        // Should create at least 3 transliterators: 2 IVS/SVS + 1 kanji-old-new
        XCTAssertGreaterThanOrEqual(transliterators.count, 3)

        // Check for kanji-old-new transliterator
        XCTAssert(transliterators.contains { $0 is KanjiOldNewTransliterator })

        // Check for IVS/SVS base transliterators (should be 2)
        let ivsSvsCount = transliterators.filter { $0 is IvsSvsBaseTransliterator }.count
        XCTAssertEqual(ivsSvsCount, 2)
    }

    func testReplaceSuspiciousHyphensToProlongedSoundMarks() throws {
        let recipe = TransliteratorRecipe().withReplaceSuspiciousHyphensToProlongedSoundMarks(true)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is ProlongedSoundMarksTransliterator)
    }

    func testReplaceCircledOrSquaredCharactersDefault() throws {
        let recipe = TransliteratorRecipe().withReplaceCircledOrSquaredCharacters(.enabled)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is CircledOrSquaredTransliterator)

        // Default should include emojis
        XCTAssertTrue(recipe.replaceCircledOrSquaredCharacters.includeEmojis)
    }

    func testReplaceCircledOrSquaredCharactersExcludeEmojis() throws {
        let recipe = TransliteratorRecipe().withReplaceCircledOrSquaredCharacters(.excludeEmojis)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is CircledOrSquaredTransliterator)

        // Should exclude emojis
        XCTAssertFalse(recipe.replaceCircledOrSquaredCharacters.includeEmojis)
    }

    func testReplaceCombinedCharacters() throws {
        let recipe = TransliteratorRecipe().withReplaceCombinedCharacters(true)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is CombinedTransliterator)
    }

    func testReplaceIdeographicAnnotations() throws {
        let recipe = TransliteratorRecipe().withReplaceIdeographicAnnotations(true)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is IdeographicAnnotationsTransliterator)
    }

    func testReplaceRadicals() throws {
        let recipe = TransliteratorRecipe().withReplaceRadicals(true)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is RadicalsTransliterator)
    }

    func testReplaceSpaces() throws {
        let recipe = TransliteratorRecipe().withReplaceSpaces(true)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is SpacesTransliterator)
    }

    func testReplaceMathematicalAlphanumerics() throws {
        let recipe = TransliteratorRecipe().withReplaceMathematicalAlphanumerics(true)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is MathematicalAlphanumericsTransliterator)
    }

    func testCombineDecomposedHiraganasAndKatakanas() throws {
        let recipe = TransliteratorRecipe().withCombineDecomposedHiraganasAndKatakanas(true)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is HiraKataCompositionTransliterator)
    }

    // MARK: - Complex Option Configuration Tests

    func testReplaceHyphensDefault() throws {
        let recipe = TransliteratorRecipe().withReplaceHyphens(.enabled)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        let hyphensTransliterator = transliterators[0] as? HyphensTransliterator
        XCTAssertNotNil(hyphensTransliterator)

        // Check default precedence
        let expectedPrecedence: [HyphensTransliterator.Precedence] = [.jisx0208_90_windows, .jisx0201]
        XCTAssertEqual(recipe.replaceHyphens.precedence, expectedPrecedence)
    }

    func testReplaceHyphensCustomPrecedence() throws {
        let customPrecedence: [HyphensTransliterator.Precedence] = [.jisx0201, .jisx0208_90]
        let recipe = TransliteratorRecipe().withReplaceHyphens(.withPrecedence(customPrecedence))
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is HyphensTransliterator)
        XCTAssertEqual(recipe.replaceHyphens.precedence, customPrecedence)
    }

    func testToFullwidthBasic() throws {
        let recipe = TransliteratorRecipe().withToFullwidth(.enabled)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is Jisx0201AndAlikeTransliterator)

        XCTAssertTrue(recipe.toFullwidth.isEnabled)
        XCTAssertFalse(recipe.toFullwidth.isU005cAsYenSign)
    }

    func testToFullwidthU005cAsYenSign() throws {
        let recipe = TransliteratorRecipe().withToFullwidth(.u005cAsYenSign)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is Jisx0201AndAlikeTransliterator)

        XCTAssertTrue(recipe.toFullwidth.isEnabled)
        XCTAssertTrue(recipe.toFullwidth.isU005cAsYenSign)
    }

    func testToHalfwidthBasic() throws {
        let recipe = TransliteratorRecipe().withToHalfwidth(.enabled)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is Jisx0201AndAlikeTransliterator)

        XCTAssertTrue(recipe.toHalfwidth.isEnabled)
        XCTAssertFalse(recipe.toHalfwidth.isHankakuKana)
    }

    func testToHalfwidthHankakuKana() throws {
        let recipe = TransliteratorRecipe().withToHalfwidth(.hankakuKana)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 1)
        XCTAssert(transliterators[0] is Jisx0201AndAlikeTransliterator)

        XCTAssertTrue(recipe.toHalfwidth.isEnabled)
        XCTAssertTrue(recipe.toHalfwidth.isHankakuKana)
    }

    func testRemoveIvsSvsBasic() throws {
        let recipe = TransliteratorRecipe().withRemoveIvsSvs(.enabled)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        // Should create 2 IVS/SVS base transliterators
        XCTAssertEqual(transliterators.count, 2)

        let ivsSvsTransliterators = transliterators.compactMap { $0 as? IvsSvsBaseTransliterator }
        XCTAssertEqual(ivsSvsTransliterators.count, 2)

        XCTAssertTrue(recipe.removeIvsSvs.isEnabled)
        XCTAssertFalse(recipe.removeIvsSvs.isDropAllSelectors)
    }

    func testRemoveIvsSvsDropAllSelectors() throws {
        let recipe = TransliteratorRecipe().withRemoveIvsSvs(.dropAllSelectors)
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        // Should create 2 IVS/SVS base transliterators
        XCTAssertEqual(transliterators.count, 2)

        let ivsSvsTransliterators = transliterators.compactMap { $0 as? IvsSvsBaseTransliterator }
        XCTAssertEqual(ivsSvsTransliterators.count, 2)

        XCTAssertTrue(recipe.removeIvsSvs.isEnabled)
        XCTAssertTrue(recipe.removeIvsSvs.isDropAllSelectors)
    }

    func testCharsetConfiguration() throws {
        let recipe = TransliteratorRecipe()
            .withRemoveIvsSvs(.enabled)
            .withCharset(.unijis90)

        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(recipe.charset, .unijis90)

        // Verify IVS/SVS transliterators exist
        let ivsSvsCount = transliterators.filter { $0 is IvsSvsBaseTransliterator }.count
        XCTAssertEqual(ivsSvsCount, 2)
    }

    // MARK: - Transliterator Ordering Tests

    func testCircledOrSquaredAndCombinedOrder() throws {
        let recipe = TransliteratorRecipe()
            .withReplaceCircledOrSquaredCharacters(.enabled)
            .withReplaceCombinedCharacters(true)

        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 2)

        // Find indices
        let combinedIndex = transliterators.firstIndex { $0 is CombinedTransliterator }
        let circledIndex = transliterators.firstIndex { $0 is CircledOrSquaredTransliterator }

        XCTAssertNotNil(combinedIndex)
        XCTAssertNotNil(circledIndex)

        // Combined should come before circled-or-squared
        if let combinedIdx = combinedIndex, let circledIdx = circledIndex {
            XCTAssertLessThan(combinedIdx, circledIdx)
        }
    }

    func testComprehensiveOrdering() throws {
        let recipe = TransliteratorRecipe()
            .withCombineDecomposedHiraganasAndKatakanas(true)
            .withReplaceCircledOrSquaredCharacters(.enabled)
            .withReplaceCombinedCharacters(true)
            .withToHalfwidth(.enabled)
            .withReplaceSpaces(true)

        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        // Find indices
        let hiraKataIndex = transliterators.firstIndex { $0 is HiraKataCompositionTransliterator }
        let jisx0201Index = transliterators.firstIndex { $0 is Jisx0201AndAlikeTransliterator }
        let spacesIndex = transliterators.firstIndex { $0 is SpacesTransliterator }

        XCTAssertNotNil(hiraKataIndex)
        XCTAssertNotNil(jisx0201Index)
        XCTAssertNotNil(spacesIndex)

        // hira-kata-composition should be early (head insertion)
        // jisx0201-and-alike should be at the end (tail insertion)
        if let hiraKataIdx = hiraKataIndex, let jisx0201Idx = jisx0201Index {
            XCTAssertLessThan(hiraKataIdx, jisx0201Idx)
        }
    }

    // MARK: - Mutual Exclusion Tests

    func testToFullwidthAndToHalfwidthMutuallyExclusive() {
        let recipe = TransliteratorRecipe()
            .withToFullwidth(.enabled)
            .withToHalfwidth(.enabled)

        XCTAssertThrowsError(try recipe.buildTransliteratorConfig()) { error in
            guard let recipeError = error as? TransliteratorRecipeError,
                  case let .mutuallyExclusiveOptions(message) = recipeError
            else {
                XCTFail("Expected TransliteratorRecipeError.mutuallyExclusiveOptions")
                return
            }
            XCTAssert(message.contains("mutually exclusive"))
        }
    }

    // MARK: - Comprehensive Configuration Tests

    func testAllTransliteratorsEnabled() throws {
        let recipe = TransliteratorRecipe()
            .withKanjiOldNew(true)
            .withReplaceSuspiciousHyphensToProlongedSoundMarks(true)
            .withReplaceCombinedCharacters(true)
            .withReplaceCircledOrSquaredCharacters(.enabled)
            .withReplaceIdeographicAnnotations(true)
            .withReplaceRadicals(true)
            .withReplaceSpaces(true)
            .withReplaceHyphens(.enabled)
            .withReplaceMathematicalAlphanumerics(true)
            .withCombineDecomposedHiraganasAndKatakanas(true)
            .withToHalfwidth(.hankakuKana)
            .withRemoveIvsSvs(.enabled)
            .withCharset(.unijis90)

        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        // Verify all expected transliterators are present
        XCTAssert(transliterators.contains { $0 is KanjiOldNewTransliterator })
        XCTAssert(transliterators.contains { $0 is ProlongedSoundMarksTransliterator })
        XCTAssert(transliterators.contains { $0 is CombinedTransliterator })
        XCTAssert(transliterators.contains { $0 is CircledOrSquaredTransliterator })
        XCTAssert(transliterators.contains { $0 is IdeographicAnnotationsTransliterator })
        XCTAssert(transliterators.contains { $0 is RadicalsTransliterator })
        XCTAssert(transliterators.contains { $0 is SpacesTransliterator })
        XCTAssert(transliterators.contains { $0 is HyphensTransliterator })
        XCTAssert(transliterators.contains { $0 is MathematicalAlphanumericsTransliterator })
        XCTAssert(transliterators.contains { $0 is HiraKataCompositionTransliterator })
        XCTAssert(transliterators.contains { $0 is Jisx0201AndAlikeTransliterator })

        // IVS/SVS should appear exactly twice (2 times total)
        // Both kanji-old-new and remove-ivs-svs share the same IVS/SVS transliterators
        let ivsSvsCount = transliterators.filter { $0 is IvsSvsBaseTransliterator }.count
        XCTAssertEqual(ivsSvsCount, 2)
    }

    // MARK: - Functional Integration Tests

    func testBasicTransliteration() throws {
        let recipe = TransliteratorRecipe()
            .withReplaceCircledOrSquaredCharacters(.enabled)
            .withReplaceMathematicalAlphanumerics(true)
            .withReplaceSpaces(true)
            .withReplaceCombinedCharacters(true)  // Add this for parenthesized numbers

        let transliterator = try recipe.makeTransliterator()

        // Test circled numbers
        XCTAssertEqual(transliterator.transliterate("①"), "(1)")
        XCTAssertEqual(transliterator.transliterate("②③"), "(2)(3)")

        // Test parenthesized numbers (handled by combined characters)
        XCTAssertEqual(transliterator.transliterate("⑴"), "(1)")

        // Test mathematical alphanumerics
        XCTAssertEqual(transliterator.transliterate("𝐇𝐞𝐥𝐥𝐨"), "Hello")
        XCTAssertEqual(transliterator.transliterate("𝐀𝐁𝐂"), "ABC")

        // Test spaces
        XCTAssertEqual(transliterator.transliterate("　"), " ") // Full-width space to half-width
    }

    func testExcludeEmojiFunctional() throws {
        let recipeInclude = TransliteratorRecipe()
            .withReplaceCircledOrSquaredCharacters(.enabled)
        let recipeExclude = TransliteratorRecipe()
            .withReplaceCircledOrSquaredCharacters(.excludeEmojis)

        let transliteratorInclude = try recipeInclude.makeTransliterator()
        let transliteratorExclude = try recipeExclude.makeTransliterator()

        // Regular circled/squared characters should work in both
        XCTAssertEqual(transliteratorInclude.transliterate("①"), "(1)")
        XCTAssertEqual(transliteratorExclude.transliterate("①"), "(1)")

        // Non-emoji squared letters
        XCTAssertEqual(transliteratorInclude.transliterate("🄰"), "[A]")
        XCTAssertEqual(transliteratorExclude.transliterate("🄰"), "[A]")

        // Emoji characters - behavior depends on implementation
        // Since we don't have specific emoji test data from Swift implementation,
        // we'll test that the configuration is properly set
        XCTAssertTrue(recipeInclude.replaceCircledOrSquaredCharacters.includeEmojis)
        XCTAssertFalse(recipeExclude.replaceCircledOrSquaredCharacters.includeEmojis)
    }

    func testComplexTransliteration() throws {
        let recipe = TransliteratorRecipe()
            .withReplaceCombinedCharacters(true)
            .withReplaceCircledOrSquaredCharacters(.enabled)
            .withCombineDecomposedHiraganasAndKatakanas(true)
            .withToHalfwidth(.hankakuKana)

        let transliterator = try recipe.makeTransliterator()

        // Test combined characters
        XCTAssertEqual(transliterator.transliterate("㈱"), "(株)")
        XCTAssertEqual(transliterator.transliterate("㍻"), "平成")

        // Test circled characters
        XCTAssertEqual(transliterator.transliterate("㊙"), "(秘)")

        // Test combining marks (if applicable)
        // Note: Actual behavior depends on implementation details
    }

    // MARK: - Fluent API Tests

    func testFluentAPI() throws {
        let recipe = TransliteratorRecipe()
            .withKanjiOldNew(true)
            .withReplaceSpaces(true)
            .withToHalfwidth(.enabled)

        XCTAssertTrue(recipe.kanjiOldNew)
        XCTAssertTrue(recipe.replaceSpaces)
        XCTAssertTrue(recipe.toHalfwidth.isEnabled)

        // Test that fluent API creates new instances
        let recipe2 = recipe.withKanjiOldNew(false)
        XCTAssertFalse(recipe2.kanjiOldNew)
        XCTAssertTrue(recipe.kanjiOldNew) // Original should be unchanged
    }

    // MARK: - Edge Cases

    func testEmptyConfigurationWhenNoOptionsSet() throws {
        let recipe = TransliteratorRecipe()
        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        XCTAssertEqual(transliterators.count, 0)
    }

    func testMultipleIvsSvsConfigurations() throws {
        let recipe = TransliteratorRecipe()
            .withKanjiOldNew(true)
            .withRemoveIvsSvs(.enabled)

        let config = try recipe.buildTransliteratorConfig()
        let transliterators = config.build()

        // Should have multiple IVS/SVS configurations
        // Both kanji-old-new and remove-ivs-svs share the same IVS/SVS transliterators
        let ivsSvsTransliterators = transliterators.compactMap { $0 as? IvsSvsBaseTransliterator }
        XCTAssertEqual(ivsSvsTransliterators.count, 2)
    }
}
