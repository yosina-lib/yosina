package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.assertEquals;

import io.yosina.Chars;
import java.util.stream.Stream;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

class HiraKataTransliteratorTest {

    @Nested
    @DisplayName("Hiragana to Katakana conversion")
    class HiraToKataTest {

        @ParameterizedTest
        @MethodSource("hiraToKataTestCases")
        void testHiraToKataConversion(String input, String expected) {
            var transliterator =
                    new HiraKataTransliterator(
                            new HiraKataTransliterator.Options(
                                    HiraKataTransliterator.Options.Mode.HIRA_TO_KATA));
            String result = transliterator.transliterate(Chars.of(input).iterator()).string();
            assertEquals(expected, result);
        }

        static Stream<Arguments> hiraToKataTestCases() {
            return Stream.of(
                    Arguments.of("あいうえお", "アイウエオ"),
                    Arguments.of("がぎぐげご", "ガギグゲゴ"),
                    Arguments.of("ぱぴぷぺぽ", "パピプペポ"),
                    Arguments.of("ぁぃぅぇぉっゃゅょ", "ァィゥェォッャュョ"),
                    Arguments.of("あいうえお123ABCアイウエオ", "アイウエオ123ABCアイウエオ"),
                    Arguments.of("こんにちは、世界！", "コンニチハ、世界！"));
        }
    }

    @Nested
    @DisplayName("Katakana to Hiragana conversion")
    class KataToHiraTest {

        @ParameterizedTest
        @MethodSource("kataToHiraTestCases")
        void testKataToHiraConversion(String input, String expected) {
            var transliterator =
                    new HiraKataTransliterator(
                            new HiraKataTransliterator.Options(
                                    HiraKataTransliterator.Options.Mode.KATA_TO_HIRA));
            String result = transliterator.transliterate(Chars.of(input).iterator()).string();
            assertEquals(expected, result);
        }

        static Stream<Arguments> kataToHiraTestCases() {
            return Stream.of(
                    Arguments.of("アイウエオ", "あいうえお"),
                    Arguments.of("ガギグゲゴ", "がぎぐげご"),
                    Arguments.of("パピプペポ", "ぱぴぷぺぽ"),
                    Arguments.of("ァィゥェォッャュョ", "ぁぃぅぇぉっゃゅょ"),
                    Arguments.of("アイウエオ123ABCあいうえお", "あいうえお123ABCあいうえお"),
                    Arguments.of("コンニチハ、世界！", "こんにちは、世界！"),
                    Arguments.of("ヴ", "ゔ"),
                    Arguments.of("ヷヸヹヺ", "ヷヸヹヺ") // Special katakana remain unchanged
                    );
        }
    }

    @Test
    @DisplayName("Default constructor uses hira-to-kata mode")
    void testDefaultConstructor() {
        var transliterator = new HiraKataTransliterator();
        String result = transliterator.transliterate(Chars.of("あいうえお").iterator()).string();
        assertEquals("アイウエオ", result);
    }

    @Test
    @DisplayName("Caching behavior")
    void testCaching() {
        // Clear cache first
        HiraKataTransliterator.mappingCache.clear();

        // Create two instances with the same mode
        var t1 =
                new HiraKataTransliterator(
                        new HiraKataTransliterator.Options(
                                HiraKataTransliterator.Options.Mode.HIRA_TO_KATA));
        var t2 =
                new HiraKataTransliterator(
                        new HiraKataTransliterator.Options(
                                HiraKataTransliterator.Options.Mode.HIRA_TO_KATA));

        // Cache should have one entry
        assertEquals(1, HiraKataTransliterator.mappingCache.size());
        assertEquals(
                true,
                HiraKataTransliterator.mappingCache.containsKey(
                        HiraKataTransliterator.Options.Mode.HIRA_TO_KATA));

        // Create instance with different mode
        var t3 =
                new HiraKataTransliterator(
                        new HiraKataTransliterator.Options(
                                HiraKataTransliterator.Options.Mode.KATA_TO_HIRA));

        // Now cache should have both modes
        assertEquals(2, HiraKataTransliterator.mappingCache.size());
        assertEquals(
                true,
                HiraKataTransliterator.mappingCache.containsKey(
                        HiraKataTransliterator.Options.Mode.KATA_TO_HIRA));
    }
}
