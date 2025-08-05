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

        public Deserializer() {
            super(KanjiOldNewRecord.class);
        }
    }

    private IvsSvsPair traditional;

    private IvsSvsPair new_;

    public IvsSvsPair getTraditional() {
        return traditional;
    }

    public IvsSvsPair getNew() {
        return new_;
    }

    public KanjiOldNewRecord(IvsSvsPair traditional, IvsSvsPair new_) {
        this.traditional = traditional;
        this.new_ = new_;
    }

    public KanjiOldNewRecord() {
        this.traditional = null;
        this.new_ = null;
    }
}
