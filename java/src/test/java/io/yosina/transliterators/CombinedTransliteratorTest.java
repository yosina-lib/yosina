package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.*;

import io.yosina.CharIterator;
import io.yosina.Chars;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

/** Tests for CombinedTransliterator transliterator. */
public class CombinedTransliteratorTest {

    private static Stream<Arguments> controlCharacterTestCases() {
        return Stream.of(
                Arguments.of("NUL", "␀", "Null symbol to NUL"),
                Arguments.of("SOH", "␁", "Start of heading to SOH"),
                Arguments.of("STX", "␂", "Start of text to STX"),
                Arguments.of("BS", "␈", "Backspace to BS"),
                Arguments.of("HT", "␉", "Horizontal tab to HT"),
                Arguments.of("CR", "␍", "Carriage return to CR"),
                Arguments.of("SP", "␠", "Space symbol to SP"),
                Arguments.of("DEL", "␡", "Delete symbol to DEL"));
    }

    private static Stream<Arguments> parenthesizedNumberTestCases() {
        return Stream.of(
                Arguments.of("(1)", "⑴", "Parenthesized number 1"),
                Arguments.of("(5)", "⑸", "Parenthesized number 5"),
                Arguments.of("(10)", "⑽", "Parenthesized number 10"),
                Arguments.of("(20)", "⒇", "Parenthesized number 20"));
    }

    private static Stream<Arguments> periodNumberTestCases() {
        return Stream.of(
                Arguments.of("1.", "⒈", "Period number 1"),
                Arguments.of("10.", "⒑", "Period number 10"),
                Arguments.of("20.", "⒛", "Period number 20"));
    }

    private static Stream<Arguments> parenthesizedLetterTestCases() {
        return Stream.of(
                Arguments.of("(a)", "⒜", "Parenthesized letter a"),
                Arguments.of("(z)", "⒵", "Parenthesized letter z"));
    }

    private static Stream<Arguments> parenthesizedKanjiTestCases() {
        return Stream.of(
                Arguments.of("(一)", "㈠", "Parenthesized kanji ichi"),
                Arguments.of("(月)", "㈪", "Parenthesized kanji getsu"),
                Arguments.of("(株)", "㈱", "Parenthesized kanji kabu"));
    }

    private static Stream<Arguments> japaneseUnitTestCases() {
        return Stream.of(
                Arguments.of("アパート", "㌀", "Japanese unit apaato"),
                Arguments.of("キロ", "㌔", "Japanese unit kiro"),
                Arguments.of("メートル", "㍍", "Japanese unit meetoru"));
    }

    private static Stream<Arguments> scientificUnitTestCases() {
        return Stream.of(
                Arguments.of("hPa", "㍱", "Scientific unit hPa"),
                Arguments.of("kHz", "㎑", "Scientific unit kHz"),
                Arguments.of("kg", "㎏", "Scientific unit kg"));
    }

    @ParameterizedTest(name = "Control character test: {2}")
    @MethodSource("controlCharacterTestCases")
    public void testControlCharacterMappings(String expected, String input, String description) {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @ParameterizedTest(name = "Parenthesized number test: {2}")
    @MethodSource("parenthesizedNumberTestCases")
    public void testParenthesizedNumbers(String expected, String input, String description) {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @ParameterizedTest(name = "Period number test: {2}")
    @MethodSource("periodNumberTestCases")
    public void testPeriodNumbers(String expected, String input, String description) {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @ParameterizedTest(name = "Parenthesized letter test: {2}")
    @MethodSource("parenthesizedLetterTestCases")
    public void testParenthesizedLetters(String expected, String input, String description) {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @ParameterizedTest(name = "Parenthesized kanji test: {2}")
    @MethodSource("parenthesizedKanjiTestCases")
    public void testParenthesizedKanji(String expected, String input, String description) {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @ParameterizedTest(name = "Japanese unit test: {2}")
    @MethodSource("japaneseUnitTestCases")
    public void testJapaneseUnits(String expected, String input, String description) {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @ParameterizedTest(name = "Scientific unit test: {2}")
    @MethodSource("scientificUnitTestCases")
    public void testScientificUnits(String expected, String input, String description) {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @Test
    public void testCombinedControlAndNumbers() {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        String input = "␉⑴␠⒈";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals("HT(1)SP1.", output, "CombinedTransliterator control and number characters");
    }

    @Test
    public void testCombinedWithRegularText() {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        String input = "Hello ⑴ World ␉";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(
                "Hello (1) World HT",
                output,
                "CombinedTransliterator characters with regular text");
    }

    @Test
    public void testEmptyString() {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        CharIterator result = transliterator.transliterate(Chars.of("").iterator());
        String output = result.string();

        assertEquals("", output);
    }

    @Test
    public void testUnmappedCharacters() {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        String input = "hello world 123 abc こんにちは";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(input, output, "Unmapped characters should remain unchanged");
    }

    @Test
    public void testSequenceOfCombinedCharacters() {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        String input = "␀␁␂␃␄";
        String expected = "NULSOHSTXETXEOT";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Sequence of combined characters");
    }

    @Test
    public void testJapaneseMonths() {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        String input = "㋀㋁㋂";
        String expected = "1月2月3月";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Japanese month characters");
    }

    @Test
    public void testJapaneseUnitsCombinations() {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        String input = "㌀㌁㌂";
        String expected = "アパートアルファアンペア";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Japanese unit combinations");
    }

    @Test
    public void testScientificMeasurements() {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        String input = "\u3378\u3379\u337a";
        String expected = "dm2dm3IU";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Scientific measurement units");
    }

    @Test
    public void testMixedContent() {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        String input = "Text ⑴ with ␉ combined ㈱ characters ㍍";
        String expected = "Text (1) with HT combined (株) characters メートル";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Mixed content with combined characters");
    }

    @Test
    public void testUnicodeCharactersPreserved() {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        String input = "こんにちは⑴世界␉です";
        String expected = "こんにちは(1)世界HTです";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Unicode characters should be preserved");
    }

    @Test
    public void testNewlineAndTabPreserved() {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        String input = "Line1\nLine2\tTab";
        String expected = "Line1\nLine2\tTab";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Newlines and tabs should be preserved");
    }

    @Test
    public void testIteratorProperties() {
        CombinedTransliterator transliterator = new CombinedTransliterator();

        String input = "test⑴data";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        assertNotNull(result);
        assertTrue(result.hasNext());
    }
}
