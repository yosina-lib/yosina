// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Codegen.Generators;

/// <summary>
/// Generates binary data for IVS/SVS base transliterator mappings.
/// </summary>
public static class IvsSvsBaseTransliteratorGenerator
{
    /// <summary>
    /// Generates binary data containing IVS/SVS mapping records in a specific format.
    /// </summary>
    /// <param name="records">List of IVS/SVS base records to encode.</param>
    /// <returns>Binary data representation of the mapping records.</returns>
    public static byte[] GenerateBinaryData(IList<IvsSvsBaseRecord> records)
    {
        using var stream = new MemoryStream();
        using var writer = new BinaryWriter(stream);

        // Write record count in big-endian format
        writer.Write(ReverseBytes(records.Count));

        foreach (var record in records)
        {
            // IVS (can be 1 or 2 codepoints)
            var ivsCodepoints = record.Ivs ?? Array.Empty<int>();
            writer.Write(ReverseBytes(ivsCodepoints.Length > 0 ? ivsCodepoints[0] : 0));
            writer.Write(ReverseBytes(ivsCodepoints.Length > 1 ? ivsCodepoints[1] : 0));

            // SVS (can be null, 1 or 2 codepoints)
            var svsCodepoints = record.Svs ?? Array.Empty<int>();
            writer.Write(ReverseBytes(svsCodepoints.Length > 0 ? svsCodepoints[0] : 0));
            writer.Write(ReverseBytes(svsCodepoints.Length > 1 ? svsCodepoints[1] : 0));

            // base90 (single codepoint or null)
            var base90Codepoint = record.Base90 ?? 0;
            writer.Write(ReverseBytes(base90Codepoint));

            // base2004 (single codepoint or null)
            var base2004Codepoint = record.Base2004 ?? 0;
            writer.Write(ReverseBytes(base2004Codepoint));
        }

        return stream.ToArray();
    }

    private static int ReverseBytes(int value)
    {
        return (int)((value & 0x000000FFU) << 24 | (value & 0x0000FF00U) << 8 |
                     (value & 0x00FF0000U) >> 8 | (value & 0xFF000000U) >> 24);
    }
}
