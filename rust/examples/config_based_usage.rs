//! Configuration-based usage example for Yosina Rust library.
//! This example demonstrates using direct transliterator configurations
//! as shown in the README documentation.

use yosina::{make_transliterator, TransliteratorConfig};

fn main() {
    println!("=== Yosina Rust Configuration-based Usage Example ===\n");

    // Configure with direct transliterator configs (matching README example)
    let configs = vec![
        TransliteratorConfig::KanjiOldNew,
        TransliteratorConfig::Spaces,
        TransliteratorConfig::ProlongedSoundMarks(Default::default()),
        TransliteratorConfig::CircledOrSquared(Default::default()),
        TransliteratorConfig::Combined,
    ];

    let transliterator = make_transliterator(&configs).unwrap();

    // Test with the same input as README
    let input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿";
    let result = transliterator(input).unwrap();

    println!("Input:  {input}");
    println!("Output: {result}");
    println!("Expected: (1)(2)(3) (A)(B)(C) 株式会社リットルサンチーム令和");

    // Additional examples showing individual configs
    println!("\n--- Individual Configuration Examples ---");

    // Spaces only
    let spaces_config = vec![TransliteratorConfig::Spaces];
    let spaces_transliterator = make_transliterator(&spaces_config).unwrap();
    let space_test = "hello　world　test"; // ideographic spaces
    println!(
        "Spaces only: '{}' → '{}'",
        space_test,
        spaces_transliterator(space_test).unwrap()
    );

    // Kanji old-new only (note: needs IVS/SVS handling for proper conversion)
    let kanji_config = vec![
        TransliteratorConfig::IvsSvsBase(
            yosina::transliterators::IvsSvsBaseTransliteratorOptions {
                mode: yosina::transliterators::IvsSvsBaseMode::IvsOrSvs(false),
                charset: yosina::transliterators::Charset::Unijis2004,
                ..Default::default()
            },
        ),
        TransliteratorConfig::KanjiOldNew,
        TransliteratorConfig::IvsSvsBase(
            yosina::transliterators::IvsSvsBaseTransliteratorOptions {
                mode: yosina::transliterators::IvsSvsBaseMode::Base,
                charset: yosina::transliterators::Charset::Unijis2004,
                ..Default::default()
            },
        ),
    ];
    let kanji_transliterator = make_transliterator(&kanji_config).unwrap();
    let kanji_test = "舊字體の變換";
    println!(
        "Kanji old-new only: '{}' → '{}'",
        kanji_test,
        kanji_transliterator(kanji_test).unwrap()
    );

    // Circled/squared characters only
    let circled_config = vec![TransliteratorConfig::CircledOrSquared(Default::default())];
    let circled_transliterator = make_transliterator(&circled_config).unwrap();
    let circled_test = "①②③ⒶⒷⒸ";
    println!(
        "Circled only: '{}' → '{}'",
        circled_test,
        circled_transliterator(circled_test).unwrap()
    );

    // Combined characters only
    let combined_config = vec![TransliteratorConfig::Combined];
    let combined_transliterator = make_transliterator(&combined_config).unwrap();
    let combined_test = "㍿㍑㌠㋿";
    println!(
        "Combined only: '{}' → '{}'",
        combined_test,
        combined_transliterator(combined_test).unwrap()
    );
}
