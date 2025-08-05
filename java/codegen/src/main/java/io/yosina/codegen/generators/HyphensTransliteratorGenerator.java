package io.yosina.codegen.generators;

import io.yosina.codegen.Artifact;
import io.yosina.codegen.HyphensRecord;
import java.nio.charset.StandardCharsets;
import java.nio.file.Path;
import java.util.List;

/** Generates the hyphens transliterator. */
public class HyphensTransliteratorGenerator implements TransliteratorGenerator {
    private static final String HYPHENS_TRANSLITERATOR_TEMPLATE =
            """
package io.yosina.transliterators;

import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.TreeMap;

import io.yosina.Char;
import io.yosina.CharIterator;
import io.yosina.CodePointTuple;
import io.yosina.Transliterator;
import io.yosina.annotations.RegisteredTransliterator;

class HyphensRecord {
    private CodePointTuple code;
    private CodePointTuple[] ascii;
    private CodePointTuple[] jisx0201;
    private CodePointTuple[] jisx0208_1978;
    private CodePointTuple[] jisx0208_1978_windows;
    private CodePointTuple jisx0208_verbatim;

    public CodePointTuple getCode() {
        return code;
    }

    public CodePointTuple[] getAscii() {
        return ascii;
    }

    public CodePointTuple[] getJisx0201() {
        return jisx0201;
    }

    public CodePointTuple[] getJisx0208_1978() {
        return jisx0208_1978;
    }

    public CodePointTuple[] getJisx0208_1978_windows() {
        return jisx0208_1978_windows;
    }

    public CodePointTuple getJisx0208_verbatim() {
        return jisx0208_verbatim;
    }

    public HyphensRecord(CodePointTuple code, CodePointTuple[] ascii, CodePointTuple[] jisx0201,
            CodePointTuple[] jisx0208_1978, CodePointTuple[] jisx0208_1978_windows,
            CodePointTuple jisx0208_verbatim) {
        this.code = code;
        this.ascii = ascii;
        this.jisx0201 = jisx0201;
        this.jisx0208_1978 = jisx0208_1978;
        this.jisx0208_1978_windows = jisx0208_1978_windows;
        this.jisx0208_verbatim = jisx0208_verbatim;
    }
}

/**
 * Auto-generated transliterator for hyphens.
 */
@RegisteredTransliterator(name = "hyphens")
public class HyphensTransliterator implements Transliterator {
    private static final Map<CodePointTuple, HyphensRecord> mappings;

    static {
        final Map<CodePointTuple, HyphensRecord> mappings_ = new TreeMap<>();
%s        mappings = mappings_;
    }

    private static class HyphenCharIterator implements CharIterator {
        private final CharIterator input;
        private final List<Mapping> precedence;
        private int offset = 0;
        private Char source = null;
        private CodePointTuple[] buf = null;
        private int bufOffset = 0;

        @Override
        public boolean hasNext() {
            return input.hasNext();
        }

        @Override
        public Char next() {
            if (buf != null) {
                if (bufOffset < buf.length) {
                    final CodePointTuple ct = buf[bufOffset++];
                    final Char result = new Char(ct, offset, source);
                    offset += result.charCount();
                    return result;
                } else {
                    buf = null;
                    bufOffset = 0;
                    source = null;
                }
            }

            if (!hasNext()) {
                throw new NoSuchElementException();
            }

            Char c = input.next();
            if (c == null) {
                return null;
            }

            final HyphensRecord replacement = mappings.get(c.get());
            if (replacement != null) {
                for (final Mapping m: precedence) {
                    switch (m) {
                    case ASCII:
                        {
                            final CodePointTuple[] cts = replacement.getAscii();
                            if (cts.length > 1) {
                                buf = cts;
                                bufOffset = 1;
                                source = c;
                            }
                            final CodePointTuple ct = cts[0];
                            final Char result = new Char(ct, offset, c);
                            offset += result.charCount();
                            return result;
                        }
                    case JISX0201:
                        {
                            final CodePointTuple[] cts = replacement.getJisx0201();
                            if (cts.length > 1) {
                                buf = cts;
                                bufOffset = 1;
                                source = c;
                            }
                            final CodePointTuple ct = cts[0];
                            final Char result = new Char(ct, offset, c);
                            offset += result.charCount();
                            return result;
                        }
                    case JISX0208_90:
                        {
                            final CodePointTuple[] cts = replacement.getJisx0208_1978();
                            if (cts.length > 1) {
                                buf = cts;
                                bufOffset = 1;
                                source = c;
                            }
                            final CodePointTuple ct = cts[0];
                            final Char result = new Char(ct, offset, c);
                            offset += result.charCount();
                            return result;
                        }
                    case JISX0208_90_WINDOWS:
                        {
                            final CodePointTuple[] cts = replacement.getJisx0208_1978_windows();
                            if (cts.length > 1) {
                                buf = cts;
                                bufOffset = 1;
                                source = c;
                            }
                            final CodePointTuple ct = cts[0];
                            final Char result = new Char(ct, offset, c);
                            offset += result.charCount();
                            return result;
                        }
                    case JISX0208_VERBATIM:
                        {
                            final CodePointTuple ct = replacement.getJisx0208_verbatim();
                            if (ct != null) {
                                final Char result = new Char(ct, offset, c);
                                offset += result.charCount();
                                return result;
                            }
                        }
                    }
                }
            }
            final Char result = c.withOffset(offset);
            offset += result.charCount();
            return result;
        }

        public HyphenCharIterator(CharIterator input, List<Mapping> precedence) {
            this.input = input;
            this.precedence = precedence;
        }
    }

    /**
     * Mapping types for hyphen character conversion. Defines the target character encoding for
     * hyphen replacements.
     */
    public static enum Mapping {
        /** ASCII character mapping */
        ASCII,
        /** JIS X 0201 character mapping */
        JISX0201,
        /** JIS X 0208:1990 character mapping */
        JISX0208_90,
        /** JIS X 0208:1990 Windows variant character mapping */
        JISX0208_90_WINDOWS,
        /** JIS X 0208 verbatim character mapping */
        JISX0208_VERBATIM
    }

    /**
     * Configuration options for HyphensTransliterator. Allows customization of how hyphen
     * characters are converted.
     */
    public static class Options {
        private final List<Mapping> precedence;

        /**
         * Gets the mapping precedence list.
         *
         * @return the list of mappings in order of precedence
         */
        public List<Mapping> getPrecedence() {
            return precedence;
        }

        /**
         * Creates a new Options instance with the specified mapping precedence.
         *
         * @param precedence the list of mappings in order of precedence
         * @return a new Options instance with the specified precedence
         */
        public Options withPrecedence(List<Mapping> precedence) {
            return new Options(precedence);
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj == null || !(obj instanceof Options)) {
                return false;
            }
            final Options options = (Options) obj;
            if (precedence.size() != options.precedence.size()) {
                return false;
            }
            return precedence.containsAll(options.precedence);
        }

        @Override
        public int hashCode() {
            return precedence.hashCode();
        }

        /**
         * Creates Options with the specified mapping precedence.
         *
         * @param precedence the list of mappings in order of precedence
         */
        public Options(List<Mapping> precedence) {
            this.precedence = precedence;
        }

        /** Creates Options with default precedence (JISX0208_90). */
        public Options() {
            this.precedence = List.of(Mapping.JISX0208_90);
        }
    }

    private final Options options;

    @Override
    public CharIterator transliterate(CharIterator input) {
        return new HyphenCharIterator(input, options.getPrecedence());
    }

    /**
     * Creates a new HyphensTransliterator with the specified options.
     *
     * @param options the configuration options for hyphen conversion
     */
    public HyphensTransliterator(Options options) {
        this.options = options;
    }
}
""";

    private final List<HyphensRecord> records;

    public HyphensTransliteratorGenerator(List<HyphensRecord> records) {
        this.records = records;
    }

    private static String renderCodePointTuple(int cp) {
        return String.format("CodePointTuple.of(0x%04X)", cp);
    }

    private static String renderCodePointTupleArray(int[] cps) {
        if (cps == null || cps.length == 0) {
            return "null";
        }
        final StringBuilder sb = new StringBuilder("new CodePointTuple[] { ");
        boolean first = true;
        for (int cp : cps) {
            if (!first) {
                sb.append(", ");
            } else {
                first = false;
            }
            sb.append(renderCodePointTuple(cp));
        }
        sb.append(" }");
        return sb.toString();
    }

    public String renderMappingEntries() {
        StringBuilder sb = new StringBuilder();
        for (HyphensRecord record : records) {
            sb.append(
                    String.format(
                            "        mappings_.put(%s, new HyphensRecord(%s, %s, %s, %s, %s,"
                                    + " %s));\n",
                            renderCodePointTuple(record.getCode()),
                            renderCodePointTuple(record.getCode()),
                            renderCodePointTupleArray(record.getAscii()),
                            renderCodePointTupleArray(record.getJisx0201()),
                            renderCodePointTupleArray(record.getJisx0208_1978()),
                            renderCodePointTupleArray(record.getJisx0208_1978_windows()),
                            record.getJisx0208_verbatim() == -1
                                    ? "null"
                                    : renderCodePointTuple(record.getJisx0208_verbatim())));
        }
        return sb.toString();
    }

    @Override
    public List<Artifact> generate() {
        String mappingEntries = renderMappingEntries();
        String content = String.format(HYPHENS_TRANSLITERATOR_TEMPLATE, mappingEntries);
        return List.of(
                new Artifact(
                        Artifact.Type.SOURCE,
                        Path.of("HyphensTransliterator.java"),
                        StandardCharsets.UTF_8.encode(content)));
    }
}
