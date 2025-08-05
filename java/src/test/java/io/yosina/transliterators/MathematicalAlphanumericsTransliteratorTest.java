package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.*;

import io.yosina.CharIterator;
import io.yosina.Chars;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

/** Tests for MathematicalAlphanumericsTransliterator based on JavaScript test patterns. */
public class MathematicalAlphanumericsTransliteratorTest {

    private static Stream<Arguments> mathematicalAlphanumericsTestCases() {
        return Stream.of(
                // Mathematical Bold characters
                Arguments.of("A", "𝐀", "Mathematical Bold A to regular A"),
                Arguments.of("B", "𝐁", "Mathematical Bold B to regular B"),
                Arguments.of("Z", "𝐙", "Mathematical Bold Z to regular Z"),
                Arguments.of("a", "𝐚", "Mathematical Bold a to regular a"),
                Arguments.of("b", "𝐛", "Mathematical Bold b to regular b"),
                Arguments.of("z", "𝐳", "Mathematical Bold z to regular z"),

                // Mathematical Italic characters
                Arguments.of("A", "𝐴", "Mathematical Italic A to regular A"),
                Arguments.of("B", "𝐵", "Mathematical Italic B to regular B"),
                Arguments.of("a", "𝑎", "Mathematical Italic a to regular a"),
                Arguments.of("b", "𝑏", "Mathematical Italic b to regular b"),

                // Mathematical Bold Italic characters
                Arguments.of("A", "𝑨", "Mathematical Bold Italic A to regular A"),
                Arguments.of("a", "𝒂", "Mathematical Bold Italic a to regular a"),

                // Mathematical Script characters
                Arguments.of("A", "𝒜", "Mathematical Script A to regular A"),
                Arguments.of("a", "𝒶", "Mathematical Script a to regular a"),

                // Mathematical Bold Script characters
                Arguments.of("A", "𝓐", "Mathematical Bold Script A to regular A"),
                Arguments.of("a", "𝓪", "Mathematical Bold Script a to regular a"),

                // Mathematical Fraktur characters
                Arguments.of("A", "𝔄", "Mathematical Fraktur A to regular A"),
                Arguments.of("a", "𝔞", "Mathematical Fraktur a to regular a"),

                // Mathematical Double-struck characters
                Arguments.of("A", "𝔸", "Mathematical Double-struck A to regular A"),
                Arguments.of("a", "𝕒", "Mathematical Double-struck a to regular a"),

                // Mathematical Bold Fraktur characters
                Arguments.of("A", "𝕬", "Mathematical Bold Fraktur A to regular A"),
                Arguments.of("a", "𝖆", "Mathematical Bold Fraktur a to regular a"),

                // Mathematical Sans-serif characters
                Arguments.of("A", "𝖠", "Mathematical Sans-serif A to regular A"),
                Arguments.of("a", "𝖺", "Mathematical Sans-serif a to regular a"),

                // Mathematical Sans-serif Bold characters
                Arguments.of("A", "𝗔", "Mathematical Sans-serif Bold A to regular A"),
                Arguments.of("a", "𝗮", "Mathematical Sans-serif Bold a to regular a"),

                // Mathematical Sans-serif Italic characters
                Arguments.of("A", "𝘈", "Mathematical Sans-serif Italic A to regular A"),
                Arguments.of("a", "𝘢", "Mathematical Sans-serif Italic a to regular a"),

                // Mathematical Sans-serif Bold Italic characters
                Arguments.of("A", "𝘼", "Mathematical Sans-serif Bold Italic A to regular A"),
                Arguments.of("a", "𝙖", "Mathematical Sans-serif Bold Italic a to regular a"),

                // Mathematical Monospace characters
                Arguments.of("A", "𝙰", "Mathematical Monospace A to regular A"),
                Arguments.of("a", "𝚊", "Mathematical Monospace a to regular a"),

                // Mathematical digits
                Arguments.of("0", "𝟎", "Mathematical Bold digit 0 to regular 0"),
                Arguments.of("1", "𝟏", "Mathematical Bold digit 1 to regular 1"),
                Arguments.of("9", "𝟗", "Mathematical Bold digit 9 to regular 9"));
    }

    @ParameterizedTest(name = "Mathematical Alphanumerics test case: {2}")
    @MethodSource("mathematicalAlphanumericsTestCases")
    public void testMathematicalAlphanumericsTransliterations(
            String expected, String input, String description) {
        MathematicalAlphanumericsTransliterator transliterator =
                new MathematicalAlphanumericsTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @Test
    public void testEmptyString() {
        MathematicalAlphanumericsTransliterator transliterator =
                new MathematicalAlphanumericsTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of("").iterator());
        String output = result.string();

        assertEquals("", output);
    }

    @Test
    public void testUnmappedCharacters() {
        MathematicalAlphanumericsTransliterator transliterator =
                new MathematicalAlphanumericsTransliterator();

        String input = "hello world 123 !@# こんにちは";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(input, output, "Unmapped characters should remain unchanged");
    }

    @Test
    public void testMixedMathematicalContent() {
        MathematicalAlphanumericsTransliterator transliterator =
                new MathematicalAlphanumericsTransliterator();

        String input = "𝐀𝐁𝐂 regular ABC 𝟏𝟐𝟑";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "ABC regular ABC 123",
                output,
                "Should convert mathematical characters to regular ASCII");
    }

    @Test
    public void testMathematicalAlphabet() {
        MathematicalAlphanumericsTransliterator transliterator =
                new MathematicalAlphanumericsTransliterator();

        String input = "𝐀𝐁𝐂𝐃𝐄𝐅𝐆𝐇𝐈𝐉𝐊𝐋𝐌𝐍𝐎𝐏𝐐𝐑𝐒𝐓𝐔𝐕𝐖𝐗𝐘𝐙";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ", output, "Should convert full mathematical alphabet");
    }

    @Test
    public void testMathematicalLowercaseAlphabet() {
        MathematicalAlphanumericsTransliterator transliterator =
                new MathematicalAlphanumericsTransliterator();

        String input = "𝐚𝐛𝐜𝐝𝐞𝐟𝐠𝐡𝐢𝐣𝐤𝐥𝐦𝐧𝐨𝐩𝐪𝐫𝐬𝐭𝐮𝐯𝐰𝐱𝐲𝐳";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "abcdefghijklmnopqrstuvwxyz",
                output,
                "Should convert full mathematical lowercase alphabet");
    }

    @Test
    public void testMathematicalDigits() {
        MathematicalAlphanumericsTransliterator transliterator =
                new MathematicalAlphanumericsTransliterator();

        String input = "𝟎𝟏𝟐𝟑𝟒𝟓𝟔𝟕𝟖𝟗";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals("0123456789", output, "Should convert mathematical digits to regular digits");
    }

    @Test
    public void testDifferentMathematicalStyles() {
        MathematicalAlphanumericsTransliterator transliterator =
                new MathematicalAlphanumericsTransliterator();

        String input = "𝐀𝐴𝑨𝒜𝓐𝔄𝔸𝕬𝖠𝗔𝘈𝘼𝙰"; // Different styles of A
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "AAAAAAAAAAAAA", output, "Should convert all mathematical styles to regular A");
    }

    @Test
    public void testMathematicalEquation() {
        MathematicalAlphanumericsTransliterator transliterator =
                new MathematicalAlphanumericsTransliterator();

        String input = "𝒇(𝒙) = 𝒎𝒙 + 𝒃";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "f(x) = mx + b", output, "Should convert mathematical equation to regular text");
    }

    @Test
    public void testSpecialMathematicalCharacters() {
        MathematicalAlphanumericsTransliterator transliterator =
                new MathematicalAlphanumericsTransliterator();

        String input = "𝔄𝔞 𝕬𝖆 𝖠𝖺"; // Fraktur, Bold Fraktur, Sans-serif
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "Aa Aa Aa",
                output,
                "Should convert special mathematical styles to regular characters");
    }

    @Test
    public void testIteratorProperties() {
        MathematicalAlphanumericsTransliterator transliterator =
                new MathematicalAlphanumericsTransliterator();

        String input = "𝐀𝐁𝐂";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        assertNotNull(result);
        assertTrue(result.hasNext());
    }
}
