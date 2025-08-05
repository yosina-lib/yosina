using System.Collections.Generic;

namespace Yosina.Transliterators;

/// <summary>
/// Replace various space characters with plain whitespace.
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator("spaces")]
public class SpacesTransliterator : ITransliterator
{
    private static readonly Dictionary<int, int> _mappings = new()
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

    public IEnumerable<Char> Transliterate(IEnumerable<Char> input)
    {
        return new SimpleCharEnumerator(input, _mappings);
    }

    private class SimpleCharEnumerator : IEnumerable<Char>
    {
        private readonly IEnumerable<Char> _input;
        private readonly Dictionary<int, int> _mappings;
        private int _offset = 0;
        private bool _disposed = false;

        public SimpleCharEnumerator(IEnumerable<Char> input, Dictionary<int, int> mappings)
        {
            _input = input ?? throw new System.ArgumentNullException(nameof(input));
            _mappings = mappings ?? throw new System.ArgumentNullException(nameof(mappings));
        }

        public int Count => _input.Count;

        public Char Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => Current;

        public bool MoveNext()
        {
            if (_disposed || !_input.MoveNext()) return false;

            var c = _input.Current;
            if (c.IsSentinel)
            {
                Current = c.WithOffset(_offset);
                return true;
            }

            if (c.CodePoint.Size == 1 && _mappings.TryGetValue(c.CodePoint.First, out var mapped))
            {
                Current = new Char(CodePointTuple.Of(mapped), _offset, c);
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

        public System.Collections.Generic.IEnumerator<Char> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }
}