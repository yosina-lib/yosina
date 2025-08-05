package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

import io.yosina.CharIterator;
import io.yosina.Chars;
import io.yosina.Transliterator;
import org.junit.jupiter.api.Test;

/** Tests for HiraKataComposition transliterator. */
public class HiraKataCompositionTest {

    @Test
    public void testKatakanaWithCombiningVoicedMark() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "\u30ab\u3099\u30ac\u30ad\u30ad\u3099\u30af";
        String expected = "\u30ac\u30ac\u30ad\u30ae\u30af";
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testKatakanaWithCombiningVoicedAndSemiVoicedMarks() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "\u30cf\u30cf\u3099\u30cf\u309a\u30d2\u30d5\u30d8\u30db";
        String expected = "\u30cf\u30d0\u30d1\u30d2\u30d5\u30d8\u30db";
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testHiraganaWithCombiningVoicedMark() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "\u304b\u3099\u304c\u304d\u304d\u3099\u304f";
        String expected = "\u304c\u304c\u304d\u304e\u304f";
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testHiraganaWithCombiningVoicedAndSemiVoicedMarks() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "\u306f\u306f\u3099\u306f\u309a\u3072\u3075\u3078\u307b";
        String expected = "\u306f\u3070\u3071\u3072\u3075\u3078\u307b";
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testKatakanaWithNonCombiningMarksEnabled() {
        HiraKataCompositionTransliterator.Options options =
                new HiraKataCompositionTransliterator.Options(true);
        HiraKataCompositionTransliterator transliterator =
                new HiraKataCompositionTransliterator(options);

        String input = "\u30cf\u30cf\u309b\u30cf\u309c\u30d2\u30d5\u30d8\u30db";

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        String expected = "\u30cf\u30d0\u30d1\u30d2\u30d5\u30d8\u30db";
        assertEquals(expected, output);
    }

    @Test
    public void testKatakanaWithNonCombiningMarksDisabled() {
        HiraKataCompositionTransliterator.Options options =
                new HiraKataCompositionTransliterator.Options(false);
        HiraKataCompositionTransliterator transliterator =
                new HiraKataCompositionTransliterator(options);

        String input = "\u30cf\u30cf\u309b\u30cf\u309c\u30d2\u30d5\u30d8\u30db";

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        String expected = "\u30cf\u30cf\u309b\u30cf\u309c\u30d2\u30d5\u30d8\u30db";
        assertEquals(expected, output);
    }

    @Test
    public void testEmptyString() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "";
        String expected = "";
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testStringWithNoComposableCharacters() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "hello world 123";
        String expected = "hello world 123";
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testMixedTextWithHiraganaAndKatakana() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "こんにちは\u304b\u3099世界\u30ab\u3099";
        String expected = "こんにちは\u304c世界\u30ac";
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testCombiningMarksWithoutBaseCharacter() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "\u3099\u309a\u309b\u309c";
        String expected = "\u3099\u309a\u309b\u309c";
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testHiraganaUWithDakuten() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "\u3046\u3099";
        String expected = "\u3094";
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testKatakanaUWithDakuten() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "\u30a6\u3099";
        String expected = "\u30f4";
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testMultipleCompositionsInSequence() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "\u304b\u3099\u304d\u3099\u304f\u3099\u3051\u3099\u3053\u3099";
        String expected = "\u304c\u304e\u3050\u3052\u3054";
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testNonComposableCharacterFollowedByCombiningMark() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "\u3042\u3099";
        String expected = "\u3042\u3099";
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testHiraKataCompositionOptionsEquals() {
        HiraKataCompositionTransliterator.Options options1 =
                new HiraKataCompositionTransliterator.Options(true);
        HiraKataCompositionTransliterator.Options options2 =
                new HiraKataCompositionTransliterator.Options(true);
        HiraKataCompositionTransliterator.Options options3 =
                new HiraKataCompositionTransliterator.Options(false);

        assertEquals(options1, options2);
        assertNotEquals(options1, options3);
        assertEquals(options1.hashCode(), options2.hashCode());
        assertNotEquals(options1.hashCode(), options3.hashCode());
    }

    @Test
    public void testHiraganaIterationMark() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "\u309d\u3099"; // ゝ + combining voiced mark
        String expected = "\u309e"; // ゞ
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testKatakanaIterationMark() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        String input = "\u30fd\u3099"; // ヽ + combining voiced mark
        String expected = "\u30fe"; // ヾ
        String result = transliterator.transliterate(Chars.of(input).iterator()).string();

        assertEquals(expected, result);
    }

    @Test
    public void testIterationMarksWithNonCombiningMarks() {
        HiraKataCompositionTransliterator.Options options =
                new HiraKataCompositionTransliterator.Options(true);
        HiraKataCompositionTransliterator transliterator =
                new HiraKataCompositionTransliterator(options);

        // Test hiragana iteration mark with non-combining voiced mark
        String input1 = "\u309d\u309b"; // ゝ + ゛ (non-combining)
        String expected1 = "\u309e"; // ゞ
        String result1 = transliterator.transliterate(Chars.of(input1).iterator()).string();
        assertEquals(expected1, result1);

        // Test katakana iteration mark with non-combining voiced mark
        String input2 = "\u30fd\u309b"; // ヽ + ゛ (non-combining)
        String expected2 = "\u30fe"; // ヾ
        String result2 = transliterator.transliterate(Chars.of(input2).iterator()).string();
        assertEquals(expected2, result2);
    }

    @Test
    public void testKatakanaSpecialCharactersWithDakuten() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        // Test ワ + ゛ → ヷ
        String input1 = "\u30ef\u3099";
        String expected1 = "\u30f7";
        String result1 = transliterator.transliterate(Chars.of(input1).iterator()).string();
        assertEquals(expected1, result1);

        // Test ヰ + ゛ → ヸ
        String input2 = "\u30f0\u3099";
        String expected2 = "\u30f8";
        String result2 = transliterator.transliterate(Chars.of(input2).iterator()).string();
        assertEquals(expected2, result2);

        // Test ヱ + ゛ → ヹ
        String input3 = "\u30f1\u3099";
        String expected3 = "\u30f9";
        String result3 = transliterator.transliterate(Chars.of(input3).iterator()).string();
        assertEquals(expected3, result3);

        // Test ヲ + ゛ → ヺ
        String input4 = "\u30f2\u3099";
        String expected4 = "\u30fa";
        String result4 = transliterator.transliterate(Chars.of(input4).iterator()).string();
        assertEquals(expected4, result4);
    }

    @Test
    public void testVerticalIterationMarks() {
        Transliterator transliterator = new HiraKataCompositionTransliterator();

        // Test vertical hiragana iteration mark with combining voiced mark
        String input1 = "\u3031\u3099"; // 〱 + combining voiced mark
        String expected1 = "\u3032"; // 〲
        String result1 = transliterator.transliterate(Chars.of(input1).iterator()).string();
        assertEquals(expected1, result1);

        // Test vertical katakana iteration mark with combining voiced mark
        String input2 = "\u3033\u3099"; // 〳 + combining voiced mark
        String expected2 = "\u3034"; // 〴
        String result2 = transliterator.transliterate(Chars.of(input2).iterator()).string();
        assertEquals(expected2, result2);
    }

    @Test
    public void testVerticalIterationMarksWithNonCombiningMarks() {
        HiraKataCompositionTransliterator.Options options =
                new HiraKataCompositionTransliterator.Options(true);
        HiraKataCompositionTransliterator transliterator =
                new HiraKataCompositionTransliterator(options);

        // Test vertical hiragana iteration mark with non-combining voiced mark
        String input1 = "\u3031\u309b"; // 〱 + ゛ (non-combining)
        String expected1 = "\u3032"; // 〲
        String result1 = transliterator.transliterate(Chars.of(input1).iterator()).string();
        assertEquals(expected1, result1);

        // Test vertical katakana iteration mark with non-combining voiced mark
        String input2 = "\u3033\u309b"; // 〳 + ゛ (non-combining)
        String expected2 = "\u3034"; // 〴
        String result2 = transliterator.transliterate(Chars.of(input2).iterator()).string();
        assertEquals(expected2, result2);
    }
}
