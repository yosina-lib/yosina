package examples;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;
import io.yosina.TransliterationRecipe;
import io.yosina.Yosina;
import io.yosina.transliterators.IvsSvsBaseTransliterator;
import io.yosina.transliterators.Jisx0201AndAlikeTransliterator;
import io.yosina.transliterators.ProlongedSoundMarksTransliterator;

/**
 * Advanced usage example for Yosina Java library.
 * This example demonstrates complex text processing scenarios.
 */
public class AdvancedUsage {
    public static void main(String[] args) {
        System.out.println("=== Advanced Yosina Java Usage Examples ===\n");

        // 1. Web scraping text normalization
        System.out.println("1. Web Scraping Text Normalization");
        System.out.println("   (Typical use case: cleaning scraped Japanese web content)");

        TransliterationRecipe webScrapingRecipe = new TransliterationRecipe()
                .withKanjiOldNew(true)
                .withReplaceSpaces(true)
                .withReplaceSuspiciousHyphensToProlongedSoundMarks(true)
                .withReplaceIdeographicAnnotations(true)
                .withReplaceRadicals(true)
                .withCombineDecomposedHiraganasAndKatakanas(true);

        Function<String, String> normalizer = Yosina.makeTransliteratorFromRecipe(webScrapingRecipe);

        // Simulate messy web content
        String[][] messyContent = {
            {"これは　テスト です。", "Mixed spaces from different sources"},
            {"コンピューター-プログラム", "Suspicious hyphens in katakana"},
            {"古い漢字：廣島、檜、國", "Old-style kanji forms"},
            {"部首：⺅⻌⽊", "CJK radicals instead of regular kanji"}
        };

        for (String[] item : messyContent) {
            String text = item[0];
            String description = item[1];
            String cleaned = normalizer.apply(text);
            System.out.println("  " + description + ":");
            System.out.println("    Before: '" + text + "'");
            System.out.println("    After:  '" + cleaned + "'");
            System.out.println();
        }

        // 2. Document standardization
        System.out.println("2. Document Standardization");
        System.out.println("   (Use case: preparing documents for consistent formatting)");

        TransliterationRecipe documentRecipe = new TransliterationRecipe()
                .withToFullwidth(TransliterationRecipe.ToFullwidthOptions.ENABLED)
                .withReplaceSpaces(true)
                .withKanjiOldNew(true)
                .withCombineDecomposedHiraganasAndKatakanas(true);

        normalizer = Yosina.makeTransliteratorFromRecipe(documentRecipe);

        String[][] documentSamples = {
            {"Hello World 123", "ASCII text to full-width"},
            {"カ゛", "Decomposed katakana with combining mark"},
            {"檜原村", "Old kanji in place names"}
        };

        for (String[] item : documentSamples) {
            String text = item[0];
            String description = item[1];
            String standardized = normalizer.apply(text);
            System.out.println("  " + description + ":");
            System.out.println("    Input:  '" + text + "'");
            System.out.println("    Output: '" + standardized + "'");
            System.out.println();
        }

        // 3. Search index preparation
        System.out.println("3. Search Index Preparation");
        System.out.println("   (Use case: normalizing text for search engines)");

        TransliterationRecipe searchRecipe = new TransliterationRecipe()
                .withKanjiOldNew(true)
                .withReplaceSpaces(true)
                .withToHalfwidth(TransliterationRecipe.ToHalfwidthOptions.ENABLED)
                .withReplaceSuspiciousHyphensToProlongedSoundMarks(true);

        normalizer = Yosina.makeTransliteratorFromRecipe(searchRecipe);

        String[][] searchSamples = {
            {"東京スカイツリー", "Famous landmark name"},
            {"プログラミング言語", "Technical terms"},
            {"コンピューター-サイエンス", "Academic field with suspicious hyphen"}
        };

        for (String[] item : searchSamples) {
            String text = item[0];
            String description = item[1];
            String normalized = normalizer.apply(text);
            System.out.println("  " + description + ":");
            System.out.println("    Original:   '" + text + "'");
            System.out.println("    Normalized: '" + normalized + "'");
            System.out.println();
        }

        // 4. Custom pipeline example
        System.out.println("4. Custom Processing Pipeline");
        System.out.println("   (Use case: step-by-step text transformation)");

        // Create multiple transliterators for pipeline processing
        List<Yosina.TransliteratorConfig> spacesConfig = Arrays.asList(
                new Yosina.TransliteratorConfig("spaces")
        );

        List<Yosina.TransliteratorConfig> oldKanjiConfig = Arrays.asList(
                new Yosina.TransliteratorConfig("ivs-svs-base", 
                        new IvsSvsBaseTransliterator.Options()
                                .withMode(IvsSvsBaseTransliterator.Mode.IVS_OR_SVS)
                                .withCharset(IvsSvsBaseTransliterator.Charset.UNIJIS_2004)),
                new Yosina.TransliteratorConfig("kanji-old-new"),
                new Yosina.TransliteratorConfig("ivs-svs-base",
                        new IvsSvsBaseTransliterator.Options()
                                .withMode(IvsSvsBaseTransliterator.Mode.BASE)
                                .withCharset(IvsSvsBaseTransliterator.Charset.UNIJIS_2004))
        );

        List<Yosina.TransliteratorConfig> widthConfig = Arrays.asList(
                new Yosina.TransliteratorConfig("jisx0201-and-alike",
                        new Jisx0201AndAlikeTransliterator.Options()
                                .withFullwidthToHalfwidth(false)
                                .withU005cAsYenSign(false))
        );

        List<Yosina.TransliteratorConfig> prolongedSoundConfig = Arrays.asList(
                new Yosina.TransliteratorConfig("prolonged-sound-marks",
                        new ProlongedSoundMarksTransliterator.Options())
        );

        String[][] steps = {
            {"Spaces", null},
            {"Old Kanji", null},
            {"Width", null},
            {"ProlongedSoundMarks", null}
        };

        Function<String, String>[] transliterators = new Function[] {
            Yosina.makeTransliterator(spacesConfig),
            Yosina.makeTransliterator(oldKanjiConfig),
            Yosina.makeTransliterator(widthConfig),
            Yosina.makeTransliterator(prolongedSoundConfig)
        };

        String pipelineText = "hello\u3000world ﾃｽﾄ 檜-システム";
        String currentText = pipelineText;

        System.out.println("  Starting text: '" + currentText + "'");

        for (int i = 0; i < steps.length; i++) {
            String stepName = steps[i][0];
            String previousText = currentText;
            currentText = transliterators[i].apply(currentText);
            if (!previousText.equals(currentText)) {
                System.out.println("  After " + stepName + ": '" + currentText + "'");
            }
        }

        System.out.println("  Final result: '" + currentText + "'");

        // 5. Unicode normalization showcase
        System.out.println("\n5. Unicode Normalization Showcase");
        System.out.println("   (Demonstrating various Unicode edge cases)");

        TransliterationRecipe unicodeRecipe = new TransliterationRecipe()
                .withReplaceSpaces(true)
                .withReplaceMathematicalAlphanumerics(true)
                .withReplaceRadicals(true);

        normalizer = Yosina.makeTransliteratorFromRecipe(unicodeRecipe);

        String[][] unicodeSamples = {
            {"\u2003\u2002\u2000", "Various em/en spaces"},
            {"\u3000\u00a0\u202f", "Ideographic and narrow spaces"},
            {"⺅⻌⽊", "CJK radicals"},
            {"\uD835\uDC00\uD835\uDC01\uD835\uDC02", "Mathematical bold letters"}
        };

        System.out.println("\n   Processing text samples with character codes:\n");
        for (String[] item : unicodeSamples) {
            String text = item[0];
            String description = item[1];
            System.out.println("   " + description + ":");
            System.out.println("     Original: '" + text + "'");

            // Show character codes for clarity
            StringBuilder charCodes = new StringBuilder();
            for (int i = 0; i < text.length(); i++) {
                if (i > 0) charCodes.append(" ");
                charCodes.append(String.format("U+%04X", (int) text.charAt(i)));
            }
            System.out.println("     Codes:    " + charCodes);

            String normalized = normalizer.apply(text);
            System.out.println("     Result:   '" + normalized + "'");
            System.out.println();
        }

        // 6. Performance considerations
        System.out.println("6. Performance Considerations");
        System.out.println("   (Reusing transliterators for better performance)");

        TransliterationRecipe perfRecipe = new TransliterationRecipe()
                .withKanjiOldNew(true)
                .withReplaceSpaces(true);

        Function<String, String> perfTransliterator = 
                Yosina.makeTransliteratorFromRecipe(perfRecipe);

        // Simulate processing multiple texts
        String[] texts = {
            "これはテストです",
            "檜原村は美しい",
            "hello　world",
            "プログラミング"
        };

        System.out.println("  Processing " + texts.length + " texts with the same transliterator:");
        for (int i = 0; i < texts.length; i++) {
            String text = texts[i];
            String result = perfTransliterator.apply(text);
            System.out.println("    " + (i + 1) + ": '" + text + "' → '" + result + "'");
        }

        System.out.println("\n=== Advanced Examples Complete ===");
    }
}