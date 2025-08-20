// Copyright (c) Yosina. All rights reserved.

using System.Collections.Concurrent;
using System.Text.Json.Serialization;
using Yosina.JsonConverters;

namespace Yosina.Transliterators;

/// <summary>
/// Transliterator for converting between Hiragana and Katakana scripts.
/// </summary>
[RegisteredTransliterator("hira-kata")]
public class HiraKataTransliterator : ITransliterator
{
    /// <summary>
    /// Conversion mode.
    /// </summary>
    [JsonConverter(typeof(JsonEnumValueConverter<Mode>))]
    public enum Mode
    {
        /// <summary>
        /// Convert Hiragana to Katakana.
        /// </summary>
        [JsonEnumValue("hira-to-kata")]
        HiraToKata,

        /// <summary>
        /// Convert Katakana to Hiragana.
        /// </summary>
        [JsonEnumValue("kata-to-hira")]
        KataToHira,
    }

    /// <summary>
    /// Options for configuring the behavior of HiraKataTransliterator.
    /// </summary>
    public class Options
    {
        /// <summary>
        /// Gets or sets the conversion mode.
        /// </summary>
        [JsonPropertyName("mode")]
        public Mode Mode { get; set; } = Mode.HiraToKata;
    }

    // Class-level cache for mapping tables
    private static readonly ConcurrentDictionary<Mode, Dictionary<int, int>> MappingCache = new ConcurrentDictionary<Mode, Dictionary<int, int>>();

    private readonly Dictionary<int, int> mappingTable;

    /// <summary>
    /// Initializes a new instance of the <see cref="HiraKataTransliterator"/> class with the specified options.
    /// </summary>
    /// <param name="options">The options for the transliterator.</param>
    public HiraKataTransliterator(Options options)
    {
        this.mappingTable = GetMappingTable(options.Mode);
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="HiraKataTransliterator"/> class with default options.
    /// </summary>
    public HiraKataTransliterator()
        : this(new Options())
    {
    }

    private static Dictionary<int, int> GetMappingTable(Mode mode)
    {
        // Check cache first
        if (MappingCache.TryGetValue(mode, out var cached))
        {
            return cached;
        }

        var mapping = new Dictionary<int, int>();

        // Main table mappings
        foreach (var entry in HiraKataTable.HiraganaKatakanaTable)
        {
            if (entry.Hiragana.HasValue)
            {
                var hira = entry.Hiragana.Value;
                var kata = entry.Katakana;

                if (mode == Mode.HiraToKata)
                {
                    mapping[hira.Base] = kata.Base;
                    if (hira.Voiced >= 0 && kata.Voiced >= 0)
                    {
                        mapping[hira.Voiced] = kata.Voiced;
                    }

                    if (hira.Semivoiced >= 0 && kata.Semivoiced >= 0)
                    {
                        mapping[hira.Semivoiced] = kata.Semivoiced;
                    }
                }
                else
                {
                    mapping[kata.Base] = hira.Base;
                    if (kata.Voiced >= 0 && hira.Voiced >= 0)
                    {
                        mapping[kata.Voiced] = hira.Voiced;
                    }

                    if (kata.Semivoiced >= 0 && hira.Semivoiced >= 0)
                    {
                        mapping[kata.Semivoiced] = hira.Semivoiced;
                    }
                }
            }
        }

        // Small character mappings
        foreach (var entry in HiraKataTable.HiraganaKatakanaSmallTable)
        {
            if (mode == Mode.HiraToKata)
            {
                mapping[entry.Hiragana] = entry.Katakana;
            }
            else
            {
                mapping[entry.Katakana] = entry.Hiragana;
            }
        }

        // Cache the result
        MappingCache[mode] = mapping;
        return mapping;
    }

    /// <inheritdoc/>
    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        foreach (var ch in input)
        {
            if (ch.CodePoint.Size() == 1)
            {
                var codePoint = ch.CodePoint.First;
                if (this.mappingTable.TryGetValue(codePoint, out var mapped))
                {
                    yield return new Character((mapped, CodePointTupleExtensions.INVALID), ch.Offset, ch);
                    continue;
                }
            }

            yield return ch;
        }
    }
}
