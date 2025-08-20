// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Transliterators;

/// <summary>
/// Transliterator for normalizing various hyphen and dash characters.
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator("hyphens")]
public class HyphensTransliterator : ITransliterator
{
    public static readonly List<Mapping> DefaultPrecedence = new() { Mapping.JISX0208_90 };

    private static readonly Dictionary<Mapping, Dictionary<int, int[]>> Mappings = new()
    {
        [Mapping.ASCII] = new Dictionary<int, int[]>
        {
            [0x2D] = new[] { 0x2D },
            [0x7C] = new[] { 0x7C },
            [0x7E] = new[] { 0x7E },
            [0xA6] = new[] { 0x7C },
            [0x2D7] = new[] { 0x2D },
            [0x2010] = new[] { 0x2D },
            [0x2011] = new[] { 0x2D },
            [0x2012] = new[] { 0x2D },
            [0x2013] = new[] { 0x2D },
            [0x2014] = new[] { 0x2D },
            [0x2015] = new[] { 0x2D },
            [0x2043] = new[] { 0x2D },
            [0x2053] = new[] { 0x7E },
            [0x2212] = new[] { 0x2D },
            [0x223C] = new[] { 0x7E },
            [0x223D] = new[] { 0x7E },
            [0x2500] = new[] { 0x2D },
            [0x2501] = new[] { 0x2D },
            [0x2502] = new[] { 0x7C },
            [0x2796] = new[] { 0x2D },
            [0x29FF] = new[] { 0x2D },
            [0x2E3A] = new[] { 0x2D, 0x2D },
            [0x2E3B] = new[] { 0x2D, 0x2D, 0x2D },
            [0x301C] = new[] { 0x7E },
            [0x30A0] = new[] { 0x3D },
            [0x30FC] = new[] { 0x2D },
            [0xFE31] = new[] { 0x7C },
            [0xFE58] = new[] { 0x2D },
            [0xFE63] = new[] { 0x2D },
            [0xFF0D] = new[] { 0x2D },
            [0xFF5C] = new[] { 0x7C },
            [0xFF5E] = new[] { 0x7E },
            [0xFFE4] = new[] { 0x7C },
            [0xFF70] = new[] { 0x2D },
            [0xFFE8] = new[] { 0x7C },
        },
        [Mapping.JISX0201] = new Dictionary<int, int[]>
        {
            [0x2D] = new[] { 0x2D },
            [0x7C] = new[] { 0x7C },
            [0x7E] = new[] { 0x7E },
            [0xA6] = new[] { 0x7C },
            [0x2D7] = new[] { 0x2D },
            [0x2010] = new[] { 0x2D },
            [0x2011] = new[] { 0x2D },
            [0x2012] = new[] { 0x2D },
            [0x2013] = new[] { 0x2D },
            [0x2014] = new[] { 0x2D },
            [0x2015] = new[] { 0x2D },
            [0x203E] = new[] { 0x7E },
            [0x2043] = new[] { 0x2D },
            [0x2053] = new[] { 0x7E },
            [0x2212] = new[] { 0x2D },
            [0x223C] = new[] { 0x7E },
            [0x223D] = new[] { 0x7E },
            [0x2500] = new[] { 0x2D },
            [0x2501] = new[] { 0x2D },
            [0x2502] = new[] { 0x7C },
            [0x2796] = new[] { 0x2D },
            [0x29FF] = new[] { 0x2D },
            [0x2E3A] = new[] { 0x2D, 0x2D },
            [0x2E3B] = new[] { 0x2D, 0x2D, 0x2D },
            [0x301C] = new[] { 0x7E },
            [0x30A0] = new[] { 0x3D },
            [0x30FB] = new[] { 0xFF65 },
            [0x30FC] = new[] { 0x2D },
            [0xFE31] = new[] { 0x7C },
            [0xFE58] = new[] { 0x2D },
            [0xFE63] = new[] { 0x2D },
            [0xFF0D] = new[] { 0x2D },
            [0xFF5C] = new[] { 0x7C },
            [0xFF5E] = new[] { 0x7E },
            [0xFFE4] = new[] { 0x7C },
            [0xFF70] = new[] { 0xFF70 },
            [0xFFE8] = new[] { 0x7C },
        },
        [Mapping.JISX0208_90] = new Dictionary<int, int[]>
        {
            [0x2D] = new[] { 0x2212 },
            [0x7C] = new[] { 0xFF5C },
            [0x7E] = new[] { 0x301C },
            [0xA2] = new[] { 0xA2 },
            [0xA3] = new[] { 0xA3 },
            [0xA6] = new[] { 0xFF5C },
            [0x2D7] = new[] { 0x2212 },
            [0x2010] = new[] { 0x2010 },
            [0x2011] = new[] { 0x2010 },
            [0x2012] = new[] { 0x2015 },
            [0x2013] = new[] { 0x2015 },
            [0x2014] = new[] { 0x2014 },
            [0x2015] = new[] { 0x2015 },
            [0x2016] = new[] { 0x2016 },
            [0x203E] = new[] { 0xFFE3 },
            [0x2043] = new[] { 0x2010 },
            [0x2053] = new[] { 0x301C },
            [0x2212] = new[] { 0x2212 },
            [0x2225] = new[] { 0x2016 },
            [0x223C] = new[] { 0x301C },
            [0x223D] = new[] { 0x301C },
            [0x2500] = new[] { 0x2015 },
            [0x2501] = new[] { 0x2015 },
            [0x2502] = new[] { 0xFF5C },
            [0x2796] = new[] { 0x2212 },
            [0x29FF] = new[] { 0x2010 },
            [0x2E3A] = new[] { 0x2014, 0x2014 },
            [0x2E3B] = new[] { 0x2014, 0x2014, 0x2014 },
            [0x301C] = new[] { 0x301C },
            [0x30A0] = new[] { 0xFF1D },
            [0x30FB] = new[] { 0x30FB },
            [0x30FC] = new[] { 0x30FC },
            [0xFE31] = new[] { 0xFF5C },
            [0xFE58] = new[] { 0x2010 },
            [0xFE63] = new[] { 0x2010 },
            [0xFF0D] = new[] { 0x2212 },
            [0xFF5C] = new[] { 0xFF5C },
            [0xFF5E] = new[] { 0x301C },
            [0xFFE4] = new[] { 0xFF5C },
            [0xFF70] = new[] { 0x30FC },
            [0xFFE8] = new[] { 0xFF5C },
        },
        [Mapping.JISX0208_90_WINDOWS] = new Dictionary<int, int[]>
        {
            [0x2D] = new[] { 0x2212 },
            [0x7C] = new[] { 0xFF5C },
            [0x7E] = new[] { 0xFF5E },
            [0xA2] = new[] { 0xFFE0 },
            [0xA3] = new[] { 0xFFE1 },
            [0xA6] = new[] { 0xFF5C },
            [0x2D7] = new[] { 0xFF0D },
            [0x2010] = new[] { 0x2010 },
            [0x2011] = new[] { 0x2010 },
            [0x2012] = new[] { 0x2015 },
            [0x2013] = new[] { 0x2015 },
            [0x2014] = new[] { 0x2015 },
            [0x2015] = new[] { 0x2015 },
            [0x2016] = new[] { 0x2225 },
            [0x203E] = new[] { 0xFFE3 },
            [0x2043] = new[] { 0x2010 },
            [0x2053] = new[] { 0x301C },
            [0x2212] = new[] { 0xFF0D },
            [0x2225] = new[] { 0x2225 },
            [0x223C] = new[] { 0xFF5E },
            [0x223D] = new[] { 0xFF5E },
            [0x2500] = new[] { 0x2015 },
            [0x2501] = new[] { 0x2015 },
            [0x2502] = new[] { 0xFF5C },
            [0x2796] = new[] { 0xFF0D },
            [0x29FF] = new[] { 0xFF0D },
            [0x2E3A] = new[] { 0x2015, 0x2015 },
            [0x2E3B] = new[] { 0x2015, 0x2015, 0x2015 },
            [0x301C] = new[] { 0xFF5E },
            [0x30A0] = new[] { 0xFF1D },
            [0x30FB] = new[] { 0x30FB },
            [0x30FC] = new[] { 0x30FC },
            [0xFE31] = new[] { 0xFF5C },
            [0xFE58] = new[] { 0x2010 },
            [0xFE63] = new[] { 0x2010 },
            [0xFF0D] = new[] { 0xFF0D },
            [0xFF5C] = new[] { 0xFF5C },
            [0xFF5E] = new[] { 0xFF5E },
            [0xFFE4] = new[] { 0xFFE4 },
            [0xFF70] = new[] { 0x30FC },
            [0xFFE8] = new[] { 0xFF5C },
        },
        [Mapping.JISX0208_VERBATIM] = new Dictionary<int, int[]>
        {
            [0xA2] = new[] { 0xA2 },
            [0xA3] = new[] { 0xA3 },
            [0xA6] = new[] { 0xA6 },
            [0x2010] = new[] { 0x2010 },
            [0x2013] = new[] { 0x2013 },
            [0x2014] = new[] { 0x2014 },
            [0x2015] = new[] { 0x2015 },
            [0x2016] = new[] { 0x2016 },
            [0x203E] = new[] { 0x203D },
            [0x2212] = new[] { 0x2212 },
            [0x2225] = new[] { 0x2225 },
            [0x2500] = new[] { 0x2500 },
            [0x2501] = new[] { 0x2501 },
            [0x2502] = new[] { 0x2502 },
            [0x301C] = new[] { 0x301C },
            [0x30A0] = new[] { 0x30A0 },
            [0x30FB] = new[] { 0x30FB },
            [0x30FC] = new[] { 0x30FC },
            [0xFF5C] = new[] { 0xFF5C },
            [0xFFE4] = new[] { 0xFFE4 },
        },
    };

    private readonly Options options;

    public HyphensTransliterator()
        : this(new Options())
    {
    }

    public HyphensTransliterator(Options options)
    {
        this.options = options;
    }

#pragma warning disable CA1707 // Identifiers should not contain underscores
    public enum Mapping
    {
        ASCII,
        JISX0201,
        JISX0208_90,
        JISX0208_90_WINDOWS,
        JISX0208_VERBATIM,
    }
#pragma warning restore CA1707 // Identifiers should not contain underscores

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        var precedence = this.options.Precedence ?? DefaultPrecedence;
        var effectiveMappings = new Dictionary<int, int[]>();

        // Build effective mappings based on precedence
        foreach (var record in Mappings)
        {
            foreach (var mapping in record.Value)
            {
                if (!effectiveMappings.ContainsKey(mapping.Key))
                {
                    effectiveMappings[mapping.Key] = mapping.Value;
                }
            }
        }

        // Apply precedence order
        foreach (var mappingType in precedence.Reverse())
        {
            if (Mappings.TryGetValue(mappingType, out var mappings))
            {
                foreach (var mapping in mappings)
                {
                    effectiveMappings[mapping.Key] = mapping.Value;
                }
            }
        }

        return new HyphensCharIterator(input.GetEnumerator(), effectiveMappings);
    }

    public class Options
    {
        public IList<Mapping>? Precedence { get; set; }
    }

    private class HyphensCharIterator : IEnumerator<Character>, IEnumerable<Character>
    {
        private readonly IEnumerator<Character> input;
        private readonly Dictionary<int, int[]> mappings;
        private readonly Queue<Character> buffer = new();
        private int offset;
        private bool disposed;

        public HyphensCharIterator(IEnumerator<Character> input, Dictionary<int, int[]> mappings)
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

            // If we have buffered characters from a multi-character replacement, return the next one
            if (this.buffer.Count > 0)
            {
                this.Current = this.buffer.Dequeue();
                return true;
            }

            // Move to next input character
            if (!this.input.MoveNext())
            {
                return false;
            }

            var c = this.input.Current;
            if (c.IsSentinel)
            {
                this.Current = c.WithOffset(this.offset);
                this.offset += this.Current.CharCount;
                return true;
            }

            // Check for mapping
            if (c.CodePoint.Size() == 1 && this.mappings.TryGetValue(c.CodePoint.First, out var mapped))
            {
                if (mapped.Length == 1)
                {
                    // Single character replacement
                    this.Current = new Character((mapped[0], -1), this.offset, c);
                }
                else
                {
                    // Multi-character replacement - create individual Char objects
                    this.Current = new Character((mapped[0], -1), this.offset, c);
                    var currentOffset = this.offset + this.Current.CharCount;

                    // Buffer the remaining characters
                    for (int i = 1; i < mapped.Length; i++)
                    {
                        var bufferedChar = new Character((mapped[i], -1), currentOffset, c);
                        this.buffer.Enqueue(bufferedChar);
                        currentOffset += bufferedChar.CharCount;
                    }
                }
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
            this.buffer.Clear();
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

        public IEnumerator<Character> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }
}
