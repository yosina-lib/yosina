package io.yosina;

import static org.junit.jupiter.api.Assertions.*;

import io.yosina.transliterators.CircledOrSquaredTransliterator;
import io.yosina.transliterators.HiraKataCompositionTransliterator;
import io.yosina.transliterators.HyphensTransliterator;
import io.yosina.transliterators.IvsSvsBaseTransliterator;
import io.yosina.transliterators.Jisx0201AndAlikeTransliterator;
import io.yosina.transliterators.ProlongedSoundMarksTransliterator;
import java.util.List;
import java.util.Optional;
import java.util.function.Function;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;

/** Comprehensive tests for TransliterationRecipe functionality. */
public class TransliterationRecipeTest {

    private TransliterationRecipe recipe;

    @BeforeEach
    public void setUp() {
        recipe = new TransliterationRecipe();
    }

    @Nested
    class BasicRecipe {
        @Test
        public void testEmptyRecipe() {
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();
            assertNotNull(configs);
            assertTrue(configs.isEmpty(), "Empty recipe should produce empty config list");
        }

        @Test
        public void testDefaultValues() {
            assertFalse(recipe.isKanjiOldNew());
            assertFalse(recipe.isReplaceSuspiciousHyphensToProlongedSoundMarks());
            assertFalse(recipe.isReplaceCombinedCharacters());
            assertFalse(recipe.getReplaceCircledOrSquaredCharacters().isEnabled());
            assertFalse(recipe.isReplaceIdeographicAnnotations());
            assertFalse(recipe.isReplaceRadicals());
            assertFalse(recipe.isReplaceSpaces());
            assertFalse(recipe.getReplaceHyphens().isEnabled());
            assertFalse(recipe.isReplaceMathematicalAlphanumerics());
            assertFalse(recipe.isCombineDecomposedHiraganasAndKatakanas());
            assertFalse(recipe.getToFullwidth().isEnabled());
            assertFalse(recipe.getToHalfwidth().isEnabled());
            assertFalse(recipe.getRemoveIvsSvs().isEnabled());
            assertEquals(IvsSvsBaseTransliterator.Charset.UNIJIS_2004, recipe.getCharset());
        }
    }

    @Nested
    class IndividualTransliterators {
        @Test
        public void testKanjiOldNew() {
            recipe.withKanjiOldNew(true);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            // Should contain kanji-old-new and IVS/SVS configurations
            assertTrue(containsConfig(configs, "kanji-old-new"), "Should contain kanji-old-new");
            assertTrue(containsConfig(configs, "ivs-svs-base"), "Should contain ivs-svs-base");

            // Should have at least 3 configs: ivs-or-svs, kanji-old-new, base
            assertTrue(configs.size() >= 3, "Should have multiple configs for kanji-old-new");
        }

        @Test
        public void testProlongedSoundMarks() {
            recipe.withReplaceSuspiciousHyphensToProlongedSoundMarks(true);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            assertTrue(containsConfig(configs, "prolonged-sound-marks"));

            Yosina.TransliteratorConfig config = findConfig(configs, "prolonged-sound-marks");
            assertTrue(config.getOptions().isPresent());
            assertEquals(
                    new ProlongedSoundMarksTransliterator.Options()
                            .withReplaceProlongedMarksFollowingAlnums(true),
                    config.getOptions().get());
        }

        @Test
        public void testCircledOrSquared() {
            recipe.withReplaceCircledOrSquaredCharacters(
                    TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.ENABLED);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            assertTrue(containsConfig(configs, "circled-or-squared"));
            Yosina.TransliteratorConfig config = findConfig(configs, "circled-or-squared");
            assertTrue(config.getOptions().isPresent());
            assertTrue(config.getOptions().get() instanceof CircledOrSquaredTransliterator.Options);
            CircledOrSquaredTransliterator.Options options =
                    (CircledOrSquaredTransliterator.Options) config.getOptions().get();
            assertTrue(options.isIncludeEmojis());
        }

        @Test
        public void testCircledOrSquaredExcludeEmojis() {
            recipe.withReplaceCircledOrSquaredCharacters(
                    TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.EXCLUDE_EMOJIS);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            assertTrue(containsConfig(configs, "circled-or-squared"));
            Yosina.TransliteratorConfig config = findConfig(configs, "circled-or-squared");
            assertTrue(config.getOptions().isPresent());
            assertTrue(config.getOptions().get() instanceof CircledOrSquaredTransliterator.Options);
            CircledOrSquaredTransliterator.Options options =
                    (CircledOrSquaredTransliterator.Options) config.getOptions().get();
            assertFalse(options.isIncludeEmojis());
        }

        @Test
        public void testCombined() {
            recipe.withReplaceCombinedCharacters(true);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            assertTrue(containsConfig(configs, "combined"));
        }

        @Test
        public void testIdeographicAnnotations() {
            recipe.withReplaceIdeographicAnnotations(true);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();
            assertTrue(containsConfig(configs, "ideographic-annotations"));
        }

        @Test
        public void testRadicals() {
            recipe.withReplaceRadicals(true);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();
            assertTrue(containsConfig(configs, "radicals"));
        }

        @Test
        public void testSpaces() {
            recipe.withReplaceSpaces(true);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();
            assertTrue(containsConfig(configs, "spaces"));
        }

        @Test
        public void testMathematicalAlphanumerics() {
            recipe.withReplaceMathematicalAlphanumerics(true);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();
            assertTrue(containsConfig(configs, "mathematical-alphanumerics"));
        }

        @Test
        public void testHiraKataComposition() {
            recipe.withCombineDecomposedHiraganasAndKatakanas(true);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            assertTrue(containsConfig(configs, "hira-kata-composition"));
            Yosina.TransliteratorConfig config = findConfig(configs, "hira-kata-composition");
            assertTrue(config.getOptions().isPresent());
            assertTrue(
                    config.getOptions().get() instanceof HiraKataCompositionTransliterator.Options);
            HiraKataCompositionTransliterator.Options options =
                    (HiraKataCompositionTransliterator.Options) config.getOptions().get();
            assertTrue(options.isComposeNonCombiningMarks());
        }
    }

    @Nested
    class ComplexOptions {
        @Test
        public void testHyphensDefaultPrecedence() {
            recipe.withReplaceHyphens(TransliterationRecipe.ReplaceHyphensOptions.ENABLED);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            assertTrue(containsConfig(configs, "hyphens"));
            Yosina.TransliteratorConfig config = findConfig(configs, "hyphens");
            assertTrue(config.getOptions().isPresent());
            assertTrue(config.getOptions().get() instanceof HyphensTransliterator.Options);
            HyphensTransliterator.Options options =
                    (HyphensTransliterator.Options) config.getOptions().get();
            assertIterableEquals(
                    List.of(
                            HyphensTransliterator.Mapping.JISX0208_90_WINDOWS,
                            HyphensTransliterator.Mapping.JISX0201),
                    options.getPrecedence());
        }

        @Test
        public void testHyphensCustomPrecedence() {
            List<HyphensTransliterator.Mapping> customPrecedence =
                    List.of(
                            HyphensTransliterator.Mapping.JISX0201,
                            HyphensTransliterator.Mapping.ASCII);

            recipe.withReplaceHyphens(
                    TransliterationRecipe.ReplaceHyphensOptions.withPrecedence(customPrecedence));
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            Yosina.TransliteratorConfig config = findConfig(configs, "hyphens");
            assertTrue(config.getOptions().isPresent());
            assertTrue(config.getOptions().get() instanceof HyphensTransliterator.Options);
            HyphensTransliterator.Options options =
                    (HyphensTransliterator.Options) config.getOptions().get();
            assertIterableEquals(customPrecedence, options.getPrecedence());
        }

        @Test
        public void testToFullwidthBasic() {
            recipe.withToFullwidth(TransliterationRecipe.ToFullwidthOptions.ENABLED);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            assertTrue(containsConfig(configs, "jisx0201-and-alike"));
            Yosina.TransliteratorConfig config = findConfig(configs, "jisx0201-and-alike");
            assertTrue(config.getOptions().isPresent());
            assertTrue(config.getOptions().get() instanceof Jisx0201AndAlikeTransliterator.Options);
            Jisx0201AndAlikeTransliterator.Options options =
                    (Jisx0201AndAlikeTransliterator.Options) config.getOptions().get();
            assertFalse(options.isFullwidthToHalfwidth());
            assertFalse(options.isU005cAsYenSign().get());
        }

        @Test
        public void testToFullwidthYenSign() {
            recipe.withToFullwidth(TransliterationRecipe.ToFullwidthOptions.U005C_AS_YEN_SIGN);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            Yosina.TransliteratorConfig config = findConfig(configs, "jisx0201-and-alike");
            assertTrue(config.getOptions().isPresent());
            assertTrue(config.getOptions().get() instanceof Jisx0201AndAlikeTransliterator.Options);
            Jisx0201AndAlikeTransliterator.Options options =
                    (Jisx0201AndAlikeTransliterator.Options) config.getOptions().get();
            assertTrue(options.isU005cAsYenSign().get());
        }

        @Test
        public void testToHalfwidthBasic() {
            recipe.withToHalfwidth(TransliterationRecipe.ToHalfwidthOptions.ENABLED);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            Yosina.TransliteratorConfig config = findConfig(configs, "jisx0201-and-alike");
            assertTrue(config.getOptions().isPresent());
            assertTrue(config.getOptions().get() instanceof Jisx0201AndAlikeTransliterator.Options);
            Jisx0201AndAlikeTransliterator.Options options =
                    (Jisx0201AndAlikeTransliterator.Options) config.getOptions().get();
            assertTrue(options.isFullwidthToHalfwidth());
            assertTrue(options.isConvertGL());
            assertFalse(options.isConvertGR());
        }

        @Test
        public void testToHalfwidthHankakuKana() {
            recipe.withToHalfwidth(TransliterationRecipe.ToHalfwidthOptions.HANKAKU_KANA);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            Yosina.TransliteratorConfig config = findConfig(configs, "jisx0201-and-alike");
            assertTrue(config.getOptions().isPresent());
            assertTrue(config.getOptions().get() instanceof Jisx0201AndAlikeTransliterator.Options);
            Jisx0201AndAlikeTransliterator.Options options =
                    (Jisx0201AndAlikeTransliterator.Options) config.getOptions().get();
            assertTrue(options.isConvertGR());
        }

        @Test
        public void testRemoveIvsSvsBasic() {
            recipe.withRemoveIvsSvs(TransliterationRecipe.RemoveIvsSvsOptions.ENABLED);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            // Should have two ivs-svs-base configs
            long ivsSvsCount =
                    configs.stream().filter(c -> c.getName().equals("ivs-svs-base")).count();
            assertEquals(2, ivsSvsCount);

            // Check modes
            List<IvsSvsBaseTransliterator.Options> ivsSvsConfigs =
                    configs.stream()
                            .filter(
                                    c ->
                                            c.getName().equals("ivs-svs-base")
                                                    && c.getOptions().isPresent()
                                                    && c.getOptions().get()
                                                            instanceof
                                                            IvsSvsBaseTransliterator.Options)
                            .map(c -> (IvsSvsBaseTransliterator.Options) c.getOptions().get())
                            .toList();

            boolean hasIvsOrSvs =
                    ivsSvsConfigs.stream()
                            .anyMatch(
                                    config ->
                                            config.getMode()
                                                    == IvsSvsBaseTransliterator.Mode.IVS_OR_SVS);
            boolean hasBase =
                    ivsSvsConfigs.stream()
                            .anyMatch(
                                    config ->
                                            config.getMode() == IvsSvsBaseTransliterator.Mode.BASE);
            assertTrue(hasIvsOrSvs);
            assertTrue(hasBase);

            // Check drop_selectors_altogether is false for basic mode
            Optional<IvsSvsBaseTransliterator.Options> baseConfig =
                    ivsSvsConfigs.stream()
                            .filter(
                                    config ->
                                            config.getMode() == IvsSvsBaseTransliterator.Mode.BASE)
                            .findFirst();
            assertTrue(baseConfig.isPresent());
            assertFalse(baseConfig.get().isDropSelectorsAltogether());
        }

        @Test
        public void testRemoveIvsSvsDropAll() {
            recipe.withRemoveIvsSvs(TransliterationRecipe.RemoveIvsSvsOptions.DROP_ALL_SELECTORS);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            Optional<IvsSvsBaseTransliterator.Options> baseConfig =
                    configs.stream()
                            .filter(
                                    c ->
                                            c.getName().equals("ivs-svs-base")
                                                    && c.getOptions().isPresent()
                                                    && c.getOptions().get()
                                                            instanceof
                                                            IvsSvsBaseTransliterator.Options
                                                    && ((IvsSvsBaseTransliterator.Options)
                                                                            c.getOptions().get())
                                                                    .getMode()
                                                            == IvsSvsBaseTransliterator.Mode.BASE)
                            .map(c -> (IvsSvsBaseTransliterator.Options) c.getOptions().get())
                            .findFirst();
            assertTrue(baseConfig.isPresent());
            assertTrue(baseConfig.get().isDropSelectorsAltogether());
        }

        @Test
        public void testCharsetConfiguration() {
            recipe.withKanjiOldNew(true).withCharset(IvsSvsBaseTransliterator.Charset.UNIJIS_90);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            // Find the ivs-svs-base config with mode "base" which should have charset
            Optional<IvsSvsBaseTransliterator.Options> baseConfig =
                    configs.stream()
                            .filter(
                                    c ->
                                            c.getName().equals("ivs-svs-base")
                                                    && c.getOptions().isPresent()
                                                    && c.getOptions().get()
                                                            instanceof
                                                            IvsSvsBaseTransliterator.Options
                                                    && ((IvsSvsBaseTransliterator.Options)
                                                                            c.getOptions().get())
                                                                    .getMode()
                                                            == IvsSvsBaseTransliterator.Mode.BASE)
                            .map(c -> (IvsSvsBaseTransliterator.Options) c.getOptions().get())
                            .findFirst();
            assertTrue(baseConfig.isPresent());
            assertEquals(IvsSvsBaseTransliterator.Charset.UNIJIS_90, baseConfig.get().getCharset());
        }
    }

    @Nested
    class OrderVerification {
        @Test
        public void testCircledOrSquaredAndCombinedOrder() {
            recipe.withReplaceCircledOrSquaredCharacters(
                            TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.ENABLED)
                    .withReplaceCombinedCharacters(true);
            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            List<String> configNames =
                    configs.stream().map(Yosina.TransliteratorConfig::getName).toList();

            // Both should be present
            assertTrue(configNames.contains("circled-or-squared"));
            assertTrue(configNames.contains("combined"));

            // Verify the order
            int circledPos = configNames.indexOf("circled-or-squared");
            int combinedPos = configNames.indexOf("combined");
            assertTrue(circledPos < combinedPos, "circled-or-squared should come before combined");
        }

        @Test
        public void testComprehensiveOrdering() {
            recipe.withKanjiOldNew(true)
                    .withReplaceSuspiciousHyphensToProlongedSoundMarks(true)
                    .withReplaceSpaces(true)
                    .withCombineDecomposedHiraganasAndKatakanas(true)
                    .withToHalfwidth(TransliterationRecipe.ToHalfwidthOptions.ENABLED);

            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            // Verify some key orderings
            int hiraKataPos = findConfigPosition(configs, "hira-kata-composition");
            int jisx0201Pos = findConfigPosition(configs, "jisx0201-and-alike");
            int spacesPos = findConfigPosition(configs, "spaces");
            int prolongedPos = findConfigPosition(configs, "prolonged-sound-marks");
            int kanjiPos = findConfigPosition(configs, "kanji-old-new");

            // hira-kata-composition should be early (head insertion)
            assertTrue(hiraKataPos >= 0);

            // jisx0201-and-alike should be at the end (tail insertion)
            assertEquals(configs.size() - 1, jisx0201Pos);

            // All should be present
            assertTrue(spacesPos >= 0);
            assertTrue(prolongedPos >= 0);
            assertTrue(kanjiPos >= 0);
        }
    }

    @Nested
    class MutualExclusion {
        @Test
        public void testFullwidthHalfwidthMutualExclusion() {
            recipe.withToFullwidth(TransliterationRecipe.ToFullwidthOptions.ENABLED)
                    .withToHalfwidth(TransliterationRecipe.ToHalfwidthOptions.ENABLED);

            IllegalArgumentException exception =
                    assertThrows(
                            IllegalArgumentException.class, recipe::buildTransliteratorConfigs);
            assertTrue(exception.getMessage().contains("mutually exclusive"));
        }
    }

    @Nested
    class ComprehensiveConfiguration {
        @Test
        public void testAllTransliteratorsEnabled() {
            recipe.withCombineDecomposedHiraganasAndKatakanas(true)
                    .withKanjiOldNew(true)
                    .withRemoveIvsSvs(TransliterationRecipe.RemoveIvsSvsOptions.DROP_ALL_SELECTORS)
                    .withReplaceHyphens(TransliterationRecipe.ReplaceHyphensOptions.ENABLED)
                    .withReplaceIdeographicAnnotations(true)
                    .withReplaceSuspiciousHyphensToProlongedSoundMarks(true)
                    .withReplaceRadicals(true)
                    .withReplaceSpaces(true)
                    .withReplaceCircledOrSquaredCharacters(
                            TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.ENABLED)
                    .withReplaceCombinedCharacters(true)
                    .withReplaceMathematicalAlphanumerics(true)
                    .withToHalfwidth(TransliterationRecipe.ToHalfwidthOptions.HANKAKU_KANA)
                    .withCharset(IvsSvsBaseTransliterator.Charset.UNIJIS_90);

            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();
            List<String> configNames =
                    configs.stream().map(Yosina.TransliteratorConfig::getName).toList();

            // Verify all expected transliterators are present
            String[] expectedTransliterators = {
                "ivs-svs-base", // appears twice
                "kanji-old-new",
                "prolonged-sound-marks",
                "circled-or-squared",
                "combined",
                "ideographic-annotations",
                "radicals",
                "spaces",
                "hyphens",
                "mathematical-alphanumerics",
                "hira-kata-composition",
                "jisx0201-and-alike"
            };

            for (String expected : expectedTransliterators) {
                assertTrue(configNames.contains(expected), "Missing transliterator: " + expected);
            }

            // Verify specific configurations
            Yosina.TransliteratorConfig hyphensConfig = findConfig(configs, "hyphens");
            assertTrue(hyphensConfig.getOptions().isPresent());
            HyphensTransliterator.Options hyphensOptions =
                    (HyphensTransliterator.Options) hyphensConfig.getOptions().get();
            assertIterableEquals(
                    List.of(
                            HyphensTransliterator.Mapping.JISX0208_90_WINDOWS,
                            HyphensTransliterator.Mapping.JISX0201),
                    hyphensOptions.getPrecedence());

            Yosina.TransliteratorConfig jisxConfig = findConfig(configs, "jisx0201-and-alike");
            assertTrue(jisxConfig.getOptions().isPresent());
            Jisx0201AndAlikeTransliterator.Options jisxOptions =
                    (Jisx0201AndAlikeTransliterator.Options) jisxConfig.getOptions().get();
            assertTrue(jisxOptions.isConvertGR());

            // Count ivs-svs-base occurrences
            long ivsSvsCount =
                    configs.stream().filter(c -> c.getName().equals("ivs-svs-base")).count();
            assertEquals(2, ivsSvsCount);
        }
    }

    @Nested
    class FunctionalIntegration {
        @Test
        public void testBasicTransliteration() {
            recipe.withReplaceCircledOrSquaredCharacters(
                            TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.ENABLED)
                    .withReplaceCombinedCharacters(true)
                    .withReplaceSpaces(true)
                    .withReplaceMathematicalAlphanumerics(true);

            Function<String, String> transliterator = Yosina.makeTransliteratorFromRecipe(recipe);

            // Test mixed content
            Object[][] testCases = {
                {"①", "(1)"}, // Circled number
                {"⑴", "(1)"}, // Parenthesized number (combined)
                {"𝐇𝐞𝐥𝐥𝐨", "Hello"}, // Mathematical alphanumerics
                {"　", " "}, // Full-width space
            };

            for (Object[] testCase : testCases) {
                String input = (String) testCase[0];
                String expected = (String) testCase[1];
                String result = transliterator.apply(input);
                assertEquals(expected, result, "Failed for " + input);
            }
        }

        @Test
        public void testExcludeEmojisFunctional() {
            recipe.withReplaceCircledOrSquaredCharacters(
                    TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.EXCLUDE_EMOJIS);

            Function<String, String> transliterator = Yosina.makeTransliteratorFromRecipe(recipe);

            // Regular circled characters should still work
            assertEquals("(1)", transliterator.apply("①"));
            assertEquals("(A)", transliterator.apply("Ⓐ"));

            // Non-emoji squared letters should still be processed
            assertEquals("[A]", transliterator.apply("🅰"));

            // Emoji characters should not be processed
            assertEquals("🆘", transliterator.apply("🆘"));
        }

        @Test
        public void testToFullwidthMustComeBeforeHiraKata() {
            recipe.withToFullwidth(TransliterationRecipe.ToFullwidthOptions.ENABLED)
                    .withHiraKata("kata-to-hira");

            List<Yosina.TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();

            assertEquals(2, configs.size());
            assertEquals("jisx0201-and-alike", configs.get(0).getName());
            assertEquals("hira-kata", configs.get(1).getName());

            // Test the actual transliteration works correctly
            Function<String, String> transliterator = Yosina.makeTransliteratorFromRecipe(recipe);
            assertEquals("かたかな", transliterator.apply("ｶﾀｶﾅ"));
        }
    }

    // Helper methods
    private boolean containsConfig(List<Yosina.TransliteratorConfig> configs, String name) {
        return configs.stream().anyMatch(c -> c.getName().equals(name));
    }

    private Yosina.TransliteratorConfig findConfig(
            List<Yosina.TransliteratorConfig> configs, String name) {
        return configs.stream().filter(c -> c.getName().equals(name)).findFirst().orElse(null);
    }

    private int findConfigPosition(List<Yosina.TransliteratorConfig> configs, String name) {
        for (int i = 0; i < configs.size(); i++) {
            if (configs.get(i).getName().equals(name)) {
                return i;
            }
        }
        return -1;
    }
}
