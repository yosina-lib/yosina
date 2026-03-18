use crate::char::{Char, CharPool};
use crate::transliterator::{
    TransliterationError, Transliterator, TransliteratorFactory, TransliteratorFactoryError,
};
use crate::transliterators::SimpleTransliterator;
static SMALLHIRAKATAS_MAPPINGS: phf::Map<&'static str, &'static str> = phf::phf_map! { "ㇶ" => "ヒ" , "ㇱ" => "シ" , "𛅥" => "ヱ" , "ェ" => "エ" , "𛅒" => "を" , "ｪ" => "ｴ" , "ㇿ" => "ロ" , "ぇ" => "え" , "ㇼ" => "リ" , "ㇳ" => "ト" , "ァ" => "ア" , "ぃ" => "い" , "ㇻ" => "ラ" , "ャ" => "ヤ" , "ㇸ" => "ヘ" , "𛅐" => "ゐ" , "ヵ" => "カ" , "っ" => "つ" , "ㇽ" => "ル" , "ｭ" => "ﾕ" , "ゃ" => "や" , "ヮ" => "ワ" , "ㇴ" => "ヌ" , "ゎ" => "わ" , "ぅ" => "う" , "ォ" => "オ" , "𛅑" => "ゑ" , "𛅕" => "コ" , "ゕ" => "か" , "𛅤" => "ヰ" , "ｧ" => "ｱ" , "ぉ" => "お" , "ｫ" => "ｵ" , "ヶ" => "ケ" , "ュ" => "ユ" , "𛅧" => "ン" , "ｩ" => "ｳ" , "ョ" => "ヨ" , "ｨ" => "ｲ" , "ィ" => "イ" , "ょ" => "よ" , "ゖ" => "け" , "ㇺ" => "ム" , "ㇷ" => "フ" , "ㇲ" => "ス" , "𛅦" => "ヲ" , "ㇰ" => "ク" , "ㇾ" => "レ" , "ぁ" => "あ" , "ゥ" => "ウ" , "ッ" => "ツ" , "ｬ" => "ﾔ" , "ｯ" => "ﾂ" , "ｮ" => "ﾖ" , "ゅ" => "ゆ" , "ㇵ" => "ハ" , "𛄲" => "こ" , "ㇹ" => "ホ" };
pub struct SmallHirakatasTransliterator {
    inner: SimpleTransliterator,
}
impl SmallHirakatasTransliterator {
    #[allow(clippy::new_without_default)]
    pub fn new() -> Self {
        Self {
            inner: SimpleTransliterator::new(&SMALLHIRAKATAS_MAPPINGS),
        }
    }
}
impl Transliterator for SmallHirakatasTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        input: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        self.inner.transliterate(pool, input)
    }
}
pub struct SmallHirakatasTransliteratorFactory;
impl SmallHirakatasTransliteratorFactory {
    #[allow(clippy::new_without_default)]
    pub fn new() -> Self {
        Self
    }
}
impl TransliteratorFactory for SmallHirakatasTransliteratorFactory {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(SmallHirakatasTransliterator::new()))
    }
}
