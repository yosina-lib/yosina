package io.yosina.transliterators;

import java.util.Optional;

/** Shared hiragana-katakana mapping table */
public final class HiraKataTable {
    /** Structure to hold hiragana/katakana character forms */
    public static class HiraKata {
        /** The base character code point */
        public final int base;

        /** The voiced variant code point (dakuten), or -1 if none */
        public final int voiced;

        /** The semivoiced variant code point (handakuten), or -1 if none */
        public final int semivoiced;

        private HiraKata(int base, int voiced, int semivoiced) {
            this.base = base;
            this.voiced = voiced;
            this.semivoiced = semivoiced;
        }
    }

    /** Entry in the hiragana-katakana table */
    public static class HiraKataEntry {
        /** Optional hiragana character forms */
        public final Optional<HiraKata> hiragana;

        /** Katakana character forms */
        public final HiraKata katakana;

        /** Halfwidth katakana code point, or -1 if none */
        public final int halfwidth;

        private HiraKataEntry(Optional<HiraKata> hiragana, HiraKata katakana, int halfwidth) {
            this.hiragana = hiragana;
            this.katakana = katakana;
            this.halfwidth = halfwidth;
        }

        private static HiraKataEntry fromStringArray(String[] parts, int offset) {
            if (offset + 7 > parts.length) {
                throw new IndexOutOfBoundsException("Offset " + offset + " is out of bounds");
            }
            final int hiraganaBase = codePointOf(parts[offset]);
            final Optional<HiraKata> hiragana =
                    hiraganaBase >= 0
                            ? Optional.of(
                                    new HiraKata(
                                            hiraganaBase,
                                            codePointOf(parts[offset + 1]),
                                            codePointOf(parts[offset + 2])))
                            : Optional.empty();
            final HiraKata katakana =
                    new HiraKata(
                            codePointOf(parts[offset + 3]),
                            codePointOf(parts[offset + 4]),
                            codePointOf(parts[offset + 5]));
            final int halfwidth = codePointOf(parts[offset + 6]);
            return new HiraKataEntry(hiragana, katakana, halfwidth);
        }
    }

    private static int codePointOf(String str) {
        return str.isEmpty() ? -1 : str.codePointAt(0);
    }

    private static HiraKataEntry[] hiraKataEntriesFromStringArray(String[] parts) {
        final HiraKataEntry[] entries = new HiraKataEntry[parts.length / 7];
        for (int i = 0; i < entries.length; i++) {
            entries[i] = HiraKataEntry.fromStringArray(parts, i * 7);
        }
        return entries;
    }

    /** Main hiragana-katakana table */
    public static final HiraKataEntry[] HIRAGANA_KATAKANA_TABLE =
            hiraKataEntriesFromStringArray(
                    new String[] {
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
                        "ん", "", "", "ン", "", "", "ﾝ"
                    });

    /** Small kana entry */
    public static class SmallKanaEntry {
        /** Hiragana small character code point */
        public final int hiragana;

        /** Katakana small character code point */
        public final int katakana;

        /** Halfwidth katakana small character code point, or -1 if none */
        public final int halfwidth;

        private SmallKanaEntry(int hiragana, int katakana, int halfwidth) {
            this.hiragana = hiragana;
            this.katakana = katakana;
            this.halfwidth = halfwidth;
        }

        private static SmallKanaEntry fromStringArray(String[] parts, int offset) {
            if (offset + 3 > parts.length) {
                throw new IllegalArgumentException("Invalid offset");
            }
            int hiragana = codePointOf(parts[offset]);
            int katakana = codePointOf(parts[offset + 1]);
            int halfwidth = codePointOf(parts[offset + 2]);
            return new SmallKanaEntry(hiragana, katakana, halfwidth);
        }
    }

    private static SmallKanaEntry[] smallKanaEntriesFromStringArray(String[] parts) {
        SmallKanaEntry[] entries = new SmallKanaEntry[parts.length / 3];
        for (int i = 0; i < entries.length; i++) {
            entries[i] = SmallKanaEntry.fromStringArray(parts, i * 3);
        }
        return entries;
    }

    /** Small kana table */
    public static final SmallKanaEntry[] HIRAGANA_KATAKANA_SMALL_TABLE =
            smallKanaEntriesFromStringArray(
                    new String[] {
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
                        "ゖ", "ヶ", ""
                    });

    // Private constructor to prevent instantiation
    private HiraKataTable() {}
}
