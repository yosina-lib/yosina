# Yosina PHP

A PHP port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Usage

```php
<?php

use Yosina\TransliterationRecipe;
use Yosina\Yosina;

// Create a recipe with multiple transformations
$recipe = new TransliterationRecipe(
    replaceSpaces: true,
    replaceCircledOrSquaredCharacters: true,
    replaceCombinedCharacters: true,
    kanjiOldNew: true,
    toFullwidth: true
);

$transliterator = Yosina::makeTransliterator($recipe);

// Use it with various special characters
$input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"; // circled numbers, letters, ideographic space, combined characters
$result = $transliterator($input);
echo $result; // "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

// Convert old kanji to new
$oldKanji = "舊字體";
$result = $transliterator($oldKanji);
echo $result; // "旧字体"

// Convert half-width katakana to full-width
$halfWidth = "ﾃｽﾄﾓｼﾞﾚﾂ";
$result = $transliterator($halfWidth);
echo $result; // "テストモジレツ"
```

### Advanced Configuration

```php
<?php

use Yosina\Yosina;

// Chain multiple transliterators
$transliterator = Yosina::makeTransliterator([
    ['kanji-old-new', []],
    ['spaces', []],
    ['radicals', []],
]);

$result = $transliterator($inputText);
```

## Requirements

- PHP 8.2 or higher

## Installation

```bash
composer require yosina-lib/yosina
```

## Available Transliterators

### 1. **Circled or Squared** (`circled-or-squared`)
Converts circled or squared characters to their plain equivalents.
- Options: `templates` (custom rendering), `includeEmojis` (include emoji characters)
- Example: `①②③` → `(1)(2)(3)`, `㊙㊗` → `(秘)(祝)`

### 2. **Combined** (`combined`)
Expands combined characters into their individual character sequences.
- Example: `㍻` (Heisei era) → `平成`, `㈱` → `(株)`

### 3. **Hiragana-Katakana Composition** (`hira-kata-composition`)
Combines decomposed hiraganas and katakanas into composed equivalents.
- Options: `composeNonCombiningMarks` (compose non-combining marks)
- Example: `か + ゙` → `が`, `ヘ + ゜` → `ペ`

### 4. **Hiragana-Katakana** (`hira-kata`)
Converts between hiragana and katakana scripts bidirectionally.
- Options: `mode` ("hira-to-kata" or "kata-to-hira")
- Example: `ひらがな` → `ヒラガナ` (hira-to-kata)

### 5. **Hyphens** (`hyphens`)
Replaces various dash/hyphen symbols with common ones used in Japanese.
- Options: `precedence` (mapping priority order)
- Available mappings: "ascii", "jisx0201", "jisx0208_90", "jisx0208_90_windows", "jisx0208_verbatim"
- Example: `2019—2020` (em dash) → `2019-2020`

### 6. **Ideographic Annotations** (`ideographic-annotations`)
Replaces ideographic annotations used in traditional Chinese-to-Japanese translation.
- Example: `㆖㆘` → `上下`

### 7. **IVS-SVS Base** (`ivs-svs-base`)
Handles Ideographic and Standardized Variation Selectors.
- Options: `charset`, `mode` ("ivs-or-svs" or "base"), `preferSVS`, `dropSelectorsAltogether`
- Example: `葛󠄀` (葛 + IVS) → `葛`

### 8. **Japanese Iteration Marks** (`japanese-iteration-marks`)
Expands iteration marks by repeating the preceding character.
- Example: `時々` → `時時`, `いすゞ` → `いすず`

### 9. **JIS X 0201 and Alike** (`jisx0201-and-alike`)
Handles half-width/full-width character conversion.
- Options: `fullwidthToHalfwidth`, `convertGL` (alphanumerics/symbols), `convertGR` (katakana), `u005cAsYenSign`
- Example: `ABC123` → `ＡＢＣ１２３`, `ｶﾀｶﾅ` → `カタカナ`

### 10. **Kanji Old-New** (`kanji-old-new`)
Converts old-style kanji (旧字体) to modern forms (新字体).
- Example: `舊字體の變換` → `旧字体の変換`

### 11. **Mathematical Alphanumerics** (`mathematical-alphanumerics`)
Normalizes mathematical alphanumeric symbols to plain ASCII.
- Example: `𝐀𝐁𝐂` (mathematical bold) → `ABC`

### 12. **Prolonged Sound Marks** (`prolonged-sound-marks`)
Handles contextual conversion between hyphens and prolonged sound marks.
- Options: `skipAlreadyTransliteratedChars`, `allowProlongedHatsuon`, `allowProlongedSokuon`, `replaceProlongedMarksFollowingAlnums`
- Example: `イ−ハト−ヴォ` (with hyphen) → `イーハトーヴォ` (prolonged mark)

### 13. **Radicals** (`radicals`)
Converts CJK radical characters to their corresponding ideographs.
- Example: `⾔⾨⾷` (Kangxi radicals) → `言門食`

### 14. **Spaces** (`spaces`)
Normalizes various Unicode space characters to standard ASCII space.
- Example: `A　B` (ideographic space) → `A B`

### 15. **Roman Numerals** (`roman-numerals`)
Converts Unicode Roman numeral characters to their ASCII letter equivalents.
- Example: `Ⅰ Ⅱ Ⅲ` → `I II III`, `ⅰ ⅱ ⅲ` → `i ii iii`

### 16. **Small Hirakatas** (`small-hirakatas`)
Converts small hiragana and katakana characters to their ordinary-sized equivalents.
- Example: `ぁぃぅ` → `あいう`, `ァィゥ` → `アイウ`

### 17. **Archaic Hirakatas** (`archaic-hirakatas`)
Converts archaic kana (hentaigana) to their modern hiragana or katakana equivalents.
- Example: `𛀁` → `え`

### 18. **Historical Hirakatas** (`historical-hirakatas`)
Converts historical hiragana and katakana characters to their modern equivalents.
- Options: `hiraganas` ("simple", "decompose", or "skip"), `katakanas` ("simple", "decompose", or "skip"), `voicedKatakanas` ("decompose" or "skip")
- Example: `ゐ` → `い` (simple), `ゐ` → `うぃ` (decompose), `ヰ` → `イ` (simple)

## Development

### Prerequisites

- PHP 7.4 or higher
- Composer (PHP dependency manager)

### Setup

Install the development dependencies:

```bash
composer install
```

### Code Generation

The transliterator implementations are generated from the shared data files:

```bash
php codegen/generate.php
```

This generates transliterator classes from the JSON data files in the `../data/` directory.

### Testing

Run the basic tests:

```bash
php tests/BasicTest.php
```

### Development Workflow

1. Make changes to the code or data files
2. If you modified data files, regenerate the transliterators:
   ```bash
   php codegen/generate.php
   ```
3. Run tests to ensure everything works:
   ```bash
   composer test
   ```

## Project Structure

```
php/
├── src/
│   ├── Char.php                           # Character data structure
│   ├── Chars.php                          # Character array utilities
│   ├── TransliteratorInterface.php        # Transliterator interface
│   ├── TransliteratorFactoryInterface.php # Factory interface
│   ├── ChainedTransliterator.php          # Chained transliterator
│   ├── TransliterationRecipe.php           # Recipe configuration
│   ├── TransliteratorRegistry.php         # Transliterator registry
│   ├── Yosina.php                         # Main API
│   └── Transliterators/                   # Generated transliterators
│       ├── SpacesTransliterator.php
│       ├── RadicalsTransliterator.php
│       └── ...
├── tests/
│   └── BasicTest.php                      # Basic functionality tests
├── codegen/
│   └── generate.php                       # Code generator
├── composer.json                          # Composer configuration
└── README.md                              # This file
```

## License

MIT License. See the main project README for details.

## Contributing

This is part of the larger Yosina project. Please ensure changes maintain compatibility across all language implementations.
