# Yosina Python Examples

This directory contains example applications demonstrating various use cases for the Yosina Python library, structured as a proper Python package using `uv` for dependency management.

## Prerequisites

Make sure you have Python 3.10+ and [uv](https://github.com/astral-sh/uv) installed:

```bash
# Install uv if you haven't already
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or using pip
python -m venv .venv
source .venv/bin/activate
pip install uv
```

## Setup

### Initialize the project:

```bash
# From this directory
uv sync

# This will install all dependencies including yosina
```

### Alternative setup with local development version:

If you want to use the local development version of Yosina:

```bash
# Install the local yosina package in development mode
uv add --editable ../../python

# Or manually edit pyproject.toml to use:
# yosina = { path = "../../python", develop = true }
```

## Running the Examples

### Using uv (Recommended)

```bash
# Run examples directly with uv
uv run python src/yosina_examples/basic_usage.py
uv run python src/yosina_examples/config_based_usage.py
uv run python src/yosina_examples/advanced_usage.py

# Or use the configured scripts
uv run yosina-basic
uv run yosina-config
uv run yosina-advanced
```

### Using the installed package

After running `uv sync`, you can also run:

```bash
# Activate the virtual environment
source .venv/bin/activate  # On Unix/macOS
# or
.venv\Scripts\activate.bat  # On Windows

# Run the examples
python src/yosina_examples/basic_usage.py
python src/yosina_examples/config_based_usage.py
python src/yosina_examples/advanced_usage.py

# Or use the scripts
yosina-basic
yosina-config
yosina-advanced
```

## Examples

### 1. Basic Usage (`src/yosina_examples/basic_usage.py`)

Demonstrates the fundamental usage patterns:
- Using `TransliterationRecipe` for common transformations
- Simple kanji old-to-new conversion
- Comprehensive text normalization

```bash
uv run yosina-basic
```

### 2. Configuration-based Usage (`src/yosina_examples/config_based_usage.py`)

Shows how to use direct transliterator configurations:
- Creating transliterators with specific configs
- Individual transliterator examples
- Fine-grained control over transformations

```bash
uv run yosina-config
```

### 3. Advanced Usage (`src/yosina_examples/advanced_usage.py`)

Demonstrates complex real-world scenarios:
- Web scraping text normalization
- Document standardization workflows
- Search index preparation
- Custom processing pipelines
- Unicode edge case handling

```bash
uv run yosina-advanced
```

## Key Concepts Demonstrated

### Recipe-based Approach (Recommended)

```python
from yosina import make_transliterator, TransliterationRecipe

recipe = TransliterationRecipe(
    kanji_old_new=True,
    replace_spaces=True,
    to_fullwidth=True
)

transliterator = make_transliterator(recipe)
result = transliterator("some text")
```

### Configuration-based Approach

```python
from yosina import make_transliterator

configs = [
    ("kanji-old-new", {}),
    ("spaces", {}),
    ("jisx0201-and-alike", {"to": "fullwidth"})
]

transliterator = make_transliterator(configs)
result = transliterator("some text")
```

## Development

### Code Quality

```bash
# Format code
uv run ruff format

# Lint code
uv run ruff check

# Type checking
uv run pyright
```

## Common Use Cases

1. **Web Content Normalization**: Clean up scraped Japanese text
2. **Document Processing**: Standardize text formatting
3. **Search Index Preparation**: Normalize text for search engines
4. **Data Cleaning**: Remove inconsistencies in text data
5. **Typography**: Ensure consistent character usage

## Troubleshooting

If you encounter issues:

1. **Import errors**: Make sure you've run `uv sync` to install dependencies
2. **Module not found**: Ensure you're running commands with `uv run` or from an activated virtual environment
3. **Local development**: Use `uv add --editable ../../python` to use the local Yosina version
4. **Virtual environment**: The examples expect to run in the uv-managed virtual environment

### Common solutions:

```bash
# Reinstall dependencies
uv sync --reinstall

# Use local development version
uv add --editable ../../python

# Check installation
uv run python -c "import yosina; print('Success!')"
```

## Further Reading

- [Yosina Python README](../../python/README.md)
- [Main Project README](../../README.md)
- [Yosina Specification](https://github.com/yosina-lib/yosina-spec)
