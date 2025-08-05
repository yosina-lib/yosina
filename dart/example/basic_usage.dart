// Basic usage example for Yosina Dart library.
// This example demonstrates the fundamental transliteration functionality
// as shown in the README documentation.

import 'package:yosina/yosina.dart';

void main() {
  print('=== Yosina Dart Basic Usage Example ===\n');

  // Create a recipe with desired transformations (matching README example)
  final recipe = TransliterationRecipe(
    kanjiOldNew: true,
    replaceSpaces: true,
    replaceSuspiciousHyphensToProlongedSoundMarks: true,
    replaceCircledOrSquaredCharacters:
        ReplaceCircledOrSquaredCharactersOptions.enabled(),
    replaceCombinedCharacters: true,
    replaceJapaneseIterationMarks: true, // Expand iteration marks
    toFullwidth: ToFullwidthOptions.enabled(),
  );

  // Create the transliterator (uses default registry)
  final transliterator = Transliterator.withRecipe(recipe);

  // Use it with various special characters (matching README example)
  const input =
      '①②③　ⒶⒷⒸ　㍿㍑㌠㋿'; // circled numbers, letters, space, combined characters
  final inputChars = Chars.fromString(input);
  final resultChars = transliterator(inputChars);
  final result = Chars.charsToString(resultChars);

  print('Input:  $input');
  print('Output: $result');
  print('Expected: （１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和');

  // Convert old kanji to new
  print('\n--- Old Kanji to New ---');
  const oldKanji = '舊字體';
  final kanjiResult =
      Chars.charsToString(transliterator(Chars.fromString(oldKanji)));
  print('Input:  $oldKanji');
  print('Output: $kanjiResult');
  print('Expected: 旧字体');

  // Convert half-width katakana to full-width
  print('\n--- Half-width to Full-width ---');
  const halfWidth = 'ﾃｽﾄﾓｼﾞﾚﾂ';
  final fullWidthResult =
      Chars.charsToString(transliterator(Chars.fromString(halfWidth)));
  print('Input:  $halfWidth');
  print('Output: $fullWidthResult');
  print('Expected: テストモジレツ');

  // Demonstrate Japanese iteration marks expansion
  print('\n--- Japanese Iteration Marks Examples ---');
  const iterationExamples = [
    '佐々木', // kanji iteration
    'すゝき', // hiragana iteration
    'いすゞ', // hiragana voiced iteration
    'サヽキ', // katakana iteration
    'ミスヾ', // katakana voiced iteration
  ];

  for (final text in iterationExamples) {
    final result = Chars.charsToString(transliterator(Chars.fromString(text)));
    print('$text → $result');
  }

  // Demonstrate hiragana to katakana conversion separately
  print('\n--- Hiragana to Katakana Conversion ---');
  // Create a separate recipe for just hiragana to katakana conversion
  final hiraKataRecipe = TransliterationRecipe(
    hiraKata: 'hira-to-kata', // Convert hiragana to katakana
  );

  final hiraKataTransliterator = Transliterator.withRecipe(hiraKataRecipe);

  const hiraKataExamples = [
    'ひらがな', // pure hiragana
    'これはひらがなです', // hiragana sentence
    'ひらがなとカタカナ', // mixed hiragana and katakana
  ];

  for (final text in hiraKataExamples) {
    final result =
        Chars.charsToString(hiraKataTransliterator(Chars.fromString(text)));
    print('$text → $result');
  }

  // Also demonstrate katakana to hiragana conversion
  print('\n--- Katakana to Hiragana Conversion ---');
  final kataHiraRecipe = TransliterationRecipe(
    hiraKata: 'kata-to-hira', // Convert katakana to hiragana
  );

  final kataHiraTransliterator = Transliterator.withRecipe(kataHiraRecipe);

  const kataHiraExamples = [
    'カタカナ', // pure katakana
    'コレハカタカナデス', // katakana sentence
    'カタカナとひらがな', // mixed katakana and hiragana
  ];

  for (final text in kataHiraExamples) {
    final result =
        Chars.charsToString(kataHiraTransliterator(Chars.fromString(text)));
    print('$text → $result');
  }
}
