# Yosina Go

A Go port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a transliteration library that specifically deals with the letters and symbols used in Japanese writing.

## Usage

```go
package main

import (
    "fmt"
    "log"

    "github.com/yosina-lib/yosina/go"
)

func main() {
    // Create a transliterator using a recipe
    recipe := &yosina.TransliteratorRecipe{
        ReplaceSpaces: true,
        KanjiOldNew: true,
        ReplaceCircledOrSquaredCharacters: true,
        ReplaceCombinedCharacters: true,
        ToFullwidth: &yosina.ToFullwidthOptions{
            Enabled: true,
        },
    }

    transliterator, err := yosina.MakeTransliterator(recipe)
    if err != nil {
        log.Fatal(err)
    }

    // Use it to transliterate text with various special characters
    input := "①②③　ⒶⒷⒸ　㍿㍑㌠㋿" // circled numbers, letters, ideographic space, combined characters
    result, err := transliterator(input)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println(result) // "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

    // Convert old kanji to new
    oldKanji := "舊字體"
    result, err = transliterator(oldKanji)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println(result) // "旧字体"

    // Convert half-width katakana to full-width
    halfWidth := "ﾃｽﾄﾓｼﾞﾚﾂ"
    result, err = transliterator(halfWidth)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println(result) // "テストモジレツ"
}
```

### Advanced Usage with Configs

```go
package main

import (
    "fmt"
    "log"

    "github.com/yosina-lib/yosina/go"
)

func main() {
    // Create transliterator with specific configurations
    configs := []*yosina.TransliteratorConfig{
        yosina.NewTransliteratorConfig("spaces", nil),
        yosina.NewTransliteratorConfig("kanji-old-new", nil),
        yosina.NewTransliteratorConfig("radicals", nil),
    }

    transliterator, err := yosina.MakeTransliterator(configs)
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

### Using Individual Transliterators

```go
package main

import (
    "fmt"
    "log"

    "github.com/yosina-lib/yosina/go"
)

func main() {
    // Create a circled-or-squared transliterator
    circledFactory := &yosina.CircledOrSquaredTransliteratorFactory{}
    circledTransliterator, err := circledFactory.NewTransliterator()
    if err != nil {
        log.Fatal(err)
    }

    pool := yosina.NewCharPool()
    chars := pool.BuildCharArray("①②③ⒶⒷⒸ")

    result, err := circledTransliterator.Transliterate(pool, chars)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println(yosina.FromChars(result)) // "123ABC"

    // Create a combined transliterator
    combinedFactory := &yosina.CombinedTransliteratorFactory{}
    combinedTransliterator, err := combinedFactory.NewTransliterator()
    if err != nil {
        log.Fatal(err)
    }

    chars2 := pool.BuildCharArray("㍿㍑㌠㋿") // combined characters
    result2, err := combinedTransliterator.Transliterate(pool, chars2)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println(yosina.FromChars(result2)) // "株式会社リットルサンチーム令和"
}
```

## Installation

```bash
go get github.com/yosina-lib/yosina/go
```

## Available Transliterators

- `circled-or-squared`: Replace circled or squared alphanumeric characters with plain equivalents
- `combined`: Replace combined characters with their individual character sequences
- `hira-kata-composition`: Hiragana/katakana composition (stub)
- `hyphens`: Handle hyphen replacement (stub)
- `ideographic-annotations`: Handle ideographic annotation marks
- `ivs-svs-base`: IVS/SVS handling (stub)
- `jisx0201-and-alike`: Convert JIS X 0201 and similar characters (stub)
- `kanji-old-new`: Convert old kanji forms to new forms
- `mathematical-alphanumerics`: Normalize mathematical notation
- `prolonged-sound-marks`: Handle prolonged sound marks (stub)
- `radicals`: Convert Kangxi radicals to CJK ideographs
- `spaces`: Normalize various Unicode space characters

## Development

### Code Generation

Some transliterators are generated from data files:

```bash
go run cmd/codegen/main.go
```

This generates transliterators from the JSON data files in the `../data` directory.

### Testing

```bash
go test -v
```

## Project Status

This is a working implementation with the core functionality ported from the other language versions. Some transliterators are still stub implementations and need to be completed:

- Full JIS X 0201 support
- Complete hyphens transliterator with precedence logic
- IVS/SVS base transliterator
- Hiragana/katakana composition

## License

MIT License (same as other Yosina implementations)
