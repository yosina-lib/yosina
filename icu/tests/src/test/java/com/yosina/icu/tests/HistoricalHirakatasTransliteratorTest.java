package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

public class HistoricalHirakatasTransliteratorTest extends BaseTransliteratorTest {

    private Transliterator transliterator;

    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("historical_hirakatas");
    }

    @Test
    public void testHistoricalHiragana() {
        assertEquals("い", transliterate(transliterator, "ゐ"));
        assertEquals("え", transliterate(transliterator, "ゑ"));
    }

    @Test
    public void testHistoricalKatakana() {
        assertEquals("イ", transliterate(transliterator, "ヰ"));
        assertEquals("エ", transliterate(transliterator, "ヱ"));
    }

    @Test
    public void testVoicedHistoricalKatakanaUnchanged() {
        // Default mode: voiced_katakanas="skip"
        assertEquals("ヷ", transliterate(transliterator, "ヷ"));
        assertEquals("ヸ", transliterate(transliterator, "ヸ"));
        assertEquals("ヹ", transliterate(transliterator, "ヹ"));
        assertEquals("ヺ", transliterate(transliterator, "ヺ"));
    }

    @Test
    public void testInSentence() {
        String input = "ゐなかのゑ";
        String expected = "いなかのえ";
        assertEquals(expected, transliterate(transliterator, input));
    }

    @Test
    public void testKatakanaInSentence() {
        String input = "ヰスキー";
        String expected = "イスキー";
        assertEquals(expected, transliterate(transliterator, input));
    }

    @Test
    public void testModernKanaUnchanged() {
        String input = "あいうえおカキクケコ";
        assertEquals(input, transliterate(transliterator, input));
    }

    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }
}
