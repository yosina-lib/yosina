package io.yosina.transliterators;

import io.yosina.Char;
import io.yosina.CharIterator;
import io.yosina.CodePointTuple;
import io.yosina.Transliterator;
import io.yosina.annotations.RegisteredTransliterator;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Set;

/**
 * Japanese iteration marks transliterator.
 *
 * <p>This transliterator handles the replacement of Japanese iteration marks with the appropriate
 * repeated characters:
 *
 * <ul>
 *   <li>ゝ (hiragana repetition): Repeats previous hiragana if valid
 *   <li>ゞ (hiragana voiced repetition): Repeats previous hiragana with voicing if possible
 *   <li>〱 (vertical hiragana repetition): Same as ゝ
 *   <li>〲 (vertical hiragana voiced repetition): Same as ゞ
 *   <li>ヽ (katakana repetition): Repeats previous katakana if valid
 *   <li>ヾ (katakana voiced repetition): Repeats previous katakana with voicing if possible
 *   <li>〳 (vertical katakana repetition): Same as ヽ
 *   <li>〴 (vertical katakana voiced repetition): Same as ヾ
 *   <li>々 (kanji repetition): Repeats previous kanji
 * </ul>
 *
 * <p>Invalid combinations remain unchanged. Characters that can't be repeated include:
 *
 * <ul>
 *   <li>Voiced/semi-voiced characters
 *   <li>Hatsuon (ん/ン)
 *   <li>Sokuon (っ/ッ)
 * </ul>
 *
 * <p>Halfwidth katakana with iteration marks are NOT supported. Consecutive iteration marks: only
 * the first one is expanded.
 */
@RegisteredTransliterator(name = "japanese-iteration-marks")
public class JapaneseIterationMarksTransliterator implements Transliterator {

    // Iteration mark characters
    private static final int HIRAGANA_ITERATION_MARK = 0x309D; // ゝ
    private static final int HIRAGANA_VOICED_ITERATION_MARK = 0x309E; // ゞ
    private static final int VERTICAL_HIRAGANA_ITERATION_MARK = 0x3031; // 〱
    private static final int VERTICAL_HIRAGANA_VOICED_ITERATION_MARK = 0x3032; // 〲
    private static final int KATAKANA_ITERATION_MARK = 0x30FD; // ヽ
    private static final int KATAKANA_VOICED_ITERATION_MARK = 0x30FE; // ヾ
    private static final int VERTICAL_KATAKANA_ITERATION_MARK = 0x3033; // 〳
    private static final int VERTICAL_KATAKANA_VOICED_ITERATION_MARK = 0x3034; // 〴
    private static final int KANJI_ITERATION_MARK = 0x3005; // 々

    // Character type constants
    private enum CharType {
        OTHER,
        HIRAGANA,
        HIRAGANA_HATSUON,
        HIRAGANA_SOKUON,
        HIRAGANA_ITERATION_MARK,
        HIRAGANA_VOICED,
        HIRAGANA_VOICED_ITERATION_MARK,
        HIRAGANA_SEMIVOICED,
        KATAKANA,
        KATAKANA_ITERATION_MARK,
        KATAKANA_HATSUON,
        KATAKANA_SOKUON,
        KATAKANA_VOICED,
        KATAKANA_VOICED_ITERATION_MARK,
        KATAKANA_SEMIVOICED,
        KANJI,
        KANJI_ITERATION_MARK
    }

    // Special characters that cannot be repeated
    private static final Set<Integer> HATSUON_CHARS =
            Set.of(
                    0x3093, // ん
                    0x30F3, // ン
                    0xFF9D // ﾝ (halfwidth)
                    );

    private static final Set<Integer> SOKUON_CHARS =
            Set.of(
                    0x3063, // っ
                    0x30C3, // ッ
                    0xFF6F // ｯ (halfwidth)
                    );

    // Semi-voiced characters
    private static final Set<String> SEMI_VOICED_CHARS =
            Set.of(
                    // Hiragana semi-voiced
                    "ぱ",
                    "ぴ",
                    "ぷ",
                    "ぺ",
                    "ぽ",
                    // Katakana semi-voiced
                    "パ",
                    "ピ",
                    "プ",
                    "ペ",
                    "ポ");

    // Voicing mappings for hiragana
    private static final Map<String, String> HIRAGANA_VOICING = new HashMap<>();

    static {
        HIRAGANA_VOICING.put("か", "が");
        HIRAGANA_VOICING.put("き", "ぎ");
        HIRAGANA_VOICING.put("く", "ぐ");
        HIRAGANA_VOICING.put("け", "げ");
        HIRAGANA_VOICING.put("こ", "ご");
        HIRAGANA_VOICING.put("さ", "ざ");
        HIRAGANA_VOICING.put("し", "じ");
        HIRAGANA_VOICING.put("す", "ず");
        HIRAGANA_VOICING.put("せ", "ぜ");
        HIRAGANA_VOICING.put("そ", "ぞ");
        HIRAGANA_VOICING.put("た", "だ");
        HIRAGANA_VOICING.put("ち", "ぢ");
        HIRAGANA_VOICING.put("つ", "づ");
        HIRAGANA_VOICING.put("て", "で");
        HIRAGANA_VOICING.put("と", "ど");
        HIRAGANA_VOICING.put("は", "ば");
        HIRAGANA_VOICING.put("ひ", "び");
        HIRAGANA_VOICING.put("ふ", "ぶ");
        HIRAGANA_VOICING.put("へ", "べ");
        HIRAGANA_VOICING.put("ほ", "ぼ");
    }

    // Voicing mappings for katakana
    private static final Map<String, String> KATAKANA_VOICING = new HashMap<>();

    static {
        KATAKANA_VOICING.put("カ", "ガ");
        KATAKANA_VOICING.put("キ", "ギ");
        KATAKANA_VOICING.put("ク", "グ");
        KATAKANA_VOICING.put("ケ", "ゲ");
        KATAKANA_VOICING.put("コ", "ゴ");
        KATAKANA_VOICING.put("サ", "ザ");
        KATAKANA_VOICING.put("シ", "ジ");
        KATAKANA_VOICING.put("ス", "ズ");
        KATAKANA_VOICING.put("セ", "ゼ");
        KATAKANA_VOICING.put("ソ", "ゾ");
        KATAKANA_VOICING.put("タ", "ダ");
        KATAKANA_VOICING.put("チ", "ヂ");
        KATAKANA_VOICING.put("ツ", "ヅ");
        KATAKANA_VOICING.put("テ", "デ");
        KATAKANA_VOICING.put("ト", "ド");
        KATAKANA_VOICING.put("ハ", "バ");
        KATAKANA_VOICING.put("ヒ", "ビ");
        KATAKANA_VOICING.put("フ", "ブ");
        KATAKANA_VOICING.put("ヘ", "ベ");
        KATAKANA_VOICING.put("ホ", "ボ");
        KATAKANA_VOICING.put("ウ", "ヴ");
    }

    // Derived set of all voiced characters (values from voicing maps)
    private static final Set<String> VOICED_CHARS;

    // Reverse voicing mappings (voiced to unvoiced)
    private static final Map<String, String> HIRAGANA_UNVOICING = new HashMap<>();
    private static final Map<String, String> KATAKANA_UNVOICING = new HashMap<>();

    static {
        Set<String> voiced = new HashSet<>();
        voiced.addAll(HIRAGANA_VOICING.values());
        voiced.addAll(KATAKANA_VOICING.values());
        VOICED_CHARS = Set.copyOf(voiced);

        // Create reverse mappings
        HIRAGANA_VOICING.forEach((k, v) -> HIRAGANA_UNVOICING.put(v, k));
        KATAKANA_VOICING.forEach((k, v) -> KATAKANA_UNVOICING.put(v, k));
    }

    /** Options for the transliterator. Currently unused but reserved for future use. */
    public static class Options {
        /** Creates a new Options instance with default settings. */
        public Options() {
            // Options reserved for future use
        }
    }

    private final Options options;

    /** Creates a new JapaneseIterationMarksTransliterator with default options. */
    public JapaneseIterationMarksTransliterator() {
        this(new Options());
    }

    /**
     * Creates a new JapaneseIterationMarksTransliterator with the specified options.
     *
     * @param options the options for configuring the transliterator behavior
     */
    public JapaneseIterationMarksTransliterator(Options options) {
        this.options = options;
    }

    /**
     * Transliterates the input by replacing Japanese iteration marks with repeated characters.
     *
     * @param input the input character iterator
     * @return a new character iterator with iteration marks replaced
     */
    @Override
    public CharIterator transliterate(CharIterator input) {
        return new JapaneseIterationMarksCharIterator(input, options);
    }

    /** Check if a character is an iteration mark. */
    private static boolean isIterationMark(int codepoint) {
        return codepoint == HIRAGANA_ITERATION_MARK
                || codepoint == HIRAGANA_VOICED_ITERATION_MARK
                || codepoint == VERTICAL_HIRAGANA_ITERATION_MARK
                || codepoint == VERTICAL_HIRAGANA_VOICED_ITERATION_MARK
                || codepoint == KATAKANA_ITERATION_MARK
                || codepoint == KATAKANA_VOICED_ITERATION_MARK
                || codepoint == VERTICAL_KATAKANA_ITERATION_MARK
                || codepoint == VERTICAL_KATAKANA_VOICED_ITERATION_MARK
                || codepoint == KANJI_ITERATION_MARK;
    }

    /** Get the character type for a given character. */
    private static CharType getCharType(String charStr) {
        if (charStr == null || charStr.isEmpty()) {
            return CharType.OTHER;
        }

        int codepoint = charStr.codePointAt(0);

        // Kanji - CJK Unified Ideographs (common ranges)
        if ((codepoint >= 0x4E00 && codepoint <= 0x9FFF)
                || (codepoint >= 0x3400 && codepoint <= 0x4DBF)
                || (codepoint >= 0x20000 && codepoint <= 0x2A6DF)
                || (codepoint >= 0x2A700 && codepoint <= 0x2B73F)
                || (codepoint >= 0x2B740 && codepoint <= 0x2B81F)
                || (codepoint >= 0x2B820 && codepoint <= 0x2CEAF)
                || (codepoint >= 0x2CEB0 && codepoint <= 0x2EBEF)
                || (codepoint >= 0x30000 && codepoint <= 0x3134F)) {
            return CharType.KANJI;
        }

        // Check specific characters
        switch (codepoint) {
            case 0x3071:
            case 0x3074:
            case 0x3077:
            case 0x307A:
            case 0x307D: // ぱ, ぴ, ぷ, ぺ, ぽ
                return CharType.HIRAGANA_SEMIVOICED;
            case 0x30D1:
            case 0x30D4:
            case 0x30D7:
            case 0x30DA:
            case 0x30DD: // パ, ピ, プ, ペ, ポ
                return CharType.KATAKANA_SEMIVOICED;
            case 0x3093: // ん
                return CharType.HIRAGANA_HATSUON;
            case 0x30F3: // ン
                return CharType.KATAKANA_HATSUON;
            case 0x3063: // っ
                return CharType.HIRAGANA_SOKUON;
            case 0x30C3: // ッ
                return CharType.KATAKANA_SOKUON;
            case 0x309D: // ゝ
            case 0x3031: // 〱 (vertical hiragana repeat mark)
                return CharType.HIRAGANA_ITERATION_MARK;
            case 0x309E: // ゞ
            case 0x3032: // 〲 (vertical hiragana voiced repeat mark)
                return CharType.HIRAGANA_VOICED_ITERATION_MARK;
            case 0x30FD: // ヽ
            case 0x3033: // 〳 (vertical katakana repeat mark)
                return CharType.KATAKANA_ITERATION_MARK;
            case 0x30FE: // ヾ
            case 0x3034: // 〴 (vertical katakana voiced repeat mark)
                return CharType.KATAKANA_VOICED_ITERATION_MARK;
            case 0x3005: // 々
                return CharType.KANJI_ITERATION_MARK;
        }

        // Check if it's voiced
        if (VOICED_CHARS.contains(charStr)) {
            // Determine if it's hiragana or katakana voiced
            if (codepoint >= 0x3041 && codepoint <= 0x3096) {
                return CharType.HIRAGANA_VOICED;
            } else if (codepoint >= 0x30A1 && codepoint <= 0x30FA) {
                return CharType.KATAKANA_VOICED;
            }
        }

        // Hiragana (excluding special marks)
        if (codepoint >= 0x3041 && codepoint <= 0x3096) {
            return CharType.HIRAGANA;
        }

        // Katakana (excluding special marks)
        if (codepoint >= 0x30A1 && codepoint <= 0x30FA) {
            return CharType.KATAKANA;
        }

        return CharType.OTHER;
    }

    private static class JapaneseIterationMarksCharIterator implements CharIterator {
        private final CharIterator input;
        private final Options options;
        private int offset = 0;
        private CharInfo prevCharInfo = null;
        private boolean prevWasIterationMark = false;
        private final List<Char> outputBuf = new ArrayList<>();

        private static class CharInfo {
            final String charStr;
            final CharType type;

            CharInfo(String charStr, CharType type) {
                this.charStr = charStr;
                this.type = type;
            }
        }

        public JapaneseIterationMarksCharIterator(CharIterator input, Options options) {
            this.input = input;
            this.options = options;
        }

        @Override
        public boolean hasNext() {
            return !outputBuf.isEmpty() || input.hasNext();
        }

        @Override
        public Char next() {
            if (!hasNext()) {
                throw new NoSuchElementException();
            }

            // If we have output characters buffered, return them first
            if (!outputBuf.isEmpty()) {
                return outputBuf.remove(0);
            }

            // Get next character from input
            Char character = input.next();
            if (character == null || character.isSentinel()) {
                return character;
            }

            String currentChar = character.get().toString();
            int codepoint = currentChar.isEmpty() ? -1 : currentChar.codePointAt(0);

            if (isIterationMark(codepoint)) {
                // Check if previous character was also an iteration mark
                if (prevWasIterationMark) {
                    // Don't replace consecutive iteration marks
                    Char result = character.withOffset(offset);
                    offset += result.charCount();
                    prevWasIterationMark = true;
                    return result;
                }

                // Try to replace the iteration mark
                String replacement = null;
                if (prevCharInfo != null) {
                    switch (codepoint) {
                        case HIRAGANA_ITERATION_MARK:
                        case VERTICAL_HIRAGANA_ITERATION_MARK:
                            // Repeat previous hiragana if valid
                            if (prevCharInfo.type == CharType.HIRAGANA) {
                                replacement = prevCharInfo.charStr;
                            } else if (prevCharInfo.type == CharType.HIRAGANA_VOICED) {
                                // Voiced character followed by unvoiced iteration mark
                                replacement = HIRAGANA_UNVOICING.get(prevCharInfo.charStr);
                            }
                            break;

                        case HIRAGANA_VOICED_ITERATION_MARK:
                        case VERTICAL_HIRAGANA_VOICED_ITERATION_MARK:
                            // Repeat previous hiragana with voicing if possible
                            if (prevCharInfo.type == CharType.HIRAGANA) {
                                replacement = HIRAGANA_VOICING.get(prevCharInfo.charStr);
                            } else if (prevCharInfo.type == CharType.HIRAGANA_VOICED) {
                                // Voiced character followed by voiced iteration mark
                                replacement = prevCharInfo.charStr;
                            }
                            break;

                        case KATAKANA_ITERATION_MARK:
                        case VERTICAL_KATAKANA_ITERATION_MARK:
                            // Repeat previous katakana if valid
                            if (prevCharInfo.type == CharType.KATAKANA) {
                                replacement = prevCharInfo.charStr;
                            } else if (prevCharInfo.type == CharType.KATAKANA_VOICED) {
                                // Voiced character followed by unvoiced iteration mark
                                replacement = KATAKANA_UNVOICING.get(prevCharInfo.charStr);
                            }
                            break;

                        case KATAKANA_VOICED_ITERATION_MARK:
                        case VERTICAL_KATAKANA_VOICED_ITERATION_MARK:
                            // Repeat previous katakana with voicing if possible
                            if (prevCharInfo.type == CharType.KATAKANA) {
                                replacement = KATAKANA_VOICING.get(prevCharInfo.charStr);
                            } else if (prevCharInfo.type == CharType.KATAKANA_VOICED) {
                                // Voiced character followed by voiced iteration mark
                                replacement = prevCharInfo.charStr;
                            }
                            break;

                        case KANJI_ITERATION_MARK:
                            // Repeat previous kanji
                            if (prevCharInfo.type == CharType.KANJI) {
                                replacement = prevCharInfo.charStr;
                            }
                            break;
                    }
                }

                if (replacement != null) {
                    // Replace the iteration mark
                    Char result = new Char(CodePointTuple.of(replacement), offset, character);
                    offset += result.charCount();
                    prevWasIterationMark = true;
                    // Keep the original prevCharInfo - don't update it
                    return result;
                } else {
                    // Couldn't replace the iteration mark
                    Char result = character.withOffset(offset);
                    offset += result.charCount();
                    prevWasIterationMark = true;
                    return result;
                }
            } else {
                // Not an iteration mark
                Char result = character.withOffset(offset);
                offset += result.charCount();

                // Update previous character info
                CharType charType = getCharType(currentChar);
                if (charType != CharType.OTHER) {
                    prevCharInfo = new CharInfo(currentChar, charType);
                } else {
                    prevCharInfo = null;
                }

                prevWasIterationMark = false;
                return result;
            }
        }
    }
}
