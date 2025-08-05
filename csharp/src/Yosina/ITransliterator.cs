// Copyright (c) Yosina. All rights reserved.

namespace Yosina;

public interface ITransliterator
{
    IEnumerable<Character> Transliterate(IEnumerable<Character> input);
}
