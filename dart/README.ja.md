# Yosina Dart

Yosina日本語テキスト翻字ライブラリのDart実装。

## 概要

Yosinaは、日本語テキスト処理でよく必要とされる様々なテキスト正規化および変換機能を提供する日本語テキスト翻字ライブラリです。

## インストール

`pubspec.yaml`に以下を追加：

```yaml
dependencies:
  yosina: ^2.0.0
```

## 使用方法

### 基本的な使用方法

```dart
import 'package:yosina/yosina.dart';

// シンプルなトランスリテレータを作成
final transliterator = SpacesTransliterator();
final result = transliterator.transliterate('Hello　World'); // 全角スペース
print(result); // "Hello World" (通常のスペースに正規化)
```

### レシピベースの使用方法（推奨）

```dart
import 'package:yosina/yosina.dart';

// 複数の変換を使用してレシピを作成
final recipe = TransliterationRecipe(
  replaceSpaces: true,
  replaceCircledOrSquaredCharacters: true,
  replaceCombinedCharacters: true,
  kanjiOldNew: true,
  toFullwidth: true,
);

final transliterator = Yosina.makeTransliterator(recipe);

// 様々な特殊文字で使用
final input = '①②③　ⒶⒷⒸ　㍿㍑㌠㋿'; // 丸囲み数字、文字、表意文字空白、結合文字
final result = transliterator.transliterate(input);
print(result); // "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

// 旧字体を新字体に変換
final oldKanji = '舊字體';
final result = transliterator.transliterate(oldKanji);
print(result); // "旧字体"

// 半角カタカナを全角に変換
final halfWidth = 'ﾃｽﾄﾓｼﾞﾚﾂ';
final result = transliterator.transliterate(halfWidth);
print(result); // "テストモジレツ"
```

### 高度な設定

```dart
import 'package:yosina/yosina.dart';

// 複数のトランスリテレータをチェーン
final configs = [
  TransliteratorConfig.kanjiOldNew(),
  TransliteratorConfig.spaces(),
  TransliteratorConfig.radicals(),
];

final transliterator = Yosina.makeTransliterator(configs);
final result = transliterator.transliterate(inputText);
```

### 個別のトランスリテレータを使用

```dart
// ひらがなをカタカナに変換
final hiraKata = HiraKataTransliterator(mode: HiraKataMode.hiraToKata);
final result = hiraKata.transliterate('ひらがな');
print(result); // "ヒラガナ"

// 長音記号の処理
final prolonged = ProlongedSoundMarksTransliterator();
final result = prolonged.transliterate('データ-ベース');
print(result); // "データーベース"
```

## 要件

- Dart 2.12以降（null safetyサポート）

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

### セットアップ

```bash
# 依存関係をインストール
dart pub get
```

### テスト

```bash
# すべてのテストを実行
dart test

# 特定のテストを実行
dart test test/transliterators_test.dart
```

### コード生成

トランスリテレータデータはJSONファイルから生成されます：

```bash
dart run codegen/generate.dart
```

## プロジェクト構造

```
dart/
├── lib/
│   ├── src/
│   │   ├── chained_transliterator.dart     # チェーントランスリテレータ
│   │   ├── char.dart                       # 文字データ構造
│   │   ├── chars.dart                      # 文字配列ユーティリティ
│   │   ├── transliterator.dart             # トランスリテレータ基底クラス
│   │   ├── transliteration_recipe.dart      # レシピ設定
│   │   └── transliteration_registry.dart    # トランスリテレータレジストリ
│   └── yosina.dart                         # メインAPI
├── test/
│   ├── transliterators_test.dart           # トランスリテレータテスト
│   └── yosina_test.dart                    # 統合テスト
├── codegen/
│   └── generate.dart                       # コードジェネレータ
└── pubspec.yaml                            # パッケージ設定
```

## ライセンス

MITライセンス。詳細はメインプロジェクトのREADMEを参照してください。
