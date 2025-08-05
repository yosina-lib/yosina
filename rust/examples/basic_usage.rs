//! Basic usage example for Yosina Rust library.
//! This example demonstrates the fundamental transliteration functionality
//! as shown in the README documentation.

use yosina::recipes::{ReplaceCircledOrSquaredCharactersOptions, ToFullWidthOptions};
use yosina::{make_transliterator, TransliterationRecipe};

fn main() {
    println!("=== Yosina Rust Basic Usage Example ===\n");

    // Create a recipe with desired transformations (matching README example)
    let recipe = TransliterationRecipe {
        kanji_old_new: true,
        replace_spaces: true,
        replace_suspicious_hyphens_to_prolonged_sound_marks: true,
        replace_circled_or_squared_characters: ReplaceCircledOrSquaredCharactersOptions::Yes {
            exclude_emojis: false,
        },
        replace_combined_characters: true,
        replace_japanese_iteration_marks: true, // Expand iteration marks
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

    // Demonstrate Japanese iteration marks expansion
    println!("\n--- Japanese Iteration Marks Examples ---");
    let iteration_examples = vec![
        "佐々木", // kanji iteration
        "すゝき", // hiragana iteration
        "いすゞ", // hiragana voiced iteration
        "サヽキ", // katakana iteration
        "ミスヾ", // katakana voiced iteration
    ];

    for text in iteration_examples {
        let result = transliterator(text).unwrap();
        println!("{text} → {result}");
    }

    // Demonstrate hiragana to katakana conversion separately
    println!("\n--- Hiragana to Katakana Conversion ---");
    // Create a separate recipe for just hiragana to katakana conversion
    let hira_kata_recipe = TransliterationRecipe {
        hira_kata: yosina::recipes::HiraKataOptions::HiraToKata, // Convert hiragana to katakana
        ..Default::default()
    };

    let hira_kata_transliterator = make_transliterator(&hira_kata_recipe).unwrap();

    let hira_kata_examples = vec![
        "ひらがな",           // pure hiragana
        "これはひらがなです", // hiragana sentence
        "ひらがなとカタカナ", // mixed hiragana and katakana
    ];

    for text in hira_kata_examples {
        let result = hira_kata_transliterator(text).unwrap();
        println!("{text} → {result}");
    }

    // Also demonstrate katakana to hiragana conversion
    println!("\n--- Katakana to Hiragana Conversion ---");
    let kata_hira_recipe = TransliterationRecipe {
        hira_kata: yosina::recipes::HiraKataOptions::KataToHira, // Convert katakana to hiragana
        ..Default::default()
    };

    let kata_hira_transliterator = make_transliterator(&kata_hira_recipe).unwrap();

    let kata_hira_examples = vec![
        "カタカナ",           // pure katakana
        "コレハカタカナデス", // katakana sentence
        "カタカナとひらがな", // mixed katakana and hiragana
    ];

    for text in kata_hira_examples {
        let result = kata_hira_transliterator(text).unwrap();
        println!("{text} → {result}");
    }
}
