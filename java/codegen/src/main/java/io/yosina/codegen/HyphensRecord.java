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

    public int getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public int[] getAscii() {
        return ascii;
    }

    public int[] getShiftJis() {
        return shiftJis;
    }

    public int[] getJisx0201() {
        return jisx0201;
    }

    public int[] getJisx0208_1978() {
        return jisx0208_1978;
    }

    public int[] getJisx0208_1978_windows() {
        return jisx0208_1978_windows;
    }

    public int getJisx0208_verbatim() {
        return jisx0208_verbatim;
    }

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
