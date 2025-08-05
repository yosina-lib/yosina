import Foundation

public struct ChainedTransliterator: Transliterator {
    let transliterators: [Transliterator]

    public init(transliterators: [Transliterator]) {
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

public extension Transliterator {
    func chained(with other: Transliterator) -> ChainedTransliterator {
        if let self = self as? ChainedTransliterator {
            return ChainedTransliterator(transliterators: self.transliterators + [other])
        } else if let other = other as? ChainedTransliterator {
            return ChainedTransliterator(transliterators: [self] + other.transliterators)
        } else {
            return ChainedTransliterator(self, other)
        }
    }
}
