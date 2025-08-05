import Foundation

public class Jisx0201AndAlikeTransliterator: Transliterator {
    public struct Options {
        public var fullwidthToHalfwidth: Bool = true
        public var combineVoicedSoundMarks: Bool = true
        public var convertHiraganas: Bool = false
        public var convertGL: Bool = true // ASCII/Latin
        public var convertGR: Bool = true // Katakana
        public var convertUnsafeSpecials: Bool?
        public var u005cAsYenSign: Bool?
        public var u005cAsBackslash: Bool?
        public var u007eAsFullwidthTilde: Bool?
        public var u007eAsWaveDash: Bool?
        public var u007eAsOverline: Bool?
        public var u007eAsFullwidthMacron: Bool?
        public var u00a5AsYenSign: Bool?

        public init(
            fullwidthToHalfwidth: Bool = true,
            combineVoicedSoundMarks: Bool = true,
            convertHiraganas: Bool = false,
            convertGL: Bool = true,
            convertGR: Bool = true,
            convertUnsafeSpecials: Bool? = nil,
            u005cAsYenSign: Bool? = nil,
            u005cAsBackslash: Bool? = nil,
            u007eAsFullwidthTilde: Bool? = nil,
            u007eAsWaveDash: Bool? = nil,
            u007eAsOverline: Bool? = nil,
            u007eAsFullwidthMacron: Bool? = nil,
            u00a5AsYenSign: Bool? = nil
        ) {
            self.fullwidthToHalfwidth = fullwidthToHalfwidth
            self.combineVoicedSoundMarks = combineVoicedSoundMarks
            self.convertHiraganas = convertHiraganas
            self.convertGL = convertGL
            self.convertGR = convertGR
            self.convertUnsafeSpecials = convertUnsafeSpecials
            self.u005cAsYenSign = u005cAsYenSign
            self.u005cAsBackslash = u005cAsBackslash
            self.u007eAsFullwidthTilde = u007eAsFullwidthTilde
            self.u007eAsWaveDash = u007eAsWaveDash
            self.u007eAsOverline = u007eAsOverline
            self.u007eAsFullwidthMacron = u007eAsFullwidthMacron
            self.u00a5AsYenSign = u00a5AsYenSign
        }
    }

    private let fullwidthToHalfwidth: Bool
    private let options: ResolvedOptions

    private struct ResolvedOptions {
        let combineVoicedSoundMarks: Bool
        let convertHiraganas: Bool
        let convertGL: Bool
        let convertGR: Bool
        let convertUnsafeSpecials: Bool
        let u005cAsYenSign: Bool
        let u005cAsBackslash: Bool
        let u007eAsFullwidthTilde: Bool
        let u007eAsWaveDash: Bool
        let u007eAsOverline: Bool
        let u007eAsFullwidthMacron: Bool
        let u00a5AsYenSign: Bool
    }

    private static let glTable: [(Character, Character)] = [
        ("\u{3000}", "\u{0020}"), // Ideographic space to space
        ("\u{ff01}", "\u{0021}"), // ！ to !
        ("\u{ff02}", "\u{0022}"), // ＂ to "
        ("\u{ff03}", "\u{0023}"), // ＃ to #
        ("\u{ff04}", "\u{0024}"), // ＄ to $
        ("\u{ff05}", "\u{0025}"), // ％ to %
        ("\u{ff06}", "\u{0026}"), // ＆ to &
        ("\u{ff07}", "\u{0027}"), // ＇ to "
        ("\u{ff08}", "\u{0028}"), // （ to (
        ("\u{ff09}", "\u{0029}"), // ） to )
        ("\u{ff0a}", "\u{002a}"), // ＊ to *
        ("\u{ff0b}", "\u{002b}"), // ＋ to +
        ("\u{ff0c}", "\u{002c}"), // ， to ,
        ("\u{ff0d}", "\u{002d}"), // － to -
        ("\u{ff0e}", "\u{002e}"), // ． to .
        ("\u{ff0f}", "\u{002f}"), // ／ to /
        ("\u{ff1a}", "\u{003a}"), // ： to :
        ("\u{ff1b}", "\u{003b}"), // ； to ;
        ("\u{ff1c}", "\u{003c}"), // ＜ to <
        ("\u{ff1d}", "\u{003d}"), // ＝ to =
        ("\u{ff1e}", "\u{003e}"), // ＞ to >
        ("\u{ff1f}", "\u{003f}"), // ？ to ?
        ("\u{ff20}", "\u{0040}"), // ＠ to @
        ("\u{ff3b}", "\u{005b}"), // ［ to [
        ("\u{ff3d}", "\u{005d}"), // ］ to ]
        ("\u{ff3e}", "\u{005e}"), // ＾ to ^
        ("\u{ff3f}", "\u{005f}"), // ＿ to _
        ("\u{ff40}", "\u{0060}"), // ｀ to `
        ("\u{ff5b}", "\u{007b}"), // ｛ to {
        ("\u{ff5c}", "\u{007c}"), // ｜ to |
        ("\u{ff5d}", "\u{007d}"), // ｝ to }
    ]

    // Mapping tables (generated from shared table)
    private static let grTable = HiraKataTable.generateGRTable()

    // Hiragana to halfwidth katakana table (generated from shared table)
    private static let grHiraganaTable = HiraKataTable.generateHiraganaTable()

    private var fwdMappings: [Character: Character]?
    private var revMappings: [Character: Character]?

    // Voiced sound mark combinations (generated from shared table)
    private static let halfwidthVoicedCombinations = HiraKataTable.generateVoicedLettersTable()

    public init(options: Options = Options()) {
        fullwidthToHalfwidth = options.fullwidthToHalfwidth

        if options.fullwidthToHalfwidth {
            // Forward direction defaults
            let resolvedOptions = ResolvedOptions(
                combineVoicedSoundMarks: options.combineVoicedSoundMarks,
                convertHiraganas: options.convertHiraganas,
                convertGL: options.convertGL,
                convertGR: options.convertGR,
                convertUnsafeSpecials: options.convertUnsafeSpecials ?? true,
                u005cAsYenSign: options.u005cAsYenSign ?? (options.u00a5AsYenSign == nil),
                u005cAsBackslash: options.u005cAsBackslash ?? false,
                u007eAsFullwidthTilde: options.u007eAsFullwidthTilde ?? true,
                u007eAsWaveDash: options.u007eAsWaveDash ?? true,
                u007eAsOverline: options.u007eAsOverline ?? false,
                u007eAsFullwidthMacron: options.u007eAsFullwidthMacron ?? false,
                u00a5AsYenSign: options.u00a5AsYenSign ?? false
            )
            // Validate mutually exclusive options
            if resolvedOptions.u005cAsYenSign, resolvedOptions.u00a5AsYenSign {
                fatalError("u005cAsYenSign and u00a5AsYenSign are mutually exclusive")
            }
            self.options = resolvedOptions
        } else {
            // Reverse direction defaults
            let resolvedOptions = ResolvedOptions(
                combineVoicedSoundMarks: options.combineVoicedSoundMarks,
                convertHiraganas: options.convertHiraganas,
                convertGL: options.convertGL,
                convertGR: options.convertGR,
                convertUnsafeSpecials: options.convertUnsafeSpecials ?? false,
                u005cAsYenSign: options.u005cAsYenSign ?? (options.u005cAsBackslash == nil),
                u005cAsBackslash: options.u005cAsBackslash ?? false,
                u007eAsFullwidthTilde: options.u007eAsFullwidthTilde ??
                    (options.u007eAsWaveDash == nil && options.u007eAsOverline == nil && options.u007eAsFullwidthMacron == nil),
                u007eAsWaveDash: options.u007eAsWaveDash ?? false,
                u007eAsOverline: options.u007eAsOverline ?? false,
                u007eAsFullwidthMacron: options.u007eAsFullwidthMacron ?? false,
                u00a5AsYenSign: options.u00a5AsYenSign ?? true
            )
            // Validate mutually exclusive options for reverse direction
            if resolvedOptions.u005cAsYenSign && resolvedOptions.u005cAsBackslash {
                fatalError("u005cAsYenSign and u005cAsBackslash are mutually exclusive")
            }
            if resolvedOptions.u007eAsFullwidthTilde &&
                (resolvedOptions.u007eAsWaveDash || resolvedOptions.u007eAsOverline || resolvedOptions.u007eAsFullwidthMacron) ||
                resolvedOptions.u007eAsWaveDash &&
                (resolvedOptions.u007eAsOverline || resolvedOptions.u007eAsFullwidthMacron) ||
                resolvedOptions.u007eAsOverline && resolvedOptions.u007eAsFullwidthMacron
            {
                fatalError("u007eAsFullwidthTilde, u007eAsWaveDash, u007eAsOverline, and u007eAsFullwidthMacron are mutually exclusive")
            }
            self.options = resolvedOptions
        }
    }

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar {
        if fullwidthToHalfwidth {
            return transliterateFullwidthToHalfwidth(chars)
        } else {
            return transliterateHalfwidthToFullwidth(chars)
        }
    }

    private func transliterateFullwidthToHalfwidth<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar {
        let mappings = buildFwdMappings()
        var result: [TransliteratorChar] = []
        let charsArray = Array(chars)
        var offset = 0

        for char in charsArray {
            // Convert fullwidth to halfwidth
            if let charValue = char.value, let converted = mappings[charValue] {
                result.append(TransliteratorChar(value: converted, offset: offset, source: char))
                offset += converted.utf8.count
            } else {
                result.append(char.withOffset(offset))
                offset += char.utf8Count
            }
        }

        return result
    }

    private func transliterateHalfwidthToFullwidth<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar {
        let mappings = buildRevMappings()
        var result: [TransliteratorChar] = []
        let charsArray = Array(chars)
        var offset = 0

        for char in charsArray {
            if let charValue = char.value, let converted = mappings[charValue] {
                result.append(TransliteratorChar(value: converted, offset: offset, source: char))
                offset += converted.utf8.count
            } else {
                result.append(char.withOffset(offset))
                offset += char.utf8Count
            }
        }

        return result
    }

    private func buildFwdMappings() -> [Character: Character] {
        if let fwdMappings = fwdMappings {
            return fwdMappings
        }
        var fwdMappings = [Character: Character]()
        if options.convertGL {
            for (fullwidth, halfwidth) in Self.glTable {
                fwdMappings[fullwidth] = halfwidth
            }
            if options.u005cAsYenSign {
                fwdMappings["\u{FFE5}"] = "\\" // ￥ to \
            } else if options.u00a5AsYenSign {
                fwdMappings["\u{FFE5}"] = "\u{00A5}" // ￥ to ¥
            }
            if options.u005cAsBackslash {
                fwdMappings["\u{FF3C}"] = "\\" // ＼ to \
            }
            if options.u007eAsFullwidthTilde {
                fwdMappings["\u{FF5E}"] = "~" // ～ to ~
            }
            if options.u007eAsWaveDash {
                fwdMappings["\u{301C}"] = "~" // 〜 to ~
            }
            if options.u007eAsOverline {
                fwdMappings["\u{203E}"] = "~" // ‾ to ~
            }
            if options.u007eAsFullwidthMacron {
                fwdMappings["\u{FFE3}"] = "~" // ￣ to ~
            }
            if options.convertUnsafeSpecials {
                fwdMappings["\u{30A0}"] = "\u{003D}" // ゠ to =
            }
            for fullwidth in 0xFF10 ... 0xFF19 {
                guard let fullwidth = UnicodeScalar(fullwidth),
                      let halfwidth = UnicodeScalar(fullwidth.value - 0xFEE0)
                else {
                    fatalError("UnicodeScalar() failed; should never happen")
                }
                fwdMappings[Character(fullwidth)] = Character(halfwidth)
            }
            // Uppercase alphabets
            for fullwidth in 0xFF21 ... 0xFF3A {
                guard let fullwidth = UnicodeScalar(fullwidth),
                      let halfwidth = UnicodeScalar(fullwidth.value - 0xFEE0)
                else {
                    fatalError("UnicodeScalar() failed; should never happen")
                }
                fwdMappings[Character(fullwidth)] = Character(halfwidth)
            }
            // Lowercase alphabets
            for fullwidth in 0xFF41 ... 0xFF5A {
                guard let fullwidth = UnicodeScalar(fullwidth),
                      let halfwidth = UnicodeScalar(fullwidth.value - 0xFEE0)
                else {
                    fatalError("UnicodeScalar() failed; should never happen")
                }
                fwdMappings[Character(fullwidth)] = Character(halfwidth)
            }
        }
        if options.convertGR {
            for (fullwidth, halfwidth) in Self.grTable {
                fwdMappings[fullwidth] = halfwidth
            }
            for (fullwidth, halfwidth) in Self.halfwidthVoicedCombinations {
                fwdMappings[fullwidth] = Character(halfwidth)
            }
            if options.convertHiraganas {
                for (fullwidth, halfwidth) in Self.grHiraganaTable {
                    fwdMappings[fullwidth] = Character(halfwidth)
                }
            }
        }
        self.fwdMappings = fwdMappings
        return fwdMappings
    }

    private func buildRevMappings() -> [Character: Character] {
        if let revMappings = revMappings {
            return revMappings
        }
        var revMappings = [Character: Character]()
        if options.convertGL {
            for (fullwidth, halfwidth) in Self.glTable {
                revMappings[halfwidth] = fullwidth
            }
            if options.u00a5AsYenSign {
                revMappings["\u{00A5}"] = "\u{FFE5}" // ¥ to ￥
            }
            if options.u005cAsBackslash {
                revMappings["\\"] = "\u{FF3C}" // \ to ＼
            } else if options.u005cAsYenSign {
                revMappings["\\"] = "\u{FFE5}" // \ to ￥
            }
            if options.u007eAsFullwidthTilde {
                revMappings["~"] = "\u{FF5E}" // ~ to ～
            } else if options.u007eAsWaveDash {
                revMappings["~"] = "\u{301C}" // ~ to 〜
            } else if options.u007eAsOverline {
                revMappings["~"] = "\u{203E}" // ~ to ‾
            } else if options.u007eAsFullwidthMacron {
                revMappings["~"] = "\u{FFE3}" // ~ to ￣
            }
            if options.convertUnsafeSpecials {
                revMappings["\u{003D}"] = "\u{30A0}" // ゠ to =
            }
            for fullwidth in 0xFF10 ... 0xFF19 {
                guard let fullwidth = UnicodeScalar(fullwidth),
                      let halfwidth = UnicodeScalar(fullwidth.value - 0xFEE0)
                else {
                    fatalError("UnicodeScalar() failed; should never happen")
                }
                revMappings[Character(halfwidth)] = Character(fullwidth)
            }
            // Uppercase alphabets
            for fullwidth in 0xFF21 ... 0xFF3A {
                guard let fullwidth = UnicodeScalar(fullwidth),
                      let halfwidth = UnicodeScalar(fullwidth.value - 0xFEE0)
                else {
                    fatalError("UnicodeScalar() failed; should never happen")
                }
                revMappings[Character(halfwidth)] = Character(fullwidth)
            }
            // Lowercase alphabets
            for fullwidth in 0xFF41 ... 0xFF5A {
                guard let fullwidth = UnicodeScalar(fullwidth),
                      let halfwidth = UnicodeScalar(fullwidth.value - 0xFEE0)
                else {
                    fatalError("UnicodeScalar() failed; should never happen")
                }
                revMappings[Character(halfwidth)] = Character(fullwidth)
            }
        }
        if options.convertGR {
            for (fullwidth, halfwidth) in Self.grTable {
                revMappings[halfwidth] = fullwidth
            }
            if options.combineVoicedSoundMarks {
                for (fullwidth, halfwidth) in Self.halfwidthVoicedCombinations {
                    revMappings[Character(halfwidth)] = fullwidth
                }
            }
        }
        self.revMappings = revMappings
        return revMappings
    }
}
