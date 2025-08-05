import Foundation

public enum Yosina {
    public static func makeTransliterator(from config: TransliteratorConfig) -> StringTransliterator {
        let transliterators = config.build()
        if transliterators.count == 1 {
            return transliterators[0].stringTransliterator
        } else {
            return ChainedTransliterator(transliterators: transliterators).stringTransliterator
        }
    }
}

public struct TransliteratorConfig {
    private var configs: [(type: TransliteratorType, options: [String: Any])] = []

    public init() {}

    public enum TransliteratorType {
        case spaces
        case hyphens(options: HyphensTransliterator.Options = HyphensTransliterator.Options())
        case radicals
        case mathematicalAlphanumerics
        case ideographicAnnotations
        case kanjiOldNew
        case combined
        case circledOrSquared(options: CircledOrSquaredTransliterator.Options = CircledOrSquaredTransliterator.Options())
        case prolongedSoundMarks
        case hiraKataComposition(options: HiraKataCompositionTransliterator.Options = HiraKataCompositionTransliterator.Options())
        case jisx0201AndAlike(options: Jisx0201AndAlikeTransliterator.Options = Jisx0201AndAlikeTransliterator.Options())
        case ivsSvsBase(options: IvsSvsBaseTransliterator.Options = IvsSvsBaseTransliterator.Options())
        case japaneseIterationMarks(options: JapaneseIterationMarksTransliterator.Options = JapaneseIterationMarksTransliterator.Options())
        case custom(Transliterator)
    }

    @discardableResult
    public mutating func add(_ type: TransliteratorType) -> TransliteratorConfig {
        configs.append((type, [:]))
        return self
    }

    func build() -> [Transliterator] {
        configs.map { config in
            switch config.type {
            case .spaces:
                return SpacesTransliterator()
            case let .hyphens(options):
                return HyphensTransliterator(options: options)
            case .radicals:
                return RadicalsTransliterator()
            case .mathematicalAlphanumerics:
                return MathematicalAlphanumericsTransliterator()
            case .ideographicAnnotations:
                return IdeographicAnnotationsTransliterator()
            case .kanjiOldNew:
                return KanjiOldNewTransliterator()
            case .combined:
                return CombinedTransliterator()
            case let .circledOrSquared(options):
                return CircledOrSquaredTransliterator(options: options)
            case .prolongedSoundMarks:
                return ProlongedSoundMarksTransliterator()
            case let .hiraKataComposition(options):
                return HiraKataCompositionTransliterator(options: options)
            case let .jisx0201AndAlike(options):
                return Jisx0201AndAlikeTransliterator(options: options)
            case let .ivsSvsBase(options):
                return IvsSvsBaseTransliterator(options: options)
            case let .japaneseIterationMarks(options):
                return JapaneseIterationMarksTransliterator(options: options)
            case let .custom(transliterator):
                return transliterator
            }
        }
    }
}
