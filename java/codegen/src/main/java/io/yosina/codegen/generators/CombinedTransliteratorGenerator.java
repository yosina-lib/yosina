package io.yosina.codegen.generators;

import io.yosina.codegen.Artifact;
import io.yosina.codegen.UnicodeUtils;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** Generates the combined transliterator that maps single characters to arrays of characters. */
public class CombinedTransliteratorGenerator implements TransliteratorGenerator {
    private static final String COMBINED_TRANSLITERATOR_TEMPLATE =
            """
package io.yosina.transliterators;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import io.yosina.CharIterator;
import io.yosina.CodePointTuple;
import io.yosina.Transliterator;
import io.yosina.annotations.RegisteredTransliterator;

/**
 * Auto-generated transliterator for Combined.
 * Replace single characters with arrays of characters.
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
                    queue.add(new io.yosina.Char(
                        CodePointTuple.of(replacement[i], -1),
                        ch.getOffset() + i,
                        ch
                    ));
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
    public Combined() {
    }
}
""";

    private final Map<String, String> mappings;

    public CombinedTransliteratorGenerator(Map<String, String> mappings) {
        this.mappings = mappings;
    }

    @Override
    public List<Artifact> generate() {
        List<Artifact> artifacts = new ArrayList<>();

        // Generate source file
        artifacts.add(
                new Artifact(
                        Artifact.Type.SOURCE,
                        Path.of("Combined.java"),
                        ByteBuffer.wrap(
                                COMBINED_TRANSLITERATOR_TEMPLATE.getBytes(
                                        StandardCharsets.UTF_8))));

        // Generate binary data file
        ByteBuffer dataBuffer = generateBinaryData();
        artifacts.add(new Artifact(Artifact.Type.RESOURCE, Path.of("combined.data"), dataBuffer));

        return artifacts;
    }

    private ByteBuffer generateBinaryData() {
        // Calculate total size needed
        int totalSize = 0;
        for (Map.Entry<String, String> entry : mappings.entrySet()) {
            // 2 ints for key + 1 int for length + n ints for values
            totalSize += 3 * 4 + entry.getValue().codePointCount(0, entry.getValue().length()) * 4;
        }

        ByteBuffer buffer = ByteBuffer.allocate(totalSize).order(ByteOrder.BIG_ENDIAN);

        for (Map.Entry<String, String> entry : mappings.entrySet()) {
            int fromCodePoint = UnicodeUtils.parseUnicodeCodepoint(entry.getKey());
            String toStr = entry.getValue();

            // Write key (code point tuple)
            buffer.putInt(fromCodePoint);
            buffer.putInt(-1); // Second code point is always -1 for single characters

            // Write value array
            int[] toCodePoints = toStr.codePoints().toArray();
            buffer.putInt(toCodePoints.length);
            for (int codePoint : toCodePoints) {
                buffer.putInt(codePoint);
            }
        }

        return buffer.rewind();
    }
}
