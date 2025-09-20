// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests.Transliterators;

public class RomanNumeralsTransliteratorTests
{
    private static string Transliterate(string input)
    {
        var transliterator = new RomanNumeralsTransliterator();
        var charList = Characters.CharacterList(input);
        var result = transliterator.Transliterate(charList);
        return result.AsString();
    }

    [Theory]
    [InlineData("I", "Ⅰ")]
    [InlineData("II", "Ⅱ")]
    [InlineData("III", "Ⅲ")]
    [InlineData("IV", "Ⅳ")]
    [InlineData("V", "Ⅴ")]
    [InlineData("VI", "Ⅵ")]
    [InlineData("VII", "Ⅶ")]
    [InlineData("VIII", "Ⅷ")]
    [InlineData("IX", "Ⅸ")]
    [InlineData("X", "Ⅹ")]
    [InlineData("XI", "Ⅺ")]
    [InlineData("XII", "Ⅻ")]
    [InlineData("L", "Ⅼ")]
    [InlineData("C", "Ⅽ")]
    [InlineData("D", "Ⅾ")]
    [InlineData("M", "Ⅿ")]
    public void TestUppercaseRomanNumerals(string expected, string input)
    {
        var result = Transliterate(input);
        Assert.Equal(expected, result);
    }

    [Theory]
    [InlineData("i", "ⅰ")]
    [InlineData("ii", "ⅱ")]
    [InlineData("iii", "ⅲ")]
    [InlineData("iv", "ⅳ")]
    [InlineData("v", "ⅴ")]
    [InlineData("vi", "ⅵ")]
    [InlineData("vii", "ⅶ")]
    [InlineData("viii", "ⅷ")]
    [InlineData("ix", "ⅸ")]
    [InlineData("x", "ⅹ")]
    [InlineData("xi", "ⅺ")]
    [InlineData("xii", "ⅻ")]
    [InlineData("l", "ⅼ")]
    [InlineData("c", "ⅽ")]
    [InlineData("d", "ⅾ")]
    [InlineData("m", "ⅿ")]
    public void TestLowercaseRomanNumerals(string expected, string input)
    {
        var result = Transliterate(input);
        Assert.Equal(expected, result);
    }

    [Theory]
    [InlineData("Year XII", "Year Ⅻ")]
    [InlineData("Chapter iv", "Chapter ⅳ")]
    [InlineData("Section III.A", "Section Ⅲ.A")]
    [InlineData("I II III", "Ⅰ Ⅱ Ⅲ")]
    [InlineData("i, ii, iii", "ⅰ, ⅱ, ⅲ")]
    public void TestMixedText(string expected, string input)
    {
        var result = Transliterate(input);
        Assert.Equal(expected, result);
    }

    [Theory]
    [InlineData("", "")]
    [InlineData("ABC123", "ABC123")]
    [InlineData("IIIIII", "ⅠⅡⅢ")]
    public void TestEdgeCases(string expected, string input)
    {
        var result = Transliterate(input);
        Assert.Equal(expected, result);
    }
}
