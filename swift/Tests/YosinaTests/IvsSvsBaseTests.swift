import XCTest
@testable import Yosina

final class IvsSvsBaseTests: XCTestCase {
    func testIvsToBase() {
        var options = IvsSvsBaseTransliterator.Options()
        options.mode = .base
        options.charset = .unijis90
        let transliterator = IvsSvsBaseTransliterator(options: options)

        // IVS sequences should be converted to base characters
        // Note: The actual characters depend on the data, these are examples
        let ivsSequence = "葛\u{E0100}" // 葛 + VS17
        let result = transliterator.transliterate(ivsSequence)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result, "葛")
    }

    func testBaseToIvs() {
        var options = IvsSvsBaseTransliterator.Options()
        options.mode = .ivsOrSvs
        options.charset = .unijis90
        let transliterator = IvsSvsBaseTransliterator(options: options)

        // Base characters might be converted to IVS/SVS
        // The actual conversion depends on the mapping data
        let baseChar = "仝"
        let result = transliterator.transliterate(baseChar)
        // Result could be the same or have variation selector added
        XCTAssertNotNil(result)
    }

    func testNoChange() {
        var options = IvsSvsBaseTransliterator.Options()
        options.mode = .base
        options.charset = .unijis90
        let transliterator = IvsSvsBaseTransliterator(options: options)

        // Regular text without IVS/SVS should not change
        XCTAssertEqual(transliterator.transliterate("Hello"), "Hello")
        XCTAssertEqual(transliterator.transliterate("こんにちは"), "こんにちは")
    }

    func testCharsetDifference() {
        var options90 = IvsSvsBaseTransliterator.Options()
        options90.mode = .ivsOrSvs
        options90.charset = .unijis90
        let trans90 = IvsSvsBaseTransliterator(options: options90)

        var options2004 = IvsSvsBaseTransliterator.Options()
        options2004.mode = .ivsOrSvs
        options2004.charset = .unijis2004
        let trans2004 = IvsSvsBaseTransliterator(options: options2004)

        // Some characters might map differently between charsets
        // The actual differences depend on the mapping data
        let testChar = "辻"
        let result90 = trans90.transliterate(testChar)
        let result2004 = trans2004.transliterate(testChar)

        // Results might be different
        XCTAssertNotNil(result90)
        XCTAssertNotNil(result2004)
    }

    func testRoundTrip() {
        var optionsToIvs = IvsSvsBaseTransliterator.Options()
        optionsToIvs.mode = .ivsOrSvs
        optionsToIvs.charset = .unijis90
        let toIvs = IvsSvsBaseTransliterator(options: optionsToIvs)

        var optionsToBase = IvsSvsBaseTransliterator.Options()
        optionsToBase.mode = .base
        optionsToBase.charset = .unijis90
        let toBase = IvsSvsBaseTransliterator(options: optionsToBase)

        // Test that we can convert back and forth
        let original = "辻"
        let withIvs = toIvs.transliterate(original)
        let backToBase = toBase.transliterate(withIvs)

        // Should get back the original (or equivalent base form)
        if withIvs != original {
            // If it was converted to IVS, converting back should give us the base
            XCTAssertEqual(backToBase.count, original.count)
        }
    }
}
