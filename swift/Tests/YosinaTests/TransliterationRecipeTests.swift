import XCTest
@testable import Yosina

final class TransliterationRecipeTests: XCTestCase {
    // MARK: - Basic Recipe Functionality Tests

    func testEmptyRecipe() throws {
        let recipe = TransliterationRecipe()
        let config = try recipe.buildTransliteratorConfig()

        // An empty recipe should produce an empty config
        XCTAssertEqual(config.count, 0)
    }

    func testDefaultValues() {
        let recipe = TransliterationRecipe()

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
        let recipe = TransliterationRecipe().withKanjiOldNew(true)
        let config = try recipe.buildTransliteratorConfig()

        // Should create at least 3 transliterators: 2 IVS/SVS + 1 kanji-old-new
        XCTAssertGreaterThanOrEqual(config.count, 3)

        // Check for kanji-old-new transliterator
        XCTAssert(config.contains { if case .kanjiOldNew = $0 { return true } else { return false } })

        // Check for IVS/SVS base transliterators (should be 2)
        let ivsSvsCount = config.filter { if case .ivsSvsBase = $0 { return true } else { return false } }.count
        XCTAssertEqual(ivsSvsCount, 2)
    }

    func testReplaceSuspiciousHyphensToProlongedSoundMarks() throws {
        let recipe = TransliterationRecipe().withReplaceSuspiciousHyphensToProlongedSoundMarks(true)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .prolongedSoundMarks = config[0] { return true } else { return false } }())
    }

    func testReplaceCircledOrSquaredCharactersDefault() throws {
        let recipe = TransliterationRecipe().withReplaceCircledOrSquaredCharacters(.enabled)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .circledOrSquared = config[0] { return true } else { return false } }())

        // Default should include emojis
        XCTAssertTrue(recipe.replaceCircledOrSquaredCharacters.includeEmojis)
    }

    func testReplaceCircledOrSquaredCharactersExcludeEmojis() throws {
        let recipe = TransliterationRecipe().withReplaceCircledOrSquaredCharacters(.excludeEmojis)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .circledOrSquared = config[0] { return true } else { return false } }())

        // Should exclude emojis
        XCTAssertFalse(recipe.replaceCircledOrSquaredCharacters.includeEmojis)
    }

    func testReplaceCombinedCharacters() throws {
        let recipe = TransliterationRecipe().withReplaceCombinedCharacters(true)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .combined = config[0] { return true } else { return false } }())
    }

    func testReplaceIdeographicAnnotations() throws {
        let recipe = TransliterationRecipe().withReplaceIdeographicAnnotations(true)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .ideographicAnnotations = config[0] { return true } else { return false } }())
    }

    func testReplaceRadicals() throws {
        let recipe = TransliterationRecipe().withReplaceRadicals(true)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .radicals = config[0] { return true } else { return false } }())
    }

    func testReplaceSpaces() throws {
        let recipe = TransliterationRecipe().withReplaceSpaces(true)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .spaces = config[0] { return true } else { return false } }())
    }

    func testReplaceMathematicalAlphanumerics() throws {
        let recipe = TransliterationRecipe().withReplaceMathematicalAlphanumerics(true)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .mathematicalAlphanumerics = config[0] { return true } else { return false } }())
    }

    func testCombineDecomposedHiraganasAndKatakanas() throws {
        let recipe = TransliterationRecipe().withCombineDecomposedHiraganasAndKatakanas(true)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .hiraKataComposition = config[0] { return true } else { return false } }())
    }

    // MARK: - Complex Option Configuration Tests

    func testReplaceHyphensDefault() throws {
        let recipe = TransliterationRecipe().withReplaceHyphens(.enabled)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssertTrue({ if case .hyphens = config[0] { return true } else { return false } }())

        // Check default precedence
        let expectedPrecedence: [HyphensTransliterator.Precedence] = [.jisx0208_90_windows, .jisx0201]
        XCTAssertEqual(recipe.replaceHyphens.precedence, expectedPrecedence)
    }

    func testReplaceHyphensCustomPrecedence() throws {
        let customPrecedence: [HyphensTransliterator.Precedence] = [.jisx0201, .jisx0208_90]
        let recipe = TransliterationRecipe().withReplaceHyphens(.withPrecedence(customPrecedence))
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .hyphens = config[0] { return true } else { return false } }())
        XCTAssertEqual(recipe.replaceHyphens.precedence, customPrecedence)
    }

    func testToFullwidthBasic() throws {
        let recipe = TransliterationRecipe().withToFullwidth(.enabled)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .jisx0201AndAlike = config[0] { return true } else { return false } }())

        XCTAssertTrue(recipe.toFullwidth.isEnabled)
        XCTAssertFalse(recipe.toFullwidth.isU005cAsYenSign)
    }

    func testToFullwidthU005cAsYenSign() throws {
        let recipe = TransliterationRecipe().withToFullwidth(.u005cAsYenSign)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .jisx0201AndAlike = config[0] { return true } else { return false } }())

        XCTAssertTrue(recipe.toFullwidth.isEnabled)
        XCTAssertTrue(recipe.toFullwidth.isU005cAsYenSign)
    }

    func testToHalfwidthBasic() throws {
        let recipe = TransliterationRecipe().withToHalfwidth(.enabled)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .jisx0201AndAlike = config[0] { return true } else { return false } }())

        XCTAssertTrue(recipe.toHalfwidth.isEnabled)
        XCTAssertFalse(recipe.toHalfwidth.isHankakuKana)
    }

    func testToHalfwidthHankakuKana() throws {
        let recipe = TransliterationRecipe().withToHalfwidth(.hankakuKana)
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 1)
        XCTAssert({ if case .jisx0201AndAlike = config[0] { return true } else { return false } }())

        XCTAssertTrue(recipe.toHalfwidth.isEnabled)
        XCTAssertTrue(recipe.toHalfwidth.isHankakuKana)
    }

    func testRemoveIvsSvsBasic() throws {
        let recipe = TransliterationRecipe().withRemoveIvsSvs(.enabled)
        let config = try recipe.buildTransliteratorConfig()

        // Should create 2 IVS/SVS base transliterators
        XCTAssertEqual(config.count, 2)

        let ivsSvsTransliterators = config.compactMap { if case .ivsSvsBase = $0 { return true } else { return false } }
        XCTAssertEqual(ivsSvsTransliterators.count, 2)

        XCTAssertTrue(recipe.removeIvsSvs.isEnabled)
        XCTAssertFalse(recipe.removeIvsSvs.isDropAllSelectors)
    }

    func testRemoveIvsSvsDropAllSelectors() throws {
        let recipe = TransliterationRecipe().withRemoveIvsSvs(.dropAllSelectors)
        let config = try recipe.buildTransliteratorConfig()

        // Should create 2 IVS/SVS base transliterators
        XCTAssertEqual(config.count, 2)

        let ivsSvsTransliterators = config.compactMap { if case .ivsSvsBase = $0 { return true } else { return false } }
        XCTAssertEqual(ivsSvsTransliterators.count, 2)

        XCTAssertTrue(recipe.removeIvsSvs.isEnabled)
        XCTAssertTrue(recipe.removeIvsSvs.isDropAllSelectors)
    }

    func testCharsetConfiguration() throws {
        let recipe = TransliterationRecipe()
            .withRemoveIvsSvs(.enabled)
            .withCharset(.unijis90)

        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(recipe.charset, .unijis90)

        // Verify IVS/SVS transliterators exist
        let ivsSvsCount = config.filter { if case .ivsSvsBase = $0 { return true } else { return false } }.count
        XCTAssertEqual(ivsSvsCount, 2)
    }

    // MARK: - Transliterator Ordering Tests

    func testCircledOrSquaredAndCombinedOrder() throws {
        let recipe = TransliterationRecipe()
            .withReplaceCircledOrSquaredCharacters(.enabled)
            .withReplaceCombinedCharacters(true)

        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 2)

        // Find indices
        let combinedIndex = config.firstIndex { if case .combined = $0 { return true } else { return false } }
        let circledIndex = config.firstIndex { if case .circledOrSquared = $0 { return true } else { return false } }

        XCTAssertNotNil(combinedIndex)
        XCTAssertNotNil(circledIndex)

        // Combined should come before circled-or-squared
        if let combinedIdx = combinedIndex, let circledIdx = circledIndex {
            XCTAssertLessThan(combinedIdx, circledIdx)
        }
    }

    func testComprehensiveOrdering() throws {
        let recipe = TransliterationRecipe()
            .withCombineDecomposedHiraganasAndKatakanas(true)
            .withReplaceCircledOrSquaredCharacters(.enabled)
            .withReplaceCombinedCharacters(true)
            .withToHalfwidth(.enabled)
            .withReplaceSpaces(true)

        let config = try recipe.buildTransliteratorConfig()

        // Find indices
        let hiraKataIndex = config.firstIndex { if case .hiraKataComposition = $0 { return true } else { return false } }
        let jisx0201Index = config.firstIndex { if case .jisx0201AndAlike = $0 { return true } else { return false } }
        let spacesIndex = config.firstIndex { if case .spaces = $0 { return true } else { return false } }

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
        let recipe = TransliterationRecipe()
            .withToFullwidth(.enabled)
            .withToHalfwidth(.enabled)

        XCTAssertThrowsError(try recipe.buildTransliteratorConfig()) { error in
            guard let recipeError = error as? TransliterationRecipeError,
                  case let .mutuallyExclusiveOptions(message) = recipeError
            else {
                XCTFail("Expected TransliterationRecipeError.mutuallyExclusiveOptions")
                return
            }
            XCTAssert(message.contains("mutually exclusive"))
        }
    }

    // MARK: - Comprehensive Configuration Tests

    func testAllTransliteratorsEnabled() throws {
        let recipe = TransliterationRecipe()
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

        // Verify all expected transliterators are present
        XCTAssert(config.contains { if case .kanjiOldNew = $0 { return true } else { return false } })
        XCTAssert(config.contains { if case .prolongedSoundMarks = $0 { return true } else { return false } })
        XCTAssert(config.contains { if case .combined = $0 { return true } else { return false } })
        XCTAssert(config.contains { if case .circledOrSquared = $0 { return true } else { return false } })
        XCTAssert(config.contains { if case .ideographicAnnotations = $0 { return true } else { return false } })
        XCTAssert(config.contains { if case .radicals = $0 { return true } else { return false } })
        XCTAssert(config.contains { if case .spaces = $0 { return true } else { return false } })
        XCTAssert(config.contains { if case .hyphens = $0 { return true } else { return false } })
        XCTAssert(config.contains { if case .mathematicalAlphanumerics = $0 { return true } else { return false } })
        XCTAssert(config.contains { if case .hiraKataComposition = $0 { return true } else { return false } })
        XCTAssert(config.contains { if case .jisx0201AndAlike = $0 { return true } else { return false } })

        // IVS/SVS should appear exactly twice (2 times total)
        // Both kanji-old-new and remove-ivs-svs share the same IVS/SVS transliterators
        let ivsSvsCount = config.filter { if case .ivsSvsBase = $0 { return true } else { return false } }.count
        XCTAssertEqual(ivsSvsCount, 2)
    }

    // MARK: - Functional Integration Tests

    func testZZZBasicTransliteration() throws {
        // Test makeTransliterator with transliterate
        let recipe = TransliterationRecipe().withReplaceSpaces(true)
        let transliterator = try recipe.makeTransliterator()

        // Test spaces
        XCTAssertEqual(transliterator.transliterate("　"), " ") // Full-width space to half-width
    }

    func testExcludeEmojiFunctional() throws {
        let recipeInclude = TransliterationRecipe()
            .withReplaceCircledOrSquaredCharacters(.enabled)
        let recipeExclude = TransliterationRecipe()
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
        let recipe = TransliterationRecipe()
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
        let recipe = TransliterationRecipe()
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
        let recipe = TransliterationRecipe()
        let config = try recipe.buildTransliteratorConfig()

        XCTAssertEqual(config.count, 0)
    }

    func testMultipleIvsSvsConfigurations() throws {
        let recipe = TransliterationRecipe()
            .withKanjiOldNew(true)
            .withRemoveIvsSvs(.enabled)

        let config = try recipe.buildTransliteratorConfig()

        // Should have multiple IVS/SVS configurations
        // Both kanji-old-new and remove-ivs-svs share the same IVS/SVS transliterators
        let ivsSvsTransliterators = config.compactMap { if case .ivsSvsBase = $0 { return $0 } else { return nil } }
        XCTAssertEqual(ivsSvsTransliterators.count, 2)
    }
}
