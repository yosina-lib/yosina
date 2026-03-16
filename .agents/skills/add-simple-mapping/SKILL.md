---
name: add-simple-mapping
description: Add new entries to transliterator mapping tables across all 10 language implementations (JS, Rust, Python, Go, Java, C#, Swift, PHP, Ruby, Dart), including tests and linter checks. Supports hira-kata and code-generated simple transliterators (spaces, radicals, ideographic-annotations, mathematical-alphanumerics, kanji-old-new).
argument-hint: <transliterator name> <description of entries to add>
---

# Add Simple Mapping

Add new mapping entries to a transliterator across all language implementations in this repo, add corresponding tests, and verify linters pass.

## Task

Given the user's description in `$ARGUMENTS`, identify which transliterator to modify, determine the mapping entries to add, and apply them across all 10 languages.

The first token of `$ARGUMENTS` may be a transliterator name (e.g. `hira-kata`, `radicals`, `spaces`). If omitted or ambiguous, infer the transliterator from context. Default to `hira-kata` if unclear.

## Supported transliterators

There are two categories of transliterators, each with a different workflow:

### Category A: Code-generated simple 1:1 mapping transliterators

These transliterators are generated from JSON data files in `/data/`. Implementation files across all languages are auto-generated via `make codegen`. **Do NOT edit implementation files directly.**

| Transliterator | Data file |
|---|---|
| `spaces` | `data/spaces.json` |
| `radicals` | `data/radicals.json` |
| `ideographic-annotations` | `data/ideographic-annotation-marks.json` |
| `mathematical-alphanumerics` | `data/mathematical-alphanumerics.json` |
| `kanji-old-new` | `data/kanji-old-new-form.json` |

Data file format: `{ "U+XXXX": "U+YYYY" }` (source code point to target code point, or `null` to map to empty string).

### Category B: Manually-maintained hira-kata table

The hira-kata transliterator uses separate table files maintained per language. Each entry is a tuple of (hiragana, katakana, halfwidth_or_none).

## Procedure

### 1. Determine entries and Unicode properties

Identify the mapping entries from the user's description. For each entry, determine:
- Source and target Unicode code points
- Whether characters are BMP (U+0000-U+FFFF) or supplementary plane (U+10000+)

Supplementary characters require surrogate pair encoding in Java and C#:
```
high = 0xD800 + ((codepoint - 0x10000) >> 10)
low  = 0xDC00 + ((codepoint - 0x10000) & 0x3FF)
```

### 2. Modify the mapping data

#### For Category A (code-generated) transliterators

1. Edit the JSON data file in `/data/`, adding entries in the format `"U+XXXX": "U+YYYY"`.
2. Run code generation to regenerate all language implementations:

```bash
make codegen
```

This regenerates implementation files for all 10 languages automatically.

#### For Category B (hira-kata) transliterator

Add entries to the table file in each language directly. The table files, their no-value syntax for the halfwidth column, and their escape syntax for supplementary characters are:

| Language | File | No-value | Supplementary escape |
|----------|------|----------|----------------------|
| JavaScript | `javascript/src/transliterators/hira-kata-table.ts` | `undefined` | `\u{XXXXX}` |
| Rust | `rust/src/transliterators/hira_kata_table.rs` | `None` | `\u{xxxxx}` |
| Python | `python/src/yosina/transliterators/hira_kata_table.py` | `None` | `\U000XXXXX` (8-digit) |
| Go | `go/transliterators/internal/hira_kata_table.go` | `-1` | `'\U000XXXXX'` (rune) |
| Java | `java/src/main/java/io/yosina/transliterators/HiraKataTable.java` | `""` | `\uHHHH\uLLLL` (surrogate pair) |
| C# | `csharp/src/Yosina/Transliterators/HiraKataTable.cs` | `""` | `\uHHHH\uLLLL` (surrogate pair) |
| Swift | `swift/Sources/Yosina/Transliterators/HiraKataTable.swift` | `""` | `\u{XXXXX}` |
| PHP | `php/src/Transliterators/HiraKataTable.php` | `''` | `"\u{XXXXX}"` (double-quoted only) |
| Ruby | `ruby/lib/yosina/transliterators/hira_kata_table.rb` | `nil` | `"\u{XXXXX}"` (double-quoted only) |
| Dart | `dart/lib/src/transliterators/hira_kata_table.dart` | `''` | `\u{XXXXX}` |

Append after the last existing entry in the relevant table, preserving the formatting and comment style of each file.

### 3. Add tests

Add test cases to the transliterator's test file in each language. Read the existing test file first to match the test style and patterns. The test file locations follow these naming conventions:

| Language | Test file pattern | How to add |
|----------|-----------|------------|
| JavaScript | `javascript/src/transliterators/__tests__/<kebab-name>.test.ts` | New `test()` block |
| Rust | `rust/src/transliterators/<snake_name>.rs` (inline `#[cfg(test)]`) | New `#[test] fn` |
| Python | `python/tests/test_<snake_name>.py` or `python/tests/transliterators/test_<snake_name>.py` | New `def test_*` |
| Go | `go/transliterators/<snake_name>/<snake_name>_test.go` | New entry in table-driven test slice |
| Java | `java/src/test/java/io/yosina/transliterators/<PascalName>TransliteratorTest.java` | New `Arguments.of()` in `@MethodSource` |
| C# | `csharp/test/Yosina.Tests/<PascalName>TransliteratorTests.cs` or under `Transliterators/` | New `[InlineData()]` attribute |
| Swift | `swift/Tests/YosinaTests/<PascalName>Tests.swift` | New `XCTAssertEqual` or new func |
| PHP | `php/tests/<PascalName>TransliteratorTest.php` | New `$this->assertEquals` or new method |
| Ruby | `ruby/test/test_<snake_name>.rb` | New `def test_*` method |
| Dart | `dart/test/<snake_name>_test.dart` | New `expect()` or new `test()` |

**Important**: Always verify the test file exists at the expected path before editing. If a test file does not exist for the transliterator in a given language, check for aggregate test files (e.g. `dart/test/transliterators_test.dart`, `dart/test/new_transliterators_test.dart`) or create a new dedicated test file following the language's conventions.

For hira-kata, test both directions (hira-to-kata and kata-to-hira). For unidirectional transliterators, test the forward mapping and verify unmapped characters pass through unchanged.

### 4. Run tests

Run the relevant test for the transliterator in each language. Replace `<name>` placeholders with the appropriate transliterator name in each language's naming convention:

```bash
cd javascript && npx jest --testPathPatterns='<kebab-name>'
cd rust && cargo test --lib transliterators::<snake_name>
cd python && uv run pytest tests/test_<snake_name>.py -v  # or tests/transliterators/test_<snake_name>.py
cd go && go test ./transliterators/<snake_name>/ -v
cd java && gradle :test --tests '*<PascalName>TransliteratorTest*'
cd csharp && dotnet test --filter 'FullyQualifiedName~<PascalName>TransliteratorTest'
cd swift && swift test --filter '<PascalName>Tests'
cd php && vendor/bin/phpunit tests/<PascalName>TransliteratorTest.php
cd ruby && bundle exec ruby test/test_<snake_name>.rb
cd dart && dart test test/<snake_name>_test.dart
```

### 5. Run linters

```bash
cd javascript && npx biome check src/transliterators/<kebab-name>*.ts src/transliterators/__tests__/<kebab-name>.test.ts
cd rust && cargo fmt -- --check && cargo clippy --lib -- -D warnings
cd python && uv run ruff check && uv run ruff format --check
cd go && gofmt -l .
cd java && gradle spotlessCheck
cd csharp && dotnet format --verify-no-changes
cd swift && swiftformat --lint Sources/ Tests/
cd php && composer cs-check
cd dart && dart analyze && dart format --set-exit-if-changed .
```

Accept auto-fixes from formatters (e.g. `dart format`). The following lint failures are pre-existing and unrelated:

- **Java Spotless**: `NoSuchMethodError` from google-java-format JDK incompatibility
- **PHP CS Fixer**: Does not support PHP 8.5
- **Ruby**: System Ruby 2.6 lacks `filter_map` (needs 2.7+)
- **Swift swiftformat**: Trailing comma issues in unrelated files
