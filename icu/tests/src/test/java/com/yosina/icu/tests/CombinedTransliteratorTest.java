package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for Combined Characters transliterator ICU rules.
 */
public class CombinedTransliteratorTest extends BaseTransliteratorTest {
    
    private Transliterator transliterator;
    
    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("combined");
    }
    
    @Test
    public void testSquareUnits() {
        // Common square unit abbreviations
        assertEquals("株式会社", transliterate(transliterator, "㍿"));
        assertEquals("サンチーム", transliterate(transliterator, "㌠"));
        assertEquals("令和", transliterate(transliterator, "㋿"));
    }
    
    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }
    
    @Test
    public void testNoCombinedCharacters() {
        String input = "This is regular text 123";
        assertEquals(input, transliterate(transliterator, input));
    }
}