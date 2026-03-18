package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.assertEquals;

import io.yosina.Chars;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

class HistoricalHirakatasTransliteratorTest {

    private static String transliterate(
            String input, HistoricalHirakatasTransliterator.Options options) {
        var transliterator = new HistoricalHirakatasTransliterator(options);
        return transliterator.transliterate(Chars.of(input).iterator()).string();
    }

    @Nested
    @DisplayName("Simple hiragana (default)")
    class SimpleHiraganaTest {

        @Test
        void testBasic() {
            assertEquals(
                    "いえ", transliterate("ゐゑ", new HistoricalHirakatasTransliterator.Options()));
        }

        @Test
        void testPassthrough() {
            assertEquals(
                    "あいう", transliterate("あいう", new HistoricalHirakatasTransliterator.Options()));
        }

        @Test
        void testMixed() {
            assertEquals(
                    "あいいえう",
                    transliterate("あゐいゑう", new HistoricalHirakatasTransliterator.Options()));
        }
    }

    @Nested
    @DisplayName("Decompose hiragana")
    class DecomposeHiraganaTest {

        @Test
        void testDecompose() {
            assertEquals(
                    "うぃうぇ",
                    transliterate(
                            "ゐゑ",
                            new HistoricalHirakatasTransliterator.Options(
                                    HistoricalHirakatasTransliterator.ConversionMode.DECOMPOSE,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP)));
        }
    }

    @Nested
    @DisplayName("Simple katakana (default)")
    class SimpleKatakanaTest {

        @Test
        void testBasic() {
            assertEquals(
                    "イエ", transliterate("ヰヱ", new HistoricalHirakatasTransliterator.Options()));
        }
    }

    @Nested
    @DisplayName("Decompose katakana")
    class DecomposeKatakanaTest {

        @Test
        void testDecompose() {
            assertEquals(
                    "ウィウェ",
                    transliterate(
                            "ヰヱ",
                            new HistoricalHirakatasTransliterator.Options(
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.DECOMPOSE,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP)));
        }
    }

    @Nested
    @DisplayName("Voiced katakana decompose")
    class VoicedKatakanaDecomposeTest {

        @Test
        void testDecompose() {
            assertEquals(
                    "ヴァヴィヴェヴォ",
                    transliterate(
                            "ヷヸヹヺ",
                            new HistoricalHirakatasTransliterator.Options(
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.DECOMPOSE)));
        }
    }

    @Nested
    @DisplayName("Voiced katakana skip (default)")
    class VoicedKatakanaSkipTest {

        @Test
        void testSkip() {
            assertEquals(
                    "ヷヸヹヺ",
                    transliterate(
                            "ヷヸヹヺ",
                            new HistoricalHirakatasTransliterator.Options(
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP)));
        }
    }

    @Nested
    @DisplayName("All decompose")
    class AllDecomposeTest {

        @Test
        void testAllDecompose() {
            assertEquals(
                    "うぃうぇウィウェヴァヴィヴェヴォ",
                    transliterate(
                            "ゐゑヰヱヷヸヹヺ",
                            new HistoricalHirakatasTransliterator.Options(
                                    HistoricalHirakatasTransliterator.ConversionMode.DECOMPOSE,
                                    HistoricalHirakatasTransliterator.ConversionMode.DECOMPOSE,
                                    HistoricalHirakatasTransliterator.ConversionMode.DECOMPOSE)));
        }
    }

    @Nested
    @DisplayName("All skip")
    class AllSkipTest {

        @Test
        void testAllSkip() {
            assertEquals(
                    "ゐゑヰヱヷヸヹヺ",
                    transliterate(
                            "ゐゑヰヱヷヸヹヺ",
                            new HistoricalHirakatasTransliterator.Options(
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP)));
        }
    }

    @Nested
    @DisplayName("Decomposed voiced katakana input")
    class DecomposedVoicedKatakanaTest {

        @Test
        void testDecomposedWithDecompose() {
            // Decomposed ワ+゙ ヰ+゙ ヱ+゙ ヲ+゙ should produce decomposed output
            assertEquals(
                    "ウ\u3099ァウ\u3099ィウ\u3099ェウ\u3099ォ",
                    transliterate(
                            "ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099",
                            new HistoricalHirakatasTransliterator.Options(
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.DECOMPOSE)));
        }

        @Test
        void testDecomposedWithSkip() {
            assertEquals(
                    "ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099",
                    transliterate(
                            "ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099",
                            new HistoricalHirakatasTransliterator.Options(
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP)));
        }

        @Test
        void testDecomposedNotSplitFromBase() {
            // ヰ+゙ must be treated as ヸ (voiced), not as ヰ (katakana) + separate ゙
            assertEquals(
                    "ヰ\u3099",
                    transliterate(
                            "ヰ\u3099",
                            new HistoricalHirakatasTransliterator.Options(
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.SIMPLE,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP)));
        }

        @Test
        void testDecomposedWithVoicedDecompose() {
            // ヰ+゙ = ヸ, should produce ウ+゙+ィ (decomposed)
            assertEquals(
                    "ウ\u3099ィ",
                    transliterate(
                            "ヰ\u3099",
                            new HistoricalHirakatasTransliterator.Options(
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.SKIP,
                                    HistoricalHirakatasTransliterator.ConversionMode.DECOMPOSE)));
        }
    }

    @Nested
    @DisplayName("Empty input")
    class EmptyInputTest {

        @Test
        void testEmpty() {
            assertEquals("", transliterate("", new HistoricalHirakatasTransliterator.Options()));
        }
    }
}
