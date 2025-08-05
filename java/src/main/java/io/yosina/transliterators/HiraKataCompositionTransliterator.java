package io.yosina.transliterators;

import io.yosina.Char;
import io.yosina.CharIterator;
import io.yosina.CodePointTuple;
import io.yosina.Transliterator;
import io.yosina.annotations.RegisteredTransliterator;
import java.util.NoSuchElementException;

/** Transliterator for combining hiragana and katakana with voiced/semi-voiced marks. */
@RegisteredTransliterator(name = "hira-kata-composition")
public class HiraKataCompositionTransliterator implements Transliterator {
    private static final int VOICED = 1;
    private static final int SEMI_VOICED = 2;

    private static final long[] compositionTable;

    static {
        final long[] compositionTable_ = new long[256];
        final HiraKataTable.HiraKataEntry[] entries = HiraKataTable.HIRAGANA_KATAKANA_TABLE;
        for (HiraKataTable.HiraKataEntry entry : entries) {
            if (entry.hiragana.isPresent()) {
                final HiraKataTable.HiraKata hiragana = entry.hiragana.get();
                final int base = hiragana.base;
                final int voiced = hiragana.voiced;
                final int semiVoiced = hiragana.semivoiced;
                compositionTable_[base - 0x3000] =
                        (((long) (voiced >= 0 ? voiced : 0)) << 40)
                                | (((long) (semiVoiced >= 0 ? semiVoiced : 0)) << 16);
            }
            {
                final HiraKataTable.HiraKata katakana = entry.katakana;
                final int base = katakana.base;
                final int voiced = katakana.voiced;
                final int semiVoiced = katakana.semivoiced;
                compositionTable_[base - 0x3000] =
                        (((long) (voiced >= 0 ? voiced : 0)) << 40)
                                | (((long) (semiVoiced >= 0 ? semiVoiced : 0)) << 16);
            }
        }
        // Add iteration marks
        compositionTable_[0x309d - 0x3000] = (0x309eL << 40);
        compositionTable_[0x30fd - 0x3000] = (0x30feL << 40);
        // Add vertical iteration marks
        compositionTable_[0x3031 - 0x3000] =
                (0x3032L << 40); // U+3031 -> U+3032 (vertical hiragana)
        compositionTable_[0x3033 - 0x3000] =
                (0x3034L << 40); // U+3033 -> U+3034 (vertical katakana)
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
