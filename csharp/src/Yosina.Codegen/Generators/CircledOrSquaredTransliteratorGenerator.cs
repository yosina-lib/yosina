// Copyright (c) Yosina. All rights reserved.

namespace Yosina.CodeGen.Generators;

/// <summary>
/// Generates source code for the CircledOrSquaredTransliterator that replaces circled or squared characters with templated forms.
/// </summary>
public static class CircledOrSquaredTransliteratorGenerator
{
    /// <summary>
    /// Generates the source code for the CircledOrSquaredTransliterator class.
    /// </summary>
    /// <param name="mappings">Dictionary mapping code points to CircledOrSquaredRecord data.</param>
    /// <returns>The generated C# source code as a string.</returns>
    public static string Generate(IDictionary<int, CircledOrSquaredRecord> mappings)
    {
        var className = "CircledOrSquaredTransliterator";
        var registrationName = "circled-or-squared";
        var description = "Replace circled or squared characters with templated forms.";

        var mappingEntries = mappings
            .OrderBy(m => m.Key)
            .Select(mapping => FormatMappingEntry(mapping.Key, mapping.Value));

        var mappingsDict = string.Join("\n", mappingEntries);

        return GenerateTemplate(className, registrationName, description, mappingsDict);
    }

    private static string FormatMappingEntry(int fromCodePoint, CircledOrSquaredRecord record)
    {
        var escapedRendering = record.Rendering.Replace("\"", "\\\"").Replace("\\", "\\\\");
        return $"        [0x{fromCodePoint:X}] = new CircledOrSquaredData(\"{escapedRendering}\", CharType.{record.Type}, {record.Emoji.ToString().ToLowerInvariant()}),";
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
    private readonly Options options;

    public {className}()
        : this(new Options())
    {{
    }}

    public {className}(Options options)
    {{
        this.options = options;
    }}

    private static readonly Dictionary<int, CircledOrSquaredData> Mappings = new Dictionary<int, CircledOrSquaredData>()
    {{
{mappingsDict}
    }};

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {{
        return new CircledOrSquaredCharEnumerator(input.GetEnumerator(), Mappings, this.options);
    }}

    public class Options
    {{
        public Options()
        {{
            this.TemplateForCircled = ""(?)"";
            this.TemplateForSquared = ""[?]"";
            this.IncludeEmojis = false;
        }}

        public string TemplateForCircled {{ get; set; }}

        public string TemplateForSquared {{ get; set; }}

        public bool IncludeEmojis {{ get; set; }}
    }}

    private enum CharType
    {{
        Circle,
        Square,
    }}

    private record CircledOrSquaredData
    {{
        public string Rendering {{ get; init; }}

        public CharType Type {{ get; init; }}

        public bool Emoji {{ get; init; }}

        public CircledOrSquaredData(string rendering, CharType type, bool emoji)
        {{
            this.Rendering = rendering;
            this.Type = type;
            this.Emoji = emoji;
        }}
    }}

    private class CircledOrSquaredCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {{
        private readonly IEnumerator<Character> input;
        private readonly Dictionary<int, CircledOrSquaredData> mappings;
        private readonly Options options;
        private int offset;
        private bool disposed;
        private readonly Queue<Character> queue = new Queue<Character>();

        public CircledOrSquaredCharEnumerator(IEnumerator<Character> input, Dictionary<int, CircledOrSquaredData> mappings, Options options)
        {{
            this.input = input;
            this.mappings = mappings;
            this.options = options;
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

            CircledOrSquaredData? data;
            if (c.CodePoint.Size() == 1 && this.mappings.TryGetValue(c.CodePoint.First, out data))
            {{
                // Skip emoji characters if not included
                if (data.Emoji && !this.options.IncludeEmojis)
                {{
                    this.Current = c.WithOffset(this.offset);
                    this.offset += this.Current.CharCount;
                    return true;
                }}

                // Get template
                string template = data.Type == CharType.Circle ? this.options.TemplateForCircled : this.options.TemplateForSquared;
                var replacement = template.Replace(""?"", data.Rendering);

                if (string.IsNullOrEmpty(replacement))
                {{
                    this.Current = c.WithOffset(this.offset);
                    this.offset += this.Current.CharCount;
                    return true;
                }}

                // Create characters for each replacement character
                var chars = replacement.Select((ch, index) =>
                    new Character((ch, -1), this.offset + index, c)).ToArray();

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
