// Copyright (c) Yosina. All rights reserved.

using System.Text.Json.Serialization;

namespace Yosina.Codegen;

internal class RomanNumeralsRecord
{
    [JsonPropertyName("value")]
    public int Value { get; set; }

    [JsonPropertyName("codes")]
    public RomanNumeralsCodes? Codes { get; set; }

    [JsonPropertyName("shift_jis")]
    public RomanNumeralsShiftJis? ShiftJis { get; set; }

    [JsonPropertyName("decomposed")]
    public RomanNumeralsDecomposed? Decomposed { get; set; }
}

internal class RomanNumeralsCodes
{
    [JsonPropertyName("upper")]
    [JsonConverter(typeof(UnicodeCodePointConverter))]
    public int Upper { get; set; }

    [JsonPropertyName("lower")]
    [JsonConverter(typeof(UnicodeCodePointConverter))]
    public int Lower { get; set; }
}

internal class RomanNumeralsShiftJis
{
    [JsonPropertyName("upper")]
    public int[]? Upper { get; set; }

    [JsonPropertyName("lower")]
    public int[]? Lower { get; set; }
}

internal class RomanNumeralsDecomposed
{
    [JsonPropertyName("upper")]
    [JsonConverter(typeof(UnicodeCodePointArrayConverter))]
    public int[]? Upper { get; set; }

    [JsonPropertyName("lower")]
    [JsonConverter(typeof(UnicodeCodePointArrayConverter))]
    public int[]? Lower { get; set; }
}
