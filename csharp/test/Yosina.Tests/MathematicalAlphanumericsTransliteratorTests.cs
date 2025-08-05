// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

/// <summary>
/// Tests for MathematicalAlphanumericsTransliterator based on Java test patterns.
/// </summary>
public class MathematicalAlphanumericsTransliteratorTests
{
    private static string Transliterate(string input)
    {
        var transliterator = new MathematicalAlphanumericsTransliterator();
        var charList = Characters.CharacterList(input);
        var result = transliterator.Transliterate(charList);
        return result.AsString();
    }

    [Theory]

    // Mathematical Bold characters
    [InlineData("A", "𝐀")]
    [InlineData("B", "𝐁")]
    [InlineData("Z", "𝐙")]
    [InlineData("a", "𝐚")]
    [InlineData("b", "𝐛")]
    [InlineData("z", "𝐳")]

    // Mathematical Italic characters
    [InlineData("A", "𝐴")]
    [InlineData("B", "𝐵")]
    [InlineData("a", "𝑎")]
    [InlineData("b", "𝑏")]

    // Mathematical Bold Italic characters
    [InlineData("A", "𝑨")]
    [InlineData("a", "𝒂")]

    // Mathematical Script characters
    [InlineData("A", "𝒜")]
    [InlineData("a", "𝒶")]

    // Mathematical Bold Script characters
    [InlineData("A", "𝓐")]
    [InlineData("a", "𝓪")]

    // Mathematical Fraktur characters
    [InlineData("A", "𝔄")]
    [InlineData("a", "𝔞")]

    // Mathematical Double-struck characters
    [InlineData("A", "𝔸")]
    [InlineData("a", "𝕒")]

    // Mathematical Bold Fraktur characters
    [InlineData("A", "𝕬")]
    [InlineData("a", "𝖆")]

    // Mathematical Sans-serif characters
    [InlineData("A", "𝖠")]
    [InlineData("a", "𝖺")]

    // Mathematical Sans-serif Bold characters
    [InlineData("A", "𝗔")]
    [InlineData("a", "𝗮")]

    // Mathematical Sans-serif Italic characters
    [InlineData("A", "𝘈")]
    [InlineData("a", "𝘢")]

    // Mathematical Sans-serif Bold Italic characters
    [InlineData("A", "𝘼")]
    [InlineData("a", "𝙖")]

    // Mathematical Monospace characters
    [InlineData("A", "𝙰")]
    [InlineData("a", "𝚊")]

    // Mathematical digits
    [InlineData("0", "𝟎")]
    [InlineData("1", "𝟏")]
    [InlineData("9", "𝟗")]
    public void TestMathematicalAlphanumericsTransliterations(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestEmptyString()
    {
        var output = Transliterate(string.Empty);
        Assert.Equal(string.Empty, output);
    }

    [Fact]
    public void TestUnmappedCharacters()
    {
        var input = "hello world 123 !@# こんにちは";
        var output = Transliterate(input);
        Assert.Equal(input, output);
    }

    [Fact]
    public void TestMixedMathematicalContent()
    {
        var input = "𝐀𝐁𝐂 regular ABC 𝟏𝟐𝟑";
        var expected = "ABC regular ABC 123";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestMathematicalAlphabet()
    {
        var input = "𝐀𝐁𝐂𝐃𝐄𝐅𝐆𝐇𝐈𝐉𝐊𝐋𝐌𝐍𝐎𝐏𝐐𝐑𝐒𝐓𝐔𝐕𝐖𝐗𝐘𝐙";
        var expected = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestMathematicalLowercaseAlphabet()
    {
        var input = "𝐚𝐛𝐜𝐝𝐞𝐟𝐠𝐡𝐢𝐣𝐤𝐥𝐦𝐧𝐨𝐩𝐪𝐫𝐬𝐭𝐮𝐯𝐰𝐱𝐲𝐳";
        var expected = "abcdefghijklmnopqrstuvwxyz";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestMathematicalDigits()
    {
        var input = "𝟎𝟏𝟐𝟑𝟒𝟓𝟔𝟕𝟖𝟗";
        var expected = "0123456789";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestDifferentMathematicalStyles()
    {
        var input = "𝐀𝐴𝑨𝒜𝓐𝔄𝔸𝕬𝖠𝗔𝘈𝘼𝙰"; // Different styles of A
        var expected = "AAAAAAAAAAAAA";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestMathematicalEquation()
    {
        var input = "𝒇(𝒙) = 𝒎𝒙 + 𝒃";
        var expected = "f(x) = mx + b";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestSpecialMathematicalCharacters()
    {
        var input = "𝔄𝔞 𝕬𝖆 𝖠𝖺"; // Fraktur, Bold Fraktur, Sans-serif
        var expected = "Aa Aa Aa";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }
}
