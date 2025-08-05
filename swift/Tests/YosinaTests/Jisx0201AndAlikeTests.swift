import XCTest
@testable import Yosina

final class Jisx0201AndAlikeTests: XCTestCase {
    func testHalfwidthToFullwidth() {
        let options = Jisx0201AndAlikeTransliterator.Options(fullwidthToHalfwidth: false)
        let transliterator = Jisx0201AndAlikeTransliterator(options: options)

        // ASCII to fullwidth
        XCTAssertEqual(transliterator.transliterate("ABC"), "ＡＢＣ")
        XCTAssertEqual(transliterator.transliterate("123"), "１２３")
        XCTAssertEqual(transliterator.transliterate("!@#"), "！＠＃")

        // Space conversion
        XCTAssertEqual(transliterator.transliterate(" "), "　")

        // Halfwidth katakana to fullwidth
        XCTAssertEqual(transliterator.transliterate("ｱｲｳｴｵ"), "アイウエオ")
        XCTAssertEqual(transliterator.transliterate("ｶｷｸｹｺ"), "カキクケコ")
        XCTAssertEqual(transliterator.transliterate("ｻｼｽｾｿ"), "サシスセソ")
        XCTAssertEqual(transliterator.transliterate("ﾀﾁﾂﾃﾄ"), "タチツテト")
        XCTAssertEqual(transliterator.transliterate("ﾅﾆﾇﾈﾉ"), "ナニヌネノ")
        XCTAssertEqual(transliterator.transliterate("ﾊﾋﾌﾍﾎ"), "ハヒフヘホ")
        XCTAssertEqual(transliterator.transliterate("ﾏﾐﾑﾒﾓ"), "マミムメモ")
        XCTAssertEqual(transliterator.transliterate("ﾔﾕﾖ"), "ヤユヨ")
        XCTAssertEqual(transliterator.transliterate("ﾗﾘﾙﾚﾛ"), "ラリルレロ")
        XCTAssertEqual(transliterator.transliterate("ﾜｦﾝ"), "ワヲン")

        // Small kana
        XCTAssertEqual(transliterator.transliterate("ｧｨｩｪｫ"), "ァィゥェォ")
        XCTAssertEqual(transliterator.transliterate("ｬｭｮｯ"), "ャュョッ")

        // Punctuation
        XCTAssertEqual(transliterator.transliterate("｡｢｣､･"), "。「」、・")
        XCTAssertEqual(transliterator.transliterate("ｰ"), "ー")
    }

    func testHalfwidthToFullwidthWithVoiceMarks() {
        var options = Jisx0201AndAlikeTransliterator.Options()
        options.fullwidthToHalfwidth = false
        options.combineVoicedSoundMarks = true
        let transliterator = Jisx0201AndAlikeTransliterator(options: options)

        // With combining
        XCTAssertEqual(transliterator.transliterate("ｶﾞｷﾞｸﾞｹﾞｺﾞ"), "ガギグゲゴ")
        XCTAssertEqual(transliterator.transliterate("ｻﾞｼﾞｽﾞｾﾞｿﾞ"), "ザジズゼゾ")
        XCTAssertEqual(transliterator.transliterate("ﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞ"), "ダヂヅデド")
        XCTAssertEqual(transliterator.transliterate("ﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞ"), "バビブベボ")
        XCTAssertEqual(transliterator.transliterate("ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ"), "パピプペポ")
        XCTAssertEqual(transliterator.transliterate("ｳﾞ"), "ヴ")
    }

    func testFullwidthToHalfwidth() {
        var options = Jisx0201AndAlikeTransliterator.Options()
        options.fullwidthToHalfwidth = true
        let transliterator = Jisx0201AndAlikeTransliterator(options: options)

        // Fullwidth ASCII to halfwidth
        XCTAssertEqual(transliterator.transliterate("ＡＢＣ"), "ABC")
        XCTAssertEqual(transliterator.transliterate("１２３"), "123")
        XCTAssertEqual(transliterator.transliterate("！＠＃"), "!@#")

        // Fullwidth space
        XCTAssertEqual(transliterator.transliterate("　"), " ")

        // Fullwidth katakana to halfwidth
        XCTAssertEqual(transliterator.transliterate("アイウエオ"), "ｱｲｳｴｵ")
        XCTAssertEqual(transliterator.transliterate("カキクケコ"), "ｶｷｸｹｺ")
        XCTAssertEqual(transliterator.transliterate("ガギグゲゴ"), "ｶﾞｷﾞｸﾞｹﾞｺﾞ")
        XCTAssertEqual(transliterator.transliterate("パピプペポ"), "ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ")
        XCTAssertEqual(transliterator.transliterate("ヴ"), "ｳﾞ")

        // Small kana
        XCTAssertEqual(transliterator.transliterate("ァィゥェォ"), "ｧｨｩｪｫ")
        XCTAssertEqual(transliterator.transliterate("ャュョッ"), "ｬｭｮｯ")
    }

    func testConvertGLGROptions() {
        var options = Jisx0201AndAlikeTransliterator.Options()
        options.fullwidthToHalfwidth = false
        options.convertGL = false
        options.convertGR = true
        let transliterator = Jisx0201AndAlikeTransliterator(options: options)

        // GL (ASCII) should not convert
        XCTAssertEqual(transliterator.transliterate("ABC"), "ABC")
        XCTAssertEqual(transliterator.transliterate("123"), "123")

        // GR (Katakana) should convert
        XCTAssertEqual(transliterator.transliterate("ｱｲｳ"), "アイウ")
    }

    func testHiraganaConversion() {
        var options = Jisx0201AndAlikeTransliterator.Options()
        options.fullwidthToHalfwidth = true
        options.convertHiraganas = true
        let transliterator = Jisx0201AndAlikeTransliterator(options: options)

        // Hiragana should convert to halfwidth katakana
        XCTAssertEqual(transliterator.transliterate("あいうえお"), "ｱｲｳｴｵ")
        XCTAssertEqual(transliterator.transliterate("かきくけこ"), "ｶｷｸｹｺ")
    }

    func testBackslashYenHandling() {
        var options = Jisx0201AndAlikeTransliterator.Options()
        options.fullwidthToHalfwidth = false
        options.u005cAsYenSign = true
        let transliterator = Jisx0201AndAlikeTransliterator(options: options)

        // Backslash should become fullwidth yen
        XCTAssertEqual(transliterator.transliterate("\\"), "￥")
    }

    func testUnsafeSpecials() {
        var options = Jisx0201AndAlikeTransliterator.Options()
        options.fullwidthToHalfwidth = true
        // convertUnsafeSpecials defaults to true for forward direction
        let transliterator = Jisx0201AndAlikeTransliterator(options: options)

        XCTAssertEqual(transliterator.transliterate("゠"), "=")
    }

    func testTildeOverrides() {
        var options = Jisx0201AndAlikeTransliterator.Options()
        options.fullwidthToHalfwidth = true
        options.u007eAsWaveDash = true
        let transliterator = Jisx0201AndAlikeTransliterator(options: options)

        XCTAssertEqual(transliterator.transliterate("〜"), "~")

        options.u007eAsWaveDash = false
        options.u007eAsFullwidthTilde = true
        let transliterator2 = Jisx0201AndAlikeTransliterator(options: options)
        XCTAssertEqual(transliterator2.transliterate("～"), "~")
    }

    func testMixedContent() {
        var options = Jisx0201AndAlikeTransliterator.Options()
        options.fullwidthToHalfwidth = true
        let transliterator = Jisx0201AndAlikeTransliterator(options: options)

        XCTAssertEqual(transliterator.transliterate("Ｈｅｌｌｏ　世界！　カタカナ　１２３"), "Hello 世界! ｶﾀｶﾅ 123")
    }
}
