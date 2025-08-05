use serde::{Deserialize, Serialize};
use std::borrow::Cow;
use std::collections::HashMap;
use std::sync::OnceLock;

use super::Charset;
use crate::char::{Char, CharPool};
use crate::transliterator::{
    TransliterationError, Transliterator, TransliteratorFactory, TransliteratorFactoryError,
};

#[derive(Debug, Clone)]
pub struct IvsSvsBaseRecord {
    pub ivs: &'static str,
    pub svs: Option<&'static str>,
    pub base90: Option<&'static str>,
    pub base2004: Option<&'static str>,
}

#[derive(Debug, Clone, Copy, PartialEq, Deserialize, Serialize)]
pub enum IvsSvsBaseMode {
    #[serde(rename = "ivs-or-svs")]
    IvsOrSvs(bool),
    #[serde(rename = "base")]
    Base,
}

include!("./ivs_svs_base_data.rs");

/// Check if a character is an IVS or SVS selector
fn is_selector(c: char) -> bool {
    // IVS range: U+E0100 to U+E01EF
    // SVS range: U+FE00 to U+FE0F
    (0xE0100u32..=0xE01EF).contains(&(c as u32)) || (0xFE00u32..=0xFE0F).contains(&(c as u32))
}

struct IvsSvsBaseMappings<'a> {
    source: &'a [IvsSvsBaseRecord],
    get_base_to_variants_90_mappings: std::sync::OnceLock<HashMap<&'a str, &'a IvsSvsBaseRecord>>,
    get_base_to_variants_2004_mappings: std::sync::OnceLock<HashMap<&'a str, &'a IvsSvsBaseRecord>>,
    get_to_base_mappings: std::sync::OnceLock<HashMap<&'a str, &'a IvsSvsBaseRecord>>,
}

impl<'a> IvsSvsBaseMappings<'a> {
    fn get() -> &'static Self {
        static SELF: OnceLock<IvsSvsBaseMappings> = OnceLock::new();
        OnceLock::get_or_init(&SELF, || IvsSvsBaseMappings::new(&MAPPINGS))
    }

    fn new(source: &'a [IvsSvsBaseRecord]) -> Self {
        Self {
            source,
            get_base_to_variants_90_mappings: OnceLock::new(),
            get_base_to_variants_2004_mappings: OnceLock::new(),
            get_to_base_mappings: OnceLock::new(),
        }
    }

    fn get_base_to_variants_90_mappings(&self) -> &HashMap<&'a str, &'a IvsSvsBaseRecord> {
        self.get_base_to_variants_90_mappings.get_or_init(|| {
            self.source
                .iter()
                .map(|r| (r.ivs, r))
                .chain(self.source.iter().filter_map(|r| r.svs.map(|svs| (svs, r))))
                .chain(
                    self.source
                        .iter()
                        .filter_map(|r| r.base90.map(|base| (base, r))),
                )
                .collect::<HashMap<_, _>>()
        })
    }

    fn get_base_to_variants_2004_mappings(&self) -> &HashMap<&'a str, &'a IvsSvsBaseRecord> {
        self.get_base_to_variants_2004_mappings.get_or_init(|| {
            self.source
                .iter()
                .map(|r| (r.ivs, r))
                .chain(self.source.iter().filter_map(|r| r.svs.map(|svs| (svs, r))))
                .chain(
                    self.source
                        .iter()
                        .filter_map(|r| r.base2004.map(|base| (base, r))),
                )
                .collect::<HashMap<_, _>>()
        })
    }

    fn get_variants_to_base_mappings(&self) -> &HashMap<&'a str, &'a IvsSvsBaseRecord> {
        self.get_to_base_mappings.get_or_init(|| {
            self.source
                .iter()
                .map(|r| (r.ivs, r))
                .chain(self.source.iter().filter_map(|r| r.svs.map(|svs| (svs, r))))
                .collect::<HashMap<_, _>>()
        })
    }

    #[allow(clippy::type_complexity)]
    fn get_variant_getter<'b>(
        &'b self,
        mode: IvsSvsBaseMode,
        charset: Charset,
    ) -> Box<dyn Fn(&str) -> Option<&'a str> + 'b> {
        use Charset::*;
        use IvsSvsBaseMode::*;

        match mode {
            IvsOrSvs(prefer_svs) => {
                let mappings = match charset {
                    Unijis90 => self.get_base_to_variants_90_mappings(),
                    Unijis2004 => self.get_base_to_variants_2004_mappings(),
                };
                if prefer_svs {
                    Box::new(move |c: &str| mappings.get(c).and_then(|r| r.svs.or(Some(r.ivs))))
                } else {
                    Box::new(move |c: &str| {
                        mappings
                            .get(c)
                            .map(|r| r.ivs)
                            .or_else(|| mappings.get(c).and_then(|r| r.svs))
                    })
                }
            }
            Base => {
                let mappings = self.get_variants_to_base_mappings();
                match charset {
                    Unijis90 => Box::new(move |c: &str| mappings.get(c).and_then(|r| r.base90)),
                    Unijis2004 => Box::new(move |c: &str| mappings.get(c).and_then(|r| r.base2004)),
                }
            }
        }
    }
}

/// Options for the IVS/SVS base transliterator
#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct IvsSvsBaseTransliteratorOptions {
    /// Transliteration mode
    pub mode: IvsSvsBaseMode,

    /// Character set to use for base mappings
    #[serde(default)]
    pub charset: Charset,

    /// When the mode is `"base"`, get rid of all the selectors from the result, regardless of being contained in the mappings
    #[serde(default)]
    pub drop_selectors_altogether: bool,
}

impl Default for IvsSvsBaseTransliteratorOptions {
    fn default() -> Self {
        Self {
            mode: IvsSvsBaseMode::Base,
            charset: Charset::Unijis2004,
            drop_selectors_altogether: false,
        }
    }
}

/// IVS/SVS base transliterator implementation
pub struct IvsSvsBaseTransliterator {
    options: IvsSvsBaseTransliteratorOptions,
    #[allow(clippy::type_complexity)]
    getter: Box<dyn Fn(&str) -> Option<&'static str> + 'static>,
}

impl IvsSvsBaseTransliterator {
    pub fn new(options: IvsSvsBaseTransliteratorOptions) -> Self {
        let getter = IvsSvsBaseMappings::get().get_variant_getter(options.mode, options.charset);
        Self { options, getter }
    }
}

impl Transliterator for IvsSvsBaseTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        input: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mut result = Vec::new();
        let mut offset = 0;

        for &c in input {
            if c.is_sentinel() {
                // Sentinel character - preserve it
                result.push(c);
                continue;
            }

            // In base mode with drop_selectors_altogether, check if this is a selector
            if self.options.mode == IvsSvsBaseMode::Base && self.options.drop_selectors_altogether {
                let chars: Vec<_> = c.c.char_indices().collect();
                if chars.len() == 2 && is_selector(chars[1].1) {
                    let nc = pool.new_char_from(
                        match c.c {
                            Cow::Borrowed(c) => Cow::Borrowed(&c[..chars[1].0]),
                            Cow::Owned(ref c) => Cow::Owned(c[..chars[1].0].to_owned()),
                        },
                        offset,
                        c,
                    );
                    offset += nc.c.len();
                    result.push(nc);
                    continue;
                }
            }

            // Check if this character needs replacement
            if let Some(replacement) = (self.getter)(c.c.as_ref()) {
                let nc = pool.new_char_from(Cow::Borrowed(replacement), offset, c);
                offset += nc.c.len();
                result.push(nc);
                continue;
            }

            // No match, keep original character
            let nc = pool.new_with_offset(c, offset);
            offset += nc.c.len();
            result.push(nc);
        }

        Ok(result)
    }
}

impl TransliteratorFactory for IvsSvsBaseTransliteratorOptions {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(IvsSvsBaseTransliterator::new(self.clone())))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::char::CharPool;

    #[test]
    fn test_basic_ivs_replacement() {
        let test_cases = vec![
            (Charset::Unijis90, "\u{8FBB}\u{E0100}", "\u{8FBB}"),
            (
                Charset::Unijis2004,
                "\u{8FBB}\u{E0100}",
                "\u{8FBB}\u{E0100}",
            ),
            (Charset::Unijis90, "\u{8FBB}\u{E0101}", "\u{8FBB}\u{E0101}"),
            (Charset::Unijis2004, "\u{8FBB}\u{E0101}", "\u{8FBB}"),
            (Charset::Unijis2004, "\u{4EDD}\u{E0100}", "\u{4EDD}"),
        ];
        for (charset, input, expected) in test_cases {
            let options = IvsSvsBaseTransliteratorOptions {
                mode: IvsSvsBaseMode::Base,
                charset,
                drop_selectors_altogether: false,
            };
            let transliterator = IvsSvsBaseTransliterator::new(options);
            let mut pool = CharPool::new();

            // Test basic IVS sequence replacement
            // Using a known IVS sequence from the data
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();

            // Should replace IVS with base90 variant (default)
            assert_eq!(result.len(), 2); // replacement + sentinel
            assert_eq!(result[0].c, expected); // Base90 replacement
            assert!(result[1].c.is_empty()); // sentinel
        }
    }

    #[test]
    fn test_different_variants() {
        let mut pool = CharPool::new();

        // Test base90 charset (default)
        let base90_options = IvsSvsBaseTransliteratorOptions {
            mode: super::IvsSvsBaseMode::Base,
            charset: Charset::Unijis90,
            ..Default::default()
        };
        let base90_transliterator = IvsSvsBaseTransliterator::new(base90_options);

        let input_chars = pool.build_char_array("\u{4EDD}\u{E0100}");
        let result = base90_transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(result[0].c, "\u{4EDD}");

        // Test base2004 charset
        let base2004_options = IvsSvsBaseTransliteratorOptions {
            mode: super::IvsSvsBaseMode::Base,
            charset: Charset::Unijis2004,
            ..Default::default()
        };
        let base2004_transliterator = IvsSvsBaseTransliterator::new(base2004_options);

        let input_chars2 = pool.build_char_array("\u{4EDD}\u{E0100}");
        let result2 = base2004_transliterator
            .transliterate(&mut pool, &input_chars2)
            .unwrap();
        assert_eq!(result2[0].c, "\u{4EDD}");
    }

    #[test]
    fn test_no_replacement_for_non_ivs() {
        let options = IvsSvsBaseTransliteratorOptions::default();
        let transliterator = IvsSvsBaseTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test that non-IVS characters are preserved
        let input_chars = pool.build_char_array("普通の文字");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should preserve all original characters
        assert_eq!(result.len(), 6); // 5 characters + sentinel
        assert_eq!(result[0].c, "普");
        assert_eq!(result[1].c, "通");
        assert_eq!(result[2].c, "の");
        assert_eq!(result[3].c, "文");
        assert_eq!(result[4].c, "字");
        assert!(result[5].c.is_empty()); // sentinel
    }

    #[test]
    fn test_drop_selectors() {
        let options = IvsSvsBaseTransliteratorOptions {
            mode: super::IvsSvsBaseMode::Base,
            charset: Charset::Unijis90,
            drop_selectors_altogether: true,
        };
        let transliterator = IvsSvsBaseTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test with selectors that should be dropped
        let input_chars = pool.build_char_array("字\u{E0100}文\u{FE00}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // With drop_selectors_altogether=true, selectors should be removed
        assert_eq!(result.len(), 3); // "字", "文", sentinel
        assert_eq!(result[0].c, "字");
        assert_eq!(result[1].c, "文");
        assert!(result[2].c.is_empty()); // sentinel
    }

    #[test]
    fn test_is_selector() {
        // Test IVS selectors (U+E0100 to U+E01EF)
        assert!(is_selector('\u{E0100}'));
        assert!(is_selector('\u{E0150}'));
        assert!(is_selector('\u{E01EF}'));

        // Test SVS selectors (U+FE00 to U+FE0F)
        assert!(is_selector('\u{FE00}'));
        assert!(is_selector('\u{FE05}'));
        assert!(is_selector('\u{FE0F}'));

        // Test non-selectors
        assert!(!is_selector('a'));
        assert!(!is_selector('字'));
        assert!(!is_selector('\u{E0099}')); // Just before IVS range
        assert!(!is_selector('\u{E01F0}')); // Just after IVS range
        assert!(!is_selector('\u{FDFF}')); // Just before SVS range
        assert!(!is_selector('\u{FE10}')); // Just after SVS range
    }

    #[test]
    fn test_ivs_svs_base_record_creation() {
        // Test creating records with different combinations of fields
        let record1 = IvsSvsBaseRecord {
            ivs: "test_ivs",
            svs: Some("test_svs"),
            base90: Some("test_base90"),
            base2004: Some("test_base2004"),
        };
        assert_eq!(record1.ivs, "test_ivs");
        assert_eq!(record1.svs, Some("test_svs"));
        assert_eq!(record1.base90, Some("test_base90"));
        assert_eq!(record1.base2004, Some("test_base2004"));

        let record2 = IvsSvsBaseRecord {
            ivs: "ivs_only",
            svs: None,
            base90: None,
            base2004: None,
        };
        assert_eq!(record2.ivs, "ivs_only");
        assert_eq!(record2.svs, None);
        assert_eq!(record2.base90, None);
        assert_eq!(record2.base2004, None);
    }

    #[test]
    fn test_ivs_or_svs_mode() {
        let mut pool = CharPool::new();

        // Test IvsOrSvs mode with prefer_svs = false (default to IVS)
        let ivs_options = IvsSvsBaseTransliteratorOptions {
            mode: IvsSvsBaseMode::IvsOrSvs(false),
            charset: Charset::Unijis90,
            drop_selectors_altogether: false,
        };
        let ivs_transliterator = IvsSvsBaseTransliterator::new(ivs_options);

        // Test IvsOrSvs mode with prefer_svs = true
        let svs_options = IvsSvsBaseTransliteratorOptions {
            mode: IvsSvsBaseMode::IvsOrSvs(true),
            charset: Charset::Unijis90,
            drop_selectors_altogether: false,
        };
        let svs_transliterator = IvsSvsBaseTransliterator::new(svs_options);

        // Test with known character from mapping data
        let input_chars = pool.build_char_array("\u{8FBB}");

        let ivs_result = ivs_transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(ivs_result.len(), 2); // character + sentinel

        let svs_result = svs_transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        assert_eq!(svs_result.len(), 2); // character + sentinel
    }

    #[test]
    fn test_svs_sequences() {
        let mut pool = CharPool::new();

        // Test Base mode with SVS sequences
        let options = IvsSvsBaseTransliteratorOptions {
            mode: IvsSvsBaseMode::Base,
            charset: Charset::Unijis2004,
            drop_selectors_altogether: false,
        };
        let transliterator = IvsSvsBaseTransliterator::new(options);

        // Test various SVS sequences
        let test_cases = vec![
            ("字\u{FE00}", 2), // SVS selector FE00
            ("文\u{FE01}", 2), // SVS selector FE01
            ("本\u{FE0F}", 2), // SVS selector FE0F
        ];

        for (input, expected_len) in test_cases {
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            assert_eq!(result.len(), expected_len);
        }
    }

    #[test]
    fn test_edge_cases() {
        let mut pool = CharPool::new();
        let options = IvsSvsBaseTransliteratorOptions::default();
        let transliterator = IvsSvsBaseTransliterator::new(options);

        // Test empty input
        let empty_input = pool.build_char_array("");
        let empty_result = transliterator
            .transliterate(&mut pool, &empty_input)
            .unwrap();
        assert_eq!(empty_result.len(), 1); // Just sentinel
        assert!(empty_result[0].c.is_empty());

        // Test single character
        let single_char = pool.build_char_array("a");
        let single_result = transliterator
            .transliterate(&mut pool, &single_char)
            .unwrap();
        assert_eq!(single_result.len(), 2); // character + sentinel
        assert_eq!(single_result[0].c, "a");

        // Test invalid sequences (selector without base)
        let invalid_ivs = pool.build_char_array("\u{E0100}");
        let invalid_result = transliterator
            .transliterate(&mut pool, &invalid_ivs)
            .unwrap();
        assert_eq!(invalid_result.len(), 2); // selector + sentinel
        assert_eq!(invalid_result[0].c, "\u{E0100}");
    }

    #[test]
    fn test_mixed_content() {
        let mut pool = CharPool::new();

        // Test with drop_selectors_altogether enabled
        let options = IvsSvsBaseTransliteratorOptions {
            mode: IvsSvsBaseMode::Base,
            charset: Charset::Unijis90,
            drop_selectors_altogether: true,
        };
        let transliterator = IvsSvsBaseTransliterator::new(options);

        // Mixed content with IVS, SVS, and regular characters
        let mixed_input = pool.build_char_array("漢\u{E0100}字\u{FE00}文化");
        let result = transliterator
            .transliterate(&mut pool, &mixed_input)
            .unwrap();

        // Should have: "漢", "字", "文", "化", sentinel
        assert_eq!(result.len(), 5);
        assert_eq!(result[0].c, "漢");
        assert_eq!(result[1].c, "字");
        assert_eq!(result[2].c, "文");
        assert_eq!(result[3].c, "化");
        assert!(result[4].c.is_empty()); // sentinel
    }

    #[test]
    fn test_mappings_initialization() {
        // Test that mappings are properly initialized
        let mappings = IvsSvsBaseMappings::get();

        // Get base to variants mappings for both charsets
        let base90_mappings = mappings.get_base_to_variants_90_mappings();
        let base2004_mappings = mappings.get_base_to_variants_2004_mappings();
        let variants_to_base = mappings.get_variants_to_base_mappings();

        // Verify mappings are not empty (assuming MAPPINGS data exists)
        assert!(!base90_mappings.is_empty());
        assert!(!base2004_mappings.is_empty());
        assert!(!variants_to_base.is_empty());
    }

    #[test]
    fn test_multiple_selectors_in_sequence() {
        let mut pool = CharPool::new();

        // Test handling of multiple consecutive selectors
        let options = IvsSvsBaseTransliteratorOptions {
            mode: IvsSvsBaseMode::Base,
            charset: Charset::Unijis2004,
            drop_selectors_altogether: true,
        };
        let transliterator = IvsSvsBaseTransliterator::new(options);

        // Multiple selectors on same character
        let input = pool.build_char_array("字\u{E0100}\u{FE00}");
        let result = transliterator.transliterate(&mut pool, &input).unwrap();

        // Should handle gracefully
        assert!(!result.is_empty());
    }
}
