// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Transliterators;

/// <summary>
/// Replaces small hiragana/katakana with their ordinary-sized equivalents.
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator("small-hirakatas")]
public class SmallHirakatasTransliterator : ITransliterator
{
    private static readonly Dictionary<int, int> Mappings = new()
    {
        [0x3041] = 0x3042,
        [0x3043] = 0x3044,
        [0x3045] = 0x3046,
        [0x3047] = 0x3048,
        [0x3049] = 0x304A,
        [0x3063] = 0x3064,
        [0x3083] = 0x3084,
        [0x3085] = 0x3086,
        [0x3087] = 0x3088,
        [0x308E] = 0x308F,
        [0x3095] = 0x304B,
        [0x3096] = 0x3051,
        [0x30A1] = 0x30A2,
        [0x30A3] = 0x30A4,
        [0x30A5] = 0x30A6,
        [0x30A7] = 0x30A8,
        [0x30A9] = 0x30AA,
        [0x30C3] = 0x30C4,
        [0x30E3] = 0x30E4,
        [0x30E5] = 0x30E6,
        [0x30E7] = 0x30E8,
        [0x30EE] = 0x30EF,
        [0x30F5] = 0x30AB,
        [0x30F6] = 0x30B1,
        [0x31F0] = 0x30AF,
        [0x31F1] = 0x30B7,
        [0x31F2] = 0x30B9,
        [0x31F3] = 0x30C8,
        [0x31F4] = 0x30CC,
        [0x31F5] = 0x30CF,
        [0x31F6] = 0x30D2,
        [0x31F7] = 0x30D5,
        [0x31F8] = 0x30D8,
        [0x31F9] = 0x30DB,
        [0x31FA] = 0x30E0,
        [0x31FB] = 0x30E9,
        [0x31FC] = 0x30EA,
        [0x31FD] = 0x30EB,
        [0x31FE] = 0x30EC,
        [0x31FF] = 0x30ED,
        [0xFF67] = 0xFF71,
        [0xFF68] = 0xFF72,
        [0xFF69] = 0xFF73,
        [0xFF6A] = 0xFF74,
        [0xFF6B] = 0xFF75,
        [0xFF6C] = 0xFF94,
        [0xFF6D] = 0xFF95,
        [0xFF6E] = 0xFF96,
        [0xFF6F] = 0xFF82,
        [0x1B132] = 0x3053,
        [0x1B150] = 0x3090,
        [0x1B151] = 0x3091,
        [0x1B152] = 0x3092,
        [0x1B155] = 0x30B3,
        [0x1B164] = 0x30F0,
        [0x1B165] = 0x30F1,
        [0x1B166] = 0x30F2,
        [0x1B167] = 0x30F3,
    };

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        return new SimpleCharEnumerator(input.GetEnumerator(), Mappings);
    }

    private class SimpleCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {
        private readonly IEnumerator<Character> input;
        private readonly Dictionary<int, int> mappings;
        private int offset;
        private bool disposed;

        public SimpleCharEnumerator(IEnumerator<Character> input, Dictionary<int, int> mappings)
        {
            this.input = input;
            this.mappings = mappings;
        }

        public Character Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => this.Current;

        public bool MoveNext()
        {
            if (this.disposed || !this.input.MoveNext())
            {
                return false;
            }

            var c = this.input.Current;
            if (c.IsSentinel)
            {
                this.Current = c.WithOffset(this.offset);
                return true;
            }

            if (c.CodePoint.Size() == 1 && this.mappings.TryGetValue(c.CodePoint.First, out var mapped))
            {
                this.Current = new Character((mapped, -1), this.offset, c);
            }
            else
            {
                this.Current = c.WithOffset(this.offset);
            }

            this.offset += this.Current.CharCount;
            return true;
        }

        public void Reset()
        {
            this.input.Reset();
            this.offset = 0;
        }

        public void Dispose()
        {
            if (!this.disposed)
            {
                this.input.Dispose();
                this.disposed = true;
            }
        }

        public System.Collections.Generic.IEnumerator<Character> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }
}
