// Copyright (c) Yosina. All rights reserved.

using System.Text.Json.Serialization;
using Yosina.JsonConverters;

namespace Yosina.Transliterators;

/// <summary>
/// Transliterator for converting historical hiragana/katakana characters to their modern equivalents.
/// </summary>
[RegisteredTransliterator("historical-hirakatas")]
public class HistoricalHirakatasTransliterator : ITransliterator
{
    /// <summary>
    /// Conversion mode for historical kana characters.
    /// </summary>
    [JsonConverter(typeof(JsonEnumValueConverter<ConversionMode>))]
    public enum ConversionMode
    {
        /// <summary>
        /// Replace with the simple modern equivalent.
        /// </summary>
        [JsonEnumValue("simple")]
        Simple,

        /// <summary>
        /// Decompose into the phonetic equivalent using multiple modern characters.
        /// </summary>
        [JsonEnumValue("decompose")]
        Decompose,

        /// <summary>
        /// Skip conversion; leave the character unchanged.
        /// </summary>
        [JsonEnumValue("skip")]
        Skip,
    }

    /// <summary>
    /// Conversion mode for voiced historical kana characters.
    /// </summary>
    [JsonConverter(typeof(JsonEnumValueConverter<VoicedConversionMode>))]
    public enum VoicedConversionMode
    {
        /// <summary>
        /// Decompose into the phonetic equivalent using multiple modern characters.
        /// </summary>
        [JsonEnumValue("decompose")]
        Decompose,

        /// <summary>
        /// Skip conversion; leave the character unchanged.
        /// </summary>
        [JsonEnumValue("skip")]
        Skip,
    }

    /// <summary>
    /// Options for configuring the behavior of HistoricalHirakatasTransliterator.
    /// </summary>
    public class Options
    {
        /// <summary>
        /// Gets or sets the conversion mode for historical hiragana characters (e.g. ゐ, ゑ).
        /// </summary>
        [JsonPropertyName("hiraganas")]
        public ConversionMode Hiraganas { get; set; } = ConversionMode.Simple;

        /// <summary>
        /// Gets or sets the conversion mode for historical katakana characters (e.g. ヰ, ヱ).
        /// </summary>
        [JsonPropertyName("katakanas")]
        public ConversionMode Katakanas { get; set; } = ConversionMode.Simple;

        /// <summary>
        /// Gets or sets the conversion mode for voiced historical kana characters (e.g. ヷ, ヸ, ヹ, ヺ).
        /// </summary>
        [JsonPropertyName("voicedKatakanas")]
        public VoicedConversionMode VoicedKatakanas { get; set; } = VoicedConversionMode.Skip;
    }

    private const int CombiningDakuten = 0x3099;
    private const int Vu = 0x30F4; // ヴ
    private const int U = 0x30A6; // ウ

    private static readonly Dictionary<int, int> VoicedDecomposedMappings = new()
    {
        [0x30EF] = 0x30A1, // ヷ → ァ
        [0x30F0] = 0x30A3, // ヸ → ィ
        [0x30F1] = 0x30A7, // ヹ → ェ
        [0x30F2] = 0x30A9, // ヺ → ォ
    };

    private readonly Dictionary<int, int[]> mappings;
    private readonly VoicedConversionMode voicedKatakanas;

    /// <summary>
    /// Initializes a new instance of the <see cref="HistoricalHirakatasTransliterator"/> class with the specified options.
    /// </summary>
    /// <param name="options">The options for the transliterator.</param>
    public HistoricalHirakatasTransliterator(Options options)
    {
        this.mappings = BuildMappings(options);
        this.voicedKatakanas = options.VoicedKatakanas;
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="HistoricalHirakatasTransliterator"/> class with default options.
    /// </summary>
    public HistoricalHirakatasTransliterator()
        : this(new Options())
    {
    }

    private static Dictionary<int, int[]> BuildMappings(Options options)
    {
        var result = new Dictionary<int, int[]>();

        // Historical hiragana mappings
        switch (options.Hiraganas)
        {
            case ConversionMode.Simple:
                result[0x3090] = new[] { 0x3044 }; // ゐ (U+3090) -> い (U+3044)
                result[0x3091] = new[] { 0x3048 }; // ゑ (U+3091) -> え (U+3048)
                break;
            case ConversionMode.Decompose:
                result[0x3090] = new[] { 0x3046, 0x3043 }; // ゐ (U+3090) -> うぃ (U+3046, U+3043)
                result[0x3091] = new[] { 0x3046, 0x3047 }; // ゑ (U+3091) -> うぇ (U+3046, U+3047)
                break;
            case ConversionMode.Skip:
                break;
        }

        // Historical katakana mappings
        switch (options.Katakanas)
        {
            case ConversionMode.Simple:
                result[0x30F0] = new[] { 0x30A4 }; // ヰ (U+30F0) -> イ (U+30A4)
                result[0x30F1] = new[] { 0x30A8 }; // ヱ (U+30F1) -> エ (U+30A8)
                break;
            case ConversionMode.Decompose:
                result[0x30F0] = new[] { 0x30A6, 0x30A3 }; // ヰ (U+30F0) -> ウィ (U+30A6, U+30A3)
                result[0x30F1] = new[] { 0x30A6, 0x30A7 }; // ヱ (U+30F1) -> ウェ (U+30A6, U+30A7)
                break;
            case ConversionMode.Skip:
                break;
        }

        // Voiced historical kana mappings
        switch (options.VoicedKatakanas)
        {
            case VoicedConversionMode.Decompose:
                result[0x30F7] = new[] { Vu, 0x30A1 }; // ヷ (U+30F7) -> ヴァ
                result[0x30F8] = new[] { Vu, 0x30A3 }; // ヸ (U+30F8) -> ヴィ
                result[0x30F9] = new[] { Vu, 0x30A7 }; // ヹ (U+30F9) -> ヴェ
                result[0x30FA] = new[] { Vu, 0x30A9 }; // ヺ (U+30FA) -> ヴォ
                break;
            case VoicedConversionMode.Skip:
                break;
        }

        return result;
    }

    /// <inheritdoc/>
    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        return new HistoricalHirakatasEnumerator(input.GetEnumerator(), this.mappings, this.voicedKatakanas);
    }

    private class HistoricalHirakatasEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {
        private readonly IEnumerator<Character> input;
        private readonly Dictionary<int, int[]> mappings;
        private readonly VoicedConversionMode voicedKatakanas;
        private int offset;
        private bool disposed;
        private readonly Queue<Character> queue = new();
        private Character? pending;

        public HistoricalHirakatasEnumerator(IEnumerator<Character> input, Dictionary<int, int[]> mappings, VoicedConversionMode voicedKatakanas)
        {
            this.input = input;
            this.mappings = mappings;
            this.voicedKatakanas = voicedKatakanas;
        }

        public Character Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => this.Current;

        public bool MoveNext()
        {
            if (this.disposed)
            {
                return false;
            }

            // If we have queued characters from a previous expansion, return them first
            if (this.queue.Count > 0)
            {
                this.Current = this.queue.Dequeue();
                return true;
            }

            Character c;
            if (this.pending != null)
            {
                c = this.pending;
                this.pending = null;
            }
            else if (this.input.MoveNext())
            {
                c = this.input.Current;
            }
            else
            {
                return false;
            }

            if (c.IsSentinel)
            {
                this.Current = c.WithOffset(this.offset);
                return true;
            }

            // Lookahead: peek at next char for combining dakuten
            if (c.CodePoint.Size() == 1)
            {
                bool hasNext;
                Character? next = null;
                if (this.input.MoveNext())
                {
                    hasNext = true;
                    next = this.input.Current;
                }
                else
                {
                    hasNext = false;
                }

                if (hasNext && next != null && !next.IsSentinel && next.CodePoint.Size() == 1 && next.CodePoint.First == CombiningDakuten)
                {
                    // Check if current char is a decomposed voiced base
                    if (this.voicedKatakanas == VoicedConversionMode.Decompose && VoicedDecomposedMappings.TryGetValue(c.CodePoint.First, out var vowel))
                    {
                        // Decompose mode: emit U + dakuten + vowel
                        this.Current = new Character((U, -1), this.offset, c);
                        this.offset += this.Current.CharCount;

                        var dakutenChar = next.WithOffset(this.offset);
                        this.queue.Enqueue(dakutenChar);
                        this.offset += dakutenChar.CharCount;

                        var vowelChar = new Character((vowel, -1), this.offset, c);
                        this.queue.Enqueue(vowelChar);
                        this.offset += vowelChar.CharCount;
                    }
                    else
                    {
                        // Skip mode or not a voiced base: emit current char, then queue the dakuten char
                        this.Current = c.WithOffset(this.offset);
                        this.offset += this.Current.CharCount;
                        var dakutenChar = next.WithOffset(this.offset);
                        this.queue.Enqueue(dakutenChar);
                        this.offset += dakutenChar.CharCount;
                    }
                }
                else
                {
                    // No dakuten follows: store next as pending and fall through to regular mapping
                    if (hasNext)
                    {
                        this.pending = next;
                    }

                    if (this.mappings.TryGetValue(c.CodePoint.First, out var mapped))
                    {
                        if (mapped.Length > 0)
                        {
                            this.Current = new Character((mapped[0], -1), this.offset, c);
                            this.offset += this.Current.CharCount;

                            for (int i = 1; i < mapped.Length; i++)
                            {
                                var ch = new Character((mapped[i], -1), this.offset, c);
                                this.queue.Enqueue(ch);
                                this.offset += ch.CharCount;
                            }
                        }
                        else
                        {
                            this.Current = c.WithOffset(this.offset);
                            this.offset += this.Current.CharCount;
                        }
                    }
                    else
                    {
                        this.Current = c.WithOffset(this.offset);
                        this.offset += this.Current.CharCount;
                    }
                }
            }
            else
            {
                this.Current = c.WithOffset(this.offset);
                this.offset += this.Current.CharCount;
            }

            return true;
        }

        public void Reset()
        {
            this.input.Reset();
            this.offset = 0;
            this.queue.Clear();
            this.pending = null;
        }

        public void Dispose()
        {
            if (!this.disposed)
            {
                this.input.Dispose();
                this.disposed = true;
            }
        }

        public IEnumerator<Character> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }
}
