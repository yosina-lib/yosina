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
    circled_or_squared=True,
    combined=True,
)

# Create the transliterator
transliterator = make_transliterator(recipe)

# Use it with various special characters
input_text = "①②③　ⒶⒷⒸ　␀␁␂"  # circled numbers, letters, space, control pictures
result = transliterator(input_text)
print(result)  # "123 ABC NULSOHSTX"
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

## Related Projects

- [Yosina (JavaScript)](../javascript/) - Original JavaScript implementation
- [Yosina (Rust)](../rust/) - Rust implementation
- [Yosina (Java)](../java/) - Java implementation
