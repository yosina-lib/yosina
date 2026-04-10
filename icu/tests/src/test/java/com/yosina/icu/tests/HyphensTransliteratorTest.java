package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for Hyphens transliterator ICU rules.
 */
public class HyphensTransliteratorTest extends BaseTransliteratorTest {
    
    private Transliterator transliterator;
    
    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("hyphens");
    }
    
    @Test
    public void testVariousHyphenToAscii() {
        // Test conversions to ASCII hyphen (default mapping)
        assertEquals("-", transliterate(transliterator, "\u2010")); // Hyphen
        assertEquals("-", transliterate(transliterator, "\u2011")); // Non-breaking hyphen
        assertEquals("-", transliterate(transliterator, "\u2012")); // Figure dash
        assertEquals("-", transliterate(transliterator, "\u2013")); // En dash
        assertEquals("-", transliterate(transliterator, "\u2014")); // Em dash
        assertEquals("-", transliterate(transliterator, "\u2015")); // Horizontal bar
        assertEquals("-", transliterate(transliterator, "\uFE58")); // Small em dash
        assertEquals("-", transliterate(transliterator, "\uFE63")); // Small hyphen minus
        assertEquals("-", transliterate(transliterator, "\uFF0D")); // Fullwidth hyphen minus
    }
    
    @Test
    public void testMixedTextWithHyphens() {
        String input = "test\u2014data\u2013here";
        String expected = "test-data-here";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testMultipleHyphenTypes() {
        String input = "A\u2010B\u2013C\u2014D\uFF0DE";
        String expected = "A-B-C-D-E";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testJapaneseTextWithHyphens() {
        String input = "東京\u2014大阪";
        String expected = "東京-大阪";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testConsecutiveHyphens() {
        String input = "\u2014\u2014\u2014";
        String expected = "---";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testAsciiHyphenUnchanged() {
        String input = "test-data";
        assertEquals(input, transliterate(transliterator, input));
    }
    
    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }
    
    @Test
    public void testNoHyphens() {
        String input = "This is a test string";
        assertEquals(input, transliterate(transliterator, input));
    }
}