package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.assertEquals;

import io.yosina.Chars;
import java.util.stream.Stream;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

public class RomanNumeralsTransliteratorTest {

    private static Stream<Arguments> uppercaseRomanNumeralsTestCases() {
        return Stream.of(
                Arguments.of("I", "Ⅰ", "Roman I"),
                Arguments.of("II", "Ⅱ", "Roman II"),
                Arguments.of("III", "Ⅲ", "Roman III"),
                Arguments.of("IV", "Ⅳ", "Roman IV"),
                Arguments.of("V", "Ⅴ", "Roman V"),
                Arguments.of("VI", "Ⅵ", "Roman VI"),
                Arguments.of("VII", "Ⅶ", "Roman VII"),
                Arguments.of("VIII", "Ⅷ", "Roman VIII"),
                Arguments.of("IX", "Ⅸ", "Roman IX"),
                Arguments.of("X", "Ⅹ", "Roman X"),
                Arguments.of("XI", "Ⅺ", "Roman XI"),
                Arguments.of("XII", "Ⅻ", "Roman XII"),
                Arguments.of("L", "Ⅼ", "Roman L"),
                Arguments.of("C", "Ⅽ", "Roman C"),
                Arguments.of("D", "Ⅾ", "Roman D"),
                Arguments.of("M", "Ⅿ", "Roman M"));
    }

    @ParameterizedTest
    @MethodSource("uppercaseRomanNumeralsTestCases")
    void testUppercaseRomanNumerals(String expected, String input, String description) {
        var transliterator = new RomanNumeralsTransliterator();
        var result = transliterator.transliterate(Chars.of(input).iterator());
        assertEquals(expected, result.string(), description);
    }

    private static Stream<Arguments> lowercaseRomanNumeralsTestCases() {
        return Stream.of(
                Arguments.of("i", "ⅰ", "Roman i"),
                Arguments.of("ii", "ⅱ", "Roman ii"),
                Arguments.of("iii", "ⅲ", "Roman iii"),
                Arguments.of("iv", "ⅳ", "Roman iv"),
                Arguments.of("v", "ⅴ", "Roman v"),
                Arguments.of("vi", "ⅵ", "Roman vi"),
                Arguments.of("vii", "ⅶ", "Roman vii"),
                Arguments.of("viii", "ⅷ", "Roman viii"),
                Arguments.of("ix", "ⅸ", "Roman ix"),
                Arguments.of("x", "ⅹ", "Roman x"),
                Arguments.of("xi", "ⅺ", "Roman xi"),
                Arguments.of("xii", "ⅻ", "Roman xii"),
                Arguments.of("l", "ⅼ", "Roman l"),
                Arguments.of("c", "ⅽ", "Roman c"),
                Arguments.of("d", "ⅾ", "Roman d"),
                Arguments.of("m", "ⅿ", "Roman m"));
    }

    @ParameterizedTest
    @MethodSource("lowercaseRomanNumeralsTestCases")
    void testLowercaseRomanNumerals(String expected, String input, String description) {
        var transliterator = new RomanNumeralsTransliterator();
        var result = transliterator.transliterate(Chars.of(input).iterator());
        assertEquals(expected, result.string(), description);
    }

    private static Stream<Arguments> mixedTextTestCases() {
        return Stream.of(
                Arguments.of("Year XII", "Year Ⅻ", "Year with Roman numeral"),
                Arguments.of("Chapter iv", "Chapter ⅳ", "Chapter with lowercase Roman"),
                Arguments.of("Section III.A", "Section Ⅲ.A", "Section with Roman and period"),
                Arguments.of("I II III", "Ⅰ Ⅱ Ⅲ", "Multiple uppercase Romans"),
                Arguments.of("i, ii, iii", "ⅰ, ⅱ, ⅲ", "Multiple lowercase Romans"));
    }

    @ParameterizedTest
    @MethodSource("mixedTextTestCases")
    void testMixedText(String expected, String input, String description) {
        var transliterator = new RomanNumeralsTransliterator();
        var result = transliterator.transliterate(Chars.of(input).iterator());
        assertEquals(expected, result.string(), description);
    }

    private static Stream<Arguments> edgeCasesTestCases() {
        return Stream.of(
                Arguments.of("", "", "Empty string"),
                Arguments.of("ABC123", "ABC123", "No Roman numerals"),
                Arguments.of("IIIIII", "ⅠⅡⅢ", "Consecutive Romans"));
    }

    @ParameterizedTest
    @MethodSource("edgeCasesTestCases")
    void testEdgeCases(String expected, String input, String description) {
        var transliterator = new RomanNumeralsTransliterator();
        var result = transliterator.transliterate(Chars.of(input).iterator());
        assertEquals(expected, result.string(), description);
    }
}
