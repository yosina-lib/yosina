# Yosina Dart

A Dart port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  yosina: ^0.1.0
```

Then run:

```bash
dart pub get
```

## Usage

```dart
import 'package:yosina/yosina.dart';

// Create a recipe with desired transformations
final recipe = TransliterationRecipe(
  kanjiOldNew: true,
  replaceSpaces: true,
  replaceSuspiciousHyphensToProlongedSoundMarks: true,
  replaceCircledOrSquaredCharacters: ReplaceCircledOrSquaredCharactersOptions.enabled(),
  replaceCombinedCharacters: true,
  toFullwidth: ToFullwidthOptions.enabled(),
);

// Create the transliterator (uses default registry)
final transliterator = Transliterator.withRecipe(recipe);

// Use it with various special characters
final input = '①②③　ⒶⒷⒸ　㍿㍑㌠㋿'; // circled numbers, letters, space, combined characters
final inputChars = Chars.fromString(input);
final resultChars = transliterator(inputChars);
final result = Chars.charsToString(resultChars);
print(result); // "(1)(2)(3) (A)(B)(C) 株式会社リットルサンチーム令和"

// Convert old kanji to new
final oldKanji = '舊字體';
final kanjiResult = Chars.charsToString(transliterator(Chars.fromString(oldKanji)));
print(kanjiResult); // "旧字体"

// Convert half-width katakana to full-width
final halfWidth = 'ﾃｽﾄﾓｼﾞﾚﾂ';
final fullWidthResult = Chars.charsToString(transliterator(Chars.fromString(halfWidth)));
print(fullWidthResult); // "テストモジレツ"
```

### Using Direct Configuration

```dart
import 'package:yosina/yosina.dart';

// Using a list of transliterator names
final transliterator1 = Transliterator.withList(['spaces', 'kanjiOldNew']);

// Using configuration maps with options
final transliterator2 = Transliterator.withMap([
  {'name': 'spaces'},
  {
    'name': 'prolongedSoundMarks',
    'options': {
      'replaceProlongedMarksFollowingAlnums': true,
    },
  },
  {'name': 'circledOrSquared'},
  {'name': 'combined'},
]);

// Use the transliterator
final input = Chars.fromString('some japanese text');
final result = Chars.charsToString(transliterator2(input));
```

## Available Transliterators

### 1. **Circled or Squared** (`circledOrSquared`)
Converts circled or squared characters to their plain equivalents.
- Options: `templates` (custom rendering), `includeEmojis` (include emoji characters)
- Example: `①②③` → `(1)(2)(3)`, `㊙㊗` → `(秘)(祝)`

### 2. **Combined** (`combined`)
Expands combined characters into their individual character sequences.
- Example: `㍻` (Heisei era) → `平成`, `㈱` → `(株)`

### 3. **Hiragana-Katakana Composition** (`hiraKataComposition`)
Combines decomposed hiraganas and katakanas into composed equivalents.
- Options: `composeNonCombiningMarks` (compose non-combining marks)
- Example: `か + ゙` → `が`, `ヘ + ゜` → `ペ`

### 4. **Hiragana-Katakana** (`hiraKata`)
Converts between hiragana and katakana scripts bidirectionally.
- Options: `mode` ("hira-to-kata" or "kata-to-hira")
- Example: `ひらがな` → `ヒラガナ` (hira-to-kata)

### 5. **Hyphens** (`hyphens`)
Replaces various dash/hyphen symbols with common ones used in Japanese.
- Options: `precedence` (mapping priority order)
- Available mappings: "ascii", "jisx0201", "jisx0208_90", "jisx0208_90_windows", "jisx0208_verbatim"
- Example: `2019—2020` (em dash) → `2019-2020`

### 6. **Ideographic Annotations** (`ideographicAnnotations`)
Replaces ideographic annotations used in traditional Chinese-to-Japanese translation.
- Example: `㆖㆘` → `上下`

### 7. **IVS-SVS Base** (`ivsSvsBase`)
Handles Ideographic and Standardized Variation Selectors.
- Options: `charset`, `mode` ("ivs-or-svs" or "base"), `preferSVS`, `dropSelectorsAltogether`
- Example: `葛󠄀` (葛 + IVS) → `葛`

### 8. **Japanese Iteration Marks** (`japaneseIterationMarks`)
Expands iteration marks by repeating the preceding character.
- Example: `時々` → `時時`, `いすゞ` → `いすず`

### 9. **JIS X 0201 and Alike** (`jisX0201AndAlike`)
Handles half-width/full-width character conversion.
- Options: `fullwidthToHalfwidth`, `convertGL` (alphanumerics/symbols), `convertGR` (katakana), `u005cAsYenSign`
- Example: `ABC123` → `ＡＢＣ１２３`, `ｶﾀｶﾅ` → `カタカナ`

### 10. **Kanji Old-New** (`kanjiOldNew`)
Converts old-style kanji (旧字体) to modern forms (新字体).
- Example: `舊字體の變換` → `旧字体の変換`

### 11. **Mathematical Alphanumerics** (`mathematicalAlphanumerics`)
Normalizes mathematical alphanumeric symbols to plain ASCII.
- Example: `𝐀𝐁𝐂` (mathematical bold) → `ABC`

### 12. **Prolonged Sound Marks** (`prolongedSoundMarks`)
Handles contextual conversion between hyphens and prolonged sound marks.
- Options: `skipAlreadyTransliteratedChars`, `allowProlongedHatsuon`, `allowProlongedSokuon`, `replaceProlongedMarksFollowingAlnums`
- Example: `イ−ハト−ヴォ` (with hyphen) → `イーハトーヴォ` (prolonged mark)

### 13. **Radicals** (`radicals`)
Converts CJK radical characters to their corresponding ideographs.
- Example: `⾔⾨⾷` (Kangxi radicals) → `言門食`

### 14. **Spaces** (`spaces`)
Normalizes various Unicode space characters to standard ASCII space.
- Example: `A　B` (ideographic space) → `A B`

## Development

### Running Tests

```bash
# Run all tests
dart test

# Run a specific test file
dart test test/transliterators_test.dart

# Run with coverage
dart test --coverage=coverage
```

### Code Generation

Some transliterators are generated from data files:

```bash
cd codegen
dart run generate.dart
```

This generates transliterators from the JSON data files in the `../data` directory.

## Requirements

- Dart SDK: >=2.19.0 <4.0.0

## License

MIT