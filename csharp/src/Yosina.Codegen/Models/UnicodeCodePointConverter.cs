// Copyright (c) Yosina. All rights reserved.

using System.Text.Json;
using System.Text.Json.Serialization;

namespace Yosina.CodeGen;

/// <summary>
/// JSON converter for Unicode code points that serializes to/from "U+XXXX" format.
/// </summary>
public class UnicodeCodePointConverter : JsonConverter<int>
{
    /// <inheritdoc/>
    public override int Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        var stringValue = reader.GetString();
        return stringValue != null ? UnicodeUtils.ParseUnicodeCodepoint(stringValue) : 0;
    }

    /// <inheritdoc/>
    public override void Write(Utf8JsonWriter writer, int value, JsonSerializerOptions options)
    {
        writer.WriteStringValue($"U+{value:X4}");
    }
}
