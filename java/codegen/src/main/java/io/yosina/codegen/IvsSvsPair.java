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
    /** Jackson deserializer for {@link IvsSvsPair}. */
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

        /** Constructs a {@code Deserializer} for {@link IvsSvsPair}. */
        public Deserializer() {
            super(IvsSvsPair.class);
        }
    }

    private int[] ivs;
    private int[] svs;

    /**
     * Returns the IVS (Ideographic Variation Sequence) code points.
     *
     * @return the IVS code points, or {@code null} if absent
     */
    public int[] getIvs() {
        return ivs;
    }

    /**
     * Returns the SVS (Standardized Variation Sequence) code points.
     *
     * @return the SVS code points, or {@code null} if absent
     */
    public int[] getSvs() {
        return svs;
    }

    /**
     * Constructs an {@code IvsSvsPair} with the given IVS and SVS code points.
     *
     * @param ivs the IVS code points
     * @param svs the SVS code points
     */
    public IvsSvsPair(int[] ivs, int[] svs) {
        this.ivs = ivs;
        this.svs = svs;
    }

    /** Constructs an empty {@code IvsSvsPair} for deserialization. */
    public IvsSvsPair() {
        this.ivs = null;
        this.svs = null;
    }
}
