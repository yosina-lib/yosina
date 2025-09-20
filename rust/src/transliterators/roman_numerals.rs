use crate::char::{Char, CharPool};
use crate::transliterator::{
    TransliterationError, Transliterator, TransliteratorFactory, TransliteratorFactoryError,
};
use crate::transliterators::SimpleTransliterator;

static ROMAN_NUMERALS_MAPPINGS: phf::Map<&'static str, &'static str> = phf::phf_map! {
    "Ⅰ" => "I",
    "Ⅱ" => "II",
    "Ⅲ" => "III",
    "Ⅳ" => "IV",
    "Ⅴ" => "V",
    "Ⅵ" => "VI",
    "Ⅶ" => "VII",
    "Ⅷ" => "VIII",
    "Ⅸ" => "IX",
    "Ⅹ" => "X",
    "Ⅺ" => "XI",
    "Ⅻ" => "XII",
    "Ⅼ" => "L",
    "Ⅽ" => "C",
    "Ⅾ" => "D",
    "Ⅿ" => "M",
    "ⅰ" => "i",
    "ⅱ" => "ii",
    "ⅲ" => "iii",
    "ⅳ" => "iv",
    "ⅴ" => "v",
    "ⅵ" => "vi",
    "ⅶ" => "vii",
    "ⅷ" => "viii",
    "ⅸ" => "ix",
    "ⅹ" => "x",
    "ⅺ" => "xi",
    "ⅻ" => "xii",
    "ⅼ" => "l",
    "ⅽ" => "c",
    "ⅾ" => "d",
    "ⅿ" => "m",
};

pub struct RomanNumeralsTransliterator {
    inner: SimpleTransliterator,
}

impl RomanNumeralsTransliterator {
    #[allow(clippy::new_without_default)]
    pub fn new() -> Self {
        Self {
            inner: SimpleTransliterator::new(&ROMAN_NUMERALS_MAPPINGS),
        }
    }
}

impl Transliterator for RomanNumeralsTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        input: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        self.inner.transliterate(pool, input)
    }
}

pub struct RomanNumeralsTransliteratorFactory;

impl RomanNumeralsTransliteratorFactory {
    #[allow(clippy::new_without_default)]
    pub fn new() -> Self {
        Self
    }
}

impl TransliteratorFactory for RomanNumeralsTransliteratorFactory {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(RomanNumeralsTransliterator::new()))
    }
}
