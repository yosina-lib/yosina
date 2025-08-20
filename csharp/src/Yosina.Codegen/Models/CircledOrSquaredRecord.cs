// Copyright (c) Yosina. All rights reserved.

using System.Text.Json.Serialization;

namespace Yosina.Codegen;

/// <summary>
/// Represents a record for circled or squared character data.
/// </summary>
public class CircledOrSquaredRecord
{
    /// <summary>
    /// Gets or sets the rendering representation of the character.
    /// </summary>
    [JsonPropertyName("rendering")]
    public required string Rendering { get; set; }

    /// <summary>
    /// Gets or sets the type of the character (Circle or Square).
    /// </summary>
    [JsonPropertyName("type")]
    public required CharType Type { get; set; }

    /// <summary>
    /// Gets or sets a value indicating whether this is an emoji character.
    /// </summary>
    [JsonPropertyName("emoji")]
    public required bool Emoji { get; set; }
}
