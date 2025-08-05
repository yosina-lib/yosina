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

    public static IEnumerable<object[]> TestData()
    {
        // Hiragana repetition mark ゝ - valid cases
        yield return new object[] { "かゝ", "かか" };
        yield return new object[] { "きゝ", "きき" };
        yield return new object[] { "すゝ", "すす" };
        yield return new object[] { "たゝ", "たた" };
        yield return new object[] { "なゝ", "なな" };
        yield return new object[] { "はゝ", "はは" };
        yield return new object[] { "まゝ", "まま" };
        yield return new object[] { "やゝ", "やや" };
        yield return new object[] { "らゝ", "らら" };
        yield return new object[] { "わゝ", "わわ" };
        yield return new object[] { "がゝ", "がか" }; // voiced character

        // Hiragana repetition mark ゝ - invalid cases (should remain unchanged)
        yield return new object[] { "んゝ", "んゝ" }; // hatsuon cannot be repeated
        yield return new object[] { "っゝ", "っゝ" }; // sokuon cannot be repeated
        yield return new object[] { "ぱゝ", "ぱゝ" }; // semi-voiced character cannot be repeated

        // Hiragana voiced repetition mark ゞ - valid cases
        yield return new object[] { "かゞ", "かが" };
        yield return new object[] { "がゞ", "がが" };
        yield return new object[] { "きゞ", "きぎ" };
        yield return new object[] { "くゞ", "くぐ" };
        yield return new object[] { "さゞ", "さざ" };
        yield return new object[] { "しゞ", "しじ" };
        yield return new object[] { "たゞ", "ただ" };
        yield return new object[] { "はゞ", "はば" };

        // Hiragana voiced repetition mark ゞ - invalid cases
        yield return new object[] { "あゞ", "あゞ" }; // 'あ' cannot be voiced
        yield return new object[] { "んゞ", "んゞ" }; // hatsuon cannot be repeated
        yield return new object[] { "っゞ", "っゞ" }; // sokuon cannot be repeated

        // Katakana repetition mark ヽ - valid cases
        yield return new object[] { "カヽ", "カカ" };
        yield return new object[] { "キヽ", "キキ" };
        yield return new object[] { "スヽ", "スス" };
        yield return new object[] { "タヽ", "タタ" };
        yield return new object[] { "ガヽ", "ガカ" }; // voiced character cannot be repeated

        // Katakana repetition mark ヽ - invalid cases
        yield return new object[] { "ンヽ", "ンヽ" }; // hatsuon cannot be repeated
        yield return new object[] { "ッヽ", "ッヽ" }; // sokuon cannot be repeated
        yield return new object[] { "パヽ", "パヽ" }; // semi-voiced character cannot be repeated

        // Katakana voiced repetition mark ヾ - valid cases
        yield return new object[] { "カヾ", "カガ" };
        yield return new object[] { "キヾ", "キギ" };
        yield return new object[] { "クヾ", "クグ" };
        yield return new object[] { "サヾ", "サザ" };
        yield return new object[] { "タヾ", "タダ" };
        yield return new object[] { "ハヾ", "ハバ" };
        yield return new object[] { "ガヾ", "ガガ" }; // already voiced character

        // Katakana voiced repetition mark ヾ - invalid cases
        yield return new object[] { "アヾ", "アヾ" }; // 'ア' cannot be voiced

        // Kanji repetition mark 々 - valid cases
        yield return new object[] { "人々", "人人" };
        yield return new object[] { "山々", "山山" };
        yield return new object[] { "木々", "木木" };
        yield return new object[] { "日々", "日日" };

        // Kanji repetition mark 々 - invalid cases
        yield return new object[] { "か々", "か々" }; // hiragana before 々
        yield return new object[] { "カ々", "カ々" }; // katakana before 々

        // Edge cases and combinations
        yield return new object[] { "かゝきゝ", "かかきき" };
        yield return new object[] { "かゞきゞ", "かがきぎ" };
        yield return new object[] { "カヽキヽ", "カカキキ" };
        yield return new object[] { "カヾキヾ", "カガキギ" };
        yield return new object[] { "人々山々", "人人山山" };

        // Mixed script cases
        yield return new object[] { "こゝろ、コヽロ、其々", "こころ、ココロ、其其" };

        // No previous character cases
        yield return new object[] { "ゝ", "ゝ" }; // no previous character
        yield return new object[] { "ゞ", "ゞ" }; // no previous character
        yield return new object[] { "ヽ", "ヽ" }; // no previous character
        yield return new object[] { "ヾ", "ヾ" }; // no previous character
        yield return new object[] { "々", "々" }; // no previous character

        // Complex sentences
        yield return new object[] { "私はこゝで勉強します", "私はここで勉強します" };
        yield return new object[] { "トヽロのキヽ", "トトロのキキ" };
        yield return new object[] { "山々の木々", "山山の木木" };

        // Vertical kana repeat marks (U+3031, U+3032, U+3033, U+3034)
        // U+3031 〱 - vertical hiragana repeat mark
        yield return new object[] { "か〱", "かか" };
        yield return new object[] { "き〱", "きき" };
        yield return new object[] { "が〱", "がか" }; // voiced character followed by unvoiced vertical mark
        yield return new object[] { "ん〱", "ん〱" }; // hatsuon cannot be repeated
        yield return new object[] { "っ〱", "っ〱" }; // sokuon cannot be repeated

        // U+3032 〲 - vertical hiragana voiced repeat mark
        yield return new object[] { "か〲", "かが" };
        yield return new object[] { "き〲", "きぎ" };
        yield return new object[] { "が〲", "がが" }; // voiced character followed by voiced vertical mark
        yield return new object[] { "あ〲", "あ〲" }; // 'あ' cannot be voiced

        // U+3033 〳 - vertical katakana repeat mark
        yield return new object[] { "カ〳", "カカ" };
        yield return new object[] { "キ〳", "キキ" };
        yield return new object[] { "ガ〳", "ガカ" }; // voiced character followed by unvoiced vertical mark
        yield return new object[] { "ン〳", "ン〳" }; // hatsuon cannot be repeated
        yield return new object[] { "ッ〳", "ッ〳" }; // sokuon cannot be repeated

        // U+3034 〴 - vertical katakana voiced repeat mark
        yield return new object[] { "カ〴", "カガ" };
        yield return new object[] { "キ〴", "キギ" };
        yield return new object[] { "ガ〴", "ガガ" }; // voiced character followed by voiced vertical mark
        yield return new object[] { "ア〴", "ア〴" }; // 'ア' cannot be voiced

        // Mixed vertical marks with regular text
        yield return new object[] { "こ〱もコ〳ロも", "ここもココロも" };
        yield return new object[] { "は〲とハ〴", "はばとハバ" };

        // Vertical marks at beginning (no previous character)
        yield return new object[] { "〱", "〱" }; // no previous character
        yield return new object[] { "〲", "〲" }; // no previous character
        yield return new object[] { "〳", "〳" }; // no previous character
        yield return new object[] { "〴", "〴" }; // no previous character
    }

    [Theory]
    [MemberData(nameof(TestData))]
    public void TestJapaneseIterationMarks(string input, string expected)
    {
        Assert.Equal(expected, Transliterate(input));
    }

    [Fact]
    public void TestAllHiraganaVoicingCombinations()
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
    public void TestAllKatakanaVoicingCombinations()
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
    public void TestConsecutiveIterationMarks()
    {
        // Consecutive iteration marks - only first should be expanded
        Assert.Equal("ささゝ", Transliterate("さゝゝ"));
    }

    [Fact]
    public void TestVoicedCharacterWithUnvoicedIterationMark()
    {
        // Voiced character can be iterated as unvoiced
        Assert.Equal("づつ", Transliterate("づゝ"));

        // Semi-voiced character can't voice
        Assert.Equal("ぱゞ", Transliterate("ぱゞ"));
    }

    [Fact]
    public void TestHalfwidthKatakana()
    {
        // Halfwidth katakana should not be supported
        Assert.Equal("ｻヽ", Transliterate("ｻヽ"));
    }

    [Fact]
    public void TestNoVoicingPossible()
    {
        // No voicing possible
        Assert.Equal("あゞ", Transliterate("あゞ"));

        // Mixed test with マ which doesn't have voicing
        Assert.Equal("はは、マヾ", Transliterate("はゝ、マヾ"));
    }

    [Fact]
    public void TestIterationMarkAfterNonJapanese()
    {
        // After space
        Assert.Equal("さ ゝ", Transliterate("さ ゝ"));

        // After punctuation
        Assert.Equal("さ、ゝ", Transliterate("さ、ゝ"));
        Assert.Equal("さ。ゝ", Transliterate("さ。ゝ"));
        Assert.Equal("さ！ゝ", Transliterate("さ！ゝ"));
        Assert.Equal("さ？ゝ", Transliterate("さ？ゝ"));
        Assert.Equal("さ「ゝ", Transliterate("さ「ゝ"));
        Assert.Equal("さ」ゝ", Transliterate("さ」ゝ"));

        // After ASCII
        Assert.Equal("Aゝ", Transliterate("Aゝ"));

        // After numbers
        Assert.Equal("1ゝ", Transliterate("1ゝ"));
        Assert.Equal("１ゝ", Transliterate("１ゝ"));
    }

    [Fact]
    public void TestCJKExtensions()
    {
        // CJK Extension A kanji
        Assert.Equal("㐀㐀", Transliterate("㐀々"));

        // CJK Extension B
        Assert.Equal("𠀀𠀀", Transliterate("𠀀々"));

        // CJK Extension C
        Assert.Equal("𪀀𪀀", Transliterate("𪀀々"));
    }

    [Fact]
    public void TestSmallKanaCanBeRepeated()
    {
        // Small characters can be repeated since they are valid hiragana/katakana
        Assert.Equal("ゃゃ", Transliterate("ゃゝ"));
        Assert.Equal("ャャ", Transliterate("ャヽ"));

        // Prolonged sound mark can't be repeated (not katakana)
        Assert.Equal("ーヽ", Transliterate("ーヽ"));
    }

    [Fact]
    public void TestMixedScriptWithInvalidCombinations()
    {
        // Hiragana mark after katakana
        Assert.Equal("カゝ", Transliterate("カゝ"));

        // Katakana mark after hiragana
        Assert.Equal("かヽ", Transliterate("かヽ"));

        // Kanji mark after hiragana
        Assert.Equal("か々", Transliterate("か々"));

        // Kanji mark after katakana
        Assert.Equal("ア々", Transliterate("ア々"));
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
        Assert.Equal("日日の暮らしはささやか", Transliterate("日々の暮らしはさゝやか"));

        // Complex scenarios
        Assert.Equal("思思にこころサザめく", Transliterate("思々にこゝろサヾめく"));
        Assert.Equal("すすむ、タダカウ、山山", Transliterate("すゝむ、タヾカウ、山々"));
        Assert.Equal("これはささやかな日日です", Transliterate("これはさゝやかな日々です"));
    }

    [Fact]
    public void TestMixedScriptBoundaries()
    {
        // Script boundaries - iteration marks should work within same script type
        Assert.Equal("漢字かか", Transliterate("漢字かゝ"));
        Assert.Equal("ひらがなカカ", Transliterate("ひらがなカヽ"));
        Assert.Equal("カタカナ人人", Transliterate("カタカナ人々"));
    }

    [Fact]
    public void TestEmptyAndNoIterationMarks()
    {
        Assert.Equal(string.Empty, Transliterate(string.Empty));

        string input = "これはテストです";
        Assert.Equal(input, Transliterate(input));
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
