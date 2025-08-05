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

// Create a recipe with desired transformations
let recipe = TransliteratorRecipe {
    kanji_old_new: Some(Default::default()),
    replace_spaces: Some(Default::default()),
    replace_suspicious_hyphens_to_prolonged_sound_marks: Some(Default::default()),
    circled_or_squared: Some(Default::default()),
    combined: Some(Default::default()),
    ..Default::default()
};

// Create the transliterator
let transliterator = make_transliterator(recipe);

// Use it with various special characters
let input = "①②③　ⒶⒷⒸ　␀␁␂"; // circled numbers, letters, space, control pictures
let result = transliterator.transliterate(input);
println!("{}", result); // "123 ABC NULSOHSTX"
```

### Using Direct Configuration

```rust
use yosina::{make_transliterator, TransliteratorConfig};

// Configure with direct transliterator configs
let configs = vec![
    TransliteratorConfig::KanjiOldNew(Default::default()),
    TransliteratorConfig::Spaces(Default::default()),
    TransliteratorConfig::ProlongedSoundMarks(Default::default()),
    TransliteratorConfig::CircledOrSquared(Default::default()),
    TransliteratorConfig::Combined(Default::default()),
];

let transliterator = make_transliterator(configs);
let result = transliterator.transliterate("some japanese text");
```

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

## Related Projects

- [Yosina (JavaScript)](../javascript/) - JavaScript/TypeScript implementation
- [Yosina (Python)](../python/) - Python implementation
- [Yosina (Java)](../java/) - Java implementation
