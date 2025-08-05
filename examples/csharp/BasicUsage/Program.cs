// Basic usage example for Yosina C# library.
// This example demonstrates the fundamental transliteration functionality
// as shown in the README documentation.

using System;
using Yosina;
using HiraKataMode = Yosina.Transliterators.HiraKataTransliterator.Mode;

namespace YosinaExamples
{
    class BasicUsage
    {
        static void Main(string[] args)
        {
            Console.WriteLine("=== Yosina C# Basic Usage Example ===\n");

            // Create a recipe with desired transformations (matching README example)
            var recipe = new TransliterationRecipe
            {
                KanjiOldNew = true,
                ReplaceSpaces = true,
                ReplaceSuspiciousHyphensToProlongedSoundMarks = true,
                ReplaceCircledOrSquaredCharacters = TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.Enabled,
                ReplaceCombinedCharacters = true,
                ReplaceJapaneseIterationMarks = true, // Expand iteration marks
                ToFullwidth = TransliterationRecipe.ToFullwidthOptions.Enabled
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

            // Demonstrate Japanese iteration marks expansion
            Console.WriteLine("\n--- Japanese Iteration Marks Examples ---");
            var iterationExamples = new[]
            {
                "佐々木", // kanji iteration
                "すゝき", // hiragana iteration
                "いすゞ", // hiragana voiced iteration
                "サヽキ", // katakana iteration
                "ミスヾ"  // katakana voiced iteration
            };

            foreach (var text in iterationExamples)
            {
                result = transliterator(text);
                Console.WriteLine($"{text} → {result}");
            }

            // Demonstrate hiragana to katakana conversion separately
            Console.WriteLine("\n--- Hiragana to Katakana Conversion ---");
            // Create a separate recipe for just hiragana to katakana conversion
            var hiraKataRecipe = new TransliterationRecipe
            {
                HiraKata = HiraKataMode.HiraToKata // Convert hiragana to katakana
            };

            var hiraKataTransliterator = Entrypoint.MakeTransliterator(hiraKataRecipe);

            var hiraKataExamples = new[]
            {
                "ひらがな", // pure hiragana
                "これはひらがなです", // hiragana sentence
                "ひらがなとカタカナ" // mixed hiragana and katakana
            };

            foreach (var text in hiraKataExamples)
            {
                result = hiraKataTransliterator(text);
                Console.WriteLine($"{text} → {result}");
            }

            // Also demonstrate katakana to hiragana conversion
            Console.WriteLine("\n--- Katakana to Hiragana Conversion ---");
            var kataHiraRecipe = new TransliterationRecipe
            {
                HiraKata = HiraKataMode.KataToHira // Convert katakana to hiragana
            };

            var kataHiraTransliterator = Entrypoint.MakeTransliterator(kataHiraRecipe);

            var kataHiraExamples = new[]
            {
                "カタカナ", // pure katakana
                "コレハカタカナデス", // katakana sentence
                "カタカナとひらがな" // mixed katakana and hiragana
            };

            foreach (var text in kataHiraExamples)
            {
                result = kataHiraTransliterator(text);
                Console.WriteLine($"{text} → {result}");
            }
        }
    }
}
