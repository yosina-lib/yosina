import Foundation

/// Japanese iteration marks transliterator.
///
/// This transliterator handles the replacement of Japanese iteration marks with the appropriate
/// repeated characters:
/// - ゝ (hiragana repetition): Repeats previous hiragana if valid
/// - ゞ (hiragana voiced repetition): Repeats previous hiragana with voicing if possible
/// - 〱 (vertical hiragana repetition): Same as ゝ
/// - 〲 (vertical hiragana voiced repetition): Same as ゞ
/// - ヽ (katakana repetition): Repeats previous katakana if valid
/// - ヾ (katakana voiced repetition): Repeats previous katakana with voicing if possible
/// - 〳 (vertical katakana repetition): Same as ヽ
/// - 〴 (vertical katakana voiced repetition): Same as ヾ
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
    private static let hiraganaIterationMark: Character = "ゝ"
    private static let hiraganaVoicedIterationMark: Character = "ゞ"
    private static let verticalHiraganaIterationMark: Character = "〱"
    private static let verticalHiraganaVoicedIterationMark: Character = "〲"
    private static let katakanaIterationMark: Character = "ヽ"
    private static let katakanaVoicedIterationMark: Character = "ヾ"
    private static let verticalKatakanaIterationMark: Character = "〳"
    private static let verticalKatakanaVoicedIterationMark: Character = "〴"
    private static let kanjiIterationMark: Character = "々"

    private static let hiraganaHatsuon: Character = "ん"
    private static let katakanaHatsuon: Character = "ン"
    private static let hiraganaSokuon: Character = "っ"
    private static let katakanaSokuon: Character = "ッ"

    private enum Voicing {
        case none
        case voiced
        case semiVoiced
    }

    // Character type
    private enum CharType {
        case other
        case hiragana(voiced: Voicing)
        case katakana(voiced: Voicing)
        case kanji
        case hiraganaIterationMark(voiced: Voicing)
        case katakanaIterationMark(voiced: Voicing)
        case kanjiIterationMark
    }

    private struct CharInfo {
        let char: Character
        let type: CharType

        init(_ char: Character, _ type: CharType) {
            self.char = char
            self.type = type
        }
    }

    // Hiragana semi-voiced
    private static let hiraganaSemiVoiced: [(Character, Character)] = [
        ("ぱ", "ば"), ("ぴ", "び"), ("ぷ", "ぶ"), ("ぺ", "べ"), ("ぽ", "ぼ"),
    ]

    // Katakana semi-voiced
    private static let katakanaSemiVoiced: [(Character, Character)] = [
        ("パ", "バ"), ("ピ", "ビ"), ("プ", "ブ"), ("ペ", "ベ"), ("ポ", "ボ"),
    ]

    // Voicing mappings for hiragana
    private static let hiraganaVoicing: [(Character, Character)] = [
        ("か", "が"), ("き", "ぎ"), ("く", "ぐ"), ("け", "げ"), ("こ", "ご"),
        ("さ", "ざ"), ("し", "じ"), ("す", "ず"), ("せ", "ぜ"), ("そ", "ぞ"),
        ("た", "だ"), ("ち", "ぢ"), ("つ", "づ"), ("て", "で"), ("と", "ど"),
        ("は", "ば"), ("ひ", "び"), ("ふ", "ぶ"), ("へ", "べ"), ("ほ", "ぼ"),
    ]

    // Voicing mappings for katakana
    private static let katakanaVoicing: [(Character, Character)] = [
        ("カ", "ガ"), ("キ", "ギ"), ("ク", "グ"), ("ケ", "ゲ"), ("コ", "ゴ"),
        ("サ", "ザ"), ("シ", "ジ"), ("ス", "ズ"), ("セ", "ゼ"), ("ソ", "ゾ"),
        ("タ", "ダ"), ("チ", "ヂ"), ("ツ", "ヅ"), ("テ", "デ"), ("ト", "ド"),
        ("ハ", "バ"), ("ヒ", "ビ"), ("フ", "ブ"), ("ヘ", "ベ"), ("ホ", "ボ"),
        ("ウ", "ヴ"),
    ]

    private static let hiraganaNonvoicedToVoiced: [Character: Character] = {
        var chars = [Character: Character]()
        for (nonvoiced, voiced) in hiraganaVoicing {
            chars[nonvoiced] = voiced
        }
        return chars
    }()

    private static let katakanaNonvoicedToVoiced: [Character: Character] = {
        var chars = [Character: Character]()
        for (nonvoiced, voiced) in katakanaVoicing {
            chars[nonvoiced] = voiced
        }
        return chars
    }()

    private static let hiraganaVoicedToNonvoiced: [Character: Character] = {
        var chars = [Character: Character]()
        for (nonvoiced, voiced) in hiraganaVoicing {
            chars[voiced] = nonvoiced
        }
        return chars
    }()

    private static let hiraganaSemiVoicedToNonvoiced: [Character: Character] = {
        var chars = [Character: Character]()
        for (nonvoiced, voiced) in hiraganaSemiVoiced {
            chars[voiced] = nonvoiced
        }
        return chars
    }()

    private static let katakanaVoicedToNonvoiced: [Character: Character] = {
        var chars = [Character: Character]()
        for (nonvoiced, voiced) in katakanaVoicing {
            chars[voiced] = nonvoiced
        }
        return chars
    }()

    private static let katakanaSemiVoicedToNonvoiced: [Character: Character] = {
        var chars = [Character: Character]()
        for (nonvoiced, voiced) in katakanaSemiVoiced {
            chars[voiced] = nonvoiced
        }
        return chars
    }()

    private let options: Options

    public init(options: Options = Options()) {
        self.options = options
    }

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar]
        where S.Element == TransliteratorChar
    {
        var result: [TransliteratorChar] = []
        var lastNonIterationCharInfo: CharInfo?
        var prevCharInfo: CharInfo?
        var offset = 0

        for char in chars {
            guard let currentChar = char.value else {
                result.append(char.withOffset(offset))
                offset += char.utf8Count
                continue
            }
            let charType = getCharType(currentChar)
            outer: switch charType {
            case .other:
                break
            case let .hiraganaIterationMark(voiced):
                guard let prevCharInfo_ = prevCharInfo else {
                    break
                }
                switch prevCharInfo_.type {
                case .hiragana(voiced: .none):
                    lastNonIterationCharInfo = CharInfo(prevCharInfo_.char, prevCharInfo_.type)
                case .hiragana(voiced: .voiced):
                    guard let nonVoiced = Self.hiraganaVoicedToNonvoiced[prevCharInfo_.char] else {
                        break outer
                    }
                    lastNonIterationCharInfo = CharInfo(nonVoiced, .hiragana(voiced: .none))
                case .hiraganaIterationMark:
                    break outer
                default:
                    break outer
                }
                guard let lastNonIterationCharInfo = lastNonIterationCharInfo else {
                    break outer
                }
                guard case .hiragana = lastNonIterationCharInfo.type else {
                    break outer
                }
                if voiced == .voiced {
                    // Repeat previous hiragana with voicing
                    if let nonVoiced = Self.hiraganaNonvoicedToVoiced[lastNonIterationCharInfo.char] {
                        result.append(
                            TransliteratorChar(value: nonVoiced, offset: offset, source: char))
                        offset += nonVoiced.utf8.count
                    } else {
                        let char = char.withOffset(offset)
                        offset += char.utf8Count
                        result.append(char)
                    }
                } else {
                    result.append(
                        TransliteratorChar(
                            value: lastNonIterationCharInfo.char, offset: offset, source: char
                        ))
                    offset += lastNonIterationCharInfo.char.utf8.count
                }
                prevCharInfo = CharInfo(currentChar, charType)
                continue
            case let .katakanaIterationMark(voiced):
                guard let prevCharInfo_ = prevCharInfo else {
                    break
                }
                switch prevCharInfo_.type {
                case .katakana(voiced: .none):
                    lastNonIterationCharInfo = CharInfo(prevCharInfo_.char, prevCharInfo_.type)
                case .katakana(voiced: .voiced):
                    guard let nonVoiced = Self.katakanaVoicedToNonvoiced[prevCharInfo_.char] else {
                        break outer
                    }
                    lastNonIterationCharInfo = CharInfo(nonVoiced, .katakana(voiced: .none))
                case .katakanaIterationMark:
                    break outer
                default:
                    break outer
                }
                guard let lastNonIterationCharInfo = lastNonIterationCharInfo else {
                    break outer
                }
                guard case .katakana = lastNonIterationCharInfo.type else {
                    break outer
                }
                if voiced == .voiced {
                    // Repeat previous katakana with voicing
                    if let nonVoiced = Self.katakanaNonvoicedToVoiced[lastNonIterationCharInfo.char] {
                        result.append(
                            TransliteratorChar(value: nonVoiced, offset: offset, source: char))
                        offset += nonVoiced.utf8.count
                    } else {
                        let char = char.withOffset(offset)
                        offset += char.utf8Count
                        result.append(char)
                    }
                } else {
                    result.append(
                        TransliteratorChar(
                            value: lastNonIterationCharInfo.char, offset: offset, source: char
                        ))
                    offset += lastNonIterationCharInfo.char.utf8.count
                }
                prevCharInfo = CharInfo(currentChar, charType)
                continue
            case .kanjiIterationMark:
                guard let prevCharInfo = prevCharInfo else {
                    break
                }
                switch prevCharInfo.type {
                case .kanji:
                    lastNonIterationCharInfo = CharInfo(prevCharInfo.char, prevCharInfo.type)
                case .kanjiIterationMark:
                    break
                default:
                    break outer
                }
                guard let lastNonIterationCharInfo = lastNonIterationCharInfo else {
                    break outer
                }
                result.append(
                    TransliteratorChar(
                        value: lastNonIterationCharInfo.char, offset: offset, source: char
                    ))
                offset += lastNonIterationCharInfo.char.utf8.count
                continue
            default:
                break
            }
            result.append(char.withOffset(offset))
            offset += currentChar.utf8.count
            prevCharInfo = CharInfo(currentChar, charType)
            lastNonIterationCharInfo = prevCharInfo
        }

        return result
    }

    private func getCharType(_ char: Character) -> CharType {
        switch char {
        case Self.hiraganaHatsuon, Self.hiraganaSokuon, Self.katakanaHatsuon, Self.katakanaSokuon:
            return .other
        case Self.hiraganaIterationMark, Self.verticalHiraganaIterationMark:
            return .hiraganaIterationMark(voiced: .none)
        case Self.hiraganaVoicedIterationMark, Self.verticalHiraganaVoicedIterationMark:
            return .hiraganaIterationMark(voiced: .voiced)
        case Self.katakanaIterationMark, Self.verticalKatakanaIterationMark:
            return .katakanaIterationMark(voiced: .none)
        case Self.katakanaVoicedIterationMark, Self.verticalKatakanaVoicedIterationMark:
            return .katakanaIterationMark(voiced: .voiced)
        case Self.kanjiIterationMark:
            return .kanjiIterationMark
        default:
            break
        }
        if Self.hiraganaSemiVoicedToNonvoiced.keys.contains(char) {
            return .hiragana(voiced: .semiVoiced)
        }
        if Self.katakanaSemiVoicedToNonvoiced.keys.contains(char) {
            return .katakana(voiced: .semiVoiced)
        }
        if Self.hiraganaVoicedToNonvoiced.keys.contains(char) {
            return .hiragana(voiced: .voiced)
        }
        if Self.katakanaVoicedToNonvoiced.keys.contains(char) {
            return .katakana(voiced: .voiced)
        }
        guard let codepoint = char.unicodeScalars.first?.value else {
            return .other
        }
        if char.unicodeScalars.count != 1 {
            return .other
        }
        // Hiragana (excluding special marks)
        if (0x3041 ... 0x3096).contains(codepoint) {
            return .hiragana(voiced: .none)
        }
        // Katakana (excluding halfwidth and special marks)
        if (0x30A1 ... 0x30FA).contains(codepoint) {
            return .katakana(voiced: .none)
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
}
