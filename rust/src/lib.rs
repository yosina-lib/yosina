#![doc = include_str!("../README.md")]

pub mod char;
#[cfg(not(feature = "codegen"))]
pub mod recipes;
pub mod transliterator;
pub mod transliterators;

pub use char::*;
pub use transliterator::*;

#[cfg(not(feature = "codegen"))]
pub use recipes::TransliterationRecipe;
pub use transliterators::TransliteratorConfig;

/// Frontend convenience function to create a string-to-string transliterator from a recipe or a list of configs.
///
/// This is the main entry point for the library. It accepts either a recipe or a list of transliterator configs
/// and returns a function that can transliterate strings.
///
/// # Arguments
///
/// * `configs_or_recipe` - Either a vector of configs/strings or a TransliterationRecipe
///
/// # Returns
///
/// A function that takes a string and returns a transliterated string
#[cfg(not(feature = "codegen"))]
pub fn make_transliterator(
    factory: &impl TransliteratorFactory,
) -> Result<impl Fn(&str) -> Result<String, TransliterationError>, TransliteratorFactoryError> {
    let tl = factory.new_transliterator()?;

    Ok(move |input: &str| -> Result<String, TransliterationError> {
        let mut pool = CharPool::new();
        let chars = pool.build_char_array(input);
        let transliterated = tl.transliterate(&mut pool, &chars)?;
        Ok(from_chars(transliterated.iter().cloned()))
    })
}
