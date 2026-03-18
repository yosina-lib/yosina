# Yosina Rust

Yosina日本語テキスト翻字ライブラリのRustポート。

## 概要

Yosinaは、日本語テキスト処理でよく必要とされる様々なテキスト正規化および変換機能を提供する日本語テキスト翻字ライブラリです。

## インストール

`Cargo.toml`に以下を追加：

```toml
[dependencies]
yosina = "1.1.0"
```

## 使用方法

### レシピを使用（推奨）

```rust
use yosina::{make_transliterator, TransliterationRecipe};
use yosina::recipes::{ReplaceCircledOrSquaredCharactersOptions, ToFullWidthOptions};

// 希望する変換でレシピを作成
let recipe = TransliterationRecipe {
    kanji_old_new: true,
    replace_spaces: true,
    replace_suspicious_hyphens_to_prolonged_sound_marks: true,
    replace_circled_or_squared_characters: ReplaceCircledOrSquaredCharactersOptions::Yes {
        exclude_emojis: false,
    },
    replace_combined_characters: true,
    to_fullwidth: ToFullWidthOptions::Yes {
        u005c_as_yen_sign: false,
    },
    ..Default::default()
};

// トランスリテレータを作成
let transliterator = make_transliterator(&recipe).unwrap();

// 様々な特殊文字で使用
let input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"; // 丸囲み数字、文字、空白、結合文字
let result = transliterator(input).unwrap();
println!("{}", result); // "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

// 旧字体を新字体に変換
let old_kanji = "舊字體";
let result = transliterator(old_kanji).unwrap();
println!("{}", result); // "旧字体"

// 半角カタカナを全角に変換
let half_width = "ﾃｽﾄﾓｼﾞﾚﾂ";
let result = transliterator(half_width).unwrap();
println!("{}", result); // "テストモジレツ"
```

### 直接設定を使用

```rust
use yosina::{make_transliterator, TransliteratorConfig::*};

// 直接トランスリテレータ設定で構成
let configs = vec![
    KanjiOldNew,
    Spaces,
    ProlongedSoundMarks(Default::default()),
    CircledOrSquared(Default::default()),
    Combined,
];

let transliterator = make_transliterator(&configs).unwrap();
let result = transliterator("日本語のテキスト").unwrap();
println!("{}", result); // 変換適用後のテキスト
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

このプロジェクトは標準的なRustツールを使用しています。

```bash
# ライブラリをビルド
cargo build

# テストを実行
cargo test

# リンティングを実行
cargo clippy

# フォーマットを実行
cargo fmt

# ドキュメントをビルド
cargo doc --open
```

## 要件

- Rust 1.70以上

## ライセンス

MIT
