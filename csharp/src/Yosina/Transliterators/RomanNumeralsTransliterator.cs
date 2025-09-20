// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Transliterators;

/// <summary>
/// Replace roman numeral characters with their ASCII letter equivalents.
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator("roman-numerals")]
public class RomanNumeralsTransliterator : ITransliterator
{
    private static readonly Dictionary<int, int[]> Mappings = new()
    {
        [0x2160] = new int[] { 0x49 },
        [0x2161] = new int[] { 0x49, 0x49 },
        [0x2162] = new int[] { 0x49, 0x49, 0x49 },
        [0x2163] = new int[] { 0x49, 0x56 },
        [0x2164] = new int[] { 0x56 },
        [0x2165] = new int[] { 0x56, 0x49 },
        [0x2166] = new int[] { 0x56, 0x49, 0x49 },
        [0x2167] = new int[] { 0x56, 0x49, 0x49, 0x49 },
        [0x2168] = new int[] { 0x49, 0x58 },
        [0x2169] = new int[] { 0x58 },
        [0x216A] = new int[] { 0x58, 0x49 },
        [0x216B] = new int[] { 0x58, 0x49, 0x49 },
        [0x216C] = new int[] { 0x4C },
        [0x216D] = new int[] { 0x43 },
        [0x216E] = new int[] { 0x44 },
        [0x216F] = new int[] { 0x4D },
        [0x2170] = new int[] { 0x69 },
        [0x2171] = new int[] { 0x69, 0x69 },
        [0x2172] = new int[] { 0x69, 0x69, 0x69 },
        [0x2173] = new int[] { 0x69, 0x76 },
        [0x2174] = new int[] { 0x76 },
        [0x2175] = new int[] { 0x76, 0x69 },
        [0x2176] = new int[] { 0x76, 0x69, 0x69 },
        [0x2177] = new int[] { 0x76, 0x69, 0x69, 0x69 },
        [0x2178] = new int[] { 0x69, 0x78 },
        [0x2179] = new int[] { 0x78 },
        [0x217A] = new int[] { 0x78, 0x69 },
        [0x217B] = new int[] { 0x78, 0x69, 0x69 },
        [0x217C] = new int[] { 0x6C },
        [0x217D] = new int[] { 0x63 },
        [0x217E] = new int[] { 0x64 },
        [0x217F] = new int[] { 0x6D },
    };

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        return new CombinedCharEnumerator(input.GetEnumerator(), Mappings);
    }

    private class CombinedCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {
        private readonly IEnumerator<Character> input;
        private readonly Dictionary<int, int[]> mappings;
        private int offset;
        private bool disposed;
        private readonly Queue<Character> queue = new();

        public CombinedCharEnumerator(IEnumerator<Character> input, Dictionary<int, int[]> mappings)
        {
            this.input = input;
            this.mappings = mappings;
        }

        public Character Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => this.Current;

        public bool MoveNext()
        {
            if (this.disposed)
            {
                return false;
            }

            // If we have queued characters from a previous expansion, return them first
            if (this.queue.Count > 0)
            {
                this.Current = this.queue.Dequeue();
                return true;
            }

            if (!this.input.MoveNext())
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
                // Create characters for each mapped code point
                var chars = mapped.Select((codePoint, index) =>
                    new Character((codePoint, -1), this.offset + index, c)).ToArray();

                if (chars.Length > 0)
                {
                    this.Current = chars[0];
                    this.offset += chars[0].CharCount;

                    // Queue the remaining characters
                    for (int i = 1; i < chars.Length; i++)
                    {
                        this.queue.Enqueue(chars[i].WithOffset(this.offset));
                        this.offset += chars[i].CharCount;
                    }
                }
                else
                {
                    this.Current = c.WithOffset(this.offset);
                    this.offset += this.Current.CharCount;
                }
            }
            else
            {
                this.Current = c.WithOffset(this.offset);
                this.offset += this.Current.CharCount;
            }

            return true;
        }

        public void Reset()
        {
            this.input.Reset();
            this.offset = 0;
            this.queue.Clear();
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
