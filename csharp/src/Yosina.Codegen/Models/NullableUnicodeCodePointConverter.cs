// Copyright (c) Yosina. All rights reserved.

using System.Text.Json;
using System.Text.Json.Serialization;

namespace Yosina.Codegen;

/// <summary>
/// JSON converter for nullable Unicode code points that serializes to/from "U+XXXX" format.
/// </summary>
public class NullableUnicodeCodePointConverter : JsonConverter<int?>
{
    /// <inheritdoc/>
    public override int? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Null)
        {
            return null;
        }

        var stringValue = reader.GetString();
        return stringValue != null ? UnicodeUtils.ParseUnicodeCodepoint(stringValue) : null;
    }

    /// <inheritdoc/>
    public override void Write(Utf8JsonWriter writer, int? value, JsonSerializerOptions options)
    {
        if (value.HasValue)
        {
            writer.WriteStringValue($"U+{value.Value:X4}");
        }
        else
        {
            writer.WriteNullValue();
        }
    }
}
