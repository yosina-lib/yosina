// Copyright (c) Yosina. All rights reserved.

using System.Text.Json.Serialization;

namespace Yosina.Codegen;

/// <summary>
/// Represents a record for Kanji character old and new form relationships.
/// </summary>
public class KanjiOldNewRecord
{
    /// <summary>
    /// Gets or sets the Unicode code point of the character.
    /// </summary>
    [JsonPropertyName("codepoint")]
    [JsonConverter(typeof(UnicodeCodePointConverter))]
    public int CodePoint { get; set; }

    /// <summary>
    /// Gets or sets the array of old form code points for this character.
    /// </summary>
    [JsonPropertyName("old_forms")]
    [JsonConverter(typeof(UnicodeCodePointArrayConverter))]
    public int[] OldForms { get; set; } = Array.Empty<int>();

    /// <summary>
    /// Gets or sets the array of new form code points for this character.
    /// </summary>
    [JsonPropertyName("new_forms")]
    [JsonConverter(typeof(UnicodeCodePointArrayConverter))]
    public int[] NewForms { get; set; } = Array.Empty<int>();

    /// <summary>
    /// Gets or sets the array of code points for which this character is a new form.
    /// </summary>
    [JsonPropertyName("is_new_form_of")]
    [JsonConverter(typeof(UnicodeCodePointArrayConverter))]
    public int[] IsNewFormOf { get; set; } = Array.Empty<int>();
}
