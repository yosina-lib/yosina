package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.*;

import io.yosina.CharIterator;
import io.yosina.Chars;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

/** Tests for KanjiOldNewTransliterator based on JavaScript test patterns. */
public class KanjiOldNewTransliteratorTest {

    private static Stream<Arguments> kanjiOldNewTestCases() {
        return Stream.of(
                Arguments.of(
                        "\u6867\udb40\udd00",
                        "\u6A9C\udb40\udd00",
                        "檜 (old) to 桧 (new) with variation selector"),
                Arguments.of("\u8fbb\udb40\udd00", "\u8fbb\udb40\udd01", "辻 VS2 to VS1 conversion"),
                Arguments.of(
                        "\u6E05\udb40\udd00",
                        "\u6DF8\udb40\udd00",
                        "清 (old) to 淸 (new) conversion"),
                Arguments.of(
                        "\u62C5\udb40\udd00",
                        "\u64D4\udb40\udd00",
                        "担 (new) to 擔 (old) conversion"),
                Arguments.of(
                        "\u6669\udb40\udd00",
                        "\u665A\udb40\udd00",
                        "晩 (new) to 晚 (old) conversion"));
    }

    @ParameterizedTest(name = "Kanji Old-New test case: {2}")
    @MethodSource("kanjiOldNewTestCases")
    public void testKanjiOldNewTransliterations(String expected, String input, String description) {
        KanjiOldNewTransliterator transliterator = new KanjiOldNewTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @Test
    public void testEmptyString() {
        KanjiOldNewTransliterator transliterator = new KanjiOldNewTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of("").iterator());
        String output = result.string();

        assertEquals("", output);
    }

    @Test
    public void testUnmappedCharacters() {
        KanjiOldNewTransliterator transliterator = new KanjiOldNewTransliterator();

        String input = "hello world こんにちは";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(input, output, "Unmapped characters should remain unchanged");
    }

    @Test
    public void testMixedKanjiContent() {
        KanjiOldNewTransliterator transliterator = new KanjiOldNewTransliterator();

        String input = "古い\u6A9C\udb40\udd00新しい";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertTrue(output.contains("古い"));
        assertTrue(output.contains("新しい"));
        assertTrue(output.contains("\u6867\udb40\udd00"));
        assertFalse(output.contains("\u6A9C"));
    }

    @Test
    public void testVariationSelectorConversion() {
        KanjiOldNewTransliterator transliterator = new KanjiOldNewTransliterator();

        String input = "\u8fbb\udb40\udd01";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals("\u8fbb\udb40\udd00", output, "Should convert VS2 to VS1");
    }

    @Test
    public void testMultipleKanjiConversions() {
        KanjiOldNewTransliterator transliterator = new KanjiOldNewTransliterator();

        String input = "\u6DF8\udb40\udd00\u64D4\udb40\udd00\u665A\udb40\udd00";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        String expected = "\u6E05\udb40\udd00\u62C5\udb40\udd00\u6669\udb40\udd00";
        assertEquals(expected, output, "Should convert multiple kanji in sequence");
    }

    @Test
    public void testKanjiWithoutVariationSelector() {
        KanjiOldNewTransliterator transliterator = new KanjiOldNewTransliterator();

        String input = "\u6DF8\u64D4\u665A";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(input, output, "Kanji without variation selectors should remain unchanged");
    }

    @Test
    public void testIteratorProperties() {
        KanjiOldNewTransliterator transliterator = new KanjiOldNewTransliterator();

        String input = "test漢字";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        assertNotNull(result);
        assertTrue(result.hasNext());
    }
}
