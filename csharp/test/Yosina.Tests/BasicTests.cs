// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Tests;

public class BasicTests
{
    [Fact]
    public void CharList_EmptyString()
    {
        var result = Characters.CharacterList(string.Empty);

        var singleChar = Assert.Single(result); // Only sentinel
        Assert.True(singleChar.IsSentinel);
    }

    [Fact]
    public void CharList_UnicodeWithVariationSelector()
    {
        // 葛 (U+845B) + VS1 (U+FE00)
        var input = "葛\uFE00";
        var result = Characters.CharacterList(input);

        Assert.Equal(2, result.Count); // Combined char + sentinel
        Assert.Equal(2, result[0].CodePoint.Size()); // Should have base char + variation selector
        Assert.True(result[1].IsSentinel);
    }

    [Fact]
    public void AsString_RoundTrip()
    {
        var originalString = "Hello, 世界! 🌍";
        var charList = Characters.CharacterList(originalString);
        var reconstructed = charList.AsString();

        Assert.Equal(originalString, reconstructed);
    }

    [Fact]
    public void MakeTransliterator_EmptyConfig_ThrowsError()
    {
        // Empty params array should still work, but empty configs inside would throw
        var transliterator = Entrypoint.MakeTransliterator(); // This creates empty chain
        var result = transliterator("test");
        Assert.Equal("test", result); // Should pass through unchanged
    }

    [Fact]
    public void MakeTransliterator_InvalidTransliteratorName_ThrowsError()
    {
        Assert.Throws<ArgumentException>(() =>
            Entrypoint.MakeTransliterator(new TransliteratorConfig("invalid-name")));
    }

    [Fact]
    public void MakeTransliterator_WithConfigs()
    {
        var transliterator = Entrypoint.MakeTransliterator(
            new TransliteratorConfig("spaces"));

        var testInput = "hello\u3000world"; // ideographic space
        var result = transliterator(testInput);

        Assert.Equal("hello world", result);
    }

    [Fact]
    public void MakeTransliterator_ChainedTransliterators()
    {
        var transliterator = Entrypoint.MakeTransliterator(
            new TransliteratorConfig("mathematical-alphanumerics"),
            new TransliteratorConfig("spaces"));

        var testInput = "\U0001d583\u3000world"; // mathematical bold X + ideographic space
        var result = transliterator(testInput);

        Assert.Equal("X world", result);
    }

    [Fact]
    public void TransliteratorConfig_WithOptions()
    {
        var config = new TransliteratorConfig("jisx0201-and-alike", new
        {
            FullwidthToHalfwidth = true,
            ConvertGL = true,
        });

        Assert.Equal("jisx0201-and-alike", config.Name);
        Assert.NotNull(config.Options);
    }
}
