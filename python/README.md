# Yosina Python

A Python port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Usage

```python
from yosina import make_transliterator, TransliterationRecipe

# Create a recipe with desired transformations
recipe = TransliterationRecipe(
    kanji_old_new=True,
    replace_spaces=True,
    replace_suspicious_hyphens_to_prolonged_sound_marks=True,
    replace_circled_or_squared_characters=True,
    replace_combined_characters=True,
    hira_kata="hira-to-kata",  # Convert hiragana to katakana
    replace_japanese_iteration_marks=True,  # Expand iteration marks
    to_fullwidth=True,
)

# Create the transliterator
transliterator = make_transliterator(recipe)

# Use it with various special characters
input_text = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"  # circled numbers, letters, space, combined characters
result = transliterator(input_text)
print(result)  # "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

# Convert old kanji to new
old_kanji = "舊字體"
result = transliterator(old_kanji)
print(result)  # "旧字体"

# Convert half-width katakana to full-width
half_width = "ﾃｽﾄﾓｼﾞﾚﾂ"
result = transliterator(half_width)
print(result)  # "テストモジレツ"

# Demonstrate hiragana to katakana conversion with iteration marks
mixed_text = "学問のすゝめ"
result = transliterator(mixed_text)
print(result)  # "学問ノススメ"
```

### Using Direct Configuration

```python
from yosina import make_transliterator

# Configure with direct transliterator configs
configs = [
    ("kanji-old-new", {}),
    ("spaces", {}),
    ("prolonged-sound-marks", {"replace_prolonged_marks_following_alnums": True}),
    ("circled-or-squared", {}),
    ("combined", {}),
    ("hira-kata", {"mode": "kata-to-hira"}),  # Convert katakana to hiragana
    ("japanese-iteration-marks", {}),  # Expand iteration marks like 々, ゝゞ, ヽヾ
]

transliterator = make_transliterator(configs)

# Example with various transformations including the new ones
input_text = "カタカナでの時々の佐々木さん"
result = transliterator(input_text)
print(result)  # "かたかなでの時時の佐佐木さん"
```

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

## Requirements

- Python 3.10 or higher

## Installation

```bash
# Install with uv
uv add yosina

# Install with pip
pip install yosina
```

## Development

This project uses [uv](https://github.com/astral-sh/uv) for dependency management.

```bash
# Code generation
python -m codegen

# Install development dependencies
uv sync --extra dev

# Run tests
uv run pytest

# Run linting
uv run ruff check .

# Run formatting
uv run ruff format .

# Run type checking
uv run pyright
```

## Requirements

- Python 3.10+
- typing-extensions

## License

MIT