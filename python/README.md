# Yosina Python

A Python port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Usage

```python
from yosina import make_transliterator, TransliteratorRecipe

# Create a recipe with desired transformations
recipe = TransliteratorRecipe(
    kanji_old_new=True,
    replace_spaces=True,
    replace_suspicious_hyphens_to_prolonged_sound_marks=True,
    replace_circled_or_squared_characters=True,
    replace_combined_characters=True,
    to_fullwidth=True,
)

# Create the transliterator
transliterator = make_transliterator(recipe)

# Use it with various special characters
input_text = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"  # circled numbers, letters, space, combined characters
result = transliterator(input_text)
print(result)  # "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

# Convert old kanji to new
old_kanji = "舊字體"
result = transliterator(old_kanji)
print(result)  # "旧字体"

# Convert half-width katakana to full-width
half_width = "ﾃｽﾄﾓｼﾞﾚﾂ"
result = transliterator(half_width)
print(result)  # "テストモジレツ"
```

### Using Direct Configuration

```python
from yosina import make_transliterator

# Configure with direct transliterator configs
configs = [
    ("kanji-old-new", {}),
    ("spaces", {}),
    ("prolonged-sound-marks", {"replace_prolonged_marks_following_alnums": True}),
    ("circled-or-squared", {}),
    ("combined", {}),
]

transliterator = make_transliterator(configs)
result = transliterator("some japanese text")
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
```python
configs = [
    ("jisx0201-and-alike", {
        "fullwidth_to_halfwidth": True,      # Convert fullwidth → halfwidth (default: True)
        "convert_gl": True,                   # Convert ASCII/Latin characters (default: True)
        "convert_gr": True,                   # Convert Katakana characters (default: True)
        "convert_hiraganas": False,           # Convert Hiragana to halfwidth Katakana (default: False)
        "combine_voiced_sound_marks": True,   # Combine base + voiced marks (default: True)
        "convert_unsafe_specials": False,     # Convert special punctuation (default: False)
        # Ambiguous character handling
        "u005c_as_yen_sign": False,           # Treat backslash as yen sign
        "u007e_as_wave_dash": True,           # Treat tilde as wave dash
        "u00a5_as_yen_sign": True,            # Treat ¥ as yen sign
    })
]

transliterator = make_transliterator(configs)

# Fullwidth to halfwidth conversion
print(transliterator("ＡＢＣ１２３"))  # "ABC123"
print(transliterator("カタカナ"))       # "ｶﾀｶﾅ"

# With voice marks combination
print(transliterator("ガギグゲゴ"))     # "ｶﾞｷﾞｸﾞｹﾞｺﾞ"

# Reverse direction (halfwidth to fullwidth)
reverse_configs = [
    ("jisx0201-and-alike", {"fullwidth_to_halfwidth": False})
]
reverse_transliterator = make_transliterator(reverse_configs)
print(reverse_transliterator("ｶﾀｶﾅ ABC"))  # "カタカナ　ＡＢＣ"
```

### ivs-svs-base

Handles Ideographic Variation Sequences (IVS) and Standardized Variation Sequences (SVS) for CJK characters, particularly Japanese Kanji. This is crucial for proper display and normalization of Japanese text variants.

**Features:**
- Adds or removes IVS/SVS selectors to/from base Kanji characters
- Supports different Japanese Industrial Standards (JIS) versions
- Handles variation selectors U+FE00-U+FE0F and U+E0100-U+E01EF
- Essential for text normalization and consistent display across systems

**Example:**
```python
# Add IVS/SVS selectors to base characters
add_selectors_configs = [
    ("ivs-svs-base", {
        "mode": "ivs-or-svs",           # Add selectors (default)
        "charset": "unijis_2004",       # Use JIS 2004 mappings (default)
        "prefer_svs": False,            # Prefer SVS over IVS when both exist (default: False)
    })
]

add_transliterator = make_transliterator(add_selectors_configs)

# Example: Add variation selector to differentiate kanji variants
base_kanji = "辻"
with_variant = add_transliterator(base_kanji)  # Adds appropriate variation selector

# Remove IVS/SVS selectors from characters
remove_selectors_configs = [
    ("ivs-svs-base", {
        "mode": "base",                          # Remove selectors
        "charset": "unijis_90",                  # Use JIS 90 mappings
        "drop_selectors_altogether": True,       # Remove all selectors even if not in mapping
    })
]

remove_transliterator = make_transliterator(remove_selectors_configs)

# Remove variation selectors to get base character
kanji_with_selector = "辻\uE0100"  # Kanji with IVS selector
base_only = remove_transliterator(kanji_with_selector)  # "辻" (base character only)
```

### Other Available Transliterators

- `kanji-old-new`: Converts old kanji forms to new kanji forms
- `spaces`: Normalizes various space characters
- `prolonged-sound-marks`: Handles prolonged sound marks (ー)
- `circled-or-squared`: Converts circled/squared characters to their base forms
- `combined`: Expands combined characters (e.g., ㍿ → 株式会社)

## Requirements

- Python 3.10 or higher

## Installation

```bash
# Install with uv
uv add yosina

# Install with pip
pip install yosina
```

## Development

This project uses [uv](https://github.com/astral-sh/uv) for dependency management.

```bash
# Code generation
python -m codegen

# Install development dependencies
uv sync --extra dev

# Run tests
uv run pytest

# Run linting
uv run ruff check .

# Run formatting
uv run ruff format .

# Run type checking
uv run pyright
```

## Requirements

- Python 3.10+
- typing-extensions

## License

MIT