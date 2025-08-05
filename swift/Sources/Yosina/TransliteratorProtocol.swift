import Foundation

public protocol Transliterator {
    func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar
}

public protocol StringTransliterator {
    func transliterate(_ string: String) -> String
}

public protocol TransliteratorFactory {
    func create(with options: [String: Any]) throws -> Transliterator
}

public enum TransliteratorError: Error {
    case invalidOption(String)
    case notFound(String)
    case configurationError(String)
}
