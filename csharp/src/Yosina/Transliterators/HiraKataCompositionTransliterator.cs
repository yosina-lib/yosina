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
    private static readonly Dictionary<int, (int Voiced, int SemiVoiced)> CompositionTable;

    // Static entries defining the composition rules
    private static readonly int[] Entries =
    {
        0x304b, 0x304c, 0,        // か -> が
        0x304d, 0x304e, 0,        // き -> ぎ
        0x304f, 0x3050, 0,        // く -> ぐ
        0x3051, 0x3052, 0,        // け -> げ
        0x3053, 0x3054, 0,        // こ -> ご
        0x3055, 0x3056, 0,        // さ -> ざ
        0x3057, 0x3058, 0,        // し -> じ
        0x3059, 0x305a, 0,        // す -> ず
        0x305b, 0x305c, 0,        // せ -> ぜ
        0x305d, 0x305e, 0,        // そ -> ぞ
        0x305f, 0x3060, 0,        // た -> だ
        0x3061, 0x3062, 0,        // ち -> ぢ
        0x3064, 0x3065, 0,        // つ -> づ
        0x3066, 0x3067, 0,        // て -> で
        0x3068, 0x3069, 0,        // と -> ど
        0x306f, 0x3070, 0x3071,   // は -> ば, ぱ
        0x3072, 0x3073, 0x3074,   // ひ -> び, ぴ
        0x3075, 0x3076, 0x3077,   // ふ -> ぶ, ぷ
        0x3078, 0x3079, 0x307a,   // へ -> べ, ぺ
        0x307b, 0x307c, 0x307d,   // ほ -> ぼ, ぽ
        0x3046, 0x3094, 0,        // う -> ゔ
        0x309d, 0x309e, 0,        // ゝ -> ゞ
        0x30ab, 0x30ac, 0,        // カ -> ガ
        0x30ad, 0x30ae, 0,        // キ -> ギ
        0x30af, 0x30b0, 0,        // ク -> グ
        0x30b1, 0x30b2, 0,        // ケ -> ゲ
        0x30b3, 0x30b4, 0,        // コ -> ゴ
        0x30b5, 0x30b6, 0,        // サ -> ザ
        0x30b7, 0x30b8, 0,        // シ -> ジ
        0x30b9, 0x30ba, 0,        // ス -> ズ
        0x30bb, 0x30bc, 0,        // セ -> ゼ
        0x30bd, 0x30be, 0,        // ソ -> ゾ
        0x30bf, 0x30c0, 0,        // タ -> ダ
        0x30c1, 0x30c2, 0,        // チ -> ヂ
        0x30c4, 0x30c5, 0,        // ツ -> ヅ
        0x30c6, 0x30c7, 0,        // テ -> デ
        0x30c8, 0x30c9, 0,        // ト -> ド
        0x30cf, 0x30d0, 0x30d1,   // ハ -> バ, パ
        0x30d2, 0x30d3, 0x30d4,   // ヒ -> ビ, ピ
        0x30d5, 0x30d6, 0x30d7,   // フ -> ブ, プ
        0x30d8, 0x30d9, 0x30da,   // ヘ -> ベ, ペ
        0x30db, 0x30dc, 0x30dd,   // ホ -> ボ, ポ
        0x30a6, 0x30f4, 0,        // ウ -> ヴ
        0x30ef, 0x30f7, 0,        // ワ -> ヷ
        0x30f0, 0x30f8, 0,        // ヰ -> ヸ
        0x30f1, 0x30f9, 0,        // ヱ -> ヹ
        0x30f2, 0x30fa, 0,        // ヲ -> ヺ
    };

    private readonly Options options;

    static HiraKataCompositionTransliterator()
    {
        CompositionTable = new Dictionary<int, (int Voiced, int SemiVoiced)>();

        for (int i = 0; i < Entries.Length; i += 3)
        {
            int baseChar = Entries[i];
            int voiced = Entries[i + 1];
            int semiVoiced = Entries[i + 2];

            CompositionTable[baseChar] = (voiced, semiVoiced);
        }
    }

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
