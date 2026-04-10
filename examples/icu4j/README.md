# Yosina ICU4J Examples

Usage examples for Yosina ICU transliteration rules with ICU4J (Java).

## Prerequisites

- Java 17+
- Gradle (wrapper not included — use system Gradle or install via SDKMAN / Homebrew)

## Build and Run

```bash
gradle run
```

## Examples

### BasicUsage.java

Demonstrates:

- Loading individual transliterator rule files
- Applying transliterators to Japanese text (spaces, kanji old-new, hira-to-kata, fullwidth-to-halfwidth, iteration marks, prolonged sound marks)
- Chaining multiple transliterators into a pipeline using `CompoundTransliterator`
- Chaining `hira_kata_composition` with `::NFC;` for both non-combining and combining mark composition
