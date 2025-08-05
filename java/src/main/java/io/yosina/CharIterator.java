package io.yosina;

import java.util.Iterator;
import java.util.PrimitiveIterator;
import java.util.Spliterator;
import java.util.stream.IntStream;
import java.util.stream.StreamSupport;

/** Iterator interface for traversing character sequences. */
public interface CharIterator extends Iterator<Char>, Spliterator<Char>, Chars {
    /**
     * Performs the given action for each remaining element until all elements have been processed
     * or the action throws an exception.
     *
     * @param action the action to be performed for each element
     */
    @Override
    default void forEachRemaining(java.util.function.Consumer<? super Char> action) {
        Iterator.super.forEachRemaining(action);
    }

    /**
     * If a remaining element exists, performs the given action on it, returning true; else returns
     * false.
     *
     * @param action the action to be performed on the next element
     * @return true if the action was performed, false if no remaining elements exist
     */
    @Override
    default boolean tryAdvance(java.util.function.Consumer<? super Char> action) {
        if (hasNext()) {
            action.accept(next());
            return true;
        }
        return false;
    }

    /**
     * Attempts to partition this spliterator. This implementation does not support splitting.
     *
     * @return null as splitting is not supported
     */
    @Override
    default Spliterator<Char> trySplit() {
        return null; // No splitting support
    }

    /**
     * Returns an estimate of the number of elements that would be encountered by a forEachRemaining
     * traversal. This implementation returns Long.MAX_VALUE indicating unknown size.
     *
     * @return Long.MAX_VALUE indicating unknown size
     */
    @Override
    default long estimateSize() {
        return Long.MAX_VALUE; // Size is unknown
    }

    /**
     * Returns a set of characteristics of this Spliterator and its elements. The characteristics
     * are ORDERED, NONNULL, and IMMUTABLE.
     *
     * @return a representation of characteristics as ORed values
     */
    @Override
    default int characteristics() {
        return Spliterator.ORDERED | Spliterator.NONNULL | Spliterator.IMMUTABLE;
    }

    /**
     * Returns an iterator over the characters. Since this is already an iterator, it returns
     * itself.
     *
     * @return this iterator instance
     */
    @Override
    default CharIterator iterator() {
        return this; // This iterator is self-referential
    }

    /**
     * Returns an iterator over the code points represented by this character iterator.
     *
     * @return a primitive iterator of code points
     */
    @Override
    default PrimitiveIterator.OfInt codePointIterator() {
        return CodePoints.iteratorOf(this);
    }

    /**
     * Returns a stream of code points represented by this character iterator.
     *
     * @return an IntStream of code points
     */
    @Override
    default IntStream codePointStream() {
        return StreamSupport.intStream(CodePoints.spliteratorOf(this), false);
    }

    /**
     * Returns the count of characters, or -1 if the size is unknown.
     *
     * @return the character count, or -1 if unknown
     */
    @Override
    default int count() {
        final long size = estimateSize();
        return (int) size == Long.MAX_VALUE ? -1 : (int) size;
    }

    /**
     * Returns the count of code points. This implementation returns -1 indicating unknown count.
     *
     * @return -1 indicating unknown code point count
     */
    @Override
    default int codePointCount() {
        return -1;
    }

    /**
     * Returns the count of Java chars. This implementation returns -1 indicating unknown count.
     *
     * @return -1 indicating unknown char count
     */
    @Override
    default int charCount() {
        return -1;
    }
}
