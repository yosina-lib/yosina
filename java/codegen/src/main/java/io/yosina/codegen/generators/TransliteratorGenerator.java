package io.yosina.codegen.generators;

import io.yosina.codegen.Artifact;
import java.util.List;

/** Base class for transliterator generators. */
public interface TransliteratorGenerator {
    /** Generates the transliterator file. */
    public List<Artifact> generate();

    /** Converts snake_case to PascalCase. */
    public static String toCamelCase(String snakeCase) {
        StringBuilder result = new StringBuilder();
        boolean capitalizeNext = true;
        for (char c : snakeCase.toCharArray()) {
            if (c == '_') {
                capitalizeNext = true;
            } else if (capitalizeNext) {
                result.append(Character.toUpperCase(c));
                capitalizeNext = false;
            } else {
                result.append(c);
            }
        }
        return result.toString();
    }
}
