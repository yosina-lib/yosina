import Foundation

/// Japanese iteration marks transliterator.
///
/// This transliterator handles the replacement of Japanese iteration marks with the appropriate
/// repeated characters:
/// - ゝ (hiragana repetition): Repeats previous hiragana if valid
/// - ゞ (hiragana voiced repetition): Repeats previous hiragana with voicing if possible
/// - ヽ (katakana repetition): Repeats previous katakana if valid
/// - ヾ (katakana voiced repetition): Repeats previous katakana with voicing if possible
/// - 々 (kanji repetition): Repeats previous kanji
///
/// Invalid combinations remain unchanged. Characters that can't be repeated include:
/// - Voiced/semi-voiced characters
/// - Hatsuon (ん/ン)
/// - Sokuon (っ/ッ)
///
/// Halfwidth katakana with iteration marks are NOT supported.
/// Consecutive iteration marks: only the first one is expanded.
public struct JapaneseIterationMarksTransliterator: Transliterator {
    public struct Options {
        public init() {}
    }

    // Iteration mark characters
    private static let hiraganaIterationMark: UInt32 = 0x309D // ゝ
    private static let hiraganaVoicedIterationMark: UInt32 = 0x309E // ゞ
    private static let katakanaIterationMark: UInt32 = 0x30FD // ヽ
    private static let katakanaVoicedIterationMark: UInt32 = 0x30FE // ヾ
    private static let kanjiIterationMark: UInt32 = 0x3005 // 々

    // Character type
    private enum CharType {
        case other
        case hiragana
        case katakana
        case kanji
    }

    // Special characters that cannot be repeated
    private static let hatsuonChars: Set<UInt32> = [
        0x3093, // ん
        0x30F3, // ン
        0xFF9D, // ﾝ (halfwidth)
    ]

    private static let sokuonChars: Set<UInt32> = [
        0x3063, // っ
        0x30C3, // ッ
        0xFF6F, // ｯ (halfwidth)
    ]

    // Semi-voiced characters
    private static let semiVoicedChars: Set<String> = [
        // Hiragana semi-voiced
        "ぱ", "ぴ", "ぷ", "ぺ", "ぽ",
        // Katakana semi-voiced
        "パ", "ピ", "プ", "ペ", "ポ",
    ]

    // Voicing mappings for hiragana
    private static let hiraganaVoicing: [String: String] = [
        "か": "が", "き": "ぎ", "く": "ぐ", "け": "げ", "こ": "ご",
        "さ": "ざ", "し": "じ", "す": "ず", "せ": "ぜ", "そ": "ぞ",
        "た": "だ", "ち": "ぢ", "つ": "づ", "て": "で", "と": "ど",
        "は": "ば", "ひ": "び", "ふ": "ぶ", "へ": "べ", "ほ": "ぼ",
    ]

    // Voicing mappings for katakana
    private static let katakanaVoicing: [String: String] = [
        "カ": "ガ", "キ": "ギ", "ク": "グ", "ケ": "ゲ", "コ": "ゴ",
        "サ": "ザ", "シ": "ジ", "ス": "ズ", "セ": "ゼ", "ソ": "ゾ",
        "タ": "ダ", "チ": "ヂ", "ツ": "ヅ", "テ": "デ", "ト": "ド",
        "ハ": "バ", "ヒ": "ビ", "フ": "ブ", "ヘ": "ベ", "ホ": "ボ",
        "ウ": "ヴ",
    ]

    // Derive voiced characters from voicing mappings
    private static let voicedChars: Set<String> = {
        var chars = Set<String>()
        chars.formUnion(hiraganaVoicing.values)
        chars.formUnion(katakanaVoicing.values)
        return chars
    }()

    private let options: Options

    public init(options: Options = Options()) {
        self.options = options
    }

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar {
        var result: [TransliteratorChar] = []
        var prevCharInfo: CharInfo?
        var prevWasIterationMark = false
        var offset = 0

        for char in chars {
            let currentChar = char.value
            guard let scalar = currentChar.unicodeScalars.first else {
                result.append(TransliteratorChar(value: currentChar, offset: offset, source: char))
                offset += currentChar.utf16.count
                continue
            }

            let codepoint = scalar.value

            if isIterationMark(codepoint) {
                // Check if previous character was also an iteration mark
                if prevWasIterationMark {
                    // Don't replace consecutive iteration marks
                    result.append(TransliteratorChar(value: currentChar, offset: offset, source: char))
                    offset += currentChar.utf16.count
                    prevWasIterationMark = true
                    continue
                }

                // Try to replace the iteration mark
                var replacement: String?
                if let prevInfo = prevCharInfo {
                    switch codepoint {
                    case Self.hiraganaIterationMark:
                        // Repeat previous hiragana if valid
                        if prevInfo.type == .hiragana {
                            replacement = prevInfo.charStr
                        }

                    case Self.hiraganaVoicedIterationMark:
                        // Repeat previous hiragana with voicing if possible
                        if prevInfo.type == .hiragana {
                            replacement = Self.hiraganaVoicing[prevInfo.charStr]
                        }

                    case Self.katakanaIterationMark:
                        // Repeat previous katakana if valid
                        if prevInfo.type == .katakana {
                            replacement = prevInfo.charStr
                        }

                    case Self.katakanaVoicedIterationMark:
                        // Repeat previous katakana with voicing if possible
                        if prevInfo.type == .katakana {
                            replacement = Self.katakanaVoicing[prevInfo.charStr]
                        }

                    case Self.kanjiIterationMark:
                        // Repeat previous kanji
                        if prevInfo.type == .kanji {
                            replacement = prevInfo.charStr
                        }

                    default:
                        break
                    }
                }

                if let replacement = replacement {
                    // Replace the iteration mark
                    result.append(TransliteratorChar(value: replacement, offset: offset, source: char))
                    offset += replacement.utf16.count
                    prevWasIterationMark = true
                    // Keep the original prevCharInfo - don't update it
                } else {
                    // Couldn't replace the iteration mark
                    result.append(TransliteratorChar(value: currentChar, offset: offset, source: char))
                    offset += currentChar.utf16.count
                    prevWasIterationMark = true
                }
            } else {
                // Not an iteration mark
                result.append(TransliteratorChar(value: currentChar, offset: offset, source: char))
                offset += currentChar.utf16.count

                // Update previous character info
                let charType = getCharType(currentChar)
                if charType != .other {
                    prevCharInfo = CharInfo(charStr: currentChar, type: charType)
                } else {
                    prevCharInfo = nil
                }

                prevWasIterationMark = false
            }
        }

        return result
    }

    private func isIterationMark(_ codepoint: UInt32) -> Bool {
        return codepoint == Self.hiraganaIterationMark
            || codepoint == Self.hiraganaVoicedIterationMark
            || codepoint == Self.katakanaIterationMark
            || codepoint == Self.katakanaVoicedIterationMark
            || codepoint == Self.kanjiIterationMark
    }

    private func getCharType(_ charStr: String) -> CharType {
        guard let scalar = charStr.unicodeScalars.first else { return .other }
        let codepoint = scalar.value

        // Check if it's hatsuon or sokuon
        if Self.hatsuonChars.contains(codepoint) || Self.sokuonChars.contains(codepoint) {
            return .other
        }

        // Check if it's voiced or semi-voiced
        if Self.voicedChars.contains(charStr) || Self.semiVoicedChars.contains(charStr) {
            return .other
        }

        // Hiragana (excluding special marks)
        if (0x3041 ... 0x3096).contains(codepoint) {
            return .hiragana
        }

        // Katakana (excluding halfwidth and special marks)
        if (0x30A1 ... 0x30FA).contains(codepoint) {
            return .katakana
        }

        // Kanji - CJK Unified Ideographs (common ranges)
        if (0x4E00 ... 0x9FFF).contains(codepoint)
            || (0x3400 ... 0x4DBF).contains(codepoint)
            || (0x20000 ... 0x2A6DF).contains(codepoint)
            || (0x2A700 ... 0x2B73F).contains(codepoint)
            || (0x2B740 ... 0x2B81F).contains(codepoint)
            || (0x2B820 ... 0x2CEAF).contains(codepoint)
            || (0x2CEB0 ... 0x2EBEF).contains(codepoint)
            || (0x30000 ... 0x3134F).contains(codepoint)
        {
            return .kanji
        }

        return .other
    }

    private struct CharInfo {
        let charStr: String
        let type: CharType
    }
}
