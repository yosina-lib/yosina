// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

/// <summary>
/// Tests for HyphensTransliterator based on Java test patterns.
/// </summary>
public class HyphensTransliteratorTests
{
    private static string Transliterate(string input, HyphensTransliterator.Options? options = null)
    {
        var transliterator = options != null ? new HyphensTransliterator(options) : new HyphensTransliterator();
        var charList = Characters.CharacterList(input);
        var result = transliterator.Transliterate(charList);
        return result.AsString();
    }

    [Theory]
    [InlineData("-", "─")]
    [InlineData("-", "━")]
    [InlineData("|", "│")]
    [InlineData("-", "⁃")]
    [InlineData("-", "－")]
    [InlineData("-", "‐")]
    [InlineData("-", "‑")]
    [InlineData("-", "‒")]
    [InlineData("-", "−")]
    [InlineData("-", "–")]
    [InlineData("~", "⁓")]
    [InlineData("-", "—")]
    [InlineData("-", "―")]
    [InlineData("-", "➖")]
    [InlineData("-", "˗")]
    [InlineData("-", "﹘")]
    [InlineData("~", "〜")]
    [InlineData("|", "｜")]
    [InlineData("~", "～")]
    [InlineData("=", "゠")]
    [InlineData("-", "﹣")]
    [InlineData("|", "￤")]
    [InlineData("|", "¦")]
    [InlineData("|", "￨")]
    [InlineData("-", "-")]
    [InlineData("-", "ｰ")]
    [InlineData("|", "︱")]
    [InlineData("--", "⸺")]
    [InlineData("---", "⸻")]
    [InlineData("|", "|")]
    [InlineData("~", "∼")]
    [InlineData("-", "ー")]
    [InlineData("~", "∽")]
    [InlineData("~", "~")]
    [InlineData("-", "⧿")]
    public void TestHyphensTransliterations(string expected, string input)
    {
        var options = new HyphensTransliterator.Options
        {
            Precedence = [HyphensTransliterator.Mapping.ASCII],
        };
        var output = Transliterate(input, options);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestEmptyString()
    {
        var options = new HyphensTransliterator.Options
        {
            Precedence = [HyphensTransliterator.Mapping.ASCII],
        };
        var output = Transliterate(string.Empty, options);
        Assert.Equal(string.Empty, output);
    }

    [Fact]
    public void TestUnmappedCharacters()
    {
        var options = new HyphensTransliterator.Options
        {
            Precedence = [HyphensTransliterator.Mapping.ASCII],
        };
        var input = "hello world 123 abc";
        var output = Transliterate(input, options);
        Assert.Equal(input, output);
    }

    [Fact]
    public void TestMixedHyphensContent()
    {
        var options = new HyphensTransliterator.Options
        {
            Precedence = [HyphensTransliterator.Mapping.ASCII],
        };
        var input = "hello─world━test│data";
        var output = Transliterate(input, options);
        Assert.Equal("hello-world-test|data", output);
    }

    [Fact]
    public void TestMultipleDashesToMultipleHyphens()
    {
        var options = new HyphensTransliterator.Options
        {
            Precedence = [HyphensTransliterator.Mapping.ASCII],
        };
        var input = "⸺⸻";
        var output = Transliterate(input, options);
        Assert.Equal("-----", output);
    }

    [Fact]
    public void TestJapaneseHyphensAndTildes()
    {
        var options = new HyphensTransliterator.Options
        {
            Precedence = [HyphensTransliterator.Mapping.ASCII],
        };
        var input = "カタカナー〜ひらがな～";
        var output = Transliterate(input, options);
        Assert.Equal("カタカナ-~ひらがな~", output);
    }

    [Fact]
    public void TestFullwidthCharacters()
    {
        var options = new HyphensTransliterator.Options
        {
            Precedence = [HyphensTransliterator.Mapping.ASCII],
        };
        var input = "－｜～";
        var output = Transliterate(input, options);
        Assert.Equal("-|~", output);
    }

    [Fact]
    public void TestSpecialDashVariants()
    {
        var options = new HyphensTransliterator.Options
        {
            Precedence = [HyphensTransliterator.Mapping.ASCII],
        };
        var input = "‐‑‒–—―";
        var output = Transliterate(input, options);
        Assert.Equal("------", output);
    }

    [Fact]
    public void TestDefaultPrecedence()
    {
        // Default precedence should be JISX0208_90
        var output = Transliterate("-");

        // With default JISX0208_90 precedence, ASCII hyphen becomes minus sign
        Assert.Equal("−", output);
    }

    [Fact]
    public void TestJisx0208_90Precedence()
    {
        var options = new HyphensTransliterator.Options
        {
            Precedence = [HyphensTransliterator.Mapping.JISX0208_90],
        };

        // Test some key mappings
        Assert.Equal("−", Transliterate("-", options)); // Hyphen to minus sign
        Assert.Equal("〜", Transliterate("~", options)); // Tilde to wave dash
        Assert.Equal("｜", Transliterate("|", options)); // Pipe to fullwidth vertical line
    }

    [Fact]
    public void TestJisx0208_90_WindowsPrecedence()
    {
        var options = new HyphensTransliterator.Options
        {
            Precedence = [HyphensTransliterator.Mapping.JISX0208_90_WINDOWS],
        };

        // Test some key mappings
        Assert.Equal("−", Transliterate("-", options)); // Hyphen to minus sign
        Assert.Equal("～", Transliterate("~", options)); // Tilde to fullwidth tilde
        Assert.Equal("｜", Transliterate("|", options)); // Pipe to fullwidth vertical line
    }

    [Fact]
    public void TestMultiplePrecedence()
    {
        var options = new HyphensTransliterator.Options
        {
            Precedence = [HyphensTransliterator.Mapping.ASCII, HyphensTransliterator.Mapping.JISX0208_90],
        };

        // With ASCII first, characters should map to ASCII equivalents
        Assert.Equal("-", Transliterate("-", options));
        Assert.Equal("~", Transliterate("~", options));
        Assert.Equal("|", Transliterate("|", options));
    }
}
