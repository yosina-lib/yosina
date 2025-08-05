import Foundation

/// Shared hiragana-katakana mapping table
enum HiraKataTable {
    /// Structure to hold hiragana/katakana character forms
    struct HiraKata {
        let base: Character?
        let voiced: Character?
        let semivoiced: Character?

        init(_ base: String, _ voiced: String, _ semivoiced: String) {
            self.base = base.isEmpty ? nil : Character(base)
            self.voiced = voiced.isEmpty ? nil : Character(voiced)
            self.semivoiced = semivoiced.isEmpty ? nil : Character(semivoiced)
        }
    }

    /// Entry in the hiragana-katakana table
    struct HiraKataEntry {
        let hiragana: HiraKata?
        let katakana: HiraKata
        let halfwidth: Character?

        init(_ hiraganaData: [String]?, _ katakanaData: [String], _ halfwidthStr: String) {
            hiragana = hiraganaData.map { HiraKata($0[0], $0[1], $0[2]) }
            katakana = HiraKata(katakanaData[0], katakanaData[1], katakanaData[2])
            halfwidth = halfwidthStr.isEmpty ? nil : Character(halfwidthStr)
        }
    }

    /// Small kana entry
    struct SmallKanaEntry {
        let hiragana: Character
        let katakana: Character
        let halfwidth: Character?

        init(_ hiragana: String, _ katakana: String, _ halfwidth: String) {
            self.hiragana = Character(hiragana)
            self.katakana = Character(katakana)
            self.halfwidth = halfwidth.isEmpty ? nil : Character(halfwidth)
        }
    }

    /// Main hiragana-katakana table
    static let hiraganaKatakanaTable: [HiraKataEntry] = [
        // Vowels
        HiraKataEntry(["あ", "", ""], ["ア", "", ""], "ｱ"),
        HiraKataEntry(["い", "", ""], ["イ", "", ""], "ｲ"),
        HiraKataEntry(["う", "ゔ", ""], ["ウ", "ヴ", ""], "ｳ"),
        HiraKataEntry(["え", "", ""], ["エ", "", ""], "ｴ"),
        HiraKataEntry(["お", "", ""], ["オ", "", ""], "ｵ"),
        // K-row
        HiraKataEntry(["か", "が", ""], ["カ", "ガ", ""], "ｶ"),
        HiraKataEntry(["き", "ぎ", ""], ["キ", "ギ", ""], "ｷ"),
        HiraKataEntry(["く", "ぐ", ""], ["ク", "グ", ""], "ｸ"),
        HiraKataEntry(["け", "げ", ""], ["ケ", "ゲ", ""], "ｹ"),
        HiraKataEntry(["こ", "ご", ""], ["コ", "ゴ", ""], "ｺ"),
        // S-row
        HiraKataEntry(["さ", "ざ", ""], ["サ", "ザ", ""], "ｻ"),
        HiraKataEntry(["し", "じ", ""], ["シ", "ジ", ""], "ｼ"),
        HiraKataEntry(["す", "ず", ""], ["ス", "ズ", ""], "ｽ"),
        HiraKataEntry(["せ", "ぜ", ""], ["セ", "ゼ", ""], "ｾ"),
        HiraKataEntry(["そ", "ぞ", ""], ["ソ", "ゾ", ""], "ｿ"),
        // T-row
        HiraKataEntry(["た", "だ", ""], ["タ", "ダ", ""], "ﾀ"),
        HiraKataEntry(["ち", "ぢ", ""], ["チ", "ヂ", ""], "ﾁ"),
        HiraKataEntry(["つ", "づ", ""], ["ツ", "ヅ", ""], "ﾂ"),
        HiraKataEntry(["て", "で", ""], ["テ", "デ", ""], "ﾃ"),
        HiraKataEntry(["と", "ど", ""], ["ト", "ド", ""], "ﾄ"),
        // N-row
        HiraKataEntry(["な", "", ""], ["ナ", "", ""], "ﾅ"),
        HiraKataEntry(["に", "", ""], ["ニ", "", ""], "ﾆ"),
        HiraKataEntry(["ぬ", "", ""], ["ヌ", "", ""], "ﾇ"),
        HiraKataEntry(["ね", "", ""], ["ネ", "", ""], "ﾈ"),
        HiraKataEntry(["の", "", ""], ["ノ", "", ""], "ﾉ"),
        // H-row
        HiraKataEntry(["は", "ば", "ぱ"], ["ハ", "バ", "パ"], "ﾊ"),
        HiraKataEntry(["ひ", "び", "ぴ"], ["ヒ", "ビ", "ピ"], "ﾋ"),
        HiraKataEntry(["ふ", "ぶ", "ぷ"], ["フ", "ブ", "プ"], "ﾌ"),
        HiraKataEntry(["へ", "べ", "ぺ"], ["ヘ", "ベ", "ペ"], "ﾍ"),
        HiraKataEntry(["ほ", "ぼ", "ぽ"], ["ホ", "ボ", "ポ"], "ﾎ"),
        // M-row
        HiraKataEntry(["ま", "", ""], ["マ", "", ""], "ﾏ"),
        HiraKataEntry(["み", "", ""], ["ミ", "", ""], "ﾐ"),
        HiraKataEntry(["む", "", ""], ["ム", "", ""], "ﾑ"),
        HiraKataEntry(["め", "", ""], ["メ", "", ""], "ﾒ"),
        HiraKataEntry(["も", "", ""], ["モ", "", ""], "ﾓ"),
        // Y-row
        HiraKataEntry(["や", "", ""], ["ヤ", "", ""], "ﾔ"),
        HiraKataEntry(["ゆ", "", ""], ["ユ", "", ""], "ﾕ"),
        HiraKataEntry(["よ", "", ""], ["ヨ", "", ""], "ﾖ"),
        // R-row
        HiraKataEntry(["ら", "", ""], ["ラ", "", ""], "ﾗ"),
        HiraKataEntry(["り", "", ""], ["リ", "", ""], "ﾘ"),
        HiraKataEntry(["る", "", ""], ["ル", "", ""], "ﾙ"),
        HiraKataEntry(["れ", "", ""], ["レ", "", ""], "ﾚ"),
        HiraKataEntry(["ろ", "", ""], ["ロ", "", ""], "ﾛ"),
        // W-row
        HiraKataEntry(["わ", "", ""], ["ワ", "ヷ", ""], "ﾜ"),
        HiraKataEntry(["ゐ", "", ""], ["ヰ", "ヸ", ""], ""),
        HiraKataEntry(["ゑ", "", ""], ["ヱ", "ヹ", ""], ""),
        HiraKataEntry(["を", "", ""], ["ヲ", "ヺ", ""], "ｦ"),
        HiraKataEntry(["ん", "", ""], ["ン", "", ""], "ﾝ"),
    ]

    /// Small kana table
    static let hiraganaKatakanaSmallTable: [SmallKanaEntry] = [
        SmallKanaEntry("ぁ", "ァ", "ｧ"),
        SmallKanaEntry("ぃ", "ィ", "ｨ"),
        SmallKanaEntry("ぅ", "ゥ", "ｩ"),
        SmallKanaEntry("ぇ", "ェ", "ｪ"),
        SmallKanaEntry("ぉ", "ォ", "ｫ"),
        SmallKanaEntry("っ", "ッ", "ｯ"),
        SmallKanaEntry("ゃ", "ャ", "ｬ"),
        SmallKanaEntry("ゅ", "ュ", "ｭ"),
        SmallKanaEntry("ょ", "ョ", "ｮ"),
        SmallKanaEntry("ゎ", "ヮ", ""),
        SmallKanaEntry("ゕ", "ヵ", ""),
        SmallKanaEntry("ゖ", "ヶ", ""),
    ]

    /// Generate voiced characters table for HiraKataCompositionTransliterator
    static func generateVoicedCharacters() -> [UnicodeScalar: Character] {
        var result: [UnicodeScalar: Character] = [:]

        for entry in hiraganaKatakanaTable {
            // Add hiragana voiced mappings
            if let hiragana = entry.hiragana,
               let base = hiragana.base,
               let voiced = hiragana.voiced,
               let baseScalar = base.unicodeScalars.first
            {
                result[baseScalar] = voiced
            }

            // Add katakana voiced mappings
            if let base = entry.katakana.base,
               let voiced = entry.katakana.voiced,
               let baseScalar = base.unicodeScalars.first
            {
                result[baseScalar] = voiced
            }
        }

        // Add iteration marks
        result["\u{309D}"] = "\u{309E}" // ゝ -> ゞ
        result["\u{30FD}"] = "\u{30FE}" // ヽ -> ヾ
        result["\u{3031}"] = "\u{3032}" // 〱 -> 〲 (vertical hiragana)
        result["\u{3033}"] = "\u{3034}" // 〳 -> 〴 (vertical katakana)

        return result
    }

    /// Generate semi-voiced characters table for HiraKataCompositionTransliterator
    static func generateSemiVoicedCharacters() -> [UnicodeScalar: Character] {
        var result: [UnicodeScalar: Character] = [:]

        for entry in hiraganaKatakanaTable {
            // Add hiragana semi-voiced mappings
            if let hiragana = entry.hiragana,
               let base = hiragana.base,
               let semivoiced = hiragana.semivoiced,
               let baseScalar = base.unicodeScalars.first
            {
                result[baseScalar] = semivoiced
            }

            // Add katakana semi-voiced mappings
            if let base = entry.katakana.base,
               let semivoiced = entry.katakana.semivoiced,
               let baseScalar = base.unicodeScalars.first
            {
                result[baseScalar] = semivoiced
            }
        }

        return result
    }

    /// Generate GR table for JIS X 0201 (katakana fullwidth to halfwidth)
    static func generateGRTable() -> [Character: Character] {
        var result: [Character: Character] = [
            "。": "｡",
            "「": "｢",
            "」": "｣",
            "、": "､",
            "・": "･",
            "ー": "ｰ",
            "゛": "ﾞ",
            "゜": "ﾟ",
        ]

        // Add katakana mappings from main table
        for entry in hiraganaKatakanaTable {
            if let base = entry.katakana.base,
               let halfwidth = entry.halfwidth
            {
                result[base] = halfwidth
            }
        }

        // Add small kana mappings
        for entry in hiraganaKatakanaSmallTable {
            if let halfwidth = entry.halfwidth {
                result[entry.katakana] = halfwidth
            }
        }

        result["ヲ"] = "ｦ" // Special case

        return result
    }

    /// Generate voiced letters table for JIS X 0201
    static func generateVoicedLettersTable() -> [Character: String] {
        var result: [Character: String] = [:]

        for entry in hiraganaKatakanaTable {
            if let halfwidth = entry.halfwidth {
                let halfwidthStr = String(halfwidth)
                if let voiced = entry.katakana.voiced {
                    result[voiced] = halfwidthStr + "ﾞ"
                }
                if let semivoiced = entry.katakana.semivoiced {
                    result[semivoiced] = halfwidthStr + "ﾟ"
                }
            }
        }

        return result
    }

    /// Generate hiragana table for JIS X 0201
    static func generateHiraganaTable() -> [Character: String] {
        var result: [Character: String] = [:]

        // Add main table hiragana mappings
        for entry in hiraganaKatakanaTable {
            if let hiragana = entry.hiragana,
               let halfwidth = entry.halfwidth
            {
                let halfwidthStr = String(halfwidth)
                if let base = hiragana.base {
                    result[base] = halfwidthStr
                }
                if let voiced = hiragana.voiced {
                    result[voiced] = halfwidthStr + "ﾞ"
                }
                if let semivoiced = hiragana.semivoiced {
                    result[semivoiced] = halfwidthStr + "ﾟ"
                }
            }
        }

        // Add small kana mappings
        for entry in hiraganaKatakanaSmallTable {
            if let halfwidth = entry.halfwidth {
                result[entry.hiragana] = String(halfwidth)
            }
        }

        // Special case for ゔ
        result["ゔ"] = "ｳﾞ"

        return result
    }
}
