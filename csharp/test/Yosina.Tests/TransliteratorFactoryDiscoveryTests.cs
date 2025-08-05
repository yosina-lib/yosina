// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Tests;

public class TransliteratorFactoryDiscoveryTests
{
    [Fact]
    public void ShouldDiscoverAllRegisteredTransliterators()
    {
        var registeredNames = TransliteratorFactory.GetRegisteredNames().ToList();

        // Verify we have the expected transliterators
        var expectedNames = new[]
        {
            "spaces",
            "radicals",
            "mathematical-alphanumerics",
            "ideographic-annotations",
            "hyphens",
            "hira-kata-composition",
            "hira-kata",
            "ivs-svs-base",
            "jisx0201-and-alike",
            "kanji-old-new",
            "prolonged-sound-marks",
            "circled-or-squared",
            "combined",
            "japanese-iteration-marks",
        };

        foreach (var expectedName in expectedNames)
        {
            Assert.Contains(expectedName, registeredNames);
        }

        Assert.Equal(expectedNames.Length, registeredNames.Count);
    }

    [Theory]
    [InlineData("spaces")]
    [InlineData("radicals")]
    [InlineData("mathematical-alphanumerics")]
    [InlineData("ideographic-annotations")]
    [InlineData("hyphens")]
    [InlineData("hira-kata-composition")]
    [InlineData("ivs-svs-base")]
    [InlineData("kanji-old-new")]
    [InlineData("jisx0201-and-alike")]
    [InlineData("prolonged-sound-marks")]
    public void ShouldCreateTransliteratorByName(string name)
    {
        var transliterator = TransliteratorFactory.Create(name);
        Assert.NotNull(transliterator);
        Assert.IsAssignableFrom<ITransliterator>(transliterator);
    }

    [Fact]
    public void ShouldThrowForUnknownTransliterator()
    {
        Assert.Throws<ArgumentException>(() => TransliteratorFactory.Create("unknown"));
    }
}
