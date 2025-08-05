use crate::char::{Char, CharPool};
use crate::transliterator::{
    TransliterationError, Transliterator, TransliteratorFactory, TransliteratorFactoryError,
};
use crate::transliterators::SimpleTransliterator;
static SPACES_MAPPINGS: phf::Map<&'static str, &'static str> = phf::phf_map! { "\u{205f}" => " " , "\u{200b}" => " " , "\u{a0}" => " " , "\u{2000}" => " " , "\u{2006}" => " " , "\u{3000}" => " " , "\u{2008}" => " " , "\u{2007}" => " " , "\u{2009}" => " " , "\u{2003}" => " " , "ㅤ" => " " , "\u{2001}" => " " , "\u{2002}" => " " , "\u{2004}" => " " , "\u{180e}" => "" , "\u{2005}" => " " , "\u{200a}" => " " , "ﾠ" => " " , "\u{202f}" => " " , "\u{feff}" => "" };
pub struct SpacesTransliterator {
    inner: SimpleTransliterator,
}
impl SpacesTransliterator {
    #[allow(clippy::new_without_default)]
    pub fn new() -> Self {
        Self {
            inner: SimpleTransliterator::new(&SPACES_MAPPINGS),
        }
    }
}
impl Transliterator for SpacesTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        input: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        self.inner.transliterate(pool, input)
    }
}
pub struct SpacesTransliteratorFactory;
impl SpacesTransliteratorFactory {
    #[allow(clippy::new_without_default)]
    pub fn new() -> Self {
        Self
    }
}
impl TransliteratorFactory for SpacesTransliteratorFactory {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(SpacesTransliterator::new()))
    }
}
