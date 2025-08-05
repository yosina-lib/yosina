package io.yosina.annotations;

/**
 * Annotation to mark a transliterator for automatic registration. Transliterators marked with this
 * annotation will be discoverable through the transliterator factory system.
 */
public @interface RegisteredTransliterator {
    /**
     * The name used to identify this transliterator. This name will be used when requesting the
     * transliterator from the factory.
     *
     * @return the unique name identifier for the transliterator
     */
    String name();
}
