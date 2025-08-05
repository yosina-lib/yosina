package io.yosina;

import java.util.List;

/** Applies multiple transliterators in sequence. */
public class ChainedTransliterator implements Transliterator {
    private final List<Transliterator> transliterators;

    /**
     * Creates a new ChainedTransliterator with the specified transliterators.
     *
     * @param transliterators the list of transliterators to apply in sequence
     */
    public ChainedTransliterator(List<Transliterator> transliterators) {
        this.transliterators = List.copyOf(transliterators);
    }

    /**
     * Creates a new ChainedTransliterator with the specified transliterators.
     *
     * @param transliterators the transliterators to apply in sequence
     */
    public ChainedTransliterator(Transliterator... transliterators) {
        this.transliterators = List.of(transliterators);
    }

    @Override
    public CharIterator transliterate(CharIterator input) {
        CharIterator current = input;
        for (Transliterator transliterator : transliterators) {
            current = transliterator.transliterate(current);
        }
        return current;
    }
}
