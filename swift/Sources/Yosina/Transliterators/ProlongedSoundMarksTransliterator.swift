import Foundation

public struct ProlongedSoundMarksTransliterator: Transliterator {
    public struct Options {
        public var skipAlreadyTransliteratedChars: Bool
        public var allowProlongedHatsuon: Bool
        public var allowProlongedSokuon: Bool
        public var replaceProlongedMarksFollowingAlnums: Bool

        public init(
            skipAlreadyTransliteratedChars: Bool = false,
            allowProlongedHatsuon: Bool = false,
            allowProlongedSokuon: Bool = false,
            replaceProlongedMarksFollowingAlnums: Bool = false
        ) {
            self.skipAlreadyTransliteratedChars = skipAlreadyTransliteratedChars
            self.allowProlongedHatsuon = allowProlongedHatsuon
            self.allowProlongedSokuon = allowProlongedSokuon
            self.replaceProlongedMarksFollowingAlnums = replaceProlongedMarksFollowingAlnums
        }
    }

    private struct CharType: OptionSet {
        let rawValue: UInt8

        static let other = CharType([])
        static let hiragana = CharType(rawValue: 0x20)
        static let katakana = CharType(rawValue: 0x40)
        static let alphabet = CharType(rawValue: 0x60)
        static let digit = CharType(rawValue: 0x80)
        static let either = CharType(rawValue: 0xA0)

        static let halfwidth = CharType(rawValue: 1 << 0)
        static let vowelEnded = CharType(rawValue: 1 << 1)
        static let hatsuon = CharType(rawValue: 1 << 2)
        static let sokuon = CharType(rawValue: 1 << 3)
        static let prolongedSoundMark = CharType(rawValue: 1 << 4)

        // Compound types
        static let halfwidthDigit: CharType = [.digit, .halfwidth]
        static let fullwidthDigit: CharType = .digit
        static let halfwidthAlphabet: CharType = [.alphabet, .halfwidth]
        static let fullwidthAlphabet: CharType = .alphabet
        static let ordinaryHiragana: CharType = [.hiragana, .vowelEnded]
        static let ordinaryKatakana: CharType = [.katakana, .vowelEnded]
        static let ordinaryHalfwidthKatakana: CharType = [.katakana, .vowelEnded, .halfwidth]

        func isAlnum() -> Bool {
            let masked = rawValue & 0xE0
            return masked == CharType.alphabet.rawValue || masked == CharType.digit.rawValue
        }

        func isHalfwidth() -> Bool {
            return (rawValue & CharType.halfwidth.rawValue) != 0
        }
    }

    private let options: Options
    private let prolongables: CharType

    public init(options: Options = Options()) {
        self.options = options

        var prolongables: CharType = [.vowelEnded, .prolongedSoundMark]
        if options.allowProlongedHatsuon {
            prolongables.insert(.hatsuon)
        }
        if options.allowProlongedSokuon {
            prolongables.insert(.sokuon)
        }
        self.prolongables = prolongables
    }

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar {
        var result: [TransliteratorChar] = []
        var lookaheadBuf: [TransliteratorChar] = []
        var lastNonProlongedChar: (TransliteratorChar, CharType)? = nil
        var processedCharsInLookahead = false
        var offset = 0

        for char in chars {
            // Handle lookahead buffer - when we've accumulated potential prolonged marks
            if !lookaheadBuf.isEmpty {
                if let value = char.value, Self.isProlongedMark(String(value)) {
                    // Continue accumulating prolonged marks
                    if char.source != nil {
                        processedCharsInLookahead = true
                    }
                    lookaheadBuf.append(char)
                } else {
                    // Process the accumulated lookahead buffer
                    let prevNonProlongedChar = lastNonProlongedChar
                    let currentCharType = char.value.map { getCharType(String($0)) } ?? .other
                    lastNonProlongedChar = (char, currentCharType)

                    if (prevNonProlongedChar == nil || prevNonProlongedChar!.1.isAlnum()) &&
                        (!options.skipAlreadyTransliteratedChars || !processedCharsInLookahead)
                    {
                        let replacement = prevNonProlongedChar?.1.isHalfwidth() ?? currentCharType.isHalfwidth() ? "\u{002D}" : "\u{FF0D}"

                        // Replace all marks in lookahead buffer with the chosen replacement
                        for lookaheadChar in lookaheadBuf {
                            result.append(TransliteratorChar(value: Character(replacement), offset: offset, source: lookaheadChar))
                            offset += replacement.utf8.count
                        }
                    } else {
                        // Not between alphanumeric characters - preserve original
                        for lookaheadChar in lookaheadBuf {
                            if let value = lookaheadChar.value {
                                result.append(TransliteratorChar(value: value, offset: offset, source: lookaheadChar.source))
                                offset += lookaheadChar.utf8Count
                            }
                        }
                    }
                    lookaheadBuf.removeAll()
                    result.append(char)
                    processedCharsInLookahead = false
                }
                continue
            }

            // Check if current character is a prolonged mark
            if let value = char.value, Self.isProlongedMark(String(value)) {
                // Check if we should process this prolonged mark
                let shouldProcess = !options.skipAlreadyTransliteratedChars || char.source == nil
                if shouldProcess {
                    if let (_, lastCharType) = lastNonProlongedChar {
                        // Check if character is suitable for prolonged sound mark replacement
                        if !prolongables.intersection([lastCharType]).isEmpty {
                            // Japanese character that can be prolonged
                            let replacement = lastCharType.isHalfwidth() ? "\u{FF70}" : "\u{30FC}"
                            result.append(TransliteratorChar(value: Character(replacement), offset: offset, source: char))
                            offset += replacement.utf8.count
                            continue
                        } else {
                            // Not a Japanese character
                            if options.replaceProlongedMarksFollowingAlnums && lastCharType.isAlnum() {
                                lookaheadBuf.append(char)
                                continue
                            }
                        }
                    }
                }
            } else {
                // Regular character - update last non-prolonged character
                if let value = char.value {
                    let charType = getCharType(String(value))
                    lastNonProlongedChar = (char, charType)
                }
            }

            // Default: preserve the original character
            result.append(char.withOffset(offset))
            offset += char.utf8Count
        }

        return result
    }

    private static func isProlongedMark(_ str: String) -> Bool {
        switch str {
        case "\u{002D}", // HYPHEN-MINUS
             "\u{2010}", // HYPHEN
             "\u{2014}", // EM DASH
             "\u{2015}", // HORIZONTAL BAR
             "\u{2212}", // MINUS SIGN
             "\u{FF0D}", // FULLWIDTH HYPHEN-MINUS
             "\u{FF70}", // HALFWIDTH KATAKANA PROLONGED SOUND MARK
             "\u{30FC}": // KATAKANA PROLONGED SOUND MARK
            return true
        default:
            return false
        }
    }

    private static func getSpecialCharType(_ codepoint: UInt32) -> CharType? {
        switch codepoint {
        case 0xFF70:
            return [.katakana, .prolongedSoundMark, .halfwidth]
        case 0x30FC:
            return [.either, .prolongedSoundMark]
        case 0x3063:
            return [.hiragana, .sokuon]
        case 0x3093:
            return [.hiragana, .hatsuon]
        case 0x30C3:
            return [.katakana, .sokuon]
        case 0x30F3:
            return [.katakana, .hatsuon]
        case 0xFF6F:
            return [.katakana, .sokuon, .halfwidth]
        case 0xFF9D:
            return [.katakana, .hatsuon, .halfwidth]
        default:
            return nil
        }
    }

    private func getCharType(_ char: String) -> CharType {
        guard let scalar = char.unicodeScalars.first else { return .other }
        let codepoint = scalar.value

        // Check digits
        if (0x30 ... 0x39).contains(codepoint) {
            return .halfwidthDigit
        }
        if (0xFF10 ... 0xFF19).contains(codepoint) {
            return .fullwidthDigit
        }

        // Check alphabet
        if (0x41 ... 0x5A).contains(codepoint) || (0x61 ... 0x7A).contains(codepoint) {
            return .halfwidthAlphabet
        }
        if (0xFF21 ... 0xFF3A).contains(codepoint) || (0xFF41 ... 0xFF5A).contains(codepoint) {
            return .fullwidthAlphabet
        }

        // Check special characters
        if let specialType = Self.getSpecialCharType(codepoint) {
            return specialType
        }

        // Check hiragana
        if (0x3041 ... 0x309C).contains(codepoint) || codepoint == 0x309F {
            return .ordinaryHiragana
        }

        // Check katakana
        if (0x30A1 ... 0x30FA).contains(codepoint) || (0x30FD ... 0x30FF).contains(codepoint) {
            return .ordinaryKatakana
        }

        // Check halfwidth katakana
        if (0xFF66 ... 0xFF6F).contains(codepoint) || (0xFF71 ... 0xFF9F).contains(codepoint) {
            return .ordinaryHalfwidthKatakana
        }

        return .other
    }
}
