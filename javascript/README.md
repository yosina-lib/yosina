# Yosina JavaScript

A TypeScript port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Usage

```typescript
import { makeTransliterator } from '@yosina-lib/yosina';

// Create a recipe with desired transformations
const recipe = {
  kanjiOldNew: true,
  replaceSpaces: true,
  replaceSuspiciousHyphensToProongedSoundMarks: true,
  circledOrSquared: true,
  combined: true,
};

// Create the transliterator
const transliterator = makeTransliterator(recipe);

// Use it with various special characters
const input = '①②③　ⒶⒷⒸ　␀␁␂'; // circled numbers, letters, space, control pictures
const result = transliterator(input);
console.log(result); // "123 ABC NULSOHSTX"
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

const transliterator = makeTransliterator(configs);
const result = transliterator("some japanese text");
```

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
