package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.*;

import io.yosina.CharIterator;
import io.yosina.Chars;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

/** Tests for SpacesTransliterator based on JavaScript test patterns. */
public class SpacesTransliteratorTest {

    private static Stream<Arguments> spacesTestCases() {
        return Stream.of(
                Arguments.of(" ", " ", "Regular space remains unchanged"),
                Arguments.of(" ", " ", "En quad to regular space"),
                Arguments.of(" ", " ", "Em quad to regular space"),
                Arguments.of(" ", "　", "Ideographic space to regular space"),
                Arguments.of(" ", "ﾠ", "Halfwidth ideographic space to regular space"),
                Arguments.of(" ", " ", "En space to regular space"),
                Arguments.of(" ", " ", "Em space to regular space"),
                Arguments.of(" ", " ", "Three-per-em space to regular space"),
                Arguments.of(" ", " ", "Four-per-em space to regular space"),
                Arguments.of(" ", "ㅤ", "Hangul filler to regular space"),
                Arguments.of(" ", " ", "Six-per-em space to regular space"),
                Arguments.of(" ", " ", "Figure space to regular space"),
                Arguments.of(" ", " ", "Punctuation space to regular space"),
                Arguments.of(" ", " ", "Thin space to regular space"),
                Arguments.of(" ", " ", "Hair space to regular space"),
                Arguments.of(" ", " ", "Narrow no-break space to regular space"),
                Arguments.of(" ", "​", "Zero width space to regular space"),
                Arguments.of(" ", " ", "Medium mathematical space to regular space"),
                Arguments.of(" ", " ", "Word joiner to regular space"));
    }

    @ParameterizedTest(name = "Spaces test case: {2}")
    @MethodSource("spacesTestCases")
    public void testSpacesTransliterations(String expected, String input, String description) {
        SpacesTransliterator transliterator = new SpacesTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @Test
    public void testEmptyString() {
        SpacesTransliterator transliterator = new SpacesTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of("").iterator());
        String output = result.string();

        assertEquals("", output);
    }

    @Test
    public void testUnmappedCharacters() {
        SpacesTransliterator transliterator = new SpacesTransliterator();

        String input = "hello world abc123";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(input, output, "Unmapped characters should remain unchanged");
    }

    @Test
    public void testMixedSpacesContent() {
        SpacesTransliterator transliterator = new SpacesTransliterator();

        String input = "hello　world test　data";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "hello world test data",
                output,
                "Should convert ideographic spaces to regular spaces");
    }

    @Test
    public void testMultipleSpaceTypes() {
        SpacesTransliterator transliterator = new SpacesTransliterator();

        String input = "word　word word word";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "word word word word",
                output,
                "Should normalize all space types to regular spaces");
    }

    @Test
    public void testJapaneseTextWithIdeographicSpaces() {
        SpacesTransliterator transliterator = new SpacesTransliterator();

        String input = "こんにちは　世界　です";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals("こんにちは 世界 です", output, "Should convert Japanese ideographic spaces");
    }

    @Test
    public void testHalfwidthIdeographicSpace() {
        SpacesTransliterator transliterator = new SpacesTransliterator();

        String input = "testﾠdata";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals("test data", output, "Should convert halfwidth ideographic space");
    }

    @Test
    public void testZeroWidthAndInvisibleSpaces() {
        SpacesTransliterator transliterator = new SpacesTransliterator();

        String input = "word​word"; // Contains zero width space
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals("word word", output, "Should convert zero width space to regular space");
    }

    @Test
    public void testHangulFiller() {
        SpacesTransliterator transliterator = new SpacesTransliterator();

        String input = "testㅤdata";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals("test data", output, "Should convert Hangul filler to regular space");
    }

    @Test
    public void testConsecutiveSpaces() {
        SpacesTransliterator transliterator = new SpacesTransliterator();

        String input = "word　　　word";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals("word   word", output, "Should convert consecutive ideographic spaces");
    }

    @Test
    public void testIteratorProperties() {
        SpacesTransliterator transliterator = new SpacesTransliterator();

        String input = "test　data";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        assertNotNull(result);
        assertTrue(result.hasNext());
    }
}
