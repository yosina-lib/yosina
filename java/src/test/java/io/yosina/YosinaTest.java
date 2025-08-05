package io.yosina;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import io.yosina.transliterators.HiraKataCompositionTransliterator;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;
import org.junit.jupiter.api.Test;

/** Basic tests for the Yosina library. */
public class YosinaTest {

    @Test
    public void testMakeTransliteratorWithSingleConfig() {
        Function<String, String> transliterator =
                Yosina.makeTransliterator("hira-kata-composition");

        String input = "\u304b\u3099"; // か + combining voiced mark
        String expected = "\u304c"; // が
        String result = transliterator.apply(input);

        assertEquals(expected, result);
    }

    @Test
    public void testMakeTransliteratorWithMultipleConfigs() {
        List<Yosina.TransliteratorConfig> configs =
                List.of(
                        new Yosina.TransliteratorConfig(
                                "hira-kata-composition",
                                Optional.of(new HiraKataCompositionTransliterator.Options())),
                        new Yosina.TransliteratorConfig("spaces", Optional.empty()));

        Function<String, String> transliterator = Yosina.makeTransliterator(configs);

        String input = "\u304b\u3099\u3000world"; // が + ideographic space
        String result = transliterator.apply(input);
        // Should compose the hiragana and replace the ideographic space
        assertTrue(result.contains("\u304c")); // composed が
        assertTrue(result.contains("world"));
    }

    @Test
    public void testUnknownTransliterator() {
        assertThrows(
                IllegalArgumentException.class,
                () -> {
                    Yosina.makeTransliterator("unknown-transliterator");
                });
    }

    @Test
    public void testChainedTransliterator() {
        // Create a simple chained transliterator manually
        ChainedTransliterator chained =
                new ChainedTransliterator(
                        // Just pass through for this test
                        input -> input,
                        input -> input);

        CharIterator result = chained.transliterate(Chars.of("test").iterator());
        String output = result.string();

        assertEquals("test", output);
    }
}
