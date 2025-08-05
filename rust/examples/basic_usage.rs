//! Basic usage example for Yosina Rust library.
//! This example demonstrates the fundamental transliteration functionality
//! as shown in the README documentation.

use yosina::recipes::{ReplaceCircledOrSquaredCharactersOptions, ToFullWidthOptions};
use yosina::{make_transliterator, TransliteratorRecipe};

fn main() {
    println!("=== Yosina Rust Basic Usage Example ===\n");

    // Create a recipe with desired transformations (matching README example)
    let recipe = TransliteratorRecipe {
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

    // Create the transliterator
    let transliterator = make_transliterator(&recipe).unwrap();

    // Use it with various special characters (matching README example)
    let input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"; // circled numbers, letters, space, combined characters
    let result = transliterator(input).unwrap();

    println!("Input:  {input}");
    println!("Output: {result}");
    println!("Expected: （１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和");

    // Convert old kanji to new
    println!("\n--- Old Kanji to New ---");
    let old_kanji = "舊字體";
    let result = transliterator(old_kanji).unwrap();
    println!("Input:  {old_kanji}");
    println!("Output: {result}");
    println!("Expected: 旧字体");

    // Convert half-width katakana to full-width
    println!("\n--- Half-width to Full-width ---");
    let half_width = "ﾃｽﾄﾓｼﾞﾚﾂ";
    let result = transliterator(half_width).unwrap();
    println!("Input:  {half_width}");
    println!("Output: {result}");
    println!("Expected: テストモジレツ");
}
