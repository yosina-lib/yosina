import Foundation

public final class TransliteratorChar: Equatable, CustomStringConvertible {
    public let value: Character?
    public let offset: Int
    public let source: TransliteratorChar?

    public init(value: Character? = nil, offset: Int, source: TransliteratorChar? = nil) {
        self.value = value
        self.offset = offset
        self.source = source
    }

    public func withOffset(_ offset: Int) -> TransliteratorChar {
        return TransliteratorChar(value: value, offset: offset, source: self)
    }

    public var isSentinel: Bool {
        return value == nil
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

    public var utf8Count: Int {
        return value?.utf8.count ?? 0
    }

    public var description: String {
        if let value = value {
            String(value)
        } else {
            ""
        }
    }

    public static func == (lhs: TransliteratorChar, rhs: TransliteratorChar) -> Bool {
        lhs.value == rhs.value && lhs.offset == rhs.offset
    }
}

public enum TransliteratorChars {
    public static func fromString(_ string: String) -> [TransliteratorChar] {
        var chars: [TransliteratorChar] = []
        var offset = 0

        for c in string {
            chars.append(TransliteratorChar(value: c, offset: offset))
            offset += c.utf8.count
        }
        // Append sentinel
        chars.append(TransliteratorChar(offset: offset)) // Null terminator
        return chars
    }

    public static func toString<S: Sequence>(_ chars: S) -> String where S.Element == TransliteratorChar {
        var s = ""
        for c in chars {
            if let value = c.value {
                s.append(value)
            }
        }
        return s
    }
}
