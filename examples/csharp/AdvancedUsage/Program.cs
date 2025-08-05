// Advanced usage examples for Yosina C# library.
// This example demonstrates various real-world use cases and techniques.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Yosina;
using Yosina.Transliterators;

namespace YosinaExamples
{
    class AdvancedUsage
    {
        static void Main(string[] args)
        {
            Console.WriteLine("=== Advanced Yosina C# Usage Examples ===\n");

            // 1. Web scraping text normalization
            {
                Console.WriteLine("1. Web Scraping Text Normalization");
                Console.WriteLine("   (Typical use case: cleaning scraped Japanese web content)");

                var webScrapingRecipe = new TransliterationRecipe
                {
                    KanjiOldNew = true,
                    ReplaceSpaces = true,
                    ReplaceSuspiciousHyphensToProlongedSoundMarks = true,
                    ReplaceIdeographicAnnotations = true,
                    ReplaceRadicals = true,
                    CombineDecomposedHiraganasAndKatakanas = true
                };

                var normalizer = Entrypoint.MakeTransliterator(webScrapingRecipe);

                // Simulate messy web content
                var messyContent = new[]
                {
                    ("これは　テスト です。", "Mixed spaces from different sources"),
                    ("コンピューター-プログラム", "Suspicious hyphens in katakana"),
                    ("古い漢字：廣島、檜、國", "Old-style kanji forms"),
                    ("部首：⺅⻌⽊", "CJK radicals instead of regular kanji")
                };

                foreach (var (text, description) in messyContent)
                {
                    var cleaned = normalizer(text);
                    Console.WriteLine($"  {description}:");
                    Console.WriteLine($"    Before: '{text}'");
                    Console.WriteLine($"    After:  '{cleaned}'");
                    Console.WriteLine();
                }
            }

            // 2. Document standardization
            {
                Console.WriteLine("2. Document Standardization");
                Console.WriteLine("   (Use case: preparing documents for consistent formatting)");

                var documentRecipe = new TransliterationRecipe
                {
                    ToFullwidth = TransliterationRecipe.ToFullwidthOptions.Enabled,
                    ReplaceSpaces = true,
                    KanjiOldNew = true,
                    CombineDecomposedHiraganasAndKatakanas = true
                };

                var documentStandardizer = Entrypoint.MakeTransliterator(documentRecipe);

                var documentSamples = new[]
                {
                    ("Hello World 123", "ASCII text to full-width"),
                    ("カ゛", "Decomposed katakana with combining mark"),
                    ("檜原村", "Old kanji in place names")
                };

                foreach (var (text, description) in documentSamples)
                {
                    var standardized = documentStandardizer(text);
                    Console.WriteLine($"  {description}:");
                    Console.WriteLine($"    Input:  '{text}'");
                    Console.WriteLine($"    Output: '{standardized}'");
                    Console.WriteLine();
                }
            }

            // 3. Search index preparation
            {
                Console.WriteLine("3. Search Index Preparation");
                Console.WriteLine("   (Use case: normalizing text for search engines)");

                var searchRecipe = new TransliterationRecipe
                {
                    KanjiOldNew = true,
                    ReplaceSpaces = true,
                    ToHalfwidth = TransliterationRecipe.ToHalfwidthOptions.Enabled,
                    ReplaceSuspiciousHyphensToProlongedSoundMarks = true
                };

                var searchNormalizer = Entrypoint.MakeTransliterator(searchRecipe);

                var searchSamples = new[]
                {
                    ("東京スカイツリー", "Famous landmark name"),
                    ("プログラミング言語", "Technical terms"),
                    ("コンピューター-サイエンス", "Academic field with suspicious hyphen")
                };

                foreach (var (text, description) in searchSamples)
                {
                    var normalized = searchNormalizer(text);
                    Console.WriteLine($"  {description}:");
                    Console.WriteLine($"    Original:   '{text}'");
                    Console.WriteLine($"    Normalized: '{normalized}'");
                    Console.WriteLine();
                }
            }

            // 4. Custom pipeline example
            {
                Console.WriteLine("4. Custom Processing Pipeline");
                Console.WriteLine("   (Use case: step-by-step text transformation)");

                // Create multiple transliterators for pipeline processing
                var steps = new[]
                {
                    ("Spaces", new[] { new TransliteratorConfig("spaces") }),
                    ("Old Kanji", new[]
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
                    }),
                    ("Width", new[]
                    {
                        new TransliteratorConfig("jisx0201-and-alike", new Jisx0201AndAlikeTransliterator.Options
                        {
                            U005cAsYenSign = false
                        })
                    }),
                    ("ProlongedSoundMarks", new[] { new TransliteratorConfig("prolonged-sound-marks") })
                };

                var transliterators = new List<(string name, Func<string, string> transliterator)>();
                foreach (var (name, config) in steps)
                {
                    var t = Entrypoint.MakeTransliterator(config);
                    transliterators.Add((name, t));
                }

                var pipelineText = "hello　world ﾃｽﾄ 檜-システム";
                var currentText = pipelineText;

                Console.WriteLine($"  Starting text: '{currentText}'");

                foreach (var (stepName, transliterator) in transliterators)
                {
                    var previousText = currentText;
                    currentText = transliterator(currentText);
                    if (previousText != currentText)
                    {
                        Console.WriteLine($"  After {stepName}: '{currentText}'");
                    }
                }

                Console.WriteLine($"  Final result: '{currentText}'");
            }

            // 5. Unicode normalization showcase
            {
                Console.WriteLine("\n5. Unicode Normalization Showcase");
                Console.WriteLine("   (Demonstrating various Unicode edge cases)");

                var unicodeRecipe = new TransliterationRecipe
                {
                    ReplaceSpaces = true,
                    ReplaceMathematicalAlphanumerics = true,
                    ReplaceRadicals = true
                };

                var unicodeNormalizer = Entrypoint.MakeTransliterator(unicodeRecipe);

                var unicodeSamples = new List<(string text, string description)>
                {
                    ("\u2003\u2002\u2000", "Various em/en spaces"),
                    ("\u3000\u00A0\u202F", "Ideographic and narrow spaces"),
                    ("⺅⻌⽊", "CJK radicals"),
                    ("\U0001D400\U0001D401\U0001D402", "Mathematical bold letters")
                };

                Console.WriteLine("\n   Processing text samples with character codes:\n");
                foreach (var (text, description) in unicodeSamples)
                {
                    Console.WriteLine($"   {description}:");
                    Console.WriteLine($"     Original: '{text}'");

                    // Show character codes for clarity
                    var codes = text.Select(c => $"U+{(int)c:X4}");
                    Console.WriteLine($"     Codes:    {string.Join(" ", codes)}");

                    var transliterated = unicodeNormalizer(text);
                    Console.WriteLine($"     Result:   '{transliterated}'\n");
                }
            }

            // 6. Performance considerations
            {
                Console.WriteLine("6. Performance Considerations");
                Console.WriteLine("   (Reusing transliterators for better performance)");

                var perfRecipe = new TransliterationRecipe
                {
                    KanjiOldNew = true,
                    ReplaceSpaces = true
                };

                var perfTransliterator = Entrypoint.MakeTransliterator(perfRecipe);

                // Simulate processing multiple texts
                var texts = new[]
                {
                    "これはテストです",
                    "檜原村は美しい",
                    "hello　world",
                    "プログラミング"
                };

                Console.WriteLine($"  Processing {texts.Length} texts with the same transliterator:");
                for (int i = 0; i < texts.Length; i++)
                {
                    var text = texts[i];
                    var result = perfTransliterator(text);
                    Console.WriteLine($"    {i + 1}: '{text}' → '{result}'");
                }
            }

            Console.WriteLine("\n=== Advanced Examples Complete ===");
        }
    }
}