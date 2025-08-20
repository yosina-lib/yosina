// Copyright (c) Yosina. All rights reserved.

namespace Yosina.JsonConverters;

/// <summary>
/// Specifies the JSON string value to use when serializing/deserializing an enum value.
/// This attribute is used to map enum values to their string representations in JSON.
/// </summary>
[AttributeUsage(AttributeTargets.Field, AllowMultiple = false)]
internal class JsonEnumValueAttribute : Attribute
{
    /// <summary>
    /// Initializes a new instance of the <see cref="JsonEnumValueAttribute"/> class.
    /// </summary>
    /// <param name="value">The string value to use in JSON serialization.</param>
    public JsonEnumValueAttribute(string value)
    {
        this.Value = value ?? throw new ArgumentNullException(nameof(value));
    }

    /// <summary>
    /// Gets the string value to use in JSON serialization.
    /// </summary>
    public string Value { get; }
}
