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

// MARK: - TransliteratorRecipe

/// Configuration recipe for building transliterator chains.
///
/// This struct provides a declarative way to configure complex transliterator chains
/// using high-level options that are automatically converted to the appropriate
/// transliterator configurations.
public struct TransliteratorRecipe {
    /// Replace codepoints that correspond to old-style kanji glyphs (旧字体; kyu-ji-tai)
    /// with their modern equivalents (新字体; shin-ji-tai).
    ///
    /// Example:
    /// Input:  "舊字體の變換"
    /// Output: "旧字体の変換"
    public var kanjiOldNew: Bool = false

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

    /// Character set for IVS/SVS operations.
    public var charset: IvsSvsBaseTransliterator.Charset = .unijis2004

    public init() {}

    /// Build transliterator configurations from this recipe.
    ///
    /// Returns a TransliteratorConfig that can be passed to Yosina.makeTransliterator.
    ///
    /// Throws an error if the recipe contains mutually exclusive options.
    public func buildTransliteratorConfig() throws -> TransliteratorConfig {
        // Check for mutually exclusive options
        var errors: [String] = []
        if toFullwidth.isEnabled && toHalfwidth.isEnabled {
            errors.append("toFullwidth and toHalfwidth are mutually exclusive")
        }

        if !errors.isEmpty {
            throw TransliteratorRecipeError.mutuallyExclusiveOptions(errors.joined(separator: "; "))
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
        applyCombineDecomposedHiraganasAndKatakanas(to: builder)
        applyToFullwidth(to: builder)
        applyToHalfwidth(to: builder)
        applyRemoveIvsSvs(to: builder)

        return builder.build()
    }

    /// Create a transliterator from this recipe.
    public func makeTransliterator() throws -> StringTransliterator {
        let config = try buildTransliteratorConfig()
        return Yosina.makeTransliterator(from: config)
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

public extension TransliteratorRecipe {
    func withKanjiOldNew(_ value: Bool) -> TransliteratorRecipe {
        var recipe = self
        recipe.kanjiOldNew = value
        return recipe
    }

    func withReplaceSuspiciousHyphensToProlongedSoundMarks(_ value: Bool) -> TransliteratorRecipe {
        var recipe = self
        recipe.replaceSuspiciousHyphensToProlongedSoundMarks = value
        return recipe
    }

    func withReplaceCombinedCharacters(_ value: Bool) -> TransliteratorRecipe {
        var recipe = self
        recipe.replaceCombinedCharacters = value
        return recipe
    }

    func withReplaceCircledOrSquaredCharacters(_ value: ReplaceCircledOrSquaredCharactersOptions) -> TransliteratorRecipe {
        var recipe = self
        recipe.replaceCircledOrSquaredCharacters = value
        return recipe
    }

    func withReplaceIdeographicAnnotations(_ value: Bool) -> TransliteratorRecipe {
        var recipe = self
        recipe.replaceIdeographicAnnotations = value
        return recipe
    }

    func withReplaceRadicals(_ value: Bool) -> TransliteratorRecipe {
        var recipe = self
        recipe.replaceRadicals = value
        return recipe
    }

    func withReplaceSpaces(_ value: Bool) -> TransliteratorRecipe {
        var recipe = self
        recipe.replaceSpaces = value
        return recipe
    }

    func withReplaceHyphens(_ value: ReplaceHyphensOptions) -> TransliteratorRecipe {
        var recipe = self
        recipe.replaceHyphens = value
        return recipe
    }

    func withReplaceMathematicalAlphanumerics(_ value: Bool) -> TransliteratorRecipe {
        var recipe = self
        recipe.replaceMathematicalAlphanumerics = value
        return recipe
    }

    func withCombineDecomposedHiraganasAndKatakanas(_ value: Bool) -> TransliteratorRecipe {
        var recipe = self
        recipe.combineDecomposedHiraganasAndKatakanas = value
        return recipe
    }

    func withToFullwidth(_ value: ToFullwidthOptions) -> TransliteratorRecipe {
        var recipe = self
        recipe.toFullwidth = value
        return recipe
    }

    func withToHalfwidth(_ value: ToHalfwidthOptions) -> TransliteratorRecipe {
        var recipe = self
        recipe.toHalfwidth = value
        return recipe
    }

    func withRemoveIvsSvs(_ value: RemoveIvsSvsOptions) -> TransliteratorRecipe {
        var recipe = self
        recipe.removeIvsSvs = value
        return recipe
    }

    func withCharset(_ value: IvsSvsBaseTransliterator.Charset) -> TransliteratorRecipe {
        var recipe = self
        recipe.charset = value
        return recipe
    }
}

// MARK: - Error Types

public enum TransliteratorRecipeError: Error {
    case mutuallyExclusiveOptions(String)
}

// MARK: - TransliteratorConfigListBuilder

/// Internal builder for creating lists of transliterator configurations.
class TransliteratorConfigListBuilder {
    private var head: [TransliteratorConfig.TransliteratorType] = []
    private var tail: [TransliteratorConfig.TransliteratorType] = []

    func insertHead(_ type: TransliteratorConfig.TransliteratorType, forceReplace: Bool) {
        let existingIndex = findConfigIndex(in: head, matching: type)

        if let index = existingIndex {
            if forceReplace {
                head[index] = type
            }
        } else {
            head.insert(type, at: 0)
        }
    }

    func insertMiddle(_ type: TransliteratorConfig.TransliteratorType, forceReplace: Bool) {
        let existingIndex = findConfigIndex(in: tail, matching: type)

        if let index = existingIndex {
            if forceReplace {
                tail[index] = type
            }
        } else {
            tail.insert(type, at: 0) // Insert at beginning of tail (middle position)
        }
    }

    func insertTail(_ type: TransliteratorConfig.TransliteratorType, forceReplace: Bool) {
        let existingIndex = findConfigIndex(in: tail, matching: type)

        if let index = existingIndex {
            if forceReplace {
                tail[index] = type
            }
        } else {
            tail.append(type)
        }
    }

    private func findConfigIndex(in array: [TransliteratorConfig.TransliteratorType], matching type: TransliteratorConfig.TransliteratorType) -> Int? {
        for (index, existingType) in array.enumerated() {
            if areTypesEqual(existingType, type) {
                return index
            }
        }
        return nil
    }

    private func areTypesEqual(_ lhs: TransliteratorConfig.TransliteratorType, _ rhs: TransliteratorConfig.TransliteratorType) -> Bool {
        // Compare based on the base type name
        switch (lhs, rhs) {
        case (.spaces, .spaces),
             (.radicals, .radicals),
             (.mathematicalAlphanumerics, .mathematicalAlphanumerics),
             (.ideographicAnnotations, .ideographicAnnotations),
             (.kanjiOldNew, .kanjiOldNew),
             (.combined, .combined),
             (.prolongedSoundMarks, .prolongedSoundMarks):
            return true
        case (.hyphens, .hyphens),
             (.jisx0201AndAlike, .jisx0201AndAlike),
             (.ivsSvsBase, .ivsSvsBase),
             (.circledOrSquared, .circledOrSquared),
             (.hiraKataComposition, .hiraKataComposition):
            return true
        case (.custom, .custom):
            return false // Custom transliterators are never considered equal
        default:
            return false
        }
    }

    func build() -> TransliteratorConfig {
        var config = TransliteratorConfig()

        // Add all head configs
        for type in head {
            config.add(type)
        }

        // Add all tail configs
        for type in tail {
            config.add(type)
        }

        return config
    }
}
