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
    .package(path: "../path/to/yosina/swift")
]
```

## Usage

### Basic Usage

```swift
import Yosina

// Create a simple transliterator
let transliterator = SpacesTransliterator().stringTransliterator
let result = transliterator.transliterate("Hello　World") // Full-width space
// Result: "Hello World" (normalized to regular space)
```

### Chained Transliterations

```swift
var config = TransliteratorConfig()
config.add(.spaces)
config.add(.prolongedSoundMarks)
config.add(.hyphens(precedence: [.unicode]))

let transliterator = Yosina.makeTransliterator(from: config)
let result = transliterator.transliterate("データ-　ベース")
// Result: "データー ベース"
```

### Japanese Text Processing

```swift
// Half-width to full-width conversion
let jisTransliterator = JisX0201AndAlikeTransliterator().stringTransliterator
let fullwidth = jisTransliterator.transliterate("ABC123")
// Result: "ＡＢＣ１２３"

// Hiragana/Katakana composition
let composer = HiraKataCompositionTransliterator().stringTransliterator
let composed = composer.transliterate("か\u{3099}") // か + combining dakuten
// Result: "が"
```

### Available Transliterators

- `SpacesTransliterator` - Normalizes various space characters
- `HyphensTransliterator` - Normalizes hyphen/dash characters
- `ProlongedSoundMarksTransliterator` - Converts hyphens after katakana to prolonged sound marks
- `HiraKataCompositionTransliterator` - Combines kana with dakuten/handakuten marks
- `JisX0201AndAlikeTransliterator` - Handles half-width/full-width conversions
- `RadicalsTransliterator` - Converts Kangxi radicals to CJK ideographs
- `MathematicalAlphanumericsTransliterator` - Normalizes mathematical alphanumeric symbols
- `KanjiOldNewTransliterator` - Converts old kanji forms to new forms
- `CircledOrSquaredTransliterator` - Handles circled/squared characters
- `CombinedTransliterator` - Replaces single characters with multiple characters
- `IdeographicAnnotationsTransliterator` - Handles ideographic annotation marks
- `IvsSvsBaseTransliterator` - Handles Unicode variation sequences

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
var config = TransliteratorConfig()
config.add(.custom(MyTransliterator()))
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