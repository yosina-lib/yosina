import XCTest
@testable import Yosina

final class CombinedTests: XCTestCase {
    func testControlCharacters() {
        let transliterator = CombinedTransliterator()

        // null symbol to NUL
        XCTAssertEqual(transliterator.transliterate("␀"), "NUL")

        // start of heading to SOH
        XCTAssertEqual(transliterator.transliterate("␁"), "SOH")

        // start of text to STX
        XCTAssertEqual(transliterator.transliterate("␂"), "STX")

        // backspace to BS
        XCTAssertEqual(transliterator.transliterate("␈"), "BS")

        // horizontal tab to HT
        XCTAssertEqual(transliterator.transliterate("␉"), "HT")

        // carriage return to CR
        XCTAssertEqual(transliterator.transliterate("␍"), "CR")

        // space symbol to SP
        XCTAssertEqual(transliterator.transliterate("␠"), "SP")

        // delete symbol to DEL
        XCTAssertEqual(transliterator.transliterate("␡"), "DEL")
    }

    func testParenthesizedNumbers() {
        let transliterator = CombinedTransliterator()

        // (1) to (1)
        XCTAssertEqual(transliterator.transliterate("⑴"), "(1)")

        // (5) to (5)
        XCTAssertEqual(transliterator.transliterate("⑸"), "(5)")

        // (10) to (10)
        XCTAssertEqual(transliterator.transliterate("⑽"), "(10)")

        // (20) to (20)
        XCTAssertEqual(transliterator.transliterate("⒇"), "(20)")
    }

    func testPeriodNumbers() {
        let transliterator = CombinedTransliterator()

        // 1. to 1.
        XCTAssertEqual(transliterator.transliterate("⒈"), "1.")

        // 10. to 10.
        XCTAssertEqual(transliterator.transliterate("⒑"), "10.")

        // 20. to 20.
        XCTAssertEqual(transliterator.transliterate("⒛"), "20.")
    }

    func testParenthesizedLetters() {
        let transliterator = CombinedTransliterator()

        // (a) to (a)
        XCTAssertEqual(transliterator.transliterate("⒜"), "(a)")

        // (z) to (z)
        XCTAssertEqual(transliterator.transliterate("⒵"), "(z)")
    }

    func testParenthesizedKanji() {
        let transliterator = CombinedTransliterator()

        // (一) to (一)
        XCTAssertEqual(transliterator.transliterate("㈠"), "(一)")

        // (月) to (月)
        XCTAssertEqual(transliterator.transliterate("㈪"), "(月)")

        // (株) to (株)
        XCTAssertEqual(transliterator.transliterate("㈱"), "(株)")
    }

    func testJapaneseUnits() {
        let transliterator = CombinedTransliterator()

        // アパート to アパート
        XCTAssertEqual(transliterator.transliterate("㌀"), "アパート")

        // キロ to キロ
        XCTAssertEqual(transliterator.transliterate("㌔"), "キロ")

        // メートル to メートル
        XCTAssertEqual(transliterator.transliterate("㍍"), "メートル")
    }

    func testScientificUnits() {
        let transliterator = CombinedTransliterator()

        // hPa to hPa
        XCTAssertEqual(transliterator.transliterate("㍱"), "hPa")

        // kHz to kHz
        XCTAssertEqual(transliterator.transliterate("㎑"), "kHz")

        // kg to kg
        XCTAssertEqual(transliterator.transliterate("㎏"), "kg")
    }

    func testMixedContent() {
        let transliterator = CombinedTransliterator()

        // combined control and numbers
        XCTAssertEqual(transliterator.transliterate("␉⑴␠⒈"), "HT(1)SP1.")

        // combined with regular text
        XCTAssertEqual(transliterator.transliterate("Hello ⑴ World ␉"), "Hello (1) World HT")
    }

    func testEmptyString() {
        let transliterator = CombinedTransliterator()

        XCTAssertEqual(transliterator.transliterate(""), "")
    }

    func testUnmappedCharacters() {
        let transliterator = CombinedTransliterator()

        let input = "hello world 123 abc こんにちは"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testSequenceOfCombinedCharacters() {
        let transliterator = CombinedTransliterator()

        let input = "␀␁␂␃␄"
        let expected = "NULSOHSTXETXEOT"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testJapaneseMonths() {
        let transliterator = CombinedTransliterator()

        let input = "㋀㋁㋂"
        let expected = "1月2月3月"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testJapaneseUnitsCombinations() {
        let transliterator = CombinedTransliterator()

        let input = "㌀㌁㌂"
        let expected = "アパートアルファアンペア"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testScientificMeasurements() {
        let transliterator = CombinedTransliterator()

        let input = "\u{3378}\u{3379}\u{337a}"
        let expected = "dm2dm3IU"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }
}
