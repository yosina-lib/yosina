package examples;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;
import io.yosina.Yosina;
import io.yosina.transliterators.IvsSvsBaseTransliterator;
import io.yosina.transliterators.Jisx0201AndAlikeTransliterator;
import io.yosina.transliterators.ProlongedSoundMarksTransliterator;

/**
 * Configuration-based usage example for Yosina Java library.
 * This example demonstrates using direct transliterator configurations.
 */
public class ConfigBasedUsage {
    public static void main(String[] args) {
        System.out.println("=== Yosina Java Configuration-based Usage Example ===\n");

        // Create transliterator with direct configurations
        List<Yosina.TransliteratorConfig> configs = Arrays.asList(
                new Yosina.TransliteratorConfig("spaces"),
                new Yosina.TransliteratorConfig("prolonged-sound-marks",
                        new ProlongedSoundMarksTransliterator.Options()
                                .withReplaceProlongedMarksFollowingAlnums(true)),
                new Yosina.TransliteratorConfig("jisx0201-and-alike",
                        new Jisx0201AndAlikeTransliterator.Options())
        );

        Function<String, String> transliterator = Yosina.makeTransliterator(configs);

        System.out.println("--- Configuration-based Transliteration ---");

        // Test cases demonstrating different transformations
        String[][] testCases = {
            {"hello　world", "Space normalization"},
            {"カタカナーテスト", "Prolonged sound mark handling"},
            {"ＡＢＣ１２３", "Full-width conversion"},
            {"ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana conversion"}
        };

        for (String[] testCase : testCases) {
            String testText = testCase[0];
            String description = testCase[1];
            String result = transliterator.apply(testText);
            System.out.println(description + ":");
            System.out.println("  Input:  '" + testText + "'");
            System.out.println("  Output: '" + result + "'");
            System.out.println();
        }

        // Demonstrate individual transliterators
        System.out.println("--- Individual Transliterator Examples ---");

        // Spaces only
        Function<String, String> spacesOnly = Yosina.makeTransliterator(
                Arrays.asList(new Yosina.TransliteratorConfig("spaces")));
        String spaceTest = "hello　world　test";  // ideographic spaces
        System.out.println("Spaces only: '" + spaceTest + "' → '" + 
                spacesOnly.apply(spaceTest) + "'");

        // Kanji old-new only
        Function<String, String> kanjiOnly = Yosina.makeTransliterator(Arrays.asList(
                new Yosina.TransliteratorConfig("ivs-svs-base",
                        new IvsSvsBaseTransliterator.Options()
                                .withMode(IvsSvsBaseTransliterator.Mode.IVS_OR_SVS)
                                .withCharset(IvsSvsBaseTransliterator.Charset.UNIJIS_2004)),
                new Yosina.TransliteratorConfig("kanji-old-new"),
                new Yosina.TransliteratorConfig("ivs-svs-base",
                        new IvsSvsBaseTransliterator.Options()
                                .withMode(IvsSvsBaseTransliterator.Mode.BASE)
                                .withCharset(IvsSvsBaseTransliterator.Charset.UNIJIS_2004))
        ));
        String kanjiTest = "廣島檜";
        System.out.println("Kanji only: '" + kanjiTest + "' → '" + 
                kanjiOnly.apply(kanjiTest) + "'");

        // JIS X 0201 conversion only
        Function<String, String> jisx0201Only = Yosina.makeTransliterator(
                Arrays.asList(new Yosina.TransliteratorConfig("jisx0201-and-alike",
                        new Jisx0201AndAlikeTransliterator.Options())));
        String jisxTest = "ﾊﾛｰ ﾜｰﾙﾄﾞ";
        System.out.println("JIS X 0201 only: '" + jisxTest + "' → '" + 
                jisx0201Only.apply(jisxTest) + "'");
    }
}