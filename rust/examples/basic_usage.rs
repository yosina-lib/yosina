//! Basic usage example for Yosina Rust library.
//! This example demonstrates the fundamental transliteration functionality.

use yosina::{make_transliterator, ConfigsOrRecipe, TransliteratorRecipe};

fn main() -> anyhow::Result<()> {
    println!("=== Yosina Rust Basic Usage Example ===\n");

    // Create a simple recipe for kanji old-to-new conversion
    let recipe = TransliteratorRecipe {
        kanji_old_new: true,
        ..Default::default()
    };

    let transliterator = make_transliterator(ConfigsOrRecipe::Recipe(&recipe))?;

    // Test text with old-style kanji
    let test_text = "舊字體の變換テスト";
    let result = transliterator(test_text)?;

    println!("Original: {test_text}");
    println!("Result:   {result}");

    // More comprehensive example
    println!("\n--- Comprehensive Example ---");

    let comprehensive_recipe = TransliteratorRecipe {
        kanji_old_new: true,
        replace_spaces: true,
        replace_suspicious_hyphens_to_prolonged_sound_marks: true,
        to_fullwidth: yosina::recipes::ToFullWidthOptions::Yes {
            u005c_as_yen_sign: false,
        },
        combine_decomposed_hiraganas_and_katakanas: true,
        replace_radicals: true,
        replace_circled_or_squared_characters:
            yosina::recipes::ReplaceCircledOrSquaredCharactersOptions::Yes {
                exclude_emojis: false,
            },
        replace_combined_characters: true,
        ..Default::default()
    };

    let comprehensive_transliterator =
        make_transliterator(ConfigsOrRecipe::Recipe(&comprehensive_recipe))?;

    // Test with various Japanese text issues
    let test_cases = vec![
        ("hello　world", "Ideographic space"),
        ("カタカナ-テスト", "Suspicious hyphen"),
        ("ABC123", "Half-width to full-width"),
        ("舊字體の變換テスト", "Old kanji"),
        ("ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana"),
        ("①②③ⒶⒷⒸ", "Circled characters"),
        ("㋿㍿", "CJK compatibility characters"),
    ];

    for (test_case, description) in test_cases {
        let result = comprehensive_transliterator(test_case)?;
        println!("{description}: '{test_case}' → '{result}'");
    }

    Ok(())
}
