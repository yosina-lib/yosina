import Foundation

public struct HiraKataCompositionTransliterator: Transliterator {
    // Combining marks
    private static let combiningVoicedMark: UnicodeScalar = "\u{3099}" // Combining dakuten
    private static let combiningSemiVoicedMark: UnicodeScalar = "\u{309A}" // Combining handakuten

    // Non-combining marks
    private static let voicedMark: UnicodeScalar = "\u{309B}" // Dakuten
    private static let semiVoicedMark: UnicodeScalar = "\u{309C}" // Handakuten
    private static let halfwidthVoicedMark: UnicodeScalar = "\u{FF9E}" // Half-width dakuten
    private static let halfwidthSemiVoicedMark: UnicodeScalar = "\u{FF9F}" // Half-width handakuten

    public struct Options {
        public var composeNonCombiningMarks: Bool = true

        public init(composeNonCombiningMarks: Bool = true) {
            self.composeNonCombiningMarks = composeNonCombiningMarks
        }
    }

    private let options: Options
    private let markTables: [UnicodeScalar: [UnicodeScalar: Character]]

    // Composition tables (generated from shared table)
    private static let dakutenCompositions = HiraKataTable.generateVoicedCharacters()
    private static let handakutenCompositions = HiraKataTable.generateSemiVoicedCharacters()

    public init(options: Options = Options()) {
        self.options = options

        // Build mark tables based on options
        var tables: [UnicodeScalar: [UnicodeScalar: Character]] = [
            Self.combiningVoicedMark: Self.dakutenCompositions,
            Self.combiningSemiVoicedMark: Self.handakutenCompositions,
        ]

        if options.composeNonCombiningMarks {
            tables[Self.voicedMark] = Self.dakutenCompositions
            tables[Self.semiVoicedMark] = Self.handakutenCompositions
            tables[Self.halfwidthVoicedMark] = Self.dakutenCompositions
            tables[Self.halfwidthSemiVoicedMark] = Self.handakutenCompositions
        }

        markTables = tables
    }

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar]
        where S.Element == TransliteratorChar
    {
        var result: [TransliteratorChar] = []
        var previousChar: TransliteratorChar? = nil
        var offset = 0

        for char in chars {
            if let codepoints = char.value?.unicodeScalars, codepoints.count == 2,
               let table = markTables[
                   codepoints[codepoints.index(codepoints.startIndex, offsetBy: 1)]
               ],
               let composed = table[codepoints[codepoints.startIndex]]
            {
                // first flush the previousChar
                if let previousChar_ = previousChar {
                    // No composition, output the previous character
                    result.append(previousChar_.withOffset(offset))
                    offset += previousChar_.utf8Count
                    previousChar = nil
                }
                // Found a composition, output the composed character
                result.append(TransliteratorChar(value: composed, offset: offset, source: char))
                offset += composed.utf8.count
                continue
            }
            if let previousChar_ = previousChar?.value?.unicodeScalars.first,
               let char_ = char.value?.unicodeScalars.first,
               let table = markTables[char_], let composed = table[previousChar_]
            {
                // Found a composition, output the composed character
                result.append(TransliteratorChar(value: composed, offset: offset, source: char))
                offset += composed.utf8.count
                previousChar = nil
                continue
            }
            if let previousChar = previousChar {
                // No composition, output the previous character
                result.append(previousChar.withOffset(offset))
                offset += previousChar.utf8Count
            }
            previousChar = char
        }

        guard let previousChar = previousChar else {
            return result
        }

        if let codepoints = previousChar.value?.unicodeScalars, codepoints.count == 2,
           let table = markTables[
               codepoints[codepoints.index(codepoints.startIndex, offsetBy: 1)]
           ],
           let composed = table[codepoints[codepoints.startIndex]]
        {
            // Found a composition, output the composed character
            result.append(TransliteratorChar(value: composed, offset: offset, source: previousChar))
            offset += composed.utf8.count
        } else {
            result.append(previousChar.withOffset(offset))
            offset += previousChar.utf8Count
        }

        return result
    }
}
