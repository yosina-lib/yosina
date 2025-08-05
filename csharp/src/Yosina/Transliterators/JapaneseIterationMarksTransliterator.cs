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
/// - 〱 (vertical hiragana repetition): Same as ゝ
/// - 〲 (vertical hiragana voiced repetition): Same as ゞ
/// - ヽ (katakana repetition): Repeats previous katakana if valid
/// - ヾ (katakana voiced repetition): Repeats previous katakana with voicing if possible
/// - 〳 (vertical katakana repetition): Same as ヽ
/// - 〴 (vertical katakana voiced repetition): Same as ヾ
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
    // Character type
    private enum CharType
    {
        Other,
        Hiragana,
        HiraganaHatsuon,
        HiraganaSokuon,
        HiraganaIterationMark,
        HiraganaVoiced,
        HiraganaVoicedIterationMark,
        HiraganaSemivoiced,
        Katakana,
        KatakanaIterationMark,
        KatakanaHatsuon,
        KatakanaSokuon,
        KatakanaVoiced,
        KatakanaVoicedIterationMark,
        KatakanaSemivoiced,
        Kanji,
        KanjiIterationMark,
    }

    // Voicing mappings for hiragana
    private static readonly Dictionary<int, int> HiraganaVoicing = new()
    {
        { 0x304b, 0x304c }, // か -> が
        { 0x304d, 0x304e }, // き -> ぎ
        { 0x304f, 0x3050 }, // く -> ぐ
        { 0x3051, 0x3052 }, // け -> げ
        { 0x3053, 0x3054 }, // こ -> ご
        { 0x3055, 0x3056 }, // さ -> ざ
        { 0x3057, 0x3058 }, // し -> じ
        { 0x3059, 0x305a }, // す -> ず
        { 0x305b, 0x305c }, // せ -> ぜ
        { 0x305d, 0x305e }, // そ -> ぞ
        { 0x305f, 0x3060 }, // た -> だ
        { 0x3061, 0x3062 }, // ち -> ぢ
        { 0x3064, 0x3065 }, // つ -> づ
        { 0x3066, 0x3067 }, // て -> で
        { 0x3068, 0x3069 }, // と -> ど
        { 0x306f, 0x3070 }, // は -> ば
        { 0x3072, 0x3073 }, // ひ -> び
        { 0x3075, 0x3076 }, // ふ -> ぶ
        { 0x3078, 0x3079 }, // へ -> べ
        { 0x307b, 0x307c }, // ほ -> ぼ
    };

    // Voicing mappings for katakana
    private static readonly Dictionary<int, int> KatakanaVoicing = new()
    {
        { 0x30ab, 0x30ac }, // カ -> ガ
        { 0x30ad, 0x30ae }, // キ -> ギ
        { 0x30af, 0x30b0 }, // ク -> グ
        { 0x30b1, 0x30b2 }, // ケ -> ゲ
        { 0x30b3, 0x30b4 }, // コ -> ゴ
        { 0x30b5, 0x30b6 }, // サ -> ザ
        { 0x30b7, 0x30b8 }, // シ -> ジ
        { 0x30b9, 0x30ba }, // ス -> ズ
        { 0x30bb, 0x30bc }, // セ -> ゼ
        { 0x30bd, 0x30be }, // ソ -> ゾ
        { 0x30bf, 0x30c0 }, // タ -> ダ
        { 0x30c1, 0x30c2 }, // チ -> ヂ
        { 0x30c4, 0x30c5 }, // ツ -> ヅ
        { 0x30c6, 0x30c7 }, // テ -> デ
        { 0x30c8, 0x30c9 }, // ト -> ド
        { 0x30cf, 0x30d0 }, // ハ -> バ
        { 0x30d2, 0x30d3 }, // ヒ -> ビ
        { 0x30d5, 0x30d6 }, // フ -> ブ
        { 0x30d8, 0x30d9 }, // ヘ -> ベ
        { 0x30db, 0x30dc }, // ホ -> ボ
        { 0x30a6, 0x30f4 }, // ウ -> ヴ
    };

    private static readonly HashSet<int> HiraganaVoiced = new(HiraganaVoicing.Values);

    private static readonly HashSet<int> KatakanaVoiced = new(KatakanaVoicing.Values);

    private static readonly Dictionary<int, int> UnvoicingMap = new(
        HiraganaVoicing.Select((pair) => new KeyValuePair<int, int>(pair.Value, pair.Key)).Union(
            KatakanaVoicing.Select((pair) => new KeyValuePair<int, int>(pair.Value, pair.Key))));

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        return new JapaneseIterationMarksCharEnumerator(input.GetEnumerator());
    }

    private static CharType GetCharType(CodePointTuple codePointTuple)
    {
        if (codePointTuple.IsEmpty())
        {
            return CharType.Other;
        }

        var codepoint = codePointTuple.First;

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

        if (codePointTuple.Size() != 1)
        {
            return CharType.Other;
        }

        switch (codepoint)
        {
            case 0x3071:
            case 0x3074:
            case 0x3077:
            case 0x307A:
            case 0x307D: // ぱ, ぴ, ぷ, ぺ, ぽ
                return CharType.HiraganaSemivoiced;
            case 0x30D1:
            case 0x30D4:
            case 0x30D7:
            case 0x30DA:
            case 0x30DD: // パ, ピ, プ, ペ, ポ
                return CharType.KatakanaSemivoiced;
            case 0x3093: // ん
                return CharType.HiraganaHatsuon;
            case 0x30F3: // ン
                return CharType.KatakanaHatsuon;
            case 0x3063: // っ
                return CharType.HiraganaSokuon;
            case 0x30C3: // ッ
                return CharType.KatakanaSokuon;
            case 0x309D: // ゝ
            case 0x3031: // 〱 (vertical hiragana repeat mark)
                return CharType.HiraganaIterationMark;
            case 0x309E: // ゞ
            case 0x3032: // 〲 (vertical hiragana voiced repeat mark)
                return CharType.HiraganaVoicedIterationMark;
            case 0x30FD: // ヽ
            case 0x3033: // 〳 (vertical katakana repeat mark)
                return CharType.KatakanaIterationMark;
            case 0x30FE: // ヾ
            case 0x3034: // 〴 (vertical katakana voiced repeat mark)
                return CharType.KatakanaVoicedIterationMark;
            case 0x3005: // 々
                return CharType.KanjiIterationMark;
        }

        // Check if it's voiced or semi-voiced
        if (HiraganaVoiced.Contains(codepoint))
        {
            return CharType.HiraganaVoiced;
        }

        if (KatakanaVoiced.Contains(codepoint))
        {
            return CharType.KatakanaVoiced;
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

        return CharType.Other;
    }

    private struct CharInfo
    {
        public Character C { get; }

        public CharType Type { get; }

        public CharInfo(Character c, CharType type)
        {
            this.C = c;
            this.Type = type;
        }
    }

    private class JapaneseIterationMarksCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {
        private readonly IEnumerator<Character> input;
        private int offset;
        private CharInfo? prevChar;
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

            if (!this.input.MoveNext())
            {
                return false;
            }

            var character = this.input.Current;
            if (character.IsSentinel)
            {
                this.Current = character.WithOffset(this.offset);
                return true;
            }

            var currentChar = new CharInfo(character, GetCharType(character.CodePoint));

            if (this.prevChar != null)
            {
                var prevChar_ = this.prevChar.Value;

                switch (currentChar.Type)
                {
                    case CharType.HiraganaIterationMark:
                        switch (prevChar_.Type)
                        {
                            case CharType.Hiragana:
                                // Repeat previous hiragana
                                this.Current = new Character(prevChar_.C.CodePoint, this.offset, character);
                                this.offset += this.Current.CharCount;
                                this.prevChar = currentChar;
                                return true;

                            case CharType.HiraganaVoiced:
                                if (UnvoicingMap.TryGetValue(prevChar_.C.CodePoint.First, out var unvoicedCodePoint))
                                {
                                    this.Current = new Character((unvoicedCodePoint, -1), this.offset, character);
                                    this.offset += this.Current.CharCount;
                                    this.prevChar = currentChar;
                                    return true;
                                }

                                break;
                        }

                        break;
                    case CharType.HiraganaVoicedIterationMark:
                        switch (prevChar_.Type)
                        {
                            case CharType.Hiragana:
                                // Repeat previous hiragana as voiced
                                if (HiraganaVoicing.TryGetValue(prevChar_.C.CodePoint.First, out var voicedCodePoint))
                                {
                                    this.Current = new Character((voicedCodePoint, -1), this.offset, character);
                                    this.offset += this.Current.CharCount;
                                    this.prevChar = currentChar;
                                    return true;
                                }

                                break;
                            case CharType.HiraganaVoiced:
                                // Repeat previous voiced hiragana
                                this.Current = new Character(prevChar_.C.CodePoint, this.offset, character);
                                this.offset += this.Current.CharCount;
                                this.prevChar = currentChar;
                                return true;
                        }

                        break;
                    case CharType.KatakanaIterationMark:
                        switch (prevChar_.Type)
                        {
                            case CharType.Katakana:
                                // Repeat previous katakana
                                this.Current = new Character(prevChar_.C.CodePoint, this.offset, character);
                                this.offset += this.Current.CharCount;
                                this.prevChar = currentChar;
                                return true;

                            case CharType.KatakanaVoiced:
                                if (UnvoicingMap.TryGetValue(prevChar_.C.CodePoint.First, out var unvoicedCodePoint))
                                {
                                    this.Current = new Character((unvoicedCodePoint, -1), this.offset, character);
                                    this.offset += this.Current.CharCount;
                                    this.prevChar = currentChar;
                                    return true;
                                }

                                break;
                        }

                        break;
                    case CharType.KatakanaVoicedIterationMark:
                        switch (prevChar_.Type)
                        {
                            case CharType.Katakana:
                                // Repeat previous katakana as voiced
                                if (KatakanaVoicing.TryGetValue(prevChar_.C.CodePoint.First, out var voicedCodePoint))
                                {
                                    this.Current = new Character((voicedCodePoint, -1), this.offset, character);
                                    this.offset += this.Current.CharCount;
                                    this.prevChar = currentChar;
                                    return true;
                                }

                                break;
                            case CharType.KatakanaVoiced:
                                // Repeat previous voiced hiragana
                                this.Current = new Character(prevChar_.C.CodePoint, this.offset, character);
                                this.offset += this.Current.CharCount;
                                this.prevChar = currentChar;
                                return true;
                        }

                        break;
                    case CharType.KanjiIterationMark:
                        if (prevChar_.Type == CharType.Kanji)
                        {
                            // Repeat previous kanji
                            this.Current = new Character(prevChar_.C.CodePoint, this.offset, character);
                            this.offset += this.Current.CharCount;
                            this.prevChar = currentChar;
                            return true;
                        }

                        break;
                }
            }

            // Not an iteration mark
            var result = character.WithOffset(this.offset);
            this.offset += result.CharCount;
            this.Current = result;
            this.prevChar = currentChar;
            return true;
        }

        public void Reset()
        {
            this.input.Reset();
            this.offset = 0;
            this.prevChar = null;
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
