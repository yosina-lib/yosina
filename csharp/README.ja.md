# Yosina C#

Yosina日本語テキスト翻字ライブラリのC#ポート。

## 概要

Yosinaは、日本語の文字や記号を専門的に扱う翻字ライブラリです。

## 使用方法

### レシピを使用（推奨）

```csharp
using Yosina;

// 希望する変換でレシピを作成
var recipe = new TransliterationRecipe
{
    KanjiOldNew = true,
    ReplaceSpaces = true,
    ReplaceSuspiciousHyphensToProlongedSoundMarks = true,
    ReplaceCircledOrSquaredCharacters = TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.Enabled,
    ReplaceCombinedCharacters = true,
    HiraKata = "hira-to-kata",  // ひらがなをカタカナに変換
    ReplaceJapaneseIterationMarks = true,  // 繰り返し記号を展開
    ToFullwidth = TransliterationRecipe.ToFullwidthOptions.Enabled
};

// トランスリテレータを作成
var transliterator = Entrypoint.MakeTransliterator(recipe);

// 様々な特殊文字で使用
var input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"; // 丸囲み数字、文字、表意文字空白、結合文字
var result = transliterator(input);
Console.WriteLine(result); // "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

// 旧字体を新字体に変換
var oldKanji = "舊字體";
result = transliterator(oldKanji);
Console.WriteLine(result); // "旧字体"

// 半角カタカナを全角に変換
var halfWidth = "ﾃｽﾄﾓｼﾞﾚﾂ";
result = transliterator(halfWidth);
Console.WriteLine(result); // "テストモジレツ"

// ひらがなからカタカナへの変換と繰り返し記号のデモ
var mixedText = "学問のすゝめ";
result = transliterator(mixedText);
Console.WriteLine(result); // "学問ノススメ"
```

### 直接設定を使用

```csharp
using Yosina;

// 直接トランスリテレータ設定で構成
var configs = new[]
{
    new TransliteratorConfig("kanji-old-new"),
    new TransliteratorConfig("spaces"),
    new TransliteratorConfig("prolonged-sound-marks"),
    new TransliteratorConfig("circled-or-squared"),
    new TransliteratorConfig("combined")
};

var transliterator = Entrypoint.MakeTransliterator(configs);
var result = transliterator("日本語のテキスト");
Console.WriteLine(result);
```

### オプション付きの高度な使用方法

```csharp
using Yosina;
using Yosina.Transliterators;

// 特定のオプションで使用
var jisTransliterator = Entrypoint.MakeTransliterator(
    new TransliteratorConfig("jisx0201-and-alike", new Jisx0201AndAlikeTransliterator.Options
    {
        FullwidthToHalfwidth = true,
        ConvertGL = true
    })
);

var jisResult = jisTransliterator("Ｈｅｌｌｏ　Ｗｏｒｌｄ！"); // 全角ASCII
Console.WriteLine(jisResult); // "Hello World!"
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

## 開発

### プロジェクト

- **Yosina**: コアトランスリテレータと生成されたコードを含むメインライブラリ
- **Yosina.Tests**: ライブラリのユニットテスト
- **Yosina.Codegen**: JSONデータからトランスリテレータを作成するコード生成ツール

### コード生成

C#実装には、`../data`ディレクトリのJSONデータファイルからトランスリテレータクラスを作成するコード生成システムが含まれています。

### コード生成の実行

```bash
dotnet run --project src/Yosina.Codegen
```

### ビルドとテスト

#### ソリューションをビルド:
```bash
dotnet build
```

#### テストを実行:
```bash
dotnet test
```

### NuGetパッケージの作成:

```bash
dotnet pack
```

### コードフォーマット

```bash
dotnet format
```

### リンティング

```bash
dotnet format --verify-no-changes
```