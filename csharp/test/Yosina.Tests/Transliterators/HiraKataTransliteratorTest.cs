// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests.Transliterators;

public class HiraKataTransliteratorTest
{
    public class HiraToKataTests
    {
        [Theory]
        [InlineData("あいうえお", "アイウエオ")]
        [InlineData("がぎぐげご", "ガギグゲゴ")]
        [InlineData("ぱぴぷぺぽ", "パピプペポ")]
        [InlineData("ぁぃぅぇぉっゃゅょ", "ァィゥェォッャュョ")]
        [InlineData("あいうえお123ABCアイウエオ", "アイウエオ123ABCアイウエオ")]
        [InlineData("こんにちは、世界！", "コンニチハ、世界！")]
        public void TestHiraToKataConversion(string input, string expected)
        {
            var transliterator = new HiraKataTransliterator(new HiraKataTransliterator.Options
            {
                Mode = HiraKataTransliterator.Mode.HiraToKata,
            });

            var result = transliterator.Transliterate(Characters.CharacterList(input)).AsString();
            Assert.Equal(expected, result);
        }
    }

    public class KataToHiraTests
    {
        [Theory]
        [InlineData("アイウエオ", "あいうえお")]
        [InlineData("ガギグゲゴ", "がぎぐげご")]
        [InlineData("パピプペポ", "ぱぴぷぺぽ")]
        [InlineData("ァィゥェォッャュョ", "ぁぃぅぇぉっゃゅょ")]
        [InlineData("アイウエオ123ABCあいうえお", "あいうえお123ABCあいうえお")]
        [InlineData("コンニチハ、世界！", "こんにちは、世界！")]
        [InlineData("ヴ", "ゔ")]
        [InlineData("ヷヸヹヺ", "ヷヸヹヺ")] // Special katakana remain unchanged
        public void TestKataToHiraConversion(string input, string expected)
        {
            var transliterator = new HiraKataTransliterator(new HiraKataTransliterator.Options
            {
                Mode = HiraKataTransliterator.Mode.KataToHira,
            });

            var result = transliterator.Transliterate(Characters.CharacterList(input)).AsString();
            Assert.Equal(expected, result);
        }
    }

    [Fact]
    public void TestDefaultConstructorUsesHiraToKataMode()
    {
        var transliterator = new HiraKataTransliterator();
        var result = transliterator.Transliterate(Characters.CharacterList("あいうえお")).AsString();
        Assert.Equal("アイウエオ", result);
    }
}
