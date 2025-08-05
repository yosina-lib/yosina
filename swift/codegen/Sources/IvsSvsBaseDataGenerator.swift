import Foundation

enum IvsSvsBaseDataGenerator {
    static func generate(from jsonPath: String, to outputPath: String) throws {
        let jsonData = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
        let entries = try JSONDecoder().decode([IvsSvsMappingEntry].self, from: jsonData)

        var data = Data()

        // Write count as big-endian Int32
        var count = Int32(entries.count).bigEndian
        data.append(Data(bytes: &count, count: 4))

        // Write each entry
        for entry in entries {
            // IVS (2 code points or 0 if not present)
            if let ivs = entry.ivs, ivs.count >= 2 {
                let cp1 = parseCodePoint(ivs[0])
                let cp2 = parseCodePoint(ivs[1])
                var cp1BE = cp1.bigEndian
                var cp2BE = cp2.bigEndian
                data.append(Data(bytes: &cp1BE, count: 4))
                data.append(Data(bytes: &cp2BE, count: 4))
            } else {
                var zero: Int32 = 0
                data.append(Data(bytes: &zero, count: 4))
                data.append(Data(bytes: &zero, count: 4))
            }

            // SVS (2 code points or 0 if not present)
            if let svs = entry.svs, svs.count >= 2 {
                let cp1 = parseCodePoint(svs[0])
                let cp2 = parseCodePoint(svs[1])
                var cp1BE = cp1.bigEndian
                var cp2BE = cp2.bigEndian
                data.append(Data(bytes: &cp1BE, count: 4))
                data.append(Data(bytes: &cp2BE, count: 4))
            } else {
                var zero: Int32 = 0
                data.append(Data(bytes: &zero, count: 4))
                data.append(Data(bytes: &zero, count: 4))
            }

            // Base90 (1 code point)
            let base90 = parseCodePoint(entry.base90 ?? "U+0000")
            var base90BE = base90.bigEndian
            data.append(Data(bytes: &base90BE, count: 4))

            // Base2004 (1 code point)
            let base2004 = parseCodePoint(entry.base2004 ?? "U+0000")
            var base2004BE = base2004.bigEndian
            data.append(Data(bytes: &base2004BE, count: 4))
        }

        try data.write(to: URL(fileURLWithPath: outputPath))
        print("Generated \(outputPath) with \(entries.count) entries")
    }

    private static func parseCodePoint(_ str: String) -> Int32 {
        let hex = str.replacingOccurrences(of: "U+", with: "")
        return Int32(hex, radix: 16) ?? 0
    }
}

private struct IvsSvsMappingEntry: Codable {
    let ivs: [String]?
    let svs: [String]?
    let base90: String?
    let base2004: String?
}
