// Copyright (c) Yosina. All rights reserved.

using Charset = Yosina.Transliterators.IvsSvsBaseTransliterator.Charset;
using Mapping = Yosina.Transliterators.HyphensTransliterator.Mapping;

namespace Yosina.Tests;

public static class TransliterationRecipeTests
{
    // Test basic recipe functionality
    public class BasicRecipeTests
    {
        [Fact]
        public void EmptyRecipe_ProducesNoConfigs()
        {
            var recipe = new TransliterationRecipe();
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Empty(configs);
        }

        [Fact]
        public void DefaultValues_AreCorrect()
        {
            var recipe = new TransliterationRecipe();

            Assert.False(recipe.KanjiOldNew);
            Assert.False(recipe.ReplaceSuspiciousHyphensToProlongedSoundMarks);
            Assert.False(recipe.ReplaceCombinedCharacters);
            Assert.Equal(TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.Disabled, recipe.ReplaceCircledOrSquaredCharacters);
            Assert.False(recipe.ReplaceIdeographicAnnotations);
            Assert.False(recipe.ReplaceRadicals);
            Assert.False(recipe.ReplaceSpaces);
            Assert.Equal(TransliterationRecipe.ReplaceHyphensOptions.Disabled, recipe.ReplaceHyphens);
            Assert.False(recipe.ReplaceMathematicalAlphanumerics);
            Assert.False(recipe.CombineDecomposedHiraganasAndKatakanas);
            Assert.Equal(TransliterationRecipe.ToFullwidthOptions.Disabled, recipe.ToFullwidth);
            Assert.Equal(TransliterationRecipe.ToHalfwidthOptions.Disabled, recipe.ToHalfwidth);
            Assert.Equal(TransliterationRecipe.RemoveIvsSvsOptions.Disabled, recipe.RemoveIvsSvs);
            Assert.Equal(Charset.UniJis2004, recipe.Charset);
        }
    }

    // Test individual transliterator configurations
    public class IndividualTransliteratorsTests
    {
        [Fact]
        public void KanjiOldNew_Configuration()
        {
            var recipe = new TransliterationRecipe { KanjiOldNew = true };
            var configs = recipe.BuildTransliteratorConfigs();

            // Should contain kanji-old-new and IVS/SVS configurations
            Assert.Contains(configs, c => string.Equals(c.Name, "kanji-old-new", StringComparison.Ordinal));
            Assert.Contains(configs, c => string.Equals(c.Name, "ivs-svs-base", StringComparison.Ordinal));

            // Should have at least 3 configs: ivs-or-svs, kanji-old-new, base
            Assert.True(configs.Count >= 3);
        }

        [Fact]
        public void ProlongedSoundMarks_Configuration()
        {
            var recipe = new TransliterationRecipe { ReplaceSuspiciousHyphensToProlongedSoundMarks = true };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("prolonged-sound-marks", configs[0].Name);
            Assert.NotNull(configs[0].Options);
        }

        [Fact]
        public void CircledOrSquared_Configuration()
        {
            var recipe = new TransliterationRecipe { ReplaceCircledOrSquaredCharacters = TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.Enabled };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("circled-or-squared", configs[0].Name);
            Assert.NotNull(configs[0].Options);
        }

        [Fact]
        public void CircledOrSquared_ExcludeEmojisConfiguration()
        {
            var recipe = new TransliterationRecipe { ReplaceCircledOrSquaredCharacters = TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.ExcludeEmojis };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("circled-or-squared", configs[0].Name);
            Assert.NotNull(configs[0].Options);
        }

        [Fact]
        public void Combined_Configuration()
        {
            var recipe = new TransliterationRecipe { ReplaceCombinedCharacters = true };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("combined", configs[0].Name);
            Assert.Null(configs[0].Options);
        }

        [Fact]
        public void IdeographicAnnotations_Configuration()
        {
            var recipe = new TransliterationRecipe { ReplaceIdeographicAnnotations = true };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("ideographic-annotations", configs[0].Name);
            Assert.Null(configs[0].Options);
        }

        [Fact]
        public void Radicals_Configuration()
        {
            var recipe = new TransliterationRecipe { ReplaceRadicals = true };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("radicals", configs[0].Name);
            Assert.Null(configs[0].Options);
        }

        [Fact]
        public void Spaces_Configuration()
        {
            var recipe = new TransliterationRecipe { ReplaceSpaces = true };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("spaces", configs[0].Name);
            Assert.Null(configs[0].Options);
        }

        [Fact]
        public void MathematicalAlphanumerics_Configuration()
        {
            var recipe = new TransliterationRecipe { ReplaceMathematicalAlphanumerics = true };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("mathematical-alphanumerics", configs[0].Name);
            Assert.Null(configs[0].Options);
        }

        [Fact]
        public void HiraKataComposition_Configuration()
        {
            var recipe = new TransliterationRecipe { CombineDecomposedHiraganasAndKatakanas = true };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("hira-kata-composition", configs[0].Name);
            Assert.NotNull(configs[0].Options);
        }
    }

    // Test complex option configurations
    public class ComplexOptionsTests
    {
        [Fact]
        public void Hyphens_DefaultPrecedence()
        {
            var recipe = new TransliterationRecipe { ReplaceHyphens = TransliterationRecipe.ReplaceHyphensOptions.Enabled };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("hyphens", configs[0].Name);
            Assert.NotNull(configs[0].Options);
        }

        [Fact]
        public void Hyphens_CustomPrecedence()
        {
            var customPrecedence = new List<Mapping> { Mapping.JISX0201, Mapping.ASCII };
            var recipe = new TransliterationRecipe { ReplaceHyphens = TransliterationRecipe.ReplaceHyphensOptions.WithPrecedence(customPrecedence) };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("hyphens", configs[0].Name);
            Assert.NotNull(configs[0].Options);
        }

        [Fact]
        public void ToFullwidth_BasicConfiguration()
        {
            var recipe = new TransliterationRecipe { ToFullwidth = TransliterationRecipe.ToFullwidthOptions.Enabled };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("jisx0201-and-alike", configs[0].Name);
            Assert.NotNull(configs[0].Options);
        }

        [Fact]
        public void ToFullwidth_YenSignConfiguration()
        {
            var recipe = new TransliterationRecipe { ToFullwidth = TransliterationRecipe.ToFullwidthOptions.U005cAsYenSign };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("jisx0201-and-alike", configs[0].Name);
            Assert.NotNull(configs[0].Options);
        }

        [Fact]
        public void ToHalfwidth_BasicConfiguration()
        {
            var recipe = new TransliterationRecipe { ToHalfwidth = TransliterationRecipe.ToHalfwidthOptions.Enabled };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("jisx0201-and-alike", configs[0].Name);
            Assert.NotNull(configs[0].Options);
        }

        [Fact]
        public void ToHalfwidth_HankakuKanaConfiguration()
        {
            var recipe = new TransliterationRecipe { ToHalfwidth = TransliterationRecipe.ToHalfwidthOptions.HankakuKana };
            var configs = recipe.BuildTransliteratorConfigs();

            Assert.Single(configs);
            Assert.Equal("jisx0201-and-alike", configs[0].Name);
            Assert.NotNull(configs[0].Options);
        }

        [Fact]
        public void RemoveIvsSvs_BasicConfiguration()
        {
            var recipe = new TransliterationRecipe { RemoveIvsSvs = TransliterationRecipe.RemoveIvsSvsOptions.Enabled };
            var configs = recipe.BuildTransliteratorConfigs();

            // Should have two ivs-svs-base configs
            var ivsSvsConfigs = configs.Where(c => string.Equals(c.Name, "ivs-svs-base", StringComparison.Ordinal)).ToList();
            Assert.Equal(2, ivsSvsConfigs.Count);

            // Both should have options
            Assert.All(ivsSvsConfigs, c => Assert.NotNull(c.Options));
        }

        [Fact]
        public void RemoveIvsSvs_DropAllConfiguration()
        {
            var recipe = new TransliterationRecipe { RemoveIvsSvs = TransliterationRecipe.RemoveIvsSvsOptions.DropAllSelectors };
            var configs = recipe.BuildTransliteratorConfigs();

            // Should have two ivs-svs-base configs
            var ivsSvsConfigs = configs.Where(c => string.Equals(c.Name, "ivs-svs-base", StringComparison.Ordinal)).ToList();
            Assert.Equal(2, ivsSvsConfigs.Count);
        }

        [Fact]
        public void Charset_Configuration()
        {
            var recipe = new TransliterationRecipe
            {
                KanjiOldNew = true,
                Charset = Charset.UniJis90,
            };
            var configs = recipe.BuildTransliteratorConfigs();

            // Should have ivs-svs-base configs
            var ivsSvsConfigs = configs.Where(c => string.Equals(c.Name, "ivs-svs-base", StringComparison.Ordinal)).ToList();
            Assert.NotEmpty(ivsSvsConfigs);
        }
    }

    // Test transliterator ordering
    public class OrderVerificationTests
    {
        [Fact]
        public void CircledOrSquaredAndCombined_Order()
        {
            var recipe = new TransliterationRecipe
            {
                ReplaceCircledOrSquaredCharacters = TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.Enabled,
                ReplaceCombinedCharacters = true,
            };
            var configs = recipe.BuildTransliteratorConfigs();

            var configNames = configs.Select(c => c.Name).ToList();

            // Both should be present
            Assert.Contains("circled-or-squared", configNames);
            Assert.Contains("combined", configNames);

            // Verify the order - combined comes before circled-or-squared
            var circledPos = configNames.IndexOf("circled-or-squared");
            var combinedPos = configNames.IndexOf("combined");
            Assert.True(combinedPos < circledPos);
        }

        [Fact]
        public void Comprehensive_Ordering()
        {
            var recipe = new TransliterationRecipe
            {
                KanjiOldNew = true,
                ReplaceSuspiciousHyphensToProlongedSoundMarks = true,
                ReplaceSpaces = true,
                CombineDecomposedHiraganasAndKatakanas = true,
                ToHalfwidth = TransliterationRecipe.ToHalfwidthOptions.Enabled,
            };
            var configs = recipe.BuildTransliteratorConfigs();

            var configNames = configs.Select(c => c.Name).ToList();

            // Verify some key orderings
            // hira-kata-composition should be early (head insertion)
            Assert.Contains("hira-kata-composition", configNames);

            // jisx0201-and-alike should be at the end (tail insertion)
            Assert.Equal("jisx0201-and-alike", configNames.Last());

            // All should be present
            Assert.Contains("spaces", configNames);
            Assert.Contains("prolonged-sound-marks", configNames);
            Assert.Contains("kanji-old-new", configNames);
        }
    }

    // Test mutual exclusion rules
    public class MutualExclusionTests
    {
        [Fact]
        public void ToFullwidth_ToHalfwidth_MutuallyExclusive()
        {
            var recipe = new TransliterationRecipe
            {
                ToFullwidth = TransliterationRecipe.ToFullwidthOptions.Enabled,
                ToHalfwidth = TransliterationRecipe.ToHalfwidthOptions.Enabled,
            };

            var exception = Assert.Throws<ArgumentException>(() => recipe.BuildTransliteratorConfigs());
            Assert.Contains("mutually exclusive", exception.Message, StringComparison.Ordinal);
        }
    }

    // Test comprehensive configurations
    public class ComprehensiveConfigurationTests
    {
        [Fact]
        public void AllTransliterators_Enabled()
        {
            var recipe = new TransliterationRecipe
            {
                CombineDecomposedHiraganasAndKatakanas = true,
                KanjiOldNew = true,
                RemoveIvsSvs = TransliterationRecipe.RemoveIvsSvsOptions.DropAllSelectors,
                ReplaceHyphens = TransliterationRecipe.ReplaceHyphensOptions.Enabled,
                ReplaceIdeographicAnnotations = true,
                ReplaceSuspiciousHyphensToProlongedSoundMarks = true,
                ReplaceRadicals = true,
                ReplaceSpaces = true,
                ReplaceCircledOrSquaredCharacters = TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.Enabled,
                ReplaceCombinedCharacters = true,
                ReplaceMathematicalAlphanumerics = true,
                ToHalfwidth = TransliterationRecipe.ToHalfwidthOptions.HankakuKana,
                Charset = Charset.UniJis90,
            };

            var configs = recipe.BuildTransliteratorConfigs();

            // Verify all expected transliterators are present
            var configNames = configs.Select(c => c.Name).ToList();

            var expectedConfigs = new[]
            {
                "ivs-svs-base", // Will appear twice
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
                "jisx0201-and-alike",
            };

            foreach (var expected in expectedConfigs)
            {
                Assert.Contains(expected, configNames);
            }

            // ivs-svs-base should appear exactly twice
            Assert.Equal(2, configNames.Count(n => string.Equals(n, "ivs-svs-base", StringComparison.Ordinal)));
        }
    }

    // Test functional integration
    public class FunctionalIntegrationTests
    {
        [Fact]
        public void BasicTransliteration_Works()
        {
            var recipe = new TransliterationRecipe
            {
                ReplaceCircledOrSquaredCharacters = TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.Enabled,
                ReplaceCombinedCharacters = true,
                ReplaceSpaces = true,
                ReplaceMathematicalAlphanumerics = true,
            };

            var transliterator = Entrypoint.MakeTransliterator(recipe);

            // Test mixed content
            Assert.Equal("(1)", transliterator("①"));  // Circled number
            Assert.Equal("(1)", transliterator("⑴"));  // Parenthesized number (combined)
            Assert.Equal("Hello", transliterator("𝐇𝐞𝐥𝐥𝐨"));  // Mathematical alphanumerics
            Assert.Equal(" ", transliterator("　"));  // Full-width space
        }

        [Fact]
        public void ExcludeEmojis_Functional()
        {
            var recipe = new TransliterationRecipe
            {
                ReplaceCircledOrSquaredCharacters = TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.ExcludeEmojis,
            };

            var transliterator = Entrypoint.MakeTransliterator(recipe);

            // Regular circled characters should still work
            Assert.Equal("(1)", transliterator("①"));
            Assert.Equal("(A)", transliterator("Ⓐ"));

            // Non-emoji squared letters should still be processed
            Assert.Equal("[A]", transliterator("🅰"));

            // Emoji characters should not be processed
            Assert.Equal("🆘", transliterator("🆘"));
        }
    }
}
