import Foundation

public struct StringTransliteratorWrapper: StringTransliterator {
    private let transliterator: Transliterator

    public init(_ transliterator: Transliterator) {
        self.transliterator = transliterator
    }

    public func transliterate(_ string: String) -> String {
        let chars = TransliteratorChars.fromString(string)
        let result = transliterator.transliterate(chars)
        return TransliteratorChars.toString(result)
    }
}

public extension Transliterator {
    var stringTransliterator: StringTransliterator {
        StringTransliteratorWrapper(self)
    }
}
