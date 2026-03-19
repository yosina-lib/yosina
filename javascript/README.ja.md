# Yosina JavaScript

Yosina日本語テキスト翻字ライブラリのTypeScriptポート。

## 概要

Yosinaは、日本語テキスト処理でよく必要とされる様々なテキスト正規化および変換機能を提供する日本語テキスト翻字ライブラリです。

## 使用方法

```typescript
import { makeTransliterator, TransliterationRecipe } from '@yosina-lib/yosina';

// 希望する変換でレシピを作成
const recipe: TransliterationRecipe = {
  kanjiOldNew: true,
  replaceSpaces: true,
  replaceSuspiciousHyphensToProlongedSoundMarks: true,
  replaceCircledOrSquaredCharacters: true,
  replaceCombinedCharacters: true,
  hiraKata: "hira-to-kata", // ひらがなをカタカナに変換
  replaceJapaneseIterationMarks: true, // 繰り返し記号を展開
  toFullwidth: true,
};

// トランスリテレータを作成
const transliterator = await makeTransliterator(recipe);

// 様々な特殊文字で使用
const input = '①②③　ⒶⒷⒸ　㍿㍑㌠㋿'; // 丸囲み数字、文字、空白、結合文字
const result = transliterator(input);
console.log(result); // "(1)(2)(3) (A)(B)(C) 株式会社リットルサンチーム令和"

// 旧字体を新字体に変換
const oldKanji = '舊字體';
const kanjiResult = transliterator(oldKanji);
console.log(kanjiResult); // "旧字体"

// 半角カタカナを全角に変換
const halfWidth = 'ﾃｽﾄﾓｼﾞﾚﾂ';
const fullWidthResult = transliterator(halfWidth);
console.log(fullWidthResult); // "テストモジレツ"

// ひらがなからカタカナへの変換と繰り返し記号のデモ
const mixedText = '学問のすゝめ';
const convertedResult = transliterator(mixedText);
console.log(convertedResult); // "学問ノススメ"
```

### 直接設定を使用

```typescript
import { makeTransliterator } from '@yosina-lib/yosina';

// 直接トランスリテレータ設定で構成
const configs = [
  ["kanji-old-new", {}],
  ["spaces", {}],
  ["prolonged-sound-marks", { replaceProlongedMarksFollowingAlnums: true }],
  ["circled-or-squared", {}],
  ["combined", {}],
  ["hira-kata", { mode: "kata-to-hira" }], // カタカナをひらがなに変換
  ["japanese-iteration-marks", {}], // 々、ゝゞ、ヽヾなどの繰り返し記号を展開
];

const transliterator = await makeTransliterator(configs);

// 新しい変換を含む様々な変換の例
const input = "カタカナでの時々の佐々木さん";
const result = transliterator(input);
console.log(result); // "かたかなでの時時の佐佐木さん"
```

## インストール

```bash
npm install @yosina-lib/yosina
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

このプロジェクトはTypeScriptを使用したNode.jsと、フォーマッティング/リンティングにBiomeを使用しています。

```bash
# 依存関係をインストール
npm install

# テストを実行
npm test

# リンティングを実行
npm run lint

# フォーマッティングを実行
npm run format

# ライブラリをビルド
npm run build

# ドキュメントを生成
npm run docs:build
```

## 要件

- Node.js 18+
- TypeScript 5.0+

## ライセンス

MIT