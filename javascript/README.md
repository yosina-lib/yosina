# Yosina JavaScript

A TypeScript port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Usage

```typescript
import { makeTransliterator, TransliteratorRecipe } from '@yosina-lib/yosina';

// Create a recipe with desired transformations
const recipe: TransliteratorRecipe = {
  kanjiOldNew: true,
  replaceSpaces: true,
  replaceSuspiciousHyphensToProlongedSoundMarks: true,
  replaceCircledOrSquaredCharacters: true,
  replaceCombinedCharacters: true,
  toFullwidth: true,
};

// Create the transliterator
const transliterator = await makeTransliterator(recipe);

// Use it with various special characters
const input = '①②③　ⒶⒷⒸ　㍿㍑㌠㋿'; // circled numbers, letters, space, combined characters
const result = transliterator(input);
console.log(result); // "(1)(2)(3) (A)(B)(C) 株式会社リットルサンチーム令和"

// Convert old kanji to new
const oldKanji = '舊字體';
const kanjiResult = transliterator(oldKanji);
console.log(kanjiResult); // "旧字体"

// Convert half-width katakana to full-width
const halfWidth = 'ﾃｽﾄﾓｼﾞﾚﾂ';
const fullWidthResult = transliterator(halfWidth);
console.log(fullWidthResult); // "テストモジレツ"
```

### Using Direct Configuration

```typescript
import { makeTransliterator } from '@yosina-lib/yosina';

// Configure with direct transliterator configs
const configs = [
  ["kanji-old-new", {}],
  ["spaces", {}],
  ["prolonged-sound-marks", { replaceProlongedMarksFollowingAlnums: true }],
  ["circled-or-squared", {}],
  ["combined", {}],
];

const transliterator = await makeTransliterator(configs);
const result = transliterator("some japanese text");
```

## Available Transliterators

### jisx0201-and-alike

Handles conversion between fullwidth and halfwidth characters based on JIS X 0201 character encoding standards. This transliterator is essential for normalizing Japanese text that may contain a mix of fullwidth and halfwidth characters.

**Features:**
- Converts between fullwidth ASCII/Latin characters (U+FF01-U+FF5E) and halfwidth ASCII (U+0020-U+007E)
- Handles fullwidth/halfwidth Katakana conversion
- Optionally converts Hiragana to halfwidth Katakana
- Manages voiced sound marks (dakuten/handakuten) with optional combination
- Handles special symbols with various override options

**Example:**
```typescript
const configs = [
  ["jisx0201-and-alike", {
    fullwidthToHalfwidth: true,      // Convert fullwidth → halfwidth (default: true)
    convertGL: true,                  // Convert ASCII/Latin characters (default: true)
    convertGR: true,                  // Convert Katakana characters (default: true)
    convertHiraganas: false,          // Convert Hiragana to halfwidth Katakana (default: false)
    combineVoicedSoundMarks: true,    // Combine base + voiced marks (default: true)
    convertUnsafeSpecials: false,     // Convert special punctuation (default: false)
    // Ambiguous character handling
    u005cAsYenSign: false,            // Treat backslash as yen sign
    u007eAsWaveDash: true,            // Treat tilde as wave dash
    u00a5AsYenSign: true,             // Treat ¥ as yen sign
  }]
];

const transliterator = await makeTransliterator(configs);

// Fullwidth to halfwidth conversion
transliterator("ＡＢＣ１２３");  // "ABC123"
transliterator("カタカナ");       // "ｶﾀｶﾅ"

// With voice marks combination
transliterator("ガギグゲゴ");     // "ｶﾞｷﾞｸﾞｹﾞｺﾞ" (or "ｶﾞｷﾞｸﾞｹﾞｺﾞ" if combineVoicedSoundMarks is false)

// Reverse direction (halfwidth to fullwidth)
const reverseConfigs = [
  ["jisx0201-and-alike", { fullwidthToHalfwidth: false }]
];
const reverseTransliterator = await makeTransliterator(reverseConfigs);
reverseTransliterator("ｶﾀｶﾅ ABC");  // "カタカナ　ＡＢＣ"
```

### ivs-svs-base

Handles Ideographic Variation Sequences (IVS) and Standardized Variation Sequences (SVS) for CJK characters, particularly Japanese Kanji. This is crucial for proper display and normalization of Japanese text variants.

**Features:**
- Adds or removes IVS/SVS selectors to/from base Kanji characters
- Supports different Japanese Industrial Standards (JIS) versions
- Handles variation selectors U+FE00-U+FE0F and U+E0100-U+E01EF
- Essential for text normalization and consistent display across systems

**Example:**
```typescript
// Add IVS/SVS selectors to base characters
const addSelectorsConfigs = [
  ["ivs-svs-base", {
    mode: "ivs-or-svs",           // Add selectors (default)
    charset: "unijis_2004",       // Use JIS 2004 mappings (default)
    preferSvs: false,             // Prefer SVS over IVS when both exist (default: false)
  }]
];

const addTransliterator = await makeTransliterator(addSelectorsConfigs);

// Example: Add variation selector to differentiate kanji variants
const baseKanji = "辻";
const withVariant = addTransliterator(baseKanji);  // Adds appropriate variation selector

// Remove IVS/SVS selectors from characters
const removeSelectorsConfigs = [
  ["ivs-svs-base", {
    mode: "base",                          // Remove selectors
    charset: "unijis_90",                  // Use JIS 90 mappings
    dropSelectorsAltogether: true,         // Remove all selectors even if not in mapping
  }]
];

const removeTransliterator = await makeTransliterator(removeSelectorsConfigs);

// Remove variation selectors to get base character
const kanjiWithSelector = "辻\uE0100";  // Kanji with IVS selector
const baseOnly = removeTransliterator(kanjiWithSelector);  // "辻" (base character only)
```

### Other Available Transliterators

- `kanji-old-new`: Converts old kanji forms to new kanji forms
- `spaces`: Normalizes various space characters
- `prolonged-sound-marks`: Handles prolonged sound marks (ー)
- `circled-or-squared`: Converts circled/squared characters to their base forms
- `combined`: Expands combined characters (e.g., ㍿ → 株式会社)

## Installation

```bash
npm install @yosina-lib/yosina
```

## Development

This project uses Node.js with TypeScript and Biome for formatting/linting.

```bash
# Install dependencies
npm install

# Run tests
npm test

# Run linting
npm run lint

# Run formatting
npm run format

# Build the library
npm run build

# Generate documentation
npm run docs:build
```

## Requirements

- Node.js 18+
- TypeScript 5.0+

## License

MIT
