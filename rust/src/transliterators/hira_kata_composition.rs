use serde::{Deserialize, Serialize};
use std::borrow::Cow;
use std::collections::HashMap;
use std::sync::LazyLock;

use crate::char::{Char, CharPool};
use crate::transliterator::{Transliterator, TransliteratorFactory};
use crate::{TransliterationError, TransliteratorFactoryError};

/// Options for the hiragana katakana composition transliterator
#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub struct HiraKataCompositionTransliteratorOptions {
    /// Whether to compose non-combining marks (replace ゙ and ゚ with ゛ and ゜)
    #[serde(default)]
    pub compose_non_combining_marks: bool,
}

/// Static composition table mapping base+mark pairs to composed characters
static COMPOSITION_MAP: LazyLock<HashMap<(char, char), &'static str>> = LazyLock::new(|| {
    let mut map = HashMap::new();

    // Hiragana with voiced sound mark (U+3099)
    map.insert(('\u{304b}', '\u{3099}'), "\u{304c}"); // か + ゙ -> が
    map.insert(('\u{304d}', '\u{3099}'), "\u{304e}"); // き + ゙ -> ぎ
    map.insert(('\u{304f}', '\u{3099}'), "\u{3050}"); // く + ゙ -> ぐ
    map.insert(('\u{3051}', '\u{3099}'), "\u{3052}"); // け + ゙ -> げ
    map.insert(('\u{3053}', '\u{3099}'), "\u{3054}"); // こ + ゙ -> ご
    map.insert(('\u{3055}', '\u{3099}'), "\u{3056}"); // さ + ゙ -> ざ
    map.insert(('\u{3057}', '\u{3099}'), "\u{3058}"); // し + ゙ -> じ
    map.insert(('\u{3059}', '\u{3099}'), "\u{305a}"); // す + ゙ -> ず
    map.insert(('\u{305b}', '\u{3099}'), "\u{305c}"); // せ + ゙ -> ぜ
    map.insert(('\u{305d}', '\u{3099}'), "\u{305e}"); // そ + ゙ -> ぞ
    map.insert(('\u{305f}', '\u{3099}'), "\u{3060}"); // た + ゙ -> だ
    map.insert(('\u{3061}', '\u{3099}'), "\u{3062}"); // ち + ゙ -> ぢ
    map.insert(('\u{3064}', '\u{3099}'), "\u{3065}"); // つ + ゙ -> づ
    map.insert(('\u{3066}', '\u{3099}'), "\u{3067}"); // て + ゙ -> で
    map.insert(('\u{3068}', '\u{3099}'), "\u{3069}"); // と + ゙ -> ど
    map.insert(('\u{306f}', '\u{3099}'), "\u{3070}"); // は + ゙ -> ば
    map.insert(('\u{3072}', '\u{3099}'), "\u{3073}"); // ひ + ゙ -> び
    map.insert(('\u{3075}', '\u{3099}'), "\u{3076}"); // ふ + ゙ -> ぶ
    map.insert(('\u{3078}', '\u{3099}'), "\u{3079}"); // へ + ゙ -> べ
    map.insert(('\u{307b}', '\u{3099}'), "\u{307c}"); // ほ + ゙ -> ぼ
    map.insert(('\u{3046}', '\u{3099}'), "\u{3094}"); // う + ゙ -> ゔ
    map.insert(('\u{309d}', '\u{3099}'), "\u{309e}"); // ゝ + ゙ -> ゞ

    // Hiragana with semi-voiced sound mark (U+309A)
    map.insert(('\u{306f}', '\u{309a}'), "\u{3071}"); // は + ゚ -> ぱ
    map.insert(('\u{3072}', '\u{309a}'), "\u{3074}"); // ひ + ゚ -> ぴ
    map.insert(('\u{3075}', '\u{309a}'), "\u{3077}"); // ふ + ゚ -> ぷ
    map.insert(('\u{3078}', '\u{309a}'), "\u{307a}"); // へ + ゚ -> ぺ
    map.insert(('\u{307b}', '\u{309a}'), "\u{307d}"); // ほ + ゚ -> ぽ

    // Katakana with voiced sound mark (U+3099)
    map.insert(('\u{30ab}', '\u{3099}'), "\u{30ac}"); // カ + ゙ -> ガ
    map.insert(('\u{30ad}', '\u{3099}'), "\u{30ae}"); // キ + ゙ -> ギ
    map.insert(('\u{30af}', '\u{3099}'), "\u{30b0}"); // ク + ゙ -> グ
    map.insert(('\u{30b1}', '\u{3099}'), "\u{30b2}"); // ケ + ゙ -> ゲ
    map.insert(('\u{30b3}', '\u{3099}'), "\u{30b4}"); // コ + ゙ -> ゴ
    map.insert(('\u{30b5}', '\u{3099}'), "\u{30b6}"); // サ + ゙ -> ザ
    map.insert(('\u{30b7}', '\u{3099}'), "\u{30b8}"); // シ + ゙ -> ジ
    map.insert(('\u{30b9}', '\u{3099}'), "\u{30ba}"); // ス + ゙ -> ズ
    map.insert(('\u{30bb}', '\u{3099}'), "\u{30bc}"); // セ + ゙ -> ゼ
    map.insert(('\u{30bd}', '\u{3099}'), "\u{30be}"); // ソ + ゙ -> ゾ
    map.insert(('\u{30bf}', '\u{3099}'), "\u{30c0}"); // タ + ゙ -> ダ
    map.insert(('\u{30c1}', '\u{3099}'), "\u{30c2}"); // チ + ゙ -> ヂ
    map.insert(('\u{30c4}', '\u{3099}'), "\u{30c5}"); // ツ + ゙ -> ヅ
    map.insert(('\u{30c6}', '\u{3099}'), "\u{30c7}"); // テ + ゙ -> デ
    map.insert(('\u{30c8}', '\u{3099}'), "\u{30c9}"); // ト + ゙ -> ド
    map.insert(('\u{30cf}', '\u{3099}'), "\u{30d0}"); // ハ + ゙ -> バ
    map.insert(('\u{30d2}', '\u{3099}'), "\u{30d3}"); // ヒ + ゙ -> ビ
    map.insert(('\u{30d5}', '\u{3099}'), "\u{30d6}"); // フ + ゙ -> ブ
    map.insert(('\u{30d8}', '\u{3099}'), "\u{30d9}"); // ヘ + ゙ -> ベ
    map.insert(('\u{30db}', '\u{3099}'), "\u{30dc}"); // ホ + ゙ -> ボ
    map.insert(('\u{30a6}', '\u{3099}'), "\u{30f4}"); // ウ + ゙ -> ヴ
    map.insert(('\u{30ef}', '\u{3099}'), "\u{30f7}"); // ワ + ゙ -> ヷ
    map.insert(('\u{30f0}', '\u{3099}'), "\u{30f8}"); // ヰ + ゙ -> ヸ
    map.insert(('\u{30f1}', '\u{3099}'), "\u{30f9}"); // ヱ + ゙ -> ヹ
    map.insert(('\u{30f2}', '\u{3099}'), "\u{30fa}"); // ヲ + ゙ -> ヺ

    // Katakana with semi-voiced sound mark (U+309A)
    map.insert(('\u{30cf}', '\u{309a}'), "\u{30d1}"); // ハ + ゚ -> パ
    map.insert(('\u{30d2}', '\u{309a}'), "\u{30d4}"); // ヒ + ゚ -> ピ
    map.insert(('\u{30d5}', '\u{309a}'), "\u{30d7}"); // フ + ゚ -> プ
    map.insert(('\u{30d8}', '\u{309a}'), "\u{30da}"); // ヘ + ゚ -> ペ
    map.insert(('\u{30db}', '\u{309a}'), "\u{30dd}"); // ホ + ゚ -> ポ

    map
});

#[derive(Debug, Clone)]
pub struct HiraKataCompositionTransliterator {
    options: HiraKataCompositionTransliteratorOptions,
}

impl HiraKataCompositionTransliterator {
    pub fn new(options: HiraKataCompositionTransliteratorOptions) -> Self {
        Self { options }
    }

    fn try_compose(&self, base: char, mark: char) -> Option<&'static str> {
        // Try direct composition
        if let Some(&composed) = COMPOSITION_MAP.get(&(base, mark)) {
            return Some(composed);
        }

        // Try with non-combining marks if enabled
        if self.options.compose_non_combining_marks {
            let converted_mark = match mark {
                '\u{309b}' => '\u{3099}', // ゛ -> ゙ (non-combining to combining voiced)
                '\u{309c}' => '\u{309a}', // ゜ -> ゚ (non-combining to combining semi-voiced)
                _ => return None,
            };

            if let Some(&composed) = COMPOSITION_MAP.get(&(base, converted_mark)) {
                return Some(composed);
            }
        }

        None
    }

    fn can_be_composed(&self, ch: char) -> bool {
        // Check if this character appears as a base in any composition
        COMPOSITION_MAP.keys().any(|(base, _)| *base == ch)
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

        while i < chars.len() {
            let current_char = chars[i];

            // Skip sentinel characters
            if current_char.is_sentinel() {
                result.push(pool.new_with_offset(current_char, offset));
                i += 1;
                continue;
            }

            // Get first character from current
            let base_char = current_char.c.chars().next().ok_or_else(|| {
                TransliterationError::Failed("Empty character encountered".to_string())
            })?;

            // Check if we can form a two-character composition with the next character
            if self.can_be_composed(base_char) && i + 1 < chars.len() {
                let next_char = chars[i + 1];

                // Skip if next character is empty (sentinel)
                if !next_char.is_sentinel() {
                    if let Some(mark_char) = next_char.c.chars().next() {
                        // Try to compose the characters
                        if let Some(composed) = self.try_compose(base_char, mark_char) {
                            // Create a new composed character
                            let nc =
                                pool.new_char_from(Cow::Borrowed(composed), offset, current_char);
                            offset += nc.c.len();
                            result.push(nc);
                            i += 2; // Skip both characters
                            continue;
                        }
                    }
                }
            }

            // No composition possible, keep the original character
            let nc = pool.new_with_offset(current_char, offset);
            offset += nc.c.len();
            result.push(nc);
            i += 1;
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

        // Test か + ゙ -> が
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

        // Test カ + ゙ -> ガ
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

        // Test は + ゚ -> ぱ
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
