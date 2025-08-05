using System;
using System.Collections.Generic;
using System.Linq;

namespace Yosina.Transliterators;

/// <summary>
/// Transliterator for normalizing various hyphen and dash characters.
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator("hyphens")]
public class HyphensTransliterator : ITransliterator
{
    public enum Mapping
    {
        ASCII,
        JISX0201,
        JISX0208_90,
        JISX0208_90_WINDOWS,
        JISX0208_VERBATIM
    }

    public static readonly Mapping[] DefaultPrecedence = { Mapping.JISX0208_90 };

    private static readonly Dictionary<Mapping, Dictionary<int, int[]>> _mappings = new()
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

    public class Options
    {
        public Mapping[]? Precedence { get; set; }
    }

    private readonly Options _options;

    public HyphensTransliterator() : this(new Options()) { }

    public HyphensTransliterator(Options options)
    {
        _options = options ?? throw new ArgumentNullException(nameof(options));
    }

    public IEnumerable<Char> Transliterate(IEnumerable<Char> input)
    {
        var precedence = _options.Precedence ?? DefaultPrecedence;
        var effectiveMappings = new Dictionary<int, int[]>();

        // Build effective mappings based on precedence
        foreach (var record in _mappings)
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
            if (_mappings.TryGetValue(mappingType, out var mappings))
            {
                foreach (var mapping in mappings)
                {
                    effectiveMappings[mapping.Key] = mapping.Value;
                }
            }
        }

        return new HyphensCharEnumerator(input, effectiveMappings);
    }

    private class HyphensCharEnumerator : IEnumerable<Char>
    {
        private readonly IEnumerable<Char> _input;
        private readonly Dictionary<int, int[]> _mappings;
        private readonly Queue<Char> _buffer = new();
        private int _offset = 0;
        private bool _disposed = false;

        public HyphensCharEnumerator(IEnumerable<Char> input, Dictionary<int, int[]> mappings)
        {
            _input = input ?? throw new ArgumentNullException(nameof(input));
            _mappings = mappings ?? throw new ArgumentNullException(nameof(mappings));
        }

        public int Count => _input.Count;

        public Char Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => Current;

        public bool MoveNext()
        {
            if (_disposed) return false;

            // If we have buffered characters from a multi-character replacement, return the next one
            if (_buffer.Count > 0)
            {
                Current = _buffer.Dequeue();
                return true;
            }

            // Move to next input character
            if (!_input.MoveNext()) return false;

            var c = _input.Current;
            if (c.IsSentinel)
            {
                Current = c.WithOffset(_offset);
                _offset += Current.CharCount;
                return true;
            }

            // Check for mapping
            if (c.CodePoint.Size == 1 && _mappings.TryGetValue(c.CodePoint.First, out var mapped))
            {
                if (mapped.Length == 1)
                {
                    // Single character replacement
                    Current = new Char(CodePointTuple.Of(mapped[0]), _offset, c);
                }
                else
                {
                    // Multi-character replacement - create individual Char objects
                    Current = new Char(CodePointTuple.Of(mapped[0]), _offset, c);
                    var currentOffset = _offset + Current.CharCount;
                    
                    // Buffer the remaining characters
                    for (int i = 1; i < mapped.Length; i++)
                    {
                        var bufferedChar = new Char(CodePointTuple.Of(mapped[i]), currentOffset, c);
                        _buffer.Enqueue(bufferedChar);
                        currentOffset += bufferedChar.CharCount;
                    }
                }
            }
            else
            {
                Current = c.WithOffset(_offset);
            }

            _offset += Current.CharCount;
            return true;
        }

        public void Reset()
        {
            _input.Reset();
            _buffer.Clear();
            _offset = 0;
        }

        public void Dispose()
        {
            if (!_disposed)
            {
                _input?.Dispose();
                _disposed = true;
            }
        }

        public IEnumerator<Char> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }
}