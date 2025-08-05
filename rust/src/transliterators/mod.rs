use serde::{Deserialize, Serialize};

use super::transliterator::{Transliterator, TransliteratorFactory, TransliteratorFactoryError};

#[cfg(not(feature = "codegen"))]
mod circled_or_squared;
#[cfg(not(feature = "codegen"))]
mod combined;
mod hira_kata;
mod hira_kata_composition;
mod hira_kata_table;
#[cfg(not(feature = "codegen"))]
mod hyphens;
#[cfg(not(feature = "codegen"))]
mod ideographic_annotations;
#[cfg(not(feature = "codegen"))]
mod ivs_svs_base;
mod japanese_iteration_marks;
mod jisx0201_and_alike;
#[cfg(not(feature = "codegen"))]
mod kanji_old_new;
#[cfg(not(feature = "codegen"))]
mod mathematical_alphanumerics;
mod prolonged_sound_marks;
#[cfg(not(feature = "codegen"))]
mod radicals;
mod simple;
#[cfg(not(feature = "codegen"))]
mod spaces;

pub use hira_kata::{
    HiraKataTransliterator, HiraKataTransliteratorFactory, HiraKataTransliteratorOptions,
    Mode as HiraKataMode,
};
pub use hira_kata_composition::{
    HiraKataCompositionTransliterator, HiraKataCompositionTransliteratorOptions,
};
pub use japanese_iteration_marks::{
    JapaneseIterationMarksTransliterator, JapaneseIterationMarksTransliteratorOptions,
};
pub use jisx0201_and_alike::{
    Jisx0201AndAlikeFullwidthToHalfwidthTransliterator,
    Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorFactory,
    Jisx0201AndAlikeHalfwidthToFullwidthTransliterator,
    Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorFactory,
    Jisx0201AndAlikeTransliteratorOptions,
};
pub use prolonged_sound_marks::{
    ProlongedSoundMarksTransliterator, ProlongedSoundMarksTransliteratorOptions,
};
pub use simple::SimpleTransliterator;

#[cfg(not(feature = "codegen"))]
pub use circled_or_squared::{
    CircledOrSquaredTransliterator, CircledOrSquaredTransliteratorFactory,
    CircledOrSquaredTransliteratorOptions,
};
#[cfg(not(feature = "codegen"))]
pub use combined::{CombinedTransliterator, CombinedTransliteratorFactory};
#[cfg(not(feature = "codegen"))]
pub use hyphens::{
    HyphensTransliterationVariant, HyphensTransliterator, HyphensTransliteratorOptions,
};
#[cfg(not(feature = "codegen"))]
pub use ideographic_annotations::{
    IdeographicAnnotationsTransliterator, IdeographicAnnotationsTransliteratorFactory,
};
#[cfg(not(feature = "codegen"))]
pub use ivs_svs_base::{IvsSvsBaseMode, IvsSvsBaseTransliterator, IvsSvsBaseTransliteratorOptions};
#[cfg(not(feature = "codegen"))]
pub use kanji_old_new::{KanjiOldNewTransliterator, KanjiOldNewTransliteratorFactory};
#[cfg(not(feature = "codegen"))]
pub use mathematical_alphanumerics::{
    MathematicalAlphanumericsTransliterator, MathematicalAlphanumericsTransliteratorFactory,
};
#[cfg(not(feature = "codegen"))]
pub use radicals::{RadicalsTransliterator, RadicalsTransliteratorFactory};
#[cfg(not(feature = "codegen"))]
pub use spaces::{SpacesTransliterator, SpacesTransliteratorFactory};

#[derive(Debug, Default, Clone, Copy, PartialEq, Deserialize, Serialize)]
pub enum Charset {
    #[serde(rename = "unijis_90")]
    Unijis90,
    #[default]
    #[serde(rename = "unijis_2004")]
    Unijis2004,
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub enum TransliteratorConfig {
    #[serde(rename = "hira-kata")]
    HiraKata(HiraKataTransliteratorOptions),
    #[serde(rename = "hira-kata-composition")]
    HiraKataComposition(HiraKataCompositionTransliteratorOptions),
    #[serde(rename = "japanese-iteration-marks")]
    JapaneseIterationMarks(JapaneseIterationMarksTransliteratorOptions),
    #[serde(rename = "jisx0201-and-alike")]
    Jisx0201AndAlike {
        fullwidth_to_halfwidth: bool,
        #[serde(flatten)]
        options: Jisx0201AndAlikeTransliteratorOptions,
    },
    #[serde(rename = "prolonged-sound-marks")]
    ProlongedSoundMarks(ProlongedSoundMarksTransliteratorOptions),
    #[cfg(not(feature = "codegen"))]
    #[serde(rename = "hyphens")]
    Hyphens(HyphensTransliteratorOptions),
    #[cfg(not(feature = "codegen"))]
    #[serde(rename = "ideographic-annotations")]
    IdeographicAnnotations,
    #[cfg(not(feature = "codegen"))]
    #[serde(rename = "ivs-svs-base")]
    IvsSvsBase(IvsSvsBaseTransliteratorOptions),
    #[cfg(not(feature = "codegen"))]
    #[serde(rename = "kanji-old-new")]
    KanjiOldNew,
    #[cfg(not(feature = "codegen"))]
    #[serde(rename = "mathematical-alphanumerics")]
    MathematicalAlphanumerics,
    #[cfg(not(feature = "codegen"))]
    #[serde(rename = "radicals")]
    Radicals,
    #[cfg(not(feature = "codegen"))]
    #[serde(rename = "spaces")]
    Spaces,
    #[cfg(not(feature = "codegen"))]
    #[serde(rename = "combined")]
    Combined,
    #[cfg(not(feature = "codegen"))]
    #[serde(rename = "circled-or-squared")]
    CircledOrSquared(crate::transliterators::CircledOrSquaredTransliteratorOptions),
}

impl TransliteratorFactory for TransliteratorConfig {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        use TransliteratorConfig::*;

        match self {
            HiraKata(options) => options.new_transliterator(),
            HiraKataComposition(options) => options.new_transliterator(),
            JapaneseIterationMarks(options) => options.new_transliterator(),
            Jisx0201AndAlike {
                fullwidth_to_halfwidth,
                options,
            } => {
                if *fullwidth_to_halfwidth {
                    Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorFactory(options.into())
                        .new_transliterator()
                } else {
                    Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorFactory(options.into())
                        .new_transliterator()
                }
            }
            ProlongedSoundMarks(options) => options.new_transliterator(),
            #[cfg(not(feature = "codegen"))]
            Hyphens(options) => options.new_transliterator(),
            #[cfg(not(feature = "codegen"))]
            IdeographicAnnotations => {
                IdeographicAnnotationsTransliteratorFactory::new().new_transliterator()
            }
            #[cfg(not(feature = "codegen"))]
            IvsSvsBase(options) => options.new_transliterator(),
            #[cfg(not(feature = "codegen"))]
            KanjiOldNew => KanjiOldNewTransliteratorFactory::new().new_transliterator(),
            #[cfg(not(feature = "codegen"))]
            MathematicalAlphanumerics => {
                MathematicalAlphanumericsTransliteratorFactory::new().new_transliterator()
            }
            #[cfg(not(feature = "codegen"))]
            Radicals => RadicalsTransliteratorFactory::new().new_transliterator(),
            #[cfg(not(feature = "codegen"))]
            Spaces => SpacesTransliteratorFactory::new().new_transliterator(),
            #[cfg(not(feature = "codegen"))]
            Combined => CombinedTransliteratorFactory::new().new_transliterator(),
            #[cfg(not(feature = "codegen"))]
            CircledOrSquared(options) => {
                crate::transliterators::CircledOrSquaredTransliteratorFactory::new(options.clone())
                    .new_transliterator()
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{
        HiraKataCompositionTransliteratorOptions, JapaneseIterationMarksTransliteratorOptions,
        Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorFactory,
        Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorFactory,
        Jisx0201AndAlikeTransliteratorOptions, ProlongedSoundMarksTransliteratorOptions,
    };
    use crate::char::CharPool;
    use crate::transliterator::{Transliterator, TransliteratorFactory};

    #[test]
    fn test_all_manual_transliterators_handle_sentinels() {
        let transliterators: Vec<Box<dyn Transliterator>> = vec![
            HiraKataCompositionTransliteratorOptions::default()
                .new_transliterator()
                .unwrap(),
            JapaneseIterationMarksTransliteratorOptions::default()
                .new_transliterator()
                .unwrap(),
            Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorFactory(
                Jisx0201AndAlikeTransliteratorOptions::default().into(),
            )
            .new_transliterator()
            .unwrap(),
            Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorFactory(
                Jisx0201AndAlikeTransliteratorOptions::default().into(),
            )
            .new_transliterator()
            .unwrap(),
            ProlongedSoundMarksTransliteratorOptions::default()
                .new_transliterator()
                .unwrap(),
        ];

        for transliterator in transliterators {
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
    }

    #[test]
    fn test_all_manual_transliterators_handle_empty_input() {
        let transliterators: Vec<Box<dyn Transliterator>> = vec![
            HiraKataCompositionTransliteratorOptions::default()
                .new_transliterator()
                .unwrap(),
            JapaneseIterationMarksTransliteratorOptions::default()
                .new_transliterator()
                .unwrap(),
            Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorFactory(
                (&Jisx0201AndAlikeTransliteratorOptions::default()).into(),
            )
            .new_transliterator()
            .unwrap(),
            Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorFactory(
                (&Jisx0201AndAlikeTransliteratorOptions::default()).into(),
            )
            .new_transliterator()
            .unwrap(),
            ProlongedSoundMarksTransliteratorOptions::default()
                .new_transliterator()
                .unwrap(),
        ];

        for transliterator in transliterators {
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
    }
}
