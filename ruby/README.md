# Yosina Ruby

A Ruby port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Usage

```ruby
require 'yosina'

# Create a transliterator using a recipe
recipe = Yosina::TransliterationRecipe.new(
  replace_spaces: true,
  kanji_old_new: true,
  replace_circled_or_squared_characters: true,
  replace_combined_characters: true,
  hira_kata: "hira-to-kata",  # Convert hiragana to katakana
  replace_japanese_iteration_marks: true,  # Expand iteration marks
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

# Demonstrate hiragana to katakana conversion with iteration marks
mixed_text = "学問のすゝめ"
result = transliterator.call(mixed_text)
puts result # "学問ノススメ"
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
  Yosina::TransliteratorConfig.new('combined'),
  Yosina::TransliteratorConfig.new('hira-kata', { mode: 'kata-to-hira' }),  # Convert katakana to hiragana
  Yosina::TransliteratorConfig.new('japanese-iteration-marks')  # Expand iteration marks like 々, ゝゞ, ヽヾ
]

transliterator = Yosina.make_transliterator(configs)

# Example with various transformations including the new ones
input_text = "カタカナでの時々の佐々木さん"
result = transliterator.call(input_text)
puts result # "かたかなでの時時の佐佐木さん"
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

### 1. **Circled or Squared** (`circled-or-squared`)
Converts circled or squared characters to their plain equivalents.
- Options: `templates` (custom rendering), `includeEmojis` (include emoji characters)
- Example: `①②③` → `(1)(2)(3)`, `㊙㊗` → `(秘)(祝)`

### 2. **Combined** (`combined`)
Expands combined characters into their individual character sequences.
- Example: `㍻` (Heisei era) → `平成`, `㈱` → `(株)`

### 3. **Hiragana-Katakana Composition** (`hira-kata-composition`)
Combines decomposed hiraganas and katakanas into composed equivalents.
- Options: `composeNonCombiningMarks` (compose non-combining marks)
- Example: `か + ゙` → `が`, `ヘ + ゜` → `ペ`

### 4. **Hiragana-Katakana** (`hira-kata`)
Converts between hiragana and katakana scripts bidirectionally.
- Options: `mode` ("hira-to-kata" or "kata-to-hira")
- Example: `ひらがな` → `ヒラガナ` (hira-to-kata)

### 5. **Hyphens** (`hyphens`)
Replaces various dash/hyphen symbols with common ones used in Japanese.
- Options: `precedence` (mapping priority order)
- Available mappings: "ascii", "jisx0201", "jisx0208_90", "jisx0208_90_windows", "jisx0208_verbatim"
- Example: `2019—2020` (em dash) → `2019-2020`

### 6. **Ideographic Annotations** (`ideographic-annotations`)
Replaces ideographic annotations used in traditional Chinese-to-Japanese translation.
- Example: `㆖㆘` → `上下`

### 7. **IVS-SVS Base** (`ivs-svs-base`)
Handles Ideographic and Standardized Variation Selectors.
- Options: `charset`, `mode` ("ivs-or-svs" or "base"), `preferSVS`, `dropSelectorsAltogether`
- Example: `葛󠄀` (葛 + IVS) → `葛`

### 8. **Japanese Iteration Marks** (`japanese-iteration-marks`)
Expands iteration marks by repeating the preceding character.
- Example: `時々` → `時時`, `いすゞ` → `いすず`

### 9. **JIS X 0201 and Alike** (`jisx0201-and-alike`)
Handles half-width/full-width character conversion.
- Options: `fullwidthToHalfwidth`, `convertGL` (alphanumerics/symbols), `convertGR` (katakana), `u005cAsYenSign`
- Example: `ABC123` → `ＡＢＣ１２３`, `ｶﾀｶﾅ` → `カタカナ`

### 10. **Kanji Old-New** (`kanji-old-new`)
Converts old-style kanji (旧字体) to modern forms (新字体).
- Example: `舊字體の變換` → `旧字体の変換`

### 11. **Mathematical Alphanumerics** (`mathematical-alphanumerics`)
Normalizes mathematical alphanumeric symbols to plain ASCII.
- Example: `𝐀𝐁𝐂` (mathematical bold) → `ABC`

### 12. **Prolonged Sound Marks** (`prolonged-sound-marks`)
Handles contextual conversion between hyphens and prolonged sound marks.
- Options: `skipAlreadyTransliteratedChars`, `allowProlongedHatsuon`, `allowProlongedSokuon`, `replaceProlongedMarksFollowingAlnums`
- Example: `イ−ハト−ヴォ` (with hyphen) → `イーハトーヴォ` (prolonged mark)

### 13. **Radicals** (`radicals`)
Converts CJK radical characters to their corresponding ideographs.
- Example: `⾔⾨⾷` (Kangxi radicals) → `言門食`

### 14. **Spaces** (`spaces`)
Normalizes various Unicode space characters to standard ASCII space.
- Example: `A　B` (ideographic space) → `A B`

### 15. **Roman Numerals** (`roman-numerals`)
Converts Unicode Roman numeral characters to their ASCII letter equivalents.
- Example: `Ⅰ Ⅱ Ⅲ` → `I II III`, `ⅰ ⅱ ⅲ` → `i ii iii`

### 16. **Small Hirakatas** (`small-hirakatas`)
Converts small hiragana and katakana characters to their ordinary-sized equivalents.
- Example: `ぁぃぅ` → `あいう`, `ァィゥ` → `アイウ`

### 17. **Archaic Hirakatas** (`archaic-hirakatas`)
Converts archaic kana (hentaigana) to their modern hiragana or katakana equivalents.
- Example: `𛀁` → `え`

### 18. **Historical Hirakatas** (`historical-hirakatas`)
Converts historical hiragana and katakana characters to their modern equivalents.
- Options: `hiraganas` ("simple", "decompose", or "skip"), `katakanas` ("simple", "decompose", or "skip"), `voicedKatakanas` ("decompose" or "skip")
- Example: `ゐ` → `い` (simple), `ゐ` → `うぃ` (decompose), `ヰ` → `イ` (simple)

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yosina-lib/yosina.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
