import XCTest
@testable import Yosina

final class JapaneseIterationMarksTests: XCTestCase {
    func testBasicHiraganaRepetition() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Basic hiragana repetition
        XCTAssertEqual(transliterator.transliterate("さゝ"), "ささ")

        // Multiple hiragana repetitions
        XCTAssertEqual(transliterator.transliterate("みゝこゝろ"), "みみこころ")
    }

    func testHiraganaVoicedRepetition() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Hiragana voiced repetition
        XCTAssertEqual(transliterator.transliterate("はゞ"), "はば")

        // Multiple voiced repetitions
        XCTAssertEqual(transliterator.transliterate("たゞしゞま"), "ただしじま")
    }

    func testBasicKatakanaRepetition() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Basic katakana repetition
        XCTAssertEqual(transliterator.transliterate("サヽ"), "ササ")
    }

    func testKatakanaVoicedRepetition() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Katakana voiced repetition
        XCTAssertEqual(transliterator.transliterate("ハヾ"), "ハバ")

        // Special case: ウ with voicing
        XCTAssertEqual(transliterator.transliterate("ウヾ"), "ウヴ")
    }

    func testKanjiRepetition() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Basic kanji repetition
        XCTAssertEqual(transliterator.transliterate("人々"), "人人")

        // Multiple kanji repetitions
        XCTAssertEqual(transliterator.transliterate("日々月々年々"), "日日月月年年")

        // Kanji in compound words
        XCTAssertEqual(transliterator.transliterate("色々"), "色色")
    }

    func testInvalidCombinations() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Hiragana mark after katakana
        XCTAssertEqual(transliterator.transliterate("カゝ"), "カゝ")

        // Katakana mark after hiragana
        XCTAssertEqual(transliterator.transliterate("かヽ"), "かヽ")

        // Kanji mark after hiragana
        XCTAssertEqual(transliterator.transliterate("か々"), "か々")

        // Iteration mark at start
        XCTAssertEqual(transliterator.transliterate("ゝあ"), "ゝあ")
    }

    func testConsecutiveIterationMarks() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Consecutive iteration marks - only first should be expanded
        XCTAssertEqual(transliterator.transliterate("さゝゝ"), "ささゝ")
    }

    func testNonRepeatableCharacters() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Hiragana hatsuon can't repeat
        XCTAssertEqual(transliterator.transliterate("んゝ"), "んゝ")

        // Hiragana sokuon can't repeat
        XCTAssertEqual(transliterator.transliterate("っゝ"), "っゝ")

        // Katakana hatsuon can't repeat
        XCTAssertEqual(transliterator.transliterate("ンヽ"), "ンヽ")

        // Katakana sokuon can't repeat
        XCTAssertEqual(transliterator.transliterate("ッヽ"), "ッヽ")

        // Voiced character can't voice again
        XCTAssertEqual(transliterator.transliterate("がゞ"), "がゞ")

        // Semi-voiced character can't voice
        XCTAssertEqual(transliterator.transliterate("ぱゞ"), "ぱゞ")
    }

    func testMixedText() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Mixed hiragana, katakana, and kanji
        XCTAssertEqual(transliterator.transliterate("こゝろ、コヽロ、其々"), "こころ、ココロ、其其")

        // Iteration marks in sentence
        XCTAssertEqual(transliterator.transliterate("日々の暮らしはさゝやか"), "日日の暮らしはささやか")
    }

    func testHalfwidthKatakana() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Halfwidth katakana should not be supported
        XCTAssertEqual(transliterator.transliterate("ｻヽ"), "ｻヽ")
    }

    func testVoicingEdgeCases() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // No voicing possible
        XCTAssertEqual(transliterator.transliterate("あゞ"), "あゞ")

        // Voicing all consonants
        XCTAssertEqual(transliterator.transliterate("かゞたゞはゞさゞ"), "かがただはばさざ")
    }

    func testComplexScenarios() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Multiple types in sequence
        XCTAssertEqual(transliterator.transliterate("思々にこゝろサヾめく"), "思思にこころサザめく")
    }

    func testEmptyString() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        XCTAssertEqual(transliterator.transliterate(""), "")
    }

    func testNoIterationMarks() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        let input = "これはテストです"
        XCTAssertEqual(transliterator.transliterate(input), input)
    }

    func testIterationMarkAfterSpace() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        XCTAssertEqual(transliterator.transliterate("さ ゝ"), "さ ゝ")
    }

    func testIterationMarkAfterPunctuation() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        XCTAssertEqual(transliterator.transliterate("さ、ゝ"), "さ、ゝ")
    }

    func testIterationMarkAfterASCII() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        XCTAssertEqual(transliterator.transliterate("Aゝ"), "Aゝ")
    }

    func testCJKExtensionKanji() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // CJK Extension A kanji
        XCTAssertEqual(transliterator.transliterate("㐀々"), "㐀㐀")
    }

    func testMultipleIterationMarksInDifferentContexts() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Test various combinations
        XCTAssertEqual(transliterator.transliterate("すゝむ、タヾカウ、山々"), "すすむ、タダカウ、山山")
        XCTAssertEqual(transliterator.transliterate("はゝ、マヾ"), "はは、マヾ") // マ doesn't have voicing
    }

    func testKanjiIterationMarkAfterKatakana() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Kanji iteration mark should not work after katakana
        XCTAssertEqual(transliterator.transliterate("ア々"), "ア々")
    }

    func testVoicingVariations() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Test all possible voicing combinations for hiragana
        XCTAssertEqual(transliterator.transliterate("かゞ"), "かが")
        XCTAssertEqual(transliterator.transliterate("きゞ"), "きぎ")
        XCTAssertEqual(transliterator.transliterate("くゞ"), "くぐ")
        XCTAssertEqual(transliterator.transliterate("けゞ"), "けげ")
        XCTAssertEqual(transliterator.transliterate("こゞ"), "こご")
        XCTAssertEqual(transliterator.transliterate("さゞ"), "さざ")
        XCTAssertEqual(transliterator.transliterate("しゞ"), "しじ")
        XCTAssertEqual(transliterator.transliterate("すゞ"), "すず")
        XCTAssertEqual(transliterator.transliterate("せゞ"), "せぜ")
        XCTAssertEqual(transliterator.transliterate("そゞ"), "そぞ")
        XCTAssertEqual(transliterator.transliterate("たゞ"), "ただ")
        XCTAssertEqual(transliterator.transliterate("ちゞ"), "ちぢ")
        XCTAssertEqual(transliterator.transliterate("つゞ"), "つづ")
        XCTAssertEqual(transliterator.transliterate("てゞ"), "てで")
        XCTAssertEqual(transliterator.transliterate("とゞ"), "とど")
        XCTAssertEqual(transliterator.transliterate("はゞ"), "はば")
        XCTAssertEqual(transliterator.transliterate("ひゞ"), "ひび")
        XCTAssertEqual(transliterator.transliterate("ふゞ"), "ふぶ")
        XCTAssertEqual(transliterator.transliterate("へゞ"), "へべ")
        XCTAssertEqual(transliterator.transliterate("ほゞ"), "ほぼ")
    }

    func testKatakanaVoicingVariations() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Test all possible voicing combinations for katakana
        XCTAssertEqual(transliterator.transliterate("カヾ"), "カガ")
        XCTAssertEqual(transliterator.transliterate("キヾ"), "キギ")
        XCTAssertEqual(transliterator.transliterate("クヾ"), "クグ")
        XCTAssertEqual(transliterator.transliterate("ケヾ"), "ケゲ")
        XCTAssertEqual(transliterator.transliterate("コヾ"), "コゴ")
        XCTAssertEqual(transliterator.transliterate("サヾ"), "サザ")
        XCTAssertEqual(transliterator.transliterate("シヾ"), "シジ")
        XCTAssertEqual(transliterator.transliterate("スヾ"), "スズ")
        XCTAssertEqual(transliterator.transliterate("セヾ"), "セゼ")
        XCTAssertEqual(transliterator.transliterate("ソヾ"), "ソゾ")
        XCTAssertEqual(transliterator.transliterate("タヾ"), "タダ")
        XCTAssertEqual(transliterator.transliterate("チヾ"), "チヂ")
        XCTAssertEqual(transliterator.transliterate("ツヾ"), "ツヅ")
        XCTAssertEqual(transliterator.transliterate("テヾ"), "テデ")
        XCTAssertEqual(transliterator.transliterate("トヾ"), "トド")
        XCTAssertEqual(transliterator.transliterate("ハヾ"), "ハバ")
        XCTAssertEqual(transliterator.transliterate("ヒヾ"), "ヒビ")
        XCTAssertEqual(transliterator.transliterate("フヾ"), "フブ")
        XCTAssertEqual(transliterator.transliterate("ヘヾ"), "ヘベ")
        XCTAssertEqual(transliterator.transliterate("ホヾ"), "ホボ")
        XCTAssertEqual(transliterator.transliterate("ウヾ"), "ウヴ")
    }

    func testIterationMarkCombinations() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Different iteration marks in sequence
        XCTAssertEqual(transliterator.transliterate("さゝカヽ山々"), "ささカカ山山")

        // Mixed with normal text
        XCTAssertEqual(transliterator.transliterate("これはさゝやかな日々です"), "これはささやかな日日です")
    }

    func testSpecialCharactersAsIterationTarget() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Small characters can be repeated since they are valid hiragana/katakana
        XCTAssertEqual(transliterator.transliterate("ゃゝ"), "ゃゃ") // Small ya can be repeated
        XCTAssertEqual(transliterator.transliterate("ャヽ"), "ャャ") // Small katakana ya can be repeated

        // Prolonged sound mark
        XCTAssertEqual(transliterator.transliterate("ーヽ"), "ーヽ") // Prolonged sound mark can't be repeated (not katakana)
    }

    func testNumbersAndIterationMarks() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Numbers followed by iteration marks
        XCTAssertEqual(transliterator.transliterate("1ゝ"), "1ゝ")
        XCTAssertEqual(transliterator.transliterate("１ゝ"), "１ゝ")
    }

    func testComplexKanjiRanges() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Test various CJK ranges
        // CJK Extension B
        XCTAssertEqual(transliterator.transliterate("𠀀々"), "𠀀𠀀") // 𠀀𠀀

        // CJK Extension C
        XCTAssertEqual(transliterator.transliterate("𪀀々"), "𪀀𪀀") // 𪀀𪀀
    }

    func testRealWorldExamples() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Common real-world usage
        XCTAssertEqual(transliterator.transliterate("人々"), "人人")
        XCTAssertEqual(transliterator.transliterate("時々"), "時時")
        XCTAssertEqual(transliterator.transliterate("様々"), "様様")
        XCTAssertEqual(transliterator.transliterate("国々"), "国国")
        XCTAssertEqual(transliterator.transliterate("所々"), "所所")

        // In context
        XCTAssertEqual(transliterator.transliterate("様々な国々から"), "様様な国国から")
        XCTAssertEqual(transliterator.transliterate("時々刻々"), "時時刻刻")
    }

    func testEdgeCasesWithPunctuation() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Various punctuation between characters and iteration marks
        XCTAssertEqual(transliterator.transliterate("さ。ゝ"), "さ。ゝ")
        XCTAssertEqual(transliterator.transliterate("さ！ゝ"), "さ！ゝ")
        XCTAssertEqual(transliterator.transliterate("さ？ゝ"), "さ？ゝ")
        XCTAssertEqual(transliterator.transliterate("さ「ゝ"), "さ「ゝ")
        XCTAssertEqual(transliterator.transliterate("さ」ゝ"), "さ」ゝ")
    }

    func testMixedScriptBoundaries() {
        let transliterator = JapaneseIterationMarksTransliterator().stringTransliterator

        // Script boundaries - iteration marks should work within same script type
        XCTAssertEqual(transliterator.transliterate("漢字かゝ"), "漢字かか") // Hiragana iteration mark works after hiragana
        XCTAssertEqual(transliterator.transliterate("ひらがなカヽ"), "ひらがなカカ") // Katakana iteration mark works after katakana
        XCTAssertEqual(transliterator.transliterate("カタカナ人々"), "カタカナ人人") // Kanji iteration mark works after kanji
    }
}
