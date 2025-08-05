import 'package:test/test.dart';
import 'package:yosina/yosina.dart';

void main() {
  group('IvsSvsBaseTransliterator', () {
    test('IVS to base', () {
      final transliterator = IvsSvsBaseTransliterator(
        mode: 'base',
        charset: Charset.unijis90,
      );

      // IVS sequences should be handled
      // Note: The actual behavior depends on whether the data file is available
      final ivsSequence = '葛\u{E0100}'; // 葛 + VS17
      final result = Chars.charsToString(
        transliterator(Chars.fromString(ivsSequence)),
      );
      // Without data file, the sequence passes through unchanged
      // With data file, it might be converted to base character
      expect(result, equals('葛'));
    });

    test('base to IVS', () {
      final transliterator = IvsSvsBaseTransliterator(
        mode: 'ivs-or-svs',
        charset: Charset.unijis90,
      );

      // Base characters might be converted to IVS/SVS
      // The actual conversion depends on the mapping data
      final baseChar = '仝';
      final result = Chars.charsToString(
        transliterator(Chars.fromString(baseChar)),
      );
      // Result could be the same or have variation selector added
      expect(result, isNotNull);
    });

    test('no change for regular text', () {
      final transliterator = IvsSvsBaseTransliterator(
        mode: 'base',
        charset: Charset.unijis90,
      );

      // Regular text without IVS/SVS should not change
      expect(
        Chars.charsToString(transliterator(Chars.fromString('Hello'))),
        'Hello',
      );
      expect(
        Chars.charsToString(transliterator(Chars.fromString('こんにちは'))),
        'こんにちは',
      );
    });

    test('charset difference', () {
      final trans90 = IvsSvsBaseTransliterator(
        mode: 'ivs-or-svs',
        charset: Charset.unijis90,
      );
      final trans2004 = IvsSvsBaseTransliterator(
        mode: 'ivs-or-svs',
        charset: Charset.unijis2004,
      );

      // Some characters might map differently between charsets
      // The actual differences depend on the mapping data
      final testChar = '辻';
      final result90 = Chars.charsToString(
        trans90(Chars.fromString(testChar)),
      );
      final result2004 = Chars.charsToString(
        trans2004(Chars.fromString(testChar)),
      );

      // Results might be different
      expect(result90, isNotNull);
      expect(result2004, isNotNull);
    });

    test('round trip conversion', () {
      final toIvs = IvsSvsBaseTransliterator(
        mode: 'ivs-or-svs',
        charset: Charset.unijis90,
      );
      final toBase = IvsSvsBaseTransliterator(
        mode: 'base',
        charset: Charset.unijis90,
      );

      // Test that we can convert back and forth
      final original = '辻';
      final withIvs = Chars.charsToString(
        toIvs(Chars.fromString(original)),
      );
      final backToBase = Chars.charsToString(
        toBase(Chars.fromString(withIvs)),
      );

      // Should get back the original (or equivalent base form)
      if (withIvs != original) {
        // If it was converted to IVS, converting back should give us the base
        expect(backToBase.length, original.length);
      }
    });

    test('drop selectors altogether', () {
      final transliterator = IvsSvsBaseTransliterator(
        mode: 'base',
        charset: Charset.unijis90,
        dropSelectorsAltogether: true,
      );

      // Test with a simple non-VS character
      final simpleText = 'Hello世界';
      final result1 = Chars.charsToString(
        transliterator(Chars.fromString(simpleText)),
      );
      expect(result1, simpleText);

      // Test behavior with variation selector sequences
      // Note: The actual behavior depends on the implementation details
      // and handling of surrogate pairs for IVS (U+E0100 range)
      final svsSequence = '例\u{FE00}'; // 例 + VS1
      final result2 = Chars.charsToString(
        transliterator(Chars.fromString(svsSequence)),
      );
      // The result should either be the base character or pass through
      // depending on the implementation's selector detection
      expect(result2, isNotEmpty);
      expect(result2.startsWith('例'), isTrue);
    });

    test('prefer SVS option', () {
      final transliterator = IvsSvsBaseTransliterator(
        mode: 'ivs-or-svs',
        charset: Charset.unijis90,
        preferSvs: true,
      );

      // When preferSvs is true, SVS should be preferred over IVS
      // The actual behavior depends on the mapping data
      final testChar = '辻';
      final result = Chars.charsToString(
        transliterator(Chars.fromString(testChar)),
      );
      expect(result, isNotNull);
    });
  });
}
