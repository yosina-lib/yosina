package io.yosina;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.function.Function;
import java.util.stream.Collectors;

/** Main entry point for the Yosina Japanese text transliteration library. */
public class Yosina {

    /** Configuration for a transliterator. */
    public static class TransliteratorConfig {
        private final String name;
        private final Optional<Object> options;

        /**
         * Gets the name of the transliterator.
         *
         * @return the name of the transliterator
         */
        public String getName() {
            return name;
        }

        /**
         * Gets the options for the transliterator.
         *
         * @return the options for the transliterator
         */
        public Optional<Object> getOptions() {
            return options;
        }

        /**
         * Creates a TransliteratorConfig with the specified name and optional options.
         *
         * @param name the name of the transliterator
         * @param options optional configuration options for the transliterator
         */
        public TransliteratorConfig(String name, Optional<Object> options) {
            this.name = name;
            this.options = options;
        }

        /**
         * Creates a TransliteratorConfig with the specified name and options.
         *
         * @param name the name of the transliterator
         * @param options configuration options for the transliterator
         */
        public TransliteratorConfig(String name, Object options) {
            this.name = name;
            this.options = Optional.of(options);
        }

        /**
         * Creates a TransliteratorConfig with the specified name and no options.
         *
         * @param name the name of the transliterator
         */
        public TransliteratorConfig(String name) {
            this.name = name;
            this.options = Optional.empty();
        }
    }

    private static final String TRANSLITERATORS_PACKAGE_REL = "transliterators";
    private static final String TRANSLITERATORS_MANIFEST_NAME = "TRANSLITERATORS";
    private static volatile Map<String, Class<Transliterator>> registeredTransliterators;

    /**
     * Creates a string-to-string transliterator function from a list of configurations.
     *
     * @param configs the list of transliterator configurations to chain together
     * @return a function that applies the chained transliterations to input strings
     */
    public static Function<String, String> makeTransliterator(List<TransliteratorConfig> configs) {
        List<Transliterator> transliterators = new ArrayList<>();

        for (TransliteratorConfig config : configs) {
            Transliterator transliterator =
                    createTransliterator(config.getName(), config.getOptions());
            transliterators.add(transliterator);
        }

        ChainedTransliterator chained = new ChainedTransliterator(transliterators);

        return (String input) -> chained.transliterate(Chars.of(input).iterator()).string();
    }

    /**
     * Creates a transliterator function from a single configuration.
     *
     * @param name the name of the transliterator
     * @param options optional configuration options for the transliterator
     * @return a function that applies the transliteration to input strings
     */
    public static Function<String, String> makeTransliterator(
            String name, Optional<Object> options) {
        final Transliterator transliterator = createTransliterator(name, options);
        return (String input) -> transliterator.transliterate(Chars.of(input).iterator()).string();
    }

    /**
     * Creates a transliterator function from a single configuration with options.
     *
     * @param name the name of the transliterator
     * @param options configuration options for the transliterator
     * @return a function that applies the transliteration to input strings
     */
    public static Function<String, String> makeTransliterator(String name, Object options) {
        return makeTransliterator(name, Optional.of(options));
    }

    /**
     * Creates a transliterator function with default options.
     *
     * @param name the name of the transliterator
     * @return a function that applies the transliteration to input strings
     */
    public static Function<String, String> makeTransliterator(String name) {
        return makeTransliterator(name, Optional.empty());
    }

    /**
     * Creates a transliterator function from a recipe.
     *
     * @param recipe The recipe specifying which transliterations to apply
     * @return A function that applies the configured transliterations to input strings
     */
    public static Function<String, String> makeTransliteratorFromRecipe(
            TransliterationRecipe recipe) {
        List<TransliteratorConfig> configs = recipe.buildTransliteratorConfigs();
        return makeTransliterator(configs);
    }

    private static Map<String, Class<Transliterator>> getRegisteredTransliteratorsInner()
            throws IOException {
        final Map<String, Class<Transliterator>> transliterators = new HashMap<>();
        final String manifestPath =
                TRANSLITERATORS_PACKAGE_REL + "/" + TRANSLITERATORS_MANIFEST_NAME;
        final InputStream s = Yosina.class.getResourceAsStream(manifestPath);
        if (s == null) {
            throw new RuntimeException("No transliterators manifest found under " + manifestPath);
        }
        try (s) {
            final BufferedReader r = new BufferedReader(new InputStreamReader(s));
            for (String line; (line = r.readLine()) != null; ) {
                final String[] elems = line.stripTrailing().split("\\s+");
                if (elems.length != 2) {
                    continue;
                }
                try {
                    @SuppressWarnings("unchecked")
                    final Class<Transliterator> class_ =
                            (Class<Transliterator>) Class.forName(elems[1]);
                    if (!Transliterator.class.isAssignableFrom(class_)) {
                        continue;
                    }
                    transliterators.put(elems[0], class_);
                } catch (ClassNotFoundException e) {
                    continue;
                }
            }
        }
        return transliterators;
    }

    /**
     * Returns a map of all registered transliterators.
     *
     * @return an unmodifiable map where keys are transliterator names and values are their classes
     * @throws RuntimeException if failed to load the transliterators manifest
     */
    public static Map<String, Class<Transliterator>> getRegisteredTransliterators() {
        if (registeredTransliterators != null) {
            return registeredTransliterators;
        }
        try {
            registeredTransliterators =
                    Collections.unmodifiableMap(getRegisteredTransliteratorsInner());
        } catch (IOException e) {
            throw new RuntimeException("Failed to load registered transliterators", e);
        }
        return registeredTransliterators;
    }

    private static Transliterator createTransliterator(String name, Optional<Object> options) {
        Class<Transliterator> class_ = getRegisteredTransliterators().get(name);
        if (class_ == null) {
            throw new IllegalArgumentException(
                    "Unknown transliterator: "
                            + name
                            + " (available: "
                            + getRegisteredTransliterators().keySet().stream()
                                    .collect(Collectors.joining(", "))
                            + ")");
        }
        final Constructor<?>[] ctors = class_.getConstructors();
        final List<Class<?>> otherCandidates = new ArrayList<>();

        if (options.isEmpty()) {
            // If no options are provided, try to find a default constructor
            for (Constructor<?> ctor : ctors) {
                if (ctor.getParameterCount() == 0) {
                    try {
                        return (Transliterator) ctor.newInstance();
                    } catch (InstantiationException
                            | IllegalAccessException
                            | InvocationTargetException e) {
                        throw new RuntimeException("Failed to create transliterator: " + name, e);
                    }
                }
            }
            throw new IllegalArgumentException(
                    "Transliterator " + name + " has no default constructor");
        } else {
            final Object options_ = options.get();
            // First try to find a constructor with a parameters
            for (Constructor<?> ctor : ctors) {
                final Class<?>[] paramTypes = ctor.getParameterTypes();
                if (paramTypes.length != 1) {
                    continue; // We only care about single-parameter constructors
                }
                if (paramTypes[0].isAssignableFrom(options_.getClass())) {
                    try {
                        return (Transliterator) ctor.newInstance(options_);
                    } catch (Exception e) {
                        throw new RuntimeException(
                                "Failed to create transliterator with options: " + name, e);
                    }
                } else {
                    otherCandidates.add(paramTypes[0]);
                }
            }
            throw new IllegalArgumentException(
                    "Transliterator "
                            + name
                            + " has a constructor(s) with a single parameter"
                            + " that take(s) "
                            + otherCandidates.stream()
                                    .map(Class::getName)
                                    .collect(Collectors.joining(", "))
                            + ", but type "
                            + options.getClass().getName()
                            + " was provided as the options");
        }
    }
}
