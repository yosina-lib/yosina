package lib.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

import lib.yosina.CharIterator;
import lib.yosina.Chars;
import org.junit.jupiter.api.Test;

public class Jisx0201AndAlikeTransliteratorTest {

    @Test
    public void testFullwidthToHalfwidthBasic() {
        Jisx0201AndAlikeTransliterator.Options options =
                new Jisx0201AndAlikeTransliterator.Options(true);
        Jisx0201AndAlikeTransliterator transliterator = new Jisx0201AndAlikeTransliterator(options);

        // Test cases
        String[][] testCases = {
            {"Ａ", "A"}, // FULLWIDTH A -> A
            {"１", "1"}, // FULLWIDTH 1 -> 1
            {"！", "!"}, // FULLWIDTH ! -> !
            {"カ", "ｶ"}, // KATAKANA KA -> HALFWIDTH KATAKANA KA
            {"　", " "}, // IDEOGRAPHIC SPACE -> SPACE
            {"ＡＢＣ", "ABC"}, // Multiple characters
        };

        for (String[] testCase : testCases) {
            String input = testCase[0];
            String expected = testCase[1];

            CharIterator resultIter = transliterator.transliterate(Chars.of(input).iterator());
            String result = resultIter.string();

            assertEquals(expected, result, "Failed for input: " + input);
        }
    }

    @Test
    public void testHalfwidthToFullwidthBasic() {
        Jisx0201AndAlikeTransliterator.Options options =
                new Jisx0201AndAlikeTransliterator.Options(false);
        Jisx0201AndAlikeTransliterator transliterator = new Jisx0201AndAlikeTransliterator(options);

        // Test cases
        String[][] testCases = {
            {"A", "Ａ"}, // A -> FULLWIDTH A
            {"1", "１"}, // 1 -> FULLWIDTH 1
            {"!", "！"}, // ! -> FULLWIDTH !
            {"ｶ", "カ"}, // HALFWIDTH KATAKANA KA -> KATAKANA KA
            {" ", "　"}, // SPACE -> IDEOGRAPHIC SPACE
            {"ABC", "ＡＢＣ"}, // Multiple characters
        };

        for (String[] testCase : testCases) {
            String input = testCase[0];
            String expected = testCase[1];

            CharIterator resultIter = transliterator.transliterate(Chars.of(input).iterator());
            String result = resultIter.string();

            assertEquals(expected, result, "Failed for input: " + input);
        }
    }

    @Test
    public void testVoicedSoundMarks() {
        Jisx0201AndAlikeTransliterator.Options options =
                new Jisx0201AndAlikeTransliterator.Options(true);
        Jisx0201AndAlikeTransliterator transliterator = new Jisx0201AndAlikeTransliterator(options);

        // Test cases
        String[][] testCases = {
            {"ガ", "ｶﾞ"}, // GA -> KA + VOICED MARK
            {"パ", "ﾊﾟ"}, // PA -> HA + SEMI-VOICED MARK
            {"ヴ", "ｳﾞ"}, // VU -> U + VOICED MARK
            {"ダイジョウブ", "ﾀﾞｲｼﾞｮｳﾌﾞ"}, // Multiple voiced characters
        };

        for (String[] testCase : testCases) {
            String input = testCase[0];
            String expected = testCase[1];

            CharIterator resultIter = transliterator.transliterate(Chars.of(input).iterator());
            String result = resultIter.string();

            assertEquals(expected, result, "Failed for input: " + input);
        }
    }

    @Test
    public void testVoicedSoundMarksCombining() {
        Jisx0201AndAlikeTransliterator.Options options =
                new Jisx0201AndAlikeTransliterator.Options()
                        .withFullwidthToHalfwidth(false)
                        .withCombineVoicedSoundMarks(true);
        Jisx0201AndAlikeTransliterator transliterator = new Jisx0201AndAlikeTransliterator(options);

        // Test cases
        String[][] testCases = {
            {"ｶﾞ", "ガ"}, // KA + VOICED MARK -> GA
            {"ﾊﾟ", "パ"}, // HA + SEMI-VOICED MARK -> PA
            {"ｳﾞ", "ヴ"}, // U + VOICED MARK -> VU
        };

        for (String[] testCase : testCases) {
            String input = testCase[0];
            String expected = testCase[1];

            CharIterator resultIter = transliterator.transliterate(Chars.of(input).iterator());
            String result = resultIter.string();

            assertEquals(expected, result, "Failed for input: " + input);
        }
    }

    @Test
    public void testHiraganaConversion() {
        Jisx0201AndAlikeTransliterator.Options options =
                new Jisx0201AndAlikeTransliterator.Options().withConvertHiraganas(true);
        Jisx0201AndAlikeTransliterator transliterator = new Jisx0201AndAlikeTransliterator(options);

        // Test cases
        String[][] testCases = {
            {"あ", "ｱ"}, // HIRAGANA A -> HALFWIDTH KATAKANA A
            {"が", "ｶﾞ"}, // HIRAGANA GA -> KA + VOICED MARK
            {"ぱ", "ﾊﾟ"}, // HIRAGANA PA -> HA + SEMI-VOICED MARK
            {"こんにちは", "ｺﾝﾆﾁﾊ"}, // Multiple hiragana characters
        };

        for (String[] testCase : testCases) {
            String input = testCase[0];
            String expected = testCase[1];

            CharIterator resultIter = transliterator.transliterate(Chars.of(input).iterator());
            String result = resultIter.string();

            assertEquals(expected, result, "Failed for input: " + input);
        }
    }

    @Test
    public void testSpecialPunctuations() {
        Jisx0201AndAlikeTransliterator.Options options =
                new Jisx0201AndAlikeTransliterator.Options().withConvertUnsafeSpecials(true);
        Jisx0201AndAlikeTransliterator transliterator = new Jisx0201AndAlikeTransliterator(options);

        // Test cases
        String[][] testCases = {
            {"゠", "="}, // KATAKANA-HIRAGANA DOUBLE HYPHEN -> EQUALS SIGN
        };

        for (String[] testCase : testCases) {
            String input = testCase[0];
            String expected = testCase[1];

            CharIterator resultIter = transliterator.transliterate(Chars.of(input).iterator());
            String result = resultIter.string();

            assertEquals(expected, result, "Failed for input: " + input);
        }
    }

    @Test
    public void testGLOverrides() {
        // Test Yen sign override
        Jisx0201AndAlikeTransliterator.Options yenOptions =
                new Jisx0201AndAlikeTransliterator.Options().withU005cAsBackslash(true);
        Jisx0201AndAlikeTransliterator yenTransliterator =
                new Jisx0201AndAlikeTransliterator(yenOptions);

        CharIterator resultIter = yenTransliterator.transliterate(Chars.of("￥").iterator());
        String result = resultIter.string();
        assertEquals("\\", result, "Failed for Yen sign override");

        // Test tilde override
        Jisx0201AndAlikeTransliterator.Options tildeOptions =
                new Jisx0201AndAlikeTransliterator.Options().withU007eAsWaveDash(true);
        Jisx0201AndAlikeTransliterator tildeTransliterator =
                new Jisx0201AndAlikeTransliterator(tildeOptions);

        resultIter = tildeTransliterator.transliterate(Chars.of("\u301c").iterator());
        result = resultIter.string();
        assertEquals("~", result, "Failed for tilde override");
        resultIter = tildeTransliterator.transliterate(Chars.of("\uff5e").iterator());
        result = resultIter.string();
        assertEquals("~", result);
    }

    @Test
    public void testPreservesUnmappedCharacters() {
        Jisx0201AndAlikeTransliterator.Options options =
                new Jisx0201AndAlikeTransliterator.Options(true);
        Jisx0201AndAlikeTransliterator transliterator = new Jisx0201AndAlikeTransliterator(options);

        // Test cases - characters that should not be mapped
        String[] testCases = {
            "漢", // KANJI should be preserved
            "🎌", // EMOJI should be preserved
            "€", // EURO SIGN should be preserved
        };

        for (String input : testCases) {
            CharIterator resultIter = transliterator.transliterate(Chars.of(input).iterator());
            String result = resultIter.string();

            assertEquals(input, result, "Failed to preserve: " + input);
        }
    }

    @Test
    public void testMixedContent() {
        Jisx0201AndAlikeTransliterator.Options options =
                new Jisx0201AndAlikeTransliterator.Options(true);
        Jisx0201AndAlikeTransliterator transliterator = new Jisx0201AndAlikeTransliterator(options);

        String input = "Ｈｅｌｌｏ　世界！　カタカナ　１２３";
        String expected = "Hello 世界! ｶﾀｶﾅ 123";

        CharIterator resultIter = transliterator.transliterate(Chars.of(input).iterator());
        String result = resultIter.string();

        assertEquals(expected, result, "Failed for mixed content");
    }

    @Test
    public void testEmptyInput() {
        Jisx0201AndAlikeTransliterator.Options options =
                new Jisx0201AndAlikeTransliterator.Options(true);
        Jisx0201AndAlikeTransliterator transliterator = new Jisx0201AndAlikeTransliterator(options);

        CharIterator resultIter = transliterator.transliterate(Chars.of("").iterator());
        String result = resultIter.string();

        assertEquals("", result, "Failed for empty input");
    }

    @Test
    public void testJisx0201AndAlikeTransliteratorOptionsEquals() {
        Jisx0201AndAlikeTransliterator.Options options1 =
                new Jisx0201AndAlikeTransliterator.Options();
        Jisx0201AndAlikeTransliterator.Options options2 =
                new Jisx0201AndAlikeTransliterator.Options().withFullwidthToHalfwidth(true);
        Jisx0201AndAlikeTransliterator.Options options3 =
                new Jisx0201AndAlikeTransliterator.Options()
                        .withFullwidthToHalfwidth(false)
                        .withConvertGR(false);

        assertEquals(options1, options2);
        assertNotEquals(options1, options3);
        assertEquals(options1.hashCode(), options2.hashCode());
        assertNotEquals(options1.hashCode(), options3.hashCode());
    }
}
