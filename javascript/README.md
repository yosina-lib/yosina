# Yosina JavaScript

A TypeScript port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Usage

```typescript
import { makeTransliterator, TransliterationRecipe } from '@yosina-lib/yosina';

// Create a recipe with desired transformations
const recipe: TransliterationRecipe = {
  kanjiOldNew: true,
  replaceSpaces: true,
  replaceSuspiciousHyphensToProlongedSoundMarks: true,
  replaceCircledOrSquaredCharacters: true,
  replaceCombinedCharacters: true,
  hiraKata: "hira-to-kata", // Convert hiragana to katakana
  replaceJapaneseIterationMarks: true, // Expand iteration marks
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

// Demonstrate hiragana to katakana conversion with iteration marks
const mixedText = '学問のすゝめ';
const convertedResult = transliterator(mixedText);
console.log(convertedResult); // "学問ノススメ"
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
  ["hira-kata", { mode: "kata-to-hira" }], // Convert katakana to hiragana
  ["japanese-iteration-marks", {}], // Expand iteration marks like 々, ゝゞ, ヽヾ
];

const transliterator = await makeTransliterator(configs);

// Example with various transformations including the new ones
const input = "カタカナでの時々の佐々木さん";
const result = transliterator(input);
console.log(result); // "かたかなでの時時の佐佐木さん"
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
