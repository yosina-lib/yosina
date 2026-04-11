package io.yosina.codegen;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JacksonException;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.deser.std.StdDeserializer;
import java.io.IOException;
import java.util.List;

/** Represents an IVS/SVS base mapping record. */
@JsonDeserialize(using = IvsSvsBaseRecord.Deserializer.class)
public class IvsSvsBaseRecord extends IvsSvsPair {
    /** Jackson deserializer for {@link IvsSvsBaseRecord}. */
    public static class Deserializer extends StdDeserializer<IvsSvsPair> {
        private static final class _IvsSvsBaseRecord {
            @JsonProperty("ivs")
            private List<String> ivs;

            @JsonProperty("svs")
            private List<String> svs;

            @JsonProperty("base90")
            private String base90;

            @JsonProperty("base2004")
            private String base2004;
        }

        @Override
        public IvsSvsBaseRecord deserialize(JsonParser p, DeserializationContext ctxt)
                throws IOException, JacksonException {
            final _IvsSvsBaseRecord pair = p.readValueAs(_IvsSvsBaseRecord.class);
            return new IvsSvsBaseRecord(
                    pair.ivs != null ? UnicodeUtils.parseUnicodeCodepoint(pair.ivs) : null,
                    pair.svs != null ? UnicodeUtils.parseUnicodeCodepoint(pair.svs) : null,
                    pair.base90 != null ? UnicodeUtils.parseUnicodeCodepoint(pair.base90) : -1,
                    pair.base2004 != null ? UnicodeUtils.parseUnicodeCodepoint(pair.base2004) : -1);
        }

        /** Constructs a {@code Deserializer} for {@link IvsSvsBaseRecord}. */
        public Deserializer() {
            super(IvsSvsBaseRecord.class);
        }
    }

    private int base90;

    private int base2004;

    /**
     * Returns the base code point under the UniJIS-90 (JIS X 0208-1990) standard, or {@code -1} if
     * not applicable.
     *
     * @return the UniJIS-90 base code point
     */
    public int getBase90() {
        return base90;
    }

    /**
     * Returns the base code point under the UniJIS-2004 standard, or {@code -1} if not applicable.
     *
     * @return the UniJIS-2004 base code point
     */
    public int getBase2004() {
        return base2004;
    }

    /**
     * Constructs an {@code IvsSvsBaseRecord} with all fields.
     *
     * @param ivs the IVS code points
     * @param svs the SVS code points
     * @param base90 the UniJIS-90 base code point, or {@code -1}
     * @param base2004 the UniJIS-2004 base code point, or {@code -1}
     */
    public IvsSvsBaseRecord(int[] ivs, int[] svs, int base90, int base2004) {
        super(ivs, svs);
        this.base90 = base90;
        this.base2004 = base2004;
    }

    /** Constructs an empty {@code IvsSvsBaseRecord} for deserialization. */
    public IvsSvsBaseRecord() {
        super();
        this.base90 = -1;
        this.base2004 = -1;
    }
}
