// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

public class EdgeCaseTests
{
    [Fact]
    public void LargeInput_Performance()
    {
        // Test with a large input to ensure reasonable performance
        var largeInput = string.Concat(Enumerable.Repeat("あいうえお\u3000カキクケコ−テスト", 1000));
        var transliterator = Entrypoint.MakeTransliterator(
            new TransliteratorConfig("spaces"),
            new TransliteratorConfig("prolonged-sound-marks"));

        var startTime = DateTime.UtcNow;
        var result = transliterator(largeInput);
        var endTime = DateTime.UtcNow;
        var duration = endTime - startTime;

        Assert.NotEmpty(result);
        Assert.True(duration.TotalSeconds < 5.0, "Large input processing should complete in reasonable time");
    }

    [Fact]
    public void SurrogatePairs_Handling()
    {
        // Test handling of surrogate pairs (emoji and other high codepoint characters)
        var testCases = new[]
        {
            "🌍",                    // Earth emoji
            "𝕏",                     // Mathematical double-struck X
            "𠀋",                    // CJK Extension B character
            "👨‍👩‍👧‍👦",                   // Family emoji with ZWJ sequences
        };

        foreach (var input in testCases)
        {
            var charList = Characters.CharacterList(input);
            var reconstructed = charList.AsString();

            Assert.Equal(input, reconstructed);
        }
    }

    [Fact]
    public void MixedContent_ComplexScenarios()
    {
        var testCases = new[]
        {
            ("Hello\u3000世界!", "Hello 世界!"),                     // Mixed Latin/CJK with ideographic space
            ("Test\u00A0string", "Test string"),                   // Non-breaking space
            ("Math:\U0001d400\U0001d401\U0001d402", "Math:ABC"),   // Mathematical bold letters
            ("Price:¥１００", "Price:¥100"),                       // Mixed currency with fullwidth digits
        };

        var transliterator = Entrypoint.MakeTransliterator(
            new TransliteratorConfig("spaces"),
            new TransliteratorConfig("mathematical-alphanumerics"),
            new TransliteratorConfig("jisx0201-and-alike", new Jisx0201AndAlikeTransliterator.Options
            {
                FullwidthToHalfwidth = true,
                ConvertGL = true,
            }));

        foreach (var (input, expected) in testCases)
        {
            var result = transliterator(input);
            Assert.Equal(expected, result);
        }
    }

    [Fact]
    public void BoundaryConditions_CharacterProcessing()
    {
        var transliterator = new ProlongedSoundMarksTransliterator();

        var testCases = new[]
        {
            ("-", "-"),              // Single hyphen
            ("コ", "コ"),             // Single katakana
            ("コ-コ-コ", "コーコーコ"), // Multiple hyphens
            ("--", "--"),            // Multiple consecutive hyphens without context
            ("コ--", "コーー"),        // Multiple hyphens after katakana
        };

        foreach (var (input, expected) in testCases)
        {
            var charList = Characters.CharacterList(input);
            var result = transliterator.Transliterate(charList);
            var output = result.AsString();

            Assert.Equal(expected, output);
        }
    }

    [Fact]
    public void NullAndInvalidInputs_ErrorHandling()
    {
        // Test null input handling
        Assert.Throws<NullReferenceException>(() => Characters.CharacterList(null!));

        // Test invalid transliterator configuration
        Assert.Throws<ArgumentException>(() =>
            Entrypoint.MakeTransliterator(new TransliteratorConfig("non-existent-transliterator")));
    }

    [Fact]
    public void VariationSelectorEdgeCases()
    {
        var testCases = new[]
        {
            ("葛\uFE00", "葛\uFE00"),           // VS1 (16-bit variation selector)
            ("葛\U000E0100", "葛\U000E0100"),   // VS17 (256-bit variation selector)
            ("\uFE00", "\uFE00"),              // Lone variation selector
            ("A\uFE00", "A\uFE00"),            // Variation selector with non-CJK
        };

        var transliterator = new SpacesTransliterator(); // Should pass through unchanged

        foreach (var (input, expected) in testCases)
        {
            var charList = Characters.CharacterList(input);
            var result = transliterator.Transliterate(charList);
            var output = result.AsString();

            Assert.Equal(expected, output);
        }
    }

    [Fact]
    public void CombiningCharacters_EdgeCases()
    {
        var testCases = new[]
        {
            ("か\u3099", "が"),              // Combining voiced mark
            ("は\u309A", "ぱ"),              // Combining semi-voiced mark
            ("a\u0301", "a\u0301"),          // Latin with combining acute
            ("\u3099", "\u3099"),            // Lone combining mark
        };

        var transliterator = new HiraKataCompositionTransliterator();

        foreach (var (input, expected) in testCases)
        {
            var charList = Characters.CharacterList(input);
            var result = transliterator.Transliterate(charList);
            var output = result.AsString();

            Assert.Equal(expected, output);
        }
    }

    [Fact]
    public void Unicode_NormalizationConsistency()
    {
        // Test that the library handles different Unicode normalization forms consistently
        var nfcInput = "が";                // Precomposed (NFC)
        var nfdInput = "か\u3099";          // Decomposed (NFD)

        var transliterator = new HiraKataCompositionTransliterator();

        // Both should produce the same result
        var nfcCharList = Characters.CharacterList(nfcInput);
        var nfcResult = transliterator.Transliterate(nfcCharList).AsString();

        var nfdCharList = Characters.CharacterList(nfdInput);
        var nfdResult = transliterator.Transliterate(nfdCharList).AsString();

        Assert.Equal(nfdResult, nfcResult);
        Assert.Equal("が", nfcResult);
    }

    [Fact]
    public void MemoryUsage_LargeStrings()
    {
        // Test that large strings don't cause excessive memory usage
        var largeString = new string('あ', 10000);
        var initialMemory = GC.GetTotalMemory(true);

        var charList = Characters.CharacterList(largeString);
        var result = charList.AsString();

        var finalMemory = GC.GetTotalMemory(true);
        var memoryUsed = finalMemory - initialMemory;

        Assert.Equal(largeString.Length, result.Length);
        Assert.True(memoryUsed < 100_000_000, "Memory usage should be reasonable for large strings");
    }

    [Fact]
    public async System.Threading.Tasks.Task ThreadSafety_ConcurrentAccess()
    {
        var transliterator = Entrypoint.MakeTransliterator(
            new TransliteratorConfig("spaces"));

        var testInput = "test\u3000input";
        var expectedOutput = "test input";

        // Run multiple operations concurrently
        var tasks = Enumerable.Range(0, 100)
            .Select(_ => System.Threading.Tasks.Task.Run(() => transliterator(testInput)))
            .ToArray();

        await System.Threading.Tasks.Task.WhenAll(tasks);

        // All results should be consistent
        foreach (var task in tasks)
        {
            Assert.Equal(expectedOutput, await task);
        }
    }
}
