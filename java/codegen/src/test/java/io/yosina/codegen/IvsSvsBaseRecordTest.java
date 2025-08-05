package io.yosina.codegen;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

public class IvsSvsBaseRecordTest {
    @Test
    public void testIvsSvsBaseDeserialization() throws Exception {
        String json =
                """
                {
                    "ivs": ["U+3042"],
                    "svs": ["U+30A2"],
                    "base90": "U+0041",
                    "base2004": "U+0042"
                }
                """;

        final ObjectMapper objectMapper = new ObjectMapper();
        final IvsSvsBaseRecord record = objectMapper.readValue(json, IvsSvsBaseRecord.class);
        assertArrayEquals(new int[] {0x3042}, record.getIvs());
        assertArrayEquals(new int[] {0x30A2}, record.getSvs());
        assertEquals(0x0041, record.getBase90());
        assertEquals(0x0042, record.getBase2004());
    }
}
