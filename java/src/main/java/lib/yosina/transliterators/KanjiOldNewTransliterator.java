package lib.yosina.transliterators;

import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Collections;
import java.util.Map;
import java.util.TreeMap;
import lib.yosina.CharIterator;
import lib.yosina.CodePointTuple;
import lib.yosina.Transliterator;
import lib.yosina.annotations.RegisteredTransliterator;

/** Auto-generated transliterator for KanjiOldNewTransliterator. */
@RegisteredTransliterator(name = "kanji-old-new")
public class KanjiOldNewTransliterator implements Transliterator {
    private static final Map<CodePointTuple, CodePointTuple> mappings;

    static {
        final Map<CodePointTuple, CodePointTuple> mappings_ = new TreeMap<>();
        final ByteBuffer b;
        try {
            try (final InputStream s =
                    KanjiOldNewTransliterator.class.getResourceAsStream("kanji_old_new.data")) {
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
