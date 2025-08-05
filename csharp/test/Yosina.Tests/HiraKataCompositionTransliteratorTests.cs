// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

/// <summary>
/// Tests for HiraKataCompositionTransliterator based on Java test patterns.
/// </summary>
public class HiraKataCompositionTransliteratorTests
{
    private static string Transliterate(string input, HiraKataCompositionTransliterator.Options? options = null)
    {
        var transliterator = options != null
            ? new HiraKataCompositionTransliterator(options)
            : new HiraKataCompositionTransliterator();
        var charList = Characters.CharacterList(input);
        var result = transliterator.Transliterate(charList);
        return result.AsString();
    }

    [Fact]
    public void TestKatakanaWithCombiningVoicedMark()
    {
        var input = "\u30ab\u3099\u30ac\u30ad\u30ad\u3099\u30af";
        var expected = "\u30ac\u30ac\u30ad\u30ae\u30af";
        var result = Transliterate(input);
        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestKatakanaWithCombiningVoicedAndSemiVoicedMarks()
    {
        var input = "\u30cf\u30cf\u3099\u30cf\u309a\u30d2\u30d5\u30d8\u30db";
        var expected = "\u30cf\u30d0\u30d1\u30d2\u30d5\u30d8\u30db";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestHiraganaWithCombiningVoicedMark()
    {
        var input = "\u304b\u3099\u304c\u304d\u304d\u3099\u304f";
        var expected = "\u304c\u304c\u304d\u304e\u304f";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestHiraganaWithCombiningVoicedAndSemiVoicedMarks()
    {
        var input = "\u306f\u306f\u3099\u306f\u309a\u3072\u3075\u3078\u307b";
        var expected = "\u306f\u3070\u3071\u3072\u3075\u3078\u307b";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestKatakanaWithNonCombiningMarksEnabled()
    {
        var options = new HiraKataCompositionTransliterator.Options
        {
            ComposeNonCombiningMarks = true,
        };

        var input = "\u30cf\u30cf\u309b\u30cf\u309c\u30d2\u30d5\u30d8\u30db";
        var expected = "\u30cf\u30d0\u30d1\u30d2\u30d5\u30d8\u30db";
        var result = Transliterate(input, options);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestKatakanaWithNonCombiningMarksDisabled()
    {
        var options = new HiraKataCompositionTransliterator.Options
        {
            ComposeNonCombiningMarks = false,
        };

        var input = "\u30cf\u30cf\u309b\u30cf\u309c\u30d2\u30d5\u30d8\u30db";
        var expected = "\u30cf\u30cf\u309b\u30cf\u309c\u30d2\u30d5\u30d8\u30db";
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
    public void TestStringWithNoComposableCharacters()
    {
        var input = "hello world 123";
        var expected = "hello world 123";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestMixedTextWithHiraganaAndKatakana()
    {
        var input = "こんにちは\u304b\u3099世界\u30ab\u3099";
        var expected = "こんにちは\u304c世界\u30ac";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestCombiningMarksWithoutBaseCharacter()
    {
        var input = "\u3099\u309a\u309b\u309c";
        var expected = "\u3099\u309a\u309b\u309c";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestHiraganaUWithDakuten()
    {
        var input = "\u3046\u3099";
        var expected = "\u3094";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestKatakanaUWithDakuten()
    {
        var input = "\u30a6\u3099";
        var expected = "\u30f4";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestMultipleCompositionsInSequence()
    {
        var input = "\u304b\u3099\u304d\u3099\u304f\u3099\u3051\u3099\u3053\u3099";
        var expected = "\u304c\u304e\u3050\u3052\u3054";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestNonComposableCharacterFollowedByCombiningMark()
    {
        var input = "\u3042\u3099";
        var expected = "\u3042\u3099";
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestOptionsEquals()
    {
        var options1 = new HiraKataCompositionTransliterator.Options
        {
            ComposeNonCombiningMarks = true,
        };
        var options2 = new HiraKataCompositionTransliterator.Options
        {
            ComposeNonCombiningMarks = true,
        };
        var options3 = new HiraKataCompositionTransliterator.Options
        {
            ComposeNonCombiningMarks = false,
        };

        // Basic property tests
        Assert.True(options1.ComposeNonCombiningMarks);
        Assert.True(options2.ComposeNonCombiningMarks);
        Assert.False(options3.ComposeNonCombiningMarks);
    }

    [Fact]
    public void TestHiraganaIterationMark()
    {
        var input = "\u309d\u3099"; // ゝ + combining voiced mark
        var expected = "\u309e"; // ゞ
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestKatakanaIterationMark()
    {
        var input = "\u30fd\u3099"; // ヽ + combining voiced mark
        var expected = "\u30fe"; // ヾ
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestKatakanaWaRow()
    {
        var input = "\u30ef\u3099"; // ワ + combining voiced mark
        var expected = "\u30f7"; // ヷ
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestPartialComposition()
    {
        // Test where a character can be composed but no combining mark follows
        var input = "\u304b\u3042"; // か + あ (no combining mark)
        var expected = "\u304b\u3042"; // Should remain unchanged
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestSemiVoicedComposition()
    {
        var input = "\u306f\u309a"; // は + combining semi-voiced mark
        var expected = "\u3071"; // ぱ
        var result = Transliterate(input);

        Assert.Equal(expected, result);
    }

    [Theory]
    [InlineData("\u304b\u3099", "\u304c")]
    [InlineData("\u306f\u3099", "\u3070")]
    [InlineData("\u306f\u309a", "\u3071")]
    [InlineData("\u30ab\u3099", "\u30ac")]
    [InlineData("\u30cf\u3099", "\u30d0")]
    [InlineData("\u30cf\u309a", "\u30d1")]
    [InlineData("\u304c", "\u304c")]
    [InlineData("a\u3099", "a\u3099")]
    [InlineData("\u309d\u3099", "\u309e")] // Hiragana iteration mark: ゝ + ゛ → ゞ
    [InlineData("\u30fd\u3099", "\u30fe")] // Katakana iteration mark: ヽ + ゛ → ヾ
    [InlineData("\u3031\u3099", "\u3032")] // Vertical hiragana iteration mark: 〱 + ゛ → 〲
    [InlineData("\u3033\u3099", "\u3034")] // Vertical katakana iteration mark: 〳 + ゛ → 〴
    public void TestCompositionTestCases(string input, string expected)
    {
        var result = Transliterate(input);
        Assert.Equal(expected, result);
    }

    [Fact]
    public void TestIterationMarksWithNonCombiningMarks()
    {
        var options = new HiraKataCompositionTransliterator.Options
        {
            ComposeNonCombiningMarks = true,
        };

        // Test hiragana iteration mark with non-combining voiced mark
        var input1 = "\u309d\u309b"; // ゝ + ゛ (non-combining)
        var expected1 = "\u309e"; // ゞ
        var result1 = Transliterate(input1, options);
        Assert.Equal(expected1, result1);

        // Test katakana iteration mark with non-combining voiced mark
        var input2 = "\u30fd\u309b"; // ヽ + ゛ (non-combining)
        var expected2 = "\u30fe"; // ヾ
        var result2 = Transliterate(input2, options);
        Assert.Equal(expected2, result2);

        // Test vertical hiragana iteration mark with non-combining voiced mark
        var input3 = "\u3031\u309b"; // 〱 + ゛ (non-combining)
        var expected3 = "\u3032"; // 〲
        var result3 = Transliterate(input3, options);
        Assert.Equal(expected3, result3);

        // Test vertical katakana iteration mark with non-combining voiced mark
        var input4 = "\u3033\u309b"; // 〳 + ゛ (non-combining)
        var expected4 = "\u3034"; // 〴
        var result4 = Transliterate(input4, options);
        Assert.Equal(expected4, result4);
    }
}
