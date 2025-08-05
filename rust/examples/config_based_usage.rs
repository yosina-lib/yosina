//! Configuration-based usage example for Yosina Rust library.
//! This example demonstrates using direct transliterator configurations.

use anyhow::Result;
use yosina::transliterators::{
    Charset, IvsSvsBaseMode, IvsSvsBaseTransliteratorOptions,
    Jisx0201AndAlikeTransliteratorOptions, ProlongedSoundMarksTransliteratorOptions,
};
use yosina::{make_transliterator, ConfigsOrRecipe, TransliteratorConfig};

fn main() -> Result<()> {
    println!("=== Yosina Rust Configuration-based Usage Example ===\n");

    // Create transliterator with direct configurations
    let configs = vec![
        TransliteratorConfig::Spaces,
        TransliteratorConfig::ProlongedSoundMarks(ProlongedSoundMarksTransliteratorOptions {
            replace_prolonged_marks_following_alnums: true,
            ..Default::default()
        }),
        TransliteratorConfig::Jisx0201AndAlikeHalfwidthToFullwidth(
            Jisx0201AndAlikeTransliteratorOptions {
                ..Default::default()
            },
        ),
    ];

    let transliterator = make_transliterator(ConfigsOrRecipe::Configs(&configs))?;

    println!("--- Configuration-based Transliteration ---");

    // Test cases demonstrating different transformations
    let test_cases = vec![
        ("hello　world", "Space normalization"),
        ("カタカナ-テスト", "Prolonged sound mark handling"),
        ("ABC123", "Full-width conversion"),
        ("ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana conversion"),
    ];

    for (test_text, description) in test_cases {
        let result = transliterator(test_text)?;
        println!("{description}:");
        println!("  Input:  '{test_text}'");
        println!("  Output: '{result}'");
        println!();
    }

    // Demonstrate individual transliterators
    println!("--- Individual Transliterator Examples ---");

    // Spaces only
    let spaces_config = vec![TransliteratorConfig::Spaces];
    let spaces_only = make_transliterator(ConfigsOrRecipe::Configs(&spaces_config))?;
    let space_test = "hello\u{3000}world\u{00A0}test"; // ideographic space + non-breaking space
    println!(
        "Spaces only: '{}' → '{}'",
        space_test,
        spaces_only(space_test)?
    );

    // Kanji old-new only
    let kanji_config = vec![
        TransliteratorConfig::IvsSvsBase(IvsSvsBaseTransliteratorOptions {
            mode: IvsSvsBaseMode::IvsOrSvs(false),
            charset: Charset::Unijis2004,
            ..Default::default()
        }),
        TransliteratorConfig::KanjiOldNew,
        TransliteratorConfig::IvsSvsBase(IvsSvsBaseTransliteratorOptions {
            mode: IvsSvsBaseMode::Base,
            charset: Charset::Unijis2004,
            ..Default::default()
        }),
    ];
    let kanji_only = make_transliterator(ConfigsOrRecipe::Configs(&kanji_config))?;
    let kanji_test = "廣島檜";
    println!(
        "Kanji only: '{}' → '{}'",
        kanji_test,
        kanji_only(kanji_test)?
    );

    // JIS X 0201 conversion only
    let jisx0201_config = vec![TransliteratorConfig::Jisx0201AndAlikeHalfwidthToFullwidth(
        yosina::transliterators::Jisx0201AndAlikeTransliteratorOptions {
            ..Default::default()
        },
    )];
    let jisx0201_only = make_transliterator(ConfigsOrRecipe::Configs(&jisx0201_config))?;
    let jisx_test = "ﾊﾛｰ ﾜｰﾙﾄﾞ";
    println!(
        "JIS X 0201 only: '{}' → '{}'",
        jisx_test,
        jisx0201_only(jisx_test)?
    );

    Ok(())
}
