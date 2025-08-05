import Foundation

public final class TransliteratorChar: Equatable, CustomStringConvertible {
    public let value: String
    public let offset: Int
    public let source: TransliteratorChar?

    public init(value: String, offset: Int, source: TransliteratorChar? = nil) {
        self.value = value
        self.offset = offset
        self.source = source
    }

    public func withOffset(_ offset: Int) -> TransliteratorChar {
        return TransliteratorChar(value: value, offset: offset, source: self)
    }

    public var isTransliterated: Bool {
        var c = self
        while true {
            if let s = c.source {
                if s.value != c.value {
                    return true
                }
                c = s
            } else {
                break
            }
        }
        return false
    }

    public var description: String {
        value
    }

    public static func == (lhs: TransliteratorChar, rhs: TransliteratorChar) -> Bool {
        lhs.value == rhs.value && lhs.offset == rhs.offset
    }
}

public enum TransliteratorChars {
    public static func fromString(_ string: String) -> [TransliteratorChar] {
        var chars: [TransliteratorChar] = []
        var offset = 0

        for graphemeCluster in string {
            let value = String(graphemeCluster)
            chars.append(TransliteratorChar(value: value, offset: offset))
            offset += value.utf16.count
        }

        return chars
    }

    public static func toString<S: Sequence>(_ chars: S) -> String where S.Element == TransliteratorChar {
        chars.map { $0.value }.joined()
    }
}
