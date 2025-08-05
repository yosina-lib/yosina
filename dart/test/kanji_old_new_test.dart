import 'package:test/test.dart';
import 'package:yosina/yosina.dart';

void main() {
  group('KanjiOldNew', () {
    late Transliterator transliterator;

    setUp(() {
      transliterator = Transliterator.withList(['kanjiOldNew']);
    });

    group('Basic functionality without IVS', () {
      test('preserves kanji without IVS', () {
        final input = '檜';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('檜')); // No conversion without IVS
      });

      test('preserves multiple kanji without IVS', () {
        final input = '檜辻';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('檜辻')); // No conversion without IVS
      });

      test('preserves mixed content without IVS', () {
        final input = '新檜字';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('新檜字')); // No conversion without IVS
      });

      test('preserves sentence context without IVS', () {
        final input = '檜の木材を使用しています';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('檜の木材を使用しています')); // No conversion without IVS
      });

      test('no change for regular kanji', () {
        final input = '普通の漢字です';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('普通の漢字です'));
      });

      test('empty string', () {
        final input = '';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals(''));
      });

      test('mixed content with latin', () {
        final input = 'Hello 檜 World';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('Hello 檜 World')); // No conversion without IVS
      });

      test('preserve other characters', () {
        final input = '🎌檜🌸新🗾';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('🎌檜🌸新🗾')); // No conversion without IVS
      });

      test('hiragana and katakana preservation', () {
        final input = 'ひらがな檜カタカナ';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('ひらがな檜カタカナ')); // No conversion without IVS
      });

      test('numbers and punctuation', () {
        final input = '檜123！？';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('檜123！？')); // No conversion without IVS
      });
    });

    group('IVS (Ideographic Variation Selector) handling', () {
      test('kanji with IVS VS17', () {
        final input = '檜\u{E0100}';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('桧\u{E0100}'));
      });

      test('kanji with IVS VS18 to VS17', () {
        final input = '辻\u{E0101}';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('辻\u{E0100}'));
      });

      test('mixed content with IVS', () {
        final input = 'Hello 檜\u{E0100} World';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('Hello 桧\u{E0100} World'));
      });

      test('multiple kanji with IVS', () {
        final input = '檜\u{E0100}辻\u{E0101}';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('桧\u{E0100}辻\u{E0100}'));
      });

      test('sentence with IVS kanji', () {
        final input = '檜\u{E0100}の木は美しい';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('桧\u{E0100}の木は美しい'));
      });
    });

    group('Edge cases without IVS', () {
      test('kanji at string start without IVS', () {
        final input = '檜が好き';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('檜が好き')); // No conversion without IVS
      });

      test('kanji at string end without IVS', () {
        final input = 'これは檜';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('これは檜')); // No conversion without IVS
      });

      test('consecutive kanji without IVS', () {
        final input = '檜檜檜';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('檜檜檜')); // No conversion without IVS
      });

      test('kanji between non-cjk without IVS', () {
        final input = 'A檜B檜C';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('A檜B檜C')); // No conversion without IVS
      });

      test('newlines and whitespace without IVS', () {
        final input = '檜\n木\t材';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('檜\n木\t材')); // No conversion without IVS
      });

      test('unicode surrogates preservation without IVS', () {
        final input = '𝓗檜𝓮𝓵𝓵𝓸';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('𝓗檜𝓮𝓵𝓵𝓸')); // No conversion without IVS
      });

      test('mixed scripts without IVS', () {
        final input = 'English檜日本語카타나hiraganaひらがな';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result,
            equals('English檜日本語카타나hiraganaひらがな')); // No conversion without IVS
      });

      test('punctuation around kanji without IVS', () {
        final input = '(檜)、[檜]、「檜」';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('(檜)、[檜]、「檜」')); // No conversion without IVS
      });
    });

    group('Common old-new kanji conversions with IVS', () {
      test('converts 廣 to 広 with IVS', () {
        final input = '廣\u{E0100}島';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('広\u{E0100}島'));
      });

      test('converts 國 to 国 with IVS', () {
        final input = '國\u{E0100}語';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('国\u{E0100}語'));
      });

      test('converts multiple old kanji with IVS in a sentence', () {
        final input = '古い漢字：廣\u{E0100}島、檜\u{E0100}、國\u{E0100}';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('古い漢字：広\u{E0100}島、桧\u{E0100}、国\u{E0100}'));
      });

      test('preserves kanji without IVS', () {
        final input = '廣島、檜、國';
        final result =
            Chars.charsToString(transliterator(Chars.fromString(input)));
        expect(result, equals('廣島、檜、國')); // No conversion without IVS
      });
    });
  });
}
