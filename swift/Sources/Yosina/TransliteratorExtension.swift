import Foundation

public extension Transliterator {
    func transliterate(_ string: String) -> String {
        let chars = TransliteratorChars.fromString(string)
        let result = transliterate(chars)
        return TransliteratorChars.toString(result)
    }

    func callAsFunction(_ string: String) -> String {
        return transliterate(string)
    }
}
