package io.yosina.codegen;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.core.JacksonException;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.deser.std.StdDeserializer;
import java.io.IOException;
import java.util.List;

/** Represents a kanji old-new form mapping record. */
@JsonDeserialize(using = IvsSvsPair.Deserializer.class)
public class IvsSvsPair {
    public static class Deserializer extends StdDeserializer<IvsSvsPair> {
        private static final class _IvsSvsPair {
            @JsonProperty("ivs")
            private List<String> ivs;

            @JsonProperty("svs")
            private List<String> svs;
        }

        @Override
        public IvsSvsPair deserialize(JsonParser p, DeserializationContext ctxt)
                throws IOException, JacksonException {
            final _IvsSvsPair pair = p.readValueAs(_IvsSvsPair.class);
            return new IvsSvsPair(
                    pair.ivs != null ? UnicodeUtils.parseUnicodeCodepoint(pair.ivs) : null,
                    pair.svs != null ? UnicodeUtils.parseUnicodeCodepoint(pair.svs) : null);
        }

        public Deserializer() {
            super(IvsSvsPair.class);
        }
    }

    private int[] ivs;
    private int[] svs;

    public int[] getIvs() {
        return ivs;
    }

    public int[] getSvs() {
        return svs;
    }

    public IvsSvsPair(int[] ivs, int[] svs) {
        this.ivs = ivs;
        this.svs = svs;
    }

    public IvsSvsPair() {
        this.ivs = null;
        this.svs = null;
    }
}
