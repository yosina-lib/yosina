# Yosina Swift

A Swift implementation of the Yosina transliteration library for Japanese text processing.

## Features

- **Character normalization**: Spaces, hyphens, mathematical symbols, etc.
- **Japanese-specific transliterations**:
  - Prolonged sound marks conversion
  - Hiragana/Katakana composition with combining marks
  - JIS X 0201 (half-width/full-width) conversion
  - Old to new kanji form conversion
- **Unicode variation sequences**: IVS/SVS support
- **Chained transliterations**: Combine multiple transliterators

## Installation

Add this package to your Swift project:

```swift
dependencies: [
    .package(url: "https://github.com/yosina-lib/yosina-swift", from: "0.1.0")
]
```

## Usage

### Basic Usage

```swift
import Yosina

// Create a simple transliterator
let transliterator = SpacesTransliterator().stringTransliterator
let result = transliterator("Hello　World") // Full-width space
// Result: "Hello World" (normalized to regular space)
```

### Recipe-based Usage (Recommended)

```swift
import Yosina

// Create a recipe with desired transformations
var recipe = TransliterationRecipe()
recipe.kanjiOldNew = true
recipe.replaceSpaces = true
recipe.replaceCircledOrSquaredCharacters = .enabled
recipe.replaceCombinedCharacters = true
recipe.toFullwidth = .enabled

// Create the transliterator
let transliterator = try recipe.makeTransliterator()

// Use it with various special characters
let input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"
let result = transliterator(input)
// Result: "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"
```

### Configuration-based Usage

```swift
import Yosina

// Create transliterator with direct configurations
let configs: [TransliteratorConfig] = [
    .spaces,
    .prolongedSoundMarks,
    .jisx0201AndAlike()
]

let transliterator = configs.makeTransliterator()
let result = transliterator("データ-　ベース")
// Result: "データー ベース"
```

### Individual Transliterators

```swift
// Half-width to full-width conversion
let jisTransliterator = Jisx0201AndAlikeTransliterator().stringTransliterator
let fullwidth = jisTransliterator("ABC123")
// Result: "ＡＢＣ１２３"

// Hiragana/Katakana composition
let composer = HiraKataCompositionTransliterator().stringTransliterator
let composed = composer("か\u{3099}") // か + combining dakuten
// Result: "が"
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
Converts Roman numerals to Arabic numerals.
- Example: `Ⅰ Ⅱ Ⅲ` → `1 2 3`, `MCMXCIV` → `1994`

## Custom Transliterators

You can create custom transliterators by implementing the `Transliterator` protocol:

```swift
struct MyTransliterator: Transliterator {
    func transliterate<S: Sequence>(_ chars: S) -> [TransliteratorChar]
        where S.Element == TransliteratorChar {
        // Your implementation here
    }
}

// Use it with the configuration
let configs: [TransliteratorConfig] = [
    .custom(MyTransliterator())
]
let transliterator = configs.makeTransliterator()
```

## Testing

Run the tests with:

```bash
swift test
```

## Code Generation

Some transliterators are automatically generated from JSON data files. To regenerate:

```bash
cd codegen
swift run
```

## License

See the main project LICENSE file.