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

        public Deserializer() {
            super(IvsSvsBaseRecord.class);
        }
    }

    private int base90;

    private int base2004;

    public int getBase90() {
        return base90;
    }

    public int getBase2004() {
        return base2004;
    }

    public IvsSvsBaseRecord(int[] ivs, int[] svs, int base90, int base2004) {
        super(ivs, svs);
        this.base90 = base90;
        this.base2004 = base2004;
    }

    public IvsSvsBaseRecord() {
        super();
        this.base90 = -1;
        this.base2004 = -1;
    }
}
