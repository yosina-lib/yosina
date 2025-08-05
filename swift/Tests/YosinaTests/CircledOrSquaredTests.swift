import XCTest
@testable import Yosina

final class CircledOrSquaredTests: XCTestCase {
    func testDefaultBehavior() {
        let transliterator = CircledOrSquaredTransliterator().stringTransliterator

        // Circled numbers
        XCTAssertEqual(transliterator.transliterate("①"), "(1)")
        XCTAssertEqual(transliterator.transliterate("②"), "(2)")
        XCTAssertEqual(transliterator.transliterate("⑳"), "(20)")
        XCTAssertEqual(transliterator.transliterate("⓪"), "(0)")

        // Circled letters
        XCTAssertEqual(transliterator.transliterate("Ⓐ"), "(A)")
        XCTAssertEqual(transliterator.transliterate("Ⓩ"), "(Z)")
        XCTAssertEqual(transliterator.transliterate("ⓐ"), "(a)")
        XCTAssertEqual(transliterator.transliterate("ⓩ"), "(z)")

        // Circled kanji
        XCTAssertEqual(transliterator.transliterate("㊀"), "(一)")
        XCTAssertEqual(transliterator.transliterate("㊊"), "(月)")
        XCTAssertEqual(transliterator.transliterate("㊰"), "(夜)")

        // Circled katakana
        XCTAssertEqual(transliterator.transliterate("㋐"), "(ア)")
        XCTAssertEqual(transliterator.transliterate("㋾"), "(ヲ)")

        // Squared letters
        XCTAssertEqual(transliterator.transliterate("🅰"), "[A]")
        XCTAssertEqual(transliterator.transliterate("🆉"), "[Z]")

        // Regional indicators
        XCTAssertEqual(transliterator.transliterate("🇦"), "[A]")
        XCTAssertEqual(transliterator.transliterate("🇿"), "[Z]")

        // Large circled numbers
        XCTAssertEqual(transliterator.transliterate("㊱"), "(36)")
        XCTAssertEqual(transliterator.transliterate("㊲"), "(37)")
        XCTAssertEqual(transliterator.transliterate("㊳"), "(38)")
        XCTAssertEqual(transliterator.transliterate("㊿"), "(50)")
    }

    func testNoChange() {
        let transliterator = CircledOrSquaredTransliterator().stringTransliterator

        // Regular text should not change
        XCTAssertEqual(transliterator.transliterate("Hello World"), "Hello World")
        XCTAssertEqual(transliterator.transliterate("123"), "123")
        XCTAssertEqual(transliterator.transliterate("あいうえお"), "あいうえお")
    }

    func testMixedContent() {
        let transliterator = CircledOrSquaredTransliterator().stringTransliterator

        XCTAssertEqual(transliterator.transliterate("番号①と②"), "番号(1)と(2)")
        XCTAssertEqual(transliterator.transliterate("Ⓐから始まりⓩで終わる"), "(A)から始まり(z)で終わる")
    }
}
