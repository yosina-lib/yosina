use serde::{Deserialize, Serialize};
use std::borrow::Cow;
use std::collections::HashMap;

use crate::char::{Char, CharPool};
use crate::transliterator::{Transliterator, TransliteratorFactory};
use crate::{TransliterationError, TransliteratorFactoryError};

/// Options for the hiragana katakana composition transliterator
#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub struct HiraKataCompositionTransliteratorOptions {
    /// Whether to compose non-combining marks (replace ゛and ゜with ゛ and ゜)
    #[serde(default)]
    pub compose_non_combining_marks: bool,
}

// Voiced character mappings (base -> voiced)
static VOICED_CHARACTERS: &[(&str, &str)] = &[
    ("\u{304b}", "\u{304c}"), // か -> が
    ("\u{304d}", "\u{304e}"), // き -> ぎ
    ("\u{304f}", "\u{3050}"), // く -> ぐ
    ("\u{3051}", "\u{3052}"), // け -> げ
    ("\u{3053}", "\u{3054}"), // こ -> ご
    ("\u{3055}", "\u{3056}"), // さ -> ざ
    ("\u{3057}", "\u{3058}"), // し -> じ
    ("\u{3059}", "\u{305a}"), // す -> ず
    ("\u{305b}", "\u{305c}"), // せ -> ぜ
    ("\u{305d}", "\u{305e}"), // そ -> ぞ
    ("\u{305f}", "\u{3060}"), // た -> だ
    ("\u{3061}", "\u{3062}"), // ち -> ぢ
    ("\u{3064}", "\u{3065}"), // つ -> づ
    ("\u{3066}", "\u{3067}"), // て -> で
    ("\u{3068}", "\u{3069}"), // と -> ど
    ("\u{306f}", "\u{3070}"), // は -> ば
    ("\u{3072}", "\u{3073}"), // ひ -> び
    ("\u{3075}", "\u{3076}"), // ふ -> ぶ
    ("\u{3078}", "\u{3079}"), // へ -> べ
    ("\u{307b}", "\u{307c}"), // ほ -> ぼ
    ("\u{3046}", "\u{3094}"), // う -> ゔ
    ("\u{309d}", "\u{309e}"), // ゝ -> ゞ
    // Katakana
    ("\u{30ab}", "\u{30ac}"), // カ -> ガ
    ("\u{30ad}", "\u{30ae}"), // キ -> ギ
    ("\u{30af}", "\u{30b0}"), // ク -> グ
    ("\u{30b1}", "\u{30b2}"), // ケ -> ゲ
    ("\u{30b3}", "\u{30b4}"), // コ -> ゴ
    ("\u{30b5}", "\u{30b6}"), // サ -> ザ
    ("\u{30b7}", "\u{30b8}"), // シ -> ジ
    ("\u{30b9}", "\u{30ba}"), // ス -> ズ
    ("\u{30bb}", "\u{30bc}"), // セ -> ゼ
    ("\u{30bd}", "\u{30be}"), // ソ -> ゾ
    ("\u{30bf}", "\u{30c0}"), // タ -> ダ
    ("\u{30c1}", "\u{30c2}"), // チ -> ヂ
    ("\u{30c4}", "\u{30c5}"), // ツ -> ヅ
    ("\u{30c6}", "\u{30c7}"), // テ -> デ
    ("\u{30c8}", "\u{30c9}"), // ト -> ド
    ("\u{30cf}", "\u{30d0}"), // ハ -> バ
    ("\u{30d2}", "\u{30d3}"), // ヒ -> ビ
    ("\u{30d5}", "\u{30d6}"), // フ -> ブ
    ("\u{30d8}", "\u{30d9}"), // ヘ -> ベ
    ("\u{30db}", "\u{30dc}"), // ホ -> ボ
    ("\u{30a6}", "\u{30f4}"), // ウ -> ヴ
    ("\u{30ef}", "\u{30f7}"), // ワ -> ヷ
    ("\u{30f0}", "\u{30f8}"), // ヰ -> ヸ
    ("\u{30f1}", "\u{30f9}"), // ヱ -> ヹ
    ("\u{30f2}", "\u{30fa}"), // ヲ -> ヺ
    ("\u{30fd}", "\u{30fe}"), // ヽ -> ヾ
];

// Semi-voiced character mappings (base -> semi-voiced)
static SEMI_VOICED_CHARACTERS: &[(&str, &str)] = &[
    ("\u{306f}", "\u{3071}"), // は -> ぱ
    ("\u{3072}", "\u{3074}"), // ひ -> ぴ
    ("\u{3075}", "\u{3077}"), // ふ -> ぷ
    ("\u{3078}", "\u{307a}"), // へ -> ぺ
    ("\u{307b}", "\u{307d}"), // ほ -> ぽ
    // Katakana
    ("\u{30cf}", "\u{30d1}"), // ハ -> パ
    ("\u{30d2}", "\u{30d4}"), // ヒ -> ピ
    ("\u{30d5}", "\u{30d7}"), // フ -> プ
    ("\u{30d8}", "\u{30da}"), // ヘ -> ペ
    ("\u{30db}", "\u{30dd}"), // ホ -> ポ
];

#[derive(Debug, Clone)]
pub struct HiraKataCompositionTransliterator {
    table: HashMap<&'static str, HashMap<&'static str, &'static str>>,
}

impl HiraKataCompositionTransliterator {
    pub fn new(options: HiraKataCompositionTransliteratorOptions) -> Self {
        let table = Self::build_table(options.compose_non_combining_marks);
        Self { table }
    }

    fn build_table(
        compose_non_combining_marks: bool,
    ) -> HashMap<&'static str, HashMap<&'static str, &'static str>> {
        let mut voiced_table = HashMap::new();
        for &(base, voiced) in VOICED_CHARACTERS {
            voiced_table.insert(base, voiced);
        }

        let mut semi_voiced_table = HashMap::new();
        for &(base, semi_voiced) in SEMI_VOICED_CHARACTERS {
            semi_voiced_table.insert(base, semi_voiced);
        }

        let mut table = HashMap::new();
        table.insert("\u{3099}", voiced_table.clone()); // combining voiced mark
        table.insert("\u{309a}", semi_voiced_table.clone()); // combining semi-voiced mark

        // Add non-combining marks if enabled
        if compose_non_combining_marks {
            table.insert("\u{309b}", voiced_table); // non-combining voiced mark
            table.insert("\u{309c}", semi_voiced_table); // non-combining semi-voiced mark
        }

        table
    }
}

impl Transliterator for HiraKataCompositionTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        chars: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mut result = Vec::new();
        let mut i = 0;
        let mut offset = 0;
        let mut pending_char: Option<&'a Char<'a, 'b>> = None;

        while i < chars.len() {
            let current_char = chars[i];

            // Process pending character if any
            if let Some(pc) = pending_char {
                pending_char = None;

                // Skip sentinel characters for composition
                if !current_char.is_sentinel() {
                    // Check if current character is a combining mark
                    if let Some(mark_table) = self.table.get(current_char.c.as_ref()) {
                        if let Some(&composed) = mark_table.get(pc.c.as_ref()) {
                            // Create composed character
                            let nc = pool.new_char_from(Cow::Borrowed(composed), offset, pc);
                            offset += nc.c.len();
                            result.push(nc);
                            i += 1;
                            continue;
                        }
                    }
                }

                // No composition, add pending char
                let nc = pool.new_with_offset(pc, offset);
                offset += nc.c.len();
                result.push(nc);
            }

            // Handle sentinel characters
            if current_char.is_sentinel() {
                result.push(pool.new_with_offset(current_char, offset));
                i += 1;
                continue;
            }

            // Save current character as pending to check for composition
            pending_char = Some(current_char);
            i += 1;
        }

        // Handle any remaining pending character
        if let Some(pc) = pending_char {
            let nc = pool.new_with_offset(pc, offset);
            result.push(nc);
        }

        Ok(result)
    }
}

impl TransliteratorFactory for HiraKataCompositionTransliteratorOptions {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(HiraKataCompositionTransliterator::new(
            self.clone(),
        )))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::char::from_chars;

    #[test]
    fn test_hiragana_composition() {
        let options = HiraKataCompositionTransliteratorOptions::default();
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test か + ゛-> が
        let input_chars = pool.build_char_array("か\u{3099}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should have composed character + sentinel
        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c, "が");
        assert!(result[1].is_sentinel());
    }

    #[test]
    fn test_katakana_composition() {
        let options = HiraKataCompositionTransliteratorOptions::default();
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test カ + ゛-> ガ
        let input_chars = pool.build_char_array("カ\u{3099}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c, "ガ");
        assert!(result[1].is_sentinel());
    }

    #[test]
    fn test_semi_voiced_composition() {
        let options = HiraKataCompositionTransliteratorOptions::default();
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test は + ゜-> ぱ
        let input_chars = pool.build_char_array("は\u{309a}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c, "ぱ");
        assert!(result[1].is_sentinel());
    }

    #[test]
    fn test_no_composition() {
        let options = HiraKataCompositionTransliteratorOptions::default();
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test regular characters that shouldn't compose
        let input_chars = pool.build_char_array("あい");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should have 3 characters: あ, い, sentinel
        assert_eq!(result.len(), 3);
        assert_eq!(result[0].c, "あ");
        assert_eq!(result[1].c, "い");
        assert!(result[2].is_sentinel());
    }

    #[test]
    fn test_mixed_composition() {
        let options = HiraKataCompositionTransliteratorOptions::default();
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test mixed composable and non-composable characters
        let input_chars = pool.build_char_array("あか\u{3099}い");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should have: あ, が (composed), い, sentinel
        assert_eq!(result.len(), 4);
        assert_eq!(result[0].c, "あ");
        assert_eq!(result[1].c, "が");
        assert_eq!(result[2].c, "い");
        assert!(result[3].is_sentinel());
    }

    #[test]
    fn test_non_combining_marks_option() {
        let options = HiraKataCompositionTransliteratorOptions {
            compose_non_combining_marks: true,
        };
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test with non-combining voiced mark (\u{309b})
        let input_chars = pool.build_char_array("か\u{309b}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c, "が");
        assert!(result[1].is_sentinel());
    }

    #[test]
    fn test_hiragana_iteration_mark() {
        let options = HiraKataCompositionTransliteratorOptions::default();
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test ゝ + ゛-> ゞ
        let input_chars = pool.build_char_array("\u{309d}\u{3099}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c, "\u{309e}");
        assert!(result[1].is_sentinel());
    }

    #[test]
    fn test_katakana_iteration_mark() {
        let options = HiraKataCompositionTransliteratorOptions::default();
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test ヽ + ゛-> ヾ
        let input_chars = pool.build_char_array("\u{30fd}\u{3099}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c, "\u{30fe}");
        assert!(result[1].is_sentinel());
    }

    #[test]
    fn test_special_katakana_composition() {
        let options = HiraKataCompositionTransliteratorOptions::default();
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test various special katakana compositions
        let test_cases = vec![
            ("\u{30ef}\u{3099}", "\u{30f7}"), // ワ + ゛-> ヷ
            ("\u{30f0}\u{3099}", "\u{30f8}"), // ヰ + ゛-> ヸ
            ("\u{30f1}\u{3099}", "\u{30f9}"), // ヱ + ゛-> ヹ
            ("\u{30f2}\u{3099}", "\u{30fa}"), // ヲ + ゛-> ヺ
        ];

        for (input, expected) in test_cases {
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();

            assert_eq!(result.len(), 2);
            assert_eq!(result[0].c, expected);
            assert!(result[1].is_sentinel());
        }
    }

    #[test]
    fn test_iteration_marks_with_non_combining() {
        let options = HiraKataCompositionTransliteratorOptions {
            compose_non_combining_marks: true,
        };
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test hiragana iteration mark with non-combining voiced mark
        let input_chars1 = pool.build_char_array("\u{309d}\u{309b}"); // ゝ + ゛
        let result1 = transliterator
            .transliterate(&mut pool, &input_chars1)
            .unwrap();

        assert_eq!(result1.len(), 2);
        assert_eq!(result1[0].c, "\u{309e}"); // ゞ
        assert!(result1[1].is_sentinel());

        // Test katakana iteration mark with non-combining voiced mark
        let input_chars2 = pool.build_char_array("\u{30fd}\u{309b}"); // ヽ + ゛
        let result2 = transliterator
            .transliterate(&mut pool, &input_chars2)
            .unwrap();

        assert_eq!(result2.len(), 2);
        assert_eq!(result2[0].c, "\u{30fe}"); // ヾ
        assert!(result2[1].is_sentinel());
    }

    #[test]
    fn test_various_characters_preserved() {
        let options = HiraKataCompositionTransliteratorOptions::default();
        let factory_result = options.new_transliterator();
        assert!(factory_result.is_ok());

        let transliterator = factory_result.unwrap();

        let test_cases = &[
            ("ひらがな", "ひらがな"),
            ("カタカナ", "カタカナ"),
            ("hello", "hello"),
            ("", ""),
        ];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().cloned());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_multiple_consecutive_compositions() {
        let options = HiraKataCompositionTransliteratorOptions::default();
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test multiple consecutive compositions
        let input_chars = pool.build_char_array("か\u{3099}き\u{3099}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 3);
        assert_eq!(result[0].c, "が");
        assert_eq!(result[1].c, "ぎ");
        assert!(result[2].is_sentinel());
    }

    #[test]
    fn test_efficiency_with_complex_input() {
        let options = HiraKataCompositionTransliteratorOptions::default();
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test with complex input containing multiple compositions
        let input = "あか\u{3099}き\u{3099}す\u{3099}せ\u{3099}そ\u{3099}た\u{3099}ち\u{3099}つ\u{3099}て\u{3099}と\u{3099}";
        let input_chars = pool.build_char_array(input);
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should efficiently compose all pairs
        let expected = "あがぎずぜぞだぢづでど";
        let result_string = from_chars(result.iter().cloned());
        assert_eq!(result_string, expected);
    }
}
