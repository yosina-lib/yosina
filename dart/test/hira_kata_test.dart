import 'package:test/test.dart';
import 'package:yosina/yosina.dart';

void main() {
  group('HiraKataTransliterator', () {
    group('Hira to Kata', () {
      test('basic hiragana to katakana', () {
        final transliterator = HiraKataTransliterator(mode: 'hira-to-kata');

        expect(
          Chars.charsToString(transliterator(Chars.fromString('あいうえお'))),
          'アイウエオ',
        );
        expect(
          Chars.charsToString(transliterator(Chars.fromString('がぎぐげご'))),
          'ガギグゲゴ',
        );
        expect(
          Chars.charsToString(transliterator(Chars.fromString('ぱぴぷぺぽ'))),
          'パピプペポ',
        );
      });

      test('small hiragana to katakana', () {
        final transliterator = HiraKataTransliterator(mode: 'hira-to-kata');

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ぁぃぅぇぉっゃゅょ'))),
          'ァィゥェォッャュョ',
        );
        expect(
          Chars.charsToString(transliterator(Chars.fromString('ゎゕゖ'))),
          'ヮヵヶ',
        );
      });

      test('mixed text with numbers and latin', () {
        final transliterator = HiraKataTransliterator(mode: 'hira-to-kata');

        expect(
          Chars.charsToString(
              transliterator(Chars.fromString('あいうえお123ABCアイウエオ'))),
          'アイウエオ123ABCアイウエオ',
        );
        expect(
          Chars.charsToString(transliterator(Chars.fromString('こんにちは、世界！'))),
          'コンニチハ、世界！',
        );
      });

      test('all hiragana characters', () {
        final transliterator = HiraKataTransliterator(mode: 'hira-to-kata');

        final input =
            'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゔ';
        final expected =
            'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴ';

        expect(
          Chars.charsToString(transliterator(Chars.fromString(input))),
          expected,
        );
      });

      test('wi and we characters', () {
        final transliterator = HiraKataTransliterator(mode: 'hira-to-kata');

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ゐゑ'))),
          'ヰヱ',
        );
      });
    });

    group('Kata to Hira', () {
      test('basic katakana to hiragana', () {
        final transliterator = HiraKataTransliterator(mode: 'kata-to-hira');

        expect(
          Chars.charsToString(transliterator(Chars.fromString('アイウエオ'))),
          'あいうえお',
        );
        expect(
          Chars.charsToString(transliterator(Chars.fromString('ガギグゲゴ'))),
          'がぎぐげご',
        );
        expect(
          Chars.charsToString(transliterator(Chars.fromString('パピプペポ'))),
          'ぱぴぷぺぽ',
        );
      });

      test('small katakana to hiragana', () {
        final transliterator = HiraKataTransliterator(mode: 'kata-to-hira');

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ァィゥェォッャュョ'))),
          'ぁぃぅぇぉっゃゅょ',
        );
        expect(
          Chars.charsToString(transliterator(Chars.fromString('ヮヵヶ'))),
          'ゎゕゖ',
        );
      });

      test('mixed text with numbers and latin', () {
        final transliterator = HiraKataTransliterator(mode: 'kata-to-hira');

        expect(
          Chars.charsToString(
              transliterator(Chars.fromString('アイウエオ123ABCあいうえお'))),
          'あいうえお123ABCあいうえお',
        );
        expect(
          Chars.charsToString(transliterator(Chars.fromString('コンニチハ、世界！'))),
          'こんにちは、世界！',
        );
      });

      test('vu character', () {
        final transliterator = HiraKataTransliterator(mode: 'kata-to-hira');

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ヴ'))),
          'ゔ',
        );
      });

      test('special katakana without hiragana equivalents', () {
        final transliterator = HiraKataTransliterator(mode: 'kata-to-hira');

        // Special katakana without hiragana equivalents should remain unchanged
        expect(
          Chars.charsToString(transliterator(Chars.fromString('ヷヸヹヺ'))),
          'ヷヸヹヺ',
        );
      });

      test('all katakana characters', () {
        final transliterator = HiraKataTransliterator(mode: 'kata-to-hira');

        final input =
            'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴ';
        final expected =
            'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゔ';

        expect(
          Chars.charsToString(transliterator(Chars.fromString(input))),
          expected,
        );
      });

      test('wi and we characters', () {
        final transliterator = HiraKataTransliterator(mode: 'kata-to-hira');

        expect(
          Chars.charsToString(transliterator(Chars.fromString('ヰヱ'))),
          'ゐゑ',
        );
      });
    });

    test('default mode is hira-to-kata', () {
      final transliterator = HiraKataTransliterator();

      expect(
        Chars.charsToString(transliterator(Chars.fromString('あいうえお'))),
        'アイウエオ',
      );
    });

    test('caching behavior', () {
      // First transliterator builds the cache
      final transliterator1 = HiraKataTransliterator(mode: 'hira-to-kata');
      expect(
        Chars.charsToString(transliterator1(Chars.fromString('あいうえお'))),
        'アイウエオ',
      );

      // Second transliterator should use cached table
      final transliterator2 = HiraKataTransliterator(mode: 'hira-to-kata');
      expect(
        Chars.charsToString(transliterator2(Chars.fromString('かきくけこ'))),
        'カキクケコ',
      );

      // Test kata to hira mode caching
      final transliterator3 = HiraKataTransliterator(mode: 'kata-to-hira');
      expect(
        Chars.charsToString(transliterator3(Chars.fromString('アイウエオ'))),
        'あいうえお',
      );
    });

    test('registry integration', () {
      final registry = TransliteratorRegistry.defaultRegistry;
      final transliterator =
          registry.create('hiraKata', {'mode': 'hira-to-kata'});

      expect(
        Chars.charsToString(transliterator(Chars.fromString('あいうえお'))),
        'アイウエオ',
      );
    });
  });
}
