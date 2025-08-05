package io.yosina;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

public class CodePointTupleTest {

    public static Stream<Arguments> provideCodePointTuples() {
        return Stream.of(
                Arguments.of(0x0041),
                Arguments.of(0x3000),
                Arguments.of(0x3040),
                Arguments.of(0x3080));
    }

    @ParameterizedTest
    @MethodSource("provideCodePointTuples")
    public void testFlyweight(int expected) {
        // Create a CodePointTuple with a single code point
        CodePointTuple tuple = CodePointTuple.of(expected); // 一
        assertEquals(expected, tuple.get(0));
    }

    @Test
    public void testCreation() {
        // Test creating a CodePointTuple with a single code point
        CodePointTuple single = CodePointTuple.of(0x4e00);
        assertEquals(0x4e00, single.get(0));

        // Test creating a CodePointTuple with a base character and variation selector
        CodePointTuple combined = CodePointTuple.of(0x4e00, 0xfe00); // 一 + vs1
        assertEquals(0x4e00, combined.get(0));
        assertEquals(0xfe00, combined.get(1));
    }

    @Test
    public void testEqualityAndHashCode() {
        // Test equality of CodePointTuples
        CodePointTuple tuple1 = CodePointTuple.of(0x9038, 0xe0100);
        CodePointTuple tuple2 = CodePointTuple.of(0x9038, 0xe0100);
        CodePointTuple tuple3 = CodePointTuple.of(0x9038); // Different variation selector
        CodePointTuple tuple4 = CodePointTuple.of(); // Different variation selector
        assertEquals(tuple1, tuple2);
        assertEquals(tuple1.hashCode(), tuple2.hashCode());
        assertNotEquals(tuple1, tuple3);
        assertNotEquals(tuple1, tuple4);
    }

    @Test
    public void testComparison() {
        // Test comparison of CodePointTuples
        CodePointTuple tuple1 = CodePointTuple.of(0x9038, 0xe0100);
        CodePointTuple tuple2 = CodePointTuple.of(0x9038, 0xe0101); // Different variation selector
        CodePointTuple tuple3 = CodePointTuple.of(0x9038); // Different variation selector
        CodePointTuple tuple4 = CodePointTuple.of(); // Different variation selector
        assertEquals(-1, tuple1.compareTo(tuple2));
        assertEquals(1, tuple2.compareTo(tuple1));
        assertEquals(
                0, tuple1.compareTo(tuple1)); // Same base code point, different variation selector
        assertEquals(
                0, tuple2.compareTo(tuple2)); // Same base code point, different variation selector
        assertEquals(
                1, tuple1.compareTo(tuple4)); // Same base code point, different variation selector
        assertEquals(
                1, tuple2.compareTo(tuple4)); // Same base code point, different variation selector
        assertEquals(-1, tuple3.compareTo(tuple1));
        assertEquals(-1, tuple3.compareTo(tuple1));
        assertEquals(
                -1, tuple4.compareTo(tuple1)); // Same base code point, different variation selector
        assertEquals(
                -1, tuple4.compareTo(tuple2)); // Same base code point, different variation selector
        assertEquals(1, tuple1.compareTo(tuple3));
        assertEquals(0, tuple3.compareTo(tuple3)); // Same base code point
        assertEquals(-1, tuple3.compareTo(tuple2));
        assertEquals(1, tuple2.compareTo(tuple3));
    }
}
