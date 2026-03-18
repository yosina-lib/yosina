import Foundation

// MARK: - Option Types

/// Options for full-width conversion.
public struct ToFullwidthOptions {
    public let enabled: Bool
    public let u005cAsYenSign: Bool

    public static let disabled = ToFullwidthOptions(enabled: false, u005cAsYenSign: false)
    public static let enabled = ToFullwidthOptions(enabled: true, u005cAsYenSign: false)
    public static let u005cAsYenSign = ToFullwidthOptions(enabled: true, u005cAsYenSign: true)

    public var isEnabled: Bool { enabled }
    public var isU005cAsYenSign: Bool { u005cAsYenSign }

    public init(enabled: Bool, u005cAsYenSign: Bool) {
        self.enabled = enabled
        self.u005cAsYenSign = u005cAsYenSign
    }

    public static func from(_ enabled: Bool) -> ToFullwidthOptions {
        enabled ? .enabled : .disabled
    }
}

/// Options for half-width conversion.
public struct ToHalfwidthOptions {
    public let enabled: Bool
    public let hankakuKana: Bool

    public static let disabled = ToHalfwidthOptions(enabled: false, hankakuKana: false)
    public static let enabled = ToHalfwidthOptions(enabled: true, hankakuKana: false)
    public static let hankakuKana = ToHalfwidthOptions(enabled: true, hankakuKana: true)

    public var isEnabled: Bool { enabled }
    public var isHankakuKana: Bool { hankakuKana }

    public init(enabled: Bool, hankakuKana: Bool) {
        self.enabled = enabled
        self.hankakuKana = hankakuKana
    }

    public static func from(_ enabled: Bool) -> ToHalfwidthOptions {
        enabled ? .enabled : .disabled
    }
}

/// Options for IVS/SVS removal.
public struct RemoveIvsSvsOptions {
    public let enabled: Bool
    public let dropAllSelectors: Bool

    public static let disabled = RemoveIvsSvsOptions(enabled: false, dropAllSelectors: false)
    public static let enabled = RemoveIvsSvsOptions(enabled: true, dropAllSelectors: false)
    public static let dropAllSelectors = RemoveIvsSvsOptions(enabled: true, dropAllSelectors: true)

    public var isEnabled: Bool { enabled }
    public var isDropAllSelectors: Bool { dropAllSelectors }

    public init(enabled: Bool, dropAllSelectors: Bool) {
        self.enabled = enabled
        self.dropAllSelectors = dropAllSelectors
    }

    public static func from(_ enabled: Bool) -> RemoveIvsSvsOptions {
        enabled ? .enabled : .disabled
    }
}

/// Options for hyphens replacement.
public struct ReplaceHyphensOptions {
    public let enabled: Bool
    public let precedence: [HyphensTransliterator.Precedence]?

    public static let disabled = ReplaceHyphensOptions(enabled: false, precedence: nil)
    public static let enabled = ReplaceHyphensOptions(
        enabled: true,
        precedence: [.jisx0208_90_windows, .jisx0201]
    )

    public var isEnabled: Bool { enabled }

    public init(enabled: Bool, precedence: [HyphensTransliterator.Precedence]?) {
        self.enabled = enabled
        self.precedence = precedence
    }

    public static func withPrecedence(_ precedence: [HyphensTransliterator.Precedence]) -> ReplaceHyphensOptions {
        ReplaceHyphensOptions(enabled: true, precedence: precedence)
    }

    public static func from(_ enabled: Bool) -> ReplaceHyphensOptions {
        enabled ? .enabled : .disabled
    }
}

/// Options for circled or squared characters replacement.
public struct ReplaceCircledOrSquaredCharactersOptions {
    public let enabled: Bool
    public let includeEmojis: Bool

    public static let disabled = ReplaceCircledOrSquaredCharactersOptions(enabled: false, includeEmojis: false)
    public static let enabled = ReplaceCircledOrSquaredCharactersOptions(enabled: true, includeEmojis: true)
    public static let excludeEmojis = ReplaceCircledOrSquaredCharactersOptions(enabled: true, includeEmojis: false)

    public var isEnabled: Bool { enabled }

    public init(enabled: Bool, includeEmojis: Bool) {
        self.enabled = enabled
        self.includeEmojis = includeEmojis
    }

    public static func from(_ enabled: Bool) -> ReplaceCircledOrSquaredCharactersOptions {
        enabled ? .enabled : .disabled
    }
}

/// Mode for converting historical hiragana and katakana characters at the recipe level.
public enum ConvertHistoricalHirakatasMode {
    /// Replace with the modern single-character equivalent.
    /// Hiraganas and katakanas use `.simple`, voiced katakanas are skipped.
    case simple
    /// Decompose into multiple modern characters.
    /// All categories (hiraganas, katakanas, voiced katakanas) use `.decompose`.
    case decompose
}

// MARK: - TransliterationRecipe

/// Configuration recipe for building transliterator chains.
///
/// This struct provides a declarative way to configure complex transliterator chains
/// using high-level options that are automatically converted to the appropriate
/// transliterator configurations.
public struct TransliterationRecipe: TransliteratorFactory {
    /// Replace codepoints that correspond to old-style kanji glyphs (旧字体; kyu-ji-tai)
    /// with their modern equivalents (新字体; shin-ji-tai).
    ///
    /// Example:
    /// Input:  "舊字體の變換"
    /// Output: "旧字体の変換"
    public var kanjiOldNew: Bool = false

    /// Convert between hiragana and katakana scripts.
    ///
    /// Example:
    /// Input:  "ひらがな" (with "hira-to-kata")
    /// Output: "ヒラガナ"
    /// Input:  "カタカナ" (with "kata-to-hira")
    /// Output: "かたかな"
    public var hiraKata: HiraKataTransliterator.Mode?

    /// Replace Japanese iteration marks with the characters they represent.
    ///
    /// Example:
    /// Input:  "時々"
    /// Output: "時時"
    /// Input:  "いすゞ"
    /// Output: "いすず"
    public var replaceJapaneseIterationMarks: Bool = false

    /// Replace "suspicious" hyphens with prolonged sound marks, and vice versa.
    ///
    /// Example:
    /// Input:  "スーパ-" (with hyphen-minus)
    /// Output: "スーパー" (becomes prolonged sound mark)
    public var replaceSuspiciousHyphensToProlongedSoundMarks: Bool = false

    /// Replace combined characters with their corresponding characters.
    ///
    /// Example:
    /// Input:  "㍻" (single character for Heisei era)
    /// Output: "平成"
    /// Input:  "㈱"
    /// Output: "(株)"
    public var replaceCombinedCharacters: Bool = false

    /// Replace circled or squared characters with their corresponding templates.
    ///
    /// Example:
    /// Input:  "①②③"
    /// Output: "(1)(2)(3)"
    /// Input:  "㊙㊗"
    /// Output: "(秘)(祝)"
    public var replaceCircledOrSquaredCharacters: ReplaceCircledOrSquaredCharactersOptions = .disabled

    /// Replace ideographic annotations used in the traditional method of
    /// Chinese-to-Japanese translation devised in ancient Japan.
    ///
    /// Example:
    /// Input:  "㆖㆘" (ideographic annotations)
    /// Output: "上下"
    public var replaceIdeographicAnnotations: Bool = false

    /// Replace codepoints for the Kang Xi radicals whose glyphs resemble those of
    /// CJK ideographs with the CJK ideograph counterparts.
    ///
    /// Example:
    /// Input:  "⾔⾨⾷" (Kangxi radicals)
    /// Output: "言門食" (CJK ideographs)
    public var replaceRadicals: Bool = false

    /// Replace various space characters with plain whitespaces or empty strings.
    ///
    /// Example:
    /// Input:  "A　B" (ideographic space U+3000)
    /// Output: "A B" (half-width space)
    /// Input:  "A B" (non-breaking space U+00A0)
    /// Output: "A B" (regular space)
    public var replaceSpaces: Bool = false

    /// Replace various dash or hyphen symbols with those common in Japanese writing.
    ///
    /// Example:
    /// Input:  "2019—2020" (em dash)
    /// Output: "2019-2020" (hyphen-minus)
    /// Input:  "A–B" (en dash)
    /// Output: "A-B"
    public var replaceHyphens: ReplaceHyphensOptions = .disabled

    /// Replace mathematical alphanumerics with their plain ASCII equivalents.
    ///
    /// Example:
    /// Input:  "𝐀𝐁𝐂" (mathematical bold)
    /// Output: "ABC"
    /// Input:  "𝟏𝟐𝟑" (mathematical bold digits)
    /// Output: "123"
    public var replaceMathematicalAlphanumerics: Bool = false

    /// Replace Roman numeral characters with their ASCII letter equivalents.
    ///
    /// Example:
    /// Input:  "ⅠⅡⅢ" (Roman numerals)
    /// Output: "III"
    /// Input:  "ⅸⅹ" (lowercase Roman numerals)
    /// Output: "ixx"
    public var replaceRomanNumerals: Bool = false

    /// Replace archaic kana (hentaigana) with their modern equivalents.
    ///
    /// Example:
    /// Input:  "𛀁"
    /// Output: "え"
    public var replaceArchaicHirakatas: Bool = false

    /// Replace small hiragana/katakana with their ordinary-sized equivalents.
    ///
    /// Example:
    /// Input:  "ァィゥ"
    /// Output: "アイウ"
    public var replaceSmallHirakatas: Bool = false

    /// Combine decomposed hiraganas and katakanas into single counterparts.
    ///
    /// Example:
    /// Input:  "が" (か + ゙)
    /// Output: "が" (single character)
    /// Input:  "ヘ゜" (ヘ + ゜)
    /// Output: "ペ" (single character)
    public var combineDecomposedHiraganasAndKatakanas: Bool = false

    /// Replace half-width characters to fullwidth equivalents.
    ///
    /// Example:
    /// Input:  "ABC123"
    /// Output: "ＡＢＣ１２３"
    /// Input:  "ｶﾀｶﾅ"
    /// Output: "カタカナ"
    public var toFullwidth: ToFullwidthOptions = .disabled

    /// Replace full-width characters with their half-width equivalents.
    ///
    /// Example:
    /// Input:  "ＡＢＣ１２３"
    /// Output: "ABC123"
    /// Input:  "カタカナ" (with hankaku-kana)
    /// Output: "ｶﾀｶﾅ"
    public var toHalfwidth: ToHalfwidthOptions = .disabled

    /// Replace CJK ideographs followed by IVSes and SVSes with those without selectors
    /// based on Adobe-Japan1 character mappings.
    ///
    /// Example:
    /// Input:  "葛󠄀" (葛 + IVS U+E0100)
    /// Output: "葛" (without selector)
    /// Input:  "辻󠄀" (辻 + IVS)
    /// Output: "辻"
    public var removeIvsSvs: RemoveIvsSvsOptions = .disabled

    /// Convert historical hiragana and katakana characters to their modern equivalents.
    ///
    /// Example:
    /// Input:  "ゐ" (historical hiragana wi)
    /// Output: "い" (modern hiragana i, with simple mode)
    /// Output: "うぃ" (decomposed, with decompose mode)
    public var convertHistoricalHirakatas: ConvertHistoricalHirakatasMode?

    /// Character set for IVS/SVS operations.
    public var charset: IvsSvsBaseTransliterator.Charset = .unijis2004

    /// Build transliterator configurations from this recipe.
    ///
    /// Returns a TransliteratorConfig that can be passed to Yosina.makeTransliterator.
    ///
    /// Throws an error if the recipe contains mutually exclusive options.
    public func buildTransliteratorConfig() throws -> [TransliteratorConfig] {
        // Check for mutually exclusive options
        var errors: [String] = []
        if toFullwidth.isEnabled, toHalfwidth.isEnabled {
            errors.append("toFullwidth and toHalfwidth are mutually exclusive")
        }

        if !errors.isEmpty {
            throw TransliterationRecipeError.mutuallyExclusiveOptions(errors.joined(separator: "; "))
        }

        let builder = TransliteratorConfigListBuilder()

        // Apply transformations in the specified order
        applyKanjiOldNew(to: builder)
        applyReplaceSuspiciousHyphensToProlongedSoundMarks(to: builder)
        applyReplaceCircledOrSquaredCharacters(to: builder)
        applyReplaceCombinedCharacters(to: builder)
        applyReplaceIdeographicAnnotations(to: builder)
        applyReplaceRadicals(to: builder)
        applyReplaceSpaces(to: builder)
        applyReplaceHyphens(to: builder)
        applyReplaceMathematicalAlphanumerics(to: builder)
        applyReplaceRomanNumerals(to: builder)
        applyReplaceArchaicHirakatas(to: builder)
        applyReplaceSmallHirakatas(to: builder)
        applyConvertHistoricalHirakatas(to: builder)
        applyCombineDecomposedHiraganasAndKatakanas(to: builder)
        applyToFullwidth(to: builder)
        applyHiraKata(to: builder)
        applyReplaceJapaneseIterationMarks(to: builder)
        applyToHalfwidth(to: builder)
        applyRemoveIvsSvs(to: builder)

        return builder.build()
    }

    /// Create a transliterator from this recipe.
    public func makeTransliterator() throws -> Transliterator {
        return try (buildTransliteratorConfig()).makeTransliterator()
    }

    // MARK: - Private helper methods

    private func removeIvsSvsHelper(to builder: TransliteratorConfigListBuilder, dropAllSelectors _: Bool) {
        // First insert IVS-or-SVS mode at head
        var ivsOptions = IvsSvsBaseTransliterator.Options()
        ivsOptions.mode = .ivsOrSvs
        ivsOptions.charset = charset
        builder.insertHead(.ivsSvsBase(options: ivsOptions), forceReplace: true)

        // Then insert base mode at tail
        var baseOptions = IvsSvsBaseTransliterator.Options()
        baseOptions.mode = .base
        baseOptions.charset = charset
        // Note: dropSelectorsAltogether is not yet available in Swift implementation
        // The dropAllSelectors parameter would be used here when implemented
        builder.insertTail(.ivsSvsBase(options: baseOptions), forceReplace: true)
    }

    private func applyKanjiOldNew(to builder: TransliteratorConfigListBuilder) {
        if kanjiOldNew {
            removeIvsSvsHelper(to: builder, dropAllSelectors: false)
            builder.insertMiddle(.kanjiOldNew, forceReplace: false)
        }
    }

    private func applyHiraKata(to builder: TransliteratorConfigListBuilder) {
        if let hiraKata = hiraKata {
            let options = HiraKataTransliterator.Options(mode: hiraKata)
            builder.insertTail(.hiraKata(options: options), forceReplace: false)
        }
    }

    private func applyReplaceJapaneseIterationMarks(to builder: TransliteratorConfigListBuilder) {
        if replaceJapaneseIterationMarks {
            // Insert HiraKataComposition at head to ensure composed forms
            var compositionOptions = HiraKataCompositionTransliterator.Options()
            compositionOptions.composeNonCombiningMarks = true
            builder.insertHead(.hiraKataComposition(options: compositionOptions), forceReplace: false)
            // Then insert the japanese-iteration-marks in the middle
            builder.insertMiddle(.japaneseIterationMarks(options: JapaneseIterationMarksTransliterator.Options()), forceReplace: false)
        }
    }

    private func applyReplaceSuspiciousHyphensToProlongedSoundMarks(to builder: TransliteratorConfigListBuilder) {
        if replaceSuspiciousHyphensToProlongedSoundMarks {
            // Note: ProlongedSoundMarksTransliterator does not yet support options in Swift
            // The replaceProlongedMarksFollowingAlnums option would be configured here when available
            builder.insertMiddle(.prolongedSoundMarks, forceReplace: false)
        }
    }

    private func applyReplaceIdeographicAnnotations(to builder: TransliteratorConfigListBuilder) {
        if replaceIdeographicAnnotations {
            builder.insertMiddle(.ideographicAnnotations, forceReplace: false)
        }
    }

    private func applyReplaceRadicals(to builder: TransliteratorConfigListBuilder) {
        if replaceRadicals {
            builder.insertMiddle(.radicals, forceReplace: false)
        }
    }

    private func applyReplaceSpaces(to builder: TransliteratorConfigListBuilder) {
        if replaceSpaces {
            builder.insertMiddle(.spaces, forceReplace: false)
        }
    }

    private func applyReplaceHyphens(to builder: TransliteratorConfigListBuilder) {
        if replaceHyphens.isEnabled {
            var options = HyphensTransliterator.Options()
            if let precedence = replaceHyphens.precedence {
                options.precedence = precedence
            }
            builder.insertMiddle(.hyphens(options: options), forceReplace: false)
        }
    }

    private func applyReplaceMathematicalAlphanumerics(to builder: TransliteratorConfigListBuilder) {
        if replaceMathematicalAlphanumerics {
            builder.insertMiddle(.mathematicalAlphanumerics, forceReplace: false)
        }
    }

    private func applyReplaceRomanNumerals(to builder: TransliteratorConfigListBuilder) {
        if replaceRomanNumerals {
            builder.insertMiddle(.romanNumerals, forceReplace: false)
        }
    }

    private func applyReplaceArchaicHirakatas(to builder: TransliteratorConfigListBuilder) {
        if replaceArchaicHirakatas {
            builder.insertMiddle(.archaicHirakatas, forceReplace: false)
        }
    }

    private func applyReplaceSmallHirakatas(to builder: TransliteratorConfigListBuilder) {
        if replaceSmallHirakatas {
            builder.insertMiddle(.smallHirakatas, forceReplace: false)
        }
    }

    private func applyCombineDecomposedHiraganasAndKatakanas(to builder: TransliteratorConfigListBuilder) {
        if combineDecomposedHiraganasAndKatakanas {
            var options = HiraKataCompositionTransliterator.Options()
            options.composeNonCombiningMarks = true
            builder.insertHead(.hiraKataComposition(options: options), forceReplace: false)
        }
    }

    private func applyToFullwidth(to builder: TransliteratorConfigListBuilder) {
        if toFullwidth.isEnabled {
            var options = Jisx0201AndAlikeTransliterator.Options()
            options.fullwidthToHalfwidth = false
            options.u005cAsYenSign = toFullwidth.isU005cAsYenSign
            builder.insertTail(.jisx0201AndAlike(options: options), forceReplace: false)
        }
    }

    private func applyToHalfwidth(to builder: TransliteratorConfigListBuilder) {
        if toHalfwidth.isEnabled {
            var options = Jisx0201AndAlikeTransliterator.Options()
            options.fullwidthToHalfwidth = true
            options.convertGL = true
            options.convertGR = toHalfwidth.isHankakuKana
            builder.insertTail(.jisx0201AndAlike(options: options), forceReplace: false)
        }
    }

    private func applyConvertHistoricalHirakatas(to builder: TransliteratorConfigListBuilder) {
        if let mode = convertHistoricalHirakatas {
            let options: HistoricalHirakatasTransliterator.Options
            switch mode {
            case .simple:
                options = HistoricalHirakatasTransliterator.Options(
                    hiraganas: .simple,
                    katakanas: .simple,
                    voicedKatakanas: .skip
                )
            case .decompose:
                options = HistoricalHirakatasTransliterator.Options(
                    hiraganas: .decompose,
                    katakanas: .decompose,
                    voicedKatakanas: .decompose
                )
            }
            builder.insertMiddle(.historicalHirakatas(options: options), forceReplace: false)
        }
    }

    private func applyRemoveIvsSvs(to builder: TransliteratorConfigListBuilder) {
        if removeIvsSvs.isEnabled {
            removeIvsSvsHelper(to: builder, dropAllSelectors: removeIvsSvs.isDropAllSelectors)
        }
    }

    private func applyReplaceCombinedCharacters(to builder: TransliteratorConfigListBuilder) {
        if replaceCombinedCharacters {
            builder.insertMiddle(.combined, forceReplace: false)
        }
    }

    private func applyReplaceCircledOrSquaredCharacters(to builder: TransliteratorConfigListBuilder) {
        if replaceCircledOrSquaredCharacters.isEnabled {
            var options = CircledOrSquaredTransliterator.Options()
            options.includeEmojis = replaceCircledOrSquaredCharacters.includeEmojis
            builder.insertMiddle(.circledOrSquared(options: options), forceReplace: false)
        }
    }
}

// MARK: - Fluent API Extensions

public extension TransliterationRecipe {
    func withKanjiOldNew(_ value: Bool) -> TransliterationRecipe {
        var recipe = self
        recipe.kanjiOldNew = value
        return recipe
    }

    func withReplaceSuspiciousHyphensToProlongedSoundMarks(_ value: Bool) -> TransliterationRecipe {
        var recipe = self
        recipe.replaceSuspiciousHyphensToProlongedSoundMarks = value
        return recipe
    }

    func withReplaceCombinedCharacters(_ value: Bool) -> TransliterationRecipe {
        var recipe = self
        recipe.replaceCombinedCharacters = value
        return recipe
    }

    func withReplaceCircledOrSquaredCharacters(_ value: ReplaceCircledOrSquaredCharactersOptions) -> TransliterationRecipe {
        var recipe = self
        recipe.replaceCircledOrSquaredCharacters = value
        return recipe
    }

    func withReplaceIdeographicAnnotations(_ value: Bool) -> TransliterationRecipe {
        var recipe = self
        recipe.replaceIdeographicAnnotations = value
        return recipe
    }

    func withReplaceRadicals(_ value: Bool) -> TransliterationRecipe {
        var recipe = self
        recipe.replaceRadicals = value
        return recipe
    }

    func withReplaceSpaces(_ value: Bool) -> TransliterationRecipe {
        var recipe = self
        recipe.replaceSpaces = value
        return recipe
    }

    func withReplaceHyphens(_ value: ReplaceHyphensOptions) -> TransliterationRecipe {
        var recipe = self
        recipe.replaceHyphens = value
        return recipe
    }

    func withReplaceMathematicalAlphanumerics(_ value: Bool) -> TransliterationRecipe {
        var recipe = self
        recipe.replaceMathematicalAlphanumerics = value
        return recipe
    }

    func withReplaceRomanNumerals(_ value: Bool) -> TransliterationRecipe {
        var recipe = self
        recipe.replaceRomanNumerals = value
        return recipe
    }

    func withCombineDecomposedHiraganasAndKatakanas(_ value: Bool) -> TransliterationRecipe {
        var recipe = self
        recipe.combineDecomposedHiraganasAndKatakanas = value
        return recipe
    }

    func withToFullwidth(_ value: ToFullwidthOptions) -> TransliterationRecipe {
        var recipe = self
        recipe.toFullwidth = value
        return recipe
    }

    func withToHalfwidth(_ value: ToHalfwidthOptions) -> TransliterationRecipe {
        var recipe = self
        recipe.toHalfwidth = value
        return recipe
    }

    func withRemoveIvsSvs(_ value: RemoveIvsSvsOptions) -> TransliterationRecipe {
        var recipe = self
        recipe.removeIvsSvs = value
        return recipe
    }

    func withConvertHistoricalHirakatas(_ value: ConvertHistoricalHirakatasMode?) -> TransliterationRecipe {
        var recipe = self
        recipe.convertHistoricalHirakatas = value
        return recipe
    }

    func withCharset(_ value: IvsSvsBaseTransliterator.Charset) -> TransliterationRecipe {
        var recipe = self
        recipe.charset = value
        return recipe
    }
}

// MARK: - Error Types

public enum TransliterationRecipeError: Error {
    case mutuallyExclusiveOptions(String)
}

// MARK: - TransliteratorConfigListBuilder

/// Internal builder for creating lists of transliterator configurations.
class TransliteratorConfigListBuilder {
    private var head: [TransliteratorConfig] = []
    private var tail: [TransliteratorConfig] = []

    func insertHead(_ type: TransliteratorConfig, forceReplace: Bool) {
        let existingIndex = findConfigIndex(in: head, matching: type)

        if let index = existingIndex {
            if forceReplace {
                head[index] = type
            }
        } else {
            head.insert(type, at: 0)
        }
    }

    func insertMiddle(_ type: TransliteratorConfig, forceReplace: Bool) {
        let existingIndex = findConfigIndex(in: tail, matching: type)

        if let index = existingIndex {
            if forceReplace {
                tail[index] = type
            }
        } else {
            tail.insert(type, at: 0) // Insert at beginning of tail (middle position)
        }
    }

    func insertTail(_ type: TransliteratorConfig, forceReplace: Bool) {
        let existingIndex = findConfigIndex(in: tail, matching: type)

        if let index = existingIndex {
            if forceReplace {
                tail[index] = type
            }
        } else {
            tail.append(type)
        }
    }

    private func findConfigIndex(in array: [TransliteratorConfig], matching type: TransliteratorConfig) -> Int? {
        for (index, existingType) in array.enumerated() {
            if areTypesEqual(existingType, type) {
                return index
            }
        }
        return nil
    }

    private func areTypesEqual(_ lhs: TransliteratorConfig, _ rhs: TransliteratorConfig) -> Bool {
        // Compare based on the base type name
        switch (lhs, rhs) {
        case (.spaces, .spaces),
             (.radicals, .radicals),
             (.mathematicalAlphanumerics, .mathematicalAlphanumerics),
             (.ideographicAnnotations, .ideographicAnnotations),
             (.kanjiOldNew, .kanjiOldNew),
             (.combined, .combined),
             (.prolongedSoundMarks, .prolongedSoundMarks),
             (.romanNumerals, .romanNumerals):
            return true
        case (.hyphens, .hyphens),
             (.jisx0201AndAlike, .jisx0201AndAlike),
             (.ivsSvsBase, .ivsSvsBase),
             (.circledOrSquared, .circledOrSquared),
             (.hiraKataComposition, .hiraKataComposition),
             (.hiraKata, .hiraKata),
             (.japaneseIterationMarks, .japaneseIterationMarks):
            return true
        case let (.historicalHirakatas(options: lhsOpts), .historicalHirakatas(options: rhsOpts)):
            return lhsOpts == rhsOpts
        case (.custom, .custom):
            return false // Custom transliterators are never considered equal
        default:
            return false
        }
    }

    func build() -> [TransliteratorConfig] {
        var config: [TransliteratorConfig] = []
        config.append(contentsOf: head)
        config.append(contentsOf: tail)
        return config
    }
}
