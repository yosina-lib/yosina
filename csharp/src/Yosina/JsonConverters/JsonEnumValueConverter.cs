// Copyright (c) Yosina. All rights reserved.

using System.Reflection;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace Yosina.JsonConverters;

/// <summary>
/// Base JSON converter for enums that use JsonEnumValueAttribute.
/// </summary>
/// <typeparam name="TEnum">The enum type to convert.</typeparam>
internal class JsonEnumValueConverter<TEnum> : JsonConverter<TEnum>
    where TEnum : struct, Enum
{
    /// <inheritdoc/>
    public override TEnum Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        var value = reader.GetString();
        if (value == null)
        {
            throw new JsonException($"Null value for enum {typeof(TEnum).Name}");
        }

        foreach (var field in typeof(TEnum).GetFields(BindingFlags.Public | BindingFlags.Static))
        {
            var attribute = field.GetCustomAttribute<JsonEnumValueAttribute>();
            if (attribute != null && string.Equals(attribute.Value, value, StringComparison.Ordinal))
            {
                return (TEnum)field.GetValue(null)!;
            }
        }

        throw new JsonException($"Invalid {typeof(TEnum).Name} value: {value}");
    }

    /// <inheritdoc/>
    public override void Write(Utf8JsonWriter writer, TEnum value, JsonSerializerOptions options)
    {
        var field = typeof(TEnum).GetField(value.ToString());
        var attribute = field?.GetCustomAttribute<JsonEnumValueAttribute>();

        if (attribute == null)
        {
            throw new JsonException($"No JsonEnumValue attribute found for {value}");
        }

        writer.WriteStringValue(attribute.Value);
    }
}
