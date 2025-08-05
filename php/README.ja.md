# Yosina PHP

Yosina日本語テキスト翻字ライブラリのPHPポート。

## 概要

Yosinaは、日本語テキスト処理でよく必要とされる様々なテキスト正規化および変換機能を提供する日本語テキスト翻字ライブラリです。

## 使用方法

```php
<?php

use Yosina\TransliterationRecipe;
use Yosina\Yosina;

// 複数の変換を使用してレシピを作成
$recipe = new TransliterationRecipe(
    replaceSpaces: true,
    replaceCircledOrSquaredCharacters: true,
    replaceCombinedCharacters: true,
    kanjiOldNew: true,
    toFullwidth: true
);

$transliterator = Yosina::makeTransliterator($recipe);

// 様々な特殊文字で使用
$input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"; // 丸囲み数字、文字、表意文字空白、結合文字
$result = $transliterator($input);
echo $result; // "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

// 旧字体を新字体に変換
$oldKanji = "舊字體";
$result = $transliterator($oldKanji);
echo $result; // "旧字体"

// 半角カタカナを全角に変換
$halfWidth = "ﾃｽﾄﾓｼﾞﾚﾂ";
$result = $transliterator($halfWidth);
echo $result; // "テストモジレツ"
```

### 高度な設定

```php
<?php

use Yosina\Yosina;

// 複数のトランスリテレータをチェーン
$transliterator = Yosina::makeTransliterator([
    ['kanji-old-new', []],
    ['spaces', []],
    ['radicals', []],
]);

$result = $transliterator($inputText);
```

## 要件

- PHP 8.2以降

## インストール

```bash
composer require yosina/yosina
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

### 前提条件

- PHP 7.4以降
- Composer (PHP依存関係マネージャー)

### セットアップ

開発依存関係をインストール：

```bash
composer install
```

### コード生成

トランスリテレータの実装は共有データファイルから生成されます：

```bash
php codegen/generate.php
```

これにより、`../data/`ディレクトリのJSONデータファイルからトランスリテレータクラスが生成されます。

### テスト

基本的なテストを実行：

```bash
php tests/BasicTest.php
```

### 開発ワークフロー

1. コードまたはデータファイルに変更を加える
2. データファイルを変更した場合は、トランスリテレータを再生成：
   ```bash
   php codegen/generate.php
   ```
3. テストを実行してすべてが動作することを確認：
   ```bash
   php tests/BasicTest.php
   ```

## プロジェクト構造

```
php/
├── src/
│   ├── Char.php                           # 文字データ構造
│   ├── Chars.php                          # 文字配列ユーティリティ
│   ├── TransliteratorInterface.php        # トランスリテレータインターフェース
│   ├── TransliteratorFactoryInterface.php # ファクトリインターフェース
│   ├── ChainedTransliterator.php          # チェーントランスリテレータ
│   ├── TransliterationRecipe.php           # レシピ設定
│   ├── TransliteratorRegistry.php         # トランスリテレータレジストリ
│   ├── Yosina.php                         # メインAPI
│   └── Transliterators/                   # 生成されたトランスリテレータ
│       ├── SpacesTransliterator.php
│       ├── RadicalsTransliterator.php
│       └── ...
├── tests/
│   └── BasicTest.php                      # 基本機能テスト
├── codegen/
│   └── generate.php                       # コードジェネレータ
├── composer.json                          # Composer設定
└── README.md                              # このファイル
```

## ライセンス

MITライセンス。詳細はメインプロジェクトのREADMEを参照してください。

## 貢献

これはより大きなYosinaプロジェクトの一部です。変更はすべての言語実装間で互換性を維持するようにしてください。