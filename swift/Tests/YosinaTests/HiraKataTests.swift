import XCTest
@testable import Yosina

final class HiraKataTests: XCTestCase {
    func testHiraToKataBasic() {
        let transliterator = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .hiraToKata))

        XCTAssertEqual(transliterator.transliterate("あいうえお"), "アイウエオ")
        XCTAssertEqual(transliterator.transliterate("がぎぐげご"), "ガギグゲゴ")
        XCTAssertEqual(transliterator.transliterate("ぱぴぷぺぽ"), "パピプペポ")
    }

    func testHiraToKataSmallCharacters() {
        let transliterator = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .hiraToKata))

        XCTAssertEqual(transliterator.transliterate("ぁぃぅぇぉっゃゅょ"), "ァィゥェォッャュョ")
        XCTAssertEqual(transliterator.transliterate("ゎゕゖ"), "ヮヵヶ")
    }

    func testHiraToKataMixedText() {
        let transliterator = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .hiraToKata))

        XCTAssertEqual(transliterator.transliterate("あいうえお123ABCアイウエオ"), "アイウエオ123ABCアイウエオ")
        XCTAssertEqual(transliterator.transliterate("こんにちは、世界！"), "コンニチハ、世界！")
    }

    func testHiraToKataAllCharacters() {
        let transliterator = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .hiraToKata))

        let input = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゔ"
        let expected = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴ"

        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHiraToKataWiWe() {
        let transliterator = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .hiraToKata))

        XCTAssertEqual(transliterator.transliterate("ゐゑ"), "ヰヱ")
    }

    func testKataToHiraBasic() {
        let transliterator = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .kataToHira))

        XCTAssertEqual(transliterator.transliterate("アイウエオ"), "あいうえお")
        XCTAssertEqual(transliterator.transliterate("ガギグゲゴ"), "がぎぐげご")
        XCTAssertEqual(transliterator.transliterate("パピプペポ"), "ぱぴぷぺぽ")
    }

    func testKataToHiraSmallCharacters() {
        let transliterator = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .kataToHira))

        XCTAssertEqual(transliterator.transliterate("ァィゥェォッャュョ"), "ぁぃぅぇぉっゃゅょ")
        XCTAssertEqual(transliterator.transliterate("ヮヵヶ"), "ゎゕゖ")
    }

    func testKataToHiraMixedText() {
        let transliterator = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .kataToHira))

        XCTAssertEqual(transliterator.transliterate("アイウエオ123ABCあいうえお"), "あいうえお123ABCあいうえお")
        XCTAssertEqual(transliterator.transliterate("コンニチハ、世界！"), "こんにちは、世界！")
    }

    func testKataToHiraVu() {
        let transliterator = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .kataToHira))

        XCTAssertEqual(transliterator.transliterate("ヴ"), "ゔ")
    }

    func testKataToHiraSpecialKatakana() {
        let transliterator = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .kataToHira))

        // Special katakana without hiragana equivalents should remain unchanged
        XCTAssertEqual(transliterator.transliterate("ヷヸヹヺ"), "ヷヸヹヺ")
    }

    func testKataToHiraAllCharacters() {
        let transliterator = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .kataToHira))

        let input = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴ"
        let expected = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゔ"

        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testKataToHiraWiWe() {
        let transliterator = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .kataToHira))

        XCTAssertEqual(transliterator.transliterate("ヰヱ"), "ゐゑ")
    }

    func testDefaultMode() {
        // Test that default mode is hiraToKata
        let transliterator = HiraKataTransliterator()

        XCTAssertEqual(transliterator.transliterate("あいうえお"), "アイウエオ")
    }

    func testCachingBehavior() {
        // First transliterator builds the cache
        let transliterator1 = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .hiraToKata))
        XCTAssertEqual(transliterator1.transliterate("あいうえお"), "アイウエオ")

        // Second transliterator should use cached table
        let transliterator2 = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .hiraToKata))
        XCTAssertEqual(transliterator2.transliterate("かきくけこ"), "カキクケコ")

        // Test kata to hira mode caching
        let transliterator3 = HiraKataTransliterator(options: HiraKataTransliterator.Options(mode: .kataToHira))
        XCTAssertEqual(transliterator3.transliterate("アイウエオ"), "あいうえお")
    }

    func testYosinaIntegration() {
        // Test that the transliterator can be created via Yosina API
        var config: [TransliteratorConfig] = []
        config.append(.hiraKata(options: HiraKataTransliterator.Options(mode: .hiraToKata)))

        XCTAssertEqual(TransliteratorConfigsWrapper(config).makeTransliterator().transliterate("あいうえお"), "アイウエオ")
    }
}
