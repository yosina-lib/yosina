use crate::char::{Char, CharPool};
use crate::transliterator::{TransliterationError, Transliterator};
use std::borrow::Cow;

/// A generic simple transliterator that uses a PHF map for character-to-character mappings
pub struct SimpleTransliterator {
    mappings: &'static phf::Map<&'static str, &'static str>,
}

impl SimpleTransliterator {
    /// Create a new SimpleTransliterator with the given mappings
    pub fn new(mappings: &'static phf::Map<&'static str, &'static str>) -> Self {
        Self { mappings }
    }
}

impl Transliterator for SimpleTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        input: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mut result = Vec::new();
        let mut offset = 0;

        for char in input {
            if char.c.is_empty() {
                // Sentinel character - preserve it
                result.push(*char);
                continue;
            }

            let nc = if let Some(mapped) = self.mappings.get(char.c.as_ref()) {
                // Create new character with mapped value
                pool.new_char_from(Cow::Borrowed(mapped), offset, char)
            } else {
                // Keep original character
                pool.new_with_offset(char, offset)
            };
            offset += nc.c.len();
            result.push(nc);
        }

        Ok(result)
    }
}

// Note: TransliteratorFactory implementation removed to avoid conflicts with generated wrappers
// Each generated transliterator will have its own wrapper struct with the factory implementation

#[cfg(test)]
mod tests {
    use super::*;
    use crate::char::from_chars;

    /// Create a test SimpleTransliterator with basic mappings
    fn create_basic_test_transliterator() -> SimpleTransliterator {
        static BASIC_MAPPINGS: phf::Map<&'static str, &'static str> = phf::phf_map! {
            "a" => "α",
            "b" => "β",
            "c" => "γ",
            "h" => "こんにちは",
        };
        SimpleTransliterator::new(&BASIC_MAPPINGS)
    }

    /// Create a test SimpleTransliterator with Unicode mappings
    fn create_unicode_test_transliterator() -> SimpleTransliterator {
        static UNICODE_MAPPINGS: phf::Map<&'static str, &'static str> = phf::phf_map! {
            "α" => "a",
            "β" => "b",
            "こ" => "ko",
            "ん" => "n",
            "ば" => "ba",
            "は" => "wa",
        };
        SimpleTransliterator::new(&UNICODE_MAPPINGS)
    }

    #[test]
    fn test_simple_transliterator_basic_mappings() {
        let transliterator = create_basic_test_transliterator();

        let test_cases = &[
            ("a", "α"),
            ("b", "β"),
            ("c", "γ"),
            ("ab", "αβ"),
            ("abc", "αβγ"),
            ("h", "こんにちは"),
        ];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().cloned());
            assert_eq!(
                result_string, *expected,
                "Failed for input '{input}', result: '{result_string}'"
            );
        }
    }

    #[test]
    fn test_simple_transliterator_no_mapping() {
        let transliterator = create_basic_test_transliterator();

        // Characters without mappings should be preserved
        let test_cases = &[
            ("d", "d"),
            ("x", "x"),
            ("xyz", "xyz"),
            ("1", "1"),
            ("!", "!"),
            (" ", " "),
        ];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_simple_transliterator_mixed_input() {
        let transliterator = create_basic_test_transliterator();

        // Mix of mapped and unmapped characters
        let test_cases = &[
            ("ax", "αx"),
            ("bz", "βz"),
            ("h world", "こんにちは world"),
            ("a1b2c3", "α1β2γ3"),
            ("test_a_test", "test_α_test"),
        ];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_simple_transliterator_unicode_input() {
        let transliterator = create_unicode_test_transliterator();

        let test_cases = &[
            ("α", "a"),
            ("β", "b"),
            ("こ", "ko"),
            ("ん", "n"),
            ("こんばんは", "konbanwa"),
            ("αβγ", "abγ"), // γ not mapped, should be preserved
        ];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_simple_transliterator_empty_input() {
        let transliterator = create_basic_test_transliterator();

        // Test empty input
        let mut pool = CharPool::new();
        let input_chars = pool.build_char_array("");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let non_sentinel_chars: Vec<_> = result.iter().filter(|c| !c.c.is_empty()).collect();
        assert!(
            non_sentinel_chars.is_empty(),
            "Expected empty result for empty input"
        );
    }

    #[test]
    fn test_simple_transliterator_sentinel_handling() {
        let transliterator = create_basic_test_transliterator();

        // Test sentinel handling
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

    #[test]
    fn test_simple_transliterator_direct_usage() {
        let transliterator = create_basic_test_transliterator();

        // Test direct usage of the transliterator
        let mut pool = CharPool::new();
        let input_chars = pool.build_char_array("abc");
        let result = transliterator.transliterate(&mut pool, &input_chars);

        assert!(result.is_ok());
        let result_chars = result.unwrap();
        let result_string = from_chars(result_chars.iter().cloned());
        assert_eq!(result_string, "αβγ");
    }

    #[test]
    fn test_simple_transliterator_character_offsets() {
        let transliterator = create_basic_test_transliterator();
        let mut pool = CharPool::new();
        let input_chars = pool.build_char_array("abc");

        let result = transliterator.transliterate(&mut pool, &input_chars);
        assert!(result.is_ok());

        let result_chars = result.unwrap();

        // Check that offsets are preserved from original characters
        assert_eq!(result_chars[0].offset, 0); // 'a' -> 'α'
        assert_eq!(result_chars[1].offset, 2); // 'b' -> 'β'
        assert_eq!(result_chars[2].offset, 4); // 'c' -> 'γ'

        // Check that source tracking works
        assert!(result_chars[0].source.is_some());
        assert!(result_chars[1].source.is_some());
        assert!(result_chars[2].source.is_some());
    }

    #[test]
    fn test_simple_transliterator_variation_selectors() {
        let transliterator = create_basic_test_transliterator();

        // Test input with variation selectors (these should be handled by CharPool)
        let input_with_vs = "a\u{FE00}b"; // 'a' with variation selector-1
        let mut pool = CharPool::new();
        let input_chars = pool.build_char_array(input_with_vs);

        let result = transliterator.transliterate(&mut pool, &input_chars);
        assert!(result.is_ok());

        // The variation selector should be preserved with the character
        let result_chars = result.unwrap();
        let result_string = from_chars(result_chars.iter().cloned());

        // First character should be the combined sequence, second should be 'β'
        assert!(result_string.contains("β"));
    }

    #[test]
    fn test_simple_transliterator_multibyte_unicode() {
        let transliterator = create_basic_test_transliterator();

        // Test with multibyte Unicode characters
        let input = "a🎌b"; // Japanese flag emoji between mapped characters
        let mut pool = CharPool::new();
        let input_chars = pool.build_char_array(input);

        let result = transliterator.transliterate(&mut pool, &input_chars);
        assert!(result.is_ok());

        let result_chars = result.unwrap();
        let result_string = from_chars(result_chars.iter().cloned());
        assert_eq!(result_string, "α🎌β");
    }
}
