package io.yosina.codegen;

import com.fasterxml.jackson.annotation.JsonProperty;

/** Represents a circled or squared character record. */
public class CircledOrSquaredRecord {
    @JsonProperty("rendering")
    private String rendering;

    @JsonProperty("type")
    private String type;

    @JsonProperty("emoji")
    private boolean emoji;

    public String getRendering() {
        return rendering;
    }

    public void setRendering(String rendering) {
        this.rendering = rendering;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public boolean isEmoji() {
        return emoji;
    }

    public void setEmoji(boolean emoji) {
        this.emoji = emoji;
    }

    public CircledOrSquaredRecord() {}

    public CircledOrSquaredRecord(String rendering, String type, boolean emoji) {
        this.rendering = rendering;
        this.type = type;
        this.emoji = emoji;
    }
}
