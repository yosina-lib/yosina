// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Transliterators;

/// <summary>
/// Replace various space characters with plain whitespace.
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator("spaces")]
public class SpacesTransliterator : ITransliterator
{
    private static readonly Dictionary<int, int> Mappings = new()
    {
        [0xA0] = 0x20,
        [0x2000] = 0x20,
        [0x2001] = 0x20,
        [0x2002] = 0x20,
        [0x2003] = 0x20,
        [0x2004] = 0x20,
        [0x2005] = 0x20,
        [0x2006] = 0x20,
        [0x2007] = 0x20,
        [0x2008] = 0x20,
        [0x2009] = 0x20,
        [0x200A] = 0x20,
        [0x200B] = 0x20,
        [0x202F] = 0x20,
        [0x205F] = 0x20,
        [0x3000] = 0x20,
        [0x3164] = 0x20,
        [0xFFA0] = 0x20,
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
