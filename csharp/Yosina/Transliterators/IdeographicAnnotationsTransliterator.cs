using System.Collections.Generic;

namespace Yosina.Transliterators;

/// <summary>
/// Replace ideographic annotation marks used in traditional translation.
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator("ideographic-annotations")]
public class IdeographicAnnotationsTransliterator : ITransliterator
{
    private static readonly Dictionary<int, int> _mappings = new()
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