// Copyright (c) Yosina. All rights reserved.

using System.Text.Json.Serialization;

namespace Yosina.CodeGen;

/// <summary>
/// Represents a record for hyphen character data.
/// </summary>
public class HyphensRecord
{
    /// <summary>
    /// Gets or sets the Unicode code point.
    /// </summary>
    [JsonPropertyName("code")]
    [JsonConverter(typeof(UnicodeCodePointConverter))]
    public int Code { get; set; }

    /// <summary>
    /// Gets or sets the name of the character.
    /// </summary>
    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the ASCII representation code points.
    /// </summary>
    [JsonPropertyName("ascii")]
    [JsonConverter(typeof(UnicodeCodePointArrayConverter))]
    public int[]? Ascii { get; set; }

    /// <summary>
    /// Gets or sets the JIS X 0201 representation code points.
    /// </summary>
    [JsonPropertyName("jisx0201")]
    [JsonConverter(typeof(UnicodeCodePointArrayConverter))]
    public int[]? Jisx0201 { get; set; }

    /// <summary>
    /// Gets or sets the JIS X 0208-1978 representation code points.
    /// </summary>
    [JsonPropertyName("jisx0208-1978")]
    [JsonConverter(typeof(UnicodeCodePointArrayConverter))]
    public int[]? Jisx02081978 { get; set; }

    /// <summary>
    /// Gets or sets the JIS X 0208-1978 Windows representation code points.
    /// </summary>
    [JsonPropertyName("jisx0208-1978-windows")]
    [JsonConverter(typeof(UnicodeCodePointArrayConverter))]
    public int[]? Jisx02081978Windows { get; set; }

    /// <summary>
    /// Gets or sets the JIS X 0208 verbatim code point.
    /// </summary>
    [JsonPropertyName("jisx0208-verbatim")]
    [JsonConverter(typeof(NullableUnicodeCodePointConverter))]
    public int? Jisx0208Verbatim { get; set; }
}
