import XCTest
@testable import Yosina

final class ProlongedSoundMarksTests: XCTestCase {
    func testAfterHiragana() {
        let transliterator = ProlongedSoundMarksTransliterator().stringTransliterator

        // After hiragana, hyphen should convert to prolonged sound mark
        XCTAssertEqual(transliterator.transliterate("あ-"), "あー")
        XCTAssertEqual(transliterator.transliterate("か-"), "かー")
        XCTAssertEqual(transliterator.transliterate("が-"), "がー")
        XCTAssertEqual(transliterator.transliterate("わ-"), "わー")
    }

    func testAfterKatakana() {
        let transliterator = ProlongedSoundMarksTransliterator().stringTransliterator

        // After katakana, hyphen should convert to prolonged sound mark
        XCTAssertEqual(transliterator.transliterate("ア-"), "アー")
        XCTAssertEqual(transliterator.transliterate("カ-"), "カー")
        XCTAssertEqual(transliterator.transliterate("ガ-"), "ガー")
        XCTAssertEqual(transliterator.transliterate("ワ-"), "ワー")
        XCTAssertEqual(transliterator.transliterate("ン-"), "ンー")
    }

    func testAfterHalfwidthKatakana() {
        let transliterator = ProlongedSoundMarksTransliterator().stringTransliterator

        // After halfwidth katakana, should use halfwidth prolonged mark
        XCTAssertEqual(transliterator.transliterate("ｱ-"), "ｱｰ")
        XCTAssertEqual(transliterator.transliterate("ｶ-"), "ｶｰ")
        XCTAssertEqual(transliterator.transliterate("ﾝ-"), "ﾝｰ")
    }

    func testVariousHyphens() {
        let transliterator = ProlongedSoundMarksTransliterator().stringTransliterator

        // Various hyphen characters should all convert
        XCTAssertEqual(transliterator.transliterate("ア-"), "アー") // HYPHEN-MINUS
        XCTAssertEqual(transliterator.transliterate("ア－"), "アー") // FULLWIDTH HYPHEN-MINUS
        XCTAssertEqual(transliterator.transliterate("ア‐"), "アー") // HYPHEN
        XCTAssertEqual(transliterator.transliterate("ア—"), "アー") // EM DASH
        XCTAssertEqual(transliterator.transliterate("ア―"), "アー") // HORIZONTAL BAR
        XCTAssertEqual(transliterator.transliterate("ア−"), "アー") // MINUS SIGN
    }

    func testMultipleHyphens() {
        let transliterator = ProlongedSoundMarksTransliterator().stringTransliterator

        // Multiple hyphens should each convert
        XCTAssertEqual(transliterator.transliterate("ア--"), "アーー")
        XCTAssertEqual(transliterator.transliterate("ア---"), "アーーー")
    }

    func testNoConversionCases() {
        let transliterator = ProlongedSoundMarksTransliterator().stringTransliterator

        // After Latin letters
        XCTAssertEqual(transliterator.transliterate("A-"), "A-")
        XCTAssertEqual(transliterator.transliterate("Hello-World"), "Hello-World")

        // After numbers
        XCTAssertEqual(transliterator.transliterate("123-"), "123-")

        // After symbols
        XCTAssertEqual(transliterator.transliterate("。-"), "。-")
        XCTAssertEqual(transliterator.transliterate("、-"), "、-")

        // At beginning
        XCTAssertEqual(transliterator.transliterate("-ア"), "-ア")

        // After space
        XCTAssertEqual(transliterator.transliterate(" -"), " -")
    }

    func testAfterSmallKana() {
        let transliterator = ProlongedSoundMarksTransliterator().stringTransliterator

        // After small kana
        XCTAssertEqual(transliterator.transliterate("ァ-"), "ァー")
        XCTAssertEqual(transliterator.transliterate("ッ-"), "ッー")
        XCTAssertEqual(transliterator.transliterate("ャ-"), "ャー")
    }

    func testAfterIterationMarks() {
        let transliterator = ProlongedSoundMarksTransliterator().stringTransliterator

        // After iteration marks
        XCTAssertEqual(transliterator.transliterate("ヽ-"), "ヽー")
        XCTAssertEqual(transliterator.transliterate("ヾ-"), "ヾー")
    }

    func testMixedContent() {
        let transliterator = ProlongedSoundMarksTransliterator().stringTransliterator

        XCTAssertEqual(transliterator.transliterate("データ-ベース"), "データーベース")
        XCTAssertEqual(transliterator.transliterate("コンピュータ-の使い方"), "コンピューターの使い方")
        XCTAssertEqual(transliterator.transliterate("A-1とB-2"), "A-1とB-2")
    }
}
