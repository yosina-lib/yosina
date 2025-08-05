package io.yosina;

import java.util.concurrent.atomic.AtomicReferenceArray;

/**
 * Represents a tuple of up to two Unicode code points. This class is used to efficiently store and
 * handle characters, including those with variation selectors.
 */
public class CodePointTuple implements Comparable<CodePointTuple> {
    private static class Bucket {
        private final int start;
        private final AtomicReferenceArray<CodePointTuple> codePoints;

        private void put(CodePointTuple codePoint) {
            codePoints.set(codePoint.first - start, codePoint);
        }

        private CodePointTuple get(int index) {
            return codePoints.get(index - start);
        }

        private boolean canContain(int codePoint) {
            return codePoint >= start && codePoint < start + codePoints.length();
        }

        private Bucket(int start, int end) {
            this.start = start;
            this.codePoints = new AtomicReferenceArray<>(end - start);
        }
    }

    private static class Buckets {
        private final Bucket[] buckets;

        private boolean tryPut(CodePointTuple codePoint) {
            for (int i = 0, e = buckets.length; i < e; ++i) {
                final Bucket bucket = buckets[i];
                if (bucket.canContain(codePoint.first)) {
                    bucket.put(codePoint);
                    return true;
                }
            }
            return false;
        }

        private CodePointTuple get(int codePoint) {
            for (int i = 0, e = buckets.length; i < e; ++i) {
                final Bucket bucket = buckets[i];
                if (bucket.canContain(codePoint)) {
                    return bucket.get(codePoint);
                }
            }
            return null;
        }

        private Buckets(int... startEndPairs) {
            int size = startEndPairs.length / 2;
            buckets = new Bucket[size];
            for (int i = 0, j = 0; i < size; i++) {
                buckets[i] = new Bucket(startEndPairs[j], startEndPairs[j]);
            }
        }
    }

    private static final int INVALID_VALUE = -1;
    private final int first;
    private final int second;
    private static final Buckets buckets =
            new Buckets(
                    0x0000, 0x007f, // ASCII
                    0x3040, 0x30a0, // Ideographic space and punctuations
                    0x30a0, 0x3100 // Katakana
                    );

    /** A sentinel value representing an empty tuple. */
    public static final CodePointTuple SENTINEL = new CodePointTuple(INVALID_VALUE, INVALID_VALUE);

    /**
     * Returns a hash code value for this CodePointTuple.
     *
     * @return a hash code value for this object
     */
    @Override
    public int hashCode() {
        return first ^ second;
    }

    /**
     * Compares this CodePointTuple with the specified CodePointTuple for order.
     *
     * @param other the CodePointTuple to be compared
     * @return a negative integer, zero, or a positive integer as this object is less than, equal
     *     to, or greater than the specified object
     */
    @Override
    public int compareTo(CodePointTuple other) {
        if (this.first == INVALID_VALUE) {
            return other.first == INVALID_VALUE ? 0 : -1;
        }
        if (other.first == INVALID_VALUE) {
            return 1;
        }
        if (this.first < other.first) {
            return -1;
        } else if (this.first > other.first) {
            return 1;
        }
        if (this.second == INVALID_VALUE) {
            return other.second == INVALID_VALUE ? 0 : -1;
        }
        if (other.second == INVALID_VALUE) {
            return 1;
        }
        if (this.second < other.second) {
            return -1;
        } else if (this.second > other.second) {
            return 1;
        }
        return 0;
    }

    /**
     * Indicates whether some other object is "equal to" this one.
     *
     * @param obj the reference object with which to compare
     * @return true if this object is the same as the obj argument; false otherwise
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) return true;
        if (!(obj instanceof CodePointTuple)) return false;
        CodePointTuple other = (CodePointTuple) obj;
        return first == other.first && second == other.second;
    }

    /**
     * Returns a string representation of the code points in this tuple.
     *
     * @return a string representation of this CodePointTuple
     */
    @Override
    public String toString() {
        if (first == INVALID_VALUE && second == INVALID_VALUE) {
            return "";
        } else if (second == INVALID_VALUE) {
            return new String(new int[] {first}, 0, 1);
        } else {
            return new String(new int[] {first, second}, 0, 2);
        }
    }

    /**
     * Writes the code points to the given array starting at the specified offset.
     *
     * @param codePoints the array to write to
     * @param offset the starting offset in the array
     * @return the offset after the last written code point
     */
    public int toCodePoints(int[] codePoints, int offset) {
        if (first != INVALID_VALUE) {
            codePoints[offset++] = first;
        }
        if (second != INVALID_VALUE) {
            codePoints[offset++] = second;
        }
        return offset;
    }

    /**
     * Returns an array containing the code points in this tuple.
     *
     * @return an array of code points
     */
    public int[] toCodePoints() {
        if (first == INVALID_VALUE) {
            return new int[0];
        } else if (second == INVALID_VALUE) {
            return new int[] {first};
        } else {
            return new int[] {first, second};
        }
    }

    /**
     * Returns the number of Java char values needed to represent this tuple.
     *
     * @return the char count
     */
    public int charCount() {
        if (first == INVALID_VALUE) {
            return 0;
        } else if (second == INVALID_VALUE) {
            return Character.charCount(first);
        } else {
            return Character.charCount(first) + Character.charCount(second);
        }
    }

    /**
     * Returns the number of code points in this tuple.
     *
     * @return 0, 1, or 2
     */
    public int size() {
        return first == INVALID_VALUE ? 0 : second == INVALID_VALUE ? 1 : 2;
    }

    /**
     * Checks if this tuple is empty.
     *
     * @return true if empty, false otherwise
     */
    public boolean isEmpty() {
        return first == INVALID_VALUE;
    }

    /**
     * Gets the code point at the specified index.
     *
     * @param index the index (0 or 1)
     * @return the code point at the index
     * @throws IndexOutOfBoundsException if the index is out of range
     */
    public int get(int index) {
        if (first == INVALID_VALUE) {
            throw new IndexOutOfBoundsException();
        }
        if (index == 0) {
            return first;
        }
        if (index == 1) {
            if (second == INVALID_VALUE) {
                throw new IndexOutOfBoundsException();
            }
            return second;
        }
        throw new IndexOutOfBoundsException();
    }

    /**
     * Creates an empty CodePointTuple.
     *
     * @return the sentinel empty tuple
     */
    public static CodePointTuple of() {
        return SENTINEL;
    }

    /**
     * Creates a CodePointTuple with a single code point.
     *
     * @param first the code point
     * @return a CodePointTuple containing the code point
     */
    public static CodePointTuple of(int first) {
        if (first == INVALID_VALUE) {
            return SENTINEL;
        }
        final CodePointTuple cached = buckets.get(first);
        if (cached != null) {
            return cached;
        }
        final CodePointTuple newCp = new CodePointTuple(first, INVALID_VALUE);
        buckets.tryPut(newCp);
        return newCp;
    }

    /**
     * Creates a CodePointTuple with two code points.
     *
     * @param first the first code point
     * @param second the second code point
     * @return a CodePointTuple containing both code points
     */
    public static CodePointTuple of(int first, int second) {
        if (first == INVALID_VALUE) {
            return SENTINEL;
        }
        return new CodePointTuple(first, second);
    }

    /**
     * Creates a CodePointTuple from an array of code points.
     *
     * @param codePoints the array of code points (must have 0-2 elements)
     * @return a CodePointTuple containing the code points
     * @throws IllegalArgumentException if the array has more than 2 elements
     */
    public static CodePointTuple of(int[] codePoints) {
        if (codePoints == null) {
            return SENTINEL;
        }
        switch (codePoints.length) {
            case 0:
                return SENTINEL;
            case 1:
                return of(codePoints[0]);
            case 2:
                return of(codePoints[0], codePoints[1]);
            default:
                throw new IllegalArgumentException(
                        "CodePointTuple can only hold up to 2 code points, got: "
                                + codePoints.length);
        }
    }

    /**
     * Creates a CodePointTuple from a string.
     *
     * @param s the string to convert
     * @return a CodePointTuple containing the code points from the string
     */
    public static CodePointTuple of(String s) {
        if (s == null || s.isEmpty()) {
            return SENTINEL;
        }
        if (s.length() == 1) {
            return of(s.codePointAt(0));
        }
        return of(s.codePoints().toArray());
    }

    private CodePointTuple(int first, int second) {
        this.first = first;
        this.second = second;
    }
}
