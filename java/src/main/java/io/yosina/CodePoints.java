package io.yosina;

import java.util.Iterator;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.PrimitiveIterator;
import java.util.Spliterator;
import java.util.function.IntConsumer;

/** Utility class for converting between Char iterators and code point iterators. */
public final class CodePoints {
    /**
     * Creates a code point iterator from a Char iterator.
     *
     * @param input the Char iterator to convert
     * @return a PrimitiveIterator.OfInt that iterates over code points
     */
    public static PrimitiveIterator.OfInt iteratorOf(final Iterator<Char> input) {
        return new PrimitiveIterator.OfInt() {
            int i = 0;
            Optional<CodePointTuple> codePoint = Optional.empty();

            @Override
            public boolean hasNext() {
                if (codePoint.isEmpty()) {
                    if (!input.hasNext()) {
                        return false;
                    }
                    final Char c = input.next();
                    if (c.isSentinel()) {
                        return false;
                    }
                    codePoint = Optional.of(c.get());
                } else if (i >= codePoint.get().size()) {
                    return false;
                }
                return true;
            }

            @Override
            public int nextInt() {
                if (codePoint.isEmpty()) {
                    final Char c = input.next();
                    if (c.isSentinel()) {
                        throw new NoSuchElementException("No more characters in iterator");
                    }
                    i = 0;
                    codePoint = Optional.of(c.get());
                }
                final CodePointTuple cp = codePoint.get();
                final int v = cp.get(i++);
                if (i >= cp.size()) {
                    i = 0;
                    codePoint = Optional.empty();
                }
                return v;
            }
        };
    }

    /**
     * Creates a code point spliterator from a Char spliterator.
     *
     * @param input the Char spliterator to convert
     * @return a Spliterator.OfInt that splits over code points
     */
    public static Spliterator.OfInt spliteratorOf(final Spliterator<Char> input) {
        return new Spliterator.OfInt() {
            int i = 0;
            Optional<CodePointTuple> codePoint = Optional.empty();

            @Override
            public boolean tryAdvance(IntConsumer action) {
                if (codePoint.isEmpty()) {
                    if (!input.tryAdvance(
                            c -> {
                                if (c.isSentinel()) {
                                    codePoint = Optional.empty();
                                    return;
                                }
                                codePoint = Optional.of(c.get());
                            })) {
                        return false;
                    }
                    if (codePoint.isEmpty()) {
                        return false;
                    }
                }
                final CodePointTuple cp = codePoint.get();
                final int v = cp.get(i++);
                if (i >= cp.size()) {
                    i = 0;
                    codePoint = Optional.empty();
                }
                action.accept(v);
                return true;
            }

            @Override
            public long estimateSize() {
                return input.estimateSize();
            }

            @Override
            public int characteristics() {
                return Spliterator.ORDERED | Spliterator.NONNULL | Spliterator.IMMUTABLE;
            }

            @Override
            public OfInt trySplit() {
                return null; // No splitting for this iterator
            }
        };
    }
}
