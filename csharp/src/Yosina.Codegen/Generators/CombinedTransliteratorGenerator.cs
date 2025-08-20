// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Codegen.Generators;

/// <summary>
/// Generates source code for the CombinedTransliterator that replaces single characters with arrays of characters.
/// </summary>
public static class CombinedTransliteratorGenerator
{
    /// <summary>
    /// Generates the source code for the CombinedTransliterator class.
    /// </summary>
    /// <param name="mappings">Dictionary mapping source code points to arrays of replacement characters.</param>
    /// <returns>The generated C# source code as a string.</returns>
    public static string Generate(IDictionary<int, string[]> mappings)
    {
        var className = "CombinedTransliterator";
        var registrationName = "combined";
        var description = "Replace single characters with arrays of characters.";

        var mappingEntries = mappings
            .OrderBy(m => m.Key)
            .Select(mapping => FormatMappingEntry(mapping.Key, mapping.Value));

        var mappingsDict = string.Join("\n", mappingEntries);

        return GenerateTemplate(className, registrationName, description, mappingsDict);
    }

    private static string FormatMappingEntry(int fromCodePoint, string[] toChars)
    {
        var charArray = string.Join(", ", toChars.Select(c => $"0x{char.ConvertToUtf32(c, 0):X}"));
        return $"        [0x{fromCodePoint:X}] = new int[] {{ {charArray} }},";
    }

    private static string GenerateTemplate(string className, string registrationName, string description, string mappingsDict)
    {
        return $@"namespace Yosina.Transliterators;

/// <summary>
/// {description}
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator(""{registrationName}"")]
public class {className} : ITransliterator
{{
    private static readonly Dictionary<int, int[]> Mappings = new()
    {{
{mappingsDict}
    }};

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {{
        return new CombinedCharEnumerator(input.GetEnumerator(), Mappings);
    }}

    private class CombinedCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {{
        private readonly IEnumerator<Character> input;
        private readonly Dictionary<int, int[]> mappings;
        private int offset;
        private bool disposed;
        private readonly Queue<Character> queue = new();

        public CombinedCharEnumerator(IEnumerator<Character> input, Dictionary<int, int[]> mappings)
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

            // If we have queued characters from a previous expansion, return them first
            if (this.queue.Count > 0)
            {{
                this.Current = this.queue.Dequeue();
                return true;
            }}

            if (!this.input.MoveNext())
            {{
                return false;
            }}

            var c = this.input.Current;
            if (c.IsSentinel)
            {{
                this.Current = c.WithOffset(this.offset);
                return true;
            }}

            if (c.CodePoint.Size() == 1 && this.mappings.TryGetValue(c.CodePoint.First, out var mapped))
            {{
                // Create characters for each mapped code point
                var chars = mapped.Select((codePoint, index) =>
                    new Character((codePoint, -1), this.offset + index, c)).ToArray();

                if (chars.Length > 0)
                {{
                    this.Current = chars[0];
                    this.offset += chars[0].CharCount;

                    // Queue the remaining characters
                    for (int i = 1; i < chars.Length; i++)
                    {{
                        this.queue.Enqueue(chars[i].WithOffset(this.offset));
                        this.offset += chars[i].CharCount;
                    }}
                }}
                else
                {{
                    this.Current = c.WithOffset(this.offset);
                    this.offset += this.Current.CharCount;
                }}
            }}
            else
            {{
                this.Current = c.WithOffset(this.offset);
                this.offset += this.Current.CharCount;
            }}

            return true;
        }}

        public void Reset()
        {{
            this.input.Reset();
            this.offset = 0;
            this.queue.Clear();
        }}

        public void Dispose()
        {{
            if (!this.disposed)
            {{
                this.input.Dispose();
                this.disposed = true;
            }}
        }}

        public System.Collections.Generic.IEnumerator<Character> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }}
}}";
    }
}
