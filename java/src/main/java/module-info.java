/**
 * Yosina Java - Japanese text transliteration library.
 *
 * <p>Java implementation of the Yosina Japanese text transliteration library, providing
 * comprehensive Japanese text transformation capabilities including:
 *
 * <ul>
 *   <li><b>Hiragana/Katakana composition</b>: Combine decomposed characters with voiced/semi-voiced
 *       marks
 *   <li><b>Character normalization</b>: Convert between different Unicode representations
 *   <li><b>Space normalization</b>: Standardize various space characters
 *   <li><b>Radical replacement</b>: Convert Kangxi radicals to equivalent CJK ideographs
 *   <li><b>Mathematical alphanumeric normalization</b>: Convert mathematical notation characters
 *   <li><b>Ideographic annotation handling</b>: Process traditional Chinese-to-Japanese translation
 *       marks
 *   <li><b>Old-style to new-style kanji conversion</b>: Transform traditional kanji forms
 *   <li><b>Hyphen normalization</b>: Handle various hyphen-like characters
 *   <li><b>IVS/SVS processing</b>: Handle Ideographic and Standardized Variation Sequences
 * </ul>
 *
 * <h2>Quick Start</h2>
 *
 * <pre>{@code
 * import io.yosina.Yosina;
 * import java.util.function.Function;
 *
 * // Create a simple transliterator
 * Function<String, String> transliterator = Yosina.makeTransliterator("circled-or-squared");
 *
 * // Use the transliterator
 * String input = "①②③ⒶⒷⒸ";  // circled numbers and letters
 * String result = transliterator.apply(input);  // "123ABC"
 * System.out.println(result);
 * }</pre>
 *
 * <h2>Available Transliterators</h2>
 *
 * <ul>
 *   <li>{@code hira-kata-composition}: Combines hiragana/katakana with voiced marks
 *   <li>{@code spaces}: Normalizes various space characters to U+0020
 *   <li>{@code radicals}: Converts Kangxi radicals to equivalent ideographs
 *   <li>{@code mathematical-alphanumerics}: Normalizes mathematical notation
 *   <li>{@code ideographic-annotations}: Handles ideographic annotation marks
 *   <li>{@code kanji-old-new}: Converts old-style kanji to modern forms
 *   <li>{@code hyphens}: Normalizes hyphen-like characters
 *   <li>{@code ivs-svs-base}: Processes variation sequences
 *   <li>{@code circled-or-squared}: Converts circled or squared alphanumeric characters to plain
 *       equivalents
 *   <li>{@code combined}: Expands combined characters into their individual character sequences
 * </ul>
 *
 * <h2>Chaining Multiple Transliterators</h2>
 *
 * <pre>{@code
 * import io.yosina.Yosina;
 * import java.util.List;
 * import java.util.function.Function;
 *
 * // Chain multiple transliterators
 * List<Yosina.TransliteratorConfig> configs = List.of(
 *     new Yosina.TransliteratorConfig("hira-kata-composition"),
 *     new Yosina.TransliteratorConfig("spaces"),
 *     new Yosina.TransliteratorConfig("kanji-old-new"),
 *     new Yosina.TransliteratorConfig("circled-or-squared"),
 *     new Yosina.TransliteratorConfig("combined")
 * );
 *
 * Function<String, String> transliterator = Yosina.makeTransliterator(configs);
 * String result = transliterator.apply("some japanese text");
 * }</pre>
 *
 * @since 0.1.0
 */
module io.yosina {
    requires java.base;

    exports io.yosina;
    exports io.yosina.transliterators;
}
