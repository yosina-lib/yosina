package examples;

import java.util.function.Function;
import io.yosina.TransliterationRecipe;
import io.yosina.Yosina;

/**
 * Basic usage example for Yosina Java library.
 * This example demonstrates the fundamental transliteration functionality
 * as shown in the README documentation.
 */
public class BasicUsage {
    public static void main(String[] args) {
        System.out.println("=== Yosina Java Basic Usage Example ===\n");

        // Create a recipe with desired transformations (matching README example)
        TransliterationRecipe recipe = new TransliterationRecipe()
                .withKanjiOldNew(true)
                .withReplaceSpaces(true)
                .withReplaceSuspiciousHyphensToProlongedSoundMarks(true)
                .withReplaceCircledOrSquaredCharacters(
                        TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.ENABLED)
                .withReplaceCombinedCharacters(true)
                .withReplaceJapaneseIterationMarks(true)  // Expand iteration marks
                .withToFullwidth(TransliterationRecipe.ToFullwidthOptions.ENABLED);

        // Create the transliterator
        Function<String, String> transliterator = Yosina.makeTransliteratorFromRecipe(recipe);

        // Use it with various special characters (matching README example)
        String input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿";  // circled numbers, letters, space, combined characters
        String result = transliterator.apply(input);

        System.out.println("Input:  " + input);
        System.out.println("Output: " + result);
        System.out.println("Expected: （１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和");

        // Convert old kanji to new
        System.out.println("\n--- Old Kanji to New ---");
        String oldKanji = "舊字體";
        result = transliterator.apply(oldKanji);
        System.out.println("Input:  " + oldKanji);
        System.out.println("Output: " + result);
        System.out.println("Expected: 旧字体");

        // Convert half-width katakana to full-width
        System.out.println("\n--- Half-width to Full-width ---");
        String halfWidth = "ﾃｽﾄﾓｼﾞﾚﾂ";
        result = transliterator.apply(halfWidth);
        System.out.println("Input:  " + halfWidth);
        System.out.println("Output: " + result);
        System.out.println("Expected: テストモジレツ");

        // Demonstrate Japanese iteration marks expansion
        System.out.println("\n--- Japanese Iteration Marks Examples ---");
        String[] iterationExamples = {
            "佐々木",  // kanji iteration
            "すゝき",  // hiragana iteration
            "いすゞ",  // hiragana voiced iteration
            "サヽキ",  // katakana iteration
            "ミスヾ"   // katakana voiced iteration
        };

        for (String text : iterationExamples) {
            result = transliterator.apply(text);
            System.out.println(text + " → " + result);
        }

        // Demonstrate hiragana to katakana conversion separately
        System.out.println("\n--- Hiragana to Katakana Conversion ---");
        // Create a separate recipe for just hiragana to katakana conversion
        TransliterationRecipe hiraKataRecipe = new TransliterationRecipe()
                .withHiraKata("hira-to-kata");  // Convert hiragana to katakana

        Function<String, String> hiraKataTransliterator = 
                Yosina.makeTransliteratorFromRecipe(hiraKataRecipe);

        String[] hiraKataExamples = {
            "ひらがな",  // pure hiragana
            "これはひらがなです",  // hiragana sentence
            "ひらがなとカタカナ"   // mixed hiragana and katakana
        };

        for (String text : hiraKataExamples) {
            result = hiraKataTransliterator.apply(text);
            System.out.println(text + " → " + result);
        }

        // Also demonstrate katakana to hiragana conversion
        System.out.println("\n--- Katakana to Hiragana Conversion ---");
        TransliterationRecipe kataHiraRecipe = new TransliterationRecipe()
                .withHiraKata("kata-to-hira");  // Convert katakana to hiragana

        Function<String, String> kataHiraTransliterator = 
                Yosina.makeTransliteratorFromRecipe(kataHiraRecipe);

        String[] kataHiraExamples = {
            "カタカナ",  // pure katakana
            "コレハカタカナデス",  // katakana sentence
            "カタカナとひらがな"   // mixed katakana and hiragana
        };

        for (String text : kataHiraExamples) {
            result = kataHiraTransliterator.apply(text);
            System.out.println(text + " → " + result);
        }
    }
}