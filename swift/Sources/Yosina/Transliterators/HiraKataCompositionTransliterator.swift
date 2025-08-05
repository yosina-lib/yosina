import Foundation

public struct HiraKataCompositionTransliterator: Transliterator {
    // Combining marks
    private static let combiningVoicedMark: Character = "\u{3099}" // Combining dakuten
    private static let combiningSemiVoicedMark: Character = "\u{309A}" // Combining handakuten

    // Non-combining marks
    private static let voicedMark: Character = "\u{309B}" // Dakuten
    private static let semiVoicedMark: Character = "\u{309C}" // Handakuten
    private static let halfwidthVoicedMark: Character = "\u{FF9E}" // Half-width dakuten
    private static let halfwidthSemiVoicedMark: Character = "\u{FF9F}" // Half-width handakuten

    public struct Options {
        public var composeNonCombiningMarks: Bool = true

        public init(composeNonCombiningMarks: Bool = true) {
            self.composeNonCombiningMarks = composeNonCombiningMarks
        }
    }

    private let options: Options
    private let markTables: [Character: [UInt32: String]]

    // Composition tables
    private static let dakutenCompositions: [UInt32: String] = [
        // Hiragana with dakuten
        0x304B: "\u{304C}", // か → が
        0x304D: "\u{304E}", // き → ぎ
        0x304F: "\u{3050}", // く → ぐ
        0x3051: "\u{3052}", // け → げ
        0x3053: "\u{3054}", // こ → ご
        0x3055: "\u{3056}", // さ → ざ
        0x3057: "\u{3058}", // し → じ
        0x3059: "\u{305A}", // す → ず
        0x305B: "\u{305C}", // せ → ぜ
        0x305D: "\u{305E}", // そ → ぞ
        0x305F: "\u{3060}", // た → だ
        0x3061: "\u{3062}", // ち → ぢ
        0x3064: "\u{3065}", // つ → づ
        0x3066: "\u{3067}", // て → で
        0x3068: "\u{3069}", // と → ど
        0x306F: "\u{3070}", // は → ば
        0x3072: "\u{3073}", // ひ → び
        0x3075: "\u{3076}", // ふ → ぶ
        0x3078: "\u{3079}", // へ → べ
        0x307B: "\u{307C}", // ほ → ぼ
        0x3046: "\u{3094}", // う → ゔ
        0x309D: "\u{309E}", // ゝ → ゞ

        // Katakana with dakuten
        0x30AB: "\u{30AC}", // カ → ガ
        0x30AD: "\u{30AE}", // キ → ギ
        0x30AF: "\u{30B0}", // ク → グ
        0x30B1: "\u{30B2}", // ケ → ゲ
        0x30B3: "\u{30B4}", // コ → ゴ
        0x30B5: "\u{30B6}", // サ → ザ
        0x30B7: "\u{30B8}", // シ → ジ
        0x30B9: "\u{30BA}", // ス → ズ
        0x30BB: "\u{30BC}", // セ → ゼ
        0x30BD: "\u{30BE}", // ソ → ゾ
        0x30BF: "\u{30C0}", // タ → ダ
        0x30C1: "\u{30C2}", // チ → ヂ
        0x30C4: "\u{30C5}", // ツ → ヅ
        0x30C6: "\u{30C7}", // テ → デ
        0x30C8: "\u{30C9}", // ト → ド
        0x30CF: "\u{30D0}", // ハ → バ
        0x30D2: "\u{30D3}", // ヒ → ビ
        0x30D5: "\u{30D6}", // フ → ブ
        0x30D8: "\u{30D9}", // ヘ → ベ
        0x30DB: "\u{30DC}", // ホ → ボ
        0x30A6: "\u{30F4}", // ウ → ヴ
        0x30EF: "\u{30F7}", // ワ → ヷ
        0x30F0: "\u{30F8}", // ヰ → ヸ
        0x30F1: "\u{30F9}", // ヱ → ヹ
        0x30F2: "\u{30FA}", // ヲ → ヺ
        0x30FD: "\u{30FE}", // ヽ → ヾ

        // Halfwidth katakana with dakuten
        0xFF76: "ガ", // ｶ → ガ
        0xFF77: "ギ", // ｷ → ギ
        0xFF78: "グ", // ｸ → グ
        0xFF79: "ゲ", // ｹ → ゲ
        0xFF7A: "ゴ", // ｺ → ゴ
        0xFF7B: "ザ", // ｻ → ザ
        0xFF7C: "ジ", // ｼ → ジ
        0xFF7D: "ズ", // ｽ → ズ
        0xFF7E: "ゼ", // ｾ → ゼ
        0xFF7F: "ゾ", // ｿ → ゾ
        0xFF80: "ダ", // ﾀ → ダ
        0xFF81: "ヂ", // ﾁ → ヂ
        0xFF82: "ヅ", // ﾂ → ヅ
        0xFF83: "デ", // ﾃ → デ
        0xFF84: "ド", // ﾄ → ド
        0xFF8A: "バ", // ﾊ → バ
        0xFF8B: "ビ", // ﾋ → ビ
        0xFF8C: "ブ", // ﾌ → ブ
        0xFF8D: "ベ", // ﾍ → ベ
        0xFF8E: "ボ", // ﾎ → ボ
    ]

    private static let handakutenCompositions: [UInt32: String] = [
        // Hiragana with handakuten
        0x306F: "\u{3071}", // は → ぱ
        0x3072: "\u{3074}", // ひ → ぴ
        0x3075: "\u{3077}", // ふ → ぷ
        0x3078: "\u{307A}", // へ → ぺ
        0x307B: "\u{307D}", // ほ → ぽ

        // Katakana with handakuten
        0x30CF: "\u{30D1}", // ハ → パ
        0x30D2: "\u{30D4}", // ヒ → ピ
        0x30D5: "\u{30D7}", // フ → プ
        0x30D8: "\u{30DA}", // ヘ → ペ
        0x30DB: "\u{30DD}", // ホ → ポ

        // Halfwidth katakana with handakuten
        0xFF8A: "パ", // ﾊ → パ
        0xFF8B: "ピ", // ﾋ → ピ
        0xFF8C: "プ", // ﾌ → プ
        0xFF8D: "ペ", // ﾍ → ペ
        0xFF8E: "ポ", // ﾎ → ポ
    ]

    public init(options: Options = Options()) {
        self.options = options

        // Build mark tables based on options
        var tables: [Character: [UInt32: String]] = [
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

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar {
        var result: [TransliteratorChar] = []
        var previousChar: TransliteratorChar? = nil
        var offset = 0

        for char in chars {
            if let pc = previousChar {
                // Check if current char is a mark that can compose with the previous char
                if let composed = tryCompose(base: pc.value, mark: char.value) {
                    // Found a composition, output the composed character
                    result.append(TransliteratorChar(value: composed, offset: offset, source: pc))
                    offset += composed.count
                    previousChar = nil
                    continue
                }
                // Not a composition, output the previous char
                result.append(TransliteratorChar(value: pc.value, offset: offset, source: pc))
                offset += pc.value.count
            }
            // Store current char as previous for next iteration
            previousChar = char
        }

        // Output any remaining character
        if let pc = previousChar {
            result.append(TransliteratorChar(value: pc.value, offset: offset, source: pc))
            offset += pc.value.count
        }

        return result
    }

    private func tryCompose(base: String, mark: String) -> String? {
        guard let baseScalar = base.unicodeScalars.first,
              let markChar = mark.first,
              let table = markTables[markChar] else { return nil }

        return table[baseScalar.value]
    }
}
