import XCTest
@testable import Yosina

final class HyphensTests: XCTestCase {
    func testDefaultBehavior() {
        // Default precedence should be jisx0208_90
        let transliterator = HyphensTransliterator()

        // Hyphen-minus should convert to minus sign
        XCTAssertEqual(transliterator.transliterate("-"), "\u{2212}") // MINUS SIGN

        // Other conversions
        XCTAssertEqual(transliterator.transliterate("~"), "\u{301C}") // WAVE DASH
        XCTAssertEqual(transliterator.transliterate("|"), "\u{FF5C}") // FULLWIDTH VERTICAL LINE
        XCTAssertEqual(transliterator.transliterate("\u{00A6}"), "\u{FF5C}") // Broken bar to fullwidth vertical line
    }

    func testAsciiPrecedence() {
        var options = HyphensTransliterator.Options()
        options.precedence = [.ascii]
        let transliterator = HyphensTransliterator(options: options)

        // With ASCII precedence, hyphen-minus stays the same
        XCTAssertEqual(transliterator.transliterate("-"), "-")
        XCTAssertEqual(transliterator.transliterate("~"), "~")
    }

    func testJisx0201Precedence() {
        var options = HyphensTransliterator.Options()
        options.precedence = [.jisx0201]
        let transliterator = HyphensTransliterator(options: options)

        // With JIS X 0201 precedence
        XCTAssertEqual(transliterator.transliterate("-"), "-")
        XCTAssertEqual(transliterator.transliterate("~"), "~")
        XCTAssertEqual(transliterator.transliterate("\u{203E}"), "~") // OVERLINE → ~
        XCTAssertEqual(transliterator.transliterate("\u{30FB}"), "\u{FF65}") // KATAKANA MIDDLE DOT → HALFWIDTH
    }

    func testMultiplePrecedence() {
        // Try ASCII first, then fall back to jisx0208_90
        var options = HyphensTransliterator.Options()
        options.precedence = [.ascii, .jisx0208_90]
        let transliterator = HyphensTransliterator(options: options)

        XCTAssertEqual(transliterator.transliterate("-"), "-") // ASCII has it
        XCTAssertEqual(transliterator.transliterate("\u{2013}"), "-") // EN DASH → ASCII hyphen
        XCTAssertEqual(transliterator.transliterate("\u{2014}"), "-") // EM DASH → ASCII hyphen
        XCTAssertEqual(transliterator.transliterate("\u{00A2}"), "\u{00A2}") // CENT SIGN (no ASCII mapping)
    }

    func testVariousHyphens() {
        let transliterator = HyphensTransliterator()

        // Various dash characters with jisx0208_90 precedence
        XCTAssertEqual(transliterator.transliterate("\u{2010}"), "\u{2010}") // HYPHEN stays same
        XCTAssertEqual(transliterator.transliterate("\u{2011}"), "\u{2010}") // NON-BREAKING HYPHEN → HYPHEN
        XCTAssertEqual(transliterator.transliterate("\u{2013}"), "\u{2015}") // EN DASH → HORIZONTAL BAR
        XCTAssertEqual(transliterator.transliterate("\u{2014}"), "\u{2014}") // EM DASH stays same in jisx0208_90
        XCTAssertEqual(transliterator.transliterate("\u{2015}"), "\u{2015}") // HORIZONTAL BAR stays same
        XCTAssertEqual(transliterator.transliterate("\u{2212}"), "\u{2212}") // MINUS SIGN stays same
    }

    func testNoChange() {
        let transliterator = HyphensTransliterator()

        // Regular text should not change
        XCTAssertEqual(transliterator.transliterate("Hello World"), "Hello World")
        XCTAssertEqual(transliterator.transliterate("123"), "123")
        XCTAssertEqual(transliterator.transliterate("あいうえお"), "あいうえお")
    }

    func testJisx0208_90_windowsPrecedence() {
        var options = HyphensTransliterator.Options()
        options.precedence = [.jisx0208_90_windows]
        let transliterator = HyphensTransliterator(options: options)

        // Test Windows-specific mappings
        XCTAssertEqual(transliterator.transliterate("~"), "\u{FF5E}") // WAVE DASH → FULLWIDTH TILDE
        XCTAssertEqual(transliterator.transliterate("\u{00A2}"), "\u{FFE0}") // CENT SIGN → FULLWIDTH CENT
        XCTAssertEqual(transliterator.transliterate("\u{00A3}"), "\u{FFE1}") // POUND SIGN → FULLWIDTH POUND
        XCTAssertEqual(transliterator.transliterate("\u{2014}"), "\u{2015}") // EM DASH → HORIZONTAL BAR
        XCTAssertEqual(transliterator.transliterate("\u{2016}"), "\u{2225}") // DOUBLE VERTICAL LINE → PARALLEL TO
    }

    func testMultiCharacterReplacements() {
        let transliterator = HyphensTransliterator()

        // Test TWO-EM DASH and THREE-EM DASH
        XCTAssertEqual(transliterator.transliterate("\u{2E3A}"), "\u{2014}\u{2014}") // TWO-EM DASH
        XCTAssertEqual(transliterator.transliterate("\u{2E3B}"), "\u{2014}\u{2014}\u{2014}") // THREE-EM DASH
    }

    func testJapaneseSpecificCharacters() {
        let transliterator = HyphensTransliterator()

        // Test Japanese-specific characters
        XCTAssertEqual(transliterator.transliterate("\u{30A0}"), "\u{FF1D}") // KATAKANA-HIRAGANA DOUBLE HYPHEN → FULLWIDTH EQUALS
        XCTAssertEqual(transliterator.transliterate("\u{30FB}"), "\u{30FB}") // KATAKANA MIDDLE DOT stays same
        XCTAssertEqual(transliterator.transliterate("\u{30FC}"), "\u{30FC}") // PROLONGED SOUND MARK stays same
        XCTAssertEqual(transliterator.transliterate("\u{FF70}"), "\u{30FC}") // HALFWIDTH PROLONGED → FULLWIDTH
    }
}
