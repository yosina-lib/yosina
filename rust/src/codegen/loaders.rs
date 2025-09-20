use super::models::*;
use super::parsers::*;
use std::fs;
use std::path::Path;

fn load_file(path: &Path) -> Result<String, anyhow::Error> {
    let content = fs::read_to_string(path)?;
    Ok(content)
}

pub fn load_spaces(path: &Path) -> Result<Vec<(String, String)>, anyhow::Error> {
    let content = load_file(path)?;
    parse_simple_transliteration_records(&content)
}

pub fn load_radicals(path: &Path) -> Result<Vec<(String, String)>, anyhow::Error> {
    let content = load_file(path)?;
    parse_simple_transliteration_records(&content)
}

pub fn load_mathematical_alphanumerics(
    path: &Path,
) -> Result<Vec<(String, String)>, anyhow::Error> {
    let content = load_file(path)?;
    parse_simple_transliteration_records(&content)
}

pub fn load_ideographic_annotations(path: &Path) -> Result<Vec<(String, String)>, anyhow::Error> {
    let content = load_file(path)?;
    parse_simple_transliteration_records(&content)
}

pub fn load_hyphens(path: &Path) -> Result<Vec<(String, HyphensRecord)>, anyhow::Error> {
    let content = load_file(path)?;
    parse_hyphen_transliteration_records(&content)
}

pub fn load_ivs_svs_base(path: &Path) -> Result<Vec<IvsSvsBaseRecord>, anyhow::Error> {
    let content = load_file(path)?;
    parse_ivs_svs_base_transliteration_records(&content)
}

pub fn load_kanji_old_new(path: &Path) -> Result<Vec<(String, String)>, anyhow::Error> {
    let content = load_file(path)?;
    parse_kanji_old_new_transliteration_records(&content)
}

pub fn load_combined(path: &Path) -> Result<Vec<(String, String)>, anyhow::Error> {
    let content = load_file(path)?;
    parse_combined_transliteration_records(&content)
}

pub fn load_circled_or_squared(
    path: &Path,
) -> Result<Vec<(String, CircledOrSquaredRecord)>, anyhow::Error> {
    let content = load_file(path)?;
    parse_circled_or_squared_transliteration_records(&content)
}

pub fn load_roman_numerals(
    path: &Path,
) -> Result<Vec<(String, RomanNumeralsRecord)>, anyhow::Error> {
    let content = load_file(path)?;
    parse_roman_numerals_records(&content)
}
