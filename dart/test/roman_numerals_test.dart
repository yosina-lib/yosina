import 'package:test/test.dart';
import 'package:yosina/src/chars.dart';
import 'package:yosina/src/transliterators/roman_numerals_transliterator.dart';

void main() {
  group('RomanNumeralsTransliterator', () {
    late RomanNumeralsTransliterator transliterator;

    setUp(() {
      transliterator = const RomanNumeralsTransliterator();
    });

    test('converts uppercase Roman numerals to ASCII', () {
      final testCases = [
        ['Ⅰ', 'I'],
        ['Ⅱ', 'II'],
        ['Ⅲ', 'III'],
        ['Ⅳ', 'IV'],
        ['Ⅴ', 'V'],
        ['Ⅵ', 'VI'],
        ['Ⅶ', 'VII'],
        ['Ⅷ', 'VIII'],
        ['Ⅸ', 'IX'],
        ['Ⅹ', 'X'],
        ['Ⅺ', 'XI'],
        ['Ⅻ', 'XII'],
        ['Ⅼ', 'L'],
        ['Ⅽ', 'C'],
        ['Ⅾ', 'D'],
        ['Ⅿ', 'M'],
      ];

      for (final testCase in testCases) {
        final input = Chars.fromString(testCase[0]);
        final output = transliterator(input);
        final result = Chars.charsToString(output);
        expect(result, testCase[1],
            reason: 'Converting ${testCase[0]} to ${testCase[1]}');
      }
    });

    test('converts lowercase Roman numerals to ASCII', () {
      final testCases = [
        ['ⅰ', 'i'],
        ['ⅱ', 'ii'],
        ['ⅲ', 'iii'],
        ['ⅳ', 'iv'],
        ['ⅴ', 'v'],
        ['ⅵ', 'vi'],
        ['ⅶ', 'vii'],
        ['ⅷ', 'viii'],
        ['ⅸ', 'ix'],
        ['ⅹ', 'x'],
        ['ⅺ', 'xi'],
        ['ⅻ', 'xii'],
        ['ⅼ', 'l'],
        ['ⅽ', 'c'],
        ['ⅾ', 'd'],
        ['ⅿ', 'm'],
      ];

      for (final testCase in testCases) {
        final input = Chars.fromString(testCase[0]);
        final output = transliterator(input);
        final result = Chars.charsToString(output);
        expect(result, testCase[1],
            reason: 'Converting ${testCase[0]} to ${testCase[1]}');
      }
    });

    test('handles mixed text with Roman numerals', () {
      final testCases = [
        ['Year Ⅻ', 'Year XII'],
        ['Chapter ⅳ', 'Chapter iv'],
        ['Section Ⅲ.A', 'Section III.A'],
        ['Ⅰ Ⅱ Ⅲ', 'I II III'],
        ['ⅰ, ⅱ, ⅲ', 'i, ii, iii'],
      ];

      for (final testCase in testCases) {
        final input = Chars.fromString(testCase[0]);
        final output = transliterator(input);
        final result = Chars.charsToString(output);
        expect(result, testCase[1],
            reason: 'Converting "${testCase[0]}" to "${testCase[1]}"');
      }
    });

    test('handles edge cases', () {
      final testCases = [
        ['', ''],
        ['ABC123', 'ABC123'],
        ['ⅠⅡⅢ', 'IIIIII'],
      ];

      for (final testCase in testCases) {
        final input = Chars.fromString(testCase[0]);
        final output = transliterator(input);
        final result = Chars.charsToString(output);
        expect(result, testCase[1],
            reason: 'Converting "${testCase[0]}" to "${testCase[1]}"');
      }
    });
  });
}
