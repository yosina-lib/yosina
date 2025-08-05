package io.yosina.transliterators;

import io.yosina.Char;
import io.yosina.CharIterator;
import io.yosina.CodePointTuple;
import io.yosina.Transliterator;
import io.yosina.annotations.RegisteredTransliterator;
import java.util.HashMap;
import java.util.Map;

/** Transliterator for converting between Hiragana and Katakana scripts. */
@RegisteredTransliterator(name = "hira-kata")
public class HiraKataTransliterator implements Transliterator {
    /** Options for configuring the behavior of HiraKataTransliterator. */
    public static class Options {
        private final Mode mode;

        /** Conversion mode. */
        public enum Mode {
            /** Convert Hiragana to Katakana */
            HIRA_TO_KATA,
            /** Convert Katakana to Hiragana */
            KATA_TO_HIRA
        }

        /**
         * Creates a new Options instance with the specified mode.
         *
         * @param mode the conversion mode
         */
        public Options(Mode mode) {
            this.mode = mode;
        }

        /**
         * Gets the conversion mode.
         *
         * @return the conversion mode
         */
        public Mode getMode() {
            return mode;
        }
    }

    // Class-level cache for mapping tables (package-private for testing)
    static final Map<Options.Mode, Map<Integer, Integer>> mappingCache = new HashMap<>();

    private final Map<Integer, Integer> mappingTable;

    /**
     * Creates a new HiraKataTransliterator with the specified options.
     *
     * @param options the transliterator options
     */
    public HiraKataTransliterator(Options options) {
        this.mappingTable = getMappingTable(options.getMode());
    }

    /** Default constructor uses hira-to-kata mode. */
    public HiraKataTransliterator() {
        this(new Options(Options.Mode.HIRA_TO_KATA));
    }

    private static synchronized Map<Integer, Integer> getMappingTable(Options.Mode mode) {
        // Check cache first
        Map<Integer, Integer> cached = mappingCache.get(mode);
        if (cached != null) {
            return cached;
        }

        Map<Integer, Integer> mapping = new HashMap<>();

        // Main table mappings
        for (HiraKataTable.HiraKataEntry entry : HiraKataTable.HIRAGANA_KATAKANA_TABLE) {
            if (entry.hiragana.isPresent()) {
                HiraKataTable.HiraKata hira = entry.hiragana.get();
                HiraKataTable.HiraKata kata = entry.katakana;

                if (mode == Options.Mode.HIRA_TO_KATA) {
                    mapping.put(hira.base, kata.base);
                    if (hira.voiced >= 0 && kata.voiced >= 0) {
                        mapping.put(hira.voiced, kata.voiced);
                    }
                    if (hira.semivoiced >= 0 && kata.semivoiced >= 0) {
                        mapping.put(hira.semivoiced, kata.semivoiced);
                    }
                } else {
                    mapping.put(kata.base, hira.base);
                    if (kata.voiced >= 0 && hira.voiced >= 0) {
                        mapping.put(kata.voiced, hira.voiced);
                    }
                    if (kata.semivoiced >= 0 && hira.semivoiced >= 0) {
                        mapping.put(kata.semivoiced, hira.semivoiced);
                    }
                }
            }
        }

        // Small character mappings
        for (HiraKataTable.SmallKanaEntry entry : HiraKataTable.HIRAGANA_KATAKANA_SMALL_TABLE) {
            if (mode == Options.Mode.HIRA_TO_KATA) {
                mapping.put(entry.hiragana, entry.katakana);
            } else {
                mapping.put(entry.katakana, entry.hiragana);
            }
        }

        // Cache the result
        mappingCache.put(mode, mapping);
        return mapping;
    }

    @Override
    public CharIterator transliterate(CharIterator inputChars) {
        return new CharIterator() {
            @Override
            public boolean hasNext() {
                return inputChars.hasNext();
            }

            @Override
            public Char next() {
                Char ch = inputChars.next();
                CodePointTuple tuple = ch.get();
                if (tuple.size() == 1) {
                    int codePoint = tuple.get(0);
                    Integer mapped = mappingTable.get(codePoint);

                    if (mapped != null) {
                        return new Char(CodePointTuple.of(mapped), ch.getOffset(), ch);
                    }
                }
                return ch;
            }
        };
    }
}
