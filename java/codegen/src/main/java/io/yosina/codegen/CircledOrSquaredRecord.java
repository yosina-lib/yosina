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

    /**
     * Returns the rendering string of this record.
     *
     * @return the rendering
     */
    public String getRendering() {
        return rendering;
    }

    /**
     * Sets the rendering string of this record.
     *
     * @param rendering the rendering to set
     */
    public void setRendering(String rendering) {
        this.rendering = rendering;
    }

    /**
     * Returns the type of this record.
     *
     * @return the type
     */
    public String getType() {
        return type;
    }

    /**
     * Sets the type of this record.
     *
     * @param type the type to set
     */
    public void setType(String type) {
        this.type = type;
    }

    /**
     * Returns whether this record represents an emoji character.
     *
     * @return {@code true} if this is an emoji record
     */
    public boolean isEmoji() {
        return emoji;
    }

    /**
     * Sets whether this record represents an emoji character.
     *
     * @param emoji {@code true} if this is an emoji record
     */
    public void setEmoji(boolean emoji) {
        this.emoji = emoji;
    }

    /** Constructs an empty {@code CircledOrSquaredRecord} for deserialization. */
    public CircledOrSquaredRecord() {}

    /**
     * Constructs a {@code CircledOrSquaredRecord} with the given values.
     *
     * @param rendering the rendering string
     * @param type the character type
     * @param emoji whether this is an emoji character
     */
    public CircledOrSquaredRecord(String rendering, String type, boolean emoji) {
        this.rendering = rendering;
        this.type = type;
        this.emoji = emoji;
    }
}
