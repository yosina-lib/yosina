use itertools::Itertools as _;
use serde::{Deserialize, Serialize};

use crate::config::TransliteratorConfigBuilder;
use crate::transliterator::TransliteratorFactoryError;
use crate::transliterators::{
    Charset, HyphensTransliterationVariant, IvsSvsBaseMode, IvsSvsBaseTransliteratorOptions,
    TransliteratorConfig,
};

#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub enum ToFullWidthOptions {
    #[default]
    No,
    Yes {
        u005c_as_yen_sign: bool,
    },
}

#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub enum ToHalfwidthOptions {
    #[default]
    No,
    Yes {
        hankaku_kana: bool,
    },
}

#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub enum RemoveIVSSVSOptions {
    #[default]
    No,
    Yes {
        drop_all_selectors: bool,
    },
}

#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub enum ReplaceCircledOrSquaredCharactersOptions {
    #[default]
    No,
    Yes {
        exclude_emojis: bool,
    },
}

#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub enum ReplaceHyphensOptions {
    #[default]
    No,
    Yes {
        precedence: Vec<HyphensTransliterationVariant>,
    },
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct TransliteratorRecipe {
    /// Replace codepoints that correspond to old-style kanji glyphs (旧字体; kyu-ji-tai) with their modern equivalents (新字体; shin-ji-tai).
    ///
    /// # Example
    /// ```text
    /// Input:  "舊字體の變換"
    /// Output: "旧字体の変換"
    /// ```
    #[serde(default)]
    pub kanji_old_new: bool,
    /// Replace "suspicious" hyphens with prolonged sound marks, and vice versa.
    ///
    /// # Example
    /// ```text
    /// Input:  "スーパ-" (with hyphen-minus)
    /// Output: "スーパー" (becomes prolonged sound mark)
    /// ```
    #[serde(default)]
    pub replace_suspicious_hyphens_to_prolonged_sound_marks: bool,
    /// Replace combined characters with their corresponding characters.
    ///
    /// # Example
    /// ```text
    /// Input:  "㍻" (single character for Heisei era)
    /// Output: "平成"
    /// ```
    /// ```text
    /// Input:  "㈱"
    /// Output: "(株)"
    /// ```
    #[serde(default)]
    pub replace_combined_characters: bool,
    /// Replace circled or squared characters with their corresponding templates.
    ///
    /// # Example
    /// ```text
    /// Input:  "①②③"
    /// Output: "(1)(2)(3)"
    /// ```
    /// ```text
    /// Input:  "㊙㊗"
    /// Output: "(秘)(祝)"
    /// ```
    #[serde(default)]
    pub replace_circled_or_squared_characters: ReplaceCircledOrSquaredCharactersOptions,
    /// Replace ideographic annotations used in the traditional method of Chinese-to-Japanese translation deviced in the ancient Japan.
    ///
    /// # Example
    /// ```text
    /// Input:  "㆖㆘" (ideographic annotations)
    /// Output: "上下"
    /// ```
    #[serde(default)]
    pub replace_ideographic_annotations: bool,
    /// Replace codepoints for the Kang Xi radicals whose glyphs resemble those of CJK ideographs with the CJK ideograph counterparts.
    ///
    /// # Example
    /// ```text
    /// Input:  "⾔⾨⾷" (Kangxi radicals)
    /// Output: "言門食" (CJK ideographs)
    /// ```
    #[serde(default)]
    pub replace_radicals: bool,
    /// Replace various space characters with plain whitespaces or empty strings.
    ///
    /// # Example
    /// ```text
    /// Input:  "A　B" (ideographic space U+3000)
    /// Output: "A B" (half-width space)
    /// ```
    /// ```text
    /// Input:  "A B" (non-breaking space U+00A0)
    /// Output: "A B" (regular space)
    /// ```
    #[serde(default)]
    pub replace_spaces: bool,
    /// Replace various dash or hyphen symbols with those common in Japanese writing.
    ///
    /// # Example
    /// ```text
    /// Input:  "2019—2020" (em dash)
    /// Output: "2019-2020" (hyphen-minus)
    /// ```
    /// ```text
    /// Input:  "A–B" (en dash)
    /// Output: "A-B"
    /// ```
    #[serde(default)]
    pub replace_hyphens: ReplaceHyphensOptions,
    /// Replace mathematical alphanumerics with their plain ASCII equivalents.
    ///
    /// # Example
    /// ```text
    /// Input:  "𝐀𝐁𝐂" (mathematical bold)
    /// Output: "ABC"
    /// ```
    /// ```text
    /// Input:  "𝟏𝟐𝟑" (mathematical bold digits)
    /// Output: "123"
    /// ```
    pub replace_mathematical_alphanumerics: bool,
    /// Combine decomposed hiraganas and katakanas into single counterparts.
    ///
    /// # Example
    /// ```text
    /// Input:  "が" (か + ゙)
    /// Output: "が" (single character)
    /// ```
    /// ```text
    /// Input:  "ペ" (ヘ + ゚)
    /// Output: "ペ" (single character)
    /// ```
    #[serde(default)]
    pub combine_decomposed_hiraganas_and_katakanas: bool,
    /// Replace half-width characters in that they are marked as half-width or ambiguous in the East Asian Width table to the fullwidth equivalents.
    /// Specify `"u005c-as-yen-sign"` instead of a bool to treat the backslash character (U+005C) as the yen sign in JIS X 0201.
    ///
    /// # Example
    /// ```text
    /// Input:  "ABC123"
    /// Output: "ＡＢＣ１２３"
    /// ```
    /// ```text
    /// Input:  "ｶﾀｶﾅ"
    /// Output: "カタカナ"
    /// ```
    #[serde(default)]
    pub to_fullwidth: ToFullWidthOptions,
    /// Replace full-width characters with their half-width equivalents.
    /// Specify `"hankaku-kana"` instead of a bool to handle half-width katakanas too.
    ///
    /// # Example
    /// ```text
    /// Input:  "ＡＢＣ１２３"
    /// Output: "ABC123"
    /// ```
    /// ```text
    /// Input:  "カタカナ" (with hankaku-kana)
    /// Output: "ｶﾀｶﾅ"
    /// ```
    #[serde(default)]
    pub to_halfwidth: ToHalfwidthOptions,
    /// Replace CJK ideographs followed by IVSes and SVSes with those without selectors based on Adobe-Japan1 character mappings.
    /// Specify `Yes { drop_all_selectors: true }` to get rid of all selectors from the result.
    ///
    /// # Example
    /// ```text
    /// Input:  "葛󠄀" (葛 + IVS U+E0100)
    /// Output: "葛" (without selector)
    /// ```
    /// ```text
    /// Input:  "辻󠄀" (辻 + IVS)
    /// Output: "辻"
    /// ```
    #[serde(default)]
    pub remove_ivs_svs: RemoveIVSSVSOptions,
    /// Assumed charset for IVS/SVS base transliterator
    #[serde(default)]
    pub charset: Charset,
}

#[derive(thiserror::Error, Debug)]
pub enum TransliterationRecipeError {
    #[error("kanji_old_new: {}", .0.join(", "))]
    KanjiOldNewError(Vec<String>),
    #[error("replace_suspicious_hyphens_to_prolonged_sound_marks: {}", .0.join(", "))]
    ReplaceSuspiciousHyphensError(Vec<String>),
    #[error("replace_combined_characters: {}", .0.join(", "))]
    ReplaceCombinedCharactersError(Vec<String>),
    #[error("replace_circled_or_squared_characters: {}", .0.join(", "))]
    ReplaceCircledOrSquaredCharactersError(Vec<String>),
    #[error("replace_ideographic_annotations: {}", .0.join(", "))]
    ReplaceIdeographicAnnotationsError(Vec<String>),
    #[error("replace_radicals: {}", .0.join(", "))]
    ReplaceRadicalsError(Vec<String>),
    #[error("replace_spaces: {}", .0.join(", "))]
    ReplaceSpacesError(Vec<String>),
    #[error("replace_hyphens: {}", .0.join(", "))]
    ReplaceHyphensError(Vec<String>),
    #[error("replace_mathematical_alphanumerics: {}", .0.join(", "))]
    ReplaceMathematicalAlphanumericsError(Vec<String>),
    #[error("combine_decomposed_hiraganas_and_katakanas: {}", .0.join(", "))]
    CombineDecomposedHiraganasAndKatakanasError(Vec<String>),
    #[error("to_fullwidth: {}", .0.join(", "))]
    ToFullwidthError(Vec<String>),
    #[error("to_halfwidth: {}", .0.join(", "))]
    ToHalfwidthError(Vec<String>),
    #[error("remove_ivs_svs: {}", .0.join(", "))]
    RemoveIVSSVSError(Vec<String>),
}

impl TransliteratorRecipe {
    fn remove_ivs_svs_helper(
        &self,
        mut builder: TransliteratorConfigBuilder,
        drop_selectors_altogether: bool,
    ) -> TransliteratorConfigBuilder {
        // First insert "ivs-or-svs" mode at head
        builder = builder.insert_head(
            TransliteratorConfig::IvsSvsBase(IvsSvsBaseTransliteratorOptions {
                mode: IvsSvsBaseMode::IvsOrSvs(false),
                charset: self.charset,
                ..Default::default()
            }),
            true,
        );

        // Then insert "base" mode at tail
        builder.insert_tail(
            TransliteratorConfig::IvsSvsBase(IvsSvsBaseTransliteratorOptions {
                mode: IvsSvsBaseMode::Base,
                charset: self.charset,
                drop_selectors_altogether,
            }),
            true,
        )
    }

    fn apply_kanji_old_new(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if self.kanji_old_new {
            builder = self.remove_ivs_svs_helper(builder, false);
            builder = builder.insert_middle(TransliteratorConfig::KanjiOldNew, false);
        }
        (builder, None)
    }

    fn apply_replace_suspicious_hyphens_to_prolonged_sound_marks(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if self.replace_suspicious_hyphens_to_prolonged_sound_marks {
            builder = builder.insert_middle(
                TransliteratorConfig::ProlongedSoundMarks(
                    crate::transliterators::ProlongedSoundMarksTransliteratorOptions {
                        replace_prolonged_marks_following_alnums: true,
                        ..Default::default()
                    },
                ),
                false,
            );
        }
        (builder, None)
    }

    fn apply_replace_ideographic_annotations(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if self.replace_ideographic_annotations {
            builder = builder.insert_middle(TransliteratorConfig::IdeographicAnnotations, false);
        }
        (builder, None)
    }

    fn apply_replace_radicals(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if self.replace_radicals {
            builder = builder.insert_middle(TransliteratorConfig::Radicals, false);
        }
        (builder, None)
    }

    fn apply_replace_spaces(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if self.replace_spaces {
            builder = builder.insert_middle(TransliteratorConfig::Spaces, false);
        }
        (builder, None)
    }

    fn apply_replace_hyphens(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if let ReplaceHyphensOptions::Yes { precedence } = &self.replace_hyphens {
            let precedence = if precedence.is_empty() {
                vec![
                    HyphensTransliterationVariant::Jisx0208_90Windows,
                    HyphensTransliterationVariant::Jisx0201,
                ]
            } else {
                precedence.clone()
            };
            builder = builder.insert_middle(
                TransliteratorConfig::Hyphens(
                    crate::transliterators::HyphensTransliteratorOptions { precedence },
                ),
                false,
            );
        }
        (builder, None)
    }

    fn apply_replace_mathematical_alphanumerics(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if self.replace_mathematical_alphanumerics {
            builder = builder.insert_middle(TransliteratorConfig::MathematicalAlphanumerics, false);
        }
        (builder, None)
    }

    fn apply_combine_decomposed_hiraganas_and_katakanas(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if self.combine_decomposed_hiraganas_and_katakanas {
            builder = builder.insert_head(
                TransliteratorConfig::HiraKataComposition(
                    crate::transliterators::HiraKataCompositionTransliteratorOptions {
                        compose_non_combining_marks: true,
                    },
                ),
                false,
            );
        }
        (builder, None)
    }

    fn apply_to_fullwidth(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if let ToFullWidthOptions::Yes { u005c_as_yen_sign } = self.to_fullwidth {
            if self.to_halfwidth != ToHalfwidthOptions::No {
                return (
                    builder,
                    Some(TransliterationRecipeError::ToFullwidthError(vec![
                        "to_fullwidth and to_halfwidth are mutually exclusive".to_string(),
                    ])),
                );
            }

            builder = builder.insert_tail(
                TransliteratorConfig::Jisx0201AndAlikeHalfwidthToFullwidth(
                    crate::transliterators::Jisx0201AndAlikeTransliteratorOptions {
                        u005c_as_yen_sign,
                        ..Default::default()
                    },
                ),
                false,
            );
        }
        (builder, None)
    }

    fn apply_to_halfwidth(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if let ToHalfwidthOptions::Yes { hankaku_kana } = self.to_halfwidth {
            if self.to_fullwidth != ToFullWidthOptions::No {
                return (
                    builder,
                    Some(TransliterationRecipeError::ToHalfwidthError(vec![
                        "to_halfwidth and to_fullwidth are mutually exclusive".to_string(),
                    ])),
                );
            }

            builder = builder.insert_tail(
                TransliteratorConfig::Jisx0201AndAlikeFullwidthToHalfwidth(
                    crate::transliterators::Jisx0201AndAlikeTransliteratorOptions {
                        convert_gl: true,
                        convert_gr: hankaku_kana,
                        ..Default::default()
                    },
                ),
                false,
            );
        }
        (builder, None)
    }

    fn apply_remove_ivs_svs(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if let RemoveIVSSVSOptions::Yes { drop_all_selectors } = self.remove_ivs_svs {
            builder = self.remove_ivs_svs_helper(builder, drop_all_selectors);
        }
        (builder, None)
    }

    fn apply_replace_combined_characters(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if self.replace_combined_characters {
            builder = builder.insert_middle(TransliteratorConfig::Combined, false);
        }
        (builder, None)
    }

    fn apply_replace_circled_or_squared_characters(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if let ReplaceCircledOrSquaredCharactersOptions::Yes { exclude_emojis } =
            self.replace_circled_or_squared_characters
        {
            builder = builder.insert_middle(
                TransliteratorConfig::CircledOrSquared(
                    crate::transliterators::CircledOrSquaredTransliteratorOptions {
                        include_emojis: !exclude_emojis,
                    },
                ),
                false,
            );
        }
        (builder, None)
    }

    /// Build transliterator configs from a recipe
    pub fn build(&self) -> Result<Vec<TransliteratorConfig>, TransliteratorFactoryError> {
        // Check for mutually exclusive options
        let builder = TransliteratorConfigBuilder::new();
        let mut errors = Vec::<TransliterationRecipeError>::new();
        // Apply transliterators in the specified order
        // 1. kanjiOldNew
        let (builder, e) = self.apply_kanji_old_new(builder);
        if let Some(e) = e {
            errors.push(e)
        }

        // 2. replaceSuspiciousHyphensToProlongedSoundMarks
        let (builder, e) = self.apply_replace_suspicious_hyphens_to_prolonged_sound_marks(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 3. replaceCircledOrSquaredCharacters
        let (builder, e) = self.apply_replace_circled_or_squared_characters(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 4. replaceCombinedCharacters
        let (builder, e) = self.apply_replace_combined_characters(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 5. replaceIdeographicAnnotations
        let (builder, e) = self.apply_replace_ideographic_annotations(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 6. replaceRadicals
        let (builder, e) = self.apply_replace_radicals(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 7. replaceSpaces
        let (builder, e) = self.apply_replace_spaces(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 8. replaceHyphens
        let (builder, e) = self.apply_replace_hyphens(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 9. replaceMathematicalAlphanumerics
        let (builder, e) = self.apply_replace_mathematical_alphanumerics(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 10. combineDecomposedHiraganasAndKatakanas
        let (builder, e) = self.apply_combine_decomposed_hiraganas_and_katakanas(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 11. toFullwidth
        let (builder, e) = self.apply_to_fullwidth(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 12. toHalfwidth
        let (builder, e) = self.apply_to_halfwidth(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 13. removeIVSSVS
        let (builder, e) = self.apply_remove_ivs_svs(builder);
        if let Some(e) = e {
            errors.push(e);
        }
        if !errors.is_empty() {
            return Err(TransliteratorFactoryError::new(
                errors.iter().map(|e| e.to_string()).join("; "),
            ));
        }
        Ok(builder.build())
    }
}

impl Default for TransliteratorRecipe {
    fn default() -> Self {
        Self {
            kanji_old_new: false,
            replace_suspicious_hyphens_to_prolonged_sound_marks: false,
            replace_combined_characters: false,
            replace_circled_or_squared_characters: ReplaceCircledOrSquaredCharactersOptions::No,
            replace_ideographic_annotations: false,
            replace_radicals: false,
            replace_spaces: false,
            replace_hyphens: ReplaceHyphensOptions::No,
            replace_mathematical_alphanumerics: false,
            combine_decomposed_hiraganas_and_katakanas: false,
            to_fullwidth: ToFullWidthOptions::No,
            to_halfwidth: ToHalfwidthOptions::No,
            remove_ivs_svs: RemoveIVSSVSOptions::No,
            charset: Charset::Unijis2004,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_recipe_build_basic() {
        let recipe = TransliteratorRecipe {
            kanji_old_new: true,
            replace_spaces: true,
            ..Default::default()
        };

        let result = recipe.build();
        assert!(result.is_ok(), "Recipe build should succeed");

        let configs = result.unwrap();
        assert!(!configs.is_empty(), "Should have at least one config");
    }

    #[test]
    fn test_mutual_exclusion() {
        let recipe = TransliteratorRecipe {
            to_fullwidth: ToFullWidthOptions::Yes {
                u005c_as_yen_sign: false,
            },
            to_halfwidth: ToHalfwidthOptions::Yes {
                hankaku_kana: false,
            },
            ..Default::default()
        };

        let result = recipe.build();
        assert!(
            result.is_err(),
            "Should error on mutually exclusive options"
        );
    }
}
