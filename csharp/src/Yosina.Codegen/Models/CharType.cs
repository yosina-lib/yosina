// Copyright (c) Yosina. All rights reserved.

using System.Text.Json.Serialization;

namespace Yosina.Codegen;

/// <summary>
/// Specifies the type of character enclosure.
/// </summary>
[JsonConverter(typeof(JsonEnumValueConverter<CharType>))]
public enum CharType
{
    /// <summary>
    /// Circled character.
    /// </summary>
    [JsonEnumValue("circle")]
    Circle,

    /// <summary>
    /// Squared character.
    /// </summary>
    [JsonEnumValue("square")]
    Square,
}
