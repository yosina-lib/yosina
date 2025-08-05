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
import java.util.Collections;
import java.util.Map;
import java.util.TreeMap;

/** Auto-generated transliterator for RadicalsTransliterator. */
@RegisteredTransliterator(name = "radicals")
public class RadicalsTransliterator implements Transliterator {
    private static final Map<CodePointTuple, CodePointTuple> mappings;

    static {
        final Map<CodePointTuple, CodePointTuple> mappings_ = new TreeMap<>();
        final ByteBuffer b;
        try {
            try (final InputStream s =
                    RadicalsTransliterator.class.getResourceAsStream("radicals.data")) {
                b = ByteBuffer.wrap(s.readAllBytes()).order(ByteOrder.BIG_ENDIAN);
            }
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        while (b.hasRemaining()) {
            final int key1 = b.getInt(), key2 = b.getInt();
            final int value1 = b.getInt(), value2 = b.getInt();
            final CodePointTuple key = CodePointTuple.of(key1, key2);
            final CodePointTuple value = CodePointTuple.of(value1, value2);
            mappings_.put(key, value);
        }
        mappings = Collections.unmodifiableMap(mappings_);
    }

    @Override
    public CharIterator transliterate(CharIterator input) {
        return new SimpleCharIterator(input, mappings);
    }
}
