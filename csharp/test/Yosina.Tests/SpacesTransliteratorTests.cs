// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

/// <summary>
/// Tests for SpacesTransliterator based on Java test patterns.
/// </summary>
public class SpacesTransliteratorTests
{
    private static string Transliterate(string input)
    {
        var transliterator = new SpacesTransliterator();
        var charList = Characters.CharacterList(input);
        var result = transliterator.Transliterate(charList);
        return result.AsString();
    }

    [Theory]
    [InlineData(" ", " ")]
    [InlineData(" ", "　")]
    [InlineData(" ", "ﾠ")]
    [InlineData(" ", "ㅤ")]
    [InlineData(" ", "​")]
    public void TestSpacesTransliterations(string expected, string input)
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
        var input = "hello world abc123";
        var output = Transliterate(input);
        Assert.Equal(input, output);
    }

    [Fact]
    public void TestMixedSpacesContent()
    {
        var input = "hello　world test　data";
        var expected = "hello world test data";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestMultipleSpaceTypes()
    {
        var input = "word　word word word";
        var expected = "word word word word";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestJapaneseTextWithIdeographicSpaces()
    {
        var input = "こんにちは　世界　です";
        var expected = "こんにちは 世界 です";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestHalfwidthIdeographicSpace()
    {
        var input = "testﾠdata";
        var expected = "test data";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestZeroWidthAndInvisibleSpaces()
    {
        var input = "word​word"; // Contains zero width space
        var expected = "word word";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestHangulFiller()
    {
        var input = "testㅤdata";
        var expected = "test data";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestConsecutiveSpaces()
    {
        var input = "word　　　word";
        var expected = "word   word";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }
}
