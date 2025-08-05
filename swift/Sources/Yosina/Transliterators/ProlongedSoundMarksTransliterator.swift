import Foundation

public struct ProlongedSoundMarksTransliterator: Transliterator {
    private struct CharType: OptionSet {
        let rawValue: Int

        static let none = CharType([])
        static let uppercaseLetter = CharType(rawValue: 1 << 0)
        static let lowercaseLetter = CharType(rawValue: 1 << 1)
        static let cjkIdeograph = CharType(rawValue: 1 << 2)
        static let hiragana = CharType(rawValue: 1 << 3)
        static let katakana = CharType(rawValue: 1 << 4)
        static let halfwidthKatakana = CharType(rawValue: 1 << 5)
        static let fullwidthUppercaseLetter = CharType(rawValue: 1 << 6)
        static let fullwidthLowercaseLetter = CharType(rawValue: 1 << 7)
        static let hyphenMinus = CharType(rawValue: 1 << 8)
        static let nDash = CharType(rawValue: 1 << 9)
        static let mDash = CharType(rawValue: 1 << 10)
        static let cjkSymbol = CharType(rawValue: 1 << 11)
        static let middleDot = CharType(rawValue: 1 << 12)
        static let waveSymbol = CharType(rawValue: 1 << 13)
        static let twoDotLeader = CharType(rawValue: 1 << 14)
        static let ellipsis = CharType(rawValue: 1 << 15)
        static let prolongedSoundMark = CharType(rawValue: 1 << 16)
        static let smallHiragana = CharType(rawValue: 1 << 17)
        static let smallKatakana = CharType(rawValue: 1 << 18)
        static let smallHalfwidthKatakana = CharType(rawValue: 1 << 19)
        static let voicedMark = CharType(rawValue: 1 << 20)
        static let semiVoicedMark = CharType(rawValue: 1 << 21)
        static let iterationMark = CharType(rawValue: 1 << 22)
        static let verticalIterationMark = CharType(rawValue: 1 << 23)
        static let voicedIterationMark = CharType(rawValue: 1 << 24)
        static let verticalVoicedIterationMark = CharType(rawValue: 1 << 25)
        static let halfwidthVoicedMark = CharType(rawValue: 1 << 26)
        static let halfwidthSemiVoicedMark = CharType(rawValue: 1 << 27)
        static let whiteSpace = CharType(rawValue: 1 << 28)
        static let hyphenLike = CharType(rawValue: 1 << 29)

        static let latin: CharType = [.uppercaseLetter, .lowercaseLetter]
        static let fullwidthLatin: CharType = [.fullwidthUppercaseLetter, .fullwidthLowercaseLetter]
        static let kana: CharType = [.hiragana, .katakana, .halfwidthKatakana, .smallHiragana, .smallKatakana, .smallHalfwidthKatakana]
        static let voicingMark: CharType = [.voicedMark, .semiVoicedMark, .halfwidthVoicedMark, .halfwidthSemiVoicedMark]
    }

    // Character type lookup table for common characters
    private static let charTypeTable: [UInt32: CharType] = [
        // Hyphen-like characters
        0x002D: [.hyphenMinus, .hyphenLike],
        0x2013: [.nDash, .hyphenLike],
        0x2014: [.mDash, .hyphenLike],
        0x2015: [.mDash, .hyphenLike],
        0x2212: [.cjkSymbol, .hyphenLike],

        // Voicing marks
        0x3099: .voicedMark,
        0x309B: .voicedMark,
        0x309A: .semiVoicedMark,
        0x309C: .semiVoicedMark,
        0xFF9E: .halfwidthVoicedMark,
        0xFF9F: .halfwidthSemiVoicedMark,

        // Iteration marks
        0x3005: .iterationMark,
        0x309D: [.hiragana, .iterationMark],
        0x30FD: [.katakana, .iterationMark],
        0x309E: [.hiragana, .voicedIterationMark],
        0x30FE: [.katakana, .voicedIterationMark],
        0x3031: .verticalIterationMark,
        0x3032: .verticalIterationMark,
        0x3033: .verticalVoicedIterationMark,
        0x3034: .verticalVoicedIterationMark,

        // Prolonged sound marks
        0x30FC: .prolongedSoundMark,
        0xFF70: .prolongedSoundMark,

        // Other symbols
        0x30FB: .middleDot,
        0xFF65: .middleDot,
        0x301C: .waveSymbol,
        0xFF5E: .waveSymbol,
        0x2025: .twoDotLeader,
        0xFE30: .twoDotLeader,
        0x2026: .ellipsis,
        0xFE19: .ellipsis,
    ]

    // Small kana characters
    private static let smallHiraganaSet: Set<UInt32> = [
        0x3041, 0x3043, 0x3045, 0x3047, 0x3049, // ぁ ぃ ぅ ぇ ぉ
        0x304B, 0x304D, 0x304F, 0x3051, 0x3053, // ゕ ゖ っ ゃ ゅ
        0x3055, 0x3057, 0x3059, 0x305B, 0x305D, // ょ ゎ
        0x305F, 0x3061, 0x3063,
    ]

    private static let smallKatakanaSet: Set<UInt32> = [
        0x30A1, 0x30A3, 0x30A5, 0x30A7, 0x30A9, // ァ ィ ゥ ェ ォ
        0x30AB, 0x30AD, 0x30AF, 0x30B1, 0x30B3, // ヵ ヶ ッ ャ ュ
        0x30B5, 0x30B7, 0x30B9, 0x30BB, 0x30BD, // ョ ヮ
        0x30BF, 0x30C1, 0x30C3,
    ]

    private static let smallHalfwidthKatakanaSet: Set<UInt32> = [
        0xFF67, 0xFF68, 0xFF69, 0xFF6A, 0xFF6B, // ｧ ｨ ｩ ｪ ｫ
        0xFF6C, 0xFF6D, 0xFF6E, 0xFF6F, // ｬ ｭ ｮ ｯ
    ]

    public init() {}

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar {
        var result: [TransliteratorChar] = []
        var prevType = CharType.none
        var offset = 0

        for char in chars {
            let currentType = getCharType(char.value)

            if currentType.contains(.hyphenLike) && shouldConvertToProlongedMark(prevType) {
                let prolongedMark = getProlongedMark(for: prevType)
                result.append(TransliteratorChar(value: prolongedMark, offset: offset, source: char))
                offset += prolongedMark.count
            } else {
                result.append(TransliteratorChar(value: char.value, offset: offset, source: char))
                offset += char.value.count
            }

            prevType = currentType
        }

        return result
    }

    private func shouldConvertToProlongedMark(_ prevType: CharType) -> Bool {
        return prevType.contains(.hiragana) ||
            prevType.contains(.katakana) ||
            prevType.contains(.halfwidthKatakana) ||
            prevType.contains(.smallHiragana) ||
            prevType.contains(.smallKatakana) ||
            prevType.contains(.smallHalfwidthKatakana) ||
            prevType.contains(.iterationMark) ||
            prevType.contains(.voicedIterationMark)
    }

    private func getProlongedMark(for prevType: CharType) -> String {
        if prevType.contains(.halfwidthKatakana) || prevType.contains(.smallHalfwidthKatakana) {
            return "\u{FF70}" // Halfwidth katakana-hiragana prolonged sound mark
        } else {
            return "\u{30FC}" // Katakana-hiragana prolonged sound mark
        }
    }

    private func getCharType(_ char: String) -> CharType {
        guard let scalar = char.unicodeScalars.first else { return .none }
        let value = scalar.value

        // Check lookup table first
        if let type = Self.charTypeTable[value] {
            return type
        }

        var type = CharType.none

        // Character ranges that can't be efficiently represented in a lookup table
        // Latin letters
        if (0x0041 ... 0x005A).contains(value) {
            type.insert(.uppercaseLetter)
        } else if (0x0061 ... 0x007A).contains(value) {
            type.insert(.lowercaseLetter)
        }
        // Fullwidth Latin
        else if (0xFF21 ... 0xFF3A).contains(value) {
            type.insert(.fullwidthUppercaseLetter)
        } else if (0xFF41 ... 0xFF5A).contains(value) {
            type.insert(.fullwidthLowercaseLetter)
        }
        // CJK Ideograph
        else if (0x4E00 ... 0x9FFF).contains(value) || (0x3400 ... 0x4DBF).contains(value) {
            type.insert(.cjkIdeograph)
        }
        // Hiragana
        else if (0x3041 ... 0x3096).contains(value) {
            type.insert(.hiragana)
            if Self.smallHiraganaSet.contains(value) {
                type.insert(.smallHiragana)
            }
        }
        // Katakana
        else if (0x30A1 ... 0x30FA).contains(value) {
            type.insert(.katakana)
            if Self.smallKatakanaSet.contains(value) {
                type.insert(.smallKatakana)
            }
        }
        // Halfwidth katakana
        else if (0xFF61 ... 0xFF9F).contains(value) {
            type.insert(.halfwidthKatakana)
            if Self.smallHalfwidthKatakanaSet.contains(value) {
                type.insert(.smallHalfwidthKatakana)
            }
        }
        // CJK symbols (range not covered in lookup table)
        else if (0x3000 ... 0x303F).contains(value) {
            type.insert(.cjkSymbol)
        }
        // Whitespace
        else if CharacterSet.whitespacesAndNewlines.contains(scalar) {
            type.insert(.whiteSpace)
        }

        return type
    }
}
