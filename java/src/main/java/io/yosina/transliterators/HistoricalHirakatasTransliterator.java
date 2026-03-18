package io.yosina.transliterators;

import io.yosina.Char;
import io.yosina.CharIterator;
import io.yosina.CodePointTuple;
import io.yosina.Transliterator;
import io.yosina.annotations.RegisteredTransliterator;
import java.util.NoSuchElementException;
import java.util.Objects;

/**
 * Historical hiragana/katakana transliterator.
 *
 * <p>This transliterator converts historical hiragana and katakana characters to their modern
 * equivalents. It supports three conversion modes for each character category:
 *
 * <ul>
 *   <li>SIMPLE: replaces historical characters with their closest modern equivalents
 *   <li>DECOMPOSE: replaces historical characters with decomposed modern equivalents
 *   <li>SKIP: leaves historical characters unchanged
 * </ul>
 *
 * <p>Historical hiragana mappings:
 *
 * <ul>
 *   <li>{@code ゐ} (U+3090) -> {@code い} (simple) / {@code うぃ} (decompose)
 *   <li>{@code ゑ} (U+3091) -> {@code え} (simple) / {@code うぇ} (decompose)
 * </ul>
 *
 * <p>Historical katakana mappings:
 *
 * <ul>
 *   <li>{@code ヰ} (U+30F0) -> {@code イ} (simple) / {@code ウィ} (decompose)
 *   <li>{@code ヱ} (U+30F1) -> {@code エ} (simple) / {@code ウェ} (decompose)
 * </ul>
 *
 * <p>Voiced historical kana mappings (decompose only):
 *
 * <ul>
 *   <li>{@code ヷ} (U+30F7) -> {@code ヴァ}
 *   <li>{@code ヸ} (U+30F8) -> {@code ヴィ}
 *   <li>{@code ヹ} (U+30F9) -> {@code ヴェ}
 *   <li>{@code ヺ} (U+30FA) -> {@code ヴォ}
 * </ul>
 */
@RegisteredTransliterator(name = "historical-hirakatas")
public class HistoricalHirakatasTransliterator implements Transliterator {

    /** Conversion mode for historical kana characters. */
    public enum ConversionMode {
        /** Replace with the closest modern equivalent. */
        SIMPLE,
        /** Replace with decomposed modern equivalent. */
        DECOMPOSE,
        /** Leave historical characters unchanged. */
        SKIP
    }

    /** Options for configuring the behavior of HistoricalHirakatasTransliterator. */
    public static class Options {
        private final ConversionMode hiraganas;
        private final ConversionMode katakanas;
        private final ConversionMode voicedKatakanas;

        /** Creates a new Options instance with default settings. */
        public Options() {
            this(ConversionMode.SIMPLE, ConversionMode.SIMPLE, ConversionMode.SKIP);
        }

        /**
         * Creates a new Options instance with the specified settings.
         *
         * @param hiraganas the conversion mode for historical hiragana
         * @param katakanas the conversion mode for historical katakana
         * @param voicedKatakanas the conversion mode for voiced historical kana
         */
        public Options(
                ConversionMode hiraganas,
                ConversionMode katakanas,
                ConversionMode voicedKatakanas) {
            this.hiraganas = hiraganas;
            this.katakanas = katakanas;
            this.voicedKatakanas = voicedKatakanas;
        }

        /**
         * Returns the conversion mode for historical hiragana.
         *
         * @return the conversion mode for historical hiragana
         */
        public ConversionMode getHiraganas() {
            return hiraganas;
        }

        /**
         * Returns the conversion mode for historical katakana.
         *
         * @return the conversion mode for historical katakana
         */
        public ConversionMode getKatakanas() {
            return katakanas;
        }

        /**
         * Returns the conversion mode for voiced historical kana.
         *
         * @return the conversion mode for voiced historical kana
         */
        public ConversionMode getVoicedKatakanas() {
            return voicedKatakanas;
        }

        /**
         * Creates a new Options instance with the specified historical hiragana conversion mode.
         *
         * @param mode the conversion mode for historical hiragana
         * @return a new Options instance with the updated setting
         */
        public Options withHiraganas(ConversionMode mode) {
            return new Options(mode, this.katakanas, this.voicedKatakanas);
        }

        /**
         * Creates a new Options instance with the specified historical katakana conversion mode.
         *
         * @param mode the conversion mode for historical katakana
         * @return a new Options instance with the updated setting
         */
        public Options withKatakanas(ConversionMode mode) {
            return new Options(this.hiraganas, mode, this.voicedKatakanas);
        }

        /**
         * Creates a new Options instance with the specified voiced historical kana conversion mode.
         *
         * @param mode the conversion mode for voiced historical kana
         * @return a new Options instance with the updated setting
         */
        public Options withVoicedKatakanas(ConversionMode mode) {
            return new Options(this.hiraganas, this.katakanas, mode);
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            Options options = (Options) obj;
            return hiraganas == options.hiraganas
                    && katakanas == options.katakanas
                    && voicedKatakanas == options.voicedKatakanas;
        }

        @Override
        public int hashCode() {
            return Objects.hash(hiraganas, katakanas, voicedKatakanas);
        }
    }

    // Historical hiragana code points
    private static final int WI_HIRAGANA = 0x3090; // ゐ
    private static final int WE_HIRAGANA = 0x3091; // ゑ

    // Historical katakana code points
    private static final int WI_KATAKANA = 0x30F0; // ヰ
    private static final int WE_KATAKANA = 0x30F1; // ヱ

    // Base katakana that compose with combining dakuten to form voiced historical kana
    private static final int WA_KATAKANA = 0x30EF; // ワ
    private static final int WO_KATAKANA = 0x30F2; // ヲ
    private static final int COMBINING_DAKUTEN = 0x3099; // ゙

    // Voiced historical katakana code points
    private static final int VA_KATAKANA = 0x30F7; // ヷ
    private static final int VI_KATAKANA = 0x30F8; // ヸ
    private static final int VE_KATAKANA = 0x30F9; // ヹ
    private static final int VO_KATAKANA = 0x30FA; // ヺ

    // Simple replacements
    private static final CodePointTuple SIMPLE_I_HIRAGANA = CodePointTuple.of(0x3044); // い
    private static final CodePointTuple SIMPLE_E_HIRAGANA = CodePointTuple.of(0x3048); // え
    private static final CodePointTuple SIMPLE_I_KATAKANA = CodePointTuple.of(0x30A4); // イ
    private static final CodePointTuple SIMPLE_E_KATAKANA = CodePointTuple.of(0x30A8); // エ

    // Decomposed replacements
    private static final CodePointTuple DECOMPOSE_WI_HIRAGANA =
            CodePointTuple.of(0x3046, 0x3043); // うぃ
    private static final CodePointTuple DECOMPOSE_WE_HIRAGANA =
            CodePointTuple.of(0x3046, 0x3047); // うぇ
    private static final CodePointTuple DECOMPOSE_WI_KATAKANA =
            CodePointTuple.of(0x30A6, 0x30A3); // ウィ
    private static final CodePointTuple DECOMPOSE_WE_KATAKANA =
            CodePointTuple.of(0x30A6, 0x30A7); // ウェ

    // Voiced historical replacements (decompose only, for composed input)
    // VU prefix is emitted separately; these are just the small vowel suffixes.
    private static final int VU_KATAKANA = 0x30F4; // ヴ
    private static final int U_KATAKANA = 0x30A6; // ウ
    private static final CodePointTuple VU_TUPLE = CodePointTuple.of(VU_KATAKANA);
    private static final CodePointTuple U_TUPLE = CodePointTuple.of(U_KATAKANA);

    private static int getVoicedVowel(int composedCodePoint) {
        switch (composedCodePoint) {
            case VA_KATAKANA:
                return 0x30A1; // ァ
            case VI_KATAKANA:
                return 0x30A3; // ィ
            case VE_KATAKANA:
                return 0x30A7; // ェ
            case VO_KATAKANA:
                return 0x30A9; // ォ
            default:
                return -1;
        }
    }

    private static int getDecomposedVowel(int base) {
        switch (base) {
            case WA_KATAKANA:
                return 0x30A1; // ァ
            case WI_KATAKANA:
                return 0x30A3; // ィ
            case WE_KATAKANA:
                return 0x30A7; // ェ
            case WO_KATAKANA:
                return 0x30A9; // ォ
            default:
                return -1;
        }
    }

    private final Options options;

    /** Creates a new HistoricalHirakatasTransliterator with default options. */
    public HistoricalHirakatasTransliterator() {
        this(new Options());
    }

    /**
     * Creates a new HistoricalHirakatasTransliterator with the specified options.
     *
     * @param options the options for configuring the transliterator behavior
     */
    public HistoricalHirakatasTransliterator(Options options) {
        this.options = options;
    }

    /**
     * Transliterates the input by converting historical hiragana/katakana characters.
     *
     * @param input the input character iterator
     * @return a new character iterator with converted characters
     */
    @Override
    public CharIterator transliterate(CharIterator input) {
        return new HistoricalHirakatasCharIterator(input, options);
    }

    private static class HistoricalHirakatasCharIterator implements CharIterator {
        private final CharIterator input;
        private final Options options;
        private int offset = 0;
        private Char pending = null;
        private final java.util.ArrayDeque<Char> queue = new java.util.ArrayDeque<>();

        public HistoricalHirakatasCharIterator(CharIterator input, Options options) {
            this.input = input;
            this.options = options;
        }

        @Override
        public boolean hasNext() {
            return !queue.isEmpty() || pending != null || input.hasNext();
        }

        @Override
        public Char next() {
            if (!hasNext()) {
                throw new NoSuchElementException();
            }

            // Drain queued chars first
            if (!queue.isEmpty()) {
                return queue.poll();
            }

            final Char c;
            if (pending != null) {
                c = pending;
                pending = null;
            } else {
                c = input.next();
            }
            if (c == null || c.isSentinel()) {
                return c;
            }

            final CodePointTuple cpt = c.get();
            if (cpt.size() != 1) {
                Char result = c.withOffset(offset);
                offset += result.charCount();
                return result;
            }

            final int codePoint = cpt.get(0);

            // Lookahead: peek at next char for combining dakuten
            if (input.hasNext()) {
                Char nextChar = input.next();
                if (nextChar != null
                        && !nextChar.isSentinel()
                        && nextChar.get().size() == 1
                        && nextChar.get().get(0) == COMBINING_DAKUTEN) {
                    // Check if current char is a decomposed voiced base
                    int vowel = getDecomposedVowel(codePoint);
                    if (vowel != -1 && options.voicedKatakanas == ConversionMode.DECOMPOSE) {
                        // decompose mode: emit U + dakuten + vowel
                        Char resultU = new Char(U_TUPLE, offset, c);
                        offset += U_TUPLE.charCount();
                        Char dakutenChar = nextChar.withOffset(offset);
                        offset += dakutenChar.charCount();
                        queue.add(dakutenChar);
                        CodePointTuple vowelTuple = CodePointTuple.of(vowel);
                        Char vowelChar = new Char(vowelTuple, offset, c);
                        offset += vowelTuple.charCount();
                        queue.add(vowelChar);
                        return resultU;
                    } else {
                        // skip mode or not a voiced base: store dakuten in pending, return base
                        // unchanged
                        pending = nextChar;
                        Char result = c.withOffset(offset);
                        offset += result.charCount();
                        return result;
                    }
                } else {
                    // Next char is not dakuten, store it in pending
                    pending = nextChar;
                }
            }

            final CodePointTuple replacement = getReplacement(codePoint);

            if (replacement != null) {
                Char result = new Char(replacement, offset, c);
                offset += replacement.charCount();
                return result;
            }

            Char result = c.withOffset(offset);
            offset += result.charCount();
            return result;
        }

        private CodePointTuple getReplacement(int codePoint) {
            switch (codePoint) {
                // Historical hiragana
                case WI_HIRAGANA:
                    return getHistoricalHiraganaReplacement(
                            SIMPLE_I_HIRAGANA, DECOMPOSE_WI_HIRAGANA);
                case WE_HIRAGANA:
                    return getHistoricalHiraganaReplacement(
                            SIMPLE_E_HIRAGANA, DECOMPOSE_WE_HIRAGANA);

                // Historical katakana
                case WI_KATAKANA:
                    return getHistoricalKatakanaReplacement(
                            SIMPLE_I_KATAKANA, DECOMPOSE_WI_KATAKANA);
                case WE_KATAKANA:
                    return getHistoricalKatakanaReplacement(
                            SIMPLE_E_KATAKANA, DECOMPOSE_WE_KATAKANA);

                // Voiced historical katakana
                case VA_KATAKANA:
                case VI_KATAKANA:
                case VE_KATAKANA:
                case VO_KATAKANA:
                    return getVoicedHistoricalReplacement(codePoint);

                default:
                    return null;
            }
        }

        private CodePointTuple getHistoricalHiraganaReplacement(
                CodePointTuple simple, CodePointTuple decompose) {
            switch (options.hiraganas) {
                case SIMPLE:
                    return simple;
                case DECOMPOSE:
                    return decompose;
                case SKIP:
                default:
                    return null;
            }
        }

        private CodePointTuple getHistoricalKatakanaReplacement(
                CodePointTuple simple, CodePointTuple decompose) {
            switch (options.katakanas) {
                case SIMPLE:
                    return simple;
                case DECOMPOSE:
                    return decompose;
                case SKIP:
                default:
                    return null;
            }
        }

        private CodePointTuple getVoicedHistoricalReplacement(int codePoint) {
            if (options.voicedKatakanas != ConversionMode.DECOMPOSE) {
                return null;
            }
            int vowel = getVoicedVowel(codePoint);
            if (vowel == -1) {
                return null;
            }
            return CodePointTuple.of(VU_KATAKANA, vowel);
        }
    }
}
