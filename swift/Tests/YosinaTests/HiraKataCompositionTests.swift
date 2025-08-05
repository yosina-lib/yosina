import XCTest
@testable import Yosina

final class HiraKataCompositionTests: XCTestCase {
    func testHiraganaCombiningDakuten() {
        let transliterator = HiraKataCompositionTransliterator()

        // Basic hiragana + combining dakuten
        XCTAssertEqual(transliterator.transliterate("か\u{3099}"), "が")
        XCTAssertEqual(transliterator.transliterate("き\u{3099}"), "ぎ")
        XCTAssertEqual(transliterator.transliterate("く\u{3099}"), "ぐ")
        XCTAssertEqual(transliterator.transliterate("け\u{3099}"), "げ")
        XCTAssertEqual(transliterator.transliterate("こ\u{3099}"), "ご")

        // More hiragana rows
        XCTAssertEqual(transliterator.transliterate("さ\u{3099}"), "ざ")
        XCTAssertEqual(transliterator.transliterate("し\u{3099}"), "じ")
        XCTAssertEqual(transliterator.transliterate("す\u{3099}"), "ず")
        XCTAssertEqual(transliterator.transliterate("せ\u{3099}"), "ぜ")
        XCTAssertEqual(transliterator.transliterate("そ\u{3099}"), "ぞ")

        XCTAssertEqual(transliterator.transliterate("た\u{3099}"), "だ")
        XCTAssertEqual(transliterator.transliterate("ち\u{3099}"), "ぢ")
        XCTAssertEqual(transliterator.transliterate("つ\u{3099}"), "づ")
        XCTAssertEqual(transliterator.transliterate("て\u{3099}"), "で")
        XCTAssertEqual(transliterator.transliterate("と\u{3099}"), "ど")

        XCTAssertEqual(transliterator.transliterate("は\u{3099}"), "ば")
        XCTAssertEqual(transliterator.transliterate("ひ\u{3099}"), "び")
        XCTAssertEqual(transliterator.transliterate("ふ\u{3099}"), "ぶ")
        XCTAssertEqual(transliterator.transliterate("へ\u{3099}"), "べ")
        XCTAssertEqual(transliterator.transliterate("ほ\u{3099}"), "ぼ")

        // Special cases
        XCTAssertEqual(transliterator.transliterate("う\u{3099}"), "ゔ")
        XCTAssertEqual(transliterator.transliterate("ゝ\u{3099}"), "ゞ") // Iteration mark
        XCTAssertEqual(transliterator.transliterate("〱\u{3099}"), "〲") // Vertical hiragana iteration mark
    }

    func testHiraganaCombiningHandakuten() {
        let transliterator = HiraKataCompositionTransliterator()

        // Hiragana + combining handakuten
        XCTAssertEqual(transliterator.transliterate("は\u{309A}"), "ぱ")
        XCTAssertEqual(transliterator.transliterate("ひ\u{309A}"), "ぴ")
        XCTAssertEqual(transliterator.transliterate("ふ\u{309A}"), "ぷ")
        XCTAssertEqual(transliterator.transliterate("へ\u{309A}"), "ぺ")
        XCTAssertEqual(transliterator.transliterate("ほ\u{309A}"), "ぽ")
    }

    func testKatakanaCombining() {
        let transliterator = HiraKataCompositionTransliterator()

        // Katakana + combining dakuten
        XCTAssertEqual(transliterator.transliterate("カ\u{3099}"), "ガ")
        XCTAssertEqual(transliterator.transliterate("キ\u{3099}"), "ギ")
        XCTAssertEqual(transliterator.transliterate("ク\u{3099}"), "グ")
        XCTAssertEqual(transliterator.transliterate("ケ\u{3099}"), "ゲ")
        XCTAssertEqual(transliterator.transliterate("コ\u{3099}"), "ゴ")

        // Special katakana cases
        XCTAssertEqual(transliterator.transliterate("ウ\u{3099}"), "ヴ")
        XCTAssertEqual(transliterator.transliterate("ワ\u{3099}"), "ヷ")
        XCTAssertEqual(transliterator.transliterate("ヰ\u{3099}"), "ヸ")
        XCTAssertEqual(transliterator.transliterate("ヱ\u{3099}"), "ヹ")
        XCTAssertEqual(transliterator.transliterate("ヲ\u{3099}"), "ヺ")
        XCTAssertEqual(transliterator.transliterate("ヽ\u{3099}"), "ヾ") // Katakana iteration mark
        XCTAssertEqual(transliterator.transliterate("〳\u{3099}"), "〴") // Vertical katakana iteration mark

        // Katakana + combining handakuten
        XCTAssertEqual(transliterator.transliterate("ハ\u{309A}"), "パ")
        XCTAssertEqual(transliterator.transliterate("ヒ\u{309A}"), "ピ")
        XCTAssertEqual(transliterator.transliterate("フ\u{309A}"), "プ")
        XCTAssertEqual(transliterator.transliterate("ヘ\u{309A}"), "ペ")
        XCTAssertEqual(transliterator.transliterate("ホ\u{309A}"), "ポ")
    }

    func testMultipleCompositions() {
        let transliterator = HiraKataCompositionTransliterator()

        XCTAssertEqual(transliterator.transliterate("か\u{3099}き\u{3099}く\u{3099}"), "がぎぐ")
        XCTAssertEqual(transliterator.transliterate("は\u{309A}ひ\u{309A}ふ\u{309A}"), "ぱぴぷ")

        // Mixed text
        XCTAssertEqual(transliterator.transliterate("こんにちは\u{304B}\u{3099}世界\u{30AB}\u{3099}"), "こんにちはが世界ガ")
    }

    func testNoComposition() {
        let transliterator = HiraKataCompositionTransliterator()

        // Combining marks without valid base
        XCTAssertEqual(transliterator.transliterate("あ\u{3099}"), "あ\u{3099}")
        XCTAssertEqual(transliterator.transliterate("ん\u{3099}"), "ん\u{3099}")
        XCTAssertEqual(transliterator.transliterate("な\u{309A}"), "な\u{309A}") // な cannot take handakuten

        // Already composed characters
        XCTAssertEqual(transliterator.transliterate("がぎぐ"), "がぎぐ")
        XCTAssertEqual(transliterator.transliterate("ぱぴぷ"), "ぱぴぷ")

        // Marks at the beginning
        XCTAssertEqual(transliterator.transliterate("\u{3099}\u{309A}\u{309B}\u{309C}"), "\u{3099}\u{309A}\u{309B}\u{309C}")
    }

    func testNonCombiningMarks() {
        // With default options (composeNonCombiningMarks = true)
        let transliterator1 = HiraKataCompositionTransliterator()
        XCTAssertEqual(transliterator1.transliterate("か\u{309B}"), "が") // Non-combining dakuten
        XCTAssertEqual(transliterator1.transliterate("は\u{309C}"), "ぱ") // Non-combining handakuten

        // Test vertical iteration marks with non-combining marks
        XCTAssertEqual(transliterator1.transliterate("〱\u{309B}"), "〲") // Vertical hiragana + non-combining dakuten
        XCTAssertEqual(transliterator1.transliterate("〳\u{309B}"), "〴") // Vertical katakana + non-combining dakuten

        // With composeNonCombiningMarks = false
        let options = HiraKataCompositionTransliterator.Options(composeNonCombiningMarks: false)
        let transliterator2 = HiraKataCompositionTransliterator(options: options)
        XCTAssertEqual(transliterator2.transliterate("か\u{309B}"), "か\u{309B}")
        XCTAssertEqual(transliterator2.transliterate("は\u{309C}"), "は\u{309C}")

        // But combining marks should still work
        XCTAssertEqual(transliterator2.transliterate("か\u{3099}"), "が")
        XCTAssertEqual(transliterator2.transliterate("は\u{309A}"), "ぱ")
    }

    func testComplexSequences() {
        let transliterator = HiraKataCompositionTransliterator()

        // Multiple consecutive marks (only first should compose)
        XCTAssertEqual(transliterator.transliterate("か\u{3099}\u{3099}"), "が\u{3099}")

        // Base that can be composed followed by non-composable base
        XCTAssertEqual(transliterator.transliterate("か\u{3042}"), "か\u{3042}") // か followed by あ

        // Empty string
        XCTAssertEqual(transliterator.transliterate(""), "")

        // String with no composable characters
        XCTAssertEqual(transliterator.transliterate("hello world 123"), "hello world 123")
    }
}
