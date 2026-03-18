import XCTest
@testable import Yosina

final class HistoricalHirakatasTests: XCTestCase {
    func testSimpleHiraganaDefault() {
        let transliterator = HistoricalHirakatasTransliterator()
        XCTAssertEqual(transliterator.transliterate("ゐゑ"), "いえ")
    }

    func testPassthrough() {
        let transliterator = HistoricalHirakatasTransliterator()
        XCTAssertEqual(transliterator.transliterate("あいう"), "あいう")
    }

    func testMixedInput() {
        let transliterator = HistoricalHirakatasTransliterator()
        XCTAssertEqual(transliterator.transliterate("あゐいゑう"), "あいいえう")
    }

    func testDecomposeHiragana() {
        let transliterator = HistoricalHirakatasTransliterator(
            options: .init(hiraganas: .decompose, katakanas: .skip, voicedKatakanas: .skip)
        )
        XCTAssertEqual(transliterator.transliterate("ゐゑ"), "うぃうぇ")
    }

    func testSkipHiragana() {
        let transliterator = HistoricalHirakatasTransliterator(
            options: .init(hiraganas: .skip, katakanas: .skip, voicedKatakanas: .skip)
        )
        XCTAssertEqual(transliterator.transliterate("ゐゑ"), "ゐゑ")
    }

    func testSimpleKatakanaDefault() {
        let transliterator = HistoricalHirakatasTransliterator()
        XCTAssertEqual(transliterator.transliterate("ヰヱ"), "イエ")
    }

    func testDecomposeKatakana() {
        let transliterator = HistoricalHirakatasTransliterator(
            options: .init(hiraganas: .skip, katakanas: .decompose, voicedKatakanas: .skip)
        )
        XCTAssertEqual(transliterator.transliterate("ヰヱ"), "ウィウェ")
    }

    func testVoicedKatakanaDecompose() {
        let transliterator = HistoricalHirakatasTransliterator(
            options: .init(hiraganas: .skip, katakanas: .skip, voicedKatakanas: .decompose)
        )
        XCTAssertEqual(transliterator.transliterate("ヷヸヹヺ"), "ヴァヴィヴェヴォ")
    }

    func testVoicedKatakanaSkipDefault() {
        let transliterator = HistoricalHirakatasTransliterator(
            options: .init(hiraganas: .skip, katakanas: .skip)
        )
        XCTAssertEqual(transliterator.transliterate("ヷヸヹヺ"), "ヷヸヹヺ")
    }

    func testAllDecompose() {
        let transliterator = HistoricalHirakatasTransliterator(
            options: .init(hiraganas: .decompose, katakanas: .decompose, voicedKatakanas: .decompose)
        )
        XCTAssertEqual(transliterator.transliterate("ゐゑヰヱヷヸヹヺ"), "うぃうぇウィウェヴァヴィヴェヴォ")
    }

    func testAllSkip() {
        let transliterator = HistoricalHirakatasTransliterator(
            options: .init(hiraganas: .skip, katakanas: .skip, voicedKatakanas: .skip)
        )
        XCTAssertEqual(transliterator.transliterate("ゐゑヰヱヷヸヹヺ"), "ゐゑヰヱヷヸヹヺ")
    }

    func testDecomposedVoicedKatakanaDecompose() {
        let transliterator = HistoricalHirakatasTransliterator(
            options: .init(hiraganas: .skip, katakanas: .skip, voicedKatakanas: .decompose)
        )
        XCTAssertEqual(transliterator.transliterate("ワ\u{3099}ヰ\u{3099}ヱ\u{3099}ヲ\u{3099}"), "ウ\u{3099}ァウ\u{3099}ィウ\u{3099}ェウ\u{3099}ォ")
    }

    func testDecomposedVoicedKatakanaSkip() {
        let transliterator = HistoricalHirakatasTransliterator(
            options: .init(hiraganas: .skip, katakanas: .skip, voicedKatakanas: .skip)
        )
        XCTAssertEqual(transliterator.transliterate("ワ\u{3099}ヰ\u{3099}ヱ\u{3099}ヲ\u{3099}"), "ワ\u{3099}ヰ\u{3099}ヱ\u{3099}ヲ\u{3099}")
    }

    func testDecomposedVoicedNotSplitFromBase() {
        let transliterator = HistoricalHirakatasTransliterator(
            options: .init(hiraganas: .skip, katakanas: .simple, voicedKatakanas: .skip)
        )
        // ヰ+゙ should be treated as ヸ (voiced), not as ヰ (katakana) + separate ゙
        XCTAssertEqual(transliterator.transliterate("ヰ\u{3099}"), "ヰ\u{3099}")
    }

    func testDecomposedVoicedWithDecompose() {
        let transliterator = HistoricalHirakatasTransliterator(
            options: .init(hiraganas: .skip, katakanas: .skip, voicedKatakanas: .decompose)
        )
        // ヰ+゙ = ヸ, should produce ウ+゙+ィ (decomposed)
        XCTAssertEqual(transliterator.transliterate("ヰ\u{3099}"), "ウ\u{3099}ィ")
    }

    func testEmptyInput() {
        let transliterator = HistoricalHirakatasTransliterator()
        XCTAssertEqual(transliterator.transliterate(""), "")
    }
}
