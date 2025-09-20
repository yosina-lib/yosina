import XCTest
@testable import Yosina

final class RomanNumeralsTests: XCTestCase {
    func testCreateRomanNumeralsTransliterator() {
        let transliterator = RomanNumeralsTransliterator()
        XCTAssertNotNil(transliterator)
    }

    func testBasicUppercaseRomanNumerals() {
        let transliterator = RomanNumeralsTransliterator()

        // Test uppercase Roman numerals 1-12
        XCTAssertEqual(transliterator.transliterate("\u{2160}"), "I") // Ⅰ
        XCTAssertEqual(transliterator.transliterate("\u{2161}"), "II") // Ⅱ
        XCTAssertEqual(transliterator.transliterate("\u{2162}"), "III") // Ⅲ
        XCTAssertEqual(transliterator.transliterate("\u{2163}"), "IV") // Ⅳ
        XCTAssertEqual(transliterator.transliterate("\u{2164}"), "V") // Ⅴ
        XCTAssertEqual(transliterator.transliterate("\u{2165}"), "VI") // Ⅵ
        XCTAssertEqual(transliterator.transliterate("\u{2166}"), "VII") // Ⅶ
        XCTAssertEqual(transliterator.transliterate("\u{2167}"), "VIII") // Ⅷ
        XCTAssertEqual(transliterator.transliterate("\u{2168}"), "IX") // Ⅸ
        XCTAssertEqual(transliterator.transliterate("\u{2169}"), "X") // Ⅹ
        XCTAssertEqual(transliterator.transliterate("\u{216A}"), "XI") // Ⅺ
        XCTAssertEqual(transliterator.transliterate("\u{216B}"), "XII") // Ⅻ
    }

    func testBasicLowercaseRomanNumerals() {
        let transliterator = RomanNumeralsTransliterator()

        // Test lowercase Roman numerals 1-12
        XCTAssertEqual(transliterator.transliterate("\u{2170}"), "i") // ⅰ
        XCTAssertEqual(transliterator.transliterate("\u{2171}"), "ii") // ⅱ
        XCTAssertEqual(transliterator.transliterate("\u{2172}"), "iii") // ⅲ
        XCTAssertEqual(transliterator.transliterate("\u{2173}"), "iv") // ⅳ
        XCTAssertEqual(transliterator.transliterate("\u{2174}"), "v") // ⅴ
        XCTAssertEqual(transliterator.transliterate("\u{2175}"), "vi") // ⅵ
        XCTAssertEqual(transliterator.transliterate("\u{2176}"), "vii") // ⅶ
        XCTAssertEqual(transliterator.transliterate("\u{2177}"), "viii") // ⅷ
        XCTAssertEqual(transliterator.transliterate("\u{2178}"), "ix") // ⅸ
        XCTAssertEqual(transliterator.transliterate("\u{2179}"), "x") // ⅹ
        XCTAssertEqual(transliterator.transliterate("\u{217A}"), "xi") // ⅺ
        XCTAssertEqual(transliterator.transliterate("\u{217B}"), "xii") // ⅻ
    }

    func testLargeRomanNumerals() {
        let transliterator = RomanNumeralsTransliterator()

        // Test large Roman numerals
        XCTAssertEqual(transliterator.transliterate("\u{216C}"), "L") // Ⅼ (50)
        XCTAssertEqual(transliterator.transliterate("\u{216D}"), "C") // Ⅽ (100)
        XCTAssertEqual(transliterator.transliterate("\u{216E}"), "D") // Ⅾ (500)
        XCTAssertEqual(transliterator.transliterate("\u{216F}"), "M") // Ⅿ (1000)

        XCTAssertEqual(transliterator.transliterate("\u{217C}"), "l") // ⅼ (50)
        XCTAssertEqual(transliterator.transliterate("\u{217D}"), "c") // ⅽ (100)
        XCTAssertEqual(transliterator.transliterate("\u{217E}"), "d") // ⅾ (500)
        XCTAssertEqual(transliterator.transliterate("\u{217F}"), "m") // ⅿ (1000)
    }

    func testMixedText() {
        let transliterator = RomanNumeralsTransliterator()

        // Standard mixed text test cases (unified across all languages)
        let standardTestCases: [(String, String)] = [
            ("Year \u{216B}", "Year XII"), // Year Ⅻ
            ("Chapter \u{2173}", "Chapter iv"), // Chapter ⅳ
            ("Section \u{2162}.A", "Section III.A"), // Section Ⅲ.A
            ("\u{2160} \u{2161} \u{2162}", "I II III"), // Ⅰ Ⅱ Ⅲ
            ("\u{2170}, \u{2171}, \u{2172}", "i, ii, iii"), // ⅰ, ⅱ, ⅲ
            ("Book \u{2160}: Chapter \u{2170}, Section \u{2161}.\u{2172} and Part \u{2163}",
             "Book I: Chapter i, Section II.iii and Part IV"), // Complex mixed text
        ]

        for (input, expected) in standardTestCases {
            XCTAssertEqual(transliterator.transliterate(input), expected)
        }

        // Additional Swift-specific mixed text tests
        let input = "Chapter \u{2160}: Introduction to \u{2163} concepts"
        let expected = "Chapter I: Introduction to IV concepts"
        XCTAssertEqual(transliterator.transliterate(input), expected)

        // Test with lowercase
        let input2 = "Page \u{2178} of \u{217A}"
        let expected2 = "Page ix of xi"
        XCTAssertEqual(transliterator.transliterate(input2), expected2)
    }

    func testNonRomanNumeralsUnchanged() {
        let transliterator = RomanNumeralsTransliterator()

        // Regular text should remain unchanged
        XCTAssertEqual(transliterator.transliterate("Hello World"), "Hello World")
        XCTAssertEqual(transliterator.transliterate("123 ABC xyz"), "123 ABC xyz")

        // Other Unicode characters should remain unchanged
        XCTAssertEqual(transliterator.transliterate("日本語"), "日本語")
    }

    func testEdgeCases() {
        let transliterator = RomanNumeralsTransliterator()

        // Standard edge cases (unified across all languages)
        let edgeTestCases: [(String, String, String)] = [
            ("", "", "Empty string"),
            ("ABC123", "ABC123", "No Roman numerals"),
            ("\u{2160}\u{2161}\u{2162}", "IIIIII", "Consecutive Romans"),
            ("Book \u{2160}: Chapter \u{2170}, Section \u{2161}.\u{2172} and Part \u{2163}",
             "Book I: Chapter i, Section II.iii and Part IV", "Complex mixed text with multiple Romans"),
        ]

        for (input, expected, description) in edgeTestCases {
            XCTAssertEqual(transliterator.transliterate(input), expected, description)
        }
    }

    func testEmptyString() {
        let transliterator = RomanNumeralsTransliterator()

        XCTAssertEqual(transliterator.transliterate(""), "")
    }

    func testConsecutiveRomanNumerals() {
        let transliterator = RomanNumeralsTransliterator()

        // Multiple Roman numerals in a row
        let input = "\u{2160}\u{2161}\u{2162}" // ⅠⅡⅢ
        let expected = "IIIIII" // Each gets expanded
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testRomanNumeralsWithJapaneseText() {
        let transliterator = RomanNumeralsTransliterator()

        // Common pattern in Japanese documents
        let input = "第\u{2160}章" // 第Ⅰ章 (Chapter I)
        let expected = "第I章"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testTransliteratorConfig() {
        // Test through TransliteratorConfig
        let config = TransliteratorConfig.romanNumerals
        let transliterator = config.makeTransliterator()

        XCTAssertEqual(transliterator.transliterate("\u{2165}"), "VI")
    }

    func testTransliterationRecipe() throws {
        // Test through TransliterationRecipe
        var recipe = TransliterationRecipe()
        recipe.replaceRomanNumerals = true

        let transliterator = try recipe.makeTransliterator()

        XCTAssertEqual(transliterator.transliterate("\u{2169}"), "X")
        XCTAssertEqual(transliterator.transliterate("\u{2179}"), "x")
    }

    func testChainedWithOtherTransliterators() throws {
        // Test Roman numerals with other transformations
        var recipe = TransliterationRecipe()
        recipe.replaceRomanNumerals = true
        recipe.toHalfwidth = .enabled

        let transliterator = try recipe.makeTransliterator()

        // Full-width letters with Roman numerals
        let input = "Ａｐｐｅｎｄｉｘ　\u{2160}" // Full-width "Appendix " + Roman I
        let expected = "Appendix I" // Both converted to half-width ASCII
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testAllRomanNumeralMappings() {
        let transliterator = RomanNumeralsTransliterator()

        // Test all mappings from the data file
        let testCases: [(String, String)] = [
            // Uppercase
            ("\u{2160}", "I"),
            ("\u{2161}", "II"),
            ("\u{2162}", "III"),
            ("\u{2163}", "IV"),
            ("\u{2164}", "V"),
            ("\u{2165}", "VI"),
            ("\u{2166}", "VII"),
            ("\u{2167}", "VIII"),
            ("\u{2168}", "IX"),
            ("\u{2169}", "X"),
            ("\u{216A}", "XI"),
            ("\u{216B}", "XII"),
            ("\u{216C}", "L"),
            ("\u{216D}", "C"),
            ("\u{216E}", "D"),
            ("\u{216F}", "M"),
            // Lowercase
            ("\u{2170}", "i"),
            ("\u{2171}", "ii"),
            ("\u{2172}", "iii"),
            ("\u{2173}", "iv"),
            ("\u{2174}", "v"),
            ("\u{2175}", "vi"),
            ("\u{2176}", "vii"),
            ("\u{2177}", "viii"),
            ("\u{2178}", "ix"),
            ("\u{2179}", "x"),
            ("\u{217A}", "xi"),
            ("\u{217B}", "xii"),
            ("\u{217C}", "l"),
            ("\u{217D}", "c"),
            ("\u{217E}", "d"),
            ("\u{217F}", "m"),
        ]

        for (input, expected) in testCases {
            XCTAssertEqual(transliterator.transliterate(input), expected,
                           "Failed for U+\(String(input.unicodeScalars.first!.value, radix: 16, uppercase: true))")
        }
    }

    func testPerformanceWithLargeText() {
        let transliterator = RomanNumeralsTransliterator()

        // Create a large text with many Roman numerals
        var input = ""
        for _ in 0 ..< 1000 {
            input += "Section \u{2160} Part \u{2165} Chapter \u{2169} "
        }

        measure {
            _ = transliterator.transliterate(input)
        }
    }
}
