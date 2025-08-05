# Yosina Rust

A Rust port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Installation

Add this to your `Cargo.toml`:

```toml
[dependencies]
yosina = "0.1.0"
```

## Usage

### Using Recipes (Recommended)

```rust
use yosina::{make_transliterator, TransliteratorRecipe};
use yosina::recipes::{ReplaceCircledOrSquaredCharactersOptions, ToFullWidthOptions};

// Create a recipe with desired transformations
let recipe = TransliteratorRecipe {
    kanji_old_new: true,
    replace_spaces: true,
    replace_suspicious_hyphens_to_prolonged_sound_marks: true,
    replace_circled_or_squared_characters: ReplaceCircledOrSquaredCharactersOptions::Yes {
        exclude_emojis: false,
    },
    replace_combined_characters: true,
    to_fullwidth: ToFullWidthOptions::Yes {
        u005c_as_yen_sign: false,
    },
    ..Default::default()
};

// Create the transliterator
let transliterator = make_transliterator(&recipe).unwrap();

// Use it with various special characters
let input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"; // circled numbers, letters, space, combined characters
let result = transliterator(input).unwrap();
println!("{}", result); // "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

// Convert old kanji to new
let old_kanji = "舊字體";
let result = transliterator(old_kanji).unwrap();
println!("{}", result); // "旧字体"

// Convert half-width katakana to full-width
let half_width = "ﾃｽﾄﾓｼﾞﾚﾂ";
let result = transliterator(half_width).unwrap();
println!("{}", result); // "テストモジレツ"
```

### Using Direct Configuration

```rust
use yosina::{make_transliterator, TransliteratorConfig::*};

// Configure with direct transliterator configs
let configs = vec![
    KanjiOldNew,
    Spaces,
    ProlongedSoundMarks(Default::default()),
    CircledOrSquared(Default::default()),
    Combined,
];

let transliterator = make_transliterator(&configs).unwrap();
let result = transliterator("some japanese text").unwrap();
println!("{}", result); // Processed text with transformations applied
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
```rust
use yosina::{make_transliterator, TransliteratorConfig::*};
use yosina::configs::Jisx0201AndAlikeOptions;

// Configure for fullwidth to halfwidth conversion
let options = Jisx0201AndAlikeOptions {
    fullwidth_to_halfwidth: true,      // Convert fullwidth → halfwidth (default: true)
    convert_gl: true,                   // Convert ASCII/Latin characters (default: true)
    convert_gr: true,                   // Convert Katakana characters (default: true)
    convert_hiraganas: false,           // Convert Hiragana to halfwidth Katakana (default: false)
    combine_voiced_sound_marks: true,   // Combine base + voiced marks (default: true)
    convert_unsafe_specials: false,     // Convert special punctuation (default: false)
    // Ambiguous character handling
    u005c_as_yen_sign: false,           // Treat backslash as yen sign
    u007e_as_wave_dash: true,           // Treat tilde as wave dash
    u00a5_as_yen_sign: true,            // Treat ¥ as yen sign
    ..Default::default()
};

let configs = vec![Jisx0201AndAlike(options)];
let transliterator = make_transliterator(&configs).unwrap();

// Fullwidth to halfwidth conversion
println!("{}", transliterator("ＡＢＣ１２３").unwrap());  // "ABC123"
println!("{}", transliterator("カタカナ").unwrap());       // "ｶﾀｶﾅ"
println!("{}", transliterator("ガギグゲゴ").unwrap());     // "ｶﾞｷﾞｸﾞｹﾞｺﾞ"

// Reverse direction (halfwidth to fullwidth)
let reverse_options = Jisx0201AndAlikeOptions {
    fullwidth_to_halfwidth: false,
    ..Default::default()
};
let reverse_configs = vec![Jisx0201AndAlike(reverse_options)];
let reverse_transliterator = make_transliterator(&reverse_configs).unwrap();
println!("{}", reverse_transliterator("ｶﾀｶﾅ ABC").unwrap());  // "カタカナ　ＡＢＣ"
```

### ivs-svs-base

Handles Ideographic Variation Sequences (IVS) and Standardized Variation Sequences (SVS) for CJK characters, particularly Japanese Kanji. This is crucial for proper display and normalization of Japanese text variants.

**Features:**
- Adds or removes IVS/SVS selectors to/from base Kanji characters
- Supports different Japanese Industrial Standards (JIS) versions
- Handles variation selectors U+FE00-U+FE0F and U+E0100-U+E01EF
- Essential for text normalization and consistent display across systems

**Example:**
```rust
use yosina::{make_transliterator, TransliteratorConfig::*};
use yosina::configs::{IvsSvsBaseOptions, IvsSvsBaseMode, IvsSvsBaseCharset};

// Add IVS/SVS selectors to base characters
let add_options = IvsSvsBaseOptions {
    mode: IvsSvsBaseMode::IvsOrSvs,           // Add selectors (default)
    charset: IvsSvsBaseCharset::Unijis2004,    // Use JIS 2004 mappings (default)
    prefer_svs: false,                         // Prefer SVS over IVS when both exist (default: false)
    ..Default::default()
};

let add_configs = vec![IvsSvsBase(add_options)];
let add_transliterator = make_transliterator(&add_configs).unwrap();

// Example: Add variation selector to differentiate kanji variants
let base_kanji = "辻";
let with_variant = add_transliterator(base_kanji).unwrap();  // Adds appropriate variation selector

// Remove IVS/SVS selectors from characters
let remove_options = IvsSvsBaseOptions {
    mode: IvsSvsBaseMode::Base,                      // Remove selectors
    charset: IvsSvsBaseCharset::Unijis90,            // Use JIS 90 mappings
    drop_selectors_altogether: true,                  // Remove all selectors even if not in mapping
    ..Default::default()
};

let remove_configs = vec![IvsSvsBase(remove_options)];
let remove_transliterator = make_transliterator(&remove_configs).unwrap();

// Remove variation selectors to get base character
let kanji_with_selector = "辻\u{E0100}";  // Kanji with IVS selector
let base_only = remove_transliterator(kanji_with_selector).unwrap();  // "辻" (base character only)
```

### Other Available Transliterators

- `KanjiOldNew`: Converts old kanji forms to new kanji forms
- `Spaces`: Normalizes various space characters
- `ProlongedSoundMarks`: Handles prolonged sound marks (ー)
- `CircledOrSquared`: Converts circled/squared characters to their base forms
- `Combined`: Expands combined characters (e.g., ㍿ → 株式会社)

## Development

This project uses standard Rust tooling.

```bash
# Build the library
cargo build

# Run tests
cargo test

# Run linting
cargo clippy

# Run formatting
cargo fmt

# Build documentation
cargo doc --open
```

## Requirements

- Rust 1.70+

## License

MIT