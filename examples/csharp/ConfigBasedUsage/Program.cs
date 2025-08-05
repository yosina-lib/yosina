// Configuration-based usage example for Yosina C# library.
// This example demonstrates using direct transliterator configurations.

using System;
using System.Collections.Generic;
using Yosina;
using Yosina.Transliterators;

namespace YosinaExamples
{
    class ConfigBasedUsage
    {
        static void Main(string[] args)
        {
            Console.WriteLine("=== Yosina C# Configuration-based Usage Example ===\n");

            // Create transliterator with direct configurations
            var configs = new[]
            {
                new TransliteratorConfig("spaces"),
                new TransliteratorConfig("prolonged-sound-marks", new ProlongedSoundMarksTransliterator.Options
                {
                    ReplaceProlongedMarksFollowingAlnums = true
                }),
                new TransliteratorConfig("jisx0201-and-alike")
            };

            var transliterator = Entrypoint.MakeTransliterator(configs);

            Console.WriteLine("--- Configuration-based Transliteration ---");

            // Test cases demonstrating different transformations
            var testCases = new[]
            {
                ("hello　world", "Space normalization"),
                ("カタカナーテスト", "Prolonged sound mark handling"),
                ("ＡＢＣ１２３", "Full-width conversion"),
                ("ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana conversion")
            };

            foreach (var (testText, description) in testCases)
            {
                var result = transliterator(testText);
                Console.WriteLine($"{description}:");
                Console.WriteLine($"  Input:  '{testText}'");
                Console.WriteLine($"  Output: '{result}'");
                Console.WriteLine();
            }

            // Demonstrate individual transliterators
            Console.WriteLine("--- Individual Transliterator Examples ---");

            // Spaces only
            var spacesConfig = new[] { new TransliteratorConfig("spaces") };
            var spacesOnly = Entrypoint.MakeTransliterator(spacesConfig);
            var spaceTest = "hello　world　test"; // ideographic spaces
            Console.WriteLine($"Spaces only: '{spaceTest}' → '{spacesOnly(spaceTest)}'");

            // Kanji old-new only
            var kanjiConfig = new[]
            {
                new TransliteratorConfig("ivs-svs-base", new IvsSvsBaseTransliterator.Options
                {
                    Mode = IvsSvsBaseTransliterator.Mode.IvsSvs,
                    Charset = IvsSvsBaseTransliterator.Charset.UniJis2004
                }),
                new TransliteratorConfig("kanji-old-new"),
                new TransliteratorConfig("ivs-svs-base", new IvsSvsBaseTransliterator.Options
                {
                    Mode = IvsSvsBaseTransliterator.Mode.Base,
                    Charset = IvsSvsBaseTransliterator.Charset.UniJis2004
                })
            };
            var kanjiOnly = Entrypoint.MakeTransliterator(kanjiConfig);
            var kanjiTest = "廣島檜";
            Console.WriteLine($"Kanji only: '{kanjiTest}' → '{kanjiOnly(kanjiTest)}'");

            // JIS X 0201 conversion only
            var jisx0201Config = new[] {
                new TransliteratorConfig("jisx0201-and-alike", new Jisx0201AndAlikeTransliterator.Options {
                    FullwidthToHalfwidth = false
                })
            };
            var jisx0201Only = Entrypoint.MakeTransliterator(jisx0201Config);
            var jisxTest = "ﾊﾛｰ ﾜｰﾙﾄﾞ";
            Console.WriteLine($"JIS X 0201 only: '{jisxTest}' → '{jisx0201Only(jisxTest)}'");
        }
    }
}
