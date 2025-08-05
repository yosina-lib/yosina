// Copyright (c) Yosina. All rights reserved.

namespace Yosina;

public class ChainedTransliterator : ITransliterator
{
    private readonly IReadOnlyList<ITransliterator> transliterators;

    public ChainedTransliterator(IEnumerable<ITransliterator> transliterators)
    {
        this.transliterators = transliterators.ToList();
    }

    public ChainedTransliterator(params ITransliterator[] transliterators)
    {
        this.transliterators = transliterators.ToList();
    }

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        var current = input;
        foreach (var transliterator in this.transliterators)
        {
            current = transliterator.Transliterate(current);
        }

        return current;
    }
}
