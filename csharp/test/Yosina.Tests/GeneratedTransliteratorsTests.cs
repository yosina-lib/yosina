// Copyright (c) Yosina. All rights reserved.

using Yosina.Transliterators;

namespace Yosina.Tests;

public class GeneratedTransliteratorsTests
{
    [Fact]
    public void SpacesTransliterator_ReplacesVariousSpaces()
    {
        var transliterator = new SpacesTransliterator();

        // Test non-breaking space
        var inputString = "\u00A0"; // non-breaking space
        var charList = Characters.CharacterList(inputString);
        var result = transliterator.Transliterate(charList);
        var chars = result.Where(c => !c.IsSentinel).ToList();
        var singleChar = Assert.Single(chars);
        Assert.Equal(" ", singleChar.CodePoint.AsString());

        // Test ideographic space
        inputString = "\u3000"; // ideographic space
        charList = Characters.CharacterList(inputString);
        result = transliterator.Transliterate(charList);
        chars = result.Where(c => !c.IsSentinel).ToList();
        singleChar = Assert.Single(chars);
        Assert.Equal(" ", singleChar.CodePoint.AsString());
    }

    [Fact]
    public void TransliteratorFactory_CreatesGeneratedTransliterators()
    {
        // Test that all generated transliterators can be created via factory
        var spaces = TransliteratorFactory.Create("spaces");
        Assert.IsType<SpacesTransliterator>(spaces);

        var radicals = TransliteratorFactory.Create("radicals");
        Assert.IsType<RadicalsTransliterator>(radicals);

        var mathAlphanumerics = TransliteratorFactory.Create("mathematical-alphanumerics");
        Assert.IsType<MathematicalAlphanumericsTransliterator>(mathAlphanumerics);

        var ideographicAnnotations = TransliteratorFactory.Create("ideographic-annotations");
        Assert.IsType<IdeographicAnnotationsTransliterator>(ideographicAnnotations);

        var hyphens = TransliteratorFactory.Create("hyphens");
        Assert.IsType<HyphensTransliterator>(hyphens);
    }

    [Fact]
    public void TransliteratorFactory_GetRegisteredNames_IncludesGeneratedTransliterators()
    {
        var names = TransliteratorFactory.GetRegisteredNames().ToList();
        Assert.Contains("spaces", names);
        Assert.Contains("radicals", names);
        Assert.Contains("mathematical-alphanumerics", names);
        Assert.Contains("ideographic-annotations", names);
        Assert.Contains("hyphens", names);
    }
}
