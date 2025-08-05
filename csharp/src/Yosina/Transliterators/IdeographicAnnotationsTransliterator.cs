// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Transliterators;

/// <summary>
/// Replace ideographic annotation marks used in traditional translation.
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator("ideographic-annotations")]
public class IdeographicAnnotationsTransliterator : ITransliterator
{
    private static readonly Dictionary<int, int> Mappings = new()
    {
        [0x3192] = 0x4E00,
        [0x3193] = 0x4E8C,
        [0x3194] = 0x4E09,
        [0x3195] = 0x56DB,
        [0x3196] = 0x4E0A,
        [0x3197] = 0x4E2D,
        [0x3198] = 0x4E0B,
        [0x3199] = 0x7532,
        [0x319A] = 0x4E59,
        [0x319B] = 0x4E19,
        [0x319C] = 0x4E01,
        [0x319D] = 0x5929,
        [0x319E] = 0x5730,
        [0x319F] = 0x4EBA,
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
