package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.*;

import io.yosina.CharIterator;
import io.yosina.Chars;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

/** Tests for IvsSvsBaseTransliterator based on JavaScript test patterns. */
public class IvsSvsBaseTransliteratorTest {
    private static Stream<Arguments> ivsSvsBaseTestCases() {
        return Stream.of(
                Arguments.of(
                        "\u9038\udb40\udd00\u70ba\udb40\udd00",
                        new IvsSvsBaseTransliterator.Options(
                                IvsSvsBaseTransliterator.Mode.IVS_OR_SVS,
                                false,
                                IvsSvsBaseTransliterator.Charset.UNIJIS_2004,
                                false),
                        "\u9038\u70ba",
                        "Forward mappings with UNIJIS_2004"),
                Arguments.of(
                        "\u9038\udb40\udd00\u70ba\udb40\udd00",
                        new IvsSvsBaseTransliterator.Options(
                                IvsSvsBaseTransliterator.Mode.IVS_OR_SVS,
                                false,
                                IvsSvsBaseTransliterator.Charset.UNIJIS_90,
                                false),
                        "\u9038\u70ba",
                        "Forward mappings with UNIJIS_90"),
                Arguments.of(
                        "\u9038\u70ba",
                        new IvsSvsBaseTransliterator.Options(
                                IvsSvsBaseTransliterator.Mode.BASE,
                                false,
                                IvsSvsBaseTransliterator.Charset.UNIJIS_2004,
                                false),
                        "\u9038\udb40\udd00\u70ba\udb40\udd00",
                        "Reverse mappings with UNIJIS_2004"),
                Arguments.of(
                        "\u9038\u70ba",
                        new IvsSvsBaseTransliterator.Options(
                                IvsSvsBaseTransliterator.Mode.BASE,
                                false,
                                IvsSvsBaseTransliterator.Charset.UNIJIS_90,
                                false),
                        "\u9038\udb40\udd00\u70ba\udb40\udd00",
                        "Reverse mappings with UNIJIS_90"),
                Arguments.of(
                        "\u8fbb\udb40\udd01",
                        new IvsSvsBaseTransliterator.Options(
                                IvsSvsBaseTransliterator.Mode.IVS_OR_SVS,
                                false,
                                IvsSvsBaseTransliterator.Charset.UNIJIS_2004,
                                false),
                        "\u8fbb",
                        "U+8FBB with VS18, UNIJIS_2004"),
                Arguments.of(
                        "\u8fbb\udb40\udd00",
                        new IvsSvsBaseTransliterator.Options(
                                IvsSvsBaseTransliterator.Mode.IVS_OR_SVS,
                                false,
                                IvsSvsBaseTransliterator.Charset.UNIJIS_90,
                                false),
                        "\u8fbb",
                        "U+8FBB with VS18, UNIJIS_90"),
                Arguments.of(
                        "\u8fbb",
                        new IvsSvsBaseTransliterator.Options(
                                IvsSvsBaseTransliterator.Mode.BASE,
                                false,
                                IvsSvsBaseTransliterator.Charset.UNIJIS_2004,
                                false),
                        "\u8fbb\udb40\udd01",
                        "Test case for reverse specific kanji"),
                Arguments.of(
                        "\u8fbb",
                        new IvsSvsBaseTransliterator.Options(
                                IvsSvsBaseTransliterator.Mode.BASE,
                                false,
                                IvsSvsBaseTransliterator.Charset.UNIJIS_90,
                                false),
                        "\u8fbb\udb40\udd00",
                        "Test case for reverse specific kanji"),
                Arguments.of(
                        "\u8fbb\udb40\udd00",
                        new IvsSvsBaseTransliterator.Options(
                                IvsSvsBaseTransliterator.Mode.IVS_OR_SVS,
                                false,
                                IvsSvsBaseTransliterator.Charset.UNIJIS_2004,
                                false),
                        "\u8fbb\udb40\udd00",
                        "Test case for unchanged VS17"),
                Arguments.of(
                        "\u8fbb\udb40\udd01",
                        new IvsSvsBaseTransliterator.Options(
                                IvsSvsBaseTransliterator.Mode.IVS_OR_SVS,
                                false,
                                IvsSvsBaseTransliterator.Charset.UNIJIS_90,
                                false),
                        "\u8fbb\udb40\udd01",
                        "Test case for unchanged VS17"));
    }

    @ParameterizedTest(name = "IVS/SVS Base test case: {3}")
    @MethodSource("ivsSvsBaseTestCases")
    public void testIvsSvsBaseTransliterations(
            String expected,
            IvsSvsBaseTransliterator.Options options,
            String input,
            String description) {
        IvsSvsBaseTransliterator transliterator = new IvsSvsBaseTransliterator(options);

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @Test
    public void testIvsSvsBaseTransliteratorOptionsEquals() {
        IvsSvsBaseTransliterator.Options options1 =
                new IvsSvsBaseTransliterator.Options(
                        IvsSvsBaseTransliterator.Mode.IVS_OR_SVS,
                        false,
                        IvsSvsBaseTransliterator.Charset.UNIJIS_90,
                        true);
        IvsSvsBaseTransliterator.Options options2 =
                new IvsSvsBaseTransliterator.Options(
                        IvsSvsBaseTransliterator.Mode.IVS_OR_SVS,
                        false,
                        IvsSvsBaseTransliterator.Charset.UNIJIS_90,
                        true);
        IvsSvsBaseTransliterator.Options options3 =
                new IvsSvsBaseTransliterator.Options(
                        IvsSvsBaseTransliterator.Mode.BASE,
                        false,
                        IvsSvsBaseTransliterator.Charset.UNIJIS_90,
                        true);

        assertEquals(options1, options2);
        assertNotEquals(options1, options3);
        assertEquals(options1.hashCode(), options2.hashCode());
        assertNotEquals(options1.hashCode(), options3.hashCode());
    }
}
