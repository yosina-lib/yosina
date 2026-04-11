package io.yosina.codegen;

import com.fasterxml.jackson.core.JacksonException;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.deser.std.StdDeserializer;
import java.io.IOException;

/** Represents a kanji old-new form mapping record. */
@JsonDeserialize(using = KanjiOldNewRecord.Deserializer.class)
public class KanjiOldNewRecord {
    /** Jackson deserializer for {@link KanjiOldNewRecord}. */
    public static class Deserializer extends StdDeserializer<KanjiOldNewRecord> {
        @Override
        public KanjiOldNewRecord deserialize(JsonParser p, DeserializationContext ctxt)
                throws IOException, JacksonException {
            final IvsSvsPair[] pair = p.readValueAs(IvsSvsPair[].class);
            if (pair.length != 2) {
                throw new IOException(
                        "Expected exactly two records for KanjiOldNewRecord, but got: "
                                + pair.length);
            }
            if (pair[0] == null || pair[1] == null) {
                throw new IOException(
                        "Both traditional and new records must be present in KanjiOldNewRecord.");
            }
            return new KanjiOldNewRecord(pair[0], pair[1]);
        }

        /** Constructs a {@code Deserializer} for {@link KanjiOldNewRecord}. */
        public Deserializer() {
            super(KanjiOldNewRecord.class);
        }
    }

    private IvsSvsPair traditional;

    private IvsSvsPair new_;

    /**
     * Returns the traditional (old-form) kanji IVS/SVS pair.
     *
     * @return the traditional kanji pair
     */
    public IvsSvsPair getTraditional() {
        return traditional;
    }

    /**
     * Returns the new-form kanji IVS/SVS pair.
     *
     * @return the new kanji pair
     */
    public IvsSvsPair getNew() {
        return new_;
    }

    /**
     * Constructs a {@code KanjiOldNewRecord} with the given traditional and new form pairs.
     *
     * @param traditional the traditional (old-form) kanji pair
     * @param new_ the new-form kanji pair
     */
    public KanjiOldNewRecord(IvsSvsPair traditional, IvsSvsPair new_) {
        this.traditional = traditional;
        this.new_ = new_;
    }

    /** Constructs an empty {@code KanjiOldNewRecord} for deserialization. */
    public KanjiOldNewRecord() {
        this.traditional = null;
        this.new_ = null;
    }
}
