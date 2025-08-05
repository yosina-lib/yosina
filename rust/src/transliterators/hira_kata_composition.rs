use serde::{Deserialize, Serialize};
use std::borrow::Cow;
use std::collections::HashMap;

use crate::char::{Char, CharPool};
use crate::transliterator::{Transliterator, TransliteratorFactory};
use crate::{TransliterationError, TransliteratorFactoryError};

use super::hira_kata_table::{generate_semi_voiced_characters, generate_voiced_characters};

/// Options for the hiragana katakana composition transliterator
#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub struct HiraKataCompositionTransliteratorOptions {
    /// Whether to compose non-combining marks (replace ゛and ゜with ゛ and ゜)
    #[serde(default)]
    pub compose_non_combining_marks: bool,
}

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
        let voiced_characters = generate_voiced_characters();
        let semi_voiced_characters = generate_semi_voiced_characters();

        let mut voiced_table = HashMap::new();
        for &(base, voiced) in &voiced_characters {
            voiced_table.insert(base, voiced);
        }

        let mut semi_voiced_table = HashMap::new();
        for &(base, semi_voiced) in &semi_voiced_characters {
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
    fn test_vertical_iteration_marks() {
        let options = HiraKataCompositionTransliteratorOptions::default();
        let transliterator = HiraKataCompositionTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test 〱 + ゛-> 〲 (vertical hiragana)
        let input_chars1 = pool.build_char_array("\u{3031}\u{3099}");
        let result1 = transliterator
            .transliterate(&mut pool, &input_chars1)
            .unwrap();

        assert_eq!(result1.len(), 2);
        assert_eq!(result1[0].c, "\u{3032}");
        assert!(result1[1].is_sentinel());

        // Test 〳 + ゛-> 〴 (vertical katakana)
        let input_chars2 = pool.build_char_array("\u{3033}\u{3099}");
        let result2 = transliterator
            .transliterate(&mut pool, &input_chars2)
            .unwrap();

        assert_eq!(result2.len(), 2);
        assert_eq!(result2[0].c, "\u{3034}");
        assert!(result2[1].is_sentinel());
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

        // Test vertical hiragana iteration mark with non-combining voiced mark
        let input_chars3 = pool.build_char_array("\u{3031}\u{309b}"); // 〱 + ゛
        let result3 = transliterator
            .transliterate(&mut pool, &input_chars3)
            .unwrap();

        assert_eq!(result3.len(), 2);
        assert_eq!(result3[0].c, "\u{3032}"); // 〲
        assert!(result3[1].is_sentinel());

        // Test vertical katakana iteration mark with non-combining voiced mark
        let input_chars4 = pool.build_char_array("\u{3033}\u{309b}"); // 〳 + ゛
        let result4 = transliterator
            .transliterate(&mut pool, &input_chars4)
            .unwrap();

        assert_eq!(result4.len(), 2);
        assert_eq!(result4[0].c, "\u{3034}"); // 〴
        assert!(result4[1].is_sentinel());
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
