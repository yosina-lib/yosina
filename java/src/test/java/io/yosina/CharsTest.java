package io.yosina;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertIterableEquals;

import java.util.List;
import java.util.NoSuchElementException;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

public class CharsTest {
    private static Stream<Arguments> casesForCharList() {
        return Stream.of(
                Arguments.of(
                        List.of(
                                new Char(CodePointTuple.of('H'), 0, null),
                                new Char(CodePointTuple.of('e'), 1, null),
                                new Char(CodePointTuple.of('l'), 2, null),
                                new Char(CodePointTuple.of('l'), 3, null),
                                new Char(CodePointTuple.of('o'), 4, null),
                                new Char(CodePointTuple.SENTINEL, 5, null)),
                        "Hello"),
                Arguments.of(
                        List.of(
                                new Char(CodePointTuple.of(0x8fbb, 0xe0101), 0, null),
                                new Char(CodePointTuple.SENTINEL, 3, null)),
                        "\u8fbb\udb40\udd01"));
    }

    @ParameterizedTest()
    @MethodSource("casesForCharList")
    public void testCharList(List<Char> expected, String input) {
        assertIterableEquals(expected, Chars.of(input).toList());
    }

    private static Stream<Arguments> casesForStringFromChars() {
        return Stream.of(
                Arguments.of("H e l l o ", "Hello", Long.MAX_VALUE),
                Arguments.of("H e l l o ", "Hello", 2L),
                Arguments.of("H e l l o ", "Hello", 0L),
                Arguments.of("H e l l o ", "Hello", 5L));
    }

    @ParameterizedTest()
    @MethodSource("casesForStringFromChars")
    public void testStringFromChars(String expected, String input, long sizeHint) {
        // Example test case for stringFromChars
        CharIterator iterator =
                new CharIterator() {
                    private int index = 0;

                    @Override
                    public boolean hasNext() {
                        return index <= input.length();
                    }

                    @Override
                    public Char next() {
                        if (index > input.length()) {
                            throw new NoSuchElementException();
                        } else if (index == input.length()) {
                            return new Char(
                                    CodePointTuple.SENTINEL,
                                    index++,
                                    null); // Return sentinel at the end
                        } else {
                            return new Char(
                                    CodePointTuple.of(input.codePointAt(index), 0x20),
                                    index++,
                                    null);
                        }
                    }

                    @Override
                    public long estimateSize() {
                        return sizeHint;
                    }
                };
        assertEquals(expected, iterator.string());
    }

    @Test
    public void testCharWithVariationSelector() {
        final int baseChar = 0x4E00; // 一
        final int variationSelector = 0xFE00; // VS1

        Char c = new Char(CodePointTuple.of(baseChar, variationSelector), 0, null);

        assertEquals(baseChar, c.get().get(0));
        assertEquals(variationSelector, c.get().get(1));
        assertFalse(c.isSentinel());

        String str = c.get().toString();
        assertEquals(2, str.length()); // Should contain both base char and variation selector
    }
}
