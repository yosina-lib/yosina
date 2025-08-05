# Yosina Swift

Yosina日本語テキスト翻字ライブラリのSwift実装。

## 概要

Yosinaは、日本語テキスト処理でよく必要とされる様々なテキスト正規化および変換機能を提供する日本語テキスト翻字ライブラリです。

## 機能

- **文字正規化**: 空白、ハイフン、数学記号など
- **日本語特有の翻字**:
  - 長音記号変換
  - ひらがな/カタカナ合成（結合文字付き）
  - JIS X 0201（半角/全角）変換
  - 旧字体から新字体への変換
- **Unicode異体字シーケンス**: IVS/SVSサポート
- **チェーン翻字**: 複数のトランスリテレータを組み合わせ

## インストール

Swiftプロジェクトにこのパッケージを追加：

```swift
dependencies: [
    .package(path: "../path/to/yosina/swift")
]
```

## 使用方法

### 基本的な使用方法

```swift
import Yosina

// シンプルなトランスリテレータを作成
let transliterator = SpacesTransliterator().stringTransliterator
let result = transliterator("Hello　World") // 全角スペース
// 結果: "Hello World" (通常のスペースに正規化)
```

### レシピベースの使用方法（推奨）

```swift
import Yosina

// 複数の変換を使用してレシピを作成
var recipe = TransliterationRecipe()
recipe.kanjiOldNew = true
recipe.replaceSpaces = true
recipe.replaceCircledOrSquaredCharacters = .enabled
recipe.replaceCombinedCharacters = true
recipe.toFullwidth = .enabled

// トランスリテレータを作成
let transliterator = try recipe.makeTransliterator()

// 様々な特殊文字で使用
let input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿" // 丸囲み数字、文字、表意文字空白、結合文字
let result = transliterator(input)
// 結果: "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"
```

### 設定ベースの使用方法

```swift
import Yosina

// 直接設定でトランスリテレータを作成
let configs: [TransliteratorConfig] = [
    .spaces,
    .prolongedSoundMarks,
    .jisx0201AndAlike()
]

let transliterator = configs.makeTransliterator()
let result = transliterator("データ-　ベース")
// 結果: "データー ベース"
```

### 個別のトランスリテレータ

```swift
// 半角から全角への変換
let jisTransliterator = Jisx0201AndAlikeTransliterator().stringTransliterator
let fullwidth = jisTransliterator("ABC123")
// 結果: "ＡＢＣ１２３"

// ひらがな・カタカナ合成
let composer = HiraKataCompositionTransliterator().stringTransliterator
let composed = composer("か\u{3099}") // か + 結合濁点
// 結果: "が"
```

## 要件

- Swift 5.0以降
- macOS 10.15以降 / iOS 13.0以降 / tvOS 13.0以降 / watchOS 6.0以降

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

## 開発

### テスト

```bash
swift test
```

### ビルド

```bash
swift build
```

## ライセンス

MITライセンス。詳細はメインプロジェクトのREADMEを参照してください。