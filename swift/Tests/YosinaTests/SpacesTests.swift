import XCTest
@testable import Yosina

final class SpacesTests: XCTestCase {
    func testDictionaryCreation() {
        // Test if we can create the dictionary directly
        let testMapping: [Character: Character?] = [
            "\u{00A0}": "\u{0020}",
            "\u{180E}": nil,
            "\u{2000}": "\u{0020}",
        ]
        XCTAssertEqual(testMapping.count, 3)
    }

    func testCreateSpacesTransliterator() {
        // Test if we can create the transliterator
        let transliterator = SpacesTransliterator()
        XCTAssertNotNil(transliterator)
    }

    func testCallTransliterate() {
        // Test if we can call transliterate
        let transliterator = SpacesTransliterator()
        let result = transliterator.transliterate("Hello")
        XCTAssertEqual(result, "Hello")
    }

    func testCharacterLiterals() {
        // Test the issue with Character literals
        let dict1: [Character: Character?] = [
            "A": "B", // This might work or fail
            "C": nil,
        ]
        XCTAssertEqual(dict1.count, 2)

        // Explicit Character literals
        let dict2: [Character: Character?] = [
            Character("A"): Character("B"),
            Character("C"): nil,
        ]
        XCTAssertEqual(dict2.count, 2)
    }

    func testBasicSpaceReplacements() {
        let transliterator = SpacesTransliterator()

        // Non-breaking space (U+00A0) to regular space
        XCTAssertEqual(transliterator.transliterate("\u{00A0}"), " ")

        // Various Unicode spaces to regular space
        XCTAssertEqual(transliterator.transliterate("\u{2000}"), " ") // En quad
        XCTAssertEqual(transliterator.transliterate("\u{2001}"), " ") // Em quad
        XCTAssertEqual(transliterator.transliterate("\u{2002}"), " ") // En space
        XCTAssertEqual(transliterator.transliterate("\u{2003}"), " ") // Em space
        XCTAssertEqual(transliterator.transliterate("\u{2004}"), " ") // Three-per-em space
        XCTAssertEqual(transliterator.transliterate("\u{2005}"), " ") // Four-per-em space
        XCTAssertEqual(transliterator.transliterate("\u{2006}"), " ") // Six-per-em space
        XCTAssertEqual(transliterator.transliterate("\u{2007}"), " ") // Figure space
        XCTAssertEqual(transliterator.transliterate("\u{2008}"), " ") // Punctuation space
        XCTAssertEqual(transliterator.transliterate("\u{2009}"), " ") // Thin space
        XCTAssertEqual(transliterator.transliterate("\u{200A}"), " ") // Hair space
        XCTAssertEqual(transliterator.transliterate("\u{200B}"), " ") // Zero width space
        XCTAssertEqual(transliterator.transliterate("\u{202F}"), " ") // Narrow no-break space
        XCTAssertEqual(transliterator.transliterate("\u{205F}"), " ") // Medium mathematical space
        XCTAssertEqual(transliterator.transliterate("\u{3000}"), " ") // Ideographic space (full-width space)
        XCTAssertEqual(transliterator.transliterate("\u{3164}"), " ") // Hangul filler
        XCTAssertEqual(transliterator.transliterate("\u{FFA0}"), " ") // Halfwidth hangul filler
    }

    func testSpacesRemovedCompletely() {
        let transliterator = SpacesTransliterator()

        // Mongolian vowel separator (U+180E) should be removed
        XCTAssertEqual(transliterator.transliterate("\u{180E}"), "")

        // Zero-width no-break space (BOM) (U+FEFF) should be removed
        XCTAssertEqual(transliterator.transliterate("\u{FEFF}"), "")
    }

    func testMixedContent() {
        let transliterator = SpacesTransliterator()

        // Text with various spaces
        let input = "Hello\u{3000}World\u{00A0}!\u{2003}Test"
        let expected = "Hello World ! Test"
        XCTAssertEqual(transliterator.transliterate(input), expected)

        // Text with removable spaces
        let input2 = "\u{FEFF}Start\u{180E}Middle\u{FEFF}End"
        let expected2 = "StartMiddleEnd"
        XCTAssertEqual(transliterator.transliterate(input2), expected2)
    }

    func testRegularSpacesUnchanged() {
        let transliterator = SpacesTransliterator()

        // Regular ASCII space should remain unchanged
        XCTAssertEqual(transliterator.transliterate(" "), " ")
        XCTAssertEqual(transliterator.transliterate("Hello World"), "Hello World")
    }

    func testEmptyString() {
        let transliterator = SpacesTransliterator()

        XCTAssertEqual(transliterator.transliterate(""), "")
    }

    func testConsecutiveSpaces() {
        let transliterator = SpacesTransliterator()

        // Multiple different Unicode spaces in a row
        let input = "\u{3000}\u{00A0}\u{2003}\u{200B}"
        let expected = "    " // Four regular spaces
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testJapaneseTextWithIdeographicSpace() {
        let transliterator = SpacesTransliterator()

        // Common pattern in Japanese text
        let input = "東京\u{3000}大阪"
        let expected = "東京 大阪"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testCompleteUnicodeSpaceSet() {
        let transliterator = SpacesTransliterator()

        // Test all spaces mentioned in the Rust implementation
        let testCases: [(String, String)] = [
            ("\u{00A0}", " "), // NO-BREAK SPACE
            ("\u{180E}", ""), // MONGOLIAN VOWEL SEPARATOR (removed)
            ("\u{2000}", " "), // EN QUAD
            ("\u{2001}", " "), // EM QUAD
            ("\u{2002}", " "), // EN SPACE
            ("\u{2003}", " "), // EM SPACE
            ("\u{2004}", " "), // THREE-PER-EM SPACE
            ("\u{2005}", " "), // FOUR-PER-EM SPACE
            ("\u{2006}", " "), // SIX-PER-EM SPACE
            ("\u{2007}", " "), // FIGURE SPACE
            ("\u{2008}", " "), // PUNCTUATION SPACE
            ("\u{2009}", " "), // THIN SPACE
            ("\u{200A}", " "), // HAIR SPACE
            ("\u{200B}", " "), // ZERO WIDTH SPACE
            ("\u{202F}", " "), // NARROW NO-BREAK SPACE
            ("\u{205F}", " "), // MEDIUM MATHEMATICAL SPACE
            ("\u{3000}", " "), // IDEOGRAPHIC SPACE
            ("\u{3164}", " "), // HANGUL FILLER
            ("\u{FEFF}", ""), // ZERO WIDTH NO-BREAK SPACE (removed)
            ("\u{FFA0}", " "), // HALFWIDTH HANGUL FILLER
        ]

        for (input, expected) in testCases {
            XCTAssertEqual(transliterator.transliterate(input), expected,
                           "Failed for U+\(String(input.unicodeScalars.first!.value, radix: 16, uppercase: true))")
        }
    }

    func testPerformanceWithLargeText() {
        let transliterator = SpacesTransliterator()

        // Create a large text with many different spaces
        var input = ""
        for _ in 0 ..< 1000 {
            input += "Text\u{3000}with\u{00A0}various\u{2003}spaces\u{200B}"
        }

        measure {
            _ = transliterator.transliterate(input)
        }
    }
}
