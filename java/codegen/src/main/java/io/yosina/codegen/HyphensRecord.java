package io.yosina.codegen;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JacksonException;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.deser.std.StdDeserializer;
import java.io.IOException;
import java.util.List;

/** Represents a hyphen replacement record. */
@JsonDeserialize(using = HyphensRecord.Deserializer.class)
public class HyphensRecord {
    static class Deserializer extends StdDeserializer<HyphensRecord> {
        private static class _HyphensRecord {
            @JsonProperty("code")
            private String code;

            @JsonProperty("name")
            private String name;

            @JsonProperty("ascii")
            private List<String> ascii;

            @JsonProperty("shift_jis")
            private List<Integer> shiftJis;

            @JsonProperty("jisx0201")
            private List<String> jisx0201;

            @JsonProperty("jisx0208-1978")
            private List<String> jisx0208_1978;

            @JsonProperty("jisx0208-1978-windows")
            private List<String> jisx0208_1978_windows;

            @JsonProperty("jisx0208-verbatim")
            private String jisx0208_verbatim;
        }

        @Override
        public HyphensRecord deserialize(JsonParser p, DeserializationContext ctxt)
                throws IOException, JacksonException {
            final _HyphensRecord record = p.readValueAs(_HyphensRecord.class);
            return new HyphensRecord(
                    UnicodeUtils.parseUnicodeCodepoint(record.code),
                    record.name,
                    UnicodeUtils.parseUnicodeCodepoint(record.ascii),
                    record.shiftJis.stream().mapToInt(Integer::valueOf).toArray(),
                    UnicodeUtils.parseUnicodeCodepoint(record.jisx0201),
                    UnicodeUtils.parseUnicodeCodepoint(record.jisx0208_1978),
                    UnicodeUtils.parseUnicodeCodepoint(record.jisx0208_1978_windows),
                    UnicodeUtils.parseUnicodeCodepoint(record.jisx0208_verbatim));
        }

        public Deserializer() {
            super(HyphensRecord.class);
        }
    }

    private int code;

    private String name;

    private int[] ascii;

    private int[] shiftJis;

    private int[] jisx0201;

    private int[] jisx0208_1978;

    private int[] jisx0208_1978_windows;

    private int jisx0208_verbatim;

    /**
     * Returns the Unicode code point of this hyphen character.
     *
     * @return the Unicode code point
     */
    public int getCode() {
        return code;
    }

    /**
     * Returns the Unicode name of this hyphen character.
     *
     * @return the character name
     */
    public String getName() {
        return name;
    }

    /**
     * Returns the ASCII equivalent code points for this hyphen.
     *
     * @return the ASCII code points, or {@code null} if not applicable
     */
    public int[] getAscii() {
        return ascii;
    }

    /**
     * Returns the Shift-JIS byte sequence for this hyphen.
     *
     * @return the Shift-JIS bytes as integers
     */
    public int[] getShiftJis() {
        return shiftJis;
    }

    /**
     * Returns the JIS X 0201 equivalent code points for this hyphen.
     *
     * @return the JIS X 0201 code points, or {@code null} if not applicable
     */
    public int[] getJisx0201() {
        return jisx0201;
    }

    /**
     * Returns the JIS X 0208-1978 equivalent code points for this hyphen.
     *
     * @return the JIS X 0208-1978 code points, or {@code null} if not applicable
     */
    public int[] getJisx0208_1978() {
        return jisx0208_1978;
    }

    /**
     * Returns the JIS X 0208-1978 (Windows variant) equivalent code points for this hyphen.
     *
     * @return the JIS X 0208-1978 Windows code points, or {@code null} if not applicable
     */
    public int[] getJisx0208_1978_windows() {
        return jisx0208_1978_windows;
    }

    /**
     * Returns the verbatim JIS X 0208 code point for this hyphen.
     *
     * @return the verbatim JIS X 0208 code point
     */
    public int getJisx0208_verbatim() {
        return jisx0208_verbatim;
    }

    /**
     * Constructs a {@code HyphensRecord} with all hyphen encoding fields.
     *
     * @param code the Unicode code point
     * @param name the Unicode character name
     * @param ascii the ASCII equivalent code points
     * @param shiftJis the Shift-JIS byte sequence
     * @param jisx0201 the JIS X 0201 equivalent code points
     * @param jisx0208_1978 the JIS X 0208-1978 equivalent code points
     * @param jisx0208_1978_windows the JIS X 0208-1978 Windows variant code points
     * @param jisx0208_verbatim the verbatim JIS X 0208 code point
     */
    public HyphensRecord(
            int code,
            String name,
            int[] ascii,
            int[] shiftJis,
            int[] jisx0201,
            int[] jisx0208_1978,
            int[] jisx0208_1978_windows,
            int jisx0208_verbatim) {
        this.code = code;
        this.name = name;
        this.ascii = ascii;
        this.shiftJis = shiftJis;
        this.jisx0201 = jisx0201;
        this.jisx0208_1978 = jisx0208_1978;
        this.jisx0208_1978_windows = jisx0208_1978_windows;
        this.jisx0208_verbatim = jisx0208_verbatim;
    }
}
