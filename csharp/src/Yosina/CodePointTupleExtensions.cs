// Copyright (c) Yosina. All rights reserved.

using System.Runtime.InteropServices;
using System.Text;
using CodePointTuple = (int First, int Second);

namespace Yosina;

[StructLayout(LayoutKind.Auto)]
public static class CodePointTupleExtensions
{
    public const int INVALID = -1;

    public static bool IsEmpty(this CodePointTuple tuple) => tuple.First == INVALID && tuple.Second == INVALID;

    public static int Size(this CodePointTuple tuple) => tuple.First == INVALID ? 0 : tuple.Second == INVALID ? 1 : 2;

    public static int CharCount(this CodePointTuple tuple)
    {
        if (tuple.First == INVALID)
        {
            return 0;
        }

        if (tuple.Second == INVALID)
        {
            return tuple.First >= 0x10000 ? 2 : 1;
        }

        return (tuple.First >= 0x10000 ? 2 : 1) + (tuple.Second >= 0x10000 ? 2 : 1);
    }

    public static int[] ToCodePoints(this CodePointTuple tuple)
    {
        if (tuple.First == INVALID)
        {
            return Array.Empty<int>();
        }

        if (tuple.Second == INVALID)
        {
            return new[] { tuple.First };
        }

        return new[] { tuple.First, tuple.Second };
    }

    public static int ToCodePoints(this CodePointTuple tuple, int[] codePoints, int offset)
    {
        if (tuple.First != INVALID)
        {
            codePoints[offset++] = tuple.First;
        }

        if (tuple.Second != INVALID)
        {
            codePoints[offset++] = tuple.Second;
        }

        return offset;
    }

    public static void AppendCodePoints(this CodePointTuple tuple, ICollection<int> dest)
    {
        if (tuple.First != INVALID)
        {
            dest.Add(tuple.First);
        }

        if (tuple.Second != INVALID)
        {
            dest.Add(tuple.Second);
        }
    }

    public static void AppendChars(this CodePointTuple tuple, ICollection<char> dest)
    {
        if (tuple.First != INVALID)
        {
            AppendCodePoint(dest, tuple.First);
        }

        if (tuple.Second != INVALID)
        {
            AppendCodePoint(dest, tuple.Second);
        }
    }

    public static void AppendChars(this CodePointTuple tuple, StringBuilder dest)
    {
        if (tuple.First != INVALID)
        {
            AppendCodePoint(dest, tuple.First);
        }

        if (tuple.Second != INVALID)
        {
            AppendCodePoint(dest, tuple.Second);
        }
    }

    public static string AsString(this CodePointTuple tuple)
    {
        if (tuple.First == INVALID && tuple.Second == INVALID)
        {
            return string.Empty;
        }

        var codePoints = tuple.ToCodePoints();
        return string.Create(
            codePoints.Sum(cp => cp >= 0x10000 ? 2 : 1),
            codePoints,
            (span, cps) =>
            {
                int index = 0;
                foreach (var cp in cps)
                {
                    if (cp < 0x10000)
                    {
                        span[index++] = (char)cp;
                    }
                    else
                    {
                        var surrogatePair = char.ConvertFromUtf32(cp);
                        span[index++] = (char)(0xd800 + ((cp - 0x10000) >> 10));
                        span[index++] = (char)(0xdc00 + ((cp - 0x10000) & 0x3ff));
                    }
                }
            });
    }

    private static void AppendCodePoint(ICollection<char> dest, int cp)
    {
        if (cp >= 0x10000)
        {
            dest.Add((char)(0xd800 + ((cp - 0x10000) >> 10)));
            dest.Add((char)(0xdc00 + ((cp - 0x10000) & 0x3ff)));
        }
        else
        {
            dest.Add((char)cp);
        }
    }

    private static void AppendCodePoint(StringBuilder dest, int cp)
    {
        if (cp >= 0x10000)
        {
            dest.Append((char)(0xd800 + ((cp - 0x10000) >> 10)));
            dest.Append((char)(0xdc00 + ((cp - 0x10000) & 0x3ff)));
        }
        else
        {
            dest.Append((char)cp);
        }
    }
}
