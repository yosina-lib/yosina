// Copyright (c) Yosina. All rights reserved.

using System.Runtime.InteropServices;

namespace Yosina.Transliterators;

/// <summary>
/// Shared hiragana-katakana mapping table.
/// </summary>
internal static class HiraKataTable
{
    /// <summary>
    /// Structure to hold hiragana/katakana character forms.
    /// </summary>
    [StructLayout(LayoutKind.Auto)]
    internal readonly struct HiraKata
    {
        public readonly int Base;
        public readonly int Voiced;
        public readonly int Semivoiced;

        public HiraKata(int baseChar, int voiced, int semivoiced)
        {
            this.Base = baseChar;
            this.Voiced = voiced;
            this.Semivoiced = semivoiced;
        }
    }

    /// <summary>
    /// Entry in the hiragana-katakana table.
    /// </summary>
    [StructLayout(LayoutKind.Auto)]
    internal readonly struct HiraKataEntry
    {
        public readonly HiraKata? Hiragana;
        public readonly HiraKata Katakana;
        public readonly int Halfwidth;

        public HiraKataEntry(HiraKata? hiragana, HiraKata katakana, int halfwidth)
        {
            this.Hiragana = hiragana;
            this.Katakana = katakana;
            this.Halfwidth = halfwidth;
        }

        public static HiraKataEntry FromStringArray(string[] parts, int offset)
        {
            var hiraganaBase = CodePointOf(parts[offset]);
            var hiragana = hiraganaBase >= 0
                ? new HiraKata(
                    hiraganaBase,
                    CodePointOf(parts[offset + 1]),
                    CodePointOf(parts[offset + 2]))
                : (HiraKata?)null;
            var katakana = new HiraKata(
                CodePointOf(parts[offset + 3]),
                CodePointOf(parts[offset + 4]),
                CodePointOf(parts[offset + 5]));
            var halfwidth = CodePointOf(parts[offset + 6]);
            return new HiraKataEntry(hiragana, katakana, halfwidth);
        }
    }

    /// <summary>
    /// Small kana entry.
    /// </summary>
    [StructLayout(LayoutKind.Auto)]
    internal readonly struct SmallKanaEntry
    {
        public readonly int Hiragana;
        public readonly int Katakana;
        public readonly int Halfwidth;

        public SmallKanaEntry(int hiragana, int katakana, int halfwidth)
        {
            this.Hiragana = hiragana;
            this.Katakana = katakana;
            this.Halfwidth = halfwidth;
        }
    }

    private static int CodePointOf(string str)
    {
        return string.IsNullOrEmpty(str) ? -1 : char.ConvertToUtf32(str, 0);
    }

    private static HiraKataEntry[] HiraKataEntriesFromStringArray(string[] parts)
    {
        var entries = new HiraKataEntry[parts.Length / 7];
        for (int i = 0; i < entries.Length; i++)
        {
            entries[i] = HiraKataEntry.FromStringArray(parts, i * 7);
        }

        return entries;
    }

    /// <summary>
    /// Main hiragana-katakana table.
    /// </summary>
#pragma warning disable SA1122 // Use string.Empty for empty strings
    public static readonly HiraKataEntry[] HiraganaKatakanaTable = HiraKataEntriesFromStringArray(new[]
    {
        "あ", "", "", "ア", "", "", "ｱ",
        "い", "", "", "イ", "", "", "ｲ",
        "う", "ゔ", "", "ウ", "ヴ", "", "ｳ",
        "え", "", "", "エ", "", "", "ｴ",
        "お", "", "", "オ", "", "", "ｵ",
        "か", "が", "", "カ", "ガ", "", "ｶ",
        "き", "ぎ", "", "キ", "ギ", "", "ｷ",
        "く", "ぐ", "", "ク", "グ", "", "ｸ",
        "け", "げ", "", "ケ", "ゲ", "", "ｹ",
        "こ", "ご", "", "コ", "ゴ", "", "ｺ",
        "さ", "ざ", "", "サ", "ザ", "", "ｻ",
        "し", "じ", "", "シ", "ジ", "", "ｼ",
        "す", "ず", "", "ス", "ズ", "", "ｽ",
        "せ", "ぜ", "", "セ", "ゼ", "", "ｾ",
        "そ", "ぞ", "", "ソ", "ゾ", "", "ｿ",
        "た", "だ", "", "タ", "ダ", "", "ﾀ",
        "ち", "ぢ", "", "チ", "ヂ", "", "ﾁ",
        "つ", "づ", "", "ツ", "ヅ", "", "ﾂ",
        "て", "で", "", "テ", "デ", "", "ﾃ",
        "と", "ど", "", "ト", "ド", "", "ﾄ",
        "な", "", "", "ナ", "", "", "ﾅ",
        "に", "", "", "ニ", "", "", "ﾆ",
        "ぬ", "", "", "ヌ", "", "", "ﾇ",
        "ね", "", "", "ネ", "", "", "ﾈ",
        "の", "", "", "ノ", "", "", "ﾉ",
        "は", "ば", "ぱ", "ハ", "バ", "パ", "ﾊ",
        "ひ", "び", "ぴ", "ヒ", "ビ", "ピ", "ﾋ",
        "ふ", "ぶ", "ぷ", "フ", "ブ", "プ", "ﾌ",
        "へ", "べ", "ぺ", "ヘ", "ベ", "ペ", "ﾍ",
        "ほ", "ぼ", "ぽ", "ホ", "ボ", "ポ", "ﾎ",
        "ま", "", "", "マ", "", "", "ﾏ",
        "み", "", "", "ミ", "", "", "ﾐ",
        "む", "", "", "ム", "", "", "ﾑ",
        "め", "", "", "メ", "", "", "ﾒ",
        "も", "", "", "モ", "", "", "ﾓ",
        "や", "", "", "ヤ", "", "", "ﾔ",
        "ゆ", "", "", "ユ", "", "", "ﾕ",
        "よ", "", "", "ヨ", "", "", "ﾖ",
        "ら", "", "", "ラ", "", "", "ﾗ",
        "り", "", "", "リ", "", "", "ﾘ",
        "る", "", "", "ル", "", "", "ﾙ",
        "れ", "", "", "レ", "", "", "ﾚ",
        "ろ", "", "", "ロ", "", "", "ﾛ",
        "わ", "", "", "ワ", "ヷ", "", "ﾜ",
        "ゐ", "", "", "ヰ", "ヸ", "", "",
        "ゑ", "", "", "ヱ", "ヹ", "", "",
        "を", "", "", "ヲ", "ヺ", "", "ｦ",
        "ん", "", "", "ン", "", "", "ﾝ",
    });
#pragma warning restore SA1122 // Use string.Empty for empty strings

    private static SmallKanaEntry[] SmallKanaEntriesFromStringArray(string[] parts)
    {
        var entries = new SmallKanaEntry[parts.Length / 3];
        for (int i = 0; i < entries.Length; i++)
        {
            var hiragana = CodePointOf(parts[i * 3]);
            var katakana = CodePointOf(parts[(i * 3) + 1]);
            var halfwidth = CodePointOf(parts[(i * 3) + 2]);
            entries[i] = new SmallKanaEntry(hiragana, katakana, halfwidth);
        }

        return entries;
    }

    /// <summary>
    /// Small kana table.
    /// </summary>
#pragma warning disable SA1122 // Use string.Empty for empty strings
    public static readonly SmallKanaEntry[] HiraganaKatakanaSmallTable = SmallKanaEntriesFromStringArray(new[]
    {
        "ぁ", "ァ", "ｧ",
        "ぃ", "ィ", "ｨ",
        "ぅ", "ゥ", "ｩ",
        "ぇ", "ェ", "ｪ",
        "ぉ", "ォ", "ｫ",
        "っ", "ッ", "ｯ",
        "ゃ", "ャ", "ｬ",
        "ゅ", "ュ", "ｭ",
        "ょ", "ョ", "ｮ",
        "ゎ", "ヮ", "",
        "ゕ", "ヵ", "",
        "ゖ", "ヶ", "",
    });
#pragma warning restore SA1122 // Use string.Empty for empty strings

    /// <summary>
    /// Generate composition table for HiraKataCompositionTransliterator.
    /// </summary>
    public static Dictionary<int, (int Voiced, int SemiVoiced)> GenerateCompositionEntries()
    {
        var compositionTable = new Dictionary<int, (int Voiced, int SemiVoiced)>();

        foreach (var entry in HiraganaKatakanaTable)
        {
            if (entry.Hiragana.HasValue && (entry.Hiragana.Value.Voiced > 0 || entry.Hiragana.Value.Semivoiced > 0))
            {
                compositionTable[entry.Hiragana.Value.Base] = (entry.Hiragana.Value.Voiced, entry.Hiragana.Value.Semivoiced);
            }

            if (entry.Katakana.Voiced > 0 || entry.Katakana.Semivoiced > 0)
            {
                compositionTable[entry.Katakana.Base] = (entry.Katakana.Voiced, entry.Katakana.Semivoiced);
            }
        }

        compositionTable[0x309d] = (0x309e, -1); // ゝ -> ゞ
        compositionTable[0x30fd] = (0x30fe, -1); // ヽ -> ヾ
        compositionTable[0x3031] = (0x3032, -1); // 〱 -> 〲 (vertical hiragana)
        compositionTable[0x3033] = (0x3034, -1); // 〳 -> 〴 (vertical katakana)

        return compositionTable;
    }

    /// <summary>
    /// Generate GR table for JIS X 0201 (katakana fullwidth to halfwidth).
    /// </summary>
    public static Dictionary<int, int> GenerateGRTable()
    {
        var result = new Dictionary<int, int>
        {
            { 0x3002, 0xff61 }, // 。 -> ｡
            { 0x300c, 0xff62 }, // 「 -> ｢
            { 0x300d, 0xff63 }, // 」 -> ｣
            { 0x3001, 0xff64 }, // 、 -> ､
            { 0x30fb, 0xff65 }, // ・ -> ･
            { 0x30fc, 0xff70 }, // ー -> ｰ
            { 0x309b, 0xff9e }, // ゛ -> ﾞ
            { 0x309c, 0xff9f }, // ゜-> ﾟ
        };

        // Add katakana mappings from main table
        foreach (var entry in HiraganaKatakanaTable)
        {
            if (entry.Halfwidth > 0)
            {
                result[entry.Katakana.Base] = entry.Halfwidth;
            }
        }

        // Add small kana mappings
        foreach (var entry in HiraganaKatakanaSmallTable)
        {
            if (entry.Halfwidth > 0)
            {
                result[entry.Katakana] = entry.Halfwidth;
            }
        }

        return result;
    }

    /// <summary>
    /// Generate voiced letters table for JIS X 0201.
    /// </summary>
    public static Dictionary<int, int[]> GenerateVoicedLettersTable()
    {
        var result = new Dictionary<int, int[]>();

        foreach (var entry in HiraganaKatakanaTable)
        {
            if (entry.Halfwidth > 0)
            {
                if (entry.Katakana.Voiced > 0)
                {
                    result[entry.Katakana.Voiced] = new[] { entry.Halfwidth, 0xff9e };
                }

                if (entry.Katakana.Semivoiced > 0)
                {
                    result[entry.Katakana.Semivoiced] = new[] { entry.Halfwidth, 0xff9f };
                }
            }
        }

        return result;
    }

    /// <summary>
    /// Generate hiragana table for JIS X 0201.
    /// </summary>
    public static Dictionary<int, int[]> GenerateHiraganaTable()
    {
        var result = new Dictionary<int, int[]>();

        // Add main table hiragana mappings
        foreach (var entry in HiraganaKatakanaTable)
        {
            if (entry.Hiragana.HasValue && entry.Halfwidth > 0)
            {
                var hiragana = entry.Hiragana.Value;
                result[hiragana.Base] = new[] { entry.Halfwidth };
                if (hiragana.Voiced > 0)
                {
                    result[hiragana.Voiced] = new[] { entry.Halfwidth, 0xff9e };
                }

                if (hiragana.Semivoiced > 0)
                {
                    result[hiragana.Semivoiced] = new[] { entry.Halfwidth, 0xff9f };
                }
            }
        }

        // Add small kana mappings
        foreach (var entry in HiraganaKatakanaSmallTable)
        {
            if (entry.Halfwidth > 0)
            {
                result[entry.Hiragana] = new[] { entry.Halfwidth };
            }
        }

        return result;
    }
}
