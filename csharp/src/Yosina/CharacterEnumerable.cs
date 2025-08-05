// Copyright (c) Yosina. All rights reserved.

namespace Yosina;

public static class CharacterEnumerable
{
    public static IEnumerable<int> CodePoints(this IEnumerable<Character> chars)
    {
        foreach (var ch in chars)
        {
            if (ch.IsSentinel)
            {
                yield break;
            }

            foreach (var cp in ch.CodePoint.ToCodePoints())
            {
                yield return cp;
            }
        }
    }
}
