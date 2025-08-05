package io.yosina.transliterators;

import io.yosina.CharIterator;
import io.yosina.CodePointTuple;
import io.yosina.Transliterator;
import io.yosina.annotations.RegisteredTransliterator;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/**
 * Auto-generated transliterator for Combined. Replace single characters with arrays of characters.
 */
@RegisteredTransliterator(name = "combined")
public class Combined implements Transliterator {
    private static final Map<CodePointTuple, int[]> mappings;

    static {
        final Map<CodePointTuple, int[]> mappings_ = new TreeMap<>();
        final ByteBuffer b;
        try {
            try (final InputStream s = Combined.class.getResourceAsStream("combined.data")) {
                b = ByteBuffer.wrap(s.readAllBytes()).order(ByteOrder.BIG_ENDIAN);
            }
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        while (b.hasRemaining()) {
            final int key1 = b.getInt(), key2 = b.getInt();
            final int length = b.getInt();
            final int[] value = new int[length];
            for (int i = 0; i < length; i++) {
                value[i] = b.getInt();
            }
            mappings_.put(CodePointTuple.of(key1, key2), value);
        }
        mappings = Collections.unmodifiableMap(mappings_);
    }

    private static class CombinedCharIterator implements CharIterator {
        private final CharIterator input;
        private final Map<CodePointTuple, int[]> mappings;
        private final List<io.yosina.Char> queue = new ArrayList<>();
        private int queueIndex = 0;

        public CombinedCharIterator(CharIterator input, Map<CodePointTuple, int[]> mappings) {
            this.input = input;
            this.mappings = mappings;
        }

        @Override
        public io.yosina.Char next() {
            // Return queued characters first
            if (queueIndex < queue.size()) {
                return queue.get(queueIndex++);
            }

            // Reset queue for new character
            queue.clear();
            queueIndex = 0;

            if (!input.hasNext()) {
                return null;
            }

            io.yosina.Char ch = input.next();
            if (ch.isSentinel()) {
                return ch;
            }

            int[] replacement = mappings.get(ch.get());
            if (replacement != null) {
                // Create new characters for each replacement
                for (int i = 0; i < replacement.length; i++) {
                    queue.add(
                            new io.yosina.Char(
                                    CodePointTuple.of(replacement[i], -1), ch.getOffset() + i, ch));
                }
                return queue.get(queueIndex++);
            } else {
                return ch;
            }
        }

        @Override
        public boolean hasNext() {
            return queueIndex < queue.size() || input.hasNext();
        }
    }

    @Override
    public CharIterator transliterate(CharIterator input) {
        return new CombinedCharIterator(input, mappings);
    }

    /** Creates a new Combined transliterator. */
    public Combined() {}
}
