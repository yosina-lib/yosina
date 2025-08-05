// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

/// <summary>
/// Tests for JapaneseIterationMarksTransliterator.
/// </summary>
public class JapaneseIterationMarksTransliteratorTests
{
    private static string Transliterate(string input)
    {
        var transliterator = new JapaneseIterationMarksTransliterator();
        var charList = Characters.CharacterList(input);
        var result = transliterator.Transliterate(charList);
        return result.AsString();
    }

    [Fact]
    public void TestBasicHiraganaRepetition()
    {
        // Basic hiragana repetition
        Assert.Equal("ささ", Transliterate("さゝ"));

        // Multiple hiragana repetitions
        Assert.Equal("みみこころ", Transliterate("みゝこゝろ"));
    }

    [Fact]
    public void TestHiraganaVoicedRepetition()
    {
        // Hiragana voiced repetition
        Assert.Equal("はば", Transliterate("はゞ"));

        // Multiple voiced repetitions
        Assert.Equal("ただしじま", Transliterate("たゞしゞま"));
    }

    [Fact]
    public void TestBasicKatakanaRepetition()
    {
        // Basic katakana repetition
        Assert.Equal("ササ", Transliterate("サヽ"));
    }

    [Fact]
    public void TestKatakanaVoicedRepetition()
    {
        // Katakana voiced repetition
        Assert.Equal("ハバ", Transliterate("ハヾ"));

        // Special case: ウ with voicing
        Assert.Equal("ウヴ", Transliterate("ウヾ"));
    }

    [Fact]
    public void TestKanjiRepetition()
    {
        // Basic kanji repetition
        Assert.Equal("人人", Transliterate("人々"));

        // Multiple kanji repetitions
        Assert.Equal("日日月月年年", Transliterate("日々月々年々"));

        // Kanji in compound words
        Assert.Equal("色色", Transliterate("色々"));
    }

    [Fact]
    public void TestInvalidCombinations()
    {
        // Hiragana mark after katakana
        Assert.Equal("カゝ", Transliterate("カゝ"));

        // Katakana mark after hiragana
        Assert.Equal("かヽ", Transliterate("かヽ"));

        // Kanji mark after hiragana
        Assert.Equal("か々", Transliterate("か々"));

        // Iteration mark at start
        Assert.Equal("ゝあ", Transliterate("ゝあ"));
    }

    [Fact]
    public void TestConsecutiveIterationMarks()
    {
        // Consecutive iteration marks - only first should be expanded
        Assert.Equal("ささゝ", Transliterate("さゝゝ"));
    }

    [Fact]
    public void TestNonRepeatableCharacters()
    {
        // Hiragana hatsuon can't repeat
        Assert.Equal("んゝ", Transliterate("んゝ"));

        // Hiragana sokuon can't repeat
        Assert.Equal("っゝ", Transliterate("っゝ"));

        // Katakana hatsuon can't repeat
        Assert.Equal("ンヽ", Transliterate("ンヽ"));

        // Katakana sokuon can't repeat
        Assert.Equal("ッヽ", Transliterate("ッヽ"));

        // Voiced character can't voice again
        Assert.Equal("がゞ", Transliterate("がゞ"));

        // Semi-voiced character can't voice
        Assert.Equal("ぱゞ", Transliterate("ぱゞ"));
    }

    [Fact]
    public void TestMixedText()
    {
        // Mixed hiragana, katakana, and kanji
        Assert.Equal("こころ、ココロ、其其", Transliterate("こゝろ、コヽロ、其々"));

        // Iteration marks in sentence
        Assert.Equal("日日の暮らしはささやか", Transliterate("日々の暮らしはさゝやか"));
    }

    [Fact]
    public void TestHalfwidthKatakana()
    {
        // Halfwidth katakana should not be supported
        Assert.Equal("ｻヽ", Transliterate("ｻヽ"));
    }

    [Fact]
    public void TestVoicingEdgeCases()
    {
        // No voicing possible
        Assert.Equal("あゞ", Transliterate("あゞ"));

        // Voicing all consonants
        Assert.Equal("かがただはばさざ", Transliterate("かゞたゞはゞさゞ"));
    }

    [Fact]
    public void TestComplexScenarios()
    {
        // Multiple types in sequence
        Assert.Equal("思思にこころサザめく", Transliterate("思々にこゝろサヾめく"));
    }

    [Fact]
    public void TestEmptyString()
    {
        Assert.Equal(string.Empty, Transliterate(string.Empty));
    }

    [Fact]
    public void TestNoIterationMarks()
    {
        string input = "これはテストです";
        Assert.Equal(input, Transliterate(input));
    }

    [Fact]
    public void TestIterationMarkAfterSpace()
    {
        Assert.Equal("さ ゝ", Transliterate("さ ゝ"));
    }

    [Fact]
    public void TestIterationMarkAfterPunctuation()
    {
        Assert.Equal("さ、ゝ", Transliterate("さ、ゝ"));
    }

    [Fact]
    public void TestIterationMarkAfterASCII()
    {
        Assert.Equal("Aゝ", Transliterate("Aゝ"));
    }

    [Fact]
    public void TestCJKExtensionKanji()
    {
        // CJK Extension A kanji
        Assert.Equal("㐀㐀", Transliterate("㐀々"));
    }

    [Fact]
    public void TestMultipleIterationMarksInDifferentContexts()
    {
        // Test various combinations
        Assert.Equal("すすむ、タダカウ、山山", Transliterate("すゝむ、タヾカウ、山々"));
        Assert.Equal("はは、マヾ", Transliterate("はゝ、マヾ")); // マ doesn't have voicing
    }

    [Fact]
    public void TestKanjiIterationMarkAfterKatakana()
    {
        // Kanji iteration mark should not work after katakana
        Assert.Equal("ア々", Transliterate("ア々"));
    }

    [Fact]
    public void TestVoicingVariations()
    {
        // Test all possible voicing combinations for hiragana
        Assert.Equal("かが", Transliterate("かゞ"));
        Assert.Equal("きぎ", Transliterate("きゞ"));
        Assert.Equal("くぐ", Transliterate("くゞ"));
        Assert.Equal("けげ", Transliterate("けゞ"));
        Assert.Equal("こご", Transliterate("こゞ"));
        Assert.Equal("さざ", Transliterate("さゞ"));
        Assert.Equal("しじ", Transliterate("しゞ"));
        Assert.Equal("すず", Transliterate("すゞ"));
        Assert.Equal("せぜ", Transliterate("せゞ"));
        Assert.Equal("そぞ", Transliterate("そゞ"));
        Assert.Equal("ただ", Transliterate("たゞ"));
        Assert.Equal("ちぢ", Transliterate("ちゞ"));
        Assert.Equal("つづ", Transliterate("つゞ"));
        Assert.Equal("てで", Transliterate("てゞ"));
        Assert.Equal("とど", Transliterate("とゞ"));
        Assert.Equal("はば", Transliterate("はゞ"));
        Assert.Equal("ひび", Transliterate("ひゞ"));
        Assert.Equal("ふぶ", Transliterate("ふゞ"));
        Assert.Equal("へべ", Transliterate("へゞ"));
        Assert.Equal("ほぼ", Transliterate("ほゞ"));
    }

    [Fact]
    public void TestKatakanaVoicingVariations()
    {
        // Test all possible voicing combinations for katakana
        Assert.Equal("カガ", Transliterate("カヾ"));
        Assert.Equal("キギ", Transliterate("キヾ"));
        Assert.Equal("クグ", Transliterate("クヾ"));
        Assert.Equal("ケゲ", Transliterate("ケヾ"));
        Assert.Equal("コゴ", Transliterate("コヾ"));
        Assert.Equal("サザ", Transliterate("サヾ"));
        Assert.Equal("シジ", Transliterate("シヾ"));
        Assert.Equal("スズ", Transliterate("スヾ"));
        Assert.Equal("セゼ", Transliterate("セヾ"));
        Assert.Equal("ソゾ", Transliterate("ソヾ"));
        Assert.Equal("タダ", Transliterate("タヾ"));
        Assert.Equal("チヂ", Transliterate("チヾ"));
        Assert.Equal("ツヅ", Transliterate("ツヾ"));
        Assert.Equal("テデ", Transliterate("テヾ"));
        Assert.Equal("トド", Transliterate("トヾ"));
        Assert.Equal("ハバ", Transliterate("ハヾ"));
        Assert.Equal("ヒビ", Transliterate("ヒヾ"));
        Assert.Equal("フブ", Transliterate("フヾ"));
        Assert.Equal("ヘベ", Transliterate("ヘヾ"));
        Assert.Equal("ホボ", Transliterate("ホヾ"));
        Assert.Equal("ウヴ", Transliterate("ウヾ"));
    }

    [Fact]
    public void TestIterationMarkCombinations()
    {
        // Different iteration marks in sequence
        Assert.Equal("ささカカ山山", Transliterate("さゝカヽ山々"));

        // Mixed with normal text
        Assert.Equal("これはささやかな日日です", Transliterate("これはさゝやかな日々です"));
    }

    [Fact]
    public void TestSpecialCharactersAsIterationTarget()
    {
        // Small characters can be repeated since they are valid hiragana/katakana
        Assert.Equal("ゃゃ", Transliterate("ゃゝ")); // Small ya can be repeated
        Assert.Equal("ャャ", Transliterate("ャヽ")); // Small katakana ya can be repeated

        // Prolonged sound mark
        Assert.Equal("ーヽ", Transliterate("ーヽ")); // Prolonged sound mark can't be repeated (not katakana)
    }

    [Fact]
    public void TestNumbersAndIterationMarks()
    {
        // Numbers followed by iteration marks
        Assert.Equal("1ゝ", Transliterate("1ゝ"));
        Assert.Equal("１ゝ", Transliterate("１ゝ"));
    }

    [Fact]
    public void TestComplexKanjiRanges()
    {
        // Test various CJK ranges
        // CJK Extension B
        Assert.Equal("𠀀𠀀", Transliterate("𠀀々")); // 𠀀𠀀

        // CJK Extension C
        Assert.Equal("𪀀𪀀", Transliterate("𪀀々")); // 𪀀𪀀
    }

    [Fact]
    public void TestRealWorldExamples()
    {
        // Common real-world usage
        Assert.Equal("人人", Transliterate("人々"));
        Assert.Equal("時時", Transliterate("時々"));
        Assert.Equal("様様", Transliterate("様々"));
        Assert.Equal("国国", Transliterate("国々"));
        Assert.Equal("所所", Transliterate("所々"));

        // In context
        Assert.Equal("様様な国国から", Transliterate("様々な国々から"));
        Assert.Equal("時時刻刻", Transliterate("時々刻々"));
    }

    [Fact]
    public void TestEdgeCasesWithPunctuation()
    {
        // Various punctuation between characters and iteration marks
        Assert.Equal("さ。ゝ", Transliterate("さ。ゝ"));
        Assert.Equal("さ！ゝ", Transliterate("さ！ゝ"));
        Assert.Equal("さ？ゝ", Transliterate("さ？ゝ"));
        Assert.Equal("さ「ゝ", Transliterate("さ「ゝ"));
        Assert.Equal("さ」ゝ", Transliterate("さ」ゝ"));
    }

    [Fact]
    public void TestMixedScriptBoundaries()
    {
        // Script boundaries - iteration marks should work within same script type
        Assert.Equal("漢字かか", Transliterate("漢字かゝ")); // Hiragana iteration mark works after hiragana
        Assert.Equal("ひらがなカカ", Transliterate("ひらがなカヽ")); // Katakana iteration mark works after katakana
        Assert.Equal("カタカナ人人", Transliterate("カタカナ人々")); // Kanji iteration mark works after kanji
    }

    [Fact]
    public void TestFactoryIntegration()
    {
        // Test that the transliterator can be created via factory
        var transliterator = TransliteratorFactory.Create("japanese-iteration-marks");

        var result1 = transliterator.Transliterate(Characters.CharacterList("さゝ")).AsString();
        Assert.Equal("ささ", result1);

        var result2 = transliterator.Transliterate(Characters.CharacterList("人々")).AsString();
        Assert.Equal("人人", result2);
    }
}
