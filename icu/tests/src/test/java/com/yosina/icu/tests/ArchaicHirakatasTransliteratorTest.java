package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

public class ArchaicHirakatasTransliteratorTest extends BaseTransliteratorTest {

    private Transliterator transliterator;

    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("archaic_hirakatas");
    }

    @Test
    public void testArchaicKanaToModern() {
        // U+1B000 → エ (katakana)
        assertEquals("\u30A8", transliterate(transliterator, "\uD82C\uDC00"));
        // U+1B001 → え (hiragana)
        assertEquals("\u3048", transliterate(transliterator, "\uD82C\uDC01"));
    }

    @Test
    public void testHentaiganaToModern() {
        // U+1B002-U+1B006 → あ
        assertEquals("\u3042", transliterate(transliterator, "\uD82C\uDC02"));
        assertEquals("\u3042", transliterate(transliterator, "\uD82C\uDC03"));
        assertEquals("\u3042", transliterate(transliterator, "\uD82C\uDC04"));
    }

    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }

    @Test
    public void testModernKanaUnchanged() {
        String input = "あいうえお";
        assertEquals(input, transliterate(transliterator, input));
    }

    @Test
    public void testLatinUnchanged() {
        String input = "Hello World 123";
        assertEquals(input, transliterate(transliterator, input));
    }
}
