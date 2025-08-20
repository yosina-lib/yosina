// Copyright (c) Yosina. All rights reserved.

using System.Globalization;

namespace Yosina.Codegen;

/// <summary>
/// Provides utility methods for Unicode code point operations.
/// </summary>
public static class UnicodeUtils
{
    /// <summary>
    /// Parses a Unicode code point from various string formats.
    /// </summary>
    /// <param name="value">The string value to parse (e.g., "U+1234", "0x1234", or a single character).</param>
    /// <returns>The parsed Unicode code point.</returns>
    public static int ParseUnicodeCodepoint(string value)
    {
        if (value.StartsWith("U+", StringComparison.OrdinalIgnoreCase))
        {
            return int.Parse(value.AsSpan(2), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
        }
        else if (value.StartsWith("0x", StringComparison.OrdinalIgnoreCase))
        {
            return int.Parse(value.AsSpan(2), NumberStyles.HexNumber, CultureInfo.InvariantCulture);
        }
        else if (value.Length == 1)
        {
            return char.ConvertToUtf32(value, 0);
        }
        else
        {
            throw new ArgumentException($"Invalid codepoint format: {value}", nameof(value));
        }
    }

    /// <summary>
    /// Converts a string to PascalCase.
    /// </summary>
    /// <param name="input">The input string.</param>
    /// <returns>The PascalCase string.</returns>
    public static string ToPascalCase(string input)
    {
        var parts = input.Split('_', '-');
        return string.Join(string.Empty, parts.Select(p => char.ToUpper(p[0], CultureInfo.InvariantCulture) + p.Substring(1)));
    }

    /// <summary>
    /// Converts a string to snake_case.
    /// </summary>
    /// <param name="input">The input string.</param>
    /// <returns>The snake_case string.</returns>
    public static string ToSnakeCase(string input)
    {
        var result = new System.Text.StringBuilder();
        for (int i = 0; i < input.Length; i++)
        {
            if (i > 0 && char.IsUpper(input[i]))
            {
                result.Append('_');
            }

            result.Append(char.ToLower(input[i], CultureInfo.InvariantCulture));
        }

        return result.ToString();
    }

    /// <summary>
    /// Escapes special characters in a string for C# string literals.
    /// </summary>
    /// <param name="input">The input string.</param>
    /// <returns>The escaped string.</returns>
    public static string EscapeString(string input)
    {
        return input
            .Replace("\\", "\\\\")
            .Replace("\"", "\\\"")
            .Replace("\n", "\\n")
            .Replace("\r", "\\r")
            .Replace("\t", "\\t");
    }
}
