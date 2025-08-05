package io.yosina.transliterators;

import io.yosina.Char;
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
import java.util.NoSuchElementException;
import java.util.Objects;
import java.util.TreeMap;

class IvsSvsBaseRecord {
    private CodePointTuple ivs;
    private CodePointTuple svs;
    private CodePointTuple base90;
    private CodePointTuple base2004;

    public CodePointTuple getIvs() {
        return ivs;
    }

    public CodePointTuple getSvs() {
        return svs;
    }

    public CodePointTuple getBase90() {
        return base90;
    }

    public CodePointTuple getBase2004() {
        return base2004;
    }

    public IvsSvsBaseRecord(
            CodePointTuple ivs,
            CodePointTuple svs,
            CodePointTuple base90,
            CodePointTuple base2004) {
        this.ivs = ivs;
        this.svs = svs;
        this.base90 = base90;
        this.base2004 = base2004;
    }
}

class IvsSvsBaseMappings {
    private static final Map<CodePointTuple, IvsSvsBaseRecord> fwdBase90Mappings;
    private static final Map<CodePointTuple, IvsSvsBaseRecord> fwdBase2004Mappings;
    private static final Map<CodePointTuple, IvsSvsBaseRecord> revMappings;

    static {
        final Map<CodePointTuple, IvsSvsBaseRecord> fwdBase90Mappings_ = new TreeMap<>();
        final Map<CodePointTuple, IvsSvsBaseRecord> fwdBase2004Mappings_ = new TreeMap<>();
        final Map<CodePointTuple, IvsSvsBaseRecord> revMappings_ = new TreeMap<>();

        final ByteBuffer b;
        try {
            try (final InputStream s =
                    IvsSvsBaseMappings.class.getResourceAsStream("ivs_svs_base.data")) {
                b = ByteBuffer.wrap(s.readAllBytes()).order(ByteOrder.BIG_ENDIAN);
            }
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }

        final int n = b.getInt();
        for (int i = 0; i < n; i++) {
            final CodePointTuple ivs = CodePointTuple.of(b.getInt(), b.getInt());
            final CodePointTuple svs = CodePointTuple.of(b.getInt(), b.getInt());
            final CodePointTuple base90 = CodePointTuple.of(b.getInt());
            final CodePointTuple base2004 = CodePointTuple.of(b.getInt());
            final IvsSvsBaseRecord record = new IvsSvsBaseRecord(ivs, svs, base90, base2004);
            fwdBase90Mappings_.put(ivs, record);
            fwdBase2004Mappings_.put(ivs, record);
            if (!svs.isEmpty()) {
                fwdBase90Mappings_.put(svs, record);
                fwdBase2004Mappings_.put(svs, record);
            }
            if (!base90.isEmpty()) {
                fwdBase90Mappings_.put(base90, record);
            }
            if (!base2004.isEmpty()) {
                fwdBase2004Mappings_.put(base2004, record);
            }
            revMappings_.put(ivs, record);
        }
        fwdBase90Mappings = Collections.unmodifiableMap(fwdBase90Mappings_);
        fwdBase2004Mappings = Collections.unmodifiableMap(fwdBase2004Mappings_);
        revMappings = Collections.unmodifiableMap(revMappings_);
    }

    public static Map<CodePointTuple, IvsSvsBaseRecord> getFwdBase90Mapping() {
        return fwdBase90Mappings;
    }

    public static Map<CodePointTuple, IvsSvsBaseRecord> getFwdBase2004Mapping() {
        return fwdBase2004Mappings;
    }

    public static Map<CodePointTuple, IvsSvsBaseRecord> getRevMapping() {
        return revMappings;
    }
}

/** Auto-generated transliterator for IVS/SVS base. */
@RegisteredTransliterator(name = "ivs-svs-base")
public class IvsSvsBaseTransliterator implements Transliterator {
    private static class IvsSvsBaseFwdCharIterator implements CharIterator {
        private final CharIterator input;
        private final Map<CodePointTuple, IvsSvsBaseRecord> mappings;
        private final boolean preferSvs;
        private int offset = 0;

        @Override
        public boolean hasNext() {
            return input.hasNext();
        }

        @Override
        public Char next() {
            if (!hasNext()) {
                throw new NoSuchElementException();
            }

            Char c = input.next();
            if (c == null) {
                return null;
            }

            final IvsSvsBaseRecord replacement = mappings.get(c.get());
            if (replacement != null) {
                final CodePointTuple ct =
                        preferSvs && !replacement.getSvs().isEmpty()
                                ? replacement.getSvs()
                                : replacement.getIvs();
                final Char result = new Char(ct, offset, c);
                offset += result.charCount();
                return result;
            } else {
                final Char result = c.withOffset(offset);
                offset += result.charCount();
                return result;
            }
        }

        @Override
        public long estimateSize() {
            return input.estimateSize();
        }

        public IvsSvsBaseFwdCharIterator(
                CharIterator input,
                Map<CodePointTuple, IvsSvsBaseRecord> mappings,
                boolean preferSvs) {
            this.input = input;
            this.mappings = mappings;
            this.preferSvs = preferSvs;
        }
    }

    private static class IvsSvsBaseRevCharIterator implements CharIterator {
        private static final Map<CodePointTuple, IvsSvsBaseRecord> mappings =
                IvsSvsBaseMappings.getRevMapping();
        private final CharIterator input;
        private final Charset charset;
        private final boolean dropSelectorsAltogether;
        private int offset = 0;

        @Override
        public boolean hasNext() {
            return input.hasNext();
        }

        @Override
        public Char next() {
            if (!hasNext()) {
                throw new NoSuchElementException();
            }

            Char c = input.next();
            if (c == null) {
                return null;
            }

            final IvsSvsBaseRecord replacement = mappings.get(c.get());
            if (replacement != null) {
                CodePointTuple ct = null;
                switch (charset) {
                    case UNIJIS_90:
                        ct = replacement.getBase90();
                        break;
                    case UNIJIS_2004:
                        ct = replacement.getBase2004();
                        break;
                }
                if (ct != null) {
                    final Char result = new Char(ct, offset, c);
                    offset += result.charCount();
                    return result;
                }
            }
            final Char result;
            if (dropSelectorsAltogether && c.get().size() > 1) {
                result = new Char(CodePointTuple.of(c.get().get(0)), offset, c);
            } else {
                result = c.withOffset(offset);
            }
            offset += result.charCount();
            return result;
        }

        @Override
        public long estimateSize() {
            return input.estimateSize();
        }

        public IvsSvsBaseRevCharIterator(
                CharIterator input, Charset charset, boolean dropSelectorsAltogether) {
            this.input = input;
            this.charset = charset;
            this.dropSelectorsAltogether = dropSelectorsAltogether;
        }
    }

    /** Transliteration mode for IVS/SVS conversion. */
    public static enum Mode {
        /** Convert to IVS or SVS format */
        IVS_OR_SVS,
        /** Convert to base character format */
        BASE,
    }

    /** Character set variant for base character mapping. */
    public static enum Charset {
        /** Uni-JIS-90 character set */
        UNIJIS_90,
        /** Uni-JIS-2004 character set */
        UNIJIS_2004
    }

    /** Configuration options for IvsSvsBaseTransliterator. */
    public static class Options {
        private final Mode mode;
        private final boolean dropSelectorsAltogether;
        private final Charset charset;
        private final boolean preferSvs;

        /**
         * Gets the transliteration mode.
         *
         * @return the current mode
         */
        public Mode getMode() {
            return mode;
        }

        /**
         * Checks if selectors should be dropped altogether.
         *
         * @return true if selectors should be dropped
         */
        public boolean isDropSelectorsAltogether() {
            return dropSelectorsAltogether;
        }

        /**
         * Gets the character set variant.
         *
         * @return the current charset
         */
        public Charset getCharset() {
            return charset;
        }

        /**
         * Checks if SVS format is preferred over IVS.
         *
         * @return true if SVS is preferred
         */
        public boolean isPreferSvs() {
            return preferSvs;
        }

        /**
         * Creates a new Options instance with the specified mode.
         *
         * @param mode the transliteration mode
         * @return a new Options instance
         */
        public Options withMode(Mode mode) {
            return new Options(mode, dropSelectorsAltogether, charset, preferSvs);
        }

        /**
         * Creates a new Options instance with the specified selector dropping behavior.
         *
         * @param dropSelectorsAltogether whether to drop selectors
         * @return a new Options instance
         */
        public Options withDropSelectorAltogether(boolean dropSelectorsAltogether) {
            return new Options(mode, dropSelectorsAltogether, charset, preferSvs);
        }

        /**
         * Creates a new Options instance with the specified character set.
         *
         * @param charset the character set variant
         * @return a new Options instance
         */
        public Options withCharset(Charset charset) {
            return new Options(mode, dropSelectorsAltogether, charset, preferSvs);
        }

        /**
         * Creates a new Options instance with the specified SVS preference.
         *
         * @param preferSvs whether to prefer SVS over IVS
         * @return a new Options instance
         */
        public Options withPreferSvs(boolean preferSvs) {
            return new Options(mode, dropSelectorsAltogether, charset, preferSvs);
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            Options options = (Options) obj;
            return dropSelectorsAltogether == options.dropSelectorsAltogether
                    && preferSvs == options.preferSvs
                    && mode == options.mode
                    && charset == options.charset;
        }

        @Override
        public int hashCode() {
            return Objects.hash(mode, dropSelectorsAltogether, charset, preferSvs);
        }

        /**
         * Creates Options with all parameters specified.
         *
         * @param mode the transliteration mode
         * @param dropSelectorsAltogether whether to drop selectors
         * @param charset the character set variant
         * @param preferSvs whether to prefer SVS over IVS
         */
        public Options(
                Mode mode, boolean dropSelectorsAltogether, Charset charset, boolean preferSvs) {
            this.mode = mode;
            this.dropSelectorsAltogether = dropSelectorsAltogether;
            this.charset = charset;
            this.preferSvs = preferSvs;
        }

        /**
         * Creates Options with default values. Uses IVS_OR_SVS mode, UNIJIS_2004 charset, and does
         * not drop selectors or prefer SVS.
         */
        public Options() {
            this(Mode.IVS_OR_SVS, false, Charset.UNIJIS_2004, false);
        }
    }

    private final Options options;

    @Override
    public CharIterator transliterate(CharIterator input) {
        switch (options.getMode()) {
            case IVS_OR_SVS:
                return new IvsSvsBaseFwdCharIterator(
                        input,
                        options.getCharset() == Charset.UNIJIS_90
                                ? IvsSvsBaseMappings.getFwdBase90Mapping()
                                : IvsSvsBaseMappings.getFwdBase2004Mapping(),
                        options.isPreferSvs());
            case BASE:
                return new IvsSvsBaseRevCharIterator(
                        input, options.getCharset(), options.isDropSelectorsAltogether());
        }
        throw new IllegalArgumentException("Invalid transliteration mode: " + options.getMode());
    }

    /**
     * Creates a new IvsSvsBaseTransliterator with the specified options.
     *
     * @param options the configuration options
     */
    public IvsSvsBaseTransliterator(Options options) {
        this.options = options;
    }
}
