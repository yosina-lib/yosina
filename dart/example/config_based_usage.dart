// Configuration-based usage example for Yosina Dart library.
// This example demonstrates using direct transliterator configurations.

import 'package:yosina/yosina.dart';

void main() {
  print('=== Yosina Dart Configuration-based Usage Example ===\n');

  // Create transliterator with direct configurations (uses default registry)
  final transliterator = Transliterator.withMap([
    {'name': 'spaces'},
    {
      'name': 'prolongedSoundMarks',
      'options': {
        'replaceProlongedMarksFollowingAlnums': true,
      },
    },
    {'name': 'jisx0201AndAlike'},
  ]);

  print('--- Configuration-based Transliteration ---');

  // Test cases demonstrating different transformations
  final testCases = [
    ('hello　world', 'Space normalization'),
    ('カタカナーテスト', 'Prolonged sound mark handling'),
    ('ＡＢＣ１２３', 'Full-width conversion'),
    ('ﾊﾝｶｸ ｶﾀｶﾅ', 'Half-width katakana conversion'),
  ];

  for (final (testText, description) in testCases) {
    final result =
        Chars.charsToString(transliterator(Chars.fromString(testText)));
    print('$description:');
    print('  Input:  \'$testText\'');
    print('  Output: \'$result\'');
    print('');
  }

  // Demonstrate individual transliterators
  print('--- Individual Transliterator Examples ---');

  // Spaces only
  final spacesOnly = Transliterator.withList(['spaces']);
  const spaceTest = 'hello　world　test'; // ideographic spaces
  print(
      'Spaces only: \'$spaceTest\' → \'${Chars.charsToString(spacesOnly(Chars.fromString(spaceTest)))}\'');

  // Kanji old-new only
  final kanjiOnly = Transliterator.withMap([
    {
      'name': 'ivsSvsBase',
      'options': {
        'mode': 'ivs-svs',
        'charset': Charset.unijis2004,
      },
    },
    {'name': 'kanjiOldNew'},
    {
      'name': 'ivsSvsBase',
      'options': {
        'mode': 'base',
        'charset': Charset.unijis2004,
      },
    },
  ]);
  const kanjiTest = '廣島檜';
  print(
      'Kanji only: \'$kanjiTest\' → \'${Chars.charsToString(kanjiOnly(Chars.fromString(kanjiTest)))}\'');

  // JIS X 0201 conversion only
  final jisx0201Only = Transliterator.withMap([
    {
      'name': 'jisx0201AndAlike',
      'options': {
        'fullwidthToHalfwidth': false,
      },
    },
  ]);
  const jisxTest = 'ﾊﾛｰ ﾜｰﾙﾄﾞ';
  print(
      'JIS X 0201 only: \'$jisxTest\' → \'${Chars.charsToString(jisx0201Only(Chars.fromString(jisxTest)))}\'');
}
