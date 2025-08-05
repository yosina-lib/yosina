package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.*;

import io.yosina.CharIterator;
import io.yosina.Chars;
import java.util.List;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

/** Tests for HyphensTransliterator based on JavaScript test patterns. */
public class HyphensTransliteratorTest {

    private static Stream<Arguments> hyphensTestCases() {
        return Stream.of(
                Arguments.of("-", "─", "Box drawing horizontal to ASCII hyphen"),
                Arguments.of("-", "━", "Heavy horizontal to ASCII hyphen"),
                Arguments.of("|", "│", "Box drawing vertical to ASCII pipe"),
                Arguments.of("-", "⁃", "Hyphen bullet to ASCII hyphen"),
                Arguments.of("-", "－", "Fullwidth hyphen to ASCII hyphen"),
                Arguments.of("-", "‐", "Hyphen to ASCII hyphen"),
                Arguments.of("-", "‑", "Non-breaking hyphen to ASCII hyphen"),
                Arguments.of("-", "‒", "Figure dash to ASCII hyphen"),
                Arguments.of("-", "−", "Minus sign to ASCII hyphen"),
                Arguments.of("-", "–", "En dash to ASCII hyphen"),
                Arguments.of("~", "⁓", "Swung dash to ASCII tilde"),
                Arguments.of("-", "—", "Em dash to ASCII hyphen"),
                Arguments.of("-", "―", "Horizontal bar to ASCII hyphen"),
                Arguments.of("-", "➖", "Heavy minus sign to ASCII hyphen"),
                Arguments.of("-", "˗", "Modifier letter minus to ASCII hyphen"),
                Arguments.of("-", "﹘", "Small em dash to ASCII hyphen"),
                Arguments.of("~", "〜", "Wave dash to ASCII tilde"),
                Arguments.of("|", "｜", "Fullwidth vertical line to ASCII pipe"),
                Arguments.of("~", "～", "Fullwidth tilde to ASCII tilde"),
                Arguments.of("=", "゠", "Katakana iteration mark to ASCII equals"),
                Arguments.of("-", "﹣", "Small hyphen to ASCII hyphen"),
                Arguments.of("|", "￤", "Halfwidth vertical line to ASCII pipe"),
                Arguments.of("|", "¦", "Broken bar to ASCII pipe"),
                Arguments.of("|", "￨", "Halfwidth vertical bar to ASCII pipe"),
                Arguments.of("-", "-", "ASCII hyphen remains unchanged"),
                Arguments.of("-", "ｰ", "Halfwidth katakana prolonged sound mark to ASCII hyphen"),
                Arguments.of("|", "︱", "Presentation form vertical line to ASCII pipe"),
                Arguments.of("--", "⸺", "Two-em dash to double ASCII hyphen"),
                Arguments.of("---", "⸻", "Three-em dash to triple ASCII hyphen"),
                Arguments.of("|", "|", "ASCII pipe remains unchanged"),
                Arguments.of("~", "∼", "Tilde operator to ASCII tilde"),
                Arguments.of("-", "ー", "Katakana prolonged sound mark to ASCII hyphen"),
                Arguments.of("~", "∽", "Reversed tilde to ASCII tilde"),
                Arguments.of("~", "~", "ASCII tilde remains unchanged"),
                Arguments.of("-", "⧿", "Quadruple horizontal line to ASCII hyphen"));
    }

    @ParameterizedTest(name = "Hyphens test case: {2}")
    @MethodSource("hyphensTestCases")
    public void testHyphensTransliterations(String expected, String input, String description) {
        HyphensTransliterator transliterator =
                new HyphensTransliterator(
                        new HyphensTransliterator.Options(
                                List.of(HyphensTransliterator.Mapping.ASCII)));

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @Test
    public void testEmptyString() {
        HyphensTransliterator transliterator =
                new HyphensTransliterator(
                        new HyphensTransliterator.Options(
                                List.of(HyphensTransliterator.Mapping.ASCII)));

        CharIterator result = transliterator.transliterate(Chars.of("").iterator());
        String output = result.string();

        assertEquals("", output);
    }

    @Test
    public void testUnmappedCharacters() {
        HyphensTransliterator transliterator =
                new HyphensTransliterator(
                        new HyphensTransliterator.Options(
                                List.of(HyphensTransliterator.Mapping.ASCII)));

        String input = "hello world 123 abc";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(input, output, "Unmapped characters should remain unchanged");
    }

    @Test
    public void testMixedHyphensContent() {
        HyphensTransliterator transliterator =
                new HyphensTransliterator(
                        new HyphensTransliterator.Options(
                                List.of(HyphensTransliterator.Mapping.ASCII)));

        String input = "hello─world━test│data";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "hello-world-test|data",
                output,
                "Should convert various hyphen types to ASCII equivalents");
    }

    @Test
    public void testMultipleDashesToMultipleHyphens() {
        HyphensTransliterator transliterator =
                new HyphensTransliterator(
                        new HyphensTransliterator.Options(
                                List.of(HyphensTransliterator.Mapping.ASCII)));

        String input = "⸺⸻";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "-----",
                output,
                "Two-em dash should become -- and three-em dash should become ---");
    }

    @Test
    public void testJapaneseHyphensAndTildes() {
        HyphensTransliterator transliterator =
                new HyphensTransliterator(
                        new HyphensTransliterator.Options(
                                List.of(HyphensTransliterator.Mapping.ASCII)));

        String input = "カタカナー〜ひらがな～";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "カタカナ-~ひらがな~", output, "Japanese hyphen and tilde variants should be converted");
    }

    @Test
    public void testFullwidthCharacters() {
        HyphensTransliterator transliterator =
                new HyphensTransliterator(
                        new HyphensTransliterator.Options(
                                List.of(HyphensTransliterator.Mapping.ASCII)));

        String input = "－｜～";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "-|~", output, "Fullwidth characters should be converted to ASCII equivalents");
    }

    @Test
    public void testSpecialDashVariants() {
        HyphensTransliterator transliterator =
                new HyphensTransliterator(
                        new HyphensTransliterator.Options(
                                List.of(HyphensTransliterator.Mapping.ASCII)));

        String input = "‐‑‒–—―";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals("------", output, "All dash variants should be converted to ASCII hyphen");
    }

    @Test
    public void testIteratorProperties() {
        HyphensTransliterator transliterator =
                new HyphensTransliterator(
                        new HyphensTransliterator.Options(
                                List.of(HyphensTransliterator.Mapping.ASCII)));

        String input = "test─data";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        assertNotNull(result);
        assertTrue(result.hasNext());
    }

    @Test
    public void testHyphensTransliteratorOptionsEquals() {
        List<HyphensTransliterator.Mapping> precedence1 =
                java.util.Arrays.asList(
                        HyphensTransliterator.Mapping.ASCII,
                        HyphensTransliterator.Mapping.JISX0201);
        List<HyphensTransliterator.Mapping> precedence2 =
                java.util.Arrays.asList(
                        HyphensTransliterator.Mapping.ASCII,
                        HyphensTransliterator.Mapping.JISX0201);
        List<HyphensTransliterator.Mapping> precedence3 =
                java.util.Arrays.asList(HyphensTransliterator.Mapping.JISX0208_90);

        HyphensTransliterator.Options options1 = new HyphensTransliterator.Options(precedence1);
        HyphensTransliterator.Options options2 = new HyphensTransliterator.Options(precedence2);
        HyphensTransliterator.Options options3 = new HyphensTransliterator.Options(precedence3);

        assertEquals(options1, options2);
        assertNotEquals(options1, options3);
        assertEquals(options1.hashCode(), options2.hashCode());
        assertNotEquals(options1.hashCode(), options3.hashCode());
    }
}
