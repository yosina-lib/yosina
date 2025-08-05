// Copyright (c) Yosina. All rights reserved.

using System.Text.Json.Serialization;

namespace Yosina.CodeGen;

/// <summary>
/// Specifies the type of character enclosure.
/// </summary>
[JsonConverter(typeof(JsonStringEnumConverter))]
public enum CharType
{
    /// <summary>
    /// Circled character.
    /// </summary>
    [JsonStringEnumMemberName("circle")]
    Circle,

    /// <summary>
    /// Squared character.
    /// </summary>
    [JsonStringEnumMemberName("square")]
    Square,
}
