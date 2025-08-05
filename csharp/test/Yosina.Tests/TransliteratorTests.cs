// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

public class TransliteratorTests
{
    [Fact]
    public void HiraKataCompositionTransliterator_ComposeVoicedMarks()
    {
        // Test composing hiragana with voiced marks: か + ゛= が
        var inputString = "か\u3099"; // か + combining voiced sound mark
        var charList = Characters.CharacterList(inputString);
        var transliterator = new HiraKataCompositionTransliterator();
        var result = transliterator.Transliterate(charList);

        var chars = result.ToList();

        // Should have the composed character が plus sentinel
        Assert.True(chars.Count >= 1);
        var composed = chars.FirstOrDefault(c => !c.IsSentinel);
        Assert.NotNull(composed);
        Assert.Equal("が", composed.CodePoint.AsString());
    }

    [Fact]
    public void Jisx0201AndAlikeTransliterator_FullwidthToHalfwidth()
    {
        // Test fullwidth to halfwidth conversion: Ａ１ -> A1
        var inputString = "Ａ１"; // fullwidth A and 1
        var charList = Characters.CharacterList(inputString);
        var options = new Jisx0201AndAlikeTransliterator.Options
        {
            FullwidthToHalfwidth = true,
            ConvertGL = true,
        };
        var transliterator = new Jisx0201AndAlikeTransliterator(options);
        var result = transliterator.Transliterate(charList);

        var chars = result.Where(c => !c.IsSentinel).ToList();
        Assert.Equal(2, chars.Count);
        Assert.Equal("A", chars[0].CodePoint.AsString());
        Assert.Equal("1", chars[1].CodePoint.AsString());
    }

    [Fact]
    public void ProlongedSoundMarksTransliterator_ConvertHyphens()
    {
        // Test converting hyphens to prolonged sound marks: か- -> かー
        var inputString = "か-"; // ka + hyphen
        var charList = Characters.CharacterList(inputString);

        var transliterator = new ProlongedSoundMarksTransliterator();
        var result = transliterator.Transliterate(charList);

        var chars = result.Where(c => !c.IsSentinel).ToList();
        Assert.Equal(2, chars.Count);
        Assert.Equal("か", chars[0].CodePoint.AsString());
        Assert.Equal("ー", chars[1].CodePoint.AsString()); // Should be prolonged sound mark
    }

    [Fact]
    public void TransliteratorFactory_CreateTransliterators()
    {
        // Test factory creation
        var hiraKata = TransliteratorFactory.Create("hira-kata-composition");
        Assert.IsType<HiraKataCompositionTransliterator>(hiraKata);

        var jisx0201 = TransliteratorFactory.Create("jisx0201-and-alike");
        Assert.IsType<Jisx0201AndAlikeTransliterator>(jisx0201);

        var prolonged = TransliteratorFactory.Create("prolonged-sound-marks");
        Assert.IsType<ProlongedSoundMarksTransliterator>(prolonged);
    }

    [Fact]
    public void TransliteratorFactory_GetRegisteredNames()
    {
        var names = TransliteratorFactory.GetRegisteredNames().ToList();
        Assert.Contains("hira-kata-composition", names);
        Assert.Contains("jisx0201-and-alike", names);
        Assert.Contains("prolonged-sound-marks", names);
    }
}
