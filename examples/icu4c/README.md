# Yosina ICU4C Examples

Usage examples for Yosina ICU transliteration rules with ICU4C (C++).

## Prerequisites

- C++17 compiler
- ICU4C development libraries (`libicu-dev` on Debian/Ubuntu, `icu4c` via Homebrew on macOS)

## Build

```bash
# Using CMake
cmake -B build
cmake --build build

# Or directly with pkg-config
g++ -std=c++17 -o basic_usage basic_usage.cpp \
    $(pkg-config --cflags --libs icu-uc icu-i18n)
```

## Run

```bash
# From this directory
./build/basic_usage

# Or if built directly
./basic_usage
```

## Examples

### basic_usage.cpp

Demonstrates:

- Loading individual transliterator rule files
- Applying transliterators to Japanese text
- Chaining multiple transliterators into a pipeline using `CompoundTransliterator`
