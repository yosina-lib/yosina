# Yosina Ruby

A Ruby port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Usage

```ruby
require 'yosina'

# Create a transliterator using a recipe
recipe = Yosina::TransliteratorRecipe.new(
  replace_spaces: true,
  kanji_old_new: true,
  replace_circled_or_squared_characters: true,
  replace_combined_characters: true,
  to_fullwidth: true
)

transliterator = Yosina.make_transliterator(recipe)

# Use it to transliterate text with various special characters
input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿" # circled numbers, letters, ideographic space, combined characters
result = transliterator.call(input)
puts result # "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

# Convert old kanji to new
old_kanji = "舊字體"
result = transliterator.call(old_kanji)
puts result # "旧字体"

# Convert half-width katakana to full-width
half_width = "ﾃｽﾄﾓｼﾞﾚﾂ"
result = transliterator.call(half_width)
puts result # "テストモジレツ"
```

### Advanced Usage with Configs

```ruby
require 'yosina'

# Create transliterator with specific configurations
configs = [
  Yosina::TransliteratorConfig.new('spaces'),
  Yosina::TransliteratorConfig.new('kanji-old-new'),
  Yosina::TransliteratorConfig.new('radicals'),
  Yosina::TransliteratorConfig.new('circled-or-squared'),
  Yosina::TransliteratorConfig.new('combined')
]

transliterator = Yosina.make_transliterator(configs)
result = transliterator.call("some japanese text")
puts result
```

### Using String Names

```ruby
require 'yosina'

# Simplified configuration with string names
configs = ['spaces', 'kanji-old-new', 'radicals']

transliterator = Yosina.make_transliterator(configs)
result = transliterator.call("some japanese text")
puts result
```

### Using Individual Transliterators

```ruby
require 'yosina'

# Create a circled-or-squared transliterator
circled_factory = Yosina::Transliterators::CircledOrSquared
circled_transliterator = circled_factory.call

chars = Yosina::Chars.build_char_array("①②③ⒶⒷⒸ")
result_chars = circled_transliterator.call(chars)
output = Yosina::Chars.from_chars(result_chars)
puts output # "123ABC"

# Create a combined transliterator
combined_factory = Yosina::Transliterators::Combined
combined_transliterator = combined_factory.call

chars2 = Yosina::Chars.build_char_array("㍿㍑㌠㋿") # combined characters
result_chars2 = combined_transliterator.call(chars2)
output2 = Yosina::Chars.from_chars(result_chars2)
puts output2 # "株式会社リットルサンチーム令和"
```

## Requirements

- Ruby 3.0 and later versions

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yosina'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install yosina

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
```ruby
require 'yosina'

# Configure for fullwidth to halfwidth conversion
config = Yosina::TransliteratorConfig.new('jisx0201-and-alike', {
  fullwidth_to_halfwidth: true,      # Convert fullwidth → halfwidth (default: true)
  convert_gl: true,                   # Convert ASCII/Latin characters (default: true)
  convert_gr: true,                   # Convert Katakana characters (default: true)
  convert_hiraganas: false,           # Convert Hiragana to halfwidth Katakana (default: false)
  combine_voiced_sound_marks: true,   # Combine base + voiced marks (default: true)
  convert_unsafe_specials: false,     # Convert special punctuation (default: false)
  # Ambiguous character handling
  u005c_as_yen_sign: false,           # Treat backslash as yen sign
  u007e_as_wave_dash: true,           # Treat tilde as wave dash
  u00a5_as_yen_sign: true             # Treat ¥ as yen sign
})

transliterator = Yosina.make_transliterator([config])

# Fullwidth to halfwidth conversion
puts transliterator.call("ＡＢＣ１２３")  # "ABC123"
puts transliterator.call("カタカナ")       # "ｶﾀｶﾅ"
puts transliterator.call("ガギグゲゴ")     # "ｶﾞｷﾞｸﾞｹﾞｺﾞ"

# Reverse direction (halfwidth to fullwidth)
reverse_config = Yosina::TransliteratorConfig.new('jisx0201-and-alike', {
  fullwidth_to_halfwidth: false
})
reverse_transliterator = Yosina.make_transliterator([reverse_config])
puts reverse_transliterator.call("ｶﾀｶﾅ ABC")  # "カタカナ　ＡＢＣ"
```

### ivs-svs-base

Handles Ideographic Variation Sequences (IVS) and Standardized Variation Sequences (SVS) for CJK characters, particularly Japanese Kanji. This is crucial for proper display and normalization of Japanese text variants.

**Features:**
- Adds or removes IVS/SVS selectors to/from base Kanji characters
- Supports different Japanese Industrial Standards (JIS) versions
- Handles variation selectors U+FE00-U+FE0F and U+E0100-U+E01EF
- Essential for text normalization and consistent display across systems

**Example:**
```ruby
require 'yosina'

# Add IVS/SVS selectors to base characters
add_config = Yosina::TransliteratorConfig.new('ivs-svs-base', {
  mode: 'ivs-or-svs',           # Add selectors (default)
  charset: 'unijis_2004',       # Use JIS 2004 mappings (default)
  prefer_svs: false             # Prefer SVS over IVS when both exist (default: false)
})

add_transliterator = Yosina.make_transliterator([add_config])

# Example: Add variation selector to differentiate kanji variants
base_kanji = "辻"
with_variant = add_transliterator.call(base_kanji)  # Adds appropriate variation selector

# Remove IVS/SVS selectors from characters
remove_config = Yosina::TransliteratorConfig.new('ivs-svs-base', {
  mode: 'base',                          # Remove selectors
  charset: 'unijis_90',                  # Use JIS 90 mappings
  drop_selectors_altogether: true        # Remove all selectors even if not in mapping
})

remove_transliterator = Yosina.make_transliterator([remove_config])

# Remove variation selectors to get base character
kanji_with_selector = "辻\uE0100"  # Kanji with IVS selector
base_only = remove_transliterator.call(kanji_with_selector)  # "辻" (base character only)
```

### Other Transliterators

- `spaces`: Normalize various Unicode space characters
- `kanji-old-new`: Convert old kanji forms to new forms
- `radicals`: Convert Kangxi radicals to CJK ideographs
- `ideographic-annotations`: Handle ideographic annotation marks
- `mathematical-alphanumerics`: Normalize mathematical notation
- `prolonged-sound-marks`: Handle prolonged sound marks
- `hyphens`: Handle hyphen replacement
- `hira-kata-composition`: Hiragana/katakana composition
- `circled-or-squared`: Replace circled or squared alphanumeric characters with plain equivalents
- `combined`: Replace combined characters with their individual character sequences

## Development

After checking out the repo, run `bundle install` to install dependencies.

### Code Generation

Some transliterators are generated from data files:

```bash
rake codegen
```

This generates transliterators from the JSON data files in the `../data` directory.

### Testing

Run the test suite with:

```bash
rake test
```

Or run specific tests:

```bash
ruby test/test_basic.rb
```

## Project Status

This is a working implementation with the core functionality ported from the other language versions. Some transliterators are still stub implementations and need to be completed:

- Full JIS X 0201 support
- Complete hyphens transliterator with precedence logic
- IVS/SVS base transliterator
- Hiragana/katakana composition
- Prolonged sound marks processing

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yosina-lib/yosina.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
