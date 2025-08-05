// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

/// <summary>
/// Tests for CombinedTransliterator.
/// </summary>
public class CombinedTransliteratorTests
{
    private static string Transliterate(string input)
    {
        var transliterator = new CombinedTransliterator();
        var charList = Characters.CharacterList(input);
        return transliterator.Transliterate(charList).AsString();
    }

    [Theory]
    [InlineData("NUL", "␀")]
    [InlineData("SOH", "␁")]
    [InlineData("STX", "␂")]
    [InlineData("BS", "␈")]
    [InlineData("HT", "␉")]
    [InlineData("CR", "␍")]
    [InlineData("SP", "␠")]
    [InlineData("DEL", "␡")]
    public void TestControlCharacterMappings(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Theory]
    [InlineData("(1)", "⑴")]
    [InlineData("(5)", "⑸")]
    [InlineData("(10)", "⑽")]
    [InlineData("(20)", "⒇")]
    public void TestParenthesizedNumbers(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Theory]
    [InlineData("1.", "⒈")]
    [InlineData("10.", "⒑")]
    [InlineData("20.", "⒛")]
    public void TestPeriodNumbers(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Theory]
    [InlineData("(a)", "⒜")]
    [InlineData("(z)", "⒵")]
    public void TestParenthesizedLetters(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Theory]
    [InlineData("(一)", "㈠")]
    [InlineData("(月)", "㈪")]
    [InlineData("(株)", "㈱")]
    public void TestParenthesizedKanji(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Theory]
    [InlineData("アパート", "㌀")]
    [InlineData("キロ", "㌔")]
    [InlineData("メートル", "㍍")]
    public void TestJapaneseUnits(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Theory]
    [InlineData("hPa", "㍱")]
    [InlineData("kHz", "㎑")]
    [InlineData("kg", "㎏")]
    public void TestScientificUnits(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestCombinedControlAndNumbers()
    {
        var input = "␉⑴␠⒈";
        var expected = "HT(1)SP1.";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestCombinedWithRegularText()
    {
        var input = "Hello ⑴ World ␉";
        var expected = "Hello (1) World HT";
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
        var input = "hello world 123 abc こんにちは";
        var output = Transliterate(input);
        Assert.Equal(input, output);
    }

    [Fact]
    public void TestSequenceOfCombinedCharacters()
    {
        var input = "␀␁␂␃␄";
        var expected = "NULSOHSTXETXEOT";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestJapaneseMonths()
    {
        var input = "㋀㋁㋂";
        var expected = "1月2月3月";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestJapaneseUnitsCombinations()
    {
        var input = "㌀㌁㌂";
        var expected = "アパートアルファアンペア";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestScientificMeasurements()
    {
        var input = "\u3378\u3379\u337a";
        var expected = "dm2dm3IU";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestMixedContent()
    {
        var input = "Text ⑴ with ␉ combined ㈱ characters ㍍";
        var expected = "Text (1) with HT combined (株) characters メートル";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestUnicodeCharactersPreserved()
    {
        var input = "こんにちは⑴世界␉です";
        var expected = "こんにちは(1)世界HTです";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestNewlineAndTabPreserved()
    {
        var input = "Line1\nLine2\tTab";
        var expected = "Line1\nLine2\tTab";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }
}
