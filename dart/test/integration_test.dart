import 'package:test/test.dart';
import 'package:yosina/yosina.dart';

void main() {
  group('Integration tests', () {
    test('processes mixed Japanese text correctly', () {
      // Create a string with various Japanese characters
      final text = 'こんにちは、世界！　カタカナもﾊﾝｶｸもあります。';
      final chars = Chars.fromString(text);

      // Test fullwidth to halfwidth conversion
      final halfwidth = Jisx0201AndAlikeTransliterator();
      final halfwidthResult = Chars.charsToString(halfwidth(chars));
      expect(halfwidthResult.contains('!'), isTrue); // ！ -> !
      expect(halfwidthResult.contains(' '), isTrue); // 　 -> space

      // Test composition
      final composition = HiraKataCompositionTransliterator(
        composeNonCombiningMarks: true,
      );
      final decomposed = Chars.fromString('か\u{3099}き\u{3099}く\u{3099}');
      final composed = Chars.charsToString(composition(decomposed));
      expect(composed, equals('がぎぐ'));
    });

    test('handles complex transliteration pipeline', () {
      // Start with mixed text
      final text = '旧字体と新字体、ひらがなとカタカナ、Full-widthとhalf-width。';
      final chars = Chars.fromString(text);

      // Apply old to new kanji conversion
      final kanjiNew = KanjiOldNewTransliterator();
      final step1 = kanjiNew(chars).toList();

      // Skip katakana conversion step
      final step2 = step1;

      // Convert to halfwidth
      final halfwidth = Jisx0201AndAlikeTransliterator(
        fullwidthToHalfwidth: true,
        convertGL: true,
        convertGR: true,
      );
      final step3 = halfwidth(step2).toList();

      final result = step3.map((c) => c.c).join();

      // Check some conversions
      expect(result.contains('Full-width'),
          isTrue); // Should be converted to halfwidth
      expect(result.contains('｡'), isTrue); // 。 -> ｡
    });

    test('preserves offset information through pipeline', () {
      final text = 'あいうえお';
      final chars = Chars.fromString(text);

      final halfwidth = Jisx0201AndAlikeTransliterator(
        convertHiraganas: true,
      );

      // Convert directly to halfwidth
      final result = halfwidth(chars).toList();
      expect(result[0].c, equals('\u{FF71}')); // ｱ
      expect(result[0].offset, equals(0));
    });

    test('handles edge cases correctly', () {
      // Empty string
      var chars = Chars.fromString('');
      var result = Chars.charsToString(Jisx0201AndAlikeTransliterator()(chars));
      expect(result, equals(''));

      // Only ASCII
      chars = Chars.fromString('Hello, World!');
      result = Chars.charsToString(Jisx0201AndAlikeTransliterator()(chars));
      expect(result, equals('Hello, World!'));
    });

    test('option combinations work correctly', () {
      final text = 'ハローワールド';
      final chars = Chars.fromString(text);

      // Test different Jisx0201 options
      var transliterator = Jisx0201AndAlikeTransliterator(
        fullwidthToHalfwidth: true,
        convertGL: true,
        convertGR: true,
      );
      var result = Chars.charsToString(transliterator(chars));
      expect(result, equals('ﾊﾛｰﾜｰﾙﾄﾞ'));

      // Test with convertGR disabled
      transliterator = Jisx0201AndAlikeTransliterator(
        fullwidthToHalfwidth: true,
        convertGL: true,
        convertGR: false,
      );
      result = Chars.charsToString(transliterator(chars));
      expect(result, equals('ハローワールド')); // Should not convert katakana

      // Test halfwidth to fullwidth with voice mark combination
      final halfwidthVoiced = 'ｶﾞｷﾞｸﾞ';
      final halfwidthChars = Chars.fromString(halfwidthVoiced);
      transliterator = Jisx0201AndAlikeTransliterator(
        fullwidthToHalfwidth: false,
        combineVoicedSoundMarks: true,
      );
      result = Chars.charsToString(transliterator(halfwidthChars));
      expect(result, equals('ガギグ'));
    });

    test('all transliterators handle null/empty correctly', () {
      final empty = <Char>[];

      expect(KanjiOldNewTransliterator()(empty).toList(), isEmpty);
      expect(Jisx0201AndAlikeTransliterator()(empty).toList(), isEmpty);
      expect(HiraKataCompositionTransliterator()(empty).toList(), isEmpty);
      expect(IvsSvsBaseTransliterator()(empty).toList(), isEmpty);
    });
  });
}
