# Yosina Java

A Java port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Usage

### Using Recipes (Recommended)

```java
import lib.yosina.Yosina;
import lib.yosina.TransliteratorRecipe;
import java.util.function.Function;

// Create a recipe with desired transformations
TransliteratorRecipe recipe = new TransliteratorRecipe()
    .withKanjiOldNew(true)
    .withReplaceSpaces(true)
    .withReplaceSuspiciousHyphensToProlongedSoundMarks(true)
    .withReplaceCircledOrSquaredCharacters(
        TransliteratorRecipe.ReplaceCircledOrSquaredCharactersOptions.ENABLED)
    .withReplaceCombinedCharacters(true)
    .withToFullwidth(TransliteratorRecipe.ToFullwidthOptions.ENABLED);

// Create the transliterator
Function<String, String> transliterator = Yosina.makeTransliterator(recipe);

// Use it with various special characters
String input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"; // circled numbers, letters, space, combined characters
String result = transliterator.apply(input);
System.out.println(result); // "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

// Convert old kanji to new
String oldKanji = "舊字體";
result = transliterator.apply(oldKanji);
System.out.println(result); // "旧字体"

// Convert half-width katakana to full-width
String halfWidth = "ﾃｽﾄﾓｼﾞﾚﾂ";
result = transliterator.apply(halfWidth);
System.out.println(result); // "テストモジレツ"
```

### Using Direct Configuration

```java
import lib.yosina.Yosina;
import java.util.List;
import java.util.function.Function;

// Configure with direct transliterator configs
List<Yosina.TransliteratorConfig> configs = List.of(
    new Yosina.TransliteratorConfig("kanji-old-new"),
    new Yosina.TransliteratorConfig("spaces"),
    new Yosina.TransliteratorConfig("prolonged-sound-marks"),
    new Yosina.TransliteratorConfig("circled-or-squared"),
    new Yosina.TransliteratorConfig("combined")
);

Function<String, String> transliterator = Yosina.makeTransliterator(configs);
String result = transliterator.apply("some japanese text");
```

## Requirements

- Java 17 or higher

## Installation

### Gradle

```gradle
dependencies {
    implementation 'lib.yosina:yosina-java:0.1.0'
}
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
```java
import lib.yosina.Yosina;
import java.util.Map;
import java.util.function.Function;

// Configure for fullwidth to halfwidth conversion
Map<String, Object> options = Map.of(
    "fullwidthToHalfwidth", true,      // Convert fullwidth → halfwidth (default: true)
    "convertGL", true,                  // Convert ASCII/Latin characters (default: true)
    "convertGR", true,                  // Convert Katakana characters (default: true)
    "convertHiraganas", false,          // Convert Hiragana to halfwidth Katakana (default: false)
    "combineVoicedSoundMarks", true,    // Combine base + voiced marks (default: true)
    "convertUnsafeSpecials", false,     // Convert special punctuation (default: false)
    // Ambiguous character handling
    "u005cAsYenSign", false,            // Treat backslash as yen sign
    "u007eAsWaveDash", true,            // Treat tilde as wave dash
    "u00a5AsYenSign", true              // Treat ¥ as yen sign
);

Function<String, String> transliterator = Yosina.makeTransliterator("jisx0201-and-alike", options);

// Fullwidth to halfwidth conversion
System.out.println(transliterator.apply("ＡＢＣ１２３"));  // "ABC123"
System.out.println(transliterator.apply("カタカナ"));       // "ｶﾀｶﾅ"
System.out.println(transliterator.apply("ガギグゲゴ"));     // "ｶﾞｷﾞｸﾞｹﾞｺﾞ"

// Reverse direction (halfwidth to fullwidth)
Map<String, Object> reverseOptions = Map.of("fullwidthToHalfwidth", false);
Function<String, String> reverseTransliterator =
    Yosina.makeTransliterator("jisx0201-and-alike", reverseOptions);
System.out.println(reverseTransliterator.apply("ｶﾀｶﾅ ABC"));  // "カタカナ　ＡＢＣ"
```

### ivs-svs-base

Handles Ideographic Variation Sequences (IVS) and Standardized Variation Sequences (SVS) for CJK characters, particularly Japanese Kanji. This is crucial for proper display and normalization of Japanese text variants.

**Features:**
- Adds or removes IVS/SVS selectors to/from base Kanji characters
- Supports different Japanese Industrial Standards (JIS) versions
- Handles variation selectors U+FE00-U+FE0F and U+E0100-U+E01EF
- Essential for text normalization and consistent display across systems

**Example:**
```java
import lib.yosina.Yosina;
import java.util.Map;
import java.util.function.Function;

// Add IVS/SVS selectors to base characters
Map<String, Object> addOptions = Map.of(
    "mode", "ivs-or-svs",           // Add selectors (default)
    "charset", "unijis_2004",       // Use JIS 2004 mappings (default)
    "preferSvs", false              // Prefer SVS over IVS when both exist (default: false)
);

Function<String, String> addTransliterator =
    Yosina.makeTransliterator("ivs-svs-base", addOptions);

// Example: Add variation selector to differentiate kanji variants
String baseKanji = "辻";
String withVariant = addTransliterator.apply(baseKanji);  // Adds appropriate variation selector

// Remove IVS/SVS selectors from characters
Map<String, Object> removeOptions = Map.of(
    "mode", "base",                          // Remove selectors
    "charset", "unijis_90",                  // Use JIS 90 mappings
    "dropSelectorsAltogether", true          // Remove all selectors even if not in mapping
);

Function<String, String> removeTransliterator =
    Yosina.makeTransliterator("ivs-svs-base", removeOptions);

// Remove variation selectors to get base character
String kanjiWithSelector = "辻\uE0100";  // Kanji with IVS selector
String baseOnly = removeTransliterator.apply(kanjiWithSelector);  // "辻" (base character only)
```

### Other Transliterators

- `circled-or-squared`: Converts circled or squared alphanumeric characters to plain equivalents
- `combined`: Expands combined characters into their individual character sequences
- `hira-kata-composition`: Combines hiragana/katakana with voiced marks
- `hyphens`: Normalizes hyphen-like characters
- `ideographic-annotations`: Handles ideographic annotation marks
- `kanji-old-new`: Converts old-style kanji to modern forms
- `mathematical-alphanumerics`: Normalizes mathematical notation
- `prolonged-sound-marks`: Handles prolonged sound marks in Japanese text
- `radicals`: Converts Kangxi radicals to equivalent ideographs
- `spaces`: Normalizes various space characters to U+0020

## Building from Source

Gradle 8.0 or higher is required to build the Java library.

```bash
git clone https://github.com/yosina-lib/yosina.git
cd yosina/java
gradle build
```

We don't bundle Gradle wrapper in the repository, so you need to have Gradle installed on your system.

### Code Generation

The Java implementation uses a code generation system to create transliterators from JSON data files:

```bash
# Generate transliterator source code
gradle :codegen:run

# Build the main library
gradle build
```

## Testing

```bash
gradle test
```

## API Documentation

The library provides a simple functional interface through the `Yosina` class:

### `Yosina.makeTransliterator(String name)`
Creates a transliterator function with default options.

### `Yosina.makeTransliterator(String name, Object options)`
Creates a transliterator function with custom options.

### `Yosina.makeTransliterator(List<TransliteratorConfig> configs)`
Creates a chained transliterator from multiple configurations.

### Low-level API

For more control, you can use the transliterator classes directly:

```java
import lib.yosina.Chars;
import lib.yosina.CharIterator;
import lib.yosina.transliterators.HiraKataCompositionTransliterator;

HiraKataCompositionTransliterator transliterator = new HiraKataCompositionTransliterator();
CharIterator input = Chars.of("input text").iterator();
CharIterator result = transliterator.transliterate(input);
String output = result.string();
```

## License

MIT License. See the main project repository for details.

## Contributing

Contributions are welcome! Please ensure that any changes maintain compatibility with other language implementations and follow the existing code style.
