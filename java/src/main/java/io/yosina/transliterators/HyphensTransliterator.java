package io.yosina.transliterators;

import io.yosina.Char;
import io.yosina.CharIterator;
import io.yosina.CodePointTuple;
import io.yosina.Transliterator;
import io.yosina.annotations.RegisteredTransliterator;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.TreeMap;

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

    public HyphensRecord(
            CodePointTuple code,
            CodePointTuple[] ascii,
            CodePointTuple[] jisx0201,
            CodePointTuple[] jisx0208_1978,
            CodePointTuple[] jisx0208_1978_windows,
            CodePointTuple jisx0208_verbatim) {
        this.code = code;
        this.ascii = ascii;
        this.jisx0201 = jisx0201;
        this.jisx0208_1978 = jisx0208_1978;
        this.jisx0208_1978_windows = jisx0208_1978_windows;
        this.jisx0208_verbatim = jisx0208_verbatim;
    }
}

/** Auto-generated transliterator for hyphens. */
@RegisteredTransliterator(name = "hyphens")
public class HyphensTransliterator implements Transliterator {
    private static final Map<CodePointTuple, HyphensRecord> mappings;

    static {
        final Map<CodePointTuple, HyphensRecord> mappings_ = new TreeMap<>();
        mappings_.put(
                CodePointTuple.of(0x002D),
                new HyphensRecord(
                        CodePointTuple.of(0x002D),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2212)},
                        new CodePointTuple[] {CodePointTuple.of(0x2212)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x007C),
                new HyphensRecord(
                        CodePointTuple.of(0x007C),
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x007E),
                new HyphensRecord(
                        CodePointTuple.of(0x007E),
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0x301C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5E)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x00A2),
                new HyphensRecord(
                        CodePointTuple.of(0x00A2),
                        null,
                        null,
                        new CodePointTuple[] {CodePointTuple.of(0x00A2)},
                        new CodePointTuple[] {CodePointTuple.of(0xFFE0)},
                        CodePointTuple.of(0x00A2)));
        mappings_.put(
                CodePointTuple.of(0x00A3),
                new HyphensRecord(
                        CodePointTuple.of(0x00A3),
                        null,
                        null,
                        new CodePointTuple[] {CodePointTuple.of(0x00A3)},
                        new CodePointTuple[] {CodePointTuple.of(0xFFE1)},
                        CodePointTuple.of(0x00A3)));
        mappings_.put(
                CodePointTuple.of(0x00A6),
                new HyphensRecord(
                        CodePointTuple.of(0x00A6),
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        CodePointTuple.of(0x00A6)));
        mappings_.put(
                CodePointTuple.of(0x02D7),
                new HyphensRecord(
                        CodePointTuple.of(0x02D7),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2212)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF0D)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x2010),
                new HyphensRecord(
                        CodePointTuple.of(0x2010),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2010)},
                        new CodePointTuple[] {CodePointTuple.of(0x2010)},
                        CodePointTuple.of(0x2010)));
        mappings_.put(
                CodePointTuple.of(0x2011),
                new HyphensRecord(
                        CodePointTuple.of(0x2011),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2010)},
                        new CodePointTuple[] {CodePointTuple.of(0x2010)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x2012),
                new HyphensRecord(
                        CodePointTuple.of(0x2012),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2015)},
                        new CodePointTuple[] {CodePointTuple.of(0x2015)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x2013),
                new HyphensRecord(
                        CodePointTuple.of(0x2013),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2015)},
                        new CodePointTuple[] {CodePointTuple.of(0x2015)},
                        CodePointTuple.of(0x2013)));
        mappings_.put(
                CodePointTuple.of(0x2014),
                new HyphensRecord(
                        CodePointTuple.of(0x2014),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2014)},
                        new CodePointTuple[] {CodePointTuple.of(0x2015)},
                        CodePointTuple.of(0x2014)));
        mappings_.put(
                CodePointTuple.of(0x2015),
                new HyphensRecord(
                        CodePointTuple.of(0x2015),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2015)},
                        new CodePointTuple[] {CodePointTuple.of(0x2015)},
                        CodePointTuple.of(0x2015)));
        mappings_.put(
                CodePointTuple.of(0x2016),
                new HyphensRecord(
                        CodePointTuple.of(0x2016),
                        null,
                        null,
                        new CodePointTuple[] {CodePointTuple.of(0x2016)},
                        new CodePointTuple[] {CodePointTuple.of(0x2225)},
                        CodePointTuple.of(0x2016)));
        mappings_.put(
                CodePointTuple.of(0x2032),
                new HyphensRecord(
                        CodePointTuple.of(0x2032),
                        new CodePointTuple[] {CodePointTuple.of(0x0027)},
                        new CodePointTuple[] {CodePointTuple.of(0x0027)},
                        new CodePointTuple[] {CodePointTuple.of(0x2032)},
                        new CodePointTuple[] {CodePointTuple.of(0x2032)},
                        CodePointTuple.of(0x2032)));
        mappings_.put(
                CodePointTuple.of(0x2033),
                new HyphensRecord(
                        CodePointTuple.of(0x2033),
                        new CodePointTuple[] {CodePointTuple.of(0x0022)},
                        new CodePointTuple[] {CodePointTuple.of(0x0022)},
                        new CodePointTuple[] {CodePointTuple.of(0x2033)},
                        new CodePointTuple[] {CodePointTuple.of(0x2033)},
                        CodePointTuple.of(0x2033)));
        mappings_.put(
                CodePointTuple.of(0x203E),
                new HyphensRecord(
                        CodePointTuple.of(0x203E),
                        null,
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0xFFE3)},
                        new CodePointTuple[] {CodePointTuple.of(0xFFE3)},
                        CodePointTuple.of(0x203D)));
        mappings_.put(
                CodePointTuple.of(0x2043),
                new HyphensRecord(
                        CodePointTuple.of(0x2043),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2010)},
                        new CodePointTuple[] {CodePointTuple.of(0x2010)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x2053),
                new HyphensRecord(
                        CodePointTuple.of(0x2053),
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0x301C)},
                        new CodePointTuple[] {CodePointTuple.of(0x301C)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x2212),
                new HyphensRecord(
                        CodePointTuple.of(0x2212),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2212)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF0D)},
                        CodePointTuple.of(0x2212)));
        mappings_.put(
                CodePointTuple.of(0x2225),
                new HyphensRecord(
                        CodePointTuple.of(0x2225),
                        null,
                        null,
                        new CodePointTuple[] {CodePointTuple.of(0x2016)},
                        new CodePointTuple[] {CodePointTuple.of(0x2225)},
                        CodePointTuple.of(0x2225)));
        mappings_.put(
                CodePointTuple.of(0x223C),
                new HyphensRecord(
                        CodePointTuple.of(0x223C),
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0x301C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5E)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x223D),
                new HyphensRecord(
                        CodePointTuple.of(0x223D),
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0x301C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5E)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x2500),
                new HyphensRecord(
                        CodePointTuple.of(0x2500),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2015)},
                        new CodePointTuple[] {CodePointTuple.of(0x2015)},
                        CodePointTuple.of(0x2500)));
        mappings_.put(
                CodePointTuple.of(0x2501),
                new HyphensRecord(
                        CodePointTuple.of(0x2501),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2015)},
                        new CodePointTuple[] {CodePointTuple.of(0x2015)},
                        CodePointTuple.of(0x2501)));
        mappings_.put(
                CodePointTuple.of(0x2502),
                new HyphensRecord(
                        CodePointTuple.of(0x2502),
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        CodePointTuple.of(0x2502)));
        mappings_.put(
                CodePointTuple.of(0x2796),
                new HyphensRecord(
                        CodePointTuple.of(0x2796),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2212)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF0D)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x29FF),
                new HyphensRecord(
                        CodePointTuple.of(0x29FF),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2010)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF0D)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x2E3A),
                new HyphensRecord(
                        CodePointTuple.of(0x2E3A),
                        new CodePointTuple[] {CodePointTuple.of(0x002D), CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D), CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2014), CodePointTuple.of(0x2014)},
                        new CodePointTuple[] {CodePointTuple.of(0x2015), CodePointTuple.of(0x2015)},
                        null));
        mappings_.put(
                CodePointTuple.of(0x2E3B),
                new HyphensRecord(
                        CodePointTuple.of(0x2E3B),
                        new CodePointTuple[] {
                            CodePointTuple.of(0x002D),
                            CodePointTuple.of(0x002D),
                            CodePointTuple.of(0x002D)
                        },
                        new CodePointTuple[] {
                            CodePointTuple.of(0x002D),
                            CodePointTuple.of(0x002D),
                            CodePointTuple.of(0x002D)
                        },
                        new CodePointTuple[] {
                            CodePointTuple.of(0x2014),
                            CodePointTuple.of(0x2014),
                            CodePointTuple.of(0x2014)
                        },
                        new CodePointTuple[] {
                            CodePointTuple.of(0x2015),
                            CodePointTuple.of(0x2015),
                            CodePointTuple.of(0x2015)
                        },
                        null));
        mappings_.put(
                CodePointTuple.of(0x301C),
                new HyphensRecord(
                        CodePointTuple.of(0x301C),
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0x301C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5E)},
                        CodePointTuple.of(0x301C)));
        mappings_.put(
                CodePointTuple.of(0x30A0),
                new HyphensRecord(
                        CodePointTuple.of(0x30A0),
                        new CodePointTuple[] {CodePointTuple.of(0x003D)},
                        new CodePointTuple[] {CodePointTuple.of(0x003D)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF1D)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF1D)},
                        CodePointTuple.of(0x30A0)));
        mappings_.put(
                CodePointTuple.of(0x30FB),
                new HyphensRecord(
                        CodePointTuple.of(0x30FB),
                        null,
                        new CodePointTuple[] {CodePointTuple.of(0xFF65)},
                        new CodePointTuple[] {CodePointTuple.of(0x30FB)},
                        new CodePointTuple[] {CodePointTuple.of(0x30FB)},
                        CodePointTuple.of(0x30FB)));
        mappings_.put(
                CodePointTuple.of(0x30FC),
                new HyphensRecord(
                        CodePointTuple.of(0x30FC),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x30FC)},
                        new CodePointTuple[] {CodePointTuple.of(0x30FC)},
                        CodePointTuple.of(0x30FC)));
        mappings_.put(
                CodePointTuple.of(0xFE31),
                new HyphensRecord(
                        CodePointTuple.of(0xFE31),
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        null));
        mappings_.put(
                CodePointTuple.of(0xFE58),
                new HyphensRecord(
                        CodePointTuple.of(0xFE58),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2010)},
                        new CodePointTuple[] {CodePointTuple.of(0x2010)},
                        null));
        mappings_.put(
                CodePointTuple.of(0xFE63),
                new HyphensRecord(
                        CodePointTuple.of(0xFE63),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2010)},
                        new CodePointTuple[] {CodePointTuple.of(0x2010)},
                        null));
        mappings_.put(
                CodePointTuple.of(0xFF0D),
                new HyphensRecord(
                        CodePointTuple.of(0xFF0D),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0x2212)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF0D)},
                        null));
        mappings_.put(
                CodePointTuple.of(0xFF5C),
                new HyphensRecord(
                        CodePointTuple.of(0xFF5C),
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        CodePointTuple.of(0xFF5C)));
        mappings_.put(
                CodePointTuple.of(0xFF5E),
                new HyphensRecord(
                        CodePointTuple.of(0xFF5E),
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0x007E)},
                        new CodePointTuple[] {CodePointTuple.of(0x301C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5E)},
                        null));
        mappings_.put(
                CodePointTuple.of(0xFFE4),
                new HyphensRecord(
                        CodePointTuple.of(0xFFE4),
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFFE4)},
                        CodePointTuple.of(0xFFE4)));
        mappings_.put(
                CodePointTuple.of(0xFF70),
                new HyphensRecord(
                        CodePointTuple.of(0xFF70),
                        new CodePointTuple[] {CodePointTuple.of(0x002D)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF70)},
                        new CodePointTuple[] {CodePointTuple.of(0x30FC)},
                        new CodePointTuple[] {CodePointTuple.of(0x30FC)},
                        null));
        mappings_.put(
                CodePointTuple.of(0xFFE8),
                new HyphensRecord(
                        CodePointTuple.of(0xFFE8),
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0x007C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        new CodePointTuple[] {CodePointTuple.of(0xFF5C)},
                        null));
        mappings = mappings_;
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
                for (final Mapping m : precedence) {
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
