# Yosina Ruby Examples

This directory contains example scripts demonstrating the usage of the Yosina Ruby library for Japanese text transliteration.

## Prerequisites

Make sure you have the Ruby version of Yosina installed and working. From the project root:

```bash
cd ruby
bundle install
rake codegen  # Generate transliterators from data files
rake test     # Run tests to verify everything works
```

## Examples

### Basic Usage (`basic_usage.rb`)

Demonstrates fundamental transliteration functionality using recipes:

```bash
ruby basic_usage.rb
```

Shows:
- Simple kanji old-to-new conversion
- Comprehensive transliteration with multiple features
- Common use cases like space normalization, kanji conversion, etc.

### Advanced Usage (`advanced_usage.rb`)

Shows complex scenarios and various configuration options:

```bash
ruby advanced_usage.rb
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
ruby config_based_usage.rb
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

## Notes

Some transliterators in the Ruby implementation are still stubs and may not produce identical results to the TypeScript/Deno versions for advanced features like:

- Full-width/half-width conversion
- Suspicious hyphen replacement
- Advanced JIS X 0201 handling

This is expected as the Ruby port is still in development. The core functionality (spaces, kanji conversion, radicals) works correctly and produces consistent results.