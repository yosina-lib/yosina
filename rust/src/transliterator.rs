use super::char::{Char, CharPool};

#[derive(thiserror::Error, Debug)]
pub enum TransliterationError {
    #[error("Transliteration failed: {0}")]
    Failed(String),
}

/// A transliterator function that transforms an iterator of characters
pub trait Transliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        input: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError>;
}

pub struct FnTransliterator<T>(pub T)
where
    T: for<'a, 'b> Fn(
        &mut CharPool<'a, 'b>,
        &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError>;

impl<T> From<T> for FnTransliterator<T>
where
    T: for<'a, 'b> Fn(
        &mut CharPool<'a, 'b>,
        &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError>,
{
    fn from(f: T) -> Self {
        FnTransliterator(f)
    }
}

impl<T> Transliterator for FnTransliterator<T>
where
    T: for<'a, 'b> Fn(
        &mut CharPool<'a, 'b>,
        &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError>,
{
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        input: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        (self.0)(pool, input)
    }
}

impl Transliterator for Vec<Box<dyn Transliterator>> {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        input: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        self.iter()
            .try_fold(input.to_vec(), |input, t| t.transliterate(pool, &input))
    }
}

#[derive(thiserror::Error, Debug)]
#[error("Failed to create a transliterator: {message}")]
pub struct TransliteratorFactoryError {
    message: String,
    #[source]
    source: Option<Box<dyn std::error::Error + Send + Sync>>,
}

impl TransliteratorFactoryError {
    pub fn new(message: String) -> Self {
        TransliteratorFactoryError {
            message,
            source: None,
        }
    }

    pub fn with_source<E: std::error::Error + Send + Sync + 'static>(
        message: &str,
        source: E,
    ) -> Self {
        TransliteratorFactoryError {
            message: message.to_string(),
            source: Some(Box::new(source)),
        }
    }
}

/// A factory function that creates a transliterator with given options
pub trait TransliteratorFactory {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError>;
}

impl<I> TransliteratorFactory for Vec<I>
where
    I: TransliteratorFactory,
{
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        let transliterators = self
            .iter()
            .map(|f| f.new_transliterator())
            .collect::<Result<Vec<_>, _>>()?;
        if transliterators.is_empty() {
            return Err(TransliteratorFactoryError::new(
                "at least one transliterator must be specified".to_string(),
            ));
        }
        Ok(Box::new(transliterators))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::char::{from_chars, CharPool};
    use crate::transliterators::{HiraKataCompositionTransliteratorOptions, SimpleTransliterator};

    /// Create test SimpleTransliterators for chaining tests
    fn create_test_simple_transliterators() -> (SimpleTransliterator, SimpleTransliterator) {
        static FIRST_MAPPINGS: phf::Map<&'static str, &'static str> = phf::phf_map! {
            "a" => "1",
            "b" => "2",
            "c" => "3",
        };

        static SECOND_MAPPINGS: phf::Map<&'static str, &'static str> = phf::phf_map! {
            "1" => "α",
            "2" => "β",
            "3" => "γ",
        };

        (
            SimpleTransliterator::new(&FIRST_MAPPINGS),
            SimpleTransliterator::new(&SECOND_MAPPINGS),
        )
    }

    #[test]
    fn test_chained_transliterator_creation() {
        let (first, second) = create_test_simple_transliterators();

        let chain: Vec<Box<dyn Transliterator>> = vec![Box::new(first), Box::new(second)];

        // Test that chaining works: a -> 1 -> α
        let test_cases = &[
            ("a", "α"),
            ("b", "β"),
            ("c", "γ"),
            ("abc", "αβγ"),
            ("axc", "αxγ"), // 'x' should be preserved
        ];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = chain.transliterate(&mut pool, &input_chars).unwrap();
            let result_string = from_chars(result.iter().cloned());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_chained_transliterator_empty_chain() {
        let chain = vec![] as Vec<Box<dyn Transliterator>>;

        // Empty chain should preserve input
        let test_cases = &[("test", "test"), ("", ""), ("123", "123")];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = chain.transliterate(&mut pool, &input_chars).unwrap();
            let result_string = from_chars(result.iter().cloned());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_chained_transliterator_single_item() {
        let (first, _) = create_test_simple_transliterators();

        let chain: Vec<Box<dyn Transliterator>> = vec![Box::new(first)];

        // Single item chain should work like the single transliterator
        let test_cases = &[("a", "1"), ("b", "2"), ("c", "3"), ("abc", "123")];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = chain.transliterate(&mut pool, &input_chars).unwrap();
            let result_string = from_chars(result.iter().cloned());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_mixed_transliterator_chain() {
        // Create a chain mixing SimpleTransliterator with manual transliterators
        let (first_simple, _) = create_test_simple_transliterators();
        let manual = HiraKataCompositionTransliteratorOptions::default()
            .new_transliterator()
            .unwrap();

        let chain = vec![Box::new(first_simple), manual];

        // Test that the chain works
        let test_cases = &[
            ("a", "1"), // a -> 1, then preserved by manual transliterator
            ("abc", "123"),
            ("xyz", "xyz"), // Not mapped by first, preserved by second
        ];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = chain.transliterate(&mut pool, &input_chars).unwrap();
            let result_string = from_chars(result.iter().cloned());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_transliterator_chain_preserves_sentinels() {
        let (first, second) = create_test_simple_transliterators();

        let chain: Vec<Box<dyn Transliterator>> = vec![Box::new(first), Box::new(second)];

        // Test sentinel handling
        let mut pool = CharPool::new();
        let sentinel = pool.new_sentinel(0);
        let input = vec![sentinel];
        let result = chain.transliterate(&mut pool, &input).unwrap();
        assert_eq!(result.len(), 1);
        assert!(
            result[0].c.is_empty(),
            "Sentinel character should be preserved"
        );
    }

    #[test]
    fn test_transliterator_chain_character_metadata() {
        use crate::char::from_chars;

        let (first, second) = create_test_simple_transliterators();

        let chain: Vec<Box<dyn Transliterator>> = vec![Box::new(first), Box::new(second)];

        let mut pool = CharPool::new();
        let input_chars = pool.build_char_array("abc");

        // Store original offsets
        let original_offsets: Vec<usize> = input_chars.iter().map(|c| c.offset).collect();

        let result = chain.transliterate(&mut pool, &input_chars);
        assert!(result.is_ok());

        let result_chars = result.unwrap();
        let result_string = from_chars(result_chars.iter().cloned());

        // Check that transformation worked
        assert_eq!(result_string, "αβγ");

        // Check that offsets are correctly calculated
        for (i, char) in result_chars.iter().enumerate() {
            if !char.c.is_empty() && i < original_offsets.len() {
                assert_eq!(char.offset, original_offsets[i] * 2);
            }
        }

        // Check that source tracking is maintained through the chain
        for char in result_chars.iter() {
            if !char.c.is_empty() {
                // Each character should have source tracking
                assert!(char.source.is_some());
            }
        }
    }

    #[test]
    fn test_complex_unicode_chain() {
        // Create transliterators that handle Unicode
        static UNICODE_TO_ASCII: phf::Map<&'static str, &'static str> = phf::phf_map! {
            "こ" => "ko",
            "ん" => "n",
            "ば" => "ba",
            "は" => "wa",
        };

        static ASCII_TO_NUMBERS: phf::Map<&'static str, &'static str> = phf::phf_map! {
            "ko" => "1",
            "n" => "2",
            "ba" => "3",
            "wa" => "4",
        };

        let unicode_transliterator = SimpleTransliterator::new(&UNICODE_TO_ASCII);
        let ascii_transliterator = SimpleTransliterator::new(&ASCII_TO_NUMBERS);

        let chain: Vec<Box<dyn Transliterator>> = vec![
            Box::new(unicode_transliterator),
            Box::new(ascii_transliterator),
        ];

        let test_cases = &[
            ("こ", "1"),
            ("ん", "2"),
            ("こんばんは", "12324"),
            ("こんbanana", "12ba2a2a"), // Mixed input
        ];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = chain.transliterate(&mut pool, &input_chars).unwrap();
            let result_string = from_chars(result.iter().cloned());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_error_propagation_in_chain() {
        // Create a mock transliterator that always fails
        struct FailingTransliterator;

        impl Transliterator for FailingTransliterator {
            fn transliterate<'a, 'b>(
                &self,
                _pool: &mut CharPool<'a, 'b>,
                _input: &[&'a crate::char::Char<'a, 'b>],
            ) -> Result<
                Vec<&'a crate::char::Char<'a, 'b>>,
                crate::transliterator::TransliterationError,
            > {
                Err(crate::transliterator::TransliterationError::Failed(
                    "Test error".to_string(),
                ))
            }
        }

        let (first, _) = create_test_simple_transliterators();

        let chain: Vec<Box<dyn Transliterator>> =
            vec![Box::new(first), Box::new(FailingTransliterator)];

        let mut pool = CharPool::new();
        let input_chars = pool.build_char_array("test");

        let result = chain.transliterate(&mut pool, &input_chars);
        assert!(result.is_err());
    }

    #[test]
    fn test_performance_with_long_chain() {
        // Create a chain of 10 identity transliterators
        let mut transliterators: Vec<Box<dyn Transliterator>> = Vec::new();

        for _ in 0..10 {
            static IDENTITY_MAPPINGS: phf::Map<&'static str, &'static str> = phf::phf_map! {};
            let identity = SimpleTransliterator::new(&IDENTITY_MAPPINGS);
            transliterators.push(Box::new(identity));
        }

        // Should still work correctly with long chain
        let test_cases = &[
            ("test", "test"),
            ("long input string", "long input string"),
            ("", ""),
        ];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = transliterators
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().cloned());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }
}
