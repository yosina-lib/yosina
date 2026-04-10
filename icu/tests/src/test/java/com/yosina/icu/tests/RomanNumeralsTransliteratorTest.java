package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.junit.jupiter.api.Assertions.*;

public class RomanNumeralsTransliteratorTest extends BaseTransliteratorTest {

    private Transliterator transliterator;

    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("roman_numerals");
    }

    @Test
    public void testUpperCaseRomanNumerals() {
        assertEquals("I", transliterate(transliterator, "\u2160"));
        assertEquals("II", transliterate(transliterator, "\u2161"));
        assertEquals("III", transliterate(transliterator, "\u2162"));
        assertEquals("IV", transliterate(transliterator, "\u2163"));
        assertEquals("V", transliterate(transliterator, "\u2164"));
        assertEquals("VI", transliterate(transliterator, "\u2165"));
        assertEquals("VII", transliterate(transliterator, "\u2166"));
        assertEquals("VIII", transliterate(transliterator, "\u2167"));
        assertEquals("IX", transliterate(transliterator, "\u2168"));
        assertEquals("X", transliterate(transliterator, "\u2169"));
        assertEquals("XI", transliterate(transliterator, "\u216A"));
        assertEquals("XII", transliterate(transliterator, "\u216B"));
    }

    @Test
    public void testLowerCaseRomanNumerals() {
        assertEquals("i", transliterate(transliterator, "\u2170"));
        assertEquals("ii", transliterate(transliterator, "\u2171"));
        assertEquals("iii", transliterate(transliterator, "\u2172"));
        assertEquals("iv", transliterate(transliterator, "\u2173"));
        assertEquals("v", transliterate(transliterator, "\u2174"));
        assertEquals("vi", transliterate(transliterator, "\u2175"));
    }

    @Test
    public void testLargeRomanNumerals() {
        assertEquals("L", transliterate(transliterator, "\u216C"));
        assertEquals("C", transliterate(transliterator, "\u216D"));
        assertEquals("D", transliterate(transliterator, "\u216E"));
        assertEquals("M", transliterate(transliterator, "\u216F"));
    }

    @Test
    public void testMixedText() {
        String input = "Chapter \u2162: Section \u2171";
        assertEquals("Chapter III: Section ii", transliterate(transliterator, input));
    }

    @Test
    public void testEmptyString() {
        assertEquals("", transliterate(transliterator, ""));
    }

    @Test
    public void testNoRomanNumerals() {
        String input = "Regular text 123";
        assertEquals(input, transliterate(transliterator, input));
    }
}
