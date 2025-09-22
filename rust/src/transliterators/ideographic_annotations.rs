use crate::char::{Char, CharPool};
use crate::transliterator::{
    TransliterationError, Transliterator, TransliteratorFactory, TransliteratorFactoryError,
};
use crate::transliterators::SimpleTransliterator;
static IDEOGRAPHICANNOTATIONS_MAPPINGS: phf::Map<&'static str, &'static str> = phf::phf_map! { "㆝" => "天" , "㆒" => "一" , "㆘" => "下" , "㆟" => "人" , "㆖" => "上" , "㆕" => "四" , "㆔" => "三" , "㆓" => "二" , "㆜" => "丁" , "㆞" => "地" , "㆙" => "甲" , "㆚" => "乙" , "㆗" => "中" , "㆛" => "丙" };
pub struct IdeographicAnnotationsTransliterator {
    inner: SimpleTransliterator,
}
impl IdeographicAnnotationsTransliterator {
    #[allow(clippy::new_without_default)]
    pub fn new() -> Self {
        Self {
            inner: SimpleTransliterator::new(&IDEOGRAPHICANNOTATIONS_MAPPINGS),
        }
    }
}
impl Transliterator for IdeographicAnnotationsTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        input: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        self.inner.transliterate(pool, input)
    }
}
pub struct IdeographicAnnotationsTransliteratorFactory;
impl IdeographicAnnotationsTransliteratorFactory {
    #[allow(clippy::new_without_default)]
    pub fn new() -> Self {
        Self
    }
}
impl TransliteratorFactory for IdeographicAnnotationsTransliteratorFactory {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(IdeographicAnnotationsTransliterator::new()))
    }
}
