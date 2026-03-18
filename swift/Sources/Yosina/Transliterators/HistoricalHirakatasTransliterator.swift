import Foundation

public struct HistoricalHirakatasTransliterator: Transliterator {
    /// Conversion mode for historical hiragana/katakana characters.
    public enum ConversionMode: String, Codable {
        /// Replace with the modern single-character equivalent.
        case simple
        /// Decompose into multiple modern characters.
        case decompose
        /// Leave the character as-is.
        case skip
    }

    /// Options for the transliterator.
    public struct Options: Codable, Equatable {
        /// How to convert historical hiragana (ゐ, ゑ).
        public var hiraganas: ConversionMode

        /// How to convert historical katakana (ヰ, ヱ).
        public var katakanas: ConversionMode

        /// How to convert voiced historical katakana (ヷ, ヸ, ヹ, ヺ).
        public var voicedKatakanas: ConversionMode

        public init(
            hiraganas: ConversionMode = .simple,
            katakanas: ConversionMode = .simple,
            voicedKatakanas: ConversionMode = .skip
        ) {
            self.hiraganas = hiraganas
            self.katakanas = katakanas
            self.voicedKatakanas = voicedKatakanas
        }
    }

    private let mapping: [Character: String]
    private let voicedKatakanas: ConversionMode

    private static let combiningDakuten: UnicodeScalar = "\u{3099}"
    private static let vuChar: Character = "\u{30F4}" // ヴ
    private static let uChar: Character = "\u{30A6}" // ウ

    /// Decomposed voiced historical kana mappings (keyed by base scalar, value is small vowel suffix).
    private static let voicedDecomposedMappingTable: [UnicodeScalar: Character] = [
        "\u{30EF}": "\u{30A1}", // ヷ → ァ
        "\u{30F0}": "\u{30A3}", // ヸ → ィ
        "\u{30F1}": "\u{30A7}", // ヹ → ェ
        "\u{30F2}": "\u{30A9}", // ヺ → ォ
    ]

    public init(options: Options = Options()) {
        var mapping: [Character: String] = [:]

        // Historical hiragana mappings
        switch options.hiraganas {
        case .simple:
            // ゐ (U+3090) → い
            mapping["\u{3090}"] = "\u{3044}"
            // ゑ (U+3091) → え
            mapping["\u{3091}"] = "\u{3048}"
        case .decompose:
            // ゐ (U+3090) → うぃ
            mapping["\u{3090}"] = "\u{3046}\u{3043}"
            // ゑ (U+3091) → うぇ
            mapping["\u{3091}"] = "\u{3046}\u{3047}"
        case .skip:
            break
        }

        // Historical katakana mappings
        switch options.katakanas {
        case .simple:
            // ヰ (U+30F0) → イ
            mapping["\u{30F0}"] = "\u{30A4}"
            // ヱ (U+30F1) → エ
            mapping["\u{30F1}"] = "\u{30A8}"
        case .decompose:
            // ヰ (U+30F0) → ウィ
            mapping["\u{30F0}"] = "\u{30A6}\u{30A3}"
            // ヱ (U+30F1) → ウェ
            mapping["\u{30F1}"] = "\u{30A6}\u{30A7}"
        case .skip:
            break
        }

        // Voiced historical katakana mappings (store only vowel suffix; VU emitted separately)
        switch options.voicedKatakanas {
        case .decompose, .simple:
            mapping["\u{30F7}"] = "\u{30A1}" // ヷ → ァ
            mapping["\u{30F8}"] = "\u{30A3}" // ヸ → ィ
            mapping["\u{30F9}"] = "\u{30A7}" // ヹ → ェ
            mapping["\u{30FA}"] = "\u{30A9}" // ヺ → ォ
        case .skip:
            break
        }

        self.mapping = mapping
        voicedKatakanas = options.voicedKatakanas
    }

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar {
        var result: [TransliteratorChar] = []
        var offset = 0

        for char in chars {
            // Check for decomposed voiced katakana: a Character with two scalars
            // where the first is a base (ワ, ヰ, ヱ, ヲ) and the second is combining dakuten.
            if let charValue = char.value {
                let scalars = charValue.unicodeScalars
                if scalars.count == 2,
                   scalars[scalars.index(after: scalars.startIndex)] == Self.combiningDakuten,
                   let vowel = Self.voicedDecomposedMappingTable[scalars[scalars.startIndex]]
                {
                    // This is a decomposed voiced katakana.
                    if voicedKatakanas == .decompose || voicedKatakanas == .simple {
                        // Emit U + dakuten + vowel
                        let uNewChar = TransliteratorChar(
                            value: Self.uChar,
                            offset: offset,
                            source: char
                        )
                        offset += Self.uChar.utf8.count
                        result.append(uNewChar)
                        let dakutenChar = TransliteratorChar(
                            value: Character(Self.combiningDakuten),
                            offset: offset,
                            source: char
                        )
                        offset += Character(Self.combiningDakuten).utf8.count
                        result.append(dakutenChar)
                        let vowelChar = TransliteratorChar(
                            value: vowel,
                            offset: offset,
                            source: char
                        )
                        offset += vowel.utf8.count
                        result.append(vowelChar)
                    } else {
                        // Skip mode: pass through as-is
                        let newChar = char.withOffset(offset)
                        offset += char.utf8Count
                        result.append(newChar)
                    }
                    continue
                }
            }

            if let charValue = char.value, let vowel = mapping[charValue] {
                // Check if this is a voiced precomposed kana — emit VU prefix
                let isVoiced = charValue == "\u{30F7}" || charValue == "\u{30F8}"
                    || charValue == "\u{30F9}" || charValue == "\u{30FA}"
                if isVoiced {
                    let vuNewChar = TransliteratorChar(
                        value: Self.vuChar,
                        offset: offset,
                        source: char
                    )
                    offset += Self.vuChar.utf8.count
                    result.append(vuNewChar)
                }
                for replacement in vowel {
                    let newChar = TransliteratorChar(
                        value: replacement,
                        offset: offset,
                        source: char
                    )
                    offset += replacement.utf8.count
                    result.append(newChar)
                }
            } else {
                let newChar = char.withOffset(offset)
                offset += char.utf8Count
                result.append(newChar)
            }
        }

        return result
    }
}
