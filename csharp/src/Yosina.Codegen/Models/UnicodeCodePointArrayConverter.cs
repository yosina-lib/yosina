// Copyright (c) Yosina. All rights reserved.

using System.Text.Json;
using System.Text.Json.Serialization;

namespace Yosina.CodeGen;

/// <summary>
/// JSON converter for arrays of Unicode code points that serializes to/from "U+XXXX" format.
/// </summary>
public class UnicodeCodePointArrayConverter : JsonConverter<int[]>
{
    /// <inheritdoc/>
    public override int[]? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.Null)
        {
            return null;
        }

        if (reader.TokenType != JsonTokenType.StartArray)
        {
            throw new JsonException("Expected array");
        }

        var list = new List<int>();
        while (reader.Read())
        {
            if (reader.TokenType == JsonTokenType.EndArray)
            {
                break;
            }

            if (reader.TokenType == JsonTokenType.String)
            {
                var stringValue = reader.GetString();
                if (stringValue != null)
                {
                    list.Add(UnicodeUtils.ParseUnicodeCodepoint(stringValue));
                }
            }
        }

        return list.ToArray();
    }

    /// <inheritdoc/>
    public override void Write(Utf8JsonWriter writer, int[] value, JsonSerializerOptions options)
    {
        writer.WriteStartArray();
        foreach (var codePoint in value)
        {
            writer.WriteStringValue($"U+{codePoint:X4}");
        }

        writer.WriteEndArray();
    }
}
