# Yosina Ruby Examples

This directory contains example scripts demonstrating the usage of the Yosina Ruby library for Japanese text transliteration.

## Examples

### Basic Usage (`basic_usage.rb`)

Demonstrates fundamental transliteration functionality using recipes:

```bash
bundle exec ruby basic_usage.rb
```

Shows:
- Simple kanji old-to-new conversion
- Comprehensive transliteration with multiple features
- Common use cases like space normalization, kanji conversion, etc.

### Advanced Usage (`advanced_usage.rb`)

Shows complex scenarios and various configuration options:

```bash
bundle exec ruby advanced_usage.rb
```

Demonstrates:
- Web scraping text normalization
- Document standardization
- Search index preparation
- Custom processing pipelines
- Unicode normalization showcase
- Performance considerations

### Configuration-based Usage (`config_based_usage.rb`)

Shows how to use direct transliterator configurations instead of recipes:

```bash
bundle exec ruby config_based_usage.rb
```

Demonstrates:
- Direct configuration arrays
- Individual transliterator usage
- Step-by-step transformations

## Output Comparison

The Ruby examples produce output consistent with other language implementations. Key features tested:

- **Old kanji conversion**: `檜` → `桧`
- **Space normalization**: Ideographic spaces → regular spaces  
- **Text transformations**: Various Unicode normalization tasks