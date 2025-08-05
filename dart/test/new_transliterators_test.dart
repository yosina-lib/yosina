import 'package:test/test.dart';
import 'package:yosina/yosina.dart';

void main() {
  group('HiraKataCompositionTransliterator', () {
    late HiraKataCompositionTransliterator transliterator;

    setUp(() {
      transliterator = HiraKataCompositionTransliterator();
    });

    test('composes hiragana with dakuten', () {
      final input = Chars.fromString('か\u{3099}き\u{3099}く\u{3099}');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'がぎぐ');
    });

    test('composes hiragana with handakuten', () {
      final input = Chars.fromString('は\u{309a}ひ\u{309a}ふ\u{309a}');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'ぱぴぷ');
    });

    test('composes katakana with dakuten', () {
      final input = Chars.fromString('カ\u{3099}キ\u{3099}ク\u{3099}');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'ガギグ');
    });

    test('leaves non-composable characters unchanged', () {
      final input = Chars.fromString('あいうえお');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'あいうえお');
    });
  });

  group('Jisx0201AndAlikeTransliterator', () {
    test('converts fullwidth to halfwidth', () {
      final transliterator = Jisx0201AndAlikeTransliterator();
      final input = Chars.fromString('ＡＢＣ１２３');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'ABC123');
    });

    test('converts fullwidth katakana to halfwidth', () {
      final transliterator = Jisx0201AndAlikeTransliterator();
      final input = Chars.fromString('アイウエオ');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'ｱｲｳｴｵ');
    });

    test('decomposes voiced katakana', () {
      final transliterator = Jisx0201AndAlikeTransliterator();
      final input = Chars.fromString('ガギグゲゴ');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'ｶﾞｷﾞｸﾞｹﾞｺﾞ');
    });

    test('converts halfwidth to fullwidth with fullwidthToHalfwidth false', () {
      final transliterator = Jisx0201AndAlikeTransliterator(
        fullwidthToHalfwidth: false,
      );
      final input = Chars.fromString('ABC123');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'ＡＢＣ１２３');
    });

    test('converts halfwidth katakana to fullwidth', () {
      final transliterator = Jisx0201AndAlikeTransliterator(
        fullwidthToHalfwidth: false,
      );
      final input = Chars.fromString('ｱｲｳｴｵ');
      final output = transliterator(input);
      final result = Chars.charsToString(output);
      expect(result, 'アイウエオ');
    });
  });
}
