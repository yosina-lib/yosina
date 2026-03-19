# Yosina Go

Yosina日本語テキスト翻字ライブラリのGoポート。

## 概要

Yosinaは、日本語の文字や記号を専門的に扱う翻字ライブラリです。

## 使用方法

```go
package main

import (
    "fmt"
    "log"

    "github.com/yosina-lib/yosina/go"
)

func main() {
    // レシピを使用してトランスリテレータを作成
    recipe := &yosina.TransliterationRecipe{
        ReplaceSpaces: true,
        KanjiOldNew: true,
        ReplaceCircledOrSquaredCharacters: true,
        ReplaceCombinedCharacters: true,
        HiraKata: "hira-to-kata",  // ひらがなをカタカナに変換
        ReplaceJapaneseIterationMarks: true,  // 繰り返し記号を展開
        ToFullwidth: &yosina.ToFullwidthOptions{
            Enabled: true,
        },
    }

    transliterator, err := yosina.MakeTransliterator(recipe)
    if err != nil {
        log.Fatal(err)
    }

    // 様々な特殊文字でテキストを翻字
    input := "①②③　ⒶⒷⒸ　㍿㍑㌠㋿" // 丸囲み数字、文字、表意文字空白、結合文字
    result, err := transliterator(input)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println(result) // "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

    // 旧字体を新字体に変換
    oldKanji := "舊字體"
    result, err = transliterator(oldKanji)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println(result) // "旧字体"

    // 半角カタカナを全角に変換
    halfWidth := "ﾃｽﾄﾓｼﾞﾚﾂ"
    result, err = transliterator(halfWidth)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println(result) // "テストモジレツ"

    // ひらがなからカタカナへの変換と繰り返し記号のデモ
    mixedText := "学問のすゝめ"
    result, err = transliterator(mixedText)
    if err != nil {
        log.Fatal(err)
    }
    fmt.Println(result) // "学問ノススメ"
}
```

### 設定を使用した高度な使用方法

```go
package main

import (
    "fmt"
    "log"

    "github.com/yosina-lib/yosina/go"
)

func main() {
    // 特定の設定でトランスリテレータを作成
    configs := []*yosina.TransliteratorConfig{
        yosina.NewTransliteratorConfig("spaces", nil),
        yosina.NewTransliteratorConfig("kanji-old-new", nil),
        yosina.NewTransliteratorConfig("radicals", nil),
        yosina.NewTransliteratorConfig("hira-kata", map[string]interface{}{
            "mode": "kata-to-hira",  // カタカナをひらがなに変換
        }),
        yosina.NewTransliteratorConfig("japanese-iteration-marks", nil),  // 々、ゝゞ、ヽヾなどの繰り返し記号を展開
    }

    transliterator, err := yosina.MakeTransliterator(configs)
    if err != nil {
        log.Fatal(err)
    }

    // 新しい変換を含む様々な変換の例
    inputText := "カタカナでの時々の佐々木さん"
    result, err := transliterator(inputText)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println(result) // "かたかなでの時時の佐佐木さん"
}
```

### 個別のトランスリテレータを使用

```go
package main

import (
    "fmt"
    "log"

    "github.com/yosina-lib/yosina/go"
)

func main() {
    // 丸囲み・角囲みトランスリテレータを作成
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

    // 結合トランスリテレータを作成
    combinedFactory := &yosina.CombinedTransliteratorFactory{}
    combinedTransliterator, err := combinedFactory.NewTransliterator()
    if err != nil {
        log.Fatal(err)
    }

    chars2 := pool.BuildCharArray("㍿㍑㌠㋿") // 結合文字
    result2, err := combinedTransliterator.Transliterate(pool, chars2)
    if err != nil {
        log.Fatal(err)
    }

    fmt.Println(yosina.FromChars(result2)) // "株式会社リットルサンチーム令和"
}
```

## インストール

```bash
go get github.com/yosina-lib/yosina/go
```

## 利用可能なトランスリテレータ

### 1. **丸囲み・角囲み文字** (`circled-or-squared`)
丸囲みや角囲みの文字を通常の文字に変換します。
- オプション: `templates` (カスタムレンダリング)、`includeEmojis` (絵文字を含める)
- 例: `①②③` → `(1)(2)(3)`、`㊙㊗` → `(秘)(祝)`

### 2. **結合文字** (`combined`)
結合文字を個別の文字シーケンスに展開します。
- 例: `㍻` (平成) → `平成`、`㈱` → `(株)`

### 3. **ひらがな・カタカナ合成** (`hira-kata-composition`)
分解されたひらがなとカタカナを合成された等価文字に結合します。
- オプション: `composeNonCombiningMarks` (非結合マークを合成)
- 例: `か + ゙` → `が`、`ヘ + ゜` → `ペ`

### 4. **ひらがな・カタカナ** (`hira-kata`)
ひらがなとカタカナの間で双方向に変換します。
- オプション: `mode` ("hira-to-kata" または "kata-to-hira")
- 例: `ひらがな` → `ヒラガナ` (hira-to-kata)

### 5. **ハイフン** (`hyphens`)
様々なダッシュ・ハイフン記号を日本語で一般的に使用されるものに置き換えます。
- オプション: `precedence` (マッピング優先順位)
- 利用可能なマッピング: "ascii"、"jisx0201"、"jisx0208_90"、"jisx0208_90_windows"、"jisx0208_verbatim"
- 例: `2019—2020` (emダッシュ) → `2019-2020`

### 6. **表意文字注釈** (`ideographic-annotations`)
伝統的な中国語から日本語への翻訳で使用される表意文字注釈を置き換えます。
- 例: `㆖㆘` → `上下`

### 7. **IVS-SVSベース** (`ivs-svs-base`)
表意文字異体字セレクタ（IVS）と標準化異体字セレクタ（SVS）を処理します。
- オプション: `charset`、`mode` ("ivs-or-svs" または "base")、`preferSVS`、`dropSelectorsAltogether`
- 例: `葛󠄀` (葛 + IVS) → `葛`

### 8. **日本語繰り返し記号** (`japanese-iteration-marks`)
繰り返し記号を前の文字を繰り返すことで展開します。
- 例: `時々` → `時時`、`いすゞ` → `いすず`

### 9. **JIS X 0201および類似** (`jisx0201-and-alike`)
半角・全角文字変換を処理します。
- オプション: `fullwidthToHalfwidth`、`convertGL` (英数字/記号)、`convertGR` (カタカナ)、`u005cAsYenSign`
- 例: `ABC123` → `ＡＢＣ１２３`、`ｶﾀｶﾅ` → `カタカナ`

### 10. **旧字体・新字体** (`kanji-old-new`)
旧字体の漢字を新字体に変換します。
- 例: `舊字體の變換` → `旧字体の変換`

### 11. **数学英数記号** (`mathematical-alphanumerics`)
数学英数記号を通常のASCIIに正規化します。
- 例: `𝐀𝐁𝐂` (数学太字) → `ABC`

### 12. **長音記号** (`prolonged-sound-marks`)
ハイフンと長音記号の間の文脈的な変換を処理します。
- オプション: `skipAlreadyTransliteratedChars`、`allowProlongedHatsuon`、`allowProlongedSokuon`、`replaceProlongedMarksFollowingAlnums`
- 例: `イ−ハト−ヴォ` (ハイフン付き) → `イーハトーヴォ` (長音記号)

### 13. **部首** (`radicals`)
CJK部首文字を対応する表意文字に変換します。
- 例: `⾔⾨⾷` (康熙部首) → `言門食`

### 14. **空白** (`spaces`)
様々なUnicode空白文字を標準ASCII空白に正規化します。
- 例: `A　B` (表意文字空白) → `A B`

### 15. **ローマ数字** (`roman-numerals`)
Unicodeのローマ数字文字を対応するASCII文字に変換します。
- 例: `Ⅰ Ⅱ Ⅲ` → `I II III`、`ⅰ ⅱ ⅲ` → `i ii iii`

### 16. **小書きひらがな・カタカナ** (`small-hirakatas`)
小書きのひらがな・カタカナを通常サイズの等価文字に変換します。
- 例: `ぁぃぅ` → `あいう`、`ァィゥ` → `アイウ`

### 17. **変体仮名** (`archaic-hirakatas`)
変体仮名（古い仮名文字）を現代のひらがな・カタカナに変換します。
- 例: `𛀁` → `え`

### 18. **歴史的仮名** (`historical-hirakatas`)
歴史的なひらがな・カタカナを現代の等価文字に変換します。
- オプション: `hiraganas` ("simple"、"decompose"、"skip")、`katakanas` ("simple"、"decompose"、"skip")、`voicedKatakanas` ("decompose"、"skip")
- 例: `ゐ` → `い` (simple)、`ゐ` → `うぃ` (decompose)、`ヰ` → `イ` (simple)

## 開発

### コード生成

一部のトランスリテレータはデータファイルから生成されます：

```bash
go run internal/codegen/main.go
```

これにより、`../data`ディレクトリのJSONデータファイルからトランスリテレータが生成されます。

### テスト

```bash
go test -v
```

## ライセンス

MITライセンス（他のYosina実装と同じ）