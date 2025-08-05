package io.yosina.transliterators;

import io.yosina.Char;
import io.yosina.CharIterator;
import io.yosina.CodePointTuple;
import java.util.Map;
import java.util.NoSuchElementException;

/**
 * A simple character iterator that translates characters based on a mapping table. This class is
 * used by various transliterators for simple one-to-one character mappings.
 */
public class SimpleCharIterator implements CharIterator {
    private final CharIterator input;
    private final Map<CodePointTuple, CodePointTuple> mappings;
    private int offset = 0;

    /**
     * Creates a new SimpleCharIterator with the specified input and character mappings.
     *
     * @param input the source character iterator
     * @param mappings the character mapping table
     */
    public SimpleCharIterator(CharIterator input, Map<CodePointTuple, CodePointTuple> mappings) {
        this.input = input;
        this.mappings = mappings;
    }

    @Override
    public boolean hasNext() {
        return input.hasNext();
    }

    @Override
    public Char next() {
        for (; ; ) {
            if (!hasNext()) {
                throw new NoSuchElementException();
            }

            final Char c = input.next();
            if (c == null) {
                return null;
            }

            final CodePointTuple replacement = mappings.get(c.get());
            if (replacement != null) {
                if (replacement.isEmpty()) {
                    continue;
                }
                Char result = new Char(replacement, offset, c);
                offset += replacement.charCount();
                return result;
            } else {
                Char result = c.withOffset(offset);
                offset += c.charCount();
                return result;
            }
        }
    }

    @Override
    public long estimateSize() {
        return input.estimateSize();
    }
}
