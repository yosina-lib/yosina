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
  circled_or_squared: true,
  combined: true
)

transliterator = Yosina.make_transliterator(recipe)

# Use it to transliterate text with various special characters
input = "①②③　ⒶⒷⒸ　␀␁␂" # circled numbers, letters, ideographic space, control pictures
result = transliterator.call(input)
puts result # "123 ABC NULSOHSTX" (with regular ASCII spaces)
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

chars2 = Yosina::Chars.build_char_array("␀␁␂") # control pictures
result_chars2 = combined_transliterator.call(chars2)
output2 = Yosina::Chars.from_chars(result_chars2)
puts output2 # "NULSOHSTX"
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

- `spaces`: Normalize various Unicode space characters
- `kanji-old-new`: Convert old kanji forms to new forms
- `radicals`: Convert Kangxi radicals to CJK ideographs  
- `ideographic-annotations`: Handle ideographic annotation marks
- `mathematical-alphanumerics`: Normalize mathematical notation
- `prolonged-sound-marks`: Handle prolonged sound marks (stub)
- `hyphens`: Handle hyphen replacement (stub)
- `hira-kata-composition`: Hiragana/katakana composition (stub)
- `ivs-svs-base`: IVS/SVS handling (stub)
- `jisx0201-and-alike`: JIS X 0201 characters (stub)
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
