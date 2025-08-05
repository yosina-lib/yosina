package io.yosina.transliterators;

import static org.junit.jupiter.api.Assertions.*;

import io.yosina.CharIterator;
import io.yosina.Chars;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Stream;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

/** Tests for CircledOrSquared transliterator. */
public class CircledOrSquaredTest {

    private static Stream<Arguments> circledNumberTestCases() {
        return Stream.of(
                Arguments.of("(1)", "①", "Circled number 1"),
                Arguments.of("(2)", "②", "Circled number 2"),
                Arguments.of("(20)", "⑳", "Circled number 20"),
                Arguments.of("(0)", "⓪", "Circled number 0"));
    }

    private static Stream<Arguments> circledLetterTestCases() {
        return Stream.of(
                Arguments.of("(A)", "Ⓐ", "Circled uppercase A"),
                Arguments.of("(Z)", "Ⓩ", "Circled uppercase Z"),
                Arguments.of("(a)", "ⓐ", "Circled lowercase a"),
                Arguments.of("(z)", "ⓩ", "Circled lowercase z"));
    }

    private static Stream<Arguments> circledKanjiTestCases() {
        return Stream.of(
                Arguments.of("(一)", "㊀", "Circled kanji ichi"),
                Arguments.of("(月)", "㊊", "Circled kanji getsu"),
                Arguments.of("(夜)", "㊰", "Circled kanji yoru"));
    }

    private static Stream<Arguments> circledKatakanaTestCases() {
        return Stream.of(
                Arguments.of("(ア)", "㋐", "Circled katakana a"),
                Arguments.of("(ヲ)", "㋾", "Circled katakana wo"));
    }

    private static Stream<Arguments> squaredLetterTestCases() {
        return Stream.of(
                Arguments.of("[A]", "🅰", "Squared letter A"),
                Arguments.of("[Z]", "🆉", "Squared letter Z"));
    }

    private static Stream<Arguments> regionalIndicatorTestCases() {
        return Stream.of(
                Arguments.of("[A]", "🇦", "Regional indicator A"),
                Arguments.of("[Z]", "🇿", "Regional indicator Z"));
    }

    @ParameterizedTest(name = "Circled number test: {2}")
    @MethodSource("circledNumberTestCases")
    public void testCircledNumbers(String expected, String input, String description) {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @ParameterizedTest(name = "Circled letter test: {2}")
    @MethodSource("circledLetterTestCases")
    public void testCircledLetters(String expected, String input, String description) {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @ParameterizedTest(name = "Circled kanji test: {2}")
    @MethodSource("circledKanjiTestCases")
    public void testCircledKanji(String expected, String input, String description) {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @ParameterizedTest(name = "Circled katakana test: {2}")
    @MethodSource("circledKatakanaTestCases")
    public void testCircledKatakana(String expected, String input, String description) {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @ParameterizedTest(name = "Squared letter test: {2}")
    @MethodSource("squaredLetterTestCases")
    public void testSquaredLetters(String expected, String input, String description) {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @ParameterizedTest(name = "Regional indicator test: {2}")
    @MethodSource("regionalIndicatorTestCases")
    public void testRegionalIndicators(String expected, String input, String description) {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, description);
    }

    @Test
    public void testEmojiExclusionDefault() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "🆂🅾🆂";
        String expected = "[S][O][S]";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Emoji exclusion default behavior");
    }

    @Test
    public void testEmptyString() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        CharIterator result = transliterator.transliterate(Chars.of("").iterator());
        String output = result.string();

        assertEquals("", output);
    }

    @Test
    public void testUnmappedCharacters() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "hello world 123 abc こんにちは";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(input, output, "Unmapped characters should remain unchanged");
    }

    @Test
    public void testMixedContent() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "Hello ① World Ⓐ Test";
        String expected = "Hello (1) World (A) Test";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Mixed content with circled/squared characters");
    }

    @Test
    public void testSequenceOfCircledNumbers() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "①②③④⑤";
        String expected = "(1)(2)(3)(4)(5)";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Sequence of circled numbers");
    }

    @Test
    public void testSequenceOfCircledLetters() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "ⒶⒷⒸ";
        String expected = "(A)(B)(C)";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Sequence of circled letters");
    }

    @Test
    public void testMixedCirclesAndSquares() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "①🅰②🅱";
        String expected = "(1)[A](2)[B]";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Mixed circles and squares");
    }

    @Test
    public void testCircledKanjiSequence() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "㊀㊁㊂㊃㊄";
        String expected = "(一)(二)(三)(四)(五)";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Circled kanji sequence");
    }

    @Test
    public void testJapaneseTextWithCircledElements() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "項目①は重要で、項目②は補足です。";
        String expected = "項目(1)は重要で、項目(2)は補足です。";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Japanese text with circled elements");
    }

    @Test
    public void testNumberedListWithCircledNumbers() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "①準備\n②実行\n③確認";
        String expected = "(1)準備\n(2)実行\n(3)確認";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Numbered list with circled numbers");
    }

    @Test
    public void testLargeCircledNumbers() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "㊱㊲㊳";
        String expected = "(36)(37)(38)";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Large circled numbers");
    }

    @Test
    public void testCircledNumbersUpTo50() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "㊿";
        String expected = "(50)";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Circled numbers up to 50");
    }

    @Test
    public void testSpecialCircledCharacters() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "🄴🅂";
        String expected = "[E][S]";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Special circled characters");
    }

    @Test
    public void testIncludeEmojisTrue() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "🆘";
        String expected = "[SOS]";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Include emojis true");
    }

    @Test
    public void testIncludeEmojisFalse() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(false));

        String input = "🆘";
        String expected = "🆘";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Include emojis false");
    }

    @Test
    public void testMixedEmojiAndNonEmojiWithIncludeEmojisTrue() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "①🅰②";
        String expected = "(1)[A](2)";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Mixed emoji and non-emoji with include emojis true");
    }

    @Test
    public void testMixedEmojiAndNonEmojiWithIncludeEmojisFalse() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(false));

        String input = "①🅰②";
        String expected = "(1)[A](2)";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Mixed emoji and non-emoji with include emojis false");
    }

    @Test
    public void testCustomCircleTemplate() {
        Map<String, String> templates =
                Map.of(
                        "circle", "〔?〕",
                        "square", "[?]");
        CircledOrSquared transliterator =
                new CircledOrSquared(
                        new CircledOrSquared.Options()
                                .withIncludeEmojis(true)
                                .withTemplates(
                                        Optional.of(templates.get("circle")),
                                        Optional.of(templates.get("square"))));

        String input = "①";
        String expected = "〔1〕";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Custom circle template");
    }

    @Test
    public void testCustomSquareTemplate() {
        Map<String, String> templates =
                Map.of(
                        "circle", "(?)",
                        "square", "【?】");
        CircledOrSquared transliterator =
                new CircledOrSquared(
                        new CircledOrSquared.Options()
                                .withIncludeEmojis(true)
                                .withTemplates(
                                        Optional.of(templates.get("circle")),
                                        Optional.of(templates.get("square"))));

        String input = "🅰";
        String expected = "【A】";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Custom square template");
    }

    @Test
    public void testCustomTemplatesWithKanji() {
        Map<String, String> templates =
                Map.of(
                        "circle", "〔?〕",
                        "square", "[?]");
        CircledOrSquared transliterator =
                new CircledOrSquared(
                        new CircledOrSquared.Options()
                                .withIncludeEmojis(true)
                                .withTemplates(
                                        Optional.of(templates.get("circle")),
                                        Optional.of(templates.get("square"))));

        String input = "㊀";
        String expected = "〔一〕";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Custom templates with kanji");
    }

    @Test
    public void testMixedCharactersWithCustomTemplates() {
        Map<String, String> templates =
                Map.of(
                        "circle", "〔?〕",
                        "square", "【?】");
        CircledOrSquared transliterator =
                new CircledOrSquared(
                        new CircledOrSquared.Options()
                                .withIncludeEmojis(true)
                                .withTemplates(
                                        Optional.of(templates.get("circle")),
                                        Optional.of(templates.get("square"))));

        String input = "①🅰②";
        String expected = "〔1〕【A】〔2〕";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Mixed characters with custom templates");
    }

    @Test
    public void testUnicodeCharactersPreserved() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "こんにちは①世界🅰です";
        String expected = "こんにちは(1)世界[A]です";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Unicode characters should be preserved");
    }

    @Test
    public void testOtherEmojiPreserved() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "😀①😊";
        String expected = "😀(1)😊";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());
        String output = result.string();

        assertEquals(expected, output, "Other emoji should be preserved");
    }

    @Test
    public void testIteratorProperties() {
        CircledOrSquared transliterator =
                new CircledOrSquared(new CircledOrSquared.Options().withIncludeEmojis(true));

        String input = "test①data";
        CharIterator result = transliterator.transliterate(Chars.of(input).iterator());

        assertNotNull(result);
        assertTrue(result.hasNext());
    }
}
