// Copyright (c) Yosina. All rights reserved.

using System.Text.Json;
using Yosina.Codegen.Generators;

using CodePointTuple = (int First, int Second);

namespace Yosina.Codegen;

internal static class Program
{
#pragma warning disable MA0051 // Method is too long
    private static void Main()
    {
        try
        {
            // Find project root
            var currentDir = Directory.GetCurrentDirectory();
            var projectRoot = FindProjectRoot(currentDir);
            var dataRoot = Path.Combine(projectRoot, "data");
            var destRoot = Path.Combine(projectRoot, "csharp", "src", "Yosina", "Transliterators");

            Console.WriteLine($"Data root: {dataRoot}");
            Console.WriteLine($"Destination root: {destRoot}");

            // Ensure destination directory exists
            Directory.CreateDirectory(destRoot);

            // Generate simple transliterators
            GenerateSimpleTransliterator(
                dataRoot,
                destRoot,
                "spaces",
                "spaces.json",
                "Replace various space characters with plain whitespace.");

            GenerateSimpleTransliterator(
                dataRoot,
                destRoot,
                "radicals",
                "radicals.json",
                "Replace Kangxi radicals with equivalent CJK ideographs.");

            GenerateSimpleTransliterator(
                dataRoot,
                destRoot,
                "mathematical_alphanumerics",
                "mathematical-alphanumerics.json",
                "Replace mathematical alphanumeric symbols with plain characters.");

            GenerateSimpleTransliterator(
                dataRoot,
                destRoot,
                "ideographic_annotations",
                "ideographic-annotation-marks.json",
                "Replace ideographic annotation marks used in traditional translation.");

            // Generate kanji old-new transliterator
            GenerateKanjiOldNewTransliterator(dataRoot, destRoot);

            // Generate hyphens transliterator
            GenerateHyphensTransliterator(dataRoot, destRoot);

            // Generate IVS/SVS base data file
            GenerateIvsSvsBaseData(dataRoot, destRoot);

            // Generate combined transliterator
            GenerateCombinedTransliterator(dataRoot, destRoot);

            // Generate circled-or-squared transliterator
            GenerateCircledOrSquaredTransliterator(dataRoot, destRoot);

            // Generate roman numerals transliterator
            GenerateRomanNumeralsTransliterator(dataRoot, destRoot);

            Console.WriteLine("Code generation complete!");
        }
        catch (IOException ex)
        {
            Console.Error.WriteLine($"IO Error: {ex.Message}");
            Environment.Exit(1);
        }
        catch (JsonException ex)
        {
            Console.Error.WriteLine($"JSON Parsing Error: {ex.Message}");
            Environment.Exit(1);
        }
        catch (InvalidOperationException ex)
        {
            Console.Error.WriteLine($"Invalid Operation: {ex.Message}");
            Environment.Exit(1);
        }
    }

    private static string FindProjectRoot(string startPath)
    {
        var current = new DirectoryInfo(startPath);
        while (current != null)
        {
            // Look for .git directory or data directory as project root markers
            if (Directory.Exists(Path.Combine(current.FullName, ".git")) ||
                Directory.Exists(Path.Combine(current.FullName, "data")))
            {
                return current.FullName;
            }

            current = current.Parent;
        }

        throw new InvalidOperationException("Could not find project root (.git or data directory not found)");
    }

    private static void GenerateSimpleTransliterator(string dataRoot, string destRoot, string name, string filename, string description)
    {
        Console.WriteLine($"Generating {name}...");

        var dataPath = Path.Combine(dataRoot, filename);
        var jsonContent = File.ReadAllText(dataPath);

        var rawMappings = JsonSerializer.Deserialize<Dictionary<string, string?>>(jsonContent);
        var mappings = new Dictionary<int, int>();

        if (rawMappings != null)
        {
            foreach (var kvp in rawMappings)
            {
                if (kvp.Value != null)
                {
                    var fromCodePoint = UnicodeUtils.ParseUnicodeCodepoint(kvp.Key);
                    var toCodePoint = UnicodeUtils.ParseUnicodeCodepoint(kvp.Value);
                    mappings[fromCodePoint] = toCodePoint;
                }
            }
        }

        if (mappings.Count == 0)
        {
            throw new InvalidOperationException($"Failed to deserialize {filename}");
        }

        var code = SimpleTransliteratorGenerator.Generate(name, description, mappings);
        var outputPath = Path.Combine(destRoot, $"{UnicodeUtils.ToPascalCase(name)}Transliterator.cs");

        File.WriteAllText(outputPath, code);
        Console.WriteLine($"  Written to: {Path.GetRelativePath(dataRoot, outputPath)}");
    }

    private static CodePointTuple JsonElementArrayToCodePointTuple(JsonElement array)
    {
        switch (array.GetArrayLength())
        {
            case 1:
                if (array[0].GetString() is string cp)
                {
                    return (UnicodeUtils.ParseUnicodeCodepoint(cp), -1);
                }
                else
                {
                    throw new ArgumentException("CodePoint value cannot be null");
                }

            case 2:
                if (array[0].GetString() is string cp1 && array[1].GetString() is string cp2)
                {
                    return (UnicodeUtils.ParseUnicodeCodepoint(cp1), UnicodeUtils.ParseUnicodeCodepoint(cp2));
                }
                else
                {
                    throw new ArgumentException("CodePoint value cannot be null");
                }

            default:
                throw new ArgumentException("CodePoint array must have 1 or 2 elements");
        }
    }

    private static void GenerateKanjiOldNewTransliterator(string dataRoot, string destRoot)
    {
        Console.WriteLine("Generating kanji_old_new...");

        var dataPath = Path.Combine(dataRoot, "kanji-old-new-form.json");
        var jsonContent = File.ReadAllText(dataPath);

        // The JSON is an array of pairs: [[old_ivs_record, new_ivs_record], ...]
        using var jsonDoc = JsonDocument.Parse(jsonContent);
        var mappings = new Dictionary<CodePointTuple, CodePointTuple>();

        foreach (var pair in jsonDoc.RootElement.EnumerateArray())
        {
            if (pair.GetArrayLength() >= 2)
            {
                var oldRecord = pair[0];
                var newRecord = pair[1];

                // Get the IVS codepoints from each record
                if (oldRecord.TryGetProperty("ivs", out var oldIvs) &&
                    newRecord.TryGetProperty("ivs", out var newIvs))
                {
                    mappings[JsonElementArrayToCodePointTuple(oldIvs)] = JsonElementArrayToCodePointTuple(newIvs);
                }
            }
        }

        if (mappings.Count == 0)
        {
            throw new InvalidOperationException("Failed to deserialize kanji-old-new-form.json");
        }

        var code = KanjiOldNewTransliteratorGenerator.Generate(
            "kanji_old_new",
            "Replace old-style kanji with modern equivalents.",
            mappings);
        var outputPath = Path.Combine(destRoot, "KanjiOldNewTransliterator.cs");

        File.WriteAllText(outputPath, code);
        Console.WriteLine($"  Written to: {Path.GetRelativePath(dataRoot, outputPath)}");
    }

    private static void GenerateHyphensTransliterator(string dataRoot, string destRoot)
    {
        Console.WriteLine("Generating hyphens...");

        var dataPath = Path.Combine(dataRoot, "hyphens.json");
        var jsonContent = File.ReadAllText(dataPath);
        var records = JsonSerializer.Deserialize<List<HyphensRecord>>(jsonContent);

        if (records == null)
        {
            throw new InvalidOperationException("Failed to deserialize hyphens.json");
        }

        var code = HyphensTransliteratorGenerator.Generate(records);
        var outputPath = Path.Combine(destRoot, "HyphensTransliterator.cs");

        File.WriteAllText(outputPath, code);
        Console.WriteLine($"  Written to: {Path.GetRelativePath(dataRoot, outputPath)}");
    }

    private static void GenerateIvsSvsBaseData(string dataRoot, string destRoot)
    {
        Console.WriteLine("Generating ivs_svs_base data...");

        var dataPath = Path.Combine(dataRoot, "ivs-svs-base-mappings.json");
        var jsonContent = File.ReadAllText(dataPath);
        var records = JsonSerializer.Deserialize<List<IvsSvsBaseRecord>>(jsonContent);

        if (records == null)
        {
            throw new InvalidOperationException("Failed to deserialize ivs-svs-base-mappings.json");
        }

        var binaryData = IvsSvsBaseTransliteratorGenerator.GenerateBinaryData(records);
        var outputPath = Path.Combine(destRoot, "ivs_svs_base.data");

        File.WriteAllBytes(outputPath, binaryData);
        Console.WriteLine($"  Written to: {Path.GetRelativePath(dataRoot, outputPath)}");
    }

    private static void GenerateCombinedTransliterator(string dataRoot, string destRoot)
    {
        Console.WriteLine("Generating combined...");

        var dataPath = Path.Combine(dataRoot, "combined-chars.json");
        var jsonContent = File.ReadAllText(dataPath);
        var rawMappings = JsonSerializer.Deserialize<Dictionary<string, string>>(jsonContent);

        if (rawMappings == null)
        {
            throw new InvalidOperationException("Failed to deserialize combined-chars.json");
        }

        var mappings = new Dictionary<int, string[]>();
        foreach (var kvp in rawMappings)
        {
            var fromCodePoint = UnicodeUtils.ParseUnicodeCodepoint(kvp.Key);
            var toChars = kvp.Value.ToCharArray().Select(c => c.ToString()).ToArray();
            mappings[fromCodePoint] = toChars;
        }

        var code = CombinedTransliteratorGenerator.Generate(mappings);
        var outputPath = Path.Combine(destRoot, "CombinedTransliterator.cs");

        File.WriteAllText(outputPath, code);
        Console.WriteLine($"  Written to: {Path.GetRelativePath(dataRoot, outputPath)}");
    }

    private static void GenerateCircledOrSquaredTransliterator(string dataRoot, string destRoot)
    {
        Console.WriteLine("Generating circled-or-squared...");

        var dataPath = Path.Combine(dataRoot, "circled-or-squared.json");
        var jsonContent = File.ReadAllText(dataPath);
        var rawMappings = JsonSerializer.Deserialize<Dictionary<string, CircledOrSquaredRecord>>(jsonContent);

        if (rawMappings == null)
        {
            throw new InvalidOperationException("Failed to deserialize circled-or-squared.json");
        }

        var mappings = new Dictionary<int, CircledOrSquaredRecord>();
        foreach (var kvp in rawMappings)
        {
            var fromCodePoint = UnicodeUtils.ParseUnicodeCodepoint(kvp.Key);
            mappings[fromCodePoint] = kvp.Value;
        }

        var code = CircledOrSquaredTransliteratorGenerator.Generate(mappings);
        var outputPath = Path.Combine(destRoot, "CircledOrSquaredTransliterator.cs");

        File.WriteAllText(outputPath, code);
        Console.WriteLine($"  Written to: {Path.GetRelativePath(dataRoot, outputPath)}");
    }

    private static void GenerateRomanNumeralsTransliterator(string dataRoot, string destRoot)
    {
        Console.WriteLine("Generating roman numerals...");

        var dataPath = Path.Combine(dataRoot, "roman-numerals.json");
        var jsonContent = File.ReadAllText(dataPath);
        var records = JsonSerializer.Deserialize<List<RomanNumeralsRecord>>(jsonContent);

        if (records == null)
        {
            throw new InvalidOperationException("Failed to deserialize roman numerals data.");
        }

        // Convert to the same format as combined transliterator
        var mappings = new Dictionary<int, string[]>();
        foreach (var record in records)
        {
            if (record.Codes != null && record.Decomposed != null)
            {
                if (record.Decomposed.Upper != null)
                {
                    mappings[record.Codes.Upper] = record.Decomposed.Upper
                        .Select(cp => char.ConvertFromUtf32(cp))
                        .ToArray();
                }

                if (record.Decomposed.Lower != null)
                {
                    mappings[record.Codes.Lower] = record.Decomposed.Lower
                        .Select(cp => char.ConvertFromUtf32(cp))
                        .ToArray();
                }
            }
        }

        // Reuse the combined transliterator generator
        var code = CombinedTransliteratorGenerator.Generate(mappings);

        // Replace class name and description
        code = code.Replace("CombinedTransliterator", "RomanNumeralsTransliterator");
        code = code.Replace(
            "Replace single characters with arrays of characters.",
            "Replace roman numeral characters with their ASCII letter equivalents.");
        code = code.Replace("combined", "roman-numerals");

        var outputPath = Path.Combine(destRoot, "RomanNumeralsTransliterator.cs");
        File.WriteAllText(outputPath, code);
        Console.WriteLine($"  Written to: {Path.GetRelativePath(dataRoot, outputPath)}");
    }
#pragma warning restore MA0051 // Method is too long
}
