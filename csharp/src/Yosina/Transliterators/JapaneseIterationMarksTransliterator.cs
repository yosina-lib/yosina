// Copyright (c) Yosina. All rights reserved.

using CodePointTuple = (int First, int Second);

namespace Yosina.Transliterators;

/// <summary>
/// Japanese iteration marks transliterator.
///
/// This transliterator handles the replacement of Japanese iteration marks with the appropriate
/// repeated characters:
/// - ゝ (hiragana repetition): Repeats previous hiragana if valid
/// - ゞ (hiragana voiced repetition): Repeats previous hiragana with voicing if possible
/// - ヽ (katakana repetition): Repeats previous katakana if valid
/// - ヾ (katakana voiced repetition): Repeats previous katakana with voicing if possible
/// - 々 (kanji repetition): Repeats previous kanji
///
/// Invalid combinations remain unchanged. Characters that can't be repeated include:
/// - Voiced/semi-voiced characters
/// - Hatsuon (ん/ン)
/// - Sokuon (っ/ッ)
///
/// Halfwidth katakana with iteration marks are NOT supported.
/// Consecutive iteration marks: only the first one is expanded.
/// </summary>
[RegisteredTransliterator("japanese-iteration-marks")]
public class JapaneseIterationMarksTransliterator : ITransliterator
{
    // Iteration mark characters
    private const int HiraganaIterationMark = 0x309D; // ゝ
    private const int HiraganaVoicedIterationMark = 0x309E; // ゞ
    private const int KatakanaIterationMark = 0x30FD; // ヽ
    private const int KatakanaVoicedIterationMark = 0x30FE; // ヾ
    private const int KanjiIterationMark = 0x3005; // 々

    // Character type
    private enum CharType
    {
        Other,
        Hiragana,
        Katakana,
        Kanji,
    }

    // Special characters that cannot be repeated
    private static readonly HashSet<int> HatsuonChars = new()
    {
        0x3093, // ん
        0x30F3, // ン
        0xFF9D,  // ﾝ (halfwidth)
    };

    private static readonly HashSet<int> SokuonChars = new()
    {
        0x3063, // っ
        0x30C3, // ッ
        0xFF6F,  // ｯ (halfwidth)
    };

    // Semi-voiced characters
    private static readonly HashSet<string> SemiVoicedChars = new(StringComparer.Ordinal)
    {
        // Hiragana semi-voiced
        "ぱ", "ぴ", "ぷ", "ぺ", "ぽ",

        // Katakana semi-voiced
        "パ", "ピ", "プ", "ペ", "ポ",
    };

    // Voicing mappings for hiragana
    private static readonly Dictionary<string, string> HiraganaVoicing = new(StringComparer.Ordinal)
    {
        { "か", "が" }, { "き", "ぎ" }, { "く", "ぐ" }, { "け", "げ" }, { "こ", "ご" },
        { "さ", "ざ" }, { "し", "じ" }, { "す", "ず" }, { "せ", "ぜ" }, { "そ", "ぞ" },
        { "た", "だ" }, { "ち", "ぢ" }, { "つ", "づ" }, { "て", "で" }, { "と", "ど" },
        { "は", "ば" }, { "ひ", "び" }, { "ふ", "ぶ" }, { "へ", "べ" }, { "ほ", "ぼ" },
    };

    // Voicing mappings for katakana
    private static readonly Dictionary<string, string> KatakanaVoicing = new(StringComparer.Ordinal)
    {
        { "カ", "ガ" }, { "キ", "ギ" }, { "ク", "グ" }, { "ケ", "ゲ" }, { "コ", "ゴ" },
        { "サ", "ザ" }, { "シ", "ジ" }, { "ス", "ズ" }, { "セ", "ゼ" }, { "ソ", "ゾ" },
        { "タ", "ダ" }, { "チ", "ヂ" }, { "ツ", "ヅ" }, { "テ", "デ" }, { "ト", "ド" },
        { "ハ", "バ" }, { "ヒ", "ビ" }, { "フ", "ブ" }, { "ヘ", "ベ" }, { "ホ", "ボ" },
        { "ウ", "ヴ" },
    };

    // Lazy initialization of voiced characters derived from voicing maps
    private static readonly Lazy<HashSet<string>> VoicedCharsLazy = new(() =>
    {
        var voicedChars = new HashSet<string>(StringComparer.Ordinal);
        foreach (var voiced in HiraganaVoicing.Values)
        {
            voicedChars.Add(voiced);
        }
        foreach (var voiced in KatakanaVoicing.Values)
        {
            voicedChars.Add(voiced);
        }
        return voicedChars;
    });

    private static HashSet<string> VoicedChars => VoicedCharsLazy.Value;

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        return new JapaneseIterationMarksCharEnumerator(input.GetEnumerator());
    }

    private static bool IsIterationMark(int codepoint)
    {
        return codepoint == HiraganaIterationMark
            || codepoint == HiraganaVoicedIterationMark
            || codepoint == KatakanaIterationMark
            || codepoint == KatakanaVoicedIterationMark
            || codepoint == KanjiIterationMark;
    }

    private static CharType GetCharType(string charStr)
    {
        if (string.IsNullOrEmpty(charStr))
        {
            return CharType.Other;
        }

        var codepoints = charStr.EnumerateRunes().Select(r => r.Value).ToArray();
        if (codepoints.Length == 0)
        {
            return CharType.Other;
        }

        int codepoint = codepoints[0];

        // Check if it's hatsuon or sokuon
        if (HatsuonChars.Contains(codepoint) || SokuonChars.Contains(codepoint))
        {
            return CharType.Other;
        }

        // Check if it's voiced or semi-voiced
        if (VoicedChars.Contains(charStr) || SemiVoicedChars.Contains(charStr))
        {
            return CharType.Other;
        }

        // Hiragana (excluding special marks)
        if (codepoint >= 0x3041 && codepoint <= 0x3096)
        {
            return CharType.Hiragana;
        }

        // Katakana (excluding halfwidth and special marks)
        if (codepoint >= 0x30A1 && codepoint <= 0x30FA)
        {
            return CharType.Katakana;
        }

        // Kanji - CJK Unified Ideographs (common ranges)
        if ((codepoint >= 0x4E00 && codepoint <= 0x9FFF)
            || (codepoint >= 0x3400 && codepoint <= 0x4DBF)
            || (codepoint >= 0x20000 && codepoint <= 0x2A6DF)
            || (codepoint >= 0x2A700 && codepoint <= 0x2B73F)
            || (codepoint >= 0x2B740 && codepoint <= 0x2B81F)
            || (codepoint >= 0x2B820 && codepoint <= 0x2CEAF)
            || (codepoint >= 0x2CEB0 && codepoint <= 0x2EBEF)
            || (codepoint >= 0x30000 && codepoint <= 0x3134F))
        {
            return CharType.Kanji;
        }

        return CharType.Other;
    }

    private class CharInfo
    {
        public string CharStr { get; }

        public CharType Type { get; }

        public CharInfo(string charStr, CharType type)
        {
            this.CharStr = charStr;
            this.Type = type;
        }
    }

    private class JapaneseIterationMarksCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {
        private readonly IEnumerator<Character> input;
        private int offset;
        private CharInfo? prevCharInfo;
        private bool prevWasIterationMark;
        private readonly Queue<Character> outputBuf = new();
        private bool disposed;

        public JapaneseIterationMarksCharEnumerator(IEnumerator<Character> input)
        {
            this.input = input;
        }

        public Character Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => this.Current;

        public bool MoveNext()
        {
            if (this.disposed)
            {
                return false;
            }

            // If we have output characters buffered, return them first
            if (this.outputBuf.Count > 0)
            {
                this.Current = this.outputBuf.Dequeue();
                return true;
            }

            if (!this.input.MoveNext())
            {
                return false;
            }

            var character = this.input.Current;
            if (character.IsSentinel)
            {
                this.Current = character;
                return true;
            }

            string currentChar = character.CodePoint.AsString();
            int codepoint = character.CodePoint.Size() == 1 ? character.CodePoint.First : -1;

            if (codepoint >= 0 && IsIterationMark(codepoint))
            {
                // Check if previous character was also an iteration mark
                if (this.prevWasIterationMark)
                {
                    // Don't replace consecutive iteration marks
                    var result = character.WithOffset(this.offset);
                    this.offset += result.CharCount;
                    this.prevWasIterationMark = true;
                    this.Current = result;
                    return true;
                }

                // Try to replace the iteration mark
                string? replacement = null;
                if (this.prevCharInfo != null)
                {
                    switch (codepoint)
                    {
                        case HiraganaIterationMark:
                            // Repeat previous hiragana if valid
                            if (this.prevCharInfo.Type == CharType.Hiragana)
                            {
                                replacement = this.prevCharInfo.CharStr;
                            }

                            break;

                        case HiraganaVoicedIterationMark:
                            // Repeat previous hiragana with voicing if possible
                            if (this.prevCharInfo.Type == CharType.Hiragana)
                            {
                                HiraganaVoicing.TryGetValue(this.prevCharInfo.CharStr, out replacement);
                            }

                            break;

                        case KatakanaIterationMark:
                            // Repeat previous katakana if valid
                            if (this.prevCharInfo.Type == CharType.Katakana)
                            {
                                replacement = this.prevCharInfo.CharStr;
                            }

                            break;

                        case KatakanaVoicedIterationMark:
                            // Repeat previous katakana with voicing if possible
                            if (this.prevCharInfo.Type == CharType.Katakana)
                            {
                                KatakanaVoicing.TryGetValue(this.prevCharInfo.CharStr, out replacement);
                            }

                            break;

                        case KanjiIterationMark:
                            // Repeat previous kanji
                            if (this.prevCharInfo.Type == CharType.Kanji)
                            {
                                replacement = this.prevCharInfo.CharStr;
                            }

                            break;
                    }
                }

                if (replacement != null)
                {
                    // Replace the iteration mark
                    var replacementCodePoints = replacement.EnumerateRunes().Select(r => r.Value).ToArray();
                    CodePointTuple newCodePoint = replacementCodePoints.Length == 1
                        ? (replacementCodePoints[0], -1)
                        : (replacementCodePoints[0], replacementCodePoints[1]);

                    var result = new Character(newCodePoint, this.offset, character);
                    this.offset += result.CharCount;
                    this.prevWasIterationMark = true;

                    // Keep the original prevCharInfo - don't update it
                    this.Current = result;
                    return true;
                }
                else
                {
                    // Couldn't replace the iteration mark
                    var result = character.WithOffset(this.offset);
                    this.offset += result.CharCount;
                    this.prevWasIterationMark = true;
                    this.Current = result;
                    return true;
                }
            }
            else
            {
                // Not an iteration mark
                var result = character.WithOffset(this.offset);
                this.offset += result.CharCount;

                // Update previous character info
                CharType charType = GetCharType(currentChar);
                if (charType != CharType.Other)
                {
                    this.prevCharInfo = new CharInfo(currentChar, charType);
                }
                else
                {
                    this.prevCharInfo = null;
                }

                this.prevWasIterationMark = false;
                this.Current = result;
                return true;
            }
        }

        public void Reset()
        {
            this.input.Reset();
            this.outputBuf.Clear();
            this.offset = 0;
            this.prevCharInfo = null;
            this.prevWasIterationMark = false;
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
