import Foundation

public struct IvsSvsBaseTransliterator: Transliterator {
    public enum Mode {
        case ivsOrSvs // Convert base to IVS/SVS
        case base // Convert IVS/SVS to base
    }

    public enum Charset {
        case unijis90
        case unijis2004
    }

    public struct Options {
        public var mode: Mode = .ivsOrSvs
        public var charset: Charset = .unijis90
        public var preferSvs: Bool = false
        public var dropSelectorsAltogether: Bool = false

        public init(
            mode: Mode = .ivsOrSvs,
            charset: Charset = .unijis90,
            preferSvs: Bool = false,
            dropSelectorsAltogether: Bool = false
        ) {
            self.mode = mode
            self.charset = charset
            self.preferSvs = preferSvs
            self.dropSelectorsAltogether = dropSelectorsAltogether
        }
    }

    private let options: Options

    // Lazy loaded mappings
    private static var _mappings: MappingData?
    private static let mappingsQueue = DispatchQueue(label: "com.yosina.ivs-svs-mappings")

    private struct IvsSvsBaseRecord {
        let ivs: Character
        let svs: Character?
        let base90: Character?
        let base2004: Character?
    }

    private struct MappingData {
        let base90: [Character: IvsSvsBaseRecord]
        let base2004: [Character: IvsSvsBaseRecord]
        let variantToBase: [Character: IvsSvsBaseRecord]
    }

    private static var mappings: MappingData {
        mappingsQueue.sync {
            if let existing = _mappings {
                return existing
            }

            let loaded = loadMappings()
            _mappings = loaded
            return loaded
        }
    }

    private static func loadMappings() -> MappingData {
        // Try to load from bundle resource
        guard let url = Bundle.module.url(forResource: "ivs_svs_base", withExtension: "data") else {
            fatalError("IVS/SVS mappings file not found in bundle")
        }
        do {
            let data = try Data(contentsOf: url)
            return try parseBinaryData(data)
        } catch {
            fatalError("Failed to load IVS/SVS mappings from binary: \(error)")
        }
    }

    private static func parseBinaryData(_ data: Data) throws -> MappingData {
        guard data.count >= 4 else {
            throw NSError(
                domain: "io.yosina",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Data is too short to contain mappings"]
            )
        }

        // Read count as big-endian Int32
        let count = data.withUnsafeBytes { bytes in
            bytes.load(fromByteOffset: 0, as: Int32.self).bigEndian
        }

        let entrySize = 24 // 6 Int32 values = 24 bytes
        guard data.count >= 4 + Int(count) * entrySize else {
            throw NSError(
                domain: "io.yosina",
                code: 2,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Data is too short for the expected number of entries",
                ]
            )
        }

        var base90Mappings = [Character: IvsSvsBaseRecord]()
        var base2004Mappings = [Character: IvsSvsBaseRecord]()
        var variantToBaseMappings = [Character: IvsSvsBaseRecord]()

        var offset = 4
        for _ in 0 ..< count {
            // Read entry
            guard
                let ivs = try codepointToString(
                    data.withUnsafeBytes { bytes in
                        (
                            bytes.load(fromByteOffset: offset, as: Int32.self).bigEndian,
                            bytes.load(fromByteOffset: offset + 4, as: Int32.self).bigEndian,
                        )
                    }
                )
            else {
                throw NSError(
                    domain: "io.yosina",
                    code: 3,
                    userInfo: [NSLocalizedDescriptionKey: "IVS codepoint is zero"]
                )
            }
            let svs = try codepointToString(
                data.withUnsafeBytes { bytes in
                    (
                        bytes.load(fromByteOffset: offset + 8, as: Int32.self).bigEndian,
                        bytes.load(fromByteOffset: offset + 12, as: Int32.self).bigEndian,
                    )
                }
            )
            let base90 = try codepointToString(
                data.withUnsafeBytes { bytes in
                    bytes.load(fromByteOffset: offset + 16, as: Int32.self).bigEndian
                }
            )
            let base2004 = try codepointToString(
                data.withUnsafeBytes { bytes in
                    bytes.load(fromByteOffset: offset + 20, as: Int32.self).bigEndian
                }
            )
            let record = IvsSvsBaseRecord(
                ivs: ivs,
                svs: svs,
                base90: base90,
                base2004: base2004,
            )
            if let base90 = base90 {
                base90Mappings[base90] = record
            }
            if let base2004 = base2004 {
                base2004Mappings[base2004] = record
            }
            variantToBaseMappings[ivs] = record
            if let svs = svs {
                variantToBaseMappings[svs] = record
            }
            offset += entrySize
        }
        return MappingData(
            base90: base90Mappings,
            base2004: base2004Mappings,
            variantToBase: variantToBaseMappings
        )
    }

    private static func codepointToString(_ codepoint: Int32) throws -> Character? {
        guard codepoint != 0 else {
            return nil
        }
        guard let scalar = UnicodeScalar(Int(codepoint)) else {
            fatalError("invalid codepoint for UnicodeScalar(): \(codepoint)")
        }
        return Character(scalar)
    }

    private static func codepointToString(_ codepoints: (Int32, Int32)) throws -> Character? {
        var s = String()
        if let c = try codepointToString(codepoints.0) {
            s.append(c)
        }
        if let c = try codepointToString(codepoints.1) {
            s.append(c)
        }
        if s.count == 0 {
            return nil
        }
        return Character(s)
    }

    public init(options: Options = Options()) {
        self.options = options
    }

    public func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar]
        where S.Element == TransliteratorChar
    {
        if options.mode == .base {
            return transliterateToBase(chars)
        } else {
            return transliterateToIvsSvs(chars)
        }
    }

    public func transliterateToBase<S: Sequence>(_ chars: S) -> [TransliteratorChar]
        where S.Element == TransliteratorChar
    {
        var result: [TransliteratorChar] = []
        let charsArray = Array(chars)
        var offset = 0

        for char in charsArray {
            guard let charValue = char.value else {
                // sentinel
                result.append(char.withOffset(offset))
                offset += char.utf8Count
                continue
            }
            if let record = Self.mappings.variantToBase[charValue],
               let replacement = options.charset == .unijis90 ? record.base90 : record.base2004
            {
                result.append(
                    TransliteratorChar(value: replacement, offset: offset, source: char)
                )
                offset += replacement.utf8.count
                continue
            }
            if options.dropSelectorsAltogether,
               charValue.unicodeScalars.count == 2,
               let possibleSelector = charValue.unicodeScalars.last,
               Self.isVariantSelector(possibleSelector)
            {
                let first = charValue.unicodeScalars.first
                result.append(
                    TransliteratorChar(value: Character(first!), offset: offset, source: char))
                offset += first!.utf8.count
                continue
            }
            result.append(char.withOffset(offset))
            offset += char.utf8Count
        }

        return result
    }

    private static func isVariantSelector(_ scalar: UnicodeScalar) -> Bool {
        return (0xFE00 ... 0xFE0F).contains(scalar.value)
            || (0xE0100 ... 0xE01EF).contains(scalar.value)
    }

    public func transliterateToIvsSvs<S: Sequence>(_ chars: S) -> [TransliteratorChar]
        where S.Element == TransliteratorChar
    {
        var result: [TransliteratorChar] = []
        let charsArray = Array(chars)
        var offset = 0

        let mappings =
            options.charset == .unijis90
                ? IvsSvsBaseTransliterator.mappings.base90
                : IvsSvsBaseTransliterator.mappings.base2004

        for char in charsArray {
            guard let charValue = char.value else {
                // sentinel
                result.append(char.withOffset(offset))
                offset += char.utf8Count
                continue
            }
            // Try to convert base to variant
            if let record = mappings[charValue] {
                let replacement = options.preferSvs ? (record.svs ?? record.ivs) : record.ivs
                result.append(
                    TransliteratorChar(value: replacement, offset: offset, source: char)
                )
                offset += replacement.utf8.count
                continue
            }
            result.append(char.withOffset(offset))
            offset += char.utf8Count
        }

        return result
    }
}
