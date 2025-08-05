// Copyright (c) Yosina. All rights reserved.

using System.Text.Json.Serialization;
using CodePointTuple = (int First, int Second);

namespace Yosina.Transliterators;

/// <summary>
/// Transliterator for handling Japanese prolonged sound marks.
/// Converts hyphen-like characters to prolonged sound marks when appropriate.
/// </summary>
[RegisteredTransliterator("prolonged-sound-marks")]
public class ProlongedSoundMarksTransliterator : ITransliterator
{
    private static readonly Dictionary<int, CharType> SpecialChars = new()
    {
        { 0xff70, CharType.Katakana | CharType.ProlongedSoundMark | CharType.Halfwidth },
        { 0x30fc, CharType.Either | CharType.ProlongedSoundMark },
        { 0x3063, CharType.Hiragana | CharType.Sokuon },
        { 0x3093, CharType.Hiragana | CharType.Hatsuon },
        { 0x30c3, CharType.Katakana | CharType.Sokuon },
        { 0x30f3, CharType.Katakana | CharType.Hatsuon },
        { 0xff6f, CharType.Katakana | CharType.Sokuon | CharType.Halfwidth },
        { 0xff9d, CharType.Katakana | CharType.Hatsuon | CharType.Halfwidth },
    };

    private static readonly HashSet<int> HyphenLikeChars = new()
    {
        0x002d, // HYPHEN-MINUS
        0x2010, // HYPHEN
        0x2014, // EM DASH
        0x2015, // HORIZONTAL BAR
        0x2212, // MINUS SIGN
        0xff0d, // FULLWIDTH HYPHEN-MINUS
        0xff70, // HALFWIDTH KATAKANA-HIRAGANA PROLONGED SOUND MARK
        0x30fc, // KATAKANA-HIRAGANA PROLONGED SOUND MARK
    };

    [Flags]
    private enum CharType
    {
        Other = 0x00,
        Hiragana = 0x20,
        Katakana = 0x40,
        Alphabet = 0x60,
        Digit = 0x80,
        Either = 0xa0,

        Halfwidth = 1 << 0,
        VowelEnded = 1 << 1,
        Hatsuon = 1 << 2,
        Sokuon = 1 << 3,
        ProlongedSoundMark = 1 << 4,
    }

    private readonly Options options;

    public ProlongedSoundMarksTransliterator()
        : this(new Options())
    {
    }

    public ProlongedSoundMarksTransliterator(Options options)
    {
        this.options = options ?? throw new ArgumentNullException(nameof(options));
    }

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        return new ProlongedSoundMarksCharEnumerator(input.GetEnumerator(), this.options);
    }

    private static CharType GetCharType(int codePoint)
    {
        if (codePoint >= '0' && codePoint <= '9')
        {
            return CharType.Digit | CharType.Halfwidth;
        }

        if (codePoint >= 0xff10 && codePoint <= 0xff19)
        {
            return CharType.Digit;
        }

        if ((codePoint >= 'A' && codePoint <= 'Z') || (codePoint >= 'a' && codePoint <= 'z'))
        {
            return CharType.Alphabet | CharType.Halfwidth;
        }

        if ((codePoint >= 0xff21 && codePoint <= 0xff3a) || (codePoint >= 0xff41 && codePoint <= 0xff5a))
        {
            return CharType.Alphabet;
        }

        if (SpecialChars.TryGetValue(codePoint, out var specialType))
        {
            return specialType;
        }

        if ((codePoint >= 0x3041 && codePoint <= 0x309c) || codePoint == 0x309f)
        {
            return CharType.Hiragana | CharType.VowelEnded;
        }

        if ((codePoint >= 0x30a1 && codePoint <= 0x30fa) || (codePoint >= 0x30fd && codePoint <= 0x30ff))
        {
            return CharType.Katakana | CharType.VowelEnded;
        }

        if ((codePoint >= 0xff66 && codePoint <= 0xff6f) || (codePoint >= 0xff71 && codePoint <= 0xff9f))
        {
            return CharType.Katakana | CharType.VowelEnded | CharType.Halfwidth;
        }

        return CharType.Other;
    }

    private static bool IsAlnum(CharType charType)
    {
        var masked = charType & (CharType)0xe0;
        return masked == CharType.Alphabet || masked == CharType.Digit;
    }

    private static bool IsHalfwidth(CharType charType)
    {
        return (charType & CharType.Halfwidth) != CharType.Other;
    }

    private static bool IsHyphenLike(CodePointTuple codePoint)
    {
        return codePoint.Size() == 1 && HyphenLikeChars.Contains(codePoint.First);
    }

    private struct CharTypePair
    {
        public Character Char { get; }

        public CharType Type { get; }

        public CharTypePair(Character c, CharType t)
        {
            this.Char = c;
            this.Type = t;
        }
    }

    public class Options
    {
        [JsonPropertyName("skip_already_transliterated_chars")]
        public bool SkipAlreadyTransliteratedChars { get; set; }

        [JsonPropertyName("allow_prolonged_hatsuon")]
        public bool AllowProlongedHatsuon { get; set; }

        [JsonPropertyName("allow_prolonged_sokuon")]
        public bool AllowProlongedSokuon { get; set; }

        [JsonPropertyName("replace_prolonged_marks_following_alnums")]
        public bool ReplaceProlongedMarksFollowingAlnums { get; set; }
    }

    private class ProlongedSoundMarksCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {
        private readonly IEnumerator<Character> input;
        private readonly Options options;
        private readonly CharType prolongables;
        private readonly List<Character> lookaheadBuf = new();
        private int lookaheadBufIndex;
        private CharTypePair? lastNonProlongedChar;
        private int offset;
        private bool eoi;
        private bool disposed;

        public ProlongedSoundMarksCharEnumerator(IEnumerator<Character> input, Options options)
        {
            this.input = input;
            this.options = options;

            this.prolongables = CharType.VowelEnded | CharType.ProlongedSoundMark;
            if (this.options.AllowProlongedHatsuon)
            {
                this.prolongables |= CharType.Hatsuon;
            }

            if (this.options.AllowProlongedSokuon)
            {
                this.prolongables |= CharType.Sokuon;
            }
        }

        public Character Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => this.Current;

        public bool MoveNext()
        {
            if (this.disposed)
            {
                return false;
            }

        reenter:

            // Handle lookahead buffer first
            if (this.lookaheadBuf.Count > 0)
            {
                if (this.lookaheadBufIndex >= this.lookaheadBuf.Count)
                {
                    this.lookaheadBuf.Clear();
                    this.lookaheadBufIndex = 0;
                }
                else
                {
                    this.Current = this.lookaheadBuf[this.lookaheadBufIndex++];
                    return true;
                }
            }

            if (this.eoi)
            {
                return false;
            }

            if (!this.input.MoveNext())
            {
                return false;
            }

            var c = this.input.Current;

            if (IsHyphenLike(c.CodePoint))
            {
                bool shouldProcess = !this.options.SkipAlreadyTransliteratedChars || !c.IsTransliterated;

                if (shouldProcess && this.lastNonProlongedChar is CharTypePair lastNonProlongedChar)
                {
                    if ((lastNonProlongedChar.Type & this.prolongables) != 0)
                    {
                        int targetChar = IsHalfwidth(lastNonProlongedChar.Type) ? 0xff70 : 0x30fc;

                        this.Current = new Character((targetChar, -1), this.offset, c);
                        this.offset += this.Current.CharCount;
                        return true;
                    }

                    if (this.options.ReplaceProlongedMarksFollowingAlnums && IsAlnum(lastNonProlongedChar.Type))
                    {
                        var prevNonProlongedChar = this.lastNonProlongedChar;

                        // Collect all consecutive hyphen-like characters
                        while (true)
                        {
                            this.lookaheadBuf.Add(c);

                            if (!this.input.MoveNext())
                            {
                                this.eoi = true;
                                break;
                            }

                            c = this.input.Current;
                            if (!IsHyphenLike(c.CodePoint))
                            {
                                break;
                            }
                        }

                        if (!this.eoi)
                        {
                            this.lookaheadBuf.Add(c);
                            this.lastNonProlongedChar = new CharTypePair(c, GetCharType(c.CodePoint.First));
                        }

                        // Determine which hyphen character to use
                        bool halfwidth = prevNonProlongedChar is CharTypePair prevNonProlongedCharNonNull
                            ? IsHalfwidth(prevNonProlongedCharNonNull.Type)
                            : IsHalfwidth(lastNonProlongedChar.Type);

                        int targetChar = halfwidth ? 0x002d : 0xff0d;

                        // Replace all lookahead characters except the last one with the target hyphen
                        for (int j = 0; j < this.lookaheadBuf.Count - 1; j++)
                        {
                            var newChar = new Character((targetChar, -1), this.offset, this.lookaheadBuf[j]);
                            this.lookaheadBuf[j] = newChar;
                            this.offset += newChar.CharCount;
                        }

                        this.lookaheadBufIndex = 0;
                        goto reenter;
                    }
                }
            }
            else
            {
                this.lastNonProlongedChar = new CharTypePair(c, GetCharType(c.CodePoint.Size() == 1 ? c.CodePoint.First : -1));
            }

            this.Current = c.WithOffset(this.offset);
            this.offset += this.Current.CharCount;
            return true;
        }

        public void Reset()
        {
            this.input.Reset();
            this.lookaheadBuf.Clear();
            this.lookaheadBufIndex = 0;
            this.lastNonProlongedChar = null;
            this.offset = 0;
            this.eoi = false;
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
    }
}
