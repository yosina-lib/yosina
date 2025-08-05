//! Advanced usage example for Yosina Rust library.
//! This example demonstrates complex text processing scenarios.

use anyhow::Result;
use yosina::transliterators::{
    Charset, IvsSvsBaseMode, IvsSvsBaseTransliteratorOptions, Jisx0201AndAlikeTransliteratorOptions,
};
use yosina::{make_transliterator, TransliterationRecipe, TransliteratorConfig};

fn process_text_samples(samples: &[(String, &str)]) {
    println!("Processing text samples with character codes:");
    for (text, description) in samples {
        println!("\n{description}:");
        println!("  Original: '{text}'");

        // Show character codes for clarity
        let char_codes: Vec<String> = text
            .chars()
            .map(|c| format!("U+{:04X}", c as u32))
            .collect();
        println!("  Codes:    {}", char_codes.join(" "));
    }
}

fn main() -> Result<()> {
    println!("=== Advanced Yosina Rust Usage Examples ===\n");

    // 1. Web scraping text normalization
    println!("1. Web Scraping Text Normalization");
    println!("   (Typical use case: cleaning scraped Japanese web content)");

    let web_scraping_recipe = TransliterationRecipe {
        kanji_old_new: true,
        replace_spaces: true,
        replace_suspicious_hyphens_to_prolonged_sound_marks: true,
        replace_ideographic_annotations: true,
        replace_radicals: true,
        combine_decomposed_hiraganas_and_katakanas: true,
        ..Default::default()
    };

    let web_normalizer = make_transliterator(&web_scraping_recipe)?;

    // Simulate messy web content
    let messy_content = vec![
        (
            "これは\u{3000}テスト\u{00A0}です。".to_string(),
            "Mixed spaces from different sources",
        ),
        (
            "コンピューター-プログラム".to_string(),
            "Suspicious hyphens in katakana",
        ),
        (
            "古い漢字：廣島、檜、國".to_string(),
            "Old-style kanji forms",
        ),
        (
            "部首：⺅⻌⽊".to_string(),
            "CJK radicals instead of regular kanji",
        ),
    ];

    for (text, description) in &messy_content {
        let cleaned = web_normalizer(text)?;
        println!("  {description}:");
        println!("    Before: '{text}'");
        println!("    After:  '{cleaned}'");
        println!();
    }

    // 2. Document standardization
    println!("2. Document Standardization");
    println!("   (Use case: preparing documents for consistent formatting)");

    let document_recipe = TransliterationRecipe {
        to_fullwidth: yosina::recipes::ToFullWidthOptions::Yes {
            u005c_as_yen_sign: false,
        },
        replace_spaces: true,
        kanji_old_new: true,
        combine_decomposed_hiraganas_and_katakanas: true,
        ..Default::default()
    };

    let document_standardizer = make_transliterator(&document_recipe)?;

    let document_samples = vec![
        ("Hello World 123", "ASCII text to full-width"),
        ("ガ゙", "Decomposed katakana with combining mark"),
        ("檜原村", "Old kanji in place names"),
    ];

    for (text, description) in document_samples {
        let standardized = document_standardizer(text)?;
        println!("  {description}:");
        println!("    Input:  '{text}'");
        println!("    Output: '{standardized}'");
        println!();
    }

    // 3. Search index preparation
    println!("3. Search Index Preparation");
    println!("   (Use case: normalizing text for search engines)");

    let search_recipe = TransliterationRecipe {
        kanji_old_new: true,
        replace_spaces: true,
        to_halfwidth: yosina::recipes::ToHalfwidthOptions::Yes {
            hankaku_kana: false,
        },
        replace_suspicious_hyphens_to_prolonged_sound_marks: true,
        ..Default::default()
    };

    let search_normalizer = make_transliterator(&search_recipe)?;

    let search_samples = vec![
        ("東京スカイツリー", "Famous landmark name"),
        ("プログラミング言語", "Technical terms"),
        (
            "コンピューター-サイエンス",
            "Academic field with suspicious hyphen",
        ),
    ];

    for (text, description) in search_samples {
        let normalized = search_normalizer(text)?;
        println!("  {description}:");
        println!("    Original:   '{text}'");
        println!("    Normalized: '{normalized}'");
        println!();
    }

    // 4. Custom pipeline example
    println!("4. Custom Processing Pipeline");
    println!("   (Use case: step-by-step text transformation)");

    // Create multiple transliterators for pipeline processing
    let steps = vec![
        ("Spaces", vec![TransliteratorConfig::Spaces]),
        (
            "Old Kanji",
            vec![
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
            ],
        ),
        (
            "Width",
            vec![TransliteratorConfig::Jisx0201AndAlike {
                fullwidth_to_halfwidth: true,
                options: Jisx0201AndAlikeTransliteratorOptions {
                    u005c_as_yen_sign: Some(false),
                    ..Default::default()
                },
            }],
        ),
        (
            "ProlongedSOundMarks",
            vec![TransliteratorConfig::ProlongedSoundMarks(Default::default())],
        ),
    ];

    let mut transliterators = Vec::new();
    for (name, config) in steps {
        let transliterator = make_transliterator(&config)?;
        transliterators.push((name, transliterator));
    }

    let pipeline_text = "hello\u{3000}world ﾃｽﾄ 檜-システム";
    let mut current_text = pipeline_text.to_string();

    println!("  Starting text: '{current_text}'");

    for (step_name, transliterator) in &transliterators {
        let previous_text = current_text.clone();
        current_text = transliterator(&current_text)?;
        if previous_text != current_text {
            println!("  After {step_name}: '{current_text}'");
        }
    }

    println!("  Final result: '{current_text}'");

    // 5. Unicode normalization showcase
    println!("\n5. Unicode Normalization Showcase");
    println!("   (Demonstrating various Unicode edge cases)");

    let unicode_recipe = TransliterationRecipe {
        replace_spaces: true,
        replace_mathematical_alphanumerics: true,
        replace_radicals: true,
        ..Default::default()
    };

    let unicode_normalizer = make_transliterator(&unicode_recipe)?;

    let unicode_samples = vec![
        (
            "\u{2003}\u{2002}\u{2000}".to_string(),
            "Various em/en spaces",
        ),
        (
            "\u{3000}\u{00A0}\u{202F}".to_string(),
            "Ideographic and narrow spaces",
        ),
        ("⺅⻌⽊".to_string(), "CJK radicals"),
        (
            "\u{1D400}\u{1D401}\u{1D402}".to_string(),
            "Mathematical bold letters",
        ),
    ];

    process_text_samples(&unicode_samples);

    for (text, description) in &unicode_samples {
        let normalized = unicode_normalizer(text)?;
        println!("  Result: '{normalized}' ({description})");
        println!();
    }

    // 6. Performance considerations
    println!("6. Performance Considerations");
    println!("   (Reusing transliterators for better performance)");

    let perf_recipe = TransliterationRecipe {
        kanji_old_new: true,
        replace_spaces: true,
        ..Default::default()
    };

    let perf_transliterator = make_transliterator(&perf_recipe)?;

    // Simulate processing multiple texts
    let texts = [
        "これはテストです",
        "檜原村は美しい",
        "hello　world",
        "プログラミング",
    ];

    println!(
        "  Processing {} texts with the same transliterator:",
        texts.len()
    );
    for (i, text) in texts.iter().enumerate() {
        let result = perf_transliterator(text)?;
        println!("    {}: '{}' → '{}'", i + 1, text, result);
    }

    println!("\n=== Advanced Examples Complete ===");

    Ok(())
}
