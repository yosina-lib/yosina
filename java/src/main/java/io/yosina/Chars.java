package io.yosina;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.PrimitiveIterator;
import java.util.Spliterator;
import java.util.stream.IntStream;
import java.util.stream.StreamSupport;

/** Utility methods for working with characters and character arrays. */
public interface Chars {
    /** Checks if a code point is a variation selector. */
    private static boolean isVariationSelector(int codePoint) {
        // Variation Selector-1 to Variation Selector-16 (U+FE00–U+FE0F)
        // Variation Selector-17 to Variation Selector-256 (U+E0100–U+E01EF)
        return (codePoint >= 0xFE00 && codePoint <= 0xFE0F)
                || (codePoint >= 0xE0100 && codePoint <= 0xE01EF);
    }

    /** Represents a Chars implementation backed by a list of Char objects. */
    public static class OfList implements Chars {
        private List<Char> chars;

        /**
         * Returns an iterator over the code points in this OfList.
         *
         * @return a primitive iterator of code points
         */
        @Override
        public PrimitiveIterator.OfInt codePointIterator() {
            return CodePoints.iteratorOf(iterator());
        }

        /**
         * Returns a stream of code points from this OfList.
         *
         * @return an IntStream of code points
         */
        @Override
        public IntStream codePointStream() {
            return StreamSupport.intStream(
                    CodePoints.spliteratorOf(this.chars.spliterator()), false);
        }

        /**
         * Returns an iterator over the characters in this OfList.
         *
         * @return a CharIterator over the characters
         */
        @Override
        public CharIterator iterator() {
            return new CharIterator() {
                private int i = 0;

                @Override
                public boolean hasNext() {
                    return i < chars.size();
                }

                @Override
                public Char next() {
                    return chars.get(i++);
                }

                @Override
                public long estimateSize() {
                    return (long) chars.size();
                }

                @Override
                public int characteristics() {
                    return Spliterator.ORDERED
                            | Spliterator.NONNULL
                            | Spliterator.IMMUTABLE
                            | Spliterator.SIZED;
                }
            };
        }

        /**
         * Returns the number of Char objects in this OfList.
         *
         * @return the number of Char objects
         */
        @Override
        public int count() {
            return this.chars.size();
        }

        /**
         * Returns the total number of code points in all Char objects.
         *
         * @return the total number of code points
         */
        @Override
        public int codePointCount() {
            return this.chars.stream().mapToInt(c -> c.get().size()).sum();
        }

        /**
         * Returns the total number of Java chars needed to represent all characters.
         *
         * @return the total number of Java chars
         */
        @Override
        public int charCount() {
            return this.chars.stream().mapToInt(c -> c.get().charCount()).sum();
        }

        /**
         * Returns the underlying list of Char objects.
         *
         * @return the list of Char objects
         */
        @Override
        public List<Char> toList() {
            return this.chars;
        }

        /**
         * Creates a new instance of OfList with the specified characters.
         *
         * @param chars A list of Char objects representing the characters
         */
        public OfList(List<Char> chars) {
            this.chars = chars;
        }

        /**
         * Converts a text string into an array of Char objects, properly handling Ideographic
         * Variation Sequences (IVS) and Standardized Variation Sequences (SVS).
         *
         * @param text the text string to convert
         * @return a list of Char objects representing the text
         */
        public static List<Char> build(String text) {
            List<Char> result = new ArrayList<>();
            int prevChar = -1;
            int offset = 0;
            int[] codePoints = text.codePoints().toArray();
            for (int i = 0; i < codePoints.length; i++) {
                final int codePoint = codePoints[i];
                // Check for variation selectors
                if (prevChar >= 0) {
                    if (isVariationSelector(codePoint)) {
                        // Combine base character with variation selector
                        final var ct = CodePointTuple.of(prevChar, codePoint);
                        result.add(new Char(ct, offset, null));
                        offset += ct.charCount();
                        prevChar = -1;
                    } else {
                        final var ct = CodePointTuple.of(prevChar);
                        result.add(new Char(ct, offset, null));
                        offset += ct.charCount();
                        prevChar = codePoint;
                    }
                } else {
                    prevChar = codePoint;
                }
            }
            // Handle last character
            if (prevChar >= 0) {
                result.add(new Char(CodePointTuple.of(prevChar), offset, null));
                offset += Character.charCount(prevChar);
            }
            // Add sentinel character to mark end of input
            result.add(new Char(CodePointTuple.SENTINEL, offset, null));
            return result;
        }

        /**
         * Creates a new OfList instance from a string.
         *
         * @param chars the string to convert to a list of Char objects
         * @return a new OfList instance containing the characters
         */
        public static OfList of(String chars) {
            return new OfList(Collections.unmodifiableList(build(chars)));
        }
    }

    /**
     * Creates a new Chars instance from a string.
     *
     * @param text the text string to convert
     * @return a new Chars instance containing the characters
     */
    public static Chars of(String text) {
        return OfList.of(text);
    }

    /**
     * Returns an iterator over the code points in this Chars object.
     *
     * @return An iterator over the code points
     */
    PrimitiveIterator.OfInt codePointIterator();

    /**
     * Returns a stream of code points from this Chars object.
     *
     * @return A stream of code points
     */
    IntStream codePointStream();

    /**
     * Returns an iterator over the characters in this Chars object.
     *
     * @return An iterator over the characters
     */
    CharIterator iterator();

    /**
     * Returns the number of characters, or -1 if unknown.
     *
     * @return The number of characters, or -1 if unknown
     */
    default int count() {
        return -1;
    }

    /**
     * Returns the number of code points in this Chars object if known, or -1 if unknown.
     *
     * @return The number of code points, or -1 if unknown
     */
    default int codePointCount() {
        return -1;
    }

    /**
     * Returns the number of char's, or -1 if unknown.
     *
     * @return the number of Java char values needed, or -1 if unknown
     */
    default int charCount() {
        return -1;
    }

    /**
     * Returns a string representation of the characters in this Chars object.
     *
     * @return A string representation of the characters
     */
    default String string() {
        final int[] codePoints = codePointStream().toArray();
        final int size = codePoints.length;
        return new String(codePoints, 0, size);
    }

    /**
     * Returns a list of Char objects representing the characters in this Chars object.
     *
     * @return a list of Char objects
     */
    default List<Char> toList() {
        return StreamSupport.stream(iterator(), false).toList();
    }
}
