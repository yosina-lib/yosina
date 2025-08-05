use serde::{Deserialize, Serialize};
use std::borrow::Cow;
use std::collections::HashMap;
use std::sync::OnceLock;

use crate::char::{Char, CharPool};
use crate::transliterator::{Transliterator, TransliteratorFactory};
use crate::{TransliterationError, TransliteratorFactoryError};

use super::hira_kata_table::{HIRAGANA_KATAKANA_SMALL_TABLE, HIRAGANA_KATAKANA_TABLE};

/// Conversion mode for the transliterator
#[derive(Debug, Clone, Copy, PartialEq, Eq, Deserialize, Serialize)]
#[serde(rename_all = "snake_case")]
#[derive(Default)]
pub enum Mode {
    /// Convert Hiragana to Katakana
    #[default]
    HiraToKata,
    /// Convert Katakana to Hiragana
    KataToHira,
}

/// Options for the hiragana katakana transliterator
#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub struct HiraKataTransliteratorOptions {
    /// Conversion mode
    #[serde(default)]
    pub mode: Mode,
}

impl TransliteratorFactory for HiraKataTransliteratorOptions {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(HiraKataTransliterator::new(self.clone())))
    }
}

#[derive(Debug, Clone)]
pub struct HiraKataTransliterator {
    mapping_table: &'static HashMap<&'static str, &'static str>,
}

// Static cache for mapping tables
static HIRA_TO_KATA_CACHE: OnceLock<HashMap<&'static str, &'static str>> = OnceLock::new();
static KATA_TO_HIRA_CACHE: OnceLock<HashMap<&'static str, &'static str>> = OnceLock::new();

impl HiraKataTransliterator {
    pub fn new(options: HiraKataTransliteratorOptions) -> Self {
        let mapping_table = match options.mode {
            Mode::HiraToKata => HIRA_TO_KATA_CACHE.get_or_init(Self::build_hira_to_kata_table),
            Mode::KataToHira => KATA_TO_HIRA_CACHE.get_or_init(Self::build_kata_to_hira_table),
        };
        Self { mapping_table }
    }

    fn build_hira_to_kata_table() -> HashMap<&'static str, &'static str> {
        let mut mapping = HashMap::new();

        // Main table mappings
        for entry in HIRAGANA_KATAKANA_TABLE {
            // Base character
            mapping.insert(entry.hiragana.base, entry.katakana.base);

            // Voiced character
            if let (Some(hira_voiced), Some(kata_voiced)) =
                (entry.hiragana.voiced, entry.katakana.voiced)
            {
                mapping.insert(hira_voiced, kata_voiced);
            }

            // Semi-voiced character
            if let (Some(hira_semivoiced), Some(kata_semivoiced)) =
                (entry.hiragana.semivoiced, entry.katakana.semivoiced)
            {
                mapping.insert(hira_semivoiced, kata_semivoiced);
            }
        }

        // Small character mappings
        for entry in HIRAGANA_KATAKANA_SMALL_TABLE {
            mapping.insert(entry.hiragana, entry.katakana);
        }

        mapping
    }

    fn build_kata_to_hira_table() -> HashMap<&'static str, &'static str> {
        let mut mapping = HashMap::new();

        // Main table mappings
        for entry in HIRAGANA_KATAKANA_TABLE {
            // Base character
            mapping.insert(entry.katakana.base, entry.hiragana.base);

            // Voiced character
            if let (Some(kata_voiced), Some(hira_voiced)) =
                (entry.katakana.voiced, entry.hiragana.voiced)
            {
                mapping.insert(kata_voiced, hira_voiced);
            }

            // Semi-voiced character
            if let (Some(kata_semivoiced), Some(hira_semivoiced)) =
                (entry.katakana.semivoiced, entry.hiragana.semivoiced)
            {
                mapping.insert(kata_semivoiced, hira_semivoiced);
            }
        }

        // Small character mappings
        for entry in HIRAGANA_KATAKANA_SMALL_TABLE {
            mapping.insert(entry.katakana, entry.hiragana);
        }

        mapping
    }
}

impl Transliterator for HiraKataTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        chars: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mut result = Vec::new();
        let mut offset = 0;

        for &ch in chars {
            if let Some(&mapped) = self.mapping_table.get(ch.c.as_ref()) {
                // Character needs to be converted
                let nc = pool.new_char_from(Cow::Borrowed(mapped), offset, ch);
                offset += nc.c.len();
                result.push(nc);
            } else {
                // Character passes through unchanged
                let nc = pool.new_with_offset(ch, offset);
                offset += nc.c.len();
                result.push(nc);
            }
        }

        Ok(result)
    }
}

pub struct HiraKataTransliteratorFactory(pub HiraKataTransliteratorOptions);

impl TransliteratorFactory for HiraKataTransliteratorFactory {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(HiraKataTransliterator::new(self.0.clone())))
    }
}

#[cfg(test)]
mod tests {
    use crate::char::from_chars;

    use super::*;

    #[test]
    fn test_hira_to_kata_basic() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::HiraToKata,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("あいうえお");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "アイウエオ");
    }

    #[test]
    fn test_hira_to_kata_voiced() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::HiraToKata,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("がぎぐげご");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ガギグゲゴ");
    }

    #[test]
    fn test_hira_to_kata_semi_voiced() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::HiraToKata,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ぱぴぷぺぽ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "パピプペポ");
    }

    #[test]
    fn test_hira_to_kata_small() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::HiraToKata,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ぁぃぅぇぉっゃゅょ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ァィゥェォッャュョ");
    }

    #[test]
    fn test_hira_to_kata_mixed() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::HiraToKata,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("あいうえお123ABCアイウエオ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(
            from_chars(result.iter().cloned()),
            "アイウエオ123ABCアイウエオ"
        );
    }

    #[test]
    fn test_hira_to_kata_phrase() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::HiraToKata,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("こんにちは、世界！");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "コンニチハ、世界！");
    }

    #[test]
    fn test_hira_to_kata_all_characters() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::HiraToKata,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゔ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴ");
    }

    #[test]
    fn test_hira_to_kata_wi_we() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::HiraToKata,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ゐゑ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ヰヱ");
    }

    #[test]
    fn test_kata_to_hira_basic() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::KataToHira,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("アイウエオ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "あいうえお");
    }

    #[test]
    fn test_kata_to_hira_voiced() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::KataToHira,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ガギグゲゴ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "がぎぐげご");
    }

    #[test]
    fn test_kata_to_hira_semi_voiced() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::KataToHira,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("パピプペポ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ぱぴぷぺぽ");
    }

    #[test]
    fn test_kata_to_hira_small() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::KataToHira,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ァィゥェォッャュョ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ぁぃぅぇぉっゃゅょ");
    }

    #[test]
    fn test_kata_to_hira_mixed() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::KataToHira,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("アイウエオ123ABCあいうえお");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(
            from_chars(result.iter().cloned()),
            "あいうえお123ABCあいうえお"
        );
    }

    #[test]
    fn test_kata_to_hira_phrase() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::KataToHira,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("コンニチハ、世界！");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "こんにちは、世界！");
    }

    #[test]
    fn test_kata_to_hira_vu() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::KataToHira,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ヴ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ゔ");
    }

    #[test]
    fn test_kata_to_hira_special_katakana() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::KataToHira,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        // Special katakana without hiragana equivalents should remain unchanged
        let input_chars = pool.build_char_array("ヷヸヹヺ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ヷヸヹヺ");
    }

    #[test]
    fn test_kata_to_hira_all_characters() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::KataToHira,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲンガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポヴ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽゔ");
    }

    #[test]
    fn test_kata_to_hira_wi_we() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::KataToHira,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ヰヱ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ゐゑ");
    }

    #[test]
    fn test_kata_to_hira_small_wa_ka_ke() {
        let options = HiraKataTransliteratorOptions {
            mode: Mode::KataToHira,
        };
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ヮヵヶ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "ゎゕゖ");
    }

    #[test]
    fn test_default_mode() {
        // Test that default mode is HiraToKata
        let options = HiraKataTransliteratorOptions::default();
        let transliterator = HiraKataTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("あいうえお");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(from_chars(result.iter().cloned()), "アイウエオ");
    }
}
