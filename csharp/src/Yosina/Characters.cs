// Copyright (c) Yosina. All rights reserved.

using System.Text;

namespace Yosina;

public static class Characters
{
    public static IList<Character> CharacterList(string text)
    {
        var result = new List<Character>();
        int prevChar = -1;
        int offset = 0;
        var codePoints = text.EnumerateRunes().Select(r => r.Value).ToArray();

        for (int i = 0; i < codePoints.Length; i++)
        {
            var codePoint = codePoints[i];

            if (prevChar >= 0)
            {
                if (IsVariationSelector(codePoint))
                {
                    var ct = (prevChar, codePoint);
                    result.Add(new Character(ct, offset));
                    offset += ct.CharCount();
                    prevChar = -1;
                }
                else
                {
                    var ct = (prevChar, -1);
                    result.Add(new Character(ct, offset));
                    offset += ct.CharCount();
                    prevChar = codePoint;
                }
            }
            else
            {
                prevChar = codePoint;
            }
        }

        if (prevChar >= 0)
        {
            var ct = (prevChar, -1);
            result.Add(new Character(ct, offset));
            offset += ct.CharCount();
        }

        result.Add(new Character((-1, -1), offset));
        return result;
    }

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

    public static string AsString(this IEnumerable<Character> chars)
    {
        var result = new StringBuilder();
        foreach (var ch in chars)
        {
            if (ch.IsSentinel)
            {
                break;
            }

            ch.CodePoint.AppendChars(result);
        }

        return result.ToString();
    }

    private static bool IsVariationSelector(int codePoint)
    {
        return (codePoint >= 0xFE00 && codePoint <= 0xFE0F) ||
               (codePoint >= 0xE0100 && codePoint <= 0xE01EF);
    }
}
