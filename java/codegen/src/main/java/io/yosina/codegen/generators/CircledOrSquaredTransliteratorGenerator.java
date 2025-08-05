package io.yosina.codegen.generators;

import io.yosina.codegen.Artifact;
import io.yosina.codegen.CircledOrSquaredRecord;
import io.yosina.codegen.UnicodeUtils;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/** Generates the circled-or-squared transliterator. */
public class CircledOrSquaredTransliteratorGenerator implements TransliteratorGenerator {
    private static final String CIRCLED_OR_SQUARED_TRANSLITERATOR_TEMPLATE =
            """
package io.yosina.transliterators;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.TreeMap;

import io.yosina.CharIterator;
import io.yosina.CodePointTuple;
import io.yosina.Transliterator;
import io.yosina.annotations.RegisteredTransliterator;

/**
 * Auto-generated transliterator for CircledOrSquared.
 * Replace circled or squared characters with templated forms.
 */
@RegisteredTransliterator(name = "circled-or-squared")
public class CircledOrSquared implements Transliterator {
    /** Configuration options for the circled-or-squared transliterator. */
    public static class Options {
        private final String templateForCircled;
        private final String templateForSquared;
        private final boolean includeEmojis;

        /**
         * Sets whether to include emoji characters in transliteration.
         *
         * @param includeEmojis true to include emoji characters, false to skip them
         * @return this options instance for method chaining
         */
        public Options withIncludeEmojis(boolean includeEmojis) {
            return new Options(
                Optional.of(templateForCircled),
                Optional.of(templateForSquared),
                includeEmojis
            );
        }

        /**
         * Gets the templates for circled and squared characters.
         * @return template for circled characters, where "?" in template is replaced with the character
         */
        public String getTemplateForCircled() {
            return templateForCircled;
        }

        /**
         * Gets the template for squared characters.
         * @return template for squared characters, where "?" in template is replaced with the character
         */
        public String getTemplateForSquared() {
            return templateForSquared;
        }

        /**
         * Gets whether emoji characters are included in transliteration.
         *
         * @return true if emoji characters are included, false otherwise
         */
        public boolean isIncludeEmojis() {
            return includeEmojis;
        }

        /**
         * Creates default options with circle template "(?)" and square template "[?]".
         */
        public Options() {
            this(Optional.empty(), Optional.empty(), false);
        }

        /**
         * Creates options with specified templates and emoji inclusion.
         *
         * @param templateForCircled template for circled characters, defaults to "(?)"
         * @param templateForSquared template for squared characters, defaults to "[?]"
         * @param includeEmojis whether to include emoji characters in transliteration
         */
        public Options(
                Optional<String> templateForCircled,
                Optional<String> templateForSquared,
                boolean includeEmojis) {
            this.templateForCircled = templateForCircled.orElse("(?)");
            this.templateForSquared = templateForSquared.orElse("[?]");
            this.includeEmojis = includeEmojis;
        }

        /**
         * Sets the templates for replacing circled/squared characters.
         *
         * @param templateForCircled template for circled characters, defaults to "(?)"
         * @param templateForSquared template for squared characters, defaults to "[?]"
         * @return this options instance for method chaining
         */
        public Options withTemplates(Optional<String> templateForCircled, Optional<String> templateForSquared) {
            return new Options(
                templateForCircled,
                templateForSquared,
                includeEmojis
            );
        }
    }

    private static enum CharType {
        CIRCLE,
        SQUARE
    }

    private static class Record {
        private final String rendering;
        private final CharType type;
        private final boolean emoji;

        Record(String rendering, CharType type, boolean emoji) {
            this.rendering = rendering;
            this.type = type;
            this.emoji = emoji;
        }
    }

    private static final Map<CodePointTuple, Record> mappings;

    static {
        final Map<CodePointTuple, Record> mappings_ = new TreeMap<>();
        final ByteBuffer b;
        try {
            try (final InputStream s = CircledOrSquared.class.getResourceAsStream("circled_or_squared.data")) {
                b = ByteBuffer.wrap(s.readAllBytes()).order(ByteOrder.BIG_ENDIAN);
            }
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
        while (b.hasRemaining()) {
            final int key1 = b.getInt(), key2 = b.getInt();
            final int renderingLength = b.getInt();
            final StringBuilder rendering = new StringBuilder();
            for (int i = 0; i < renderingLength; i++) {
                rendering.appendCodePoint(b.getInt());
            }
            final int typeValue = b.getInt();
            final CharType type = typeValue == 0 ? CharType.CIRCLE : CharType.SQUARE;
            final boolean emoji = b.getInt() != 0;
            mappings_.put(CodePointTuple.of(key1, key2), new Record(rendering.toString(), type, emoji));
        }
        mappings = Collections.unmodifiableMap(mappings_);
    }

    private final Options options;

    /** Creates a new CircledOrSquared transliterator with default options. */
    public CircledOrSquared() {
        this(new Options());
    }

    /**
     * Creates a new CircledOrSquared transliterator with the specified options.
     *
     * @param options the configuration options
     */
    public CircledOrSquared(Options options) {
        this.options = options;
    }

    @Override
    public CharIterator transliterate(CharIterator input) {
        return new CircledOrSquaredCharIterator(input, mappings, options);
    }

    private static class CircledOrSquaredCharIterator implements CharIterator {
        private final CharIterator input;
        private final Map<CodePointTuple, Record> mappings;
        private final Options options;
        private final List<io.yosina.Char> queue = new ArrayList<>();
        private int queueIndex = 0;

        public CircledOrSquaredCharIterator(CharIterator input, Map<CodePointTuple, Record> mappings, Options options) {
            this.input = input;
            this.mappings = mappings;
            this.options = options;
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

            Record record = mappings.get(ch.get());
            if (record != null) {
                // Skip emoji characters if not included
                if (record.emoji && !options.isIncludeEmojis()) {
                    return ch;
                }

                // Get template
                String template = record.type == CharType.CIRCLE ? options.getTemplateForCircled() : options.getTemplateForSquared();
                String replacement = template.replace("?", record.rendering);

                if (replacement.isEmpty()) {
                    return ch;
                }

                // Create new characters for each replacement code point
                int[] replacementCodePoints = replacement.codePoints().toArray();
                for (int i = 0; i < replacementCodePoints.length; i++) {
                    queue.add(new io.yosina.Char(
                        CodePointTuple.of(replacementCodePoints[i], -1),
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
}
""";

    private final Map<String, CircledOrSquaredRecord> mappings;

    public CircledOrSquaredTransliteratorGenerator(Map<String, CircledOrSquaredRecord> mappings) {
        this.mappings = mappings;
    }

    @Override
    public List<Artifact> generate() {
        List<Artifact> artifacts = new ArrayList<>();

        // Generate source file
        artifacts.add(
                new Artifact(
                        Artifact.Type.SOURCE,
                        Path.of("CircledOrSquared.java"),
                        ByteBuffer.wrap(
                                CIRCLED_OR_SQUARED_TRANSLITERATOR_TEMPLATE.getBytes(
                                        StandardCharsets.UTF_8))));

        // Generate binary data file
        ByteBuffer dataBuffer = generateBinaryData();
        artifacts.add(
                new Artifact(
                        Artifact.Type.RESOURCE, Path.of("circled_or_squared.data"), dataBuffer));

        return artifacts;
    }

    private ByteBuffer generateBinaryData() {
        // Calculate total size needed
        int totalSize = 0;
        for (Map.Entry<String, CircledOrSquaredRecord> entry : mappings.entrySet()) {
            // 2 ints for key + 1 int for rendering length + n ints for rendering + 1 int for type +
            // 1 int for emoji
            totalSize +=
                    5 * 4
                            + entry.getValue()
                                            .getRendering()
                                            .codePointCount(
                                                    0, entry.getValue().getRendering().length())
                                    * 4;
        }

        ByteBuffer buffer = ByteBuffer.allocate(totalSize).order(ByteOrder.BIG_ENDIAN);

        for (Map.Entry<String, CircledOrSquaredRecord> entry : mappings.entrySet()) {
            int fromCodePoint = UnicodeUtils.parseUnicodeCodepoint(entry.getKey());
            CircledOrSquaredRecord record = entry.getValue();

            // Write key (code point tuple)
            buffer.putInt(fromCodePoint);
            buffer.putInt(-1); // Second code point is always -1 for single characters

            // Write rendering
            int[] renderingCodePoints = record.getRendering().codePoints().toArray();
            buffer.putInt(renderingCodePoints.length);
            for (int codePoint : renderingCodePoints) {
                buffer.putInt(codePoint);
            }

            // Write type (0 for circle, 1 for square)
            buffer.putInt("circle".equals(record.getType()) ? 0 : 1);

            // Write emoji flag
            buffer.putInt(record.isEmoji() ? 1 : 0);
        }

        return buffer.rewind();
    }
}
