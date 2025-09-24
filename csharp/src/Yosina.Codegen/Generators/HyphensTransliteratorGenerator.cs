// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Codegen.Generators;

/// <summary>
/// Generates source code for the HyphensTransliterator that normalizes various hyphen and dash characters.
/// </summary>
public static class HyphensTransliteratorGenerator
{
    private enum Mapping
    {
        ASCII,
        JISX0201,
        JISX0208_90,
        JISX0208_90_WINDOWS,
        JISX0208_VERBATIM,
    }

    /// <summary>
    /// Generates the source code for the HyphensTransliterator class.
    /// </summary>
    /// <param name="records">List of hyphen records containing mapping data.</param>
    /// <returns>The generated C# source code as a string.</returns>
    public static string Generate(IList<HyphensRecord> records)
    {
        var mappingSections = new List<string>();

        // ASCII mappings
        var asciiEntries = records
            .Where(r => r.Ascii != null && r.Ascii.Length > 0)
            .Select(r =>
            {
                var targetArray = FormatCodePointArrayFromInts(r.Ascii!);
                return FormatArrayMappingEntry(r.Code, targetArray);
            });
        mappingSections.Add(FormatMappingsSection(Mapping.ASCII, asciiEntries));

        // JISX0201 mappings
        var jisx0201Entries = records
            .Where(r => r.Jisx0201 != null && r.Jisx0201.Length > 0)
            .Select(r =>
            {
                var targetArray = FormatCodePointArrayFromInts(r.Jisx0201!);
                return FormatArrayMappingEntry(r.Code, targetArray);
            });
        mappingSections.Add(FormatMappingsSection(Mapping.JISX0201, jisx0201Entries));

        // JISX0208_90 mappings
        var jisx0208Entries = records
            .Where(r => r.Jisx02081978 != null && r.Jisx02081978.Length > 0)
            .Select(r =>
            {
                var targetArray = FormatCodePointArrayFromInts(r.Jisx02081978!);
                return FormatArrayMappingEntry(r.Code, targetArray);
            });
        mappingSections.Add(FormatMappingsSection(Mapping.JISX0208_90, jisx0208Entries));

        // JISX0208_90_WINDOWS mappings
        var jisx0208WindowsEntries = records
            .Where(r => r.Jisx02081978Windows != null && r.Jisx02081978Windows.Length > 0)
            .Select(r =>
            {
                var targetArray = FormatCodePointArrayFromInts(r.Jisx02081978Windows!);
                return FormatArrayMappingEntry(r.Code, targetArray);
            });
        mappingSections.Add(FormatMappingsSection(Mapping.JISX0208_90_WINDOWS, jisx0208WindowsEntries));

        // JISX0208_VERBATIM mappings
        var jisx0208VerbatimEntries = records
            .Where(r => r.Jisx0208Verbatim != null)
            .Select(r =>
            {
                var targetArray = FormatCodePointArrayFromInts(new[] { r.Jisx0208Verbatim!.Value });
                return FormatArrayMappingEntry(r.Code, targetArray);
            });
        mappingSections.Add(FormatMappingsSection(Mapping.JISX0208_VERBATIM, jisx0208VerbatimEntries));

        var mappingsData = string.Join("\n", mappingSections);

        return GenerateTemplate(mappingsData);
    }

    private static string FormatMappingsSection(Mapping mappingType, IEnumerable<string> entries)
    {
        var entriesStr = string.Join("\n", entries);
        return $@"        [Mapping.{mappingType}] = new Dictionary<int, int[]>
        {{
{entriesStr}
        }},";
    }

    private static string FormatArrayMappingEntry(int sourceCodePoint, string targetArray) =>
        $"            [0x{sourceCodePoint:X}] = {targetArray},";

    private static string FormatCodePointArrayFromInts(IEnumerable<int> codePoints)
    {
        var codes = codePoints.Select(c => $"0x{c:X}");
        return $"new[] {{ {string.Join(", ", codes)} }}";
    }

    private static string GenerateTemplate(string mappingsData)
    {
        return $@"// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Transliterators;

/// <summary>
/// Transliterator for normalizing various hyphen and dash characters.
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator(""hyphens"")]
public class HyphensTransliterator : ITransliterator
{{
    public static readonly List<Mapping> DefaultPrecedence = new() {{ Mapping.JISX0208_90 }};

    private static readonly Dictionary<Mapping, Dictionary<int, int[]>> Mappings = new()
    {{
{mappingsData}
    }};

    private readonly Options options;

    public HyphensTransliterator()
        : this(new Options())
    {{
    }}

    public HyphensTransliterator(Options options)
    {{
        this.options = options;
    }}

#pragma warning disable CA1707 // Identifiers should not contain underscores
    public enum Mapping
    {{
        ASCII,
        JISX0201,
        JISX0208_90,
        JISX0208_90_WINDOWS,
        JISX0208_VERBATIM,
    }}
#pragma warning restore CA1707 // Identifiers should not contain underscores

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {{
        var precedence = this.options.Precedence ?? DefaultPrecedence;
        var effectiveMappings = new Dictionary<int, int[]>();

        // Build effective mappings based on precedence
        foreach (var record in Mappings)
        {{
            foreach (var mapping in record.Value)
            {{
                if (!effectiveMappings.ContainsKey(mapping.Key))
                {{
                    effectiveMappings[mapping.Key] = mapping.Value;
                }}
            }}
        }}

        // Apply precedence order
        foreach (var mappingType in precedence.Reverse())
        {{
            if (Mappings.TryGetValue(mappingType, out var mappings))
            {{
                foreach (var mapping in mappings)
                {{
                    effectiveMappings[mapping.Key] = mapping.Value;
                }}
            }}
        }}

        return new HyphensCharIterator(input.GetEnumerator(), effectiveMappings);
    }}

    public class Options
    {{
        public IList<Mapping>? Precedence {{ get; set; }}
    }}

    private class HyphensCharIterator : IEnumerator<Character>, IEnumerable<Character>
    {{
        private readonly IEnumerator<Character> input;
        private readonly Dictionary<int, int[]> mappings;
        private readonly Queue<Character> buffer = new();
        private int offset;
        private bool disposed;

        public HyphensCharIterator(IEnumerator<Character> input, Dictionary<int, int[]> mappings)
        {{
            this.input = input;
            this.mappings = mappings;
        }}

        public Character Current {{ get; private set; }} = null!;

        object System.Collections.IEnumerator.Current => this.Current;

        public bool MoveNext()
        {{
            if (this.disposed)
            {{
                return false;
            }}

            // If we have buffered characters from a multi-character replacement, return the next one
            if (this.buffer.Count > 0)
            {{
                this.Current = this.buffer.Dequeue();
                return true;
            }}

            // Move to next input character
            if (!this.input.MoveNext())
            {{
                return false;
            }}

            var c = this.input.Current;
            if (c.IsSentinel)
            {{
                this.Current = c.WithOffset(this.offset);
                this.offset += this.Current.CharCount;
                return true;
            }}

            // Check for mapping
            if (c.CodePoint.Size() == 1 && this.mappings.TryGetValue(c.CodePoint.First, out var mapped))
            {{
                if (mapped.Length == 1)
                {{
                    // Single character replacement
                    this.Current = new Character((mapped[0], -1), this.offset, c);
                }}
                else
                {{
                    // Multi-character replacement - create individual Char objects
                    this.Current = new Character((mapped[0], -1), this.offset, c);
                    var currentOffset = this.offset + this.Current.CharCount;

                    // Buffer the remaining characters
                    for (int i = 1; i < mapped.Length; i++)
                    {{
                        var bufferedChar = new Character((mapped[i], -1), currentOffset, c);
                        this.buffer.Enqueue(bufferedChar);
                        currentOffset += bufferedChar.CharCount;
                    }}
                }}
            }}
            else
            {{
                this.Current = c.WithOffset(this.offset);
            }}

            this.offset += this.Current.CharCount;
            return true;
        }}

        public void Reset()
        {{
            this.input.Reset();
            this.buffer.Clear();
            this.offset = 0;
        }}

        public void Dispose()
        {{
            if (!this.disposed)
            {{
                this.input.Dispose();
                this.disposed = true;
            }}
        }}

        public IEnumerator<Character> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }}
}}";
    }
}
