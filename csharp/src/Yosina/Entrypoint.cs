// Copyright (c) Yosina. All rights reserved.

namespace Yosina;

public static class Entrypoint
{
    public static Func<string, string> MakeTransliterator(params TransliteratorConfig[] configs)
    {
        var transliterators = new List<ITransliterator>();

        foreach (var config in configs)
        {
            var transliterator = TransliteratorFactory.Create(config.Name, config.Options);
            transliterators.Add(transliterator);
        }

        var chainedTransliterator = new ChainedTransliterator(transliterators);

        return input =>
        {
            var chars = Characters.CharacterList(input);
            var result = chainedTransliterator.Transliterate(chars);
            return result.AsString();
        };
    }

    /// <summary>
    /// Creates a transliterator function from a TransliterationRecipe.
    /// </summary>
    /// <param name="recipe">The recipe to build the transliterator from.</param>
    /// <returns>A function that can transliterate text according to the recipe.</returns>
    public static Func<string, string> MakeTransliterator(TransliterationRecipe recipe)
    {
        var configs = recipe.BuildTransliteratorConfigs();
        return MakeTransliterator(configs.ToArray());
    }
}

public record TransliteratorConfig(string Name, object? Options = null);
