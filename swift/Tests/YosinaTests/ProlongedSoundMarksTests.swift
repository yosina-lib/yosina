import XCTest
@testable import Yosina

final class ProlongedSoundMarksTests: XCTestCase {
    func testFullwidthHyphenMinusToProlongedSoundMark() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "イ\u{ff0d}ハト\u{ff0d}ヴォ"
        let expected = "イ\u{30fc}ハト\u{30fc}ヴォ"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testFullwidthHyphenMinusAtEndOfWord() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "カトラリ\u{ff0d}"
        let expected = "カトラリ\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testAsciiHyphenMinusToProlongedSoundMark() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "イ\u{002d}ハト\u{002d}ヴォ"
        let expected = "イ\u{30fc}ハト\u{30fc}ヴォ"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testAsciiHyphenMinusAtEndOfWord() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "カトラリ\u{002d}"
        let expected = "カトラリ\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testDontReplaceBetweenProlongedSoundMarks() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "1\u{30fc}\u{ff0d}2\u{30fc}3"
        let expected = "1\u{30fc}\u{ff0d}2\u{30fc}3"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testReplaceProlongedMarksBetweenAlphanumerics() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: false,
            allowProlongedSokuon: false,
            replaceProlongedMarksFollowingAlnums: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "1\u{30fc}\u{ff0d}2\u{30fc}3"
        let expected = "1\u{002d}\u{002d}2\u{002d}3"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testReplaceProlongedMarksBetweenFullwidthAlphanumerics() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: false,
            allowProlongedSokuon: false,
            replaceProlongedMarksFollowingAlnums: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "\u{ff11}\u{30fc}\u{ff0d}\u{ff12}\u{30fc}\u{ff13}"
        let expected = "\u{ff11}\u{ff0d}\u{ff0d}\u{ff12}\u{ff0d}\u{ff13}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testDontProlongSokuonByDefault() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ウッ\u{ff0d}ウン\u{ff0d}"
        let expected = "ウッ\u{ff0d}ウン\u{ff0d}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testAllowProlongedSokuon() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: false,
            allowProlongedSokuon: true,
            replaceProlongedMarksFollowingAlnums: false
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "ウッ\u{ff0d}ウン\u{ff0d}"
        let expected = "ウッ\u{30fc}ウン\u{ff0d}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testAllowProlongedHatsuon() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: true,
            allowProlongedSokuon: false,
            replaceProlongedMarksFollowingAlnums: false
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "ウッ\u{ff0d}ウン\u{ff0d}"
        let expected = "ウッ\u{ff0d}ウン\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testAllowBothProlongedSokuonAndHatsuon() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: true,
            allowProlongedSokuon: true,
            replaceProlongedMarksFollowingAlnums: false
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "ウッ\u{ff0d}ウン\u{ff0d}"
        let expected = "ウッ\u{30fc}ウン\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testEmptyString() {
        let transliterator = ProlongedSoundMarksTransliterator()
        XCTAssertEqual(transliterator.transliterate(""), "")
    }

    func testStringWithNoHyphens() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "こんにちは世界"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testMixedHiraganaAndKatakanaWithHyphens() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "あいう\u{002d}かきく\u{ff0d}"
        let expected = "あいう\u{30fc}かきく\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHalfwidthKatakanaWithHyphen() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ｱｲｳ\u{002d}"
        let expected = "ｱｲｳ\u{ff70}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHalfwidthKatakanaWithFullwidthHyphen() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ｱｲｳ\u{ff0d}"
        let expected = "ｱｲｳ\u{ff70}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHyphenAfterNonJapaneseCharacter() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ABC\u{002d}123\u{ff0d}"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testMultipleHyphensInSequence() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ア\u{002d}\u{002d}\u{002d}イ"
        let expected = "ア\u{30fc}\u{30fc}\u{30fc}イ"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testVariousHyphenTypes() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ア\u{002d}イ\u{2010}ウ\u{2014}エ\u{2015}オ\u{2212}カ\u{ff0d}"
        let expected = "ア\u{30fc}イ\u{30fc}ウ\u{30fc}エ\u{30fc}オ\u{30fc}カ\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testProlongedSoundMarkRemainsUnchanged1() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ア\u{30fc}Ａ\u{ff70}Ｂ"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testProlongedSoundMarkRemainsUnchanged2() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ア\u{30fc}ン\u{ff70}ウ"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testMixedAlphanumericAndJapaneseWithReplaceOption() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: false,
            allowProlongedSokuon: false,
            replaceProlongedMarksFollowingAlnums: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "A\u{30fc}B\u{ff0d}アイウ\u{002d}123\u{30fc}"
        let expected = "A\u{002d}B\u{002d}アイウ\u{30fc}123\u{002d}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHiraganaSokuonWithHyphen() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "あっ\u{002d}"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testHiraganaSokuonWithHyphenAndAllowProlongedSokuon() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: false,
            allowProlongedSokuon: true,
            replaceProlongedMarksFollowingAlnums: false
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "あっ\u{002d}"
        let expected = "あっ\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHiraganaHatsuonWithHyphen() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "あん\u{002d}"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testHiraganaHatsuonWithHyphenAndAllowProlongedHatsuon() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: true,
            allowProlongedSokuon: false,
            replaceProlongedMarksFollowingAlnums: false
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "あん\u{002d}"
        let expected = "あん\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHalfwidthKatakanaSokuonWithHyphen() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ｳｯ\u{002d}"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testHalfwidthKatakanaSokuonWithHyphenAndAllowProlongedSokuon() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: false,
            allowProlongedSokuon: true,
            replaceProlongedMarksFollowingAlnums: false
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "ｳｯ\u{002d}"
        let expected = "ｳｯ\u{ff70}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHalfwidthKatakanaHatsuonWithHyphen() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ｳﾝ\u{002d}"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testHalfwidthKatakanaHatsuonWithHyphenAndAllowProlongedHatsuon() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: true,
            allowProlongedSokuon: false,
            replaceProlongedMarksFollowingAlnums: false
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "ｳﾝ\u{002d}"
        let expected = "ｳﾝ\u{ff70}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHyphenAtStartOfString() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "\u{002d}アイウ"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testOnlyHyphens() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "\u{002d}\u{ff0d}\u{2010}\u{2014}\u{2015}\u{2212}"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testNewlineAndTabCharacters() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ア\n\u{002d}\tイ\u{ff0d}"
        let expected = "ア\n\u{002d}\tイ\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testEmojiWithHyphens() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "😀\u{002d}😊\u{ff0d}"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testUnicodeSurrogates() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "\u{1f600}ア\u{002d}\u{1f601}イ\u{ff0d}"
        let expected = "\u{1f600}ア\u{30fc}\u{1f601}イ\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHyphenBetweenDifferentCharacterTypes() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "あ\u{002d}ア\u{002d}A\u{002d}1\u{002d}ａ\u{002d}１"
        let expected = "あ\u{30fc}ア\u{30fc}A\u{002d}1\u{002d}ａ\u{002d}１"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHyphenBetweenDifferentCharacterTypesWithReplaceOption() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: false,
            allowProlongedSokuon: false,
            replaceProlongedMarksFollowingAlnums: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "A\u{002d}1\u{30fc}ａ\u{ff70}１"
        let expected = "A\u{002d}1\u{002d}ａ\u{ff0d}１"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testSkipAlreadyTransliteratedCharsOption() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: true,
            allowProlongedHatsuon: false,
            allowProlongedSokuon: false,
            replaceProlongedMarksFollowingAlnums: false
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "ア\u{002d}イ\u{ff0d}"
        let expected = "ア\u{30fc}イ\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHiraganaVowelEndedCharacters() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "あ\u{002d}か\u{002d}さ\u{002d}た\u{002d}な\u{002d}は\u{002d}ま\u{002d}や\u{002d}ら\u{002d}わ\u{002d}"
        let expected = "あ\u{30fc}か\u{30fc}さ\u{30fc}た\u{30fc}な\u{30fc}は\u{30fc}ま\u{30fc}や\u{30fc}ら\u{30fc}わ\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testKatakanaVowelEndedCharacters() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ア\u{002d}カ\u{002d}サ\u{002d}タ\u{002d}ナ\u{002d}ハ\u{002d}マ\u{002d}ヤ\u{002d}ラ\u{002d}ワ\u{002d}"
        let expected = "ア\u{30fc}カ\u{30fc}サ\u{30fc}タ\u{30fc}ナ\u{30fc}ハ\u{30fc}マ\u{30fc}ヤ\u{30fc}ラ\u{30fc}ワ\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testHalfwidthKatakanaVowelEndedCharacters() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ｱ\u{002d}ｶ\u{002d}ｻ\u{002d}ﾀ\u{002d}ﾅ\u{002d}ﾊ\u{002d}ﾏ\u{002d}ﾔ\u{002d}ﾗ\u{002d}ﾜ\u{002d}"
        let expected = "ｱ\u{ff70}ｶ\u{ff70}ｻ\u{ff70}ﾀ\u{ff70}ﾅ\u{ff70}ﾊ\u{ff70}ﾏ\u{ff70}ﾔ\u{ff70}ﾗ\u{ff70}ﾜ\u{ff70}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testDigitsWithHyphens() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "0\u{002d}1\u{002d}2\u{002d}3\u{002d}4\u{002d}5\u{002d}6\u{002d}7\u{002d}8\u{002d}9\u{002d}"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testFullwidthDigitsWithHyphens() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "０\u{002d}１\u{002d}２\u{002d}３\u{002d}４\u{002d}５\u{002d}６\u{002d}７\u{002d}８\u{002d}９\u{002d}"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testFullwidthDigitsWithHyphensWithOptions() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: false,
            allowProlongedSokuon: false,
            replaceProlongedMarksFollowingAlnums: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "０\u{002d}１\u{002d}２\u{002d}３\u{002d}４\u{002d}５\u{002d}６\u{002d}７\u{002d}８\u{002d}９\u{002d}"
        let expected = "０\u{ff0d}１\u{ff0d}２\u{ff0d}３\u{ff0d}４\u{ff0d}５\u{ff0d}６\u{ff0d}７\u{ff0d}８\u{ff0d}９\u{ff0d}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testAlphabetWithHyphens() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "A\u{002d}B\u{002d}C\u{002d}a\u{002d}b\u{002d}c\u{002d}"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testAlphabetWithHyphensWithOptions() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: false,
            allowProlongedSokuon: false,
            replaceProlongedMarksFollowingAlnums: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "A\u{002d}B\u{002d}C\u{002d}a\u{002d}b\u{002d}c\u{002d}"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testFullwidthAlphabetWithHyphens() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "Ａ\u{002d}Ｂ\u{002d}Ｃ\u{002d}ａ\u{002d}ｂ\u{002d}ｃ\u{002d}"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testFullwidthAlphabetWithHyphensWithOptions() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: false,
            allowProlongedSokuon: false,
            replaceProlongedMarksFollowingAlnums: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "Ａ\u{002d}Ｂ\u{002d}Ｃ\u{002d}ａ\u{002d}ｂ\u{002d}ｃ\u{002d}"
        let expected = "Ａ\u{ff0d}Ｂ\u{ff0d}Ｃ\u{ff0d}ａ\u{ff0d}ｂ\u{ff0d}ｃ\u{ff0d}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    // Additional parameterized test cases
    func testConsecutiveProlongedMarksWithAlphanumerics() {
        let options = ProlongedSoundMarksTransliterator.Options(
            skipAlreadyTransliteratedChars: false,
            allowProlongedHatsuon: false,
            allowProlongedSokuon: false,
            replaceProlongedMarksFollowingAlnums: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "A\u{30fc}\u{30fc}\u{30fc}B"
        let expected = "A\u{002d}\u{002d}\u{002d}B"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testMixedWidthCharactersMaintainConsistency() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ｱ\u{ff0d}ア\u{002d}"
        let expected = "ｱ\u{ff70}ア\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testProlongedMarkFollowedByHyphen() {
        let transliterator = ProlongedSoundMarksTransliterator()
        let input = "ア\u{30fc}\u{002d}"
        let expected = "ア\u{30fc}\u{30fc}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    // MARK: - replaceProlongedMarksBetweenNonKanas tests

    func testReplaceProlongedMarksBetweenNonKanasOtherChars() {
        let options = ProlongedSoundMarksTransliterator.Options(
            replaceProlongedMarksBetweenNonKanas: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "漢\u{30fc}字"
        let expected = "漢\u{ff0d}字"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testReplaceProlongedMarksBetweenHalfwidthAlnums() {
        let options = ProlongedSoundMarksTransliterator.Options(
            replaceProlongedMarksBetweenNonKanas: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "1\u{30fc}2"
        let expected = "1\u{002d}2"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testReplaceProlongedMarksBetweenFullwidthAlnums() {
        let options = ProlongedSoundMarksTransliterator.Options(
            replaceProlongedMarksBetweenNonKanas: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "１\u{30fc}２"
        let expected = "１\u{ff0d}２"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testReplaceProlongedMarksAfterKanaNotReplaced() {
        let options = ProlongedSoundMarksTransliterator.Options(
            replaceProlongedMarksBetweenNonKanas: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "カ\u{30fc}漢"
        let expected = "カ\u{30fc}漢"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testReplaceProlongedMarksBeforeKanaNotReplaced() {
        let options = ProlongedSoundMarksTransliterator.Options(
            replaceProlongedMarksBetweenNonKanas: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "漢\u{30fc}カ"
        let expected = "漢\u{30fc}カ"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testConsecutiveProlongedMarksBetweenNonKanas() {
        let options = ProlongedSoundMarksTransliterator.Options(
            replaceProlongedMarksBetweenNonKanas: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "漢\u{30fc}\u{30fc}\u{30fc}字"
        let expected = "漢\u{ff0d}\u{ff0d}\u{ff0d}字"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testConsecutiveProlongedMarksBeforeKanaNotReplaced() {
        let options = ProlongedSoundMarksTransliterator.Options(
            replaceProlongedMarksBetweenNonKanas: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "漢\u{30fc}\u{30fc}\u{30fc}カ"
        let expected = "漢\u{30fc}\u{30fc}\u{30fc}カ"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testTrailingProlongedMarksAfterFullwidthNonKana() {
        let options = ProlongedSoundMarksTransliterator.Options(
            replaceProlongedMarksBetweenNonKanas: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "漢\u{30fc}\u{30fc}\u{30fc}"
        let expected = "漢\u{ff0d}\u{ff0d}\u{ff0d}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testTrailingProlongedMarksAfterHalfwidthNonKana() {
        let options = ProlongedSoundMarksTransliterator.Options(
            replaceProlongedMarksBetweenNonKanas: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "1\u{30fc}\u{30fc}\u{30fc}"
        let expected = "1\u{002d}\u{002d}\u{002d}"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testNonKanaOnlyProlongedMarkAfterAlnumBeforeKana() {
        let options = ProlongedSoundMarksTransliterator.Options(
            replaceProlongedMarksBetweenNonKanas: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "A\u{30fc}カ"
        let expected = "A\u{30fc}カ"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }

    func testBothOptionsProlongedMarkAfterAlnumBeforeKana() {
        let options = ProlongedSoundMarksTransliterator.Options(
            replaceProlongedMarksFollowingAlnums: true,
            replaceProlongedMarksBetweenNonKanas: true
        )
        let transliterator = ProlongedSoundMarksTransliterator(options: options)
        let input = "A\u{30fc}カ"
        let expected = "A\u{002d}カ"
        XCTAssertEqual(transliterator.transliterate(input), expected)
    }
}
