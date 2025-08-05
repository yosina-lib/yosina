// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

/// <summary>
/// Tests for CircledOrSquaredTransliterator.
/// </summary>
public class CircledOrSquaredTransliteratorTests
{
    private static string Transliterate(string input, bool includeEmojis = true, string? templateForCircled = null, string? templateForSquared = null)
    {
        var options = new CircledOrSquaredTransliterator.Options { IncludeEmojis = includeEmojis };
        if (templateForCircled != null)
        {
            options.TemplateForCircled = templateForCircled;
        }

        if (templateForSquared != null)
        {
            options.TemplateForSquared = templateForSquared;
        }

        var transliterator = new CircledOrSquaredTransliterator(options);
        var charList = Characters.CharacterList(input);
        var result = transliterator.Transliterate(charList);
        return result.AsString();
    }

    [Theory]
    [InlineData("(1)", "①")]
    [InlineData("(2)", "②")]
    [InlineData("(20)", "⑳")]
    [InlineData("(0)", "⓪")]
    public void TestCircledNumbers(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Theory]
    [InlineData("(A)", "Ⓐ")]
    [InlineData("(Z)", "Ⓩ")]
    [InlineData("(a)", "ⓐ")]
    [InlineData("(z)", "ⓩ")]
    public void TestCircledLetters(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Theory]
    [InlineData("(一)", "㊀")]
    [InlineData("(月)", "㊊")]
    [InlineData("(夜)", "㊰")]
    public void TestCircledKanji(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Theory]
    [InlineData("(ア)", "㋐")]
    [InlineData("(ヲ)", "㋾")]
    public void TestCircledKatakana(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Theory]
    [InlineData("[A]", "🅰")]
    [InlineData("[Z]", "🆉")]
    public void TestSquaredLetters(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Theory]
    [InlineData("[A]", "🇦")]
    [InlineData("[Z]", "🇿")]
    public void TestRegionalIndicators(string expected, string input)
    {
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestEmojiExclusionDefault()
    {
        var input = "🆂🅾🆂";
        var expected = "[S][O][S]";
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
    public void TestMixedContent()
    {
        var input = "Hello ① World Ⓐ Test";
        var expected = "Hello (1) World (A) Test";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestSequenceOfCircledNumbers()
    {
        var input = "①②③④⑤";
        var expected = "(1)(2)(3)(4)(5)";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestSequenceOfCircledLetters()
    {
        var input = "ⒶⒷⒸ";
        var expected = "(A)(B)(C)";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestMixedCirclesAndSquares()
    {
        var input = "①🅰②🅱";
        var expected = "(1)[A](2)[B]";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestCircledKanjiSequence()
    {
        var input = "㊀㊁㊂㊃㊄";
        var expected = "(一)(二)(三)(四)(五)";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestJapaneseTextWithCircledElements()
    {
        var input = "項目①は重要で、項目②は補足です。";
        var expected = "項目(1)は重要で、項目(2)は補足です。";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestNumberedListWithCircledNumbers()
    {
        var input = "①準備\n②実行\n③確認";
        var expected = "(1)準備\n(2)実行\n(3)確認";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestLargeCircledNumbers()
    {
        var input = "㊱㊲㊳";
        var expected = "(36)(37)(38)";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestCircledNumbersUpTo50()
    {
        var input = "㊿";
        var expected = "(50)";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestSpecialCircledCharacters()
    {
        var input = "🄴🅂";
        var expected = "[E][S]";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestIncludeEmojisTrue()
    {
        var input = "🆘";
        var expected = "[SOS]";
        var output = Transliterate(input, includeEmojis: true);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestIncludeEmojisFalse()
    {
        var input = "🆘";
        var expected = "🆘";
        var output = Transliterate(input, includeEmojis: false);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestMixedEmojiAndNonEmojiWithIncludeEmojisTrue()
    {
        var input = "①🅰②";
        var expected = "(1)[A](2)";
        var output = Transliterate(input, includeEmojis: true);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestMixedEmojiAndNonEmojiWithIncludeEmojisFalse()
    {
        var input = "①🆘②";
        var expected = "(1)🆘(2)";
        var output = Transliterate(input, includeEmojis: false);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestCustomCircleTemplate()
    {
        var input = "①";
        var expected = "〔1〕";
        var output = Transliterate(input, templateForCircled: "〔?〕");
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestCustomSquareTemplate()
    {
        var input = "🅰";
        var expected = "【A】";
        var output = Transliterate(input, templateForSquared: "【?】");
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestCustomTemplatesWithKanji()
    {
        var input = "㊀";
        var expected = "〔一〕";
        var output = Transliterate(input, templateForCircled: "〔?〕");
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestMixedCharactersWithCustomTemplates()
    {
        var input = "①🅰②";
        var expected = "〔1〕【A】〔2〕";
        var output = Transliterate(input, templateForCircled: "〔?〕", templateForSquared: "【?】");
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestUnicodeCharactersPreserved()
    {
        var input = "こんにちは①世界🅰です";
        var expected = "こんにちは(1)世界[A]です";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }

    [Fact]
    public void TestOtherEmojiPreserved()
    {
        var input = "😀①😊";
        var expected = "😀(1)😊";
        var output = Transliterate(input);
        Assert.Equal(expected, output);
    }
}
