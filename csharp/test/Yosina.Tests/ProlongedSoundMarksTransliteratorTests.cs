// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

/// <summary>
/// Tests for ProlongedSoundMarksTransliterator based on Java test patterns.
/// </summary>
public class ProlongedSoundMarksTransliteratorTests
{
    private static string Transliterate(string input, ProlongedSoundMarksTransliterator.Options? options = null)
    {
        var transliterator = options != null
            ? new ProlongedSoundMarksTransliterator(options)
            : new ProlongedSoundMarksTransliterator();
        var charList = Characters.CharacterList(input);
        var result = transliterator.Transliterate(charList);
        return result.AsString();
    }

    [Fact]
    public void TestFullwidthHyphenMinusToProlongedSoundMark()
    {
        var input = "イ\uff0dハト\uff0dヴォ";
        var expected = "イ\u30fcハト\u30fcヴォ";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestFullwidthHyphenMinusAtEndOfWord()
    {
        var input = "カトラリ\uff0d";
        var expected = "カトラリ\u30fc";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestAsciiHyphenMinusToProlongedSoundMark()
    {
        var input = "イ\u002dハト\u002dヴォ";
        var expected = "イ\u30fcハト\u30fcヴォ";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestAsciiHyphenMinusAtEndOfWord()
    {
        var input = "カトラリ\u002d";
        var expected = "カトラリ\u30fc";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestDontReplaceBetweenProlongedSoundMarks()
    {
        var input = "1\u30fc\uff0d2\u30fc3";
        var expected = "1\u30fc\uff0d2\u30fc3";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBetweenAlphanumerics()
    {
        var input = "1\u30fc\uff0d2\u30fc3";
        var expected = "1\u002d\u002d2\u002d3";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksFollowingAlnums = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBetweenFullwidthAlphanumerics()
    {
        var input = "\uff11\u30fc\uff0d\uff12\u30fc\uff13";
        var expected = "\uff11\uff0d\uff0d\uff12\uff0d\uff13";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksFollowingAlnums = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestDontProlongSokuonByDefault()
    {
        var input = "ウッ\uff0dウン\uff0d";
        var expected = "ウッ\uff0dウン\uff0d";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestAllowProlongedSokuon()
    {
        var input = "ウッ\uff0dウン\uff0d";
        var expected = "ウッ\u30fcウン\uff0d";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            AllowProlongedSokuon = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestAllowProlongedHatsuon()
    {
        var input = "ウッ\uff0dウン\uff0d";
        var expected = "ウッ\uff0dウン\u30fc";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            AllowProlongedHatsuon = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestAllowBothProlongedSokuonAndHatsuon()
    {
        var input = "ウッ\uff0dウン\uff0d";
        var expected = "ウッ\u30fcウン\u30fc";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            AllowProlongedHatsuon = true,
            AllowProlongedSokuon = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestEmptyString()
    {
        var result = Transliterate(string.Empty);
        Assert.Equal(string.Empty, result);
    }

    [Fact]
    public void TestStringWithNoHyphens()
    {
        var input = "こんにちは世界";
        var result = Transliterate(input);
        Assert.Equal(input, result);
    }

    [Fact]
    public void TestMixedHiraganaAndKatakanaWithHyphens()
    {
        var input = "あいう\u002dかきく\uff0d";
        var expected = "あいう\u30fcかきく\u30fc";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestHalfwidthKatakanaWithHyphen()
    {
        var input = "ｱｲｳ\u002d";
        var expected = "ｱｲｳ\uff70";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestHalfwidthKatakanaWithFullwidthHyphen()
    {
        var input = "ｱｲｳ\uff0d";
        var expected = "ｱｲｳ\uff70";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestHyphenAfterNonJapaneseCharacter()
    {
        var input = "ABC\u002d123\uff0d";
        var result = Transliterate(input);
        Assert.Equal(input, result);
    }

    [Fact]
    public void TestMultipleHyphensInSequence()
    {
        var input = "ア\u002d\u002d\u002dイ";
        var expected = "ア\u30fc\u30fc\u30fcイ";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestVariousHyphenTypes()
    {
        var input = "ア\u002dイ\u2010ウ\u2014エ\u2015オ\u2212カ\uff0d";
        var expected = "ア\u30fcイ\u30fcウ\u30fcエ\u30fcオ\u30fcカ\u30fc";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestProlongedSoundMarkRemainsUnchanged1()
    {
        var input = "ア\u30fcＡ\uff70Ｂ";
        var result = Transliterate(input);
        Assert.Equal(input, result);
    }

    [Fact]
    public void TestProlongedSoundMarkRemainsUnchanged2()
    {
        var input = "ア\u30fcン\uff70ウ";
        var result = Transliterate(input);
        Assert.Equal(input, result);
    }

    [Fact]
    public void TestMixedAlphanumericAndJapaneseWithReplaceOption()
    {
        var input = "A\u30fcB\uff0dアイウ\u002d123\u30fc";
        var expected = "A\u002dB\u002dアイウ\u30fc123\u002d";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksFollowingAlnums = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestHiraganaSokuonWithHyphen()
    {
        var input = "あっ\u002d";
        var result = Transliterate(input);
        Assert.Equal(input, result);
    }

    [Fact]
    public void TestHiraganaSokuonWithHyphenAndAllowProlongedSokuon()
    {
        var input = "あっ\u002d";
        var expected = "あっ\u30fc";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            AllowProlongedSokuon = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestHiraganaHatsuonWithHyphen()
    {
        var input = "あん\u002d";
        var result = Transliterate(input);
        Assert.Equal(input, result);
    }

    [Fact]
    public void TestHiraganaHatsuonWithHyphenAndAllowProlongedHatsuon()
    {
        var input = "あん\u002d";
        var expected = "あん\u30fc";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            AllowProlongedHatsuon = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestHalfwidthKatakanaSokuonWithHyphen()
    {
        var input = "ｳｯ\u002d";
        var result = Transliterate(input);
        Assert.Equal(input, result);
    }

    [Fact]
    public void TestHalfwidthKatakanaSokuonWithHyphenAndAllowProlongedSokuon()
    {
        var input = "ｳｯ\u002d";
        var expected = "ｳｯ\uff70";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            AllowProlongedSokuon = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestHalfwidthKatakanaHatsuonWithHyphen()
    {
        var input = "ｳﾝ\u002d";
        var result = Transliterate(input);
        Assert.Equal(input, result);
    }

    [Fact]
    public void TestHalfwidthKatakanaHatsuonWithHyphenAndAllowProlongedHatsuon()
    {
        var input = "ｳﾝ\u002d";
        var expected = "ｳﾝ\uff70";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            AllowProlongedHatsuon = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestHyphenAtStartOfString()
    {
        var input = "\u002dアイウ";
        var result = Transliterate(input);
        Assert.Equal(input, result);
    }

    [Fact]
    public void TestOnlyHyphens()
    {
        var input = "\u002d\uff0d\u2010\u2014\u2015\u2212";
        var result = Transliterate(input);
        Assert.Equal(input, result);
    }

    [Fact]
    public void TestNewlineAndTabCharacters()
    {
        var input = "ア\n\u002d\tイ\uff0d";
        var expected = "ア\n\u002d\tイ\u30fc";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestEmojiWithHyphens()
    {
        var input = "😀\u002d😊\uff0d";
        var result = Transliterate(input);
        Assert.Equal(input, result);
    }

    [Fact]
    public void TestUnicodeSurrogates()
    {
        var input = "\uD83D\uDE00ア\u002d\uD83D\uDE01イ\uff0d";
        var expected = "\uD83D\uDE00ア\u30fc\uD83D\uDE01イ\u30fc";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestOptionsEquals()
    {
        var options1 = new ProlongedSoundMarksTransliterator.Options
        {
            SkipAlreadyTransliteratedChars = true,
            AllowProlongedSokuon = true,
        };
        var options2 = new ProlongedSoundMarksTransliterator.Options
        {
            SkipAlreadyTransliteratedChars = true,
            AllowProlongedSokuon = true,
        };
        var options3 = new ProlongedSoundMarksTransliterator.Options
        {
            SkipAlreadyTransliteratedChars = false,
            AllowProlongedSokuon = true,
        };

        // Basic property tests
        Assert.True(options1.SkipAlreadyTransliteratedChars);
        Assert.True(options1.AllowProlongedSokuon);
        Assert.True(options2.SkipAlreadyTransliteratedChars);
        Assert.True(options2.AllowProlongedSokuon);
        Assert.False(options3.SkipAlreadyTransliteratedChars);
        Assert.True(options3.AllowProlongedSokuon);
    }

    [Theory]
    [InlineData("consecutive prolonged marks with alphanumerics", "A\u30fc\u30fc\u30fcB", "A\u002d\u002d\u002dB")]
    [InlineData("mixed width characters maintain consistency", "ｱ\uff0dア\u002d", "ｱ\uff70ア\u30fc")]
    [InlineData("prolonged mark followed by hyphen", "ア\u30fc\u002d", "ア\u30fc\u30fc")]
    public void TestParameterizedCases(string description, string input, string expected)
    {
        var options = description.Contains("alphanumerics")
            ? new ProlongedSoundMarksTransliterator.Options { ReplaceProlongedMarksFollowingAlnums = true }
            : new ProlongedSoundMarksTransliterator.Options();

        var result = Transliterate(input, options);
        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBetweenNonKanasOtherChars()
    {
        var input = "\u6f22\u30fc\u5b57";
        var expected = "\u6f22\uff0d\u5b57";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksBetweenNonKanas = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBetweenNonKanasHalfwidthAlnums()
    {
        var input = "1\u30fc2";
        var expected = "1\u002d2";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksBetweenNonKanas = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBetweenNonKanasFullwidthAlnums()
    {
        var input = "\uff11\u30fc\uff12";
        var expected = "\uff11\uff0d\uff12";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksBetweenNonKanas = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBetweenNonKanasAfterKanaNotReplaced()
    {
        var input = "\u30ab\u30fc\u6f22";
        var expected = "\u30ab\u30fc\u6f22";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksBetweenNonKanas = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBetweenNonKanasBeforeKanaNotReplaced()
    {
        var input = "\u6f22\u30fc\u30ab";
        var expected = "\u6f22\u30fc\u30ab";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksBetweenNonKanas = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBetweenNonKanasConsecutive()
    {
        var input = "\u6f22\u30fc\u30fc\u30fc\u5b57";
        var expected = "\u6f22\uff0d\uff0d\uff0d\u5b57";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksBetweenNonKanas = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBetweenNonKanasConsecutiveBeforeKanaPreserved()
    {
        var input = "\u6f22\u30fc\u30fc\u30fc\u30ab";
        var expected = "\u6f22\u30fc\u30fc\u30fc\u30ab";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksBetweenNonKanas = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBetweenNonKanasTrailingAfterFullwidth()
    {
        var input = "\u6f22\u30fc\u30fc\u30fc";
        var expected = "\u6f22\uff0d\uff0d\uff0d";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksBetweenNonKanas = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBetweenNonKanasTrailingAfterHalfwidth()
    {
        var input = "1\u30fc\u30fc\u30fc";
        var expected = "1\u002d\u002d\u002d";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksBetweenNonKanas = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBetweenNonKanasOnlyPsmAfterAlnumBeforeKana()
    {
        var input = "A\u30fc\u30ab";
        var expected = "A\u30fc\u30ab";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksBetweenNonKanas = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestReplaceProlongedMarksBothOptions()
    {
        var input = "A\u30fc\u30ab";
        var expected = "A\u002d\u30ab";
        var options = new ProlongedSoundMarksTransliterator.Options
        {
            ReplaceProlongedMarksFollowingAlnums = true,
            ReplaceProlongedMarksBetweenNonKanas = true,
        };
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }
}
