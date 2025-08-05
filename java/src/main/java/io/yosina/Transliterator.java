package io.yosina;

/** Interface for character transformation. */
@FunctionalInterface
public interface Transliterator {
    /**
     * Transliterates the input character iterator.
     *
     * @param input the input character iterator
     * @return the transliterated character iterator
     */
    CharIterator transliterate(CharIterator input);
}
