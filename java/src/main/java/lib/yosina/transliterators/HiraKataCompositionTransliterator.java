package lib.yosina.transliterators;

import java.util.NoSuchElementException;
import lib.yosina.Char;
import lib.yosina.CharIterator;
import lib.yosina.CodePointTuple;
import lib.yosina.Transliterator;
import lib.yosina.annotations.RegisteredTransliterator;

/** Transliterator for combining hiragana and katakana with voiced/semi-voiced marks. */
@RegisteredTransliterator(name = "hira-kata-composition")
public class HiraKataCompositionTransliterator implements Transliterator {
    private static final int VOICED = 1;
    private static final int SEMI_VOICED = 2;

    private static final long[] compositionTable;

    private static final int[] entries = {
        0x304b, 0x304c, 0,
        0x304d, 0x304e, 0,
        0x304f, 0x3050, 0,
        0x3051, 0x3052, 0,
        0x3053, 0x3054, 0,
        0x3055, 0x3056, 0,
        0x3057, 0x3058, 0,
        0x3059, 0x305a, 0,
        0x305b, 0x305c, 0,
        0x305d, 0x305e, 0,
        0x305f, 0x3060, 0,
        0x3061, 0x3062, 0,
        0x3064, 0x3065, 0,
        0x3066, 0x3067, 0,
        0x3068, 0x3069, 0,
        0x306f, 0x3070, 0x3071,
        0x3072, 0x3073, 0x3074,
        0x3075, 0x3076, 0x3077,
        0x3078, 0x3079, 0x307a,
        0x307b, 0x307c, 0x307d,
        0x3046, 0x3094, 0,
        0x309d, 0x309e, 0,
        0x30ab, 0x30ac, 0,
        0x30ad, 0x30ae, 0,
        0x30af, 0x30b0, 0,
        0x30b1, 0x30b2, 0,
        0x30b3, 0x30b4, 0,
        0x30b5, 0x30b6, 0,
        0x30b7, 0x30b8, 0,
        0x30b9, 0x30ba, 0,
        0x30bb, 0x30bc, 0,
        0x30bd, 0x30be, 0,
        0x30bf, 0x30c0, 0,
        0x30c1, 0x30c2, 0,
        0x30c4, 0x30c5, 0,
        0x30c6, 0x30c7, 0,
        0x30c8, 0x30c9, 0,
        0x30cf, 0x30d0, 0x30d1,
        0x30d2, 0x30d3, 0x30d4,
        0x30d5, 0x30d6, 0x30d7,
        0x30d8, 0x30d9, 0x30da,
        0x30db, 0x30dc, 0x30dd,
        0x30a6, 0x30f4, 0,
        0x30ef, 0x30f7, 0,
        0x30f0, 0x30f8, 0,
        0x30f1, 0x30f9, 0,
        0x30f2, 0x30fa, 0,
        0x30fd, 0x30fe, 0,
    };

    static {
        final long[] compositionTable_ = new long[entries[entries.length - 3] - 0x3000 + 1];
        for (int i = 0; i < entries.length; i += 3) {
            final int base = entries[i];
            final int voiced = entries[i + 1];
            final int semiVoiced = entries[i + 2];
            compositionTable_[base - 0x3000] =
                    (((long) voiced) << 40) | (((long) semiVoiced) << 16);
        }
        compositionTable = compositionTable_;
    }

    /** Options for configuring the behavior of HiraKataCompositionTransliterator. */
    public static class Options {
        private final boolean composeNonCombiningMarks;

        /**
         * Creates a new Options instance with default settings. By default, non-combining marks are
         * not composed.
         */
        public Options() {
            this(false);
        }

        /**
         * Creates a new Options instance with the specified settings.
         *
         * @param composeNonCombiningMarks if true, non-combining voiced/semi-voiced marks (U+309B
         *     and U+309C) will also be composed
         */
        public Options(boolean composeNonCombiningMarks) {
            this.composeNonCombiningMarks = composeNonCombiningMarks;
        }

        /**
         * Returns whether non-combining marks should be composed.
         *
         * @return true if non-combining marks should be composed, false otherwise
         */
        public boolean isComposeNonCombiningMarks() {
            return composeNonCombiningMarks;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            Options options = (Options) obj;
            return composeNonCombiningMarks == options.composeNonCombiningMarks;
        }

        @Override
        public int hashCode() {
            return Boolean.hashCode(composeNonCombiningMarks);
        }
    }

    private final Options options;

    /** Creates a new HiraKataCompositionTransliterator with default options. */
    public HiraKataCompositionTransliterator() {
        this(new Options());
    }

    /**
     * Creates a new HiraKataCompositionTransliterator with the specified options.
     *
     * @param options the options for configuring the transliterator behavior
     */
    public HiraKataCompositionTransliterator(Options options) {
        this.options = options;
    }

    /**
     * Transliterates the input by composing hiragana/katakana characters with voiced/semi-voiced
     * marks.
     *
     * @param input the input character iterator
     * @return a new character iterator with composed characters
     */
    @Override
    public CharIterator transliterate(CharIterator input) {
        return new HiraKataCompositionCharIterator(input, options);
    }

    private static class HiraKataCompositionCharIterator implements CharIterator {
        private final CharIterator input;
        private final Options options;
        private Char pending;
        private int offset = 0;

        public HiraKataCompositionCharIterator(CharIterator input, Options options) {
            this.input = input;
            this.options = options;
        }

        private long canBeComposed(CodePointTuple c) {
            if (c.size() != 1) {
                return 0;
            }
            final int codePoint = c.get(0);
            final int i = codePoint - 0x3000;
            if (i < 0 || i >= compositionTable.length) {
                return 0;
            }
            return compositionTable[i];
        }

        private int isSoundMark(CodePointTuple c) {
            if (c.size() != 1) {
                return 0;
            }
            final int codePoint = c.get(0);
            switch (codePoint) {
                case 0x3099: // U+3099 (combining voiced sound mark)
                    return VOICED;
                case 0x309a: // U+309A (combining semi-voiced sound mark)
                    return SEMI_VOICED;
                case 0x309b: // U+309B (non-combining voiced sound mark)
                    return options.composeNonCombiningMarks ? VOICED : 0;
                case 0x309c: // U+309C (non-combining semi-voiced sound mark)
                    return options.composeNonCombiningMarks ? SEMI_VOICED : 0;
                default:
                    return 0;
            }
        }

        @Override
        public boolean hasNext() {
            return pending != null || input.hasNext();
        }

        @Override
        public Char next() {
            if (!hasNext()) {
                throw new NoSuchElementException();
            }

            final Char c;
            if (pending != null) {
                c = pending;
                pending = null;
            } else {
                c = input.next();
            }

            if (c.isSentinel()) {
                return c.withOffset(offset);
            }

            // Check if current character can be the first part of a composition
            final long cc = canBeComposed(c.get());
            if (cc != 0) {
                if (input.hasNext()) {
                    final Char nc = input.next();
                    final int m = isSoundMark(nc.get());
                    final int composed = ((int) (cc >>> (64 - 24 * m))) & 0xffff;
                    if (composed != 0) {
                        final Char result = new Char(CodePointTuple.of(composed), offset, c);
                        offset += result.charCount();
                        return result;
                    }
                    // No composition found, set next as pending
                    pending = nc;
                }
            }

            final Char result = c.withOffset(offset);
            offset += result.charCount();
            return result;
        }
    }
}
