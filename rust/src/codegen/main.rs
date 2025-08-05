use std::collections::BTreeMap;
use std::fs;
use std::path::Path;

mod dataset;
mod emitter;
mod loaders;
mod models;
mod parsers;

use dataset::Dataset;
use emitter::*;

fn snake_case(s: &str) -> String {
    let mut result = String::new();
    let mut prev_lowercase = false;

    for ch in s.chars() {
        if ch.is_uppercase() && prev_lowercase {
            result.push('_');
        }
        result.push(ch.to_lowercase().next().unwrap());
        prev_lowercase = ch.is_lowercase();
    }

    result
}

fn main() -> Result<(), anyhow::Error> {
    // Determine the project root
    let manifest_dir = env!("CARGO_MANIFEST_DIR");
    let project_root = Path::new(manifest_dir).parent().unwrap();
    let data_root = project_root.join("data");
    let dest_root = Path::new(manifest_dir).join("src/transliterators");

    println!("Loading dataset from: {:?}", data_root);
    println!("Writing output to: {:?}", dest_root);

    // Define the dataset source definitions
    let mut defs = BTreeMap::new();
    defs.insert("spaces".to_string(), "spaces.json".to_string());
    defs.insert("radicals".to_string(), "radicals.json".to_string());
    defs.insert(
        "mathematical_alphanumerics".to_string(),
        "mathematical-alphanumerics.json".to_string(),
    );
    defs.insert(
        "ideographic_annotations".to_string(),
        "ideographic-annotation-marks.json".to_string(),
    );
    defs.insert("hyphens".to_string(), "hyphens.json".to_string());
    defs.insert(
        "ivs_svs_base".to_string(),
        "ivs-svs-base-mappings.json".to_string(),
    );
    defs.insert(
        "kanji_old_new".to_string(),
        "kanji-old-new-form.json".to_string(),
    );
    defs.insert("combined".to_string(), "combined-chars.json".to_string());
    defs.insert(
        "circled_or_squared".to_string(),
        "circled-or-squared.json".to_string(),
    );

    // Load the dataset
    let dataset = Dataset::from_data_root(&data_root, &defs)?;

    // Generate and write files

    // Simple transliterators
    let simple_transliterators = vec![
        ("spaces", "Spaces", &dataset.spaces),
        ("radicals", "Radicals", &dataset.radicals),
        (
            "mathematical_alphanumerics",
            "MathematicalAlphanumerics",
            &dataset.mathematical_alphanumerics,
        ),
        (
            "ideographic_annotations",
            "IdeographicAnnotations",
            &dataset.ideographic_annotations,
        ),
        ("kanji_old_new", "KanjiOldNew", &dataset.kanji_old_new),
        ("combined", "Combined", &dataset.combined),
    ];

    for (name, module_name, data) in simple_transliterators {
        let output = render_simple_transliterator(module_name, data)?;
        let filename = format!("{}.rs", snake_case(name));
        let filepath = dest_root.join(&filename);
        println!("Generating: {}", filename);
        fs::write(filepath, output)?;
    }

    // Hyphens transliterator
    {
        let output = render_hyphens_transliterator_data(&dataset.hyphens)?;
        let filepath = dest_root.join("hyphens_data.rs");
        println!("Generating: hyphens_data.rs");
        fs::write(filepath, output)?;
    }

    // IVS/SVS base data
    {
        let output = render_ivs_svs_base_data(&dataset.ivs_svs_base)?;
        let filepath = dest_root.join("ivs_svs_base_data.rs");
        println!("Generating: ivs_svs_base_data.rs");
        fs::write(filepath, output)?;
    }

    // Circled or squared transliterator data
    {
        let output = render_circled_or_squared_data(&dataset.circled_or_squared)?;
        let filepath = dest_root.join("circled_or_squared_data.rs");
        println!("Generating: circled_or_squared_data.rs");
        fs::write(filepath, output)?;
    }

    println!("Code generation complete!");

    Ok(())
}
