use std::borrow::Cow;
use std::collections::HashMap;
use std::sync::OnceLock;

use serde::{Deserialize, Serialize};

use crate::char::{Char, CharPool};
use crate::transliterator::{
    TransliterationError, Transliterator, TransliteratorFactory, TransliteratorFactoryError,
};

#[derive(Debug, Clone)]
struct HyphensRecord {
    pub ascii: Option<&'static str>,
    pub jisx0201: Option<&'static str>,
    pub jisx0208_90: Option<&'static str>,
    pub jisx0208_90_windows: Option<&'static str>,
    pub jisx0208_verbatim: Option<&'static str>,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Deserialize, Serialize)]
pub enum HyphensTransliterationVariant {
    Ascii,
    Jisx0201,
    Jisx0208_90,
    Jisx0208_90Windows,
    Jisx0208Verbatim,
}

include!("./hyphens_data.rs");

pub struct HyphensMappings(HashMap<&'static str, HyphensRecord>);

impl HyphensMappings {
    pub fn get() -> &'static Self {
        static SELF: OnceLock<HyphensMappings> = OnceLock::new();
        OnceLock::get_or_init(&SELF, || HyphensMappings(MAPPINGS.clone()))
    }

    fn get_ascii(&self, key: &str) -> Option<&'static str> {
        self.0.get(key).and_then(|r| r.ascii)
    }

    fn get_jisx0201(&self, key: &str) -> Option<&'static str> {
        self.0.get(key).and_then(|r| r.jisx0201)
    }

    fn get_jisx0208_90(&self, key: &str) -> Option<&'static str> {
        self.0.get(key).and_then(|r| r.jisx0208_90)
    }

    fn get_jisx0208_90_windows(&self, key: &str) -> Option<&'static str> {
        self.0.get(key).and_then(|r| r.jisx0208_90_windows)
    }

    fn get_jisx0208_verbatim(&self, key: &str) -> Option<&'static str> {
        self.0.get(key).and_then(|r| r.jisx0208_verbatim)
    }

    pub fn variant_getter<'a>(
        &'a self,
        variant: HyphensTransliterationVariant,
    ) -> impl Fn(&str) -> Option<&'static str> + 'a {
        use HyphensTransliterationVariant::*;
        let getter = match variant {
            Ascii => Self::get_ascii,
            Jisx0201 => Self::get_jisx0201,
            Jisx0208_90 => Self::get_jisx0208_90,
            Jisx0208_90Windows => Self::get_jisx0208_90_windows,
            Jisx0208Verbatim => Self::get_jisx0208_verbatim,
        };
        move |key: &str| getter(self, key)
    }
}

pub struct HyphensTransliterator<'c> {
    #[allow(clippy::type_complexity)]
    getters: Vec<Box<dyn Fn(&str) -> Option<&'static str> + 'c>>,
}

impl<'c> Transliterator for HyphensTransliterator<'c> {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        input: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mut result = Vec::new();
        let mut offset = 0;
        'outer: for char in input {
            if let Some(c) = char.c() {
                for getter in &self.getters {
                    if let Some(mapped) = getter(c) {
                        let nc = pool.new_char_from(Cow::Borrowed(mapped), offset, char);
                        offset += nc.c.len();
                        result.push(nc);
                        continue 'outer;
                    }
                }
            }
            let nc = pool.new_with_offset(char, offset);
            offset += nc.c.len();
            result.push(nc);
        }
        Ok(result)
    }
}

impl<'c> HyphensTransliterator<'c> {
    pub fn new(precedence: impl IntoIterator<Item = HyphensTransliterationVariant>) -> Self {
        Self {
            getters: precedence
                .into_iter()
                .map(|variant| {
                    Box::new(HyphensMappings::get().variant_getter(variant))
                        as Box<dyn Fn(&str) -> Option<&'static str> + 'c>
                })
                .collect(),
        }
    }
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct HyphensTransliteratorOptions {
    pub precedence: Vec<HyphensTransliterationVariant>,
}

impl TransliteratorFactory for HyphensTransliteratorOptions {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(HyphensTransliterator::new(
            self.precedence.iter().cloned(),
        )))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::char::CharPool;

    #[test]
    fn test_ascii_variant() {
        let transliterator = HyphensTransliterator::new([HyphensTransliterationVariant::Ascii]);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("—");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c(), Some("-"));
    }

    #[test]
    fn test_jisx0201_variant() {
        let transliterator = HyphensTransliterator::new([HyphensTransliterationVariant::Jisx0201]);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("－");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c(), Some("-"));
    }

    #[test]
    fn test_jisx0208_90_variant() {
        let transliterator =
            HyphensTransliterator::new([HyphensTransliterationVariant::Jisx0208_90]);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("－");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c(), Some("−"));
    }

    #[test]
    fn test_jisx0208_90_windows_variant() {
        let transliterator =
            HyphensTransliterator::new([HyphensTransliterationVariant::Jisx0208_90Windows]);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("－");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c(), Some("－"));
    }

    #[test]
    fn test_precedence_order() {
        let transliterator = HyphensTransliterator::new([
            HyphensTransliterationVariant::Ascii,
            HyphensTransliterationVariant::Jisx0208_90,
        ]);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("－");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c(), Some("-"));
    }

    #[test]
    fn test_no_mapping_leaves_unchanged() {
        let transliterator = HyphensTransliterator::new([HyphensTransliterationVariant::Ascii]);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("abc");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 4);
        assert_eq!(result[0].c(), Some("a"));
        assert_eq!(result[1].c(), Some("b"));
        assert_eq!(result[2].c(), Some("c"));
    }

    #[test]
    fn test_mixed_input() {
        let transliterator = HyphensTransliterator::new([HyphensTransliterationVariant::Ascii]);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("hello—world");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 12);
        assert_eq!(result[5].c(), Some("-"));
    }

    #[test]
    fn test_vertical_lines() {
        let transliterator =
            HyphensTransliterator::new([HyphensTransliterationVariant::Jisx0208_90]);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("｜");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c(), Some("｜"));
    }

    #[test]
    fn test_wave_dash() {
        let transliterator = HyphensTransliterator::new([HyphensTransliterationVariant::Ascii]);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("〜");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c(), Some("~"));
    }

    #[test]
    fn test_multiple_variants_fallback() {
        let transliterator = HyphensTransliterator::new([
            HyphensTransliterationVariant::Jisx0208Verbatim,
            HyphensTransliterationVariant::Ascii,
        ]);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("‒");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c(), Some("-"));
    }

    #[test]
    fn test_factory() {
        let options = HyphensTransliteratorOptions {
            precedence: vec![HyphensTransliterationVariant::Ascii],
        };
        let transliterator = options.new_transliterator().unwrap();
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("—");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 2);
        assert_eq!(result[0].c(), Some("-"));
    }
}
