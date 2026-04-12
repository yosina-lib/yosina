package io.yosina.codegen;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** Utility class for Unicode operations. */
public final class UnicodeUtils {
    private UnicodeUtils() {}

    private static final Pattern UNICODE_PATTERN = Pattern.compile("^U\\+([0-9A-Fa-f]+)$");

    /**
     * Parse a Unicode codepoint representation like "U+1234" to integer.
     *
     * @param cpRepr the Unicode codepoint representation string
     * @return the parsed codepoint as an integer
     */
    public static int parseUnicodeCodepoint(String cpRepr) {
        if (cpRepr == null) {
            return -1;
        }

        Matcher matcher = UNICODE_PATTERN.matcher(cpRepr);
        if (!matcher.matches()) {
            throw new IllegalArgumentException(
                    "Invalid Unicode codepoint representation: " + cpRepr);
        }

        return Integer.parseInt(matcher.group(1), 16);
    }

    /**
     * Parse a list of Unicode codepoint representations to an int array.
     *
     * @param cpReprs the list of Unicode codepoint representation strings
     * @return the parsed codepoints as an int array, or {@code null} if the input is {@code null}
     */
    public static int[] parseUnicodeCodepoint(List<String> cpReprs) {
        return cpReprs == null
                ? null
                : cpReprs.stream().mapToInt(UnicodeUtils::parseUnicodeCodepoint).toArray();
    }

    /**
     * Convert a Unicode codepoint representation like "U+1234" to a String.
     *
     * @param cpRepr the Unicode codepoint representation string
     * @return the corresponding String
     */
    public static String unicodeToString(String cpRepr) {
        int codepoint = parseUnicodeCodepoint(cpRepr);
        return new String(Character.toChars(codepoint));
    }

    /**
     * Escape a string for Java code generation.
     *
     * @param str the string to escape
     * @return the escaped string
     */
    public static String escapeJavaString(String str) {
        if (str == null) {
            return "null";
        }
        return str.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }
}
