package io.yosina.codegen;

import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** Utility class for Unicode operations. */
public class UnicodeUtils {
    private static final Pattern UNICODE_PATTERN = Pattern.compile("^U\\+([0-9A-Fa-f]+)$");

    /** Parse a Unicode codepoint representation like "U+1234" to integer. */
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

    public static int[] parseUnicodeCodepoint(List<String> cpReprs) {
        return cpReprs == null
                ? null
                : cpReprs.stream().mapToInt(UnicodeUtils::parseUnicodeCodepoint).toArray();
    }

    /** Escape a string for Java code generation. */
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
