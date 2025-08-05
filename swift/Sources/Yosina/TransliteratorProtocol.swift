import Foundation

public protocol Transliterator {
    func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar
}

public protocol TransliteratorFactory {
    func makeTransliterator() throws -> Transliterator
}

public enum TransliteratorError: Error {
    case invalidOption(String)
    case notFound(String)
    case configurationError(String)
}
