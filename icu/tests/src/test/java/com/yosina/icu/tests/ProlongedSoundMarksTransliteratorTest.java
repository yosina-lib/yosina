package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for Prolonged Sound Marks transliterator ICU rules.
 * Note: ICU version has limitations compared to the full implementation.
 */
public class ProlongedSoundMarksTransliteratorTest extends BaseTransliteratorTest {
    
    private Transliterator transliterator;
    
    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("prolonged_sound_marks");
    }
    
    @Test
    public void testFullwidthHyphenMinusToProlongedSoundMark() {
        String input = "イ－ハト－ヴォ";
        String expected = "イーハトーヴォ";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testFullwidthHyphenMinusAtEndOfWord() {
        String input = "カトラリ－";
        String expected = "カトラリー";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testAsciiHyphenMinusToProlongedSoundMark() {
        String input = "イ-ハト-ヴォ";
        String expected = "イーハトーヴォ";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testAsciiHyphenMinusAtEndOfWord() {
        String input = "カトラリ-";
        String expected = "カトラリー";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testHiraganaWithHyphen() {
        String input = "らー";
        String expected = "らー";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testKatakanaWithVariousHyphens() {
        // Test different hyphen-like characters
        String input1 = "ア\u002Dイ"; // ASCII hyphen
        String input2 = "ア\u2010イ"; // Hyphen
        String input3 = "ア\u2014イ"; // Em dash
        String input4 = "ア\u2015イ"; // Horizontal bar
        String input5 = "ア\u2212イ"; // Minus sign
        
        assertEquals("アーイ", transliterate(transliterator, input1));
        assertEquals("アーイ", transliterate(transliterator, input2));
        assertEquals("アーイ", transliterate(transliterator, input3));
        assertEquals("アーイ", transliterate(transliterator, input4));
        assertEquals("アーイ", transliterate(transliterator, input5));
    }
    
    @Test
    public void testHalfwidthKatakanaWithHyphen() {
        String input = "ｱ-ｲ-ｳ";
        String expected = "ｱｰｲｰｳ";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testMixedScript() {
        String input = "カタカナ-ひらがな-ABC";
        // Only the hyphen after katakana should be replaced
        assertEquals("カタカナーひらがな-ABC", transliterate(transliterator, input));
    }
    
    @Test
    public void testConsecutiveHyphens() {
        String input = "アーー";
        // Should not replace hyphen after prolonged mark
        assertEquals("アーー", transliterate(transliterator, input));
    }
    
    @Test
    public void testAlphanumericContext() {
        // In the ICU version, hyphens between alphanumerics are preserved
        String input = "test-123";
        assertEquals("test-123", transliterate(transliterator, input));
        
        String input2 = "テスト－１２３";
        assertEquals("テストー１２３", transliterate(transliterator, input2));
    }
    
    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }
    
    @Test
    public void testNoHyphens() {
        String input = "これはテストです";
        assertEquals(input, transliterate(transliterator, input));
    }
}