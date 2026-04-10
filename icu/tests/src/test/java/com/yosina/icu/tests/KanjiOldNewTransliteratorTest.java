package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for Kanji Old/New form transliterator ICU rules.
 */
public class KanjiOldNewTransliteratorTest extends BaseTransliteratorTest {
    
    private Transliterator transliterator;
    
    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("kanji_old_new");
    }
    
    @Test
    public void testCommonOldToNewKanji() {
        // Common old to new kanji conversions
        assertEquals("国", transliterate(transliterator, "國"));
        assertEquals("学", transliterate(transliterator, "學"));
        assertEquals("体", transliterate(transliterator, "體"));
        assertEquals("会", transliterate(transliterator, "會"));
        assertEquals("党", transliterate(transliterator, "黨"));
        assertEquals("鉄", transliterate(transliterator, "鐵"));
        assertEquals("図", transliterate(transliterator, "圖"));
        assertEquals("関", transliterate(transliterator, "關"));
        assertEquals("医", transliterate(transliterator, "醫"));
        assertEquals("薬", transliterate(transliterator, "藥"));
    }
    
    @Test
    public void testMixedOldAndNewKanji() {
        String input = "國語學習體験會";
        String expected = "国語学習体験会";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testTextWithOldKanji() {
        String input = "東京醫科大學附屬病院";
        String expected = "東京医科大学附属病院";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testAlreadyModernKanji() {
        String input = "日本国東京都";
        assertEquals(input, transliterate(transliterator, input));
    }
    
    @Test
    public void testMixedTextWithNonKanji() {
        String input = "舊字體（旧字体）を新字体に變換する。";
        String expected = "旧字体（旧字体）を新字体に変換する。";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }
    
    @Test
    public void testLatinCharacters() {
        String input = "ABC 123 test";
        assertEquals(input, transliterate(transliterator, input));
    }
}