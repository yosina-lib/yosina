# Yosina Java

A Java port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Usage

```java
import lib.yosina.Yosina;
import java.util.function.Function;

// Create a simple transliterator
Function<String, String> transliterator = Yosina.makeTransliterator("circled-or-squared");

// Use the transliterator
String input = "①②③ⒶⒷⒸ";  // circled numbers and letters
String result = transliterator.apply(input);  // "123ABC"
System.out.println(result);

// Or use combined transliterator
Function<String, String> combinedTransliterator = Yosina.makeTransliterator("combined");
String input2 = "␀␁␂";  // control picture symbols
String result2 = combinedTransliterator.apply(input2);  // "NULSOHSTX"
System.out.println(result2);
```

### Chaining Multiple Transliterators

```java
import lib.yosina.Yosina;
import java.util.List;
import java.util.function.Function;

// Chain multiple transliterators
List<Yosina.TransliteratorConfig> configs = List.of(
    new Yosina.TransliteratorConfig("hira-kata-composition"),
    new Yosina.TransliteratorConfig("spaces"),
    new Yosina.TransliteratorConfig("kanji-old-new"),
    new Yosina.TransliteratorConfig("circled-or-squared"),
    new Yosina.TransliteratorConfig("combined")
);

Function<String, String> transliterator = Yosina.makeTransliterator(configs);
String result = transliterator.apply("some japanese text");
```

### Advanced Usage with Options

```java
import lib.yosina.transliterators.HiraKataCompositionTransliterator;

// Use specific options for a transliterator
HiraKataCompositionTransliterator.Options options = new HiraKataCompositionTransliterator.Options(true); // compose non-combining marks
HiraKataCompositionTransliterator transliterator = new HiraKataCompositionTransliterator(options);

// Or pass options through the factory
Function<String, String> transliterator2 = Yosina.makeTransliterator("hira-kata-composition", options);
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

- `circled-or-squared`: Converts circled or squared alphanumeric characters to plain equivalents
- `combined`: Expands combined characters into their individual character sequences
- `hira-kata-composition`: Combines hiragana/katakana with voiced marks
- `hyphens`: Normalizes hyphen-like characters
- `ideographic-annotations`: Handles ideographic annotation marks
- `ivs-svs-base`: Processes variation sequences
- `jisx0201-and-alike`: Converts JIS X 0201 and similar characters
- `kanji-old-new`: Converts old-style kanji to modern forms
- `mathematical-alphanumerics`: Normalizes mathematical notation
- `prolonged-sound-marks`: Handles prolonged sound marks in Japanese text
- `radicals`: Converts Kangxi radicals to equivalent ideographs
- `spaces`: Normalizes various space characters to U+0020

## Building from Source

```bash
git clone https://github.com/yosina-lib/yosina.git
cd yosina/java
gradle build
```

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
