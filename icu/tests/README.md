# ICU Transliterator Tests

This project contains test cases for the ICU transliteration rules generated for Yosina.

## Prerequisites

- Java 11 or higher
- Gradle (wrapper included)

## Running Tests

First, ensure the ICU rules are generated:

```bash
cd ../codegen
python3 generate_icu_rules.py
```

Then run the tests:

```bash
# Run all tests
./gradlew test

# Run a specific test class
./gradlew test --tests SpacesTransliteratorTest

# Run with more detailed output
./gradlew test --info
```

## Test Coverage

The test suite includes tests for all transliterators:

### Simple Transliterators (Data-driven)
- **SpacesTransliteratorTest** - Tests space character normalization
- **RadicalsTransliteratorTest** - Tests Kangxi radical replacements
- **KanjiOldNewTransliteratorTest** - Tests old/new kanji form conversions
- **HyphensTransliteratorTest** - Tests various hyphen normalizations
- **CombinedTransliteratorTest** - Tests decomposition of combined characters

### Complex Transliterators (Manually ported)
- **ProlongedSoundMarksTransliteratorTest** - Tests context-aware prolonged sound mark replacement
- **JapaneseIterationMarksTransliteratorTest** - Tests iteration mark replacement
- **HiraKataCompositionTransliteratorTest** - Tests composition of decomposed characters

## Test Structure

Each test class extends `BaseTransliteratorTest` which provides utilities for:
- Loading ICU rules from resource files
- Creating transliterators
- Applying transliterations

Tests are based on the existing Java library test cases to ensure consistency.

## Notes

Some complex transliterators have limitations in their ICU implementations:
- The prolonged sound marks transliterator doesn't support all configuration options
- The iteration marks transliterator has simplified consecutive mark handling
- The composition transliterator only handles combining marks by default

For full feature support, use the native implementations in the respective language directories.