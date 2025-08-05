package io.yosina.codegen;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

public class KanjiOldNewRecordTest {
    @Test
    public void testIvsSvsBaseDeserialization() throws Exception {
        String json =
                """
                [
                    {
                        "ivs": ["U+3042"],
                        "svs": ["U+3042"]
                    },
                    {
                        "ivs": ["U+30A2"],
                        "svs": ["U+30A2"]
                    }
                ]
                """;

        final ObjectMapper objectMapper = new ObjectMapper();
        final KanjiOldNewRecord record = objectMapper.readValue(json, KanjiOldNewRecord.class);
        assertArrayEquals(new int[] {0x3042}, record.getTraditional().getIvs());
        assertArrayEquals(new int[] {0x3042}, record.getTraditional().getSvs());
        assertArrayEquals(new int[] {0x30a2}, record.getNew().getIvs());
        assertArrayEquals(new int[] {0x30a2}, record.getNew().getSvs());
    }
}
