import Foundation

public struct HiraKataTransliterator: Transliterator {
    /// Conversion mode
    public enum Mode: String, Codable {
        case hiraToKata = "hira_to_kata"
        case kataToHira = "kata_to_hira"
    }

    /// Options for the transliterator
    public struct Options: Codable {
        public var mode: Mode

        public init(mode: Mode = .hiraToKata) {
            self.mode = mode
        }
    }

    private let mappingTable: [Character: Character]

    // Static cache for mapping tables
    private static var hiraToKataCache: [Character: Character]?
    private static var kataToHiraCache: [Character: Character]?

    public init(options: Options = Options()) {
        switch options.mode {
        case .hiraToKata:
            if let cached = Self.hiraToKataCache {
                mappingTable = cached
            } else {
                mappingTable = Self.buildHiraToKataTable()
                Self.hiraToKataCache = mappingTable
            }
        case .kataToHira:
            if let cached = Self.kataToHiraCache {
                mappingTable = cached
            } else {
                mappingTable = Self.buildKataToHiraTable()
                Self.kataToHiraCache = mappingTable
            }
        }
    }

    private static func buildHiraToKataTable() -> [Character: Character] {
        var mapping: [Character: Character] = [:]

        // Main table mappings
        for entry in HiraKataTable.hiraganaKatakanaTable {
            if let hiragana = entry.hiragana {
                // Base character
                if let hiraBase = hiragana.base, let kataBase = entry.katakana.base {
                    mapping[hiraBase] = kataBase
                }

                // Voiced character
                if let hiraVoiced = hiragana.voiced, let kataVoiced = entry.katakana.voiced {
                    mapping[hiraVoiced] = kataVoiced
                }

                // Semi-voiced character
                if let hiraSemivoiced = hiragana.semivoiced, let kataSemivoiced = entry.katakana.semivoiced {
                    mapping[hiraSemivoiced] = kataSemivoiced
                }
            }
        }

        // Small character mappings
        for entry in HiraKataTable.hiraganaKatakanaSmallTable {
            mapping[entry.hiragana] = entry.katakana
        }

        return mapping
    }

    private static func buildKataToHiraTable() -> [Character: Character] {
        var mapping: [Character: Character] = [:]

        // Main table mappings
        for entry in HiraKataTable.hiraganaKatakanaTable {
            if let hiragana = entry.hiragana {
                // Base character
                if let kataBase = entry.katakana.base, let hiraBase = hiragana.base {
                    mapping[kataBase] = hiraBase
                }

                // Voiced character
                if let kataVoiced = entry.katakana.voiced, let hiraVoiced = hiragana.voiced {
                    mapping[kataVoiced] = hiraVoiced
                }

                // Semi-voiced character
                if let kataSemivoiced = entry.katakana.semivoiced, let hiraSemivoiced = hiragana.semivoiced {
                    mapping[kataSemivoiced] = hiraSemivoiced
                }
            }
        }

        // Small character mappings
        for entry in HiraKataTable.hiraganaKatakanaSmallTable {
            mapping[entry.katakana] = entry.hiragana
        }

        return mapping
    }

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar {
        var result: [TransliteratorChar] = []
        var offset = 0

        for char in chars {
            if let charValue = char.value, let replacement = mappingTable[charValue] {
                let newChar = TransliteratorChar(value: replacement, offset: offset, source: char)
                offset += replacement.utf8.count
                result.append(newChar)
            } else {
                let newChar = char.withOffset(offset)
                offset += char.utf8Count
                result.append(newChar)
            }
        }

        return result
    }
}
