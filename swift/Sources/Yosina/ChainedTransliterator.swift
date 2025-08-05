import Foundation

public struct ChainedTransliterator: Transliterator {
    let transliterators: any Sequence<Transliterator>

    public init(transliterators: any Sequence<Transliterator>) {
        self.transliterators = transliterators
    }

    public init(_ transliterators: Transliterator...) {
        self.transliterators = transliterators
    }

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar] where S.Element == TransliteratorChar {
        var result = Array(chars)

        for transliterator in transliterators {
            result = transliterator.transliterate(result)
        }

        return result
    }
}
