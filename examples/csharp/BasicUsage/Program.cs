// Basic usage example for Yosina C# library.
// This example demonstrates the fundamental transliteration functionality
// as shown in the README documentation.

using System;
using Yosina;

namespace YosinaExamples
{
    class BasicUsage
    {
        static void Main(string[] args)
        {
            Console.WriteLine("=== Yosina C# Basic Usage Example ===\n");

            // Create a recipe with desired transformations (matching README example)
            var recipe = new TransliteratorRecipe
            {
                KanjiOldNew = true,
                ReplaceSpaces = true,
                ReplaceSuspiciousHyphensToProlongedSoundMarks = true,
                ReplaceCircledOrSquaredCharacters = TransliteratorRecipe.ReplaceCircledOrSquaredCharactersOptions.Enabled,
                ReplaceCombinedCharacters = true,
                ToFullwidth = TransliteratorRecipe.ToFullwidthOptions.Enabled
            };

            // Create the transliterator
            var transliterator = Entrypoint.MakeTransliterator(recipe);

            // Use it with various special characters (matching README example)
            var input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"; // circled numbers, letters, space, combined characters
            var result = transliterator(input);

            Console.WriteLine($"Input:  {input}");
            Console.WriteLine($"Output: {result}");
            Console.WriteLine("Expected: （１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和");

            // Convert old kanji to new
            Console.WriteLine("\n--- Old Kanji to New ---");
            var oldKanji = "舊字體";
            result = transliterator(oldKanji);
            Console.WriteLine($"Input:  {oldKanji}");
            Console.WriteLine($"Output: {result}");
            Console.WriteLine("Expected: 旧字体");

            // Convert half-width katakana to full-width
            Console.WriteLine("\n--- Half-width to Full-width ---");
            var halfWidth = "ﾃｽﾄﾓｼﾞﾚﾂ";
            result = transliterator(halfWidth);
            Console.WriteLine($"Input:  {halfWidth}");
            Console.WriteLine($"Output: {result}");
            Console.WriteLine("Expected: テストモジレツ");

            // Additional examples to demonstrate individual transformations
            Console.WriteLine("\n--- Individual Transformation Examples ---");

            var testCases = new[]
            {
                ("①②③", "Circled numbers"),
                ("ⒶⒷⒸ", "Circled letters"),
                ("　", "Ideographic space (U+3000)"),
                ("㍿", "Combined character (株式会社)"),
                ("㍑", "Combined character (リットル)"),
                ("㌠", "Combined character (サンチーム)"),
                ("㋿", "Combined character (令和)"),
                ("舊", "Old kanji (舊)"),
                ("體", "Old kanji (體)"),
                ("ﾃｽﾄ", "Half-width katakana")
            };

            foreach (var (testInput, description) in testCases)
            {
                result = transliterator(testInput);
                Console.WriteLine($"{description}: '{testInput}' → '{result}'");
            }
        }
    }
}