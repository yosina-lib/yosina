package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for Radicals transliterator ICU rules.
 */
public class RadicalsTransliteratorTest extends BaseTransliteratorTest {
    
    private Transliterator transliterator;
    
    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("radicals");
    }
    
    @Test
    public void testKangxiRadicalToIdeograph() {
        // Test some common Kangxi radicals
        assertEquals("一", transliterate(transliterator, "⼀"));
        assertEquals("丨", transliterate(transliterator, "⼁"));
        assertEquals("丶", transliterate(transliterator, "⼂"));
        assertEquals("丿", transliterate(transliterator, "⼃"));
        assertEquals("乙", transliterate(transliterator, "⼄"));
        assertEquals("人", transliterate(transliterator, "⼈"));
        assertEquals("水", transliterate(transliterator, "⽔"));
        assertEquals("火", transliterate(transliterator, "⽕"));
        assertEquals("木", transliterate(transliterator, "⽊"));
        assertEquals("金", transliterate(transliterator, "金"));
    }
    
    @Test
    public void testMixedTextWithRadicals() {
        String input = "部首：⼈（人）、⽔（水）、⽕（火）";
        String expected = "部首：人（人）、水（水）、火（火）";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testRadicalSequence() {
        String input = "⼀⼁⼂⼃⼄⼅";
        String expected = "一丨丶丿乙亅";
        assertEquals(expected, transliterate(transliterator, input));
    }
    
    @Test
    public void testUnmappedCharacters() {
        String input = "This is regular text 123";
        assertEquals(input, transliterate(transliterator, input));
    }
    
    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }
}