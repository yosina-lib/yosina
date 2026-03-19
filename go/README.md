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
    recipe := &yosina.TransliterationRecipe{
        ReplaceSpaces: true,
        KanjiOldNew: true,
        ReplaceCircledOrSquaredCharacters: true,
        ReplaceCombinedCharacters: true,
        HiraKata: "hira-to-kata",  // Convert hiragana to katakana
        ReplaceJapaneseIterationMarks: true,  // Expand iteration marks
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

    // Demonstrate hiragana to katakana conversion with iteration marks
    mixedText := "学問のすゝめ"
    result, err = transliterator(mixedText)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println(result) // "学問ノススメ"
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
        yosina.NewTransliteratorConfig("hira-kata", map[string]interface{}{
            "mode": "kata-to-hira",  // Convert katakana to hiragana
        }),
        yosina.NewTransliteratorConfig("japanese-iteration-marks", nil),  // Expand iteration marks like 々, ゝゞ, ヽヾ
    }

    transliterator, err := yosina.MakeTransliterator(configs)
    if err != nil {
        log.Fatal(err)
    }

    // Example with various transformations including the new ones
    inputText := "カタカナでの時々の佐々木さん"
    result, err := transliterator(inputText)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println(result) // "かたかなでの時時の佐佐木さん"
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

### Code Generation

Some transliterators are generated from data files:

```bash
go run internal/codegen/main.go
```

This generates transliterators from the JSON data files in the `../data` directory.

### Testing

```bash
go test -v
```

## License

MIT License (same as other Yosina implementations)
