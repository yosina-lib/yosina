// Copyright (c) Yosina. All rights reserved.

using System.Text.Json.Serialization;

namespace Yosina.Codegen;

/// <summary>
/// Represents a record for IVS (Ideographic Variation Sequence) and SVS (Standardized Variation Sequence) base data.
/// </summary>
public class IvsSvsBaseRecord
{
    /// <summary>
    /// Gets or sets the IVS (Ideographic Variation Sequence) code points.
    /// </summary>
    [JsonPropertyName("ivs")]
    [JsonConverter(typeof(UnicodeCodePointArrayConverter))]
    public int[]? Ivs { get; set; }

    /// <summary>
    /// Gets or sets the SVS (Standardized Variation Sequence) code points.
    /// </summary>
    [JsonPropertyName("svs")]
    [JsonConverter(typeof(UnicodeCodePointArrayConverter))]
    public int[]? Svs { get; set; }

    /// <summary>
    /// Gets or sets the base code point for the 1990 standard.
    /// </summary>
    [JsonPropertyName("base90")]
    [JsonConverter(typeof(NullableUnicodeCodePointConverter))]
    public int? Base90 { get; set; }

    /// <summary>
    /// Gets or sets the base code point for the 2004 standard.
    /// </summary>
    [JsonPropertyName("base2004")]
    [JsonConverter(typeof(NullableUnicodeCodePointConverter))]
    public int? Base2004 { get; set; }
}
