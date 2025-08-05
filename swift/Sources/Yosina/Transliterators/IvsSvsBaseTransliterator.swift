import Foundation

public struct IvsSvsBaseTransliterator: Transliterator {
    public enum Mode {
        case ivsOrSvs // Convert base to IVS/SVS
        case base // Convert IVS/SVS to base
    }

    public enum Charset {
        case unijis90
        case unijis2004
    }

    public struct Options {
        public var mode: Mode = .ivsOrSvs
        public var charset: Charset = .unijis90

        public init() {}
    }

    private let options: Options

    // Lazy loaded mappings
    private static var _mappings: MappingData?
    private static let mappingsQueue = DispatchQueue(label: "com.yosina.ivs-svs-mappings")

    private struct MappingData {
        let baseToVariant90: [String: String]
        let variantToBase90: [String: String]
        let baseToVariant2004: [String: String]
        let variantToBase2004: [String: String]
    }

    private struct MappingEntry: Codable {
        let ivs: [String]?
        let svs: [String]?
        let base90: String
        let base2004: String
    }

    private static var mappings: MappingData {
        mappingsQueue.sync {
            if let existing = _mappings {
                return existing
            }

            let loaded = loadMappings()
            _mappings = loaded
            return loaded
        }
    }

    private static func loadMappings() -> MappingData {
        var baseToVariant90: [String: String] = [:]
        var variantToBase90: [String: String] = [:]
        var baseToVariant2004: [String: String] = [:]
        var variantToBase2004: [String: String] = [:]

        // Try to load from bundle resource
        if let url = Bundle.module.url(forResource: "ivs-svs-base-mappings", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let entries = try JSONDecoder().decode([MappingEntry].self, from: data)

                for entry in entries {
                    // Process IVS entries
                    if let ivs = entry.ivs, ivs.count >= 2 {
                        let base = parseUnicode(ivs[0])
                        let variant = ivs.map { parseUnicode($0) }.joined()

                        baseToVariant90[base] = variant
                        variantToBase90[variant] = parseUnicode(entry.base90)

                        baseToVariant2004[base] = variant
                        variantToBase2004[variant] = parseUnicode(entry.base2004)
                    }

                    // Process SVS entries
                    if let svs = entry.svs, svs.count >= 2 {
                        let base = parseUnicode(svs[0])
                        let variant = svs.map { parseUnicode($0) }.joined()

                        baseToVariant90[base] = variant
                        variantToBase90[variant] = parseUnicode(entry.base90)

                        baseToVariant2004[base] = variant
                        variantToBase2004[variant] = parseUnicode(entry.base2004)
                    }
                }
            } catch {
                print("Warning: Failed to load IVS/SVS mappings from JSON: \(error)")
            }
        } else {
            // Fallback: Try to load from file system relative to package
            let paths = [
                "../../../data/ivs-svs-base-mappings.json",
                "../../data/ivs-svs-base-mappings.json",
                "../data/ivs-svs-base-mappings.json",
                "data/ivs-svs-base-mappings.json",
            ]

            for path in paths {
                let url = URL(fileURLWithPath: path)
                if FileManager.default.fileExists(atPath: url.path) {
                    do {
                        let data = try Data(contentsOf: url)
                        let entries = try JSONDecoder().decode([MappingEntry].self, from: data)

                        for entry in entries {
                            // Process IVS entries
                            if let ivs = entry.ivs, ivs.count >= 2 {
                                let base = parseUnicode(ivs[0])
                                let variant = ivs.map { parseUnicode($0) }.joined()

                                baseToVariant90[base] = variant
                                variantToBase90[variant] = parseUnicode(entry.base90)

                                baseToVariant2004[base] = variant
                                variantToBase2004[variant] = parseUnicode(entry.base2004)
                            }

                            // Process SVS entries
                            if let svs = entry.svs, svs.count >= 2 {
                                let base = parseUnicode(svs[0])
                                let variant = svs.map { parseUnicode($0) }.joined()

                                baseToVariant90[base] = variant
                                variantToBase90[variant] = parseUnicode(entry.base90)

                                baseToVariant2004[base] = variant
                                variantToBase2004[variant] = parseUnicode(entry.base2004)
                            }
                        }
                        break
                    } catch {
                        continue
                    }
                }
            }
        }

        return MappingData(
            baseToVariant90: baseToVariant90,
            variantToBase90: variantToBase90,
            baseToVariant2004: baseToVariant2004,
            variantToBase2004: variantToBase2004
        )
    }

    private static func parseUnicode(_ str: String) -> String {
        let hex = str.replacingOccurrences(of: "U+", with: "")
        let parts = hex.split(separator: " ")

        return parts.compactMap { part in
            guard let value = Int(part, radix: 16),
                  let scalar = UnicodeScalar(value)
            else {
                return nil
            }
            return String(Character(scalar))
        }.joined()
    }

    private var baseToVariant: [String: String] {
        switch options.charset {
        case .unijis90:
            return Self.mappings.baseToVariant90
        case .unijis2004:
            return Self.mappings.baseToVariant2004
        }
    }

    private var variantToBase: [String: String] {
        switch options.charset {
        case .unijis90:
            return Self.mappings.variantToBase90
        case .unijis2004:
            return Self.mappings.variantToBase2004
        }
    }

    public init(options: Options = Options()) {
        self.options = options
    }

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar {
        var result: [TransliteratorChar] = []
        let charsArray = Array(chars)
        var i = 0
        var offset = 0

        while i < charsArray.count {
            let char = charsArray[i]

            if options.mode == .base {
                // Try to match IVS/SVS sequence (2 characters)
                if i + 1 < charsArray.count {
                    let sequence = char.value + charsArray[i + 1].value
                    if let base = variantToBase[sequence] {
                        result.append(TransliteratorChar(value: base, offset: char.offset, source: char))
                        i += 2
                        continue
                    }
                }
            } else {
                // Try to convert base to variant
                if let variant = baseToVariant[char.value] {
                    // Split variant into separate characters
                    let variantChars = Array(variant)
                    if variantChars.count >= 2 {
                        let char1 = TransliteratorChar(value: String(variantChars[0]), offset: offset, source: char)
                        offset += char1.value.count
                        result.append(char1)

                        let char2 = TransliteratorChar(value: String(variantChars[1]), offset: offset, source: nil)
                        offset += char2.value.count
                        result.append(char2)
                        i += 1
                        continue
                    }
                }
            }
            let updatedChar = char.withOffset(offset)
            offset += updatedChar.value.count
            result.append(updatedChar)
            i += 1
        }

        return result
    }
}
