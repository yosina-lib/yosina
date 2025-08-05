# Yosina Project

- [日本語](./README.ja.md)

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

## Quick Start

### JavaScript/TypeScript

```bash
npm install @yosina-lib/yosina
```

```javascript
import { makeTransliterator, TransliteratorRecipe } from '@yosina-lib/yosina';

// Using recipes (recommended)
const recipe = new TransliteratorRecipe({
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
from yosina import make_transliterator, TransliteratorRecipe

# Using recipes (recommended)
recipe = TransliteratorRecipe(
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
    implementation 'lib.yosina:yosina-java:0.1.0'
}
```

```java
import lib.yosina.Yosina;
import lib.yosina.TransliteratorRecipe;
import java.util.function.Function;

// Using recipes (recommended)
TransliteratorRecipe recipe = new TransliteratorRecipe()
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
recipe = Yosina::TransliteratorRecipe.new(
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
    recipe := &yosina.TransliteratorRecipe{
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

use Yosina\TransliteratorRecipe;
use Yosina\Yosina;

$recipe = new TransliteratorRecipe(
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
var recipe = new TransliteratorRecipe
{
    ReplaceSpaces = true,
    ReplaceRadicals = true,
    KanjiOldNew = true
};

var transliterator = Yosina.MakeTransliterator(recipe);
var result = transliterator("some japanese text");
Console.WriteLine(result);
```

## Project Scope and Limitations

While it is known that similar problems exist in other languages such as Korean, the library only handles characters that appear in Japanese writing for the time being.

The only coded character set (CCS) the library handles is Unicode. It assumes CCSes defined in the JIS standards are backed by the Unicode character set of a certain version, but not for the opposite.

JIS X 0201 specifies control sequences to render alphabets with diacritics by combining ordinary latin alphabets and one of particular symbols such as QUOTATION MARK and APOSTROPHE along with the control codes specified in JIS X 0211. However, such sequences will not be supported because of the reason above.

## Transliterators

The following transliterators are available in Yosina:

- **CJK Radicals Transliterator**: Converts CJK radical characters to their corresponding ideographs
- **Ideographic Annotations Transliterator**: Handles ideographic annotation marks
- **Mathematical Alphanumeric Symbols Transliterator**: Normalizes mathematical notation characters
- **Hyphens Transliterator**: Manages hyphen-like characters and their contextual usage
- **Traditional to New Form Kanji Transliterator**: Converts old-style kanji to modern forms
- **JIS X 0201 and Alike Transliterator**: Handles half-width/full-width character conversion
- **Hiragana-Katakana Composition Transliterator**: Manages hiragana and katakana character composition
- **Prolonged Sound Marks Transliterator**: Handles long vowel marks in Japanese text
- **Spaces Transliterator**: Normalizes various Unicode space characters to standard ASCII space
- **Circled or Squared Transliterator**: Converts circled or squared alphanumeric characters to their plain equivalents
- **Combined Transliterator**: Expands combined characters into their individual character sequences

**Usage example:**
```javascript
// Text with various special characters
const input = "①②③　ⒶⒷⒸ"; 
// Contains: circled numbers (①②③), ideographic space, circled letters (ⒶⒷⒸ)

const result = transliterator(input);
console.log(result); // "123 ABC" (with regular ASCII characters)
```

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
