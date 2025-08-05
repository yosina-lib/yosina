// Copyright (c) Yosina. All rights reserved.

using CodePointTuple = (int First, int Second);

namespace Yosina.Transliterators;

/// <summary>
/// Transliterator for combining hiragana and katakana with voiced/semi-voiced marks.
/// </summary>
[RegisteredTransliterator("hira-kata-composition")]
public class HiraKataCompositionTransliterator : ITransliterator
{
    private const int VOICED = 1;
    private const int SEMIVOICED = 2;

    // Composition table packed into a dictionary for efficient lookup
    private static readonly Dictionary<int, (int Voiced, int SemiVoiced)> CompositionTable = HiraKataTable.GenerateCompositionEntries();

    private readonly Options options;

    public HiraKataCompositionTransliterator()
        : this(new Options())
    {
    }

    public HiraKataCompositionTransliterator(Options options)
    {
        this.options = options ?? throw new ArgumentNullException(nameof(options));
    }

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        return new HiraKataCompositionCharEnumerator(input.GetEnumerator(), this.options);
    }

    public class Options
    {
        public bool ComposeNonCombiningMarks { get; set; }
    }

    private class HiraKataCompositionCharEnumerator : IEnumerator<Character>, IEnumerable<Character>
    {
        private readonly IEnumerator<Character> input;
        private readonly Options options;
        private Character? pending;
        private int offset;
        private bool disposed;

        public HiraKataCompositionCharEnumerator(IEnumerator<Character> input, Options options)
        {
            this.input = input;
            this.options = options;
        }

        public Character Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => this.Current;

#pragma warning disable MA0051 // Method is too long
        public bool MoveNext()
        {
            if (this.disposed)
            {
                return false;
            }

            Character? c;
            if (this.pending != null)
            {
                c = this.pending;
                this.pending = null;
            }
            else
            {
                if (!this.input.MoveNext())
                {
                    return false;
                }

                c = this.input.Current;
            }

            if (c.IsSentinel)
            {
                this.Current = c.WithOffset(this.offset);
                return true;
            }

            // Check if current character can be the first part of a composition
            var (voiced, semiVoiced) = this.CanBeComposed(c.CodePoint);
            if (voiced != 0 || semiVoiced != 0)
            {
                if (this.input.MoveNext())
                {
                    var nc = this.input.Current;
                    int markType = this.IsSoundMark(nc.CodePoint);

                    int composed = markType switch
                    {
                        VOICED => voiced,
                        SEMIVOICED => semiVoiced,
                        _ => 0,
                    };

                    if (composed != 0)
                    {
                        // Successful composition
                        this.Current = new Character((composed, -1), this.offset, c);
                        this.offset += this.Current.CharCount;
                        return true;
                    }

                    // No composition found, set next as pending
                    this.pending = nc;
                }
            }

            // Return the original character
            this.Current = c.WithOffset(this.offset);
            this.offset += this.Current.CharCount;
            return true;
        }
#pragma warning restore MA0051 // Method is too long

        public void Reset()
        {
            this.input.Reset();
            this.pending = null;
            this.offset = 0;
        }

        public void Dispose()
        {
            if (!this.disposed)
            {
                this.input?.Dispose();
                this.disposed = true;
            }
        }

        public IEnumerator<Character> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;

        private (int Voiced, int SemiVoiced) CanBeComposed(CodePointTuple codePoint)
        {
            if (codePoint.Size() != 1)
            {
                return (0, 0);
            }

            int cp = codePoint.First;
            return CompositionTable.TryGetValue(cp, out var composition)
                ? composition
                : (0, 0);
        }

        private int IsSoundMark(CodePointTuple codePoint)
        {
            if (codePoint.Size() != 1)
            {
                return 0;
            }

            int cp = codePoint.First;
            return cp switch
            {
                0x3099 => VOICED,     // U+3099 (combining voiced sound mark)
                0x309a => SEMIVOICED, // U+309A (combining semi-voiced sound mark)
                0x309b => this.options.ComposeNonCombiningMarks ? VOICED : 0,     // U+309B (non-combining voiced sound mark)
                0x309c => this.options.ComposeNonCombiningMarks ? SEMIVOICED : 0, // U+309C (non-combining semi-voiced sound mark)
                _ => 0,
            };
        }
    }
}
