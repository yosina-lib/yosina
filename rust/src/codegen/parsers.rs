use serde::Deserialize;
use std::collections::HashMap;

use super::models::*;

#[derive(Debug, Deserialize)]
struct HyphensFileRecord {
    code: String,
    ascii: Option<Vec<String>>,
    #[serde(rename = "shift_jis")]
    _shift_jis: Option<Vec<i32>>,
    jisx0201: Option<Vec<String>>,
    #[serde(rename = "jisx0208-1978")]
    jisx0208_1978: Option<Vec<String>>,
    #[serde(rename = "jisx0208-1978-windows")]
    jisx0208_1978_windows: Option<Vec<String>>,
    #[serde(rename = "jisx0208-verbatim")]
    jisx0208_verbatim: Option<String>,
}

#[derive(Debug, Deserialize)]
struct IvsSvsSchema {
    ivs: Vec<String>,
    #[serde(rename = "svs")]
    _svs: Option<Vec<String>>,
}

#[derive(Debug, Deserialize)]
struct IvsSvsFileRecord {
    ivs: Vec<String>,
    svs: Option<Vec<String>>,
    base90: Option<String>,
    base2004: Option<String>,
}

fn parse_unicode_codepoint(cp_repr: &str) -> Result<u32, anyhow::Error> {
    if let Some(captures) = cp_repr.strip_prefix("U+") {
        u32::from_str_radix(captures, 16)
            .map_err(|_| anyhow::anyhow!("invalid Unicode codepoint representation: {}", cp_repr))
    } else {
        Err(anyhow::anyhow!(
            "invalid Unicode codepoint representation: {}",
            cp_repr
        ))
    }
}

fn codepoint_to_string(codepoint: u32) -> Result<String, anyhow::Error> {
    char::from_u32(codepoint)
        .map(|c| c.to_string())
        .ok_or_else(|| anyhow::anyhow!("invalid Unicode codepoint: {}", codepoint))
}

fn codepoints_to_string(codepoints: &[u32]) -> Result<String, anyhow::Error> {
    codepoints
        .iter()
        .map(|&cp| {
            char::from_u32(cp).ok_or_else(|| anyhow::anyhow!("invalid Unicode codepoint: {}", cp))
        })
        .collect::<Result<String, _>>()
}

pub fn parse_simple_transliteration_records(
    data: &str,
) -> Result<Vec<(String, String)>, anyhow::Error> {
    let map: HashMap<String, Option<String>> = serde_json::from_str(data)?;

    let mut result = Vec::new();
    for (key, value) in map {
        let from_codepoint = parse_unicode_codepoint(&key)?;
        let from_char = codepoint_to_string(from_codepoint)?;

        let to_char = if let Some(val) = value {
            let to_codepoint = parse_unicode_codepoint(&val)?;
            codepoint_to_string(to_codepoint)?
        } else {
            String::new()
        };

        result.push((from_char, to_char));
    }

    Ok(result)
}

pub fn parse_combined_transliteration_records(
    data: &str,
) -> Result<Vec<(String, String)>, anyhow::Error> {
    let map: HashMap<String, String> = serde_json::from_str(data)?;

    let mut result = Vec::new();
    for (key, value) in map {
        let from_codepoint = parse_unicode_codepoint(&key)?;
        let from_char = codepoint_to_string(from_codepoint)?;
        // value is already a string, no need to parse it as Unicode codepoint
        result.push((from_char, value));
    }

    Ok(result)
}

pub fn parse_hyphen_transliteration_records(
    data: &str,
) -> Result<Vec<(String, HyphensRecord)>, anyhow::Error> {
    let records: Vec<HyphensFileRecord> = serde_json::from_str(data)?;

    let mut result = Vec::new();
    for record in records {
        let code_codepoint = parse_unicode_codepoint(&record.code)?;
        let code_char = codepoint_to_string(code_codepoint)?;

        let hyphen_record = HyphensRecord {
            ascii: if let Some(ascii) = record.ascii {
                let codepoints: Result<Vec<_>, _> =
                    ascii.iter().map(|s| parse_unicode_codepoint(s)).collect();
                Some(codepoints_to_string(&codepoints?)?)
            } else {
                None
            },
            jisx0201: if let Some(jisx0201) = record.jisx0201 {
                let codepoints: Result<Vec<_>, _> = jisx0201
                    .iter()
                    .map(|s| parse_unicode_codepoint(s))
                    .collect();
                Some(codepoints_to_string(&codepoints?)?)
            } else {
                None
            },
            jisx0208_90: if let Some(jisx0208_1978) = record.jisx0208_1978 {
                let codepoints: Result<Vec<_>, _> = jisx0208_1978
                    .iter()
                    .map(|s| parse_unicode_codepoint(s))
                    .collect();
                Some(codepoints_to_string(&codepoints?)?)
            } else {
                None
            },
            jisx0208_90_windows: if let Some(jisx0208_1978_windows) = record.jisx0208_1978_windows {
                let codepoints: Result<Vec<_>, _> = jisx0208_1978_windows
                    .iter()
                    .map(|s| parse_unicode_codepoint(s))
                    .collect();
                Some(codepoints_to_string(&codepoints?)?)
            } else {
                None
            },
            jisx0208_verbatim: if let Some(jisx0208_verbatim) = record.jisx0208_verbatim {
                let codepoint = parse_unicode_codepoint(&jisx0208_verbatim)?;
                Some(codepoint_to_string(codepoint)?)
            } else {
                None
            },
        };

        result.push((code_char, hyphen_record));
    }

    Ok(result)
}

pub fn parse_ivs_svs_base_transliteration_records(
    data: &str,
) -> Result<Vec<IvsSvsBaseRecord>, anyhow::Error> {
    let records: Vec<IvsSvsFileRecord> = serde_json::from_str(data)?;

    let mut result = Vec::new();
    for record in records {
        let ivs_codepoints: Result<Vec<_>, _> = record
            .ivs
            .iter()
            .map(|s| parse_unicode_codepoint(s))
            .collect();
        let ivs = codepoints_to_string(&ivs_codepoints?)?;

        let svs = if let Some(svs_vec) = record.svs {
            let svs_codepoints: Result<Vec<_>, _> =
                svs_vec.iter().map(|s| parse_unicode_codepoint(s)).collect();
            Some(codepoints_to_string(&svs_codepoints?)?)
        } else {
            None
        };

        let base90 = if let Some(base90_str) = record.base90 {
            let codepoint = parse_unicode_codepoint(&base90_str)?;
            Some(codepoint_to_string(codepoint)?)
        } else {
            None
        };

        let base2004 = if let Some(base2004_str) = record.base2004 {
            let codepoint = parse_unicode_codepoint(&base2004_str)?;
            Some(codepoint_to_string(codepoint)?)
        } else {
            None
        };

        result.push(IvsSvsBaseRecord {
            ivs,
            svs,
            base90,
            base2004,
        });
    }

    Ok(result)
}

pub fn parse_kanji_old_new_transliteration_records(
    data: &str,
) -> Result<Vec<(String, String)>, anyhow::Error> {
    let records: Vec<(IvsSvsSchema, IvsSvsSchema)> = serde_json::from_str(data)?;

    let mut result = Vec::new();
    for (old, new) in records {
        let old_codepoints: Vec<u32> = old
            .ivs
            .iter()
            .map(|s| parse_unicode_codepoint(s))
            .collect::<Result<Vec<_>, _>>()?;
        let old_str = codepoints_to_string(&old_codepoints)?;

        let new_codepoints: Vec<u32> = new
            .ivs
            .iter()
            .map(|s| parse_unicode_codepoint(s))
            .collect::<Result<Vec<_>, _>>()?;
        let new_str = codepoints_to_string(&new_codepoints)?;

        result.push((old_str, new_str));
    }

    Ok(result)
}

pub fn parse_circled_or_squared_transliteration_records(
    data: &str,
) -> Result<Vec<(String, CircledOrSquaredRecord)>, anyhow::Error> {
    let map: HashMap<String, CircledOrSquaredRecord> = serde_json::from_str(data)?;

    let mut result = Vec::new();
    for (key, record) in map {
        let from_codepoint = parse_unicode_codepoint(&key)?;
        let from_char = codepoint_to_string(from_codepoint)?;
        result.push((from_char, record));
    }

    Ok(result)
}

pub fn parse_roman_numerals_records(
    data: &str,
) -> Result<Vec<(String, RomanNumeralsRecord)>, anyhow::Error> {
    let records: Vec<RomanNumeralsRecord> = serde_json::from_str(data)?;

    let mut result = Vec::new();
    for record in records {
        // Use upper code as the key
        let upper_codepoint = parse_unicode_codepoint(&record.codes.upper)?;
        let upper_char = codepoint_to_string(upper_codepoint)?;
        result.push((upper_char, record));
    }

    Ok(result)
}
