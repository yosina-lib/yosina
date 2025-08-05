// Copyright (c) Yosina. All rights reserved.

namespace Yosina.CodeGen.Generators;

/// <summary>
/// Generates source code for simple transliterators that perform one-to-one character mappings.
/// </summary>
public static class SimpleTransliteratorGenerator
{
    /// <summary>
    /// Generates the source code for a simple transliterator class.
    /// </summary>
    /// <param name="name">The name of the transliterator, used to generate the class name.</param>
    /// <param name="description">A description of what the transliterator does.</param>
    /// <param name="mappings">Dictionary mapping source code points to target code points.</param>
    /// <returns>The generated C# source code as a string.</returns>
    public static string Generate(string name, string description, IDictionary<int, int> mappings)
    {
        var className = UnicodeUtils.ToPascalCase(name) + "Transliterator";
        var registrationName = name.Replace("_", "-");

        var mappingEntries = mappings
            .OrderBy(m => m.Key)
            .Select(mapping => FormatMappingEntry(mapping.Key, mapping.Value));

        var mappingsDict = string.Join("\n", mappingEntries);

        return GenerateTemplate(className, registrationName, description, mappingsDict);
    }

    private static string FormatMappingEntry(int fromCodePoint, int toCodePoint) =>
        $"        [0x{fromCodePoint:X}] = 0x{toCodePoint:X},";

#pragma warning disable MA0051 // Method is too long
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
    private static readonly Dictionary<int, int> Mappings = new()
    {{
{mappingsDict}
    }};

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {{
        return new SimpleCharEnumerator(input.GetEnumerator(), Mappings);
    }}

    private class SimpleCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {{
        private readonly IEnumerator<Character> input;
        private readonly Dictionary<int, int> mappings;
        private int offset;
        private bool disposed;

        public SimpleCharEnumerator(IEnumerator<Character> input, Dictionary<int, int> mappings)
        {{
            this.input = input;
            this.mappings = mappings;
        }}

        public Character Current {{ get; private set; }} = null!;

        object System.Collections.IEnumerator.Current => this.Current;

        public bool MoveNext()
        {{
            if (this.disposed || !this.input.MoveNext())
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
                this.Current = new Character((mapped, -1), this.offset, c);
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

        public System.Collections.Generic.IEnumerator<Character> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }}
}}";
    }
#pragma warning restore MA0051 // Method is too long
}
