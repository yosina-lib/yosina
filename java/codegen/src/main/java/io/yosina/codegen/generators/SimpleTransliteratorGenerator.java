package io.yosina.codegen.generators;

import io.yosina.codegen.Artifact;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;

/** Generates simple transliterators that map single characters to single characters. */
public class SimpleTransliteratorGenerator implements TransliteratorGenerator {
    private static final String SIMPLE_TRANSLITERATOR_TEMPLATE =
            """
            package io.yosina.transliterators;

            import java.nio.ByteBuffer;
            import java.nio.ByteOrder;
            import java.io.IOException;
            import java.io.InputStream;
            import java.io.UncheckedIOException;
            import java.util.Collections;
            import java.util.Map;
            import java.util.TreeMap;

            import io.yosina.CharIterator;
            import io.yosina.CodePointTuple;
            import io.yosina.Transliterator;
            import io.yosina.annotations.RegisteredTransliterator;

            /**
             * Auto-generated transliterator for %1$s.
             */
            @RegisteredTransliterator(name = "%3$s")
            public class %1$s implements Transliterator {
                private static final Map<CodePointTuple, CodePointTuple> mappings;

                static {
                    final Map<CodePointTuple, CodePointTuple> mappings_ = new TreeMap<>();
                    final ByteBuffer b;
                    try {
                        try (final InputStream s = %1$s.class.getResourceAsStream("%2$s")) {
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
            """;

    private final String name;
    private final Map<int[], int[]> mappings;

    public ByteBuffer buildData() {
        ByteBuffer buf = ByteBuffer.allocate(mappings.size() * 4 * 4).order(ByteOrder.BIG_ENDIAN);
        for (Map.Entry<int[], int[]> entry :
                mappings.entrySet().stream()
                        .sorted(
                                (a, b) -> {
                                    int cmp = Integer.compare(a.getKey()[0], b.getKey()[0]);
                                    if (cmp != 0) return cmp;
                                    return Integer.compare(a.getKey()[1], b.getKey()[1]);
                                })
                        .toList()) {
            final int[] fromCp = entry.getKey();
            final int[] toCp = entry.getValue();
            buf.putInt(fromCp[0]);
            buf.putInt(fromCp[1]);
            buf.putInt(toCp[0]);
            buf.putInt(toCp[1]);
        }
        return buf;
    }

    @Override
    public List<Artifact> generate() {
        String className = TransliteratorGenerator.toCamelCase(name) + "Transliterator";
        final String dataFileName = name + ".data";
        final String discoveryName = name.replace("_", "-");

        return List.of(
                new Artifact(
                        Artifact.Type.SOURCE,
                        Path.of(className + ".java"),
                        StandardCharsets.UTF_8.encode(
                                String.format(
                                        SIMPLE_TRANSLITERATOR_TEMPLATE,
                                        className,
                                        dataFileName,
                                        discoveryName))),
                new Artifact(Artifact.Type.RESOURCE, Path.of(dataFileName), buildData()));
    }

    public SimpleTransliteratorGenerator(String name, Map<int[], int[]> rawMappings) {
        this.name = name;
        this.mappings = rawMappings;
    }
}
