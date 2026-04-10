package com.yosina.examples;

import com.ibm.icu.text.Transliterator;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;

/**
 * Basic usage example for Yosina ICU transliteration rules with ICU4J.
 *
 * <p>Demonstrates loading rule files, creating transliterators, and chaining
 * them into a pipeline — the ICU equivalent of Yosina's recipe system.
 *
 * <p>Run: {@code gradle run}
 */
public class BasicUsage {

    /**
     * Path to the ICU rule files relative to the project root.
     * Adjust if running from a different directory.
     */
    private static final String RULES_DIR = "../../icu/rules/";

    /**
     * Load ICU transliteration rules from a file.
     */
    private static String loadRules(String ruleFile) throws IOException {
        return Files.readString(
            Path.of(RULES_DIR, ruleFile), StandardCharsets.UTF_8);
    }

    /**
     * Create a Transliterator from a rule file and register it globally
     * so it can be referenced by ID in compound transliterators.
     */
    private static Transliterator createAndRegister(String id, String ruleFile)
            throws IOException {
        String rules = loadRules(ruleFile);
        Transliterator t =
            Transliterator.createFromRules(id, rules, Transliterator.FORWARD);
        Transliterator.registerInstance(t);
        return t;
    }

    /**
     * Transliterate a string and print the result.
     */
    private static void demonstrate(
            Transliterator t, String label, String input) {
        String output = t.transliterate(input);
        System.out.println(label);
        System.out.println("  Input:  " + input);
        System.out.println("  Output: " + output);
        System.out.println();
    }

    public static void main(String[] args) throws IOException {
        System.out.println("=== Yosina ICU4J Basic Usage Example ===\n");

        // --- Individual transliterators ---

        System.out.println("--- Individual transliterators ---\n");

        Transliterator spaces =
            createAndRegister("Yosina-Spaces", "spaces.txt");
        demonstrate(spaces,
            "Spaces (normalize Unicode spaces to ASCII):",
            "Hello\u3000World");

        Transliterator kanjiOldNew =
            createAndRegister("Yosina-KanjiOldNew", "kanji_old_new.txt");
        demonstrate(kanjiOldNew,
            "Kanji Old-New (modernize old-style kanji):",
            "舊字體の變換");

        Transliterator hiraToKata =
            createAndRegister("Yosina-HiraToKata", "hira_to_kata.txt");
        demonstrate(hiraToKata,
            "Hira-to-Kata (convert hiragana to katakana):",
            "ひらがな");

        Transliterator fw2hw =
            createAndRegister("Yosina-Fw2Hw", "jisx0201_and_alike.txt");
        demonstrate(fw2hw,
            "Fullwidth-to-Halfwidth:",
            "\uFF21\uFF22\uFF23\uFF11\uFF12\uFF13");

        Transliterator iterMarks =
            createAndRegister("Yosina-IterMarks",
                "japanese_iteration_marks.txt");
        demonstrate(iterMarks,
            "Japanese Iteration Marks (expand 々, ゝ, etc.):",
            "時々佐々木");

        Transliterator prolonged =
            createAndRegister("Yosina-Prolonged",
                "prolonged_sound_marks.txt");
        demonstrate(prolonged,
            "Prolonged Sound Marks (hyphen after katakana \u2192 prolonged mark):",
            "カトラリ-");

        // --- Chained pipeline ---

        System.out.println("--- Chained pipeline ---\n");

        // Build a pipeline equivalent to a Yosina recipe with:
        //   spaces + kanji_old_new + jisx0201_and_alike
        //
        // Since transliterators are registered above, we can reference them
        // by ID using ICU's compound transliterator syntax (semicolons).
        Transliterator pipeline = Transliterator.getInstance(
            "Yosina-Spaces; Yosina-KanjiOldNew; Yosina-Fw2Hw");

        demonstrate(pipeline,
            "Pipeline (spaces + kanji_old_new + jisx0201_and_alike):",
            "東京醫科大學\u3000附屬病院");

        // --- Chaining with NFC for composition ---

        System.out.println("--- Chaining with NFC ---\n");

        // hira_kata_composition handles non-combining marks (゛ ゜);
        // chain with ::NFC; to also compose combining marks (U+3099, U+309A).
        String compositionRules = loadRules("hira_kata_composition.txt");
        Transliterator composition = Transliterator.createFromRules(
            "Yosina-Composition",
            compositionRules + "\n::NFC;",
            Transliterator.FORWARD);

        demonstrate(composition,
            "Composition with NFC (non-combining \u309B and combining U+3099):",
            "か\u309Bき\u3099は\u309C");
    }
}
