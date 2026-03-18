use itertools::Itertools as _;
use serde::{Deserialize, Serialize};

use crate::transliterator::{Transliterator, TransliteratorFactory, TransliteratorFactoryError};
use crate::transliterators::{
    Charset, HistoricalHiraganaMode, HistoricalHirakatasTransliteratorOptions,
    HistoricalKatakanaMode, HyphensTransliterationVariant, IvsSvsBaseMode,
    IvsSvsBaseTransliteratorOptions, TransliteratorConfig, VoicedHistoricalKanaMode,
};

#[derive(Debug, Clone, PartialEq)]
pub(crate) struct TransliteratorConfigBuilder {
    head: Vec<TransliteratorConfig>,
    tail: Vec<TransliteratorConfig>,
}

impl TransliteratorConfigBuilder {
    pub fn new() -> Self {
        TransliteratorConfigBuilder {
            head: Vec::new(),
            tail: Vec::new(),
        }
    }

    pub fn find_in_head(&self, config: &TransliteratorConfig) -> Option<usize> {
        self.head
            .iter()
            .position(|c| std::mem::discriminant(c) == std::mem::discriminant(config))
    }

    pub fn find_in_tail(&self, config: &TransliteratorConfig) -> Option<usize> {
        self.tail
            .iter()
            .position(|c| std::mem::discriminant(c) == std::mem::discriminant(config))
    }

    pub fn insert_head(&self, config: TransliteratorConfig, force_replace: bool) -> Self {
        if let Some(i) = self.find_in_head(&config) {
            if force_replace {
                let mut new_head = self.head.clone();
                new_head[i] = config;
                TransliteratorConfigBuilder {
                    head: new_head,
                    tail: self.tail.clone(),
                }
            } else {
                self.clone()
            }
        } else {
            let mut new_head = self.head.clone();
            new_head.insert(0, config);
            TransliteratorConfigBuilder {
                head: new_head,
                tail: self.tail.clone(),
            }
        }
    }

    pub fn insert_middle(&self, config: TransliteratorConfig, force_replace: bool) -> Self {
        if let Some(i) = self.find_in_tail(&config) {
            if force_replace {
                let mut new_tail = self.tail.clone();
                new_tail[i] = config;
                TransliteratorConfigBuilder {
                    head: self.head.clone(),
                    tail: new_tail,
                }
            } else {
                self.clone()
            }
        } else {
            let mut new_tail = self.tail.clone();
            new_tail.insert(0, config);
            TransliteratorConfigBuilder {
                head: self.head.clone(),
                tail: new_tail,
            }
        }
    }

    pub fn insert_tail(&self, config: TransliteratorConfig, force_replace: bool) -> Self {
        if let Some(i) = self.find_in_tail(&config) {
            if force_replace {
                let mut new_tail = self.tail.clone();
                new_tail[i] = config;
                TransliteratorConfigBuilder {
                    head: self.head.clone(),
                    tail: new_tail,
                }
            } else {
                self.clone()
            }
        } else {
            let mut new_tail = self.tail.clone();
            new_tail.push(config);
            TransliteratorConfigBuilder {
                head: self.head.clone(),
                tail: new_tail,
            }
        }
    }

    pub fn build(self) -> Vec<TransliteratorConfig> {
        let mut configs = self.head;
        configs.extend(self.tail);
        configs
    }
}

impl Default for TransliteratorConfigBuilder {
    fn default() -> Self {
        Self::new()
    }
}

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

#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ReplaceHistoricalHirakatasMode {
    Simple,
    Decompose,
}

#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub enum HiraKataOptions {
    #[default]
    No,
    #[serde(rename = "hira-to-kata")]
    HiraToKata,
    #[serde(rename = "kata-to-hira")]
    KataToHira,
}

#[derive(Debug, Clone, Deserialize, Serialize)]
pub struct TransliterationRecipe {
    /// Replace codepoints that correspond to old-style kanji glyphs (旧字体; kyu-ji-tai) with their modern equivalents (新字体; shin-ji-tai).
    ///
    /// # Example
    /// ```text
    /// Input:  "舊字體の變換"
    /// Output: "旧字体の変換"
    /// ```
    #[serde(default)]
    pub kanji_old_new: bool,
    /// Convert between hiragana and katakana scripts.
    ///
    /// # Example
    /// ```text
    /// Input:  "ひらがな" (with HiraToKata)
    /// Output: "ヒラガナ"
    /// ```
    /// ```text
    /// Input:  "カタカナ" (with KataToHira)
    /// Output: "かたかな"
    /// ```
    #[serde(default)]
    pub hira_kata: HiraKataOptions,
    /// Replace Japanese iteration marks with the characters they represent.
    ///
    /// # Example
    /// ```text
    /// Input:  "時々"
    /// Output: "時時"
    /// ```
    /// ```text
    /// Input:  "いすゞ"
    /// Output: "いすず"
    /// ```
    #[serde(default)]
    pub replace_japanese_iteration_marks: bool,
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
    /// Replace Roman numeral characters with their ASCII equivalents.
    ///
    /// # Example
    /// ```text
    /// Input:  "Chapter Ⅻ"
    /// Output: "Chapter XII"
    /// ```
    /// ```text
    /// Input:  "section ⅲ"
    /// Output: "section iii"
    /// ```
    #[serde(default)]
    pub replace_roman_numerals: bool,
    /// Replaces archaic kana (hentaigana) with their modern equivalents.
    #[serde(default)]
    pub replace_archaic_hirakatas: bool,
    /// Replaces small hiragana/katakana with their ordinary-sized equivalents.
    #[serde(default)]
    pub replace_small_hirakatas: bool,
    /// Replaces historical hiragana/katakana characters with their modern equivalents.
    ///
    /// # Example
    /// ```text
    /// Input:  "ゐゑヰヱ"
    /// Output: "いえイエ" (with Simple mode)
    /// ```
    #[serde(default)]
    pub replace_historical_hirakatas: Option<ReplaceHistoricalHirakatasMode>,
    /// Combine decomposed hiraganas and katakanas into single counterparts.
    ///
    /// # Example
    /// ```text
    /// Input:  "が" (か + ゙)
    /// Output: "が" (single character)
    /// ```
    /// ```text
    /// Input:  "ヘ゜" (ヘ + ゜)
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

impl TransliterationRecipe {
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

    fn apply_hira_kata(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        match &self.hira_kata {
            HiraKataOptions::HiraToKata => {
                builder = builder.insert_tail(
                    TransliteratorConfig::HiraKata(
                        crate::transliterators::HiraKataTransliteratorOptions {
                            mode: crate::transliterators::HiraKataMode::HiraToKata,
                        },
                    ),
                    false,
                );
            }
            HiraKataOptions::KataToHira => {
                builder = builder.insert_tail(
                    TransliteratorConfig::HiraKata(
                        crate::transliterators::HiraKataTransliteratorOptions {
                            mode: crate::transliterators::HiraKataMode::KataToHira,
                        },
                    ),
                    false,
                );
            }
            HiraKataOptions::No => {}
        }
        (builder, None)
    }

    fn apply_replace_japanese_iteration_marks(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if self.replace_japanese_iteration_marks {
            // Insert HiraKataComposition at head to ensure composed forms
            builder = builder.insert_head(
                TransliteratorConfig::HiraKataComposition(
                    crate::transliterators::HiraKataCompositionTransliteratorOptions {
                        compose_non_combining_marks: true,
                    },
                ),
                false,
            );
            // Then insert the japanese-iteration-marks in the middle
            builder = builder.insert_middle(
                TransliteratorConfig::JapaneseIterationMarks(
                    crate::transliterators::JapaneseIterationMarksTransliteratorOptions::default(),
                ),
                false,
            );
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

    fn apply_replace_roman_numerals(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if self.replace_roman_numerals {
            builder = builder.insert_middle(TransliteratorConfig::RomanNumerals, false);
        }
        (builder, None)
    }

    fn apply_replace_archaic_hirakatas(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if self.replace_archaic_hirakatas {
            builder = builder.insert_middle(TransliteratorConfig::ArchaicHirakatas, false);
        }
        (builder, None)
    }

    fn apply_replace_small_hirakatas(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if self.replace_small_hirakatas {
            builder = builder.insert_middle(TransliteratorConfig::SmallHirakatas, false);
        }
        (builder, None)
    }

    fn apply_replace_historical_hirakatas(
        &self,
        mut builder: TransliteratorConfigBuilder,
    ) -> (
        TransliteratorConfigBuilder,
        Option<TransliterationRecipeError>,
    ) {
        if let Some(mode) = &self.replace_historical_hirakatas {
            let options = match mode {
                ReplaceHistoricalHirakatasMode::Simple => {
                    HistoricalHirakatasTransliteratorOptions {
                        hiraganas: HistoricalHiraganaMode::Simple,
                        katakanas: HistoricalKatakanaMode::Simple,
                        voiced_katakanas: VoicedHistoricalKanaMode::Skip,
                    }
                }
                ReplaceHistoricalHirakatasMode::Decompose => {
                    HistoricalHirakatasTransliteratorOptions {
                        hiraganas: HistoricalHiraganaMode::Decompose,
                        katakanas: HistoricalKatakanaMode::Decompose,
                        voiced_katakanas: VoicedHistoricalKanaMode::Decompose,
                    }
                }
            };
            builder =
                builder.insert_middle(TransliteratorConfig::HistoricalHirakatas(options), false);
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
                TransliteratorConfig::Jisx0201AndAlike {
                    fullwidth_to_halfwidth: false,
                    options: crate::transliterators::Jisx0201AndAlikeTransliteratorOptions {
                        u005c_as_yen_sign: Some(u005c_as_yen_sign),
                        ..Default::default()
                    },
                },
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
                TransliteratorConfig::Jisx0201AndAlike {
                    fullwidth_to_halfwidth: true,
                    options: crate::transliterators::Jisx0201AndAlikeTransliteratorOptions {
                        convert_gl: true,
                        convert_gr: hankaku_kana,
                        ..Default::default()
                    },
                },
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

        // 10. replaceRomanNumerals
        let (builder, e) = self.apply_replace_roman_numerals(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 10a. replaceArchaicHirakatas
        let (builder, e) = self.apply_replace_archaic_hirakatas(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 10b. replaceSmallHirakatas
        let (builder, e) = self.apply_replace_small_hirakatas(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 10c. replaceHistoricalHirakatas
        let (builder, e) = self.apply_replace_historical_hirakatas(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 11. combineDecomposedHiraganasAndKatakanas
        let (builder, e) = self.apply_combine_decomposed_hiraganas_and_katakanas(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 11. toFullwidth
        let (builder, e) = self.apply_to_fullwidth(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 12. hiraKata
        let (builder, e) = self.apply_hira_kata(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 13. replaceJapaneseIterationMarks
        let (builder, e) = self.apply_replace_japanese_iteration_marks(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 14. toHalfwidth
        let (builder, e) = self.apply_to_halfwidth(builder);
        if let Some(e) = e {
            errors.push(e);
        }

        // 15. removeIVSSVS
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

impl TryFrom<&TransliterationRecipe> for Vec<TransliteratorConfig> {
    type Error = TransliteratorFactoryError;
    fn try_from(value: &TransliterationRecipe) -> Result<Vec<TransliteratorConfig>, Self::Error> {
        value.build()
    }
}

impl Default for TransliterationRecipe {
    fn default() -> Self {
        Self {
            kanji_old_new: false,
            hira_kata: HiraKataOptions::No,
            replace_japanese_iteration_marks: false,
            replace_suspicious_hyphens_to_prolonged_sound_marks: false,
            replace_combined_characters: false,
            replace_circled_or_squared_characters: ReplaceCircledOrSquaredCharactersOptions::No,
            replace_ideographic_annotations: false,
            replace_radicals: false,
            replace_spaces: false,
            replace_hyphens: ReplaceHyphensOptions::No,
            replace_mathematical_alphanumerics: false,
            replace_roman_numerals: false,
            replace_archaic_hirakatas: false,
            replace_small_hirakatas: false,
            replace_historical_hirakatas: None,
            combine_decomposed_hiraganas_and_katakanas: false,
            to_fullwidth: ToFullWidthOptions::No,
            to_halfwidth: ToHalfwidthOptions::No,
            remove_ivs_svs: RemoveIVSSVSOptions::No,
            charset: Charset::Unijis2004,
        }
    }
}

impl TransliteratorFactory for TransliterationRecipe {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        self.build()?.new_transliterator()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::char::{from_chars, CharPool};
    use crate::transliterators::{
        HiraKataCompositionTransliteratorOptions, ProlongedSoundMarksTransliteratorOptions,
    };

    #[test]
    fn test_recipe_build_basic() {
        let recipe = TransliterationRecipe {
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
        let recipe = TransliterationRecipe {
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

    #[test]
    fn test_vec_transliterator_config_factory() {
        let configs = vec![
            TransliteratorConfig::HiraKataComposition(
                HiraKataCompositionTransliteratorOptions::default(),
            ),
            TransliteratorConfig::ProlongedSoundMarks(
                ProlongedSoundMarksTransliteratorOptions::default(),
            ),
        ];

        let factory_result = configs.new_transliterator();
        assert!(factory_result.is_ok());

        let transliterator = factory_result.unwrap();

        // Since all current implementations are stubs, this should preserve input
        let test_cases = &[("test", "test"), ("こんにちは", "こんにちは"), ("", "")];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().cloned());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_vec_transliterator_config_empty_error() {
        let configs: Vec<TransliteratorConfig> = vec![];
        let factory_result = configs.new_transliterator();
        assert!(factory_result.is_err());
    }
}
