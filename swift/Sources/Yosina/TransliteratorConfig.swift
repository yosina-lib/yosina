public enum TransliteratorConfig: TransliteratorFactory {
    case spaces
    case hyphens(options: HyphensTransliterator.Options = HyphensTransliterator.Options())
    case radicals
    case mathematicalAlphanumerics
    case ideographicAnnotations
    case kanjiOldNew
    case combined
    case circledOrSquared(options: CircledOrSquaredTransliterator.Options = CircledOrSquaredTransliterator.Options())
    case prolongedSoundMarks
    case hiraKata(options: HiraKataTransliterator.Options = HiraKataTransliterator.Options())
    case hiraKataComposition(options: HiraKataCompositionTransliterator.Options = HiraKataCompositionTransliterator.Options())
    case jisx0201AndAlike(options: Jisx0201AndAlikeTransliterator.Options = Jisx0201AndAlikeTransliterator.Options())
    case ivsSvsBase(options: IvsSvsBaseTransliterator.Options = IvsSvsBaseTransliterator.Options())
    case japaneseIterationMarks(options: JapaneseIterationMarksTransliterator.Options = JapaneseIterationMarksTransliterator.Options())
    case custom(Transliterator)

    public func makeTransliterator() -> Transliterator {
        switch self {
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
        case let .hiraKata(options):
            return HiraKataTransliterator(options: options)
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

public struct TransliteratorConfigsWrapper: TransliteratorFactory {
    let configs: any Collection<TransliteratorConfig>

    public init(_ configs: any Collection<TransliteratorConfig>) {
        self.configs = configs
    }

    public func makeTransliterator() -> Transliterator {
        return ChainedTransliterator(transliterators: configs.map { $0.makeTransliterator() })
    }
}

public extension Collection where Element == TransliteratorConfig {
    func makeTransliterator() -> Transliterator {
        return TransliteratorConfigsWrapper(self).makeTransliterator()
    }
}
