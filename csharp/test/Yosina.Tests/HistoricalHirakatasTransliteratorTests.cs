// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

public class HistoricalHirakatasTransliteratorTests
{
    private static string Transliterate(string input, HistoricalHirakatasTransliterator.Options? options = null)
    {
        var transliterator = new HistoricalHirakatasTransliterator(options ?? new HistoricalHirakatasTransliterator.Options());
        var charList = Characters.CharacterList(input);
        var result = transliterator.Transliterate(charList);
        return result.AsString();
    }

    [Fact]
    public void SimpleHiraganaDefault()
    {
        Assert.Equal("いえ", Transliterate("ゐゑ"));
    }

    [Fact]
    public void Passthrough()
    {
        Assert.Equal("あいう", Transliterate("あいう"));
    }

    [Fact]
    public void MixedInput()
    {
        Assert.Equal("あいいえう", Transliterate("あゐいゑう"));
    }

    [Fact]
    public void DecomposeHiragana()
    {
        var options = new HistoricalHirakatasTransliterator.Options
        {
            Hiraganas = HistoricalHirakatasTransliterator.ConversionMode.Decompose,
            Katakanas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
        };
        Assert.Equal("うぃうぇ", Transliterate("ゐゑ", options));
    }

    [Fact]
    public void SkipHiragana()
    {
        var options = new HistoricalHirakatasTransliterator.Options
        {
            Hiraganas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            Katakanas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
        };
        Assert.Equal("ゐゑ", Transliterate("ゐゑ", options));
    }

    [Fact]
    public void SimpleKatakanaDefault()
    {
        Assert.Equal("イエ", Transliterate("ヰヱ"));
    }

    [Fact]
    public void DecomposeKatakana()
    {
        var options = new HistoricalHirakatasTransliterator.Options
        {
            Hiraganas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            Katakanas = HistoricalHirakatasTransliterator.ConversionMode.Decompose,
        };
        Assert.Equal("ウィウェ", Transliterate("ヰヱ", options));
    }

    [Fact]
    public void VoicedKatakanaDecompose()
    {
        var options = new HistoricalHirakatasTransliterator.Options
        {
            Hiraganas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            Katakanas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            VoicedKatakanas = HistoricalHirakatasTransliterator.VoicedConversionMode.Decompose,
        };
        Assert.Equal("ヴァヴィヴェヴォ", Transliterate("ヷヸヹヺ", options));
    }

    [Fact]
    public void VoicedKatakanaSkipDefault()
    {
        var options = new HistoricalHirakatasTransliterator.Options
        {
            Hiraganas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            Katakanas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
        };
        Assert.Equal("ヷヸヹヺ", Transliterate("ヷヸヹヺ", options));
    }

    [Fact]
    public void AllDecompose()
    {
        var options = new HistoricalHirakatasTransliterator.Options
        {
            Hiraganas = HistoricalHirakatasTransliterator.ConversionMode.Decompose,
            Katakanas = HistoricalHirakatasTransliterator.ConversionMode.Decompose,
            VoicedKatakanas = HistoricalHirakatasTransliterator.VoicedConversionMode.Decompose,
        };
        Assert.Equal("うぃうぇウィウェヴァヴィヴェヴォ", Transliterate("ゐゑヰヱヷヸヹヺ", options));
    }

    [Fact]
    public void AllSkip()
    {
        var options = new HistoricalHirakatasTransliterator.Options
        {
            Hiraganas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            Katakanas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            VoicedKatakanas = HistoricalHirakatasTransliterator.VoicedConversionMode.Skip,
        };
        Assert.Equal("ゐゑヰヱヷヸヹヺ", Transliterate("ゐゑヰヱヷヸヹヺ", options));
    }

    [Fact]
    public void DecomposedVoicedKatakanaDecompose()
    {
        var options = new HistoricalHirakatasTransliterator.Options
        {
            Hiraganas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            Katakanas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            VoicedKatakanas = HistoricalHirakatasTransliterator.VoicedConversionMode.Decompose,
        };
        Assert.Equal("ウ\u3099ァウ\u3099ィウ\u3099ェウ\u3099ォ", Transliterate("ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099", options));
    }

    [Fact]
    public void DecomposedVoicedKatakanaSkip()
    {
        var options = new HistoricalHirakatasTransliterator.Options
        {
            Hiraganas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            Katakanas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            VoicedKatakanas = HistoricalHirakatasTransliterator.VoicedConversionMode.Skip,
        };
        Assert.Equal("ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099", Transliterate("ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099", options));
    }

    [Fact]
    public void DecomposedVoicedNotSplitFromBase()
    {
        var options = new HistoricalHirakatasTransliterator.Options
        {
            Hiraganas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            Katakanas = HistoricalHirakatasTransliterator.ConversionMode.Simple,
            VoicedKatakanas = HistoricalHirakatasTransliterator.VoicedConversionMode.Skip,
        };
        Assert.Equal("ヰ\u3099", Transliterate("ヰ\u3099", options));
    }

    [Fact]
    public void DecomposedVoicedWithDecompose()
    {
        var options = new HistoricalHirakatasTransliterator.Options
        {
            Hiraganas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            Katakanas = HistoricalHirakatasTransliterator.ConversionMode.Skip,
            VoicedKatakanas = HistoricalHirakatasTransliterator.VoicedConversionMode.Decompose,
        };
        Assert.Equal("ウ\u3099ィ", Transliterate("ヰ\u3099", options));
    }

    [Fact]
    public void EmptyInput()
    {
        Assert.Equal(string.Empty, Transliterate(string.Empty));
    }
}
