# Yosina Java Examples

This directory contains example code demonstrating how to use the Yosina Java library for Japanese text transliteration.

## Prerequisites

- Java 21 or later
- Gradle (or use the Gradle wrapper from the parent project)

## Examples

### 1. BasicUsage.java
Demonstrates fundamental transliteration functionality including:
- Old kanji to new kanji conversion
- Half-width to full-width conversion
- Japanese iteration marks expansion
- Hiragana-katakana conversion
- Special character replacement

### 2. AdvancedUsage.java
Shows complex text processing scenarios:
- Web scraping text normalization
- Document standardization
- Search index preparation
- Custom processing pipelines
- Unicode normalization
- Performance considerations

### 3. ConfigBasedUsage.java
Illustrates direct transliterator configuration:
- Using specific transliterator configurations
- Building custom transliterator chains
- Individual transliterator usage

## Running the Examples

From the `java/examples` directory:

```bash
# Run basic usage example
gradle runBasicUsage

# Run advanced usage example
gradle runAdvancedUsage

# Run configuration-based usage example
gradle runConfigBasedUsage

# Run all examples
gradle runAllExamples
```

Or from the parent directory:

```bash
# Run basic usage example
gradle :examples:runBasicUsage
```

## Building

To compile the examples:

```bash
gradle build
```

## Understanding the Code

Each example is self-contained and includes comments explaining the various features. The examples follow the same structure as those in other languages (Python, Ruby, etc.) to maintain consistency across the Yosina ecosystem.