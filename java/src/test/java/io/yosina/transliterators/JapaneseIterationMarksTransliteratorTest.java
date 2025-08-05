package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.assertEquals;

import io.yosina.Chars;
import io.yosina.Transliterator;
import org.junit.jupiter.api.Test;

/** Tests for JapaneseIterationMarks transliterator. */
public class JapaneseIterationMarksTransliteratorTest {

    private String transliterate(
            String input, JapaneseIterationMarksTransliterator.Options options) {
        Transliterator transliterator = new JapaneseIterationMarksTransliterator(options);
        return transliterator.transliterate(Chars.of(input).iterator()).string();
    }

    private String transliterate(String input) {
        return transliterate(input, new JapaneseIterationMarksTransliterator.Options());
    }

    @Test
    public void testBasicHiraganaRepetition() {
        // Basic hiragana repetition
        assertEquals("ささ", transliterate("さゝ"));

        // Multiple hiragana repetitions
        assertEquals("みみこころ", transliterate("みゝこゝろ"));
    }

    @Test
    public void testHiraganaVoicedRepetition() {
        // Hiragana voiced repetition
        assertEquals("はば", transliterate("はゞ"));

        // Multiple voiced repetitions
        assertEquals("ただしじま", transliterate("たゞしゞま"));
    }

    @Test
    public void testBasicKatakanaRepetition() {
        // Basic katakana repetition
        assertEquals("ササ", transliterate("サヽ"));
    }

    @Test
    public void testKatakanaVoicedRepetition() {
        // Katakana voiced repetition
        assertEquals("ハバ", transliterate("ハヾ"));

        // Special case: ウ with voicing
        assertEquals("ウヴ", transliterate("ウヾ"));
    }

    @Test
    public void testKanjiRepetition() {
        // Basic kanji repetition
        assertEquals("人人", transliterate("人々"));

        // Multiple kanji repetitions
        assertEquals("日日月月年年", transliterate("日々月々年々"));

        // Kanji in compound words
        assertEquals("色色", transliterate("色々"));
    }

    @Test
    public void testInvalidCombinations() {
        // Hiragana mark after katakana
        assertEquals("カゝ", transliterate("カゝ"));

        // Katakana mark after hiragana
        assertEquals("かヽ", transliterate("かヽ"));

        // Kanji mark after hiragana
        assertEquals("か々", transliterate("か々"));

        // Iteration mark at start
        assertEquals("ゝあ", transliterate("ゝあ"));
    }

    @Test
    public void testConsecutiveIterationMarks() {
        // Consecutive iteration marks - only first should be expanded
        assertEquals("ささゝ", transliterate("さゝゝ"));
    }

    @Test
    public void testNonRepeatableCharacters() {
        // Hiragana hatsuon can't repeat
        assertEquals("んゝ", transliterate("んゝ"));

        // Hiragana sokuon can't repeat
        assertEquals("っゝ", transliterate("っゝ"));

        // Katakana hatsuon can't repeat
        assertEquals("ンヽ", transliterate("ンヽ"));

        // Katakana sokuon can't repeat
        assertEquals("ッヽ", transliterate("ッヽ"));

        // Voiced character with voiced iteration mark now repeats the voiced character
        // This behavior was changed to match other implementations
        assertEquals("がが", transliterate("がゞ"));

        // Semi-voiced character can't voice
        assertEquals("ぱゞ", transliterate("ぱゞ"));
    }

    @Test
    public void testMixedText() {
        // Mixed hiragana, katakana, and kanji
        assertEquals("こころ、ココロ、其其", transliterate("こゝろ、コヽロ、其々"));

        // Iteration marks in sentence
        assertEquals("日日の暮らしはささやか", transliterate("日々の暮らしはさゝやか"));
    }

    @Test
    public void testHalfwidthKatakana() {
        // Halfwidth katakana should not be supported
        assertEquals("ｻヽ", transliterate("ｻヽ"));
    }

    @Test
    public void testVoicingEdgeCases() {
        // No voicing possible
        assertEquals("あゞ", transliterate("あゞ"));

        // Voicing all consonants
        assertEquals("かがただはばさざ", transliterate("かゞたゞはゞさゞ"));
    }

    @Test
    public void testComplexScenarios() {
        // Multiple types in sequence
        assertEquals("思思にこころサザめく", transliterate("思々にこゝろサヾめく"));
    }

    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(""));
    }

    @Test
    public void testNoIterationMarks() {
        String input = "これはテストです";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testIterationMarkAfterSpace() {
        assertEquals("さ ゝ", transliterate("さ ゝ"));
    }

    @Test
    public void testIterationMarkAfterPunctuation() {
        assertEquals("さ、ゝ", transliterate("さ、ゝ"));
    }

    @Test
    public void testIterationMarkAfterASCII() {
        assertEquals("Aゝ", transliterate("Aゝ"));
    }

    @Test
    public void testCJKExtensionKanji() {
        // CJK Extension A kanji
        assertEquals("㐀㐀", transliterate("㐀々"));
    }

    @Test
    public void testMultipleIterationMarksInDifferentContexts() {
        // Test various combinations
        assertEquals("すすむ、タダカウ、山山", transliterate("すゝむ、タヾカウ、山々"));
        assertEquals("はは、マヾ", transliterate("はゝ、マヾ")); // マ doesn't have voicing
    }

    @Test
    public void testKanjiIterationMarkAfterKatakana() {
        // Kanji iteration mark should not work after katakana
        assertEquals("ア々", transliterate("ア々"));
    }

    @Test
    public void testVoicingVariations() {
        // Test all possible voicing combinations for hiragana
        assertEquals("かが", transliterate("かゞ"));
        assertEquals("きぎ", transliterate("きゞ"));
        assertEquals("くぐ", transliterate("くゞ"));
        assertEquals("けげ", transliterate("けゞ"));
        assertEquals("こご", transliterate("こゞ"));
        assertEquals("さざ", transliterate("さゞ"));
        assertEquals("しじ", transliterate("しゞ"));
        assertEquals("すず", transliterate("すゞ"));
        assertEquals("せぜ", transliterate("せゞ"));
        assertEquals("そぞ", transliterate("そゞ"));
        assertEquals("ただ", transliterate("たゞ"));
        assertEquals("ちぢ", transliterate("ちゞ"));
        assertEquals("つづ", transliterate("つゞ"));
        assertEquals("てで", transliterate("てゞ"));
        assertEquals("とど", transliterate("とゞ"));
        assertEquals("はば", transliterate("はゞ"));
        assertEquals("ひび", transliterate("ひゞ"));
        assertEquals("ふぶ", transliterate("ふゞ"));
        assertEquals("へべ", transliterate("へゞ"));
        assertEquals("ほぼ", transliterate("ほゞ"));
    }

    @Test
    public void testKatakanaVoicingVariations() {
        // Test all possible voicing combinations for katakana
        assertEquals("カガ", transliterate("カヾ"));
        assertEquals("キギ", transliterate("キヾ"));
        assertEquals("クグ", transliterate("クヾ"));
        assertEquals("ケゲ", transliterate("ケヾ"));
        assertEquals("コゴ", transliterate("コヾ"));
        assertEquals("サザ", transliterate("サヾ"));
        assertEquals("シジ", transliterate("シヾ"));
        assertEquals("スズ", transliterate("スヾ"));
        assertEquals("セゼ", transliterate("セヾ"));
        assertEquals("ソゾ", transliterate("ソヾ"));
        assertEquals("タダ", transliterate("タヾ"));
        assertEquals("チヂ", transliterate("チヾ"));
        assertEquals("ツヅ", transliterate("ツヾ"));
        assertEquals("テデ", transliterate("テヾ"));
        assertEquals("トド", transliterate("トヾ"));
        assertEquals("ハバ", transliterate("ハヾ"));
        assertEquals("ヒビ", transliterate("ヒヾ"));
        assertEquals("フブ", transliterate("フヾ"));
        assertEquals("ヘベ", transliterate("ヘヾ"));
        assertEquals("ホボ", transliterate("ホヾ"));
        assertEquals("ウヴ", transliterate("ウヾ"));
    }

    @Test
    public void testIterationMarkCombinations() {
        // Different iteration marks in sequence
        assertEquals("ささカカ山山", transliterate("さゝカヽ山々"));

        // Mixed with normal text
        assertEquals("これはささやかな日日です", transliterate("これはさゝやかな日々です"));
    }

    @Test
    public void testSpecialCharactersAsIterationTarget() {
        // Small characters can be repeated since they are valid hiragana/katakana
        assertEquals("ゃゃ", transliterate("ゃゝ")); // Small ya can be repeated
        assertEquals("ャャ", transliterate("ャヽ")); // Small katakana ya can be repeated

        // Prolonged sound mark
        assertEquals(
                "ーヽ", transliterate("ーヽ")); // Prolonged sound mark can't be repeated (not katakana)
    }

    @Test
    public void testNumbersAndIterationMarks() {
        // Numbers followed by iteration marks
        assertEquals("1ゝ", transliterate("1ゝ"));
        assertEquals("１ゝ", transliterate("１ゝ"));
    }

    @Test
    public void testComplexKanjiRanges() {
        // Test various CJK ranges
        // CJK Extension B
        assertEquals("\uD840\uDC00\uD840\uDC00", transliterate("\uD840\uDC00々")); // 𠀀𠀀

        // CJK Extension C
        assertEquals("\uD869\uDC00\uD869\uDC00", transliterate("\uD869\uDC00々")); // 𪀀𪀀
    }

    @Test
    public void testRealWorldExamples() {
        // Common real-world usage
        assertEquals("人人", transliterate("人々"));
        assertEquals("時時", transliterate("時々"));
        assertEquals("様様", transliterate("様々"));
        assertEquals("国国", transliterate("国々"));
        assertEquals("所所", transliterate("所々"));

        // In context
        assertEquals("様様な国国から", transliterate("様々な国々から"));
        assertEquals("時時刻刻", transliterate("時々刻々"));
    }

    @Test
    public void testEdgeCasesWithPunctuation() {
        // Various punctuation between characters and iteration marks
        assertEquals("さ。ゝ", transliterate("さ。ゝ"));
        assertEquals("さ！ゝ", transliterate("さ！ゝ"));
        assertEquals("さ？ゝ", transliterate("さ？ゝ"));
        assertEquals("さ「ゝ", transliterate("さ「ゝ"));
        assertEquals("さ」ゝ", transliterate("さ」ゝ"));
    }

    @Test
    public void testMixedScriptBoundaries() {
        // Script boundaries - iteration marks should work within same script type
        assertEquals("漢字かか", transliterate("漢字かゝ")); // Hiragana iteration mark works after hiragana
        assertEquals(
                "ひらがなカカ", transliterate("ひらがなカヽ")); // Katakana iteration mark works after katakana
        assertEquals("カタカナ人人", transliterate("カタカナ人々")); // Kanji iteration mark works after kanji
    }

    @Test
    public void testFactoryIntegration() {
        // Test that the transliterator can be created via factory
        var transliterator = io.yosina.Yosina.makeTransliterator("japanese-iteration-marks");

        assertEquals("ささ", transliterator.apply("さゝ"));
        assertEquals("人人", transliterator.apply("人々"));
    }

    @Test
    public void testVerticalIterationMarks() {
        // Vertical hiragana iteration marks
        assertEquals("ささ", transliterate("さ〱")); // U+3031
        assertEquals("はば", transliterate("は〲")); // U+3032

        // Vertical katakana iteration marks
        assertEquals("ササ", transliterate("サ〳")); // U+3033
        assertEquals("ハバ", transliterate("ハ〴")); // U+3034
        assertEquals("ウヴ", transliterate("ウ〴")); // U+3034 with voicing

        // Invalid combinations with vertical marks
        assertEquals("カ〱", transliterate("カ〱")); // Katakana + vertical hiragana mark
        assertEquals("か〳", transliterate("か〳")); // Hiragana + vertical katakana mark
    }

    @Test
    public void testVoicedCharacterWithUnvoicedIterationMark() {
        // Hiragana voiced character followed by unvoiced iteration mark
        assertEquals("がか", transliterate("がゝ"));
        assertEquals("ぎき", transliterate("ぎゝ"));
        assertEquals("ぐく", transliterate("ぐゝ"));
        assertEquals("げけ", transliterate("げゝ"));
        assertEquals("ごこ", transliterate("ごゝ"));
        assertEquals("ざさ", transliterate("ざゝ"));
        assertEquals("じし", transliterate("じゝ"));
        assertEquals("ずす", transliterate("ずゝ"));
        assertEquals("ぜせ", transliterate("ぜゝ"));
        assertEquals("ぞそ", transliterate("ぞゝ"));
        assertEquals("だた", transliterate("だゝ"));
        assertEquals("ぢち", transliterate("ぢゝ"));
        assertEquals("づつ", transliterate("づゝ"));
        assertEquals("でて", transliterate("でゝ"));
        assertEquals("どと", transliterate("どゝ"));
        assertEquals("ばは", transliterate("ばゝ"));
        assertEquals("びひ", transliterate("びゝ"));
        assertEquals("ぶふ", transliterate("ぶゝ"));
        assertEquals("べへ", transliterate("べゝ"));
        assertEquals("ぼほ", transliterate("ぼゝ"));

        // Katakana voiced character followed by unvoiced iteration mark
        assertEquals("ガカ", transliterate("ガヽ"));
        assertEquals("ザサ", transliterate("ザヽ"));
        assertEquals("ダタ", transliterate("ダヽ"));
        assertEquals("バハ", transliterate("バヽ"));
        assertEquals("ヴウ", transliterate("ヴヽ"));

        // With vertical marks
        assertEquals("がか", transliterate("が〱"));
        assertEquals("ガカ", transliterate("ガ〳"));
    }

    @Test
    public void testVoicedCharacterWithVoicedIterationMark() {
        // Hiragana voiced character followed by voiced iteration mark
        assertEquals("がが", transliterate("がゞ"));
        assertEquals("ぎぎ", transliterate("ぎゞ"));
        assertEquals("ぐぐ", transliterate("ぐゞ"));
        assertEquals("げげ", transliterate("げゞ"));
        assertEquals("ごご", transliterate("ごゞ"));
        assertEquals("ざざ", transliterate("ざゞ"));
        assertEquals("じじ", transliterate("じゞ"));
        assertEquals("ずず", transliterate("ずゞ"));
        assertEquals("ぜぜ", transliterate("ぜゞ"));
        assertEquals("ぞぞ", transliterate("ぞゞ"));
        assertEquals("だだ", transliterate("だゞ"));
        assertEquals("ぢぢ", transliterate("ぢゞ"));
        assertEquals("づづ", transliterate("づゞ"));
        assertEquals("でで", transliterate("でゞ"));
        assertEquals("どど", transliterate("どゞ"));
        assertEquals("ばば", transliterate("ばゞ"));
        assertEquals("びび", transliterate("びゞ"));
        assertEquals("ぶぶ", transliterate("ぶゞ"));
        assertEquals("べべ", transliterate("べゞ"));
        assertEquals("ぼぼ", transliterate("ぼゞ"));

        // Katakana voiced character followed by voiced iteration mark
        assertEquals("ガガ", transliterate("ガヾ"));
        assertEquals("ザザ", transliterate("ザヾ"));
        assertEquals("ダダ", transliterate("ダヾ"));
        assertEquals("ババ", transliterate("バヾ"));
        assertEquals("ヴヴ", transliterate("ヴヾ"));

        // With vertical marks
        assertEquals("がが", transliterate("が〲"));
        assertEquals("ガガ", transliterate("ガ〴"));
    }

    @Test
    public void testMixedVoicedAndUnvoicedCases() {
        // Complex scenarios with mixed voiced/unvoiced patterns
        assertEquals("がかがが", transliterate("がゝがゞ"));
        assertEquals("ばはばば", transliterate("ばゝばゞ"));
        assertEquals("ガカガガ", transliterate("ガヽガヾ"));

        // With vertical marks
        assertEquals("ざさざざ", transliterate("ざ〱ざ〲"));
        assertEquals("ザサザザ", transliterate("ザ〳ザ〴"));
    }
}
