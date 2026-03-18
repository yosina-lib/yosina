use crate::char::{Char, CharPool};
use crate::transliterator::{
    TransliterationError, Transliterator, TransliteratorFactory, TransliteratorFactoryError,
};
use serde::{Deserialize, Serialize};
use std::borrow::Cow;
use std::collections::HashMap;

/// Conversion mode for historical hiragana characters (ゐ, ゑ)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Deserialize, Serialize)]
#[serde(rename_all = "snake_case")]
#[derive(Default)]
pub enum HistoricalHiraganaMode {
    /// Convert to the modern single-character equivalent (ゐ → い, ゑ → え)
    #[default]
    Simple,
    /// Decompose into a multi-character representation (ゐ → うぃ, ゑ → うぇ)
    Decompose,
    /// Do not convert
    Skip,
}

/// Conversion mode for historical katakana characters (ヰ, ヱ)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Deserialize, Serialize)]
#[serde(rename_all = "snake_case")]
#[derive(Default)]
pub enum HistoricalKatakanaMode {
    /// Convert to the modern single-character equivalent (ヰ → イ, ヱ → エ)
    #[default]
    Simple,
    /// Decompose into a multi-character representation (ヰ → ウィ, ヱ → ウェ)
    Decompose,
    /// Do not convert
    Skip,
}

/// Conversion mode for voiced historical katakana characters (ヷ, ヸ, ヹ, ヺ)
#[derive(Debug, Clone, Copy, PartialEq, Eq, Deserialize, Serialize)]
#[serde(rename_all = "snake_case")]
#[derive(Default)]
pub enum VoicedHistoricalKanaMode {
    /// Decompose into vu-form (ヷ → ヴァ, ヸ → ヴィ, ヹ → ヴェ, ヺ → ヴォ)
    Decompose,
    /// Do not convert
    #[default]
    Skip,
}

/// Options for the historical hirakatas transliterator
#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub struct HistoricalHirakatasTransliteratorOptions {
    /// Conversion mode for historical hiragana characters
    #[serde(default)]
    pub hiraganas: HistoricalHiraganaMode,
    /// Conversion mode for historical katakana characters
    #[serde(default)]
    pub katakanas: HistoricalKatakanaMode,
    /// Conversion mode for voiced historical kana characters
    #[serde(default)]
    pub voiced_katakanas: VoicedHistoricalKanaMode,
}

impl TransliteratorFactory for HistoricalHirakatasTransliteratorOptions {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(HistoricalHirakatasTransliterator::new(
            self.clone(),
        )))
    }
}

#[derive(Debug, Clone)]
pub struct HistoricalHirakatasTransliterator {
    mapping_table: HashMap<&'static str, &'static str>,
    voiced_katakanas: VoicedHistoricalKanaMode,
}

impl HistoricalHirakatasTransliterator {
    pub fn new(options: HistoricalHirakatasTransliteratorOptions) -> Self {
        let mapping_table = Self::build_table(&options);
        Self {
            mapping_table,
            voiced_katakanas: options.voiced_katakanas,
        }
    }

    fn build_table(
        options: &HistoricalHirakatasTransliteratorOptions,
    ) -> HashMap<&'static str, &'static str> {
        let mut mapping = HashMap::new();

        // Historical hiragana mappings
        match options.hiraganas {
            HistoricalHiraganaMode::Simple => {
                mapping.insert("\u{3090}", "\u{3044}"); // ゐ → い
                mapping.insert("\u{3091}", "\u{3048}"); // ゑ → え
            }
            HistoricalHiraganaMode::Decompose => {
                mapping.insert("\u{3090}", "\u{3046}\u{3043}"); // ゐ → うぃ
                mapping.insert("\u{3091}", "\u{3046}\u{3047}"); // ゑ → うぇ
            }
            HistoricalHiraganaMode::Skip => {}
        }

        // Historical katakana mappings
        match options.katakanas {
            HistoricalKatakanaMode::Simple => {
                mapping.insert("\u{30F0}", "\u{30A4}"); // ヰ → イ
                mapping.insert("\u{30F1}", "\u{30A8}"); // ヱ → エ
            }
            HistoricalKatakanaMode::Decompose => {
                mapping.insert("\u{30F0}", "\u{30A6}\u{30A3}"); // ヰ → ウィ
                mapping.insert("\u{30F1}", "\u{30A6}\u{30A7}"); // ヱ → ウェ
            }
            HistoricalKatakanaMode::Skip => {}
        }

        // Voiced historical kana mappings
        match options.voiced_katakanas {
            VoicedHistoricalKanaMode::Decompose => {
                mapping.insert("\u{30F7}", "\u{30F4}\u{30A1}"); // ヷ → ヴァ
                mapping.insert("\u{30F8}", "\u{30F4}\u{30A3}"); // ヸ → ヴィ
                mapping.insert("\u{30F9}", "\u{30F4}\u{30A7}"); // ヹ → ヴェ
                mapping.insert("\u{30FA}", "\u{30F4}\u{30A9}"); // ヺ → ヴォ
            }
            VoicedHistoricalKanaMode::Skip => {}
        }

        mapping
    }
}

fn lookup_voiced_decomposed(base: &str) -> Option<&'static str> {
    match base {
        "\u{30EF}" => Some("\u{30A1}"), // ワ → ァ
        "\u{30F0}" => Some("\u{30A3}"), // ヰ → ィ
        "\u{30F1}" => Some("\u{30A7}"), // ヱ → ェ
        "\u{30F2}" => Some("\u{30A9}"), // ヲ → ォ
        _ => None,
    }
}

/// Combining dakuten (U+3099) used in decomposed voiced katakana forms.
const COMBINING_DAKUTEN: &str = "\u{3099}";
const U: &str = "\u{30A6}";

impl Transliterator for HistoricalHirakatasTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        chars: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mut result = Vec::new();
        let mut offset = 0;
        let mut i = 0;

        while i < chars.len() {
            let ch = chars[i];

            if ch.c.is_empty() {
                // Sentinel character - preserve it
                result.push(ch);
                i += 1;
                continue;
            }

            // Check for decomposed voiced katakana: base + combining dakuten
            if i + 1 < chars.len() && chars[i + 1].c.as_ref() == COMBINING_DAKUTEN {
                if let Some(vowel) = lookup_voiced_decomposed(ch.c.as_ref()) {
                    // Found a decomposed voiced katakana pair
                    if self.voiced_katakanas == VoicedHistoricalKanaMode::Decompose {
                        // Voiced katakana mode is Decompose - emit U + dakuten + vowel
                        let nc_u = pool.new_char_from(Cow::Borrowed(U), offset, ch);
                        offset += nc_u.c.len();
                        result.push(nc_u);
                        let nc_dakuten = pool.new_with_offset(chars[i + 1], offset);
                        offset += nc_dakuten.c.len();
                        result.push(nc_dakuten);
                        let nc_vowel = pool.new_char_from(Cow::Borrowed(vowel), offset, ch);
                        offset += nc_vowel.c.len();
                        result.push(nc_vowel);
                        i += 2; // skip base + dakuten
                        continue;
                    } else {
                        // Voiced katakana mode is Skip - emit both chars unchanged
                        let nc = pool.new_with_offset(ch, offset);
                        offset += nc.c.len();
                        result.push(nc);
                        i += 1;
                        continue;
                    }
                }
            }

            if let Some(&mapped) = self.mapping_table.get(ch.c.as_ref()) {
                let nc = pool.new_char_from(Cow::Borrowed(mapped), offset, ch);
                offset += nc.c.len();
                result.push(nc);
            } else {
                let nc = pool.new_with_offset(ch, offset);
                offset += nc.c.len();
                result.push(nc);
            }
            i += 1;
        }

        Ok(result)
    }
}

pub struct HistoricalHirakatasTransliteratorFactory(pub HistoricalHirakatasTransliteratorOptions);

impl HistoricalHirakatasTransliteratorFactory {
    #[allow(clippy::new_without_default)]
    pub fn new() -> Self {
        Self(HistoricalHirakatasTransliteratorOptions::default())
    }

    pub fn with_options(options: HistoricalHirakatasTransliteratorOptions) -> Self {
        Self(options)
    }
}

impl TransliteratorFactory for HistoricalHirakatasTransliteratorFactory {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(HistoricalHirakatasTransliterator::new(
            self.0.clone(),
        )))
    }
}

#[cfg(test)]
mod tests {
    use crate::char::from_chars;

    use super::*;

    #[test]
    fn test_default_options() {
        // Default: Simple hiragana, Simple katakana, Skip voiced
        let options = HistoricalHirakatasTransliteratorOptions::default();
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ゐゑヰヱヷヸヹヺ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "いえイエヷヸヹヺ");
    }

    #[test]
    fn test_simple_hiragana() {
        let options = HistoricalHirakatasTransliteratorOptions {
            hiraganas: HistoricalHiraganaMode::Simple,
            katakanas: HistoricalKatakanaMode::Skip,
            voiced_katakanas: VoicedHistoricalKanaMode::Skip,
        };
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ゐゑ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "いえ");
    }

    #[test]
    fn test_decompose_hiragana() {
        let options = HistoricalHirakatasTransliteratorOptions {
            hiraganas: HistoricalHiraganaMode::Decompose,
            katakanas: HistoricalKatakanaMode::Skip,
            voiced_katakanas: VoicedHistoricalKanaMode::Skip,
        };
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ゐゑ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "うぃうぇ");
    }

    #[test]
    fn test_simple_katakana() {
        let options = HistoricalHirakatasTransliteratorOptions {
            hiraganas: HistoricalHiraganaMode::Skip,
            katakanas: HistoricalKatakanaMode::Simple,
            voiced_katakanas: VoicedHistoricalKanaMode::Skip,
        };
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ヰヱ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "イエ");
    }

    #[test]
    fn test_decompose_katakana() {
        let options = HistoricalHirakatasTransliteratorOptions {
            hiraganas: HistoricalHiraganaMode::Skip,
            katakanas: HistoricalKatakanaMode::Decompose,
            voiced_katakanas: VoicedHistoricalKanaMode::Skip,
        };
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ヰヱ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ウィウェ");
    }

    #[test]
    fn test_decompose_voiced() {
        let options = HistoricalHirakatasTransliteratorOptions {
            hiraganas: HistoricalHiraganaMode::Skip,
            katakanas: HistoricalKatakanaMode::Skip,
            voiced_katakanas: VoicedHistoricalKanaMode::Decompose,
        };
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ヷヸヹヺ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ヴァヴィヴェヴォ");
    }

    #[test]
    fn test_all_decompose() {
        let options = HistoricalHirakatasTransliteratorOptions {
            hiraganas: HistoricalHiraganaMode::Decompose,
            katakanas: HistoricalKatakanaMode::Decompose,
            voiced_katakanas: VoicedHistoricalKanaMode::Decompose,
        };
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ゐゑヰヱヷヸヹヺ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(
            from_chars(result.iter().cloned()),
            "うぃうぇウィウェヴァヴィヴェヴォ"
        );
    }

    #[test]
    fn test_all_skip() {
        let options = HistoricalHirakatasTransliteratorOptions {
            hiraganas: HistoricalHiraganaMode::Skip,
            katakanas: HistoricalKatakanaMode::Skip,
            voiced_katakanas: VoicedHistoricalKanaMode::Skip,
        };
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ゐゑヰヱヷヸヹヺ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ゐゑヰヱヷヸヹヺ");
    }

    #[test]
    fn test_mixed_input_passthrough() {
        let options = HistoricalHirakatasTransliteratorOptions::default();
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("あゐいゑう");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "あいいえう");
    }

    #[test]
    fn test_empty_input() {
        let options = HistoricalHirakatasTransliteratorOptions::default();
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let non_sentinel_chars: Vec<_> = result.iter().filter(|c| !c.c.is_empty()).collect();
        assert!(non_sentinel_chars.is_empty());
    }

    #[test]
    fn test_decomposed_voiced_decompose() {
        // Decomposed ワ+゙ ヰ+゙ ヱ+゙ ヲ+゙ should convert like composed ヷヸヹヺ
        let options = HistoricalHirakatasTransliteratorOptions {
            hiraganas: HistoricalHiraganaMode::Skip,
            katakanas: HistoricalKatakanaMode::Skip,
            voiced_katakanas: VoicedHistoricalKanaMode::Decompose,
        };
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ワ\u{3099}ヰ\u{3099}ヱ\u{3099}ヲ\u{3099}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(
            from_chars(result.iter().cloned()),
            "ウ\u{3099}ァウ\u{3099}ィウ\u{3099}ェウ\u{3099}ォ"
        );
    }

    #[test]
    fn test_decomposed_voiced_skip() {
        // Decomposed voiced katakana with skip mode should pass through unchanged
        let options = HistoricalHirakatasTransliteratorOptions {
            hiraganas: HistoricalHiraganaMode::Skip,
            katakanas: HistoricalKatakanaMode::Skip,
            voiced_katakanas: VoicedHistoricalKanaMode::Skip,
        };
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ワ\u{3099}ヰ\u{3099}ヱ\u{3099}ヲ\u{3099}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(
            from_chars(result.iter().cloned()),
            "ワ\u{3099}ヰ\u{3099}ヱ\u{3099}ヲ\u{3099}"
        );
    }

    #[test]
    fn test_decomposed_voiced_not_split_from_base() {
        // ヰ+゙ must be treated as ヸ (voiced), not as ヰ (katakana) + separate ゙
        let options = HistoricalHirakatasTransliteratorOptions {
            hiraganas: HistoricalHiraganaMode::Skip,
            katakanas: HistoricalKatakanaMode::Simple,
            voiced_katakanas: VoicedHistoricalKanaMode::Skip,
        };
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ヰ\u{3099}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ヰ\u{3099}");
    }

    #[test]
    fn test_decomposed_voiced_with_decompose() {
        // ヰ+゙ = ヸ, should produce ヴィ
        let options = HistoricalHirakatasTransliteratorOptions {
            hiraganas: HistoricalHiraganaMode::Skip,
            katakanas: HistoricalKatakanaMode::Skip,
            voiced_katakanas: VoicedHistoricalKanaMode::Decompose,
        };
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ヰ\u{3099}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ウ\u{3099}ィ");
    }

    #[test]
    fn test_sentinel_handling() {
        let options = HistoricalHirakatasTransliteratorOptions::default();
        let transliterator = HistoricalHirakatasTransliterator::new(options);
        let mut pool = CharPool::new();

        let sentinel = pool.new_sentinel(0);
        let input = vec![sentinel];
        let result = transliterator.transliterate(&mut pool, &input).unwrap();
        assert_eq!(result.len(), 1);
        assert!(
            result[0].c.is_empty(),
            "Sentinel character should be preserved"
        );
    }
}
