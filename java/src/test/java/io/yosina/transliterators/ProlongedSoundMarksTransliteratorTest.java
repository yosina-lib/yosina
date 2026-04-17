package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

import io.yosina.Chars;
import io.yosina.Transliterator;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

/** Tests for ProlongedSoundMarks transliterator. */
public class ProlongedSoundMarksTransliteratorTest {

    private String transliterate(String input, ProlongedSoundMarksTransliterator.Options options) {
        Transliterator transliterator = new ProlongedSoundMarksTransliterator(options);
        return transliterator.transliterate(Chars.of(input).iterator()).string();
    }

    private String transliterate(String input) {
        return transliterate(input, new ProlongedSoundMarksTransliterator.Options());
    }

    @Test
    public void testFullwidthHyphenMinusToProlongedSoundMark() {
        String input = "イ\uff0dハト\uff0dヴォ";
        String expected = "イ\u30fcハト\u30fcヴォ";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testFullwidthHyphenMinusAtEndOfWord() {
        String input = "カトラリ\uff0d";
        String expected = "カトラリ\u30fc";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testAsciiHyphenMinusToProlongedSoundMark() {
        String input = "イ\u002dハト\u002dヴォ";
        String expected = "イ\u30fcハト\u30fcヴォ";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testAsciiHyphenMinusAtEndOfWord() {
        String input = "カトラリ\u002d";
        String expected = "カトラリ\u30fc";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testDontReplaceBetweenProlongedSoundMarks() {
        String input = "1\u30fc\uff0d2\u30fc3";
        String expected = "1\u30fc\uff0d2\u30fc3";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testReplaceProlongedMarksBetweenAlphanumerics() {
        String input = "1\u30fc\uff0d2\u30fc3";
        String expected = "1\u002d\u002d2\u002d3";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testReplaceProlongedMarksBetweenFullwidthAlphanumerics() {
        String input = "\uff11\u30fc\uff0d\uff12\u30fc\uff13";
        String expected = "\uff11\uff0d\uff0d\uff12\uff0d\uff13";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testDontProlongSokuonByDefault() {
        String input = "ウッ\uff0dウン\uff0d";
        String expected = "ウッ\uff0dウン\uff0d";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testAllowProlongedSokuon() {
        String input = "ウッ\uff0dウン\uff0d";
        String expected = "ウッ\u30fcウン\uff0d";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, true, false);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testAllowProlongedHatsuon() {
        String input = "ウッ\uff0dウン\uff0d";
        String expected = "ウッ\uff0dウン\u30fc";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, true, false, false);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testAllowBothProlongedSokuonAndHatsuon() {
        String input = "ウッ\uff0dウン\uff0d";
        String expected = "ウッ\u30fcウン\u30fc";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, true, true, false);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(""));
    }

    @Test
    public void testStringWithNoHyphens() {
        String input = "こんにちは世界";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testMixedHiraganaAndKatakanaWithHyphens() {
        String input = "あいう\u002dかきく\uff0d";
        String expected = "あいう\u30fcかきく\u30fc";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testHalfwidthKatakanaWithHyphen() {
        String input = "ｱｲｳ\u002d";
        String expected = "ｱｲｳ\uff70";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testHalfwidthKatakanaWithFullwidthHyphen() {
        String input = "ｱｲｳ\uff0d";
        String expected = "ｱｲｳ\uff70";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testHyphenAfterNonJapaneseCharacter() {
        String input = "ABC\u002d123\uff0d";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testMultipleHyphensInSequence() {
        String input = "ア\u002d\u002d\u002dイ";
        String expected = "ア\u30fc\u30fc\u30fcイ";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testVariousHyphenTypes() {
        String input = "ア\u002dイ\u2010ウ\u2014エ\u2015オ\u2212カ\uff0d";
        String expected = "ア\u30fcイ\u30fcウ\u30fcエ\u30fcオ\u30fcカ\u30fc";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testProlongedSoundMarkRemainsUnchanged1() {
        String input = "ア\u30fcＡ\uff70Ｂ";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testProlongedSoundMarkRemainsUnchanged2() {
        String input = "ア\u30fcン\uff70ウ";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testMixedAlphanumericAndJapaneseWithReplaceOption() {
        String input = "A\u30fcB\uff0dアイウ\u002d123\u30fc";
        String expected = "A\u002dB\u002dアイウ\u30fc123\u002d";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testHiraganaSokuonWithHyphen() {
        String input = "あっ\u002d";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testHiraganaSokuonWithHyphenAndAllowProlongedSokuon() {
        String input = "あっ\u002d";
        String expected = "あっ\u30fc";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, true, false);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testHiraganaHatsuonWithHyphen() {
        String input = "あん\u002d";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testHiraganaHatsuonWithHyphenAndAllowProlongedHatsuon() {
        String input = "あん\u002d";
        String expected = "あん\u30fc";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, true, false, false);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testHalfwidthKatakanaSokuonWithHyphen() {
        String input = "ｳｯ\u002d";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testHalfwidthKatakanaSokuonWithHyphenAndAllowProlongedSokuon() {
        String input = "ｳｯ\u002d";
        String expected = "ｳｯ\uff70";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, true, false);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testHalfwidthKatakanaHatsuonWithHyphen() {
        String input = "ｳﾝ\u002d";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testHalfwidthKatakanaHatsuonWithHyphenAndAllowProlongedHatsuon() {
        String input = "ｳﾝ\u002d";
        String expected = "ｳﾝ\uff70";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, true, false, false);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testHyphenAtStartOfString() {
        String input = "\u002dアイウ";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testOnlyHyphens() {
        String input = "\u002d\uff0d\u2010\u2014\u2015\u2212";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testNewlineAndTabCharacters() {
        String input = "ア\n\u002d\tイ\uff0d";
        String expected = "ア\n\u002d\tイ\u30fc";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testEmojiWithHyphens() {
        String input = "😀\u002d😊\uff0d";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testUnicodeSurrogates() {
        String input = "\uD83D\uDE00ア\u002d\uD83D\uDE01イ\uff0d";
        String expected = "\uD83D\uDE00ア\u30fc\uD83D\uDE01イ\u30fc";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testHyphenBetweenDifferentCharacterTypes() {
        String input = "あ\u002dア\u002dA\u002d1\u002dａ\u002d１";
        String expected = "あ\u30fcア\u30fcA\u002d1\u002dａ\u002d１";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testHyphenBetweenDifferentCharacterTypesWithReplaceOption() {
        String input = "A\u002d1\u30fcａ\uff70１";
        String expected = "A\u002d1\u002dａ\uff0d１";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testHiraganaVowelEndedCharacters() {
        String input = "あ\u002dか\u002dさ\u002dた\u002dな\u002dは\u002dま\u002dや\u002dら\u002dわ\u002d";
        String expected = "あ\u30fcか\u30fcさ\u30fcた\u30fcな\u30fcは\u30fcま\u30fcや\u30fcら\u30fcわ\u30fc";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testKatakanaVowelEndedCharacters() {
        String input = "ア\u002dカ\u002dサ\u002dタ\u002dナ\u002dハ\u002dマ\u002dヤ\u002dラ\u002dワ\u002d";
        String expected = "ア\u30fcカ\u30fcサ\u30fcタ\u30fcナ\u30fcハ\u30fcマ\u30fcヤ\u30fcラ\u30fcワ\u30fc";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testHalfwidthKatakanaVowelEndedCharacters() {
        String input = "ｱ\u002dｶ\u002dｻ\u002dﾀ\u002dﾅ\u002dﾊ\u002dﾏ\u002dﾔ\u002dﾗ\u002dﾜ\u002d";
        String expected = "ｱ\uff70ｶ\uff70ｻ\uff70ﾀ\uff70ﾅ\uff70ﾊ\uff70ﾏ\uff70ﾔ\uff70ﾗ\uff70ﾜ\uff70";
        assertEquals(expected, transliterate(input));
    }

    @Test
    public void testDigitsWithHyphens() {
        String input = "0\u002d1\u002d2\u002d3\u002d4\u002d5\u002d6\u002d7\u002d8\u002d9\u002d";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testFullwidthDigitsWithHyphens() {
        String input = "０\u002d１\u002d２\u002d３\u002d４\u002d５\u002d６\u002d７\u002d８\u002d９\u002d";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testFullwidthDigitsWithHyphensWithOptions() {
        String input = "０\u002d１\u002d２\u002d３\u002d４\u002d５\u002d６\u002d７\u002d８\u002d９\u002d";
        String expected = "０\uff0d１\uff0d２\uff0d３\uff0d４\uff0d５\uff0d６\uff0d７\uff0d８\uff0d９\uff0d";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testAlphabetWithHyphens() {
        String input = "A\u002dB\u002dC\u002da\u002db\u002dc\u002d";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testAlphabetWithHyphensWithOptions() {
        String input = "A\u002dB\u002dC\u002da\u002db\u002dc\u002d";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testFullwidthAlphabetWithHyphens() {
        String input = "Ａ\u002dＢ\u002dＣ\u002dａ\u002dｂ\u002dｃ\u002d";
        assertEquals(input, transliterate(input));
    }

    @Test
    public void testFullwidthAlphabetWithHyphensWithOptions() {
        String input = "Ａ\u002dＢ\u002dＣ\u002dａ\u002dｂ\u002dｃ\u002d";
        String expected = "Ａ\uff0dＢ\uff0dＣ\uff0dａ\uff0dｂ\uff0dｃ\uff0d";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    private static Stream<Arguments> provideTestCases() {
        return Stream.of(
                // Test consecutive prolonged marks replacement
                Arguments.of(
                        "consecutive prolonged marks with alphanumerics",
                        "A\u30fc\u30fc\u30fcB",
                        "A\u002d\u002d\u002dB",
                        new ProlongedSoundMarksTransliterator.Options(false, false, false, true)),
                // Test mixed width consistency
                Arguments.of(
                        "mixed width characters maintain consistency",
                        "ｱ\uff0dア\u002d",
                        "ｱ\uff70ア\u30fc",
                        new ProlongedSoundMarksTransliterator.Options()),
                Arguments.of(
                        "prolonged mark followed by hyphen",
                        "ア\u30fc\u002d",
                        "ア\u30fc\u30fc",
                        new ProlongedSoundMarksTransliterator.Options()),
                // Test with skip already transliterated
                Arguments.of(
                        "skip already transliterated characters",
                        "ア\u002dイ\uff0d",
                        "ア\u30fcイ\u30fc",
                        new ProlongedSoundMarksTransliterator.Options(true, false, false, false)));
    }

    @ParameterizedTest
    @MethodSource("provideTestCases")
    public void testParameterizedCases(
            String description,
            String input,
            String expected,
            ProlongedSoundMarksTransliterator.Options options) {
        assertEquals(expected, transliterate(input, options), "Failed test: " + description);
    }

    @Test
    public void testReplaceProlongedMarksBetweenNonKanasOtherChars() {
        String input = "\u6f22\u30fc\u5b57";
        String expected = "\u6f22\uff0d\u5b57";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testReplaceProlongedMarksBetweenNonKanasHalfwidthAlnums() {
        String input = "1\u30fc2";
        String expected = "1\u002d2";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testReplaceProlongedMarksBetweenNonKanasFullwidthAlnums() {
        String input = "\uff11\u30fc\uff12";
        String expected = "\uff11\uff0d\uff12";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testReplaceProlongedMarksBetweenNonKanasAfterKanaNotReplaced() {
        String input = "\u30ab\u30fc\u6f22";
        String expected = "\u30ab\u30fc\u6f22";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testReplaceProlongedMarksBetweenNonKanasBeforeKanaNotReplaced() {
        String input = "\u6f22\u30fc\u30ab";
        String expected = "\u6f22\u30fc\u30ab";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testReplaceProlongedMarksBetweenNonKanasConsecutive() {
        String input = "\u6f22\u30fc\u30fc\u30fc\u5b57";
        String expected = "\u6f22\uff0d\uff0d\uff0d\u5b57";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testReplaceProlongedMarksBetweenNonKanasConsecutiveBeforeKanaPreserved() {
        String input = "\u6f22\u30fc\u30fc\u30fc\u30ab";
        String expected = "\u6f22\u30fc\u30fc\u30fc\u30ab";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testReplaceProlongedMarksBetweenNonKanasTrailingAfterFullwidth() {
        String input = "\u6f22\u30fc\u30fc\u30fc";
        String expected = "\u6f22\uff0d\uff0d\uff0d";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testReplaceProlongedMarksBetweenNonKanasTrailingAfterHalfwidth() {
        String input = "1\u30fc\u30fc\u30fc";
        String expected = "1\u002d\u002d\u002d";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testReplaceProlongedMarksBetweenNonKanasOnlyAfterAlnumBeforeKana() {
        String input = "A\u30fc\u30ab";
        String expected = "A\u30fc\u30ab";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, false, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testReplaceProlongedMarksBetweenNonKanasBothOptionsAfterAlnumBeforeKana() {
        String input = "A\u30fc\u30ab";
        String expected = "A\u002d\u30ab";
        ProlongedSoundMarksTransliterator.Options options =
                new ProlongedSoundMarksTransliterator.Options(false, false, false, true, true);
        assertEquals(expected, transliterate(input, options));
    }

    @Test
    public void testProlongedSoundMarksTransliteratorOptionsEquals() {
        ProlongedSoundMarksTransliterator.Options options1 =
                new ProlongedSoundMarksTransliterator.Options(true, false, true, false);
        ProlongedSoundMarksTransliterator.Options options2 =
                new ProlongedSoundMarksTransliterator.Options(true, false, true, false);
        ProlongedSoundMarksTransliterator.Options options3 =
                new ProlongedSoundMarksTransliterator.Options(false, false, true, false);

        assertEquals(options1, options2);
        assertNotEquals(options1, options3);
        assertEquals(options1.hashCode(), options2.hashCode());
        assertNotEquals(options1.hashCode(), options3.hashCode());
    }
}
