# Yosina Project

- [日本語](./README.ja.md)

## Package Repositories

Yosina is available through the following package repositories:

| Language | Package Repository | Install Command |
|----------|-------------------|-----------------|
| JavaScript/TypeScript | [npm](https://www.npmjs.com/package/@yosina-lib/yosina) | `npm install @yosina-lib/yosina` |
| Python | [PyPI](https://pypi.org/project/yosina/) | `pip install yosina` |
| Rust | [crates.io](https://crates.io/crates/yosina) | `cargo add yosina` |
| Java | [Maven Central](https://central.sonatype.com/artifact/io.yosina/yosina-java) | See [Quick Start](#java) |
| Ruby | [RubyGems](https://rubygems.org/gems/yosina) | `gem install yosina` |
| Go | [Go Packages](https://pkg.go.dev/github.com/yosina-lib/yosina/go) | `go get github.com/yosina-lib/yosina/go` |
| PHP | [Packagist](https://packagist.org/packages/yosina/yosina) | `composer require yosina-lib/yosina` |
| C# (.NET) | [NuGet](https://www.nuget.org/packages/Yosina) | `dotnet add package Yosina` |
| Dart | [pub.dev](https://pub.dev/packages/yosina) | `dart pub add yosina` |
| Swift | Swift Package Manager | See [Quick Start](#swift) |

## Introduction

Yosina is a transliteration library that specifically deals with the letters and symbols used in Japanese writing. Japanese has a long history with its unique writing system which not only incorporates different kinds of characters, such as those from Chinese and English, but is also influenced by various writing systems, including German and French. There also lie quite complicated consequences in the Japanese standards of coded character sets, which is still causing uncertainties even after the Unicode standard was deployed widely.

The name "Yosina" is taken from the old Japanese adverb "Yoshina-ni", which means suitably, appropriately, or "as you think best". Developers tackling Japanese texts should have always wondered why that many variations exist for the same letter, and once wished there would be a thing that lets them forget all the gotchas. Yosina was named in the hope it will be a way for the developers to better handle such texts.

## Features

Yosina can handle various Japanese text transformations including:

- **Conversion between half-width and full-width**: Convert half-width katakana and symbols to their full-width counterparts, and vice versa.

    ![Conversion example](./common/assets/conversion-example1.svg)

    ![Conversion example](./common/assets/conversion-example2.svg)

- **Visually-ambiguous character handling**: Contextually replace hyphen-minuses between katakana/hiragana with long-vowel marks and vice versa.

    ![Conversion example](./common/assets/conversion-example3.svg)

    ![Conversion example](./common/assets/conversion-example4.svg)

- **Old-style to new-style kanji conversion**: Transform old-style glyphs (旧字体; kyu-ji-tai) to modern forms (新字体; shin-ji-tai).

    ![Conversion example](./common/assets/conversion-example5.svg)

- **Hiragana and Katakana conversion**: Convert between Hiragana and Katakana scripts bidirectionally, handling voiced and semi-voiced characters correctly.

- **Japanese iteration mark expansion**: Expand iteration marks (々, ゝ, ゞ, ヽ, ヾ) by repeating the preceding character with proper voicing handling.

## Multi-Language Support

Yosina is available in multiple programming languages:

- **[JavaScript/TypeScript](javascript/)** - Original implementation with comprehensive features (Node.js 22+ / Major Browsers / Deno 1.28+)
- **[Python](python/)** - Python port with Pythonic interface (Python 3.10+)
- **[Rust](rust/)** - High-performance Rust implementation (Rust 2021 edition and later)
- **[Java](java/)** - Java implementation with Gradle build system (Java 17+)
- **[Ruby](ruby/)** - Ruby implementation with idiomatic Ruby interface (Ruby 2.7+)
- **[Go](go/)** - Go implementation with error handling and performance focus (Go 1.21+)
- **[PHP](php/)** - PHP implementation supporting modern PHP features (PHP 8.2+)
- **[C#](csharp/)** - C# implementation with .NET support and code generation (.NET 9.0+)
- **[Swift](swift/)** - Swift implementation with Swift Package Manager support (Swift 5.0+)
- **[Dart](dart/)** - Dart implementation for Flutter and Dart applications (Dart 3.0+)

## Quick Start

### JavaScript/TypeScript

```bash
npm install @yosina-lib/yosina
```

```javascript
import { makeTransliterator, TransliterationRecipe } from '@yosina-lib/yosina';

// Using recipes (recommended)
const recipe = new TransliterationRecipe({
  kanjiOldNew: true,
  toHalfwidth: true,
  replaceSuspiciousHyphensToprolongedSoundMarks: true
});

const transliterator = makeTransliterator(recipe);
const result = transliterator('some japanese text');
console.log(result);
```

### Python

```bash
pip install yosina
```

```python
from yosina import make_transliterator, TransliterationRecipe

# Using recipes (recommended)
recipe = TransliterationRecipe(
    kanji_old_new=True,
    jisx0201_and_alike=True,
    replace_suspicious_hyphens_to_prolonged_sound_marks=True
)

transliterator = make_transliterator(recipe)
result = transliterator("some japanese text")
print(result)
```

### Rust

Add to your `Cargo.toml`:

```toml
[dependencies]
yosina = "0.1.0"
```

### Java

Add to your `build.gradle`:

```gradle
dependencies {
    implementation 'io.yosina:yosina:0.1.0'
}
```

```java
import io.yosina.Yosina;
import io.yosina.TransliterationRecipe;
import java.util.function.Function;

// Using recipes (recommended)
TransliterationRecipe recipe = new TransliterationRecipe()
    .withKanjiOldNew(true)
    .withCombineDecomposedHiraganasAndKatakanas(true)
    .withReplaceSpaces(true);

Function<String, String> transliterator = Yosina.makeTransliterator(recipe);
String result = transliterator.apply("some japanese text");
System.out.println(result);
```

### Ruby

```bash
gem install yosina
```

```ruby
require 'yosina'

# Using recipes (recommended)
recipe = Yosina::TransliterationRecipe.new(
  kanji_old_new: true,
  replace_spaces: true,
  replace_suspicious_hyphens_to_prolonged_sound_marks: true
)

transliterator = Yosina.make_transliterator(recipe)
result = transliterator.call("some japanese text")
puts result
```

### Go

```bash
go get github.com/yosina-lib/yosina/go
```

```go
package main

import (
    "fmt"
    "log"
    "github.com/yosina-lib/yosina/go"
)

func main() {
    recipe := &yosina.TransliterationRecipe{
        ReplaceSpaces: true,
        KanjiOldNew: true,
    }
    
    transliterator, err := yosina.MakeTransliterator(recipe)
    if err != nil {
        log.Fatal(err)
    }
    
    result, err := transliterator("some japanese text")
    if err != nil {
        log.Fatal(err)
    }
    
    fmt.Println(result)
}
```

### PHP

```bash
composer require yosina/yosina
```

```php
<?php

use Yosina\TransliterationRecipe;
use Yosina\Yosina;

$recipe = new TransliterationRecipe(
    replaceSpaces: true,
    kanjiOldNew: true
);

$transliterator = Yosina::makeTransliterator($recipe);
$result = $transliterator('some japanese text');
echo $result;
```

### C#

```bash
dotnet add package Yosina
```

```csharp
using Yosina;

// Using recipes (recommended)
var recipe = new TransliterationRecipe
{
    ReplaceSpaces = true,
    ReplaceRadicals = true,
    KanjiOldNew = true
};

var transliterator = Yosina.MakeTransliterator(recipe);
var result = transliterator("some japanese text");
Console.WriteLine(result);
```

### Swift

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yosina-lib/yosina-swift", from: "0.1.0")
]
```

```swift
import Yosina

// Using recipes (recommended)
let recipe = TransliterationRecipe(
    kanjiOldNew: true,
    toHalfwidth: true,
    replaceSpaces: true
)

let transliterator = try recipe.makeTransliterator()
let result = transliterator.transliterate("some japanese text")
print(result)
```

### Dart

```bash
dart pub add yosina
```

```dart
import 'package:yosina/yosina.dart';

// Using recipes (recommended)
final recipe = TransliterationRecipe(
  kanjiOldNew: true,
  toHalfwidth: true,
  replaceSpaces: true,
);

final transliterator = makeTransliterator(recipe);
final result = transliterator('some japanese text');
print(result);
```

## Project Scope and Limitations

While it is known that similar problems exist in other languages such as Korean, the library only handles characters that appear in Japanese writing for the time being.

The only coded character set (CCS) the library handles is Unicode. It assumes CCSes defined in the JIS standards are backed by the Unicode character set of a certain version, but not for the opposite.

JIS X 0201 specifies control sequences to render alphabets with diacritics by combining ordinary latin alphabets and one of particular symbols such as QUOTATION MARK and APOSTROPHE along with the control codes specified in JIS X 0211. However, such sequences will not be supported because of the reason above.

## Available Transliterators

Yosina provides 14 specialized transliterators that can be used individually or combined through the recipe system:

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

## Using Transliterators with Recipes

The recommended way to use transliterators is through the recipe system, which provides a high-level interface:

```javascript
const recipe = new TransliterationRecipe({
  kanjiOldNew: true,                     // Uses kanji-old-new
  toFullwidth: true,                      // Uses jisx0201-and-alike
  replaceSpaces: true,                    // Uses spaces
  hiraKata: "hira-to-kata",              // Uses hira-kata
  replaceCombinedCharacters: true         // Uses combined
});

const transliterator = makeTransliterator(recipe);
```

For advanced use cases, you can also create custom transliterator chains using the lower-level API.

## Standards and Datasets

The following standards are adopted to constitute the Yosina specification:

- JIS X 0201:1997
- JIS X 0208:1997, JIS X 0208:2004
- JIS X 0213
- [Unicode 12.1](https://www.unicode.org/versions/Unicode12.1.0/)

The following publicly-available datasets are also employed:

- [Adobe-Japan1-7](https://github.com/adobe-type-tools/Adobe-Japan1/)
- [UniJIS-UTF32-H CMAP](https://github.com/adobe-type-tools/cmap-resources/)
- [UniJIS2004-UTF32-H CMAP](https://github.com/adobe-type-tools/cmap-resources/)
- [CVJKI Ideograph Database](https://kanji-database.sourceforge.net/)


## Examples

Example implementations and usage patterns can be found in the [`examples/`](examples/) directory.

## License

MIT License. See individual language implementations for specific license details.

## Contributing

Contributions are welcome! Please ensure that any changes maintain compatibility across all language implementations and follow the existing code style.

## Related Projects

For detailed specifications and additional documentation, see the [Yosina Specification](https://github.com/yosina-lib/yosina-spec) repository.
