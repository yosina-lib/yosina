package com.yosina.icu.tests;

import com.ibm.icu.text.Transliterator;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.io.IOException;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Tests for Spaces transliterator ICU rules.
 */
public class SpacesTransliteratorTest extends BaseTransliteratorTest {
    
    private Transliterator transliterator;
    
    @BeforeEach
    public void setUp() throws IOException {
        transliterator = createTransliterator("spaces");
    }
    
    private static Stream<Arguments> spacesTestCases() {
        return Stream.of(
                Arguments.of(" ", " ", "Regular space remains unchanged"),
                Arguments.of(" ", "\u2000", "En quad to regular space"),
                Arguments.of(" ", "\u2001", "Em quad to regular space"),
                Arguments.of(" ", "\u3000", "Ideographic space to regular space"),
                Arguments.of(" ", "\uFFA0", "Halfwidth ideographic space to regular space"),
                Arguments.of(" ", "\u2002", "En space to regular space"),
                Arguments.of(" ", "\u2003", "Em space to regular space"),
                Arguments.of(" ", "\u2004", "Three-per-em space to regular space"),
                Arguments.of(" ", "\u2005", "Four-per-em space to regular space"),
                Arguments.of(" ", "\u3164", "Hangul filler to regular space"),
                Arguments.of(" ", "\u2006", "Six-per-em space to regular space"),
                Arguments.of(" ", "\u2007", "Figure space to regular space"),
                Arguments.of(" ", "\u2008", "Punctuation space to regular space"),
                Arguments.of(" ", "\u2009", "Thin space to regular space"),
                Arguments.of(" ", "\u200A", "Hair space to regular space"),
                Arguments.of(" ", "\u202F", "Narrow no-break space to regular space"),
                Arguments.of(" ", "\u200B", "Zero width space to regular space"),
                Arguments.of(" ", "\u205F", "Medium mathematical space to regular space"),
                Arguments.of(" ", "\u00A0", "Non-breaking space to regular space")
        );
    }
    
    @ParameterizedTest(name = "Spaces test case: {2}")
    @MethodSource("spacesTestCases")
    public void testSpacesTransliterations(String expected, String input, String description) {
        String result = transliterate(transliterator, input);
        assertEquals(expected, result, description);
    }
    
    @Test
    public void testEmptyString() {
        String result = transliterate(transliterator, "");
        assertEquals("", result);
    }
    
    @Test
    public void testUnmappedCharacters() {
        String input = "hello world abc123";
        String result = transliterate(transliterator, input);
        assertEquals(input, result, "Unmapped characters should remain unchanged");
    }
    
    @Test
    public void testMixedSpacesContent() {
        String input = "hello\u3000world\u2003test\u3000data";
        String result = transliterate(transliterator, input);
        assertEquals("hello world test data", result, 
                "Should convert ideographic and em spaces to regular spaces");
    }
    
    @Test
    public void testMultipleSpaceTypes() {
        String input = "word\u3000word\u2002word\u200Bword";
        String result = transliterate(transliterator, input);
        assertEquals("word word word word", result, 
                "Should normalize all space types to regular spaces");
    }
    
    @Test
    public void testJapaneseTextWithIdeographicSpaces() {
        String input = "こんにちは\u3000世界\u3000です";
        String result = transliterate(transliterator, input);
        assertEquals("こんにちは 世界 です", result, 
                "Should convert Japanese ideographic spaces");
    }
    
    @Test
    public void testHalfwidthIdeographicSpace() {
        String input = "test\uFFA0data";
        String result = transliterate(transliterator, input);
        assertEquals("test data", result, "Should convert halfwidth ideographic space");
    }
    
    @Test
    public void testZeroWidthAndInvisibleSpaces() {
        String input = "word\u200Bword"; // Contains zero width space
        String result = transliterate(transliterator, input);
        assertEquals("word word", result, "Should convert zero width space to regular space");
    }
    
    @Test
    public void testHangulFiller() {
        String input = "test\u3164data";
        String result = transliterate(transliterator, input);
        assertEquals("test data", result, "Should convert Hangul filler to regular space");
    }
    
    @Test
    public void testConsecutiveSpaces() {
        String input = "word\u3000\u3000\u3000word";
        String result = transliterate(transliterator, input);
        assertEquals("word   word", result, "Should convert consecutive ideographic spaces");
    }
}