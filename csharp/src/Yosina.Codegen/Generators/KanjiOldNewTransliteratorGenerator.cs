// Copyright (c) Yosina. All rights reserved.

using CodePointTuple = (int First, int Second);

namespace Yosina.Codegen.Generators;

/// <summary>
/// Generates source code for simple transliterators that perform one-to-one character mappings.
/// </summary>
public static class KanjiOldNewTransliteratorGenerator
{
    /// <summary>
    /// Generates the source code for a simple transliterator class.
    /// </summary>
    /// <param name="name">The name of the transliterator, used to generate the class name.</param>
    /// <param name="description">A description of what the transliterator does.</param>
    /// <param name="mappings">Dictionary mapping source code points to target code points.</param>
    /// <returns>The generated C# source code as a string.</returns>
    public static string Generate(string name, string description, IDictionary<CodePointTuple, CodePointTuple> mappings)
    {
        var className = UnicodeUtils.ToPascalCase(name) + "Transliterator";
        var registrationName = name.Replace("_", "-");

        var mappingEntries = mappings
            .OrderBy(m => m.Key)
            .Select(mapping => FormatMappingEntry(mapping.Key, mapping.Value));

        var mappingsDict = string.Join("\n", mappingEntries);

        return GenerateTemplate(className, registrationName, description, mappingsDict);
    }

    private static string FormatCodePointTupleAsHex(CodePointTuple tuple) => tuple.Second != -1 ? $"(0x{tuple.First:X}, 0x{tuple.Second:X})" : $"(0x{tuple.First:X}, -1)";

    private static string FormatMappingEntry(CodePointTuple fromCodePoint, CodePointTuple toCodePoint) =>
        $"        [{FormatCodePointTupleAsHex(fromCodePoint)}] = {FormatCodePointTupleAsHex(toCodePoint)},";

#pragma warning disable MA0051 // Method is too long
    private static string GenerateTemplate(string className, string registrationName, string description, string mappingsDict)
    {
        return $@"using CodePointTuple = (int First, int Second);

namespace Yosina.Transliterators;

/// <summary>
/// {description}
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator(""{registrationName}"")]
public class {className} : ITransliterator
{{
    private static readonly Dictionary<CodePointTuple, CodePointTuple> Mappings = new()
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
        private readonly Dictionary<CodePointTuple, CodePointTuple> mappings;
        private int offset;
        private bool disposed;

        public SimpleCharEnumerator(IEnumerator<Character> input, Dictionary<CodePointTuple, CodePointTuple> mappings)
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

            if (this.mappings.TryGetValue(c.CodePoint, out var mapped))
            {{
                this.Current = new Character(mapped, this.offset, c);
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
