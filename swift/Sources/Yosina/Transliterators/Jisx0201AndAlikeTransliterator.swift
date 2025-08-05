import Foundation

public struct Jisx0201AndAlikeTransliterator: Transliterator {
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

    private let options: Options
    private let resolvedOptions: ResolvedOptions

    private struct ResolvedOptions {
        let fullwidthToHalfwidth: Bool
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

    // Mapping tables
    private static let fullwidthToHalfwidthTable: [UInt32: String] = [
        // Fullwidth punctuation marks
        0x3002: "\u{ff61}", // 。 to ｡
        0x300C: "\u{ff62}", // 「 to ｢
        0x300D: "\u{ff63}", // 」 to ｣
        0x3001: "\u{ff64}", // 、 to ､
        0x30FB: "\u{ff65}", // ・ to ･
        0x30FC: "\u{ff70}", // ー to ｰ
        0x309B: "\u{ff9e}", // ゛ to ﾞ
        0x309C: "\u{ff9f}", // ゜ to ﾟ
        0x3099: "\u{ff9e}", // combining dakuten
        0x309A: "\u{ff9f}", // combining handakuten

        // Small katakana
        0x30A1: "\u{ff67}", // ァ to ｧ
        0x30A3: "\u{ff68}", // ィ to ｨ
        0x30A5: "\u{ff69}", // ゥ to ｩ
        0x30A7: "\u{ff6a}", // ェ to ｪ
        0x30A9: "\u{ff6b}", // ォ to ｫ
        0x30E3: "\u{ff6c}", // ャ to ｬ
        0x30E5: "\u{ff6d}", // ュ to ｭ
        0x30E7: "\u{ff6e}", // ョ to ｮ
        0x30C3: "\u{ff6f}", // ッ to ｯ

        // Vowels
        0x30A2: "\u{ff71}", // ア to ｱ
        0x30A4: "\u{ff72}", // イ to ｲ
        0x30A6: "\u{ff73}", // ウ to ｳ
        0x30A8: "\u{ff74}", // エ to ｴ
        0x30AA: "\u{ff75}", // オ to ｵ

        // K-row
        0x30AB: "\u{ff76}", // カ to ｶ
        0x30AD: "\u{ff77}", // キ to ｷ
        0x30AF: "\u{ff78}", // ク to ｸ
        0x30B1: "\u{ff79}", // ケ to ｹ
        0x30B3: "\u{ff7a}", // コ to ｺ

        // G-row (voiced K)
        0x30AC: "\u{ff76}\u{ff9e}", // ガ to ｶﾞ
        0x30AE: "\u{ff77}\u{ff9e}", // ギ to ｷﾞ
        0x30B0: "\u{ff78}\u{ff9e}", // グ to ｸﾞ
        0x30B2: "\u{ff79}\u{ff9e}", // ゲ to ｹﾞ
        0x30B4: "\u{ff7a}\u{ff9e}", // ゴ to ｺﾞ

        // S-row
        0x30B5: "\u{ff7b}", // サ to ｻ
        0x30B7: "\u{ff7c}", // シ to ｼ
        0x30B9: "\u{ff7d}", // ス to ｽ
        0x30BB: "\u{ff7e}", // セ to ｾ
        0x30BD: "\u{ff7f}", // ソ to ｿ

        // Z-row (voiced S)
        0x30B6: "\u{ff7b}\u{ff9e}", // ザ to ｻﾞ
        0x30B8: "\u{ff7c}\u{ff9e}", // ジ to ｼﾞ
        0x30BA: "\u{ff7d}\u{ff9e}", // ズ to ｽﾞ
        0x30BC: "\u{ff7e}\u{ff9e}", // ゼ to ｾﾞ
        0x30BE: "\u{ff7f}\u{ff9e}", // ゾ to ｿﾞ

        // T-row
        0x30BF: "\u{ff80}", // タ to ﾀ
        0x30C1: "\u{ff81}", // チ to ﾁ
        0x30C4: "\u{ff82}", // ツ to ﾂ
        0x30C6: "\u{ff83}", // テ to ﾃ
        0x30C8: "\u{ff84}", // ト to ﾄ

        // D-row (voiced T)
        0x30C0: "\u{ff80}\u{ff9e}", // ダ to ﾀﾞ
        0x30C2: "\u{ff81}\u{ff9e}", // ヂ to ﾁﾞ
        0x30C5: "\u{ff82}\u{ff9e}", // ヅ to ﾂﾞ
        0x30C7: "\u{ff83}\u{ff9e}", // デ to ﾃﾞ
        0x30C9: "\u{ff84}\u{ff9e}", // ド to ﾄﾞ

        // N-row
        0x30CA: "\u{ff85}", // ナ to ﾅ
        0x30CB: "\u{ff86}", // ニ to ﾆ
        0x30CC: "\u{ff87}", // ヌ to ﾇ
        0x30CD: "\u{ff88}", // ネ to ﾈ
        0x30CE: "\u{ff89}", // ノ to ﾉ

        // H-row
        0x30CF: "\u{ff8a}", // ハ to ﾊ
        0x30D2: "\u{ff8b}", // ヒ to ﾋ
        0x30D5: "\u{ff8c}", // フ to ﾌ
        0x30D8: "\u{ff8d}", // ヘ to ﾍ
        0x30DB: "\u{ff8e}", // ホ to ﾎ

        // B-row (voiced H)
        0x30D0: "\u{ff8a}\u{ff9e}", // バ to ﾊﾞ
        0x30D3: "\u{ff8b}\u{ff9e}", // ビ to ﾋﾞ
        0x30D6: "\u{ff8c}\u{ff9e}", // ブ to ﾌﾞ
        0x30D9: "\u{ff8d}\u{ff9e}", // ベ to ﾍﾞ
        0x30DC: "\u{ff8e}\u{ff9e}", // ボ to ﾎﾞ

        // P-row (half-voiced H)
        0x30D1: "\u{ff8a}\u{ff9f}", // パ to ﾊﾟ
        0x30D4: "\u{ff8b}\u{ff9f}", // ピ to ﾋﾟ
        0x30D7: "\u{ff8c}\u{ff9f}", // プ to ﾌﾟ
        0x30DA: "\u{ff8d}\u{ff9f}", // ペ to ﾍﾟ
        0x30DD: "\u{ff8e}\u{ff9f}", // ポ to ﾎﾟ

        // M-row
        0x30DE: "\u{ff8f}", // マ to ﾏ
        0x30DF: "\u{ff90}", // ミ to ﾐ
        0x30E0: "\u{ff91}", // ム to ﾑ
        0x30E1: "\u{ff92}", // メ to ﾒ
        0x30E2: "\u{ff93}", // モ to ﾓ

        // Y-row
        0x30E4: "\u{ff94}", // ヤ to ﾔ
        0x30E6: "\u{ff95}", // ユ to ﾕ
        0x30E8: "\u{ff96}", // ヨ to ﾖ

        // R-row
        0x30E9: "\u{ff97}", // ラ to ﾗ
        0x30EA: "\u{ff98}", // リ to ﾘ
        0x30EB: "\u{ff99}", // ル to ﾙ
        0x30EC: "\u{ff9a}", // レ to ﾚ
        0x30ED: "\u{ff9b}", // ロ to ﾛ

        // W-row
        0x30EF: "\u{ff9c}", // ワ to ﾜ
        0x30F3: "\u{ff9d}", // ン to ﾝ
        0x30F2: "\u{ff66}", // ヲ to ｦ

        // Special
        0x30F4: "\u{ff73}\u{ff9e}", // ヴ to ｳﾞ
        0x30FA: "\u{ff66}\u{ff9e}", // ヺ to ｦﾞ

        // Small special
        0x30F5: "\u{ff76}", // ヵ to ｶ (small)
        0x30F6: "\u{ff79}", // ヶ to ｹ (small)

        // Obsolete
        0x30F0: "\u{ff72}", // ヰ to ｲ
        0x30F1: "\u{ff74}", // ヱ to ｴ
        0x30EE: "\u{ff9c}", // ヮ to ﾜ (small)

        // Fullwidth space
        0x3000: " ",

        // Special punctuation
        0x30A0: "=", // ゠ to = (convertUnsafeSpecials only)
    ]

    // Hiragana to halfwidth katakana table
    private static let hiraganaToHalfwidthTable: [UInt32: String] = [
        // Small hiragana
        0x3041: "\u{ff67}", // ぁ to ｧ
        0x3043: "\u{ff68}", // ぃ to ｨ
        0x3045: "\u{ff69}", // ぅ to ｩ
        0x3047: "\u{ff6a}", // ぇ to ｪ
        0x3049: "\u{ff6b}", // ぉ to ｫ
        0x3083: "\u{ff6c}", // ゃ to ｬ
        0x3085: "\u{ff6d}", // ゅ to ｭ
        0x3087: "\u{ff6e}", // ょ to ｮ
        0x3063: "\u{ff6f}", // っ to ｯ

        // Vowels
        0x3042: "\u{ff71}", // あ to ｱ
        0x3044: "\u{ff72}", // い to ｲ
        0x3046: "\u{ff73}", // う to ｳ
        0x3048: "\u{ff74}", // え to ｴ
        0x304A: "\u{ff75}", // お to ｵ

        // K-row
        0x304B: "\u{ff76}", // か to ｶ
        0x304D: "\u{ff77}", // き to ｷ
        0x304F: "\u{ff78}", // く to ｸ
        0x3051: "\u{ff79}", // け to ｹ
        0x3053: "\u{ff7a}", // こ to ｺ

        // G-row (voiced K)
        0x304C: "\u{ff76}\u{ff9e}", // が to ｶﾞ
        0x304E: "\u{ff77}\u{ff9e}", // ぎ to ｷﾞ
        0x3050: "\u{ff78}\u{ff9e}", // ぐ to ｸﾞ
        0x3052: "\u{ff79}\u{ff9e}", // げ to ｹﾞ
        0x3054: "\u{ff7a}\u{ff9e}", // ご to ｺﾞ

        // S-row
        0x3055: "\u{ff7b}", // さ to ｻ
        0x3057: "\u{ff7c}", // し to ｼ
        0x3059: "\u{ff7d}", // す to ｽ
        0x305B: "\u{ff7e}", // せ to ｾ
        0x305D: "\u{ff7f}", // そ to ｿ

        // Z-row (voiced S)
        0x3056: "\u{ff7b}\u{ff9e}", // ざ to ｻﾞ
        0x3058: "\u{ff7c}\u{ff9e}", // じ to ｼﾞ
        0x305A: "\u{ff7d}\u{ff9e}", // ず to ｽﾞ
        0x305C: "\u{ff7e}\u{ff9e}", // ぜ to ｾﾞ
        0x305E: "\u{ff7f}\u{ff9e}", // ぞ to ｿﾞ

        // T-row
        0x305F: "\u{ff80}", // た to ﾀ
        0x3061: "\u{ff81}", // ち to ﾁ
        0x3064: "\u{ff82}", // つ to ﾂ
        0x3066: "\u{ff83}", // て to ﾃ
        0x3068: "\u{ff84}", // と to ﾄ

        // D-row (voiced T)
        0x3060: "\u{ff80}\u{ff9e}", // だ to ﾀﾞ
        0x3062: "\u{ff81}\u{ff9e}", // ぢ to ﾁﾞ
        0x3065: "\u{ff82}\u{ff9e}", // づ to ﾂﾞ
        0x3067: "\u{ff83}\u{ff9e}", // で to ﾃﾞ
        0x3069: "\u{ff84}\u{ff9e}", // ど to ﾄﾞ

        // N-row
        0x306A: "\u{ff85}", // な to ﾅ
        0x306B: "\u{ff86}", // に to ﾆ
        0x306C: "\u{ff87}", // ぬ to ﾇ
        0x306D: "\u{ff88}", // ね to ﾈ
        0x306E: "\u{ff89}", // の to ﾉ

        // H-row
        0x306F: "\u{ff8a}", // は to ﾊ
        0x3072: "\u{ff8b}", // ひ to ﾋ
        0x3075: "\u{ff8c}", // ふ to ﾌ
        0x3078: "\u{ff8d}", // へ to ﾍ
        0x307B: "\u{ff8e}", // ほ to ﾎ

        // B-row (voiced H)
        0x3070: "\u{ff8a}\u{ff9e}", // ば to ﾊﾞ
        0x3073: "\u{ff8b}\u{ff9e}", // び to ﾋﾞ
        0x3076: "\u{ff8c}\u{ff9e}", // ぶ to ﾌﾞ
        0x3079: "\u{ff8d}\u{ff9e}", // べ to ﾍﾞ
        0x307C: "\u{ff8e}\u{ff9e}", // ぼ to ﾎﾞ

        // P-row (half-voiced H)
        0x3071: "\u{ff8a}\u{ff9f}", // ぱ to ﾊﾟ
        0x3074: "\u{ff8b}\u{ff9f}", // ぴ to ﾋﾟ
        0x3077: "\u{ff8c}\u{ff9f}", // ぷ to ﾌﾟ
        0x307A: "\u{ff8d}\u{ff9f}", // ぺ to ﾍﾟ
        0x307D: "\u{ff8e}\u{ff9f}", // ぽ to ﾎﾟ

        // M-row
        0x307E: "\u{ff8f}", // ま to ﾏ
        0x307F: "\u{ff90}", // み to ﾐ
        0x3080: "\u{ff91}", // む to ﾑ
        0x3081: "\u{ff92}", // め to ﾒ
        0x3082: "\u{ff93}", // も to ﾓ

        // Y-row
        0x3084: "\u{ff94}", // や to ﾔ
        0x3086: "\u{ff95}", // ゆ to ﾕ
        0x3088: "\u{ff96}", // よ to ﾖ

        // R-row
        0x3089: "\u{ff97}", // ら to ﾗ
        0x308A: "\u{ff98}", // り to ﾘ
        0x308B: "\u{ff99}", // る to ﾙ
        0x308C: "\u{ff9a}", // れ to ﾚ
        0x308D: "\u{ff9b}", // ろ to ﾛ

        // W-row
        0x308F: "\u{ff9c}", // わ to ﾜ
        0x3093: "\u{ff9d}", // ん to ﾝ
        0x3092: "\u{ff66}", // を to ｦ

        // Special
        0x3094: "\u{ff73}\u{ff9e}", // ゔ to ｳﾞ
    ]

    // Halfwidth to fullwidth table
    private static let halfwidthToFullwidthTable: [UInt32: String] = [
        // Punctuation marks
        0xFF61: "\u{3002}", // ｡ to 。
        0xFF62: "\u{300c}", // ｢ to 「
        0xFF63: "\u{300d}", // ｣ to 」
        0xFF64: "\u{3001}", // ､ to 、
        0xFF65: "\u{30fb}", // ･ to ・
        0xFF70: "\u{30fc}", // ｰ to ー
        0xFF9E: "\u{309b}", // ﾞ to ゛
        0xFF9F: "\u{309c}", // ﾟ to ゜

        // Small katakana
        0xFF67: "\u{30a1}", // ｧ to ァ
        0xFF68: "\u{30a3}", // ｨ to ィ
        0xFF69: "\u{30a5}", // ｩ to ゥ
        0xFF6A: "\u{30a7}", // ｪ to ェ
        0xFF6B: "\u{30a9}", // ｫ to ォ
        0xFF6C: "\u{30e3}", // ｬ to ャ
        0xFF6D: "\u{30e5}", // ｭ to ュ
        0xFF6E: "\u{30e7}", // ｮ to ョ
        0xFF6F: "\u{30c3}", // ｯ to ッ

        // Wo
        0xFF66: "\u{30f2}", // ｦ to ヲ

        // Vowels
        0xFF71: "\u{30a2}", // ｱ to ア
        0xFF72: "\u{30a4}", // ｲ to イ
        0xFF73: "\u{30a6}", // ｳ to ウ
        0xFF74: "\u{30a8}", // ｴ to エ
        0xFF75: "\u{30aa}", // ｵ to オ

        // K-row
        0xFF76: "\u{30ab}", // ｶ to カ
        0xFF77: "\u{30ad}", // ｷ to キ
        0xFF78: "\u{30af}", // ｸ to ク
        0xFF79: "\u{30b1}", // ｹ to ケ
        0xFF7A: "\u{30b3}", // ｺ to コ

        // S-row
        0xFF7B: "\u{30b5}", // ｻ to サ
        0xFF7C: "\u{30b7}", // ｼ to シ
        0xFF7D: "\u{30b9}", // ｽ to ス
        0xFF7E: "\u{30bb}", // ｾ to セ
        0xFF7F: "\u{30bd}", // ｿ to ソ

        // T-row
        0xFF80: "\u{30bf}", // ﾀ to タ
        0xFF81: "\u{30c1}", // ﾁ to チ
        0xFF82: "\u{30c4}", // ﾂ to ツ
        0xFF83: "\u{30c6}", // ﾃ to テ
        0xFF84: "\u{30c8}", // ﾄ to ト

        // N-row
        0xFF85: "\u{30ca}", // ﾅ to ナ
        0xFF86: "\u{30cb}", // ﾆ to ニ
        0xFF87: "\u{30cc}", // ﾇ to ヌ
        0xFF88: "\u{30cd}", // ﾈ to ネ
        0xFF89: "\u{30ce}", // ﾉ to ノ

        // H-row
        0xFF8A: "\u{30cf}", // ﾊ to ハ
        0xFF8B: "\u{30d2}", // ﾋ to ヒ
        0xFF8C: "\u{30d5}", // ﾌ to フ
        0xFF8D: "\u{30d8}", // ﾍ to ヘ
        0xFF8E: "\u{30db}", // ﾎ to ホ

        // M-row
        0xFF8F: "\u{30de}", // ﾏ to マ
        0xFF90: "\u{30df}", // ﾐ to ミ
        0xFF91: "\u{30e0}", // ﾑ to ム
        0xFF92: "\u{30e1}", // ﾒ to メ
        0xFF93: "\u{30e2}", // ﾓ to モ

        // Y-row
        0xFF94: "\u{30e4}", // ﾔ to ヤ
        0xFF95: "\u{30e6}", // ﾕ to ユ
        0xFF96: "\u{30e8}", // ﾖ to ヨ

        // R-row
        0xFF97: "\u{30e9}", // ﾗ to ラ
        0xFF98: "\u{30ea}", // ﾘ to リ
        0xFF99: "\u{30eb}", // ﾙ to ル
        0xFF9A: "\u{30ec}", // ﾚ to レ
        0xFF9B: "\u{30ed}", // ﾛ to ロ

        // W-row
        0xFF9C: "\u{30ef}", // ﾜ to ワ
        0xFF9D: "\u{30f3}", // ﾝ to ン

        // Halfwidth space
        0x0020: "\u{3000}",

        // Special punctuation (convertUnsafeSpecials only)
        0x003D: "\u{30a0}", // = to ゠
    ]

    // Voiced sound mark combinations
    private static let halfwidthVoicedCombinations: [UInt32: String] = [
        // Voiced combinations (with ﾞ)
        0xFF66: "\u{30fa}", // ｦﾞ to ヺ
        0xFF73: "\u{30f4}", // ｳﾞ to ヴ
        0xFF76: "\u{30ac}", // ｶﾞ to ガ
        0xFF77: "\u{30ae}", // ｷﾞ to ギ
        0xFF78: "\u{30b0}", // ｸﾞ to グ
        0xFF79: "\u{30b2}", // ｹﾞ to ゲ
        0xFF7A: "\u{30b4}", // ｺﾞ to ゴ
        0xFF7B: "\u{30b6}", // ｻﾞ to ザ
        0xFF7C: "\u{30b8}", // ｼﾞ to ジ
        0xFF7D: "\u{30ba}", // ｽﾞ to ズ
        0xFF7E: "\u{30bc}", // ｾﾞ to ゼ
        0xFF7F: "\u{30be}", // ｿﾞ to ゾ
        0xFF80: "\u{30c0}", // ﾀﾞ to ダ
        0xFF81: "\u{30c2}", // ﾁﾞ to ヂ
        0xFF82: "\u{30c5}", // ﾂﾞ to ヅ
        0xFF83: "\u{30c7}", // ﾃﾞ to デ
        0xFF84: "\u{30c9}", // ﾄﾞ to ド
        0xFF8A: "\u{30d0}", // ﾊﾞ to バ
        0xFF8B: "\u{30d3}", // ﾋﾞ to ビ
        0xFF8C: "\u{30d6}", // ﾌﾞ to ブ
        0xFF8D: "\u{30d9}", // ﾍﾞ to ベ
        0xFF8E: "\u{30dc}", // ﾎﾞ to ボ
    ]

    // Semi-voiced sound mark combinations
    private static let halfwidthSemiVoicedCombinations: [UInt32: String] = [
        0xFF8A: "\u{30d1}", // ﾊﾟ to パ
        0xFF8B: "\u{30d4}", // ﾋﾟ to ピ
        0xFF8C: "\u{30d7}", // ﾌﾟ to プ
        0xFF8D: "\u{30da}", // ﾍﾟ to ペ
        0xFF8E: "\u{30dd}", // ﾎﾟ to ポ
    ]

    public init(options: Options = Options()) {
        self.options = options

        // Resolve options with proper defaults based on direction
        let fullwidthToHalfwidth = options.fullwidthToHalfwidth

        if fullwidthToHalfwidth {
            // Forward direction defaults
            resolvedOptions = ResolvedOptions(
                fullwidthToHalfwidth: fullwidthToHalfwidth,
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
        } else {
            // Reverse direction defaults
            resolvedOptions = ResolvedOptions(
                fullwidthToHalfwidth: fullwidthToHalfwidth,
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
        }
    }

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar {
        var result: [TransliteratorChar] = []
        let charsArray = Array(chars)
        var i = 0
        var offset = 0

        while i < charsArray.count {
            let char = charsArray[i]

            if resolvedOptions.fullwidthToHalfwidth {
                // Convert fullwidth to halfwidth
                if let converted = convertFullwidthToHalfwidth(char, nextChar: i + 1 < charsArray.count ? charsArray[i + 1] : nil) {
                    if converted.consumedNext {
                        i += 1
                    }
                    result.append(TransliteratorChar(value: converted.value, offset: offset, source: char))
                    offset += converted.value.count
                } else {
                    result.append(TransliteratorChar(value: char.value, offset: offset, source: char))
                    offset += char.value.count
                }
            } else {
                // Convert halfwidth to fullwidth
                if let converted = convertHalfwidthToFullwidth(char, nextChar: i + 1 < charsArray.count ? charsArray[i + 1] : nil) {
                    if converted.consumedNext {
                        i += 1
                    }
                    result.append(TransliteratorChar(value: converted.value, offset: offset, source: char))
                    offset += converted.value.count
                } else {
                    result.append(TransliteratorChar(value: char.value, offset: offset, source: char))
                    offset += char.value.count
                }
            }

            i += 1
        }

        return result
    }

    private func convertFullwidthToHalfwidth(_ char: TransliteratorChar, nextChar _: TransliteratorChar?) -> (value: String, consumedNext: Bool)? {
        guard let scalar = char.value.unicodeScalars.first, char.value.unicodeScalars.count == 1 else { return nil }
        let value = scalar.value

        // Handle special overrides first
        if resolvedOptions.convertGL {
            if let specialResult = handleFullwidthSpecialOverrides(value) {
                return (specialResult, false)
            }

            // Basic fullwidth ASCII to halfwidth
            if (0xFF01 ... 0xFF5E).contains(value) {
                if let halfwidth = UnicodeScalar(value - 0xFF01 + 0x0021) {
                    return (String(halfwidth), false)
                }
            }
        }

        // Check fullwidth to halfwidth table
        if resolvedOptions.convertGR {
            if let replacement = Self.fullwidthToHalfwidthTable[value] {
                // Check special unsafe specials condition
                if value == 0x30A0, !resolvedOptions.convertUnsafeSpecials {
                    return nil
                }
                return (replacement, false)
            }
        }

        // Check hiragana to halfwidth katakana
        if resolvedOptions.convertHiraganas, resolvedOptions.convertGR {
            if let replacement = Self.hiraganaToHalfwidthTable[value] {
                return (replacement, false)
            }
        }

        return nil
    }

    private func convertHalfwidthToFullwidth(_ char: TransliteratorChar, nextChar: TransliteratorChar?) -> (value: String, consumedNext: Bool)? {
        guard let scalar = char.value.unicodeScalars.first, char.value.unicodeScalars.count == 1 else { return nil }
        let value = scalar.value

        // Handle special overrides first
        if resolvedOptions.convertGL {
            if let specialResult = handleHalfwidthSpecialOverrides(value) {
                return (specialResult, false)
            }

            // Basic halfwidth ASCII to fullwidth
            if (0x0021 ... 0x007E).contains(value) {
                if let fullwidth = UnicodeScalar(value - 0x0021 + 0xFF01) {
                    return (String(fullwidth), false)
                }
            }
        }

        // Check if next character is a voice mark
        if resolvedOptions.convertGR, resolvedOptions.combineVoicedSoundMarks {
            if let next = nextChar, let nextScalar = next.value.unicodeScalars.first {
                let hasVoiceMark = nextScalar.value == 0xFF9E
                let hasSemiVoiceMark = nextScalar.value == 0xFF9F

                if hasVoiceMark, let combined = Self.halfwidthVoicedCombinations[value] {
                    return (combined, true)
                }

                if hasSemiVoiceMark, let combined = Self.halfwidthSemiVoicedCombinations[value] {
                    return (combined, true)
                }
            }
        }

        // Check halfwidth to fullwidth table
        if resolvedOptions.convertGR {
            if let replacement = Self.halfwidthToFullwidthTable[value] {
                // Check special unsafe specials condition
                if value == 0x003D, !resolvedOptions.convertUnsafeSpecials {
                    return nil
                }
                // Handle non-combining voice marks
                if value == 0xFF9E {
                    return ("\u{3099}", false) // Convert to combining mark
                }
                if value == 0xFF9F {
                    return ("\u{309a}", false) // Convert to combining mark
                }
                return (replacement, false)
            }
        }

        return nil
    }

    private func handleFullwidthSpecialOverrides(_ value: UInt32) -> String? {
        switch value {
        case 0xFF3C where resolvedOptions.u005cAsBackslash:
            return "\\" // ＼ to \
        case 0xFFE5 where resolvedOptions.u005cAsYenSign:
            return "\\" // ￥ to \
        case 0xFFE5 where resolvedOptions.u00a5AsYenSign:
            return "¥" // ￥ to ¥
        case 0xFF5E where resolvedOptions.u007eAsFullwidthTilde:
            return "~" // ～ to ~
        case 0x301C where resolvedOptions.u007eAsWaveDash:
            return "~" // 〜 to ~
        case 0x203E where resolvedOptions.u007eAsOverline:
            return "~" // ‾ to ~
        case 0xFFE3 where resolvedOptions.u007eAsFullwidthMacron:
            return "~" // ￣ to ~
        default:
            return nil
        }
    }

    private func handleHalfwidthSpecialOverrides(_ value: UInt32) -> String? {
        switch value {
        case 0x005C where resolvedOptions.u005cAsYenSign:
            return "\u{ffe5}" // \ to ￥
        case 0x005C where resolvedOptions.u005cAsBackslash:
            return "\u{ff3c}" // \ to ＼
        case 0x007E where resolvedOptions.u007eAsFullwidthTilde:
            return "\u{ff5e}" // ~ to ～
        case 0x007E where resolvedOptions.u007eAsWaveDash:
            return "\u{301c}" // ~ to 〜
        case 0x007E where resolvedOptions.u007eAsOverline:
            return "\u{203e}" // ~ to ‾
        case 0x007E where resolvedOptions.u007eAsFullwidthMacron:
            return "\u{ffe3}" // ~ to ￣
        case 0x00A5 where resolvedOptions.u00a5AsYenSign:
            return "\u{ffe5}" // ¥ to ￥
        default:
            return nil
        }
    }
}
