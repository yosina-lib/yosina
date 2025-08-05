# Yosinaプロジェクト

## はじめに

Yosinaは、日本語文字に使用される文字や記号を専門的に扱う翻字ライブラリです。日本語は、中国語や英語の文字だけでなく、ドイツ語やフランス語などの様々な文字体系の影響を受けた独特の文字体系を持つ長い歴史があります。また、日本の文字コード体系の標準には非常に複雑な問題があり、Unicodeが広く普及した後でも不確実性を引き起こし続けています。

「Yosina」という名前は、「適切に」「ふさわしく」「あなたが最善と思うように」という意味の古い日本語の副詞「よしなに」から取られています。日本語テキストを扱う開発者は、同じ文字に対してなぜこれほど多くのバリエーションが存在するのかと常に疑問に思い、そのような落とし穴をすべて忘れさせてくれるものがあればと願ったことがあるでしょう。Yosinaは、開発者がそのようなテキストをより適切に処理できる方法となることを願って名付けられました。

## 機能

Yosinaは、次のような様々な日本語テキスト変換を処理できます：

- **半角・全角変換**：半角カタカナや記号を全角に変換し、その逆も可能です。

    ![変換例](common/assets/conversion-example1.svg)

    ![変換例](common/assets/conversion-example2.svg)

- **視覚的に曖昧な文字の処理**：カタカナ・ひらがなの間のハイフンマイナスを長音記号に文脈的に置き換え、その逆も可能です。

    ![変換例](common/assets/conversion-example3.svg)

    ![変換例](common/assets/conversion-example4.svg)

- **旧字体から新字体への漢字変換**：旧字体の字形を現代の新字体に変換します。

    ![変換例](common/assets/conversion-example5.svg)

- **ひらがな・カタカナ変換**：ひらがなとカタカナの間で双方向に変換し、濁音・半濁音文字を正しく処理します。

- **日本語繰り返し記号の展開**：繰り返し記号（々、ゝ、ゞ、ヽ、ヾ）を前の文字を適切な濁音処理で繰り返すことで展開します。

## 多言語サポート

Yosinaは複数のプログラミング言語で利用可能です：

- **[JavaScript/TypeScript](javascript/)** - 包括的な機能を持つオリジナル実装 (Node.js 22+, 主要ブラウザ, Deno 1.28+)
- **[Python](python/)** - PythonicなインターフェースのPythonポート (Python 3.10+)
- **[Rust](rust/)** - 高性能なRust実装 (Rust 2021 edition以降)
- **[Java](java/)** - Gradleビルドシステムを使用したJava実装 (Java 17+)
- **[Ruby](ruby/)** - Ruby固有のインターフェースを持つRuby実装 (Ruby 2.7+)
- **[Go](go/)** - エラーハンドリングとパフォーマンスに重点を置いたGo実装 (Go 1.21+)
- **[PHP](php/)** - モダンなPHP機能をサポートするPHP実装 (PHP 8.2+)
- **[C#](csharp/)** - .NETサポートとコード生成機能を持つC#実装 (.NET 9.0+)

## クイックスタート

### JavaScript/TypeScript

```bash
npm install @yosina-lib/yosina
```

```javascript
import { makeTransliterator, TransliterationRecipe } from '@yosina-lib/yosina';

// レシピを使用(推奨)
const recipe = new TransliterationRecipe({
  kanjiOldNew: true,
  toHalfwidth: true,
  replaceSuspiciousHyphensToprolongedSoundMarks: true
});

const transliterator = makeTransliterator(recipe);
const result = transliterator('日本語のテキスト');
console.log(result);
```

### Python

```bash
pip install yosina
```

```python
from yosina import make_transliterator, TransliterationRecipe

# レシピを使用(推奨)
recipe = TransliterationRecipe(
    kanji_old_new=True,
    jisx0201_and_alike=True,
    replace_suspicious_hyphens_to_prolonged_sound_marks=True
)

transliterator = make_transliterator(recipe)
result = transliterator("日本語のテキスト")
print(result)
```

### Rust

`Cargo.toml`に追加：

```toml
[dependencies]
yosina = "0.1.0"
```

### Java

`build.gradle`に追加：

```gradle
dependencies {
    implementation 'io.yosina:yosina-java:0.1.0'
}
```

```java
import io.yosina.Yosina;
import io.yosina.TransliterationRecipe;
import java.util.function.Function;

// レシピを使用(推奨)
TransliterationRecipe recipe = new TransliterationRecipe()
    .withKanjiOldNew(true)
    .withCombineDecomposedHiraganasAndKatakanas(true)
    .withReplaceSpaces(true);

Function<String, String> transliterator = Yosina.makeTransliterator(recipe);
String result = transliterator.apply("日本語のテキスト");
System.out.println(result);
```

### Ruby

```bash
gem install yosina
```

```ruby
require 'yosina'

# レシピを使用(推奨)
recipe = Yosina::TransliterationRecipe.new(
  kanji_old_new: true,
  replace_spaces: true,
  replace_suspicious_hyphens_to_prolonged_sound_marks: true
)

transliterator = Yosina.make_transliterator(recipe)
result = transliterator.call("日本語のテキスト")
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
    
    result, err := transliterator("日本語のテキスト")
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
$result = $transliterator('日本語のテキスト');
echo $result;
```

### C#

```bash
dotnet add package Yosina
```

```csharp
using Yosina;

// レシピを使用(推奨)
var recipe = new TransliterationRecipe
{
    ReplaceSpaces = true,
    ReplaceRadicals = true,
    KanjiOldNew = true
};

var transliterator = Yosina.MakeTransliterator(recipe);
var result = transliterator("日本語のテキスト");
Console.WriteLine(result);
```

## プロジェクトの範囲と制限

韓国語などの他の言語でも同様の問題が存在することは知られていますが、このライブラリは現在のところ日本語の文字に現れる文字のみを処理します。

このライブラリが処理する唯一の文字符号化文字集合 (CCS) はUnicodeです。JIS標準で定義されたCCSは特定のバージョンのUnicode文字集合によって支えられていると仮定していますが、その逆は仮定していません。

JIS X 0201では、通常のラテン文字と引用符やアポストロフィなどの特定の記号をJIS X 0211で指定された制御符号と組み合わせて発音記号付きのアルファベットをレンダリングする制御シーケンスが規定されています。しかし、上記の理由により、そのようなシーケンスはサポートされません。

## 利用可能なトランスリテレータ

Yosinaは14の専門的なトランスリテレータを提供しており、レシピシステムを通じて個別に使用したり、組み合わせて使用したりできます：

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

## レシピシステムでのトランスリテレータの使用

トランスリテレータを使用する推奨方法は、高レベルインターフェースを提供するレシピシステムを通じてです：

```javascript
const recipe = new TransliterationRecipe({
  kanjiOldNew: true,                     // kanji-old-newを使用
  toFullwidth: true,                      // jisx0201-and-alikeを使用
  replaceSpaces: true,                    // spacesを使用
  hiraKata: "hira-to-kata",              // hira-kataを使用
  replaceCombinedCharacters: true         // combinedを使用
});

const transliterator = makeTransliterator(recipe);
```

高度な使用例では、低レベルAPIを使用してカスタムトランスリテレータチェーンを作成することもできます。

## 標準とデータセット

Yosina仕様を構成するために以下の標準が採用されています：

- JIS X 0201:1997
- JIS X 0208:1997, JIS X 0208:2004
- JIS X 0213
- [Unicode 12.1](https://www.unicode.org/versions/Unicode12.1.0/)

以下の公開データセットも使用されています：

- [Adobe-Japan1-7](https://github.com/adobe-type-tools/Adobe-Japan1/)
- [UniJIS-UTF32-H CMAP](https://github.com/adobe-type-tools/cmap-resources/)
- [UniJIS2004-UTF32-H CMAP](https://github.com/adobe-type-tools/cmap-resources/)
- [CVJKI漢字データベース](https://kanji-database.sourceforge.net/)


## 例

実装例と使用パターンは[`examples/`](examples/)ディレクトリにあります。

## ライセンス

MITライセンス。具体的なライセンスの詳細については、各言語実装を参照してください。

## 貢献

貢献を歓迎します！変更はすべての言語実装間で互換性を維持し、既存のコードスタイルに従うようにしてください。

## 関連プロジェクト

詳細な仕様と追加ドキュメントについては、[Yosina仕様](https://github.com/yosina-lib/yosina-spec)リポジトリを参照してください。