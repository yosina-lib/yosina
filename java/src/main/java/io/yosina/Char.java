package io.yosina;

/**
 * Represents a character with metadata for transliteration. Properly handles Ideographic Variation
 * Sequences (IVS) and Standardized Variation Sequences (SVS).
 */
public class Char {
    /** The character data (may contain variation selector) */
    private final CodePointTuple c;

    /** The byte offset in the original string */
    private final int offset;

    /** The original character this was derived from (for tracking transformations) */
    private final Char source;

    /**
     * Gets the CodePointTuple representing this character.
     *
     * @return the CodePointTuple containing the character data
     */
    public CodePointTuple get() {
        return c;
    }

    /**
     * Gets the byte offset of this character in the original string.
     *
     * @return the byte offset
     */
    public int getOffset() {
        return offset;
    }

    /**
     * Gets the original character this was derived from.
     *
     * @return the source character, or null if this is an original character
     */
    public Char getSource() {
        return source;
    }

    /**
     * Returns the number of Java char values needed to represent this character.
     *
     * @return the number of char values
     */
    public int charCount() {
        return c.size();
    }

    /**
     * Returns true if this is a sentinel character (marks end of input).
     *
     * @return true if this character is a sentinel, false otherwise
     */
    public boolean isSentinel() {
        return c.isEmpty();
    }

    /**
     * Checks if this character has been transliterated.
     *
     * @return true if this character has been transliterated, false otherwise
     */
    public boolean isTransliterated() {
        Char c = this;
        for (; ; ) {
            final Char s = c.getSource();
            if (s == null) {
                break;
            }
            if (!c.get().equals(s.get())) {
                return true;
            }
            c = s;
        }
        return false;
    }

    /**
     * Returns a string representation of this Char for debugging purposes.
     *
     * @return a string representation of this Char
     */
    @Override
    public String toString() {
        return String.format(
                "Char(%s, %d, %s)",
                c.toString(), offset, source != null ? source.toString() : "null");
    }

    /**
     * Indicates whether some other object is "equal to" this one.
     *
     * @param obj the reference object with which to compare
     * @return true if this object is the same as the obj argument; false otherwise
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!(obj instanceof Char)) {
            return false;
        }
        final Char other = (Char) obj;
        return c.equals(other.c) && offset == other.offset && source == other.source;
    }

    /**
     * Creates a new character with the same data but different offset.
     *
     * @param newOffset The new offset for the character
     * @return A new Char instance with the updated offset
     */
    public Char withOffset(int newOffset) {
        return new Char(this.c, newOffset, this);
    }

    /**
     * Creates a new Char instance with the specified CodePointTuple,
     *
     * @param c The CodePointTuple representing the character data
     * @param offset The byte offset in the original string
     * @param source The original character this was derived from (for tracking transformations)
     */
    public Char(CodePointTuple c, int offset, Char source) {
        this.c = c;
        this.offset = offset;
        this.source = source;
    }
}
