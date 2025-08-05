# Yosina PHP

A PHP port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Usage

```php
<?php

use Yosina\TransliteratorRecipe;
use Yosina\Yosina;

// Create a recipe with multiple transformations
$recipe = new TransliteratorRecipe(
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
composer require yosina/yosina
```

## Available Transliterators

- `circled-or-squared` - Convert circled or squared alphanumeric characters to plain equivalents
- `combined` - Expand combined characters into their individual character sequences
- `hira-kata-composition` - Combines hiragana/katakana with voiced marks
- `hyphens` - Normalize hyphen-like characters
- `ideographic-annotations` - Handle ideographic annotation marks
- `ivs-svs-base` - Process variation sequences
- `jisx0201-and-alike` - Convert JIS X 0201 and similar characters
- `kanji-old-new` - Convert old-style kanji to modern forms
- `mathematical-alphanumerics` - Normalize mathematical notation characters
- `prolonged-sound-marks` - Handle prolonged sound marks in Japanese text
- `radicals` - Replace Kangxi radicals with equivalent CJK ideographs
- `spaces` - Replace various space characters with ASCII space

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
   php tests/BasicTest.php
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
│   ├── TransliteratorRecipe.php           # Recipe configuration
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
