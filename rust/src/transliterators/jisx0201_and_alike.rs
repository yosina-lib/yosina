use serde::{Deserialize, Serialize};
use std::borrow::Cow;
use std::collections::HashMap;
use std::sync::{LazyLock, RwLock};

use crate::char::{Char, CharPool};
use crate::transliterator::{Transliterator, TransliteratorFactory};
use crate::{TransliterationError, TransliteratorFactoryError};

use super::hira_kata_table::{HIRAGANA_KATAKANA_SMALL_TABLE, HIRAGANA_KATAKANA_TABLE};

/// JIS X 0201 GL (Graphics Left) character mappings: fullwidth to halfwidth
static JISX0201_GL_TABLE: &[(&str, &str)] = &[
    ("\u{3000}", "\u{0020}"), // IDEOGRAPHIC SPACE -> SPACE
    ("\u{FF01}", "\u{0021}"), // FULLWIDTH EXCLAMATION MARK -> EXCLAMATION MARK
    ("\u{FF02}", "\u{0022}"), // FULLWIDTH QUOTATION MARK -> QUOTATION MARK
    ("\u{FF03}", "\u{0023}"), // FULLWIDTH NUMBER SIGN -> NUMBER SIGN
    ("\u{FF04}", "\u{0024}"), // FULLWIDTH DOLLAR SIGN -> DOLLAR SIGN
    ("\u{FF05}", "\u{0025}"), // FULLWIDTH PERCENT SIGN -> PERCENT SIGN
    ("\u{FF06}", "\u{0026}"), // FULLWIDTH AMPERSAND -> AMPERSAND
    ("\u{FF07}", "\u{0027}"), // FULLWIDTH APOSTROPHE -> APOSTROPHE
    ("\u{FF08}", "\u{0028}"), // FULLWIDTH LEFT PARENTHESIS -> LEFT PARENTHESIS
    ("\u{FF09}", "\u{0029}"), // FULLWIDTH RIGHT PARENTHESIS -> RIGHT PARENTHESIS
    ("\u{FF0A}", "\u{002A}"), // FULLWIDTH ASTERISK -> ASTERISK
    ("\u{FF0B}", "\u{002B}"), // FULLWIDTH PLUS SIGN -> PLUS SIGN
    ("\u{FF0C}", "\u{002C}"), // FULLWIDTH COMMA -> COMMA
    ("\u{FF0D}", "\u{002D}"), // FULLWIDTH HYPHEN-MINUS -> HYPHEN-MINUS
    ("\u{FF0E}", "\u{002E}"), // FULLWIDTH FULL STOP -> FULL STOP
    ("\u{FF0F}", "\u{002F}"), // FULLWIDTH SOLIDUS -> SOLIDUS
    ("\u{FF10}", "\u{0030}"), // FULLWIDTH DIGIT ZERO -> DIGIT ZERO
    ("\u{FF11}", "\u{0031}"), // FULLWIDTH DIGIT ONE -> DIGIT ONE
    ("\u{FF12}", "\u{0032}"), // FULLWIDTH DIGIT TWO -> DIGIT TWO
    ("\u{FF13}", "\u{0033}"), // FULLWIDTH DIGIT THREE -> DIGIT THREE
    ("\u{FF14}", "\u{0034}"), // FULLWIDTH DIGIT FOUR -> DIGIT FOUR
    ("\u{FF15}", "\u{0035}"), // FULLWIDTH DIGIT FIVE -> DIGIT FIVE
    ("\u{FF16}", "\u{0036}"), // FULLWIDTH DIGIT SIX -> DIGIT SIX
    ("\u{FF17}", "\u{0037}"), // FULLWIDTH DIGIT SEVEN -> DIGIT SEVEN
    ("\u{FF18}", "\u{0038}"), // FULLWIDTH DIGIT EIGHT -> DIGIT EIGHT
    ("\u{FF19}", "\u{0039}"), // FULLWIDTH DIGIT NINE -> DIGIT NINE
    ("\u{FF1A}", "\u{003A}"), // FULLWIDTH COLON -> COLON
    ("\u{FF1B}", "\u{003B}"), // FULLWIDTH SEMICOLON -> SEMICOLON
    ("\u{FF1C}", "\u{003C}"), // FULLWIDTH LESS-THAN SIGN -> LESS-THAN SIGN
    ("\u{FF1D}", "\u{003D}"), // FULLWIDTH EQUALS SIGN -> EQUALS SIGN
    ("\u{FF1E}", "\u{003E}"), // FULLWIDTH GREATER-THAN SIGN -> GREATER-THAN SIGN
    ("\u{FF1F}", "\u{003F}"), // FULLWIDTH QUESTION MARK -> QUESTION MARK
    ("\u{FF20}", "\u{0040}"), // FULLWIDTH COMMERCIAL AT -> COMMERCIAL AT
    ("\u{FF21}", "\u{0041}"), // FULLWIDTH LATIN CAPITAL LETTER A -> LATIN CAPITAL LETTER A
    ("\u{FF22}", "\u{0042}"), // FULLWIDTH LATIN CAPITAL LETTER B -> LATIN CAPITAL LETTER B
    ("\u{FF23}", "\u{0043}"), // FULLWIDTH LATIN CAPITAL LETTER C -> LATIN CAPITAL LETTER C
    ("\u{FF24}", "\u{0044}"), // FULLWIDTH LATIN CAPITAL LETTER D -> LATIN CAPITAL LETTER D
    ("\u{FF25}", "\u{0045}"), // FULLWIDTH LATIN CAPITAL LETTER E -> LATIN CAPITAL LETTER E
    ("\u{FF26}", "\u{0046}"), // FULLWIDTH LATIN CAPITAL LETTER F -> LATIN CAPITAL LETTER F
    ("\u{FF27}", "\u{0047}"), // FULLWIDTH LATIN CAPITAL LETTER G -> LATIN CAPITAL LETTER G
    ("\u{FF28}", "\u{0048}"), // FULLWIDTH LATIN CAPITAL LETTER H -> LATIN CAPITAL LETTER H
    ("\u{FF29}", "\u{0049}"), // FULLWIDTH LATIN CAPITAL LETTER I -> LATIN CAPITAL LETTER I
    ("\u{FF2A}", "\u{004A}"), // FULLWIDTH LATIN CAPITAL LETTER J -> LATIN CAPITAL LETTER J
    ("\u{FF2B}", "\u{004B}"), // FULLWIDTH LATIN CAPITAL LETTER K -> LATIN CAPITAL LETTER K
    ("\u{FF2C}", "\u{004C}"), // FULLWIDTH LATIN CAPITAL LETTER L -> LATIN CAPITAL LETTER L
    ("\u{FF2D}", "\u{004D}"), // FULLWIDTH LATIN CAPITAL LETTER M -> LATIN CAPITAL LETTER M
    ("\u{FF2E}", "\u{004E}"), // FULLWIDTH LATIN CAPITAL LETTER N -> LATIN CAPITAL LETTER N
    ("\u{FF2F}", "\u{004F}"), // FULLWIDTH LATIN CAPITAL LETTER O -> LATIN CAPITAL LETTER O
    ("\u{FF30}", "\u{0050}"), // FULLWIDTH LATIN CAPITAL LETTER P -> LATIN CAPITAL LETTER P
    ("\u{FF31}", "\u{0051}"), // FULLWIDTH LATIN CAPITAL LETTER Q -> LATIN CAPITAL LETTER Q
    ("\u{FF32}", "\u{0052}"), // FULLWIDTH LATIN CAPITAL LETTER R -> LATIN CAPITAL LETTER R
    ("\u{FF33}", "\u{0053}"), // FULLWIDTH LATIN CAPITAL LETTER S -> LATIN CAPITAL LETTER S
    ("\u{FF34}", "\u{0054}"), // FULLWIDTH LATIN CAPITAL LETTER T -> LATIN CAPITAL LETTER T
    ("\u{FF35}", "\u{0055}"), // FULLWIDTH LATIN CAPITAL LETTER U -> LATIN CAPITAL LETTER U
    ("\u{FF36}", "\u{0056}"), // FULLWIDTH LATIN CAPITAL LETTER V -> LATIN CAPITAL LETTER V
    ("\u{FF37}", "\u{0057}"), // FULLWIDTH LATIN CAPITAL LETTER W -> LATIN CAPITAL LETTER W
    ("\u{FF38}", "\u{0058}"), // FULLWIDTH LATIN CAPITAL LETTER X -> LATIN CAPITAL LETTER X
    ("\u{FF39}", "\u{0059}"), // FULLWIDTH LATIN CAPITAL LETTER Y -> LATIN CAPITAL LETTER Y
    ("\u{FF3A}", "\u{005A}"), // FULLWIDTH LATIN CAPITAL LETTER Z -> LATIN CAPITAL LETTER Z
    ("\u{FF3B}", "\u{005B}"), // FULLWIDTH LEFT SQUARE BRACKET -> LEFT SQUARE BRACKET
    ("\u{FF3D}", "\u{005D}"), // FULLWIDTH RIGHT SQUARE BRACKET -> RIGHT SQUARE BRACKET
    ("\u{FF3E}", "\u{005E}"), // FULLWIDTH CIRCUMFLEX ACCENT -> CIRCUMFLEX ACCENT
    ("\u{FF3F}", "\u{005F}"), // FULLWIDTH LOW LINE -> LOW LINE
    ("\u{FF40}", "\u{0060}"), // FULLWIDTH GRAVE ACCENT -> GRAVE ACCENT
    ("\u{FF41}", "\u{0061}"), // FULLWIDTH LATIN SMALL LETTER A -> LATIN SMALL LETTER A
    ("\u{FF42}", "\u{0062}"), // FULLWIDTH LATIN SMALL LETTER B -> LATIN SMALL LETTER B
    ("\u{FF43}", "\u{0063}"), // FULLWIDTH LATIN SMALL LETTER C -> LATIN SMALL LETTER C
    ("\u{FF44}", "\u{0064}"), // FULLWIDTH LATIN SMALL LETTER D -> LATIN SMALL LETTER D
    ("\u{FF45}", "\u{0065}"), // FULLWIDTH LATIN SMALL LETTER E -> LATIN SMALL LETTER E
    ("\u{FF46}", "\u{0066}"), // FULLWIDTH LATIN SMALL LETTER F -> LATIN SMALL LETTER F
    ("\u{FF47}", "\u{0067}"), // FULLWIDTH LATIN SMALL LETTER G -> LATIN SMALL LETTER G
    ("\u{FF48}", "\u{0068}"), // FULLWIDTH LATIN SMALL LETTER H -> LATIN SMALL LETTER H
    ("\u{FF49}", "\u{0069}"), // FULLWIDTH LATIN SMALL LETTER I -> LATIN SMALL LETTER I
    ("\u{FF4A}", "\u{006A}"), // FULLWIDTH LATIN SMALL LETTER J -> LATIN SMALL LETTER J
    ("\u{FF4B}", "\u{006B}"), // FULLWIDTH LATIN SMALL LETTER K -> LATIN SMALL LETTER K
    ("\u{FF4C}", "\u{006C}"), // FULLWIDTH LATIN SMALL LETTER L -> LATIN SMALL LETTER L
    ("\u{FF4D}", "\u{006D}"), // FULLWIDTH LATIN SMALL LETTER M -> LATIN SMALL LETTER M
    ("\u{FF4E}", "\u{006E}"), // FULLWIDTH LATIN SMALL LETTER N -> LATIN SMALL LETTER N
    ("\u{FF4F}", "\u{006F}"), // FULLWIDTH LATIN SMALL LETTER O -> LATIN SMALL LETTER O
    ("\u{FF50}", "\u{0070}"), // FULLWIDTH LATIN SMALL LETTER P -> LATIN SMALL LETTER P
    ("\u{FF51}", "\u{0071}"), // FULLWIDTH LATIN SMALL LETTER Q -> LATIN SMALL LETTER Q
    ("\u{FF52}", "\u{0072}"), // FULLWIDTH LATIN SMALL LETTER R -> LATIN SMALL LETTER R
    ("\u{FF53}", "\u{0073}"), // FULLWIDTH LATIN SMALL LETTER S -> LATIN SMALL LETTER S
    ("\u{FF54}", "\u{0074}"), // FULLWIDTH LATIN SMALL LETTER T -> LATIN SMALL LETTER T
    ("\u{FF55}", "\u{0075}"), // FULLWIDTH LATIN SMALL LETTER U -> LATIN SMALL LETTER U
    ("\u{FF56}", "\u{0076}"), // FULLWIDTH LATIN SMALL LETTER V -> LATIN SMALL LETTER V
    ("\u{FF57}", "\u{0077}"), // FULLWIDTH LATIN SMALL LETTER W -> LATIN SMALL LETTER W
    ("\u{FF58}", "\u{0078}"), // FULLWIDTH LATIN SMALL LETTER X -> LATIN SMALL LETTER X
    ("\u{FF59}", "\u{0079}"), // FULLWIDTH LATIN SMALL LETTER Y -> LATIN SMALL LETTER Y
    ("\u{FF5A}", "\u{007A}"), // FULLWIDTH LATIN SMALL LETTER Z -> LATIN SMALL LETTER Z
    ("\u{FF5B}", "\u{007B}"), // FULLWIDTH LEFT CURLY BRACKET -> LEFT CURLY BRACKET
    ("\u{FF5C}", "\u{007C}"), // FULLWIDTH VERTICAL LINE -> VERTICAL LINE
    ("\u{FF5D}", "\u{007D}"), // FULLWIDTH RIGHT CURLY BRACKET -> RIGHT CURLY BRACKET
];

/// Generate GR table from shared hira_kata_table at runtime
fn generate_gr_table() -> Vec<(&'static str, &'static str)> {
    let mut result = vec![
        ("\u{3002}", "\u{FF61}"), // IDEOGRAPHIC FULL STOP -> HALFWIDTH IDEOGRAPHIC FULL STOP
        ("\u{300C}", "\u{FF62}"), // LEFT CORNER BRACKET -> HALFWIDTH LEFT CORNER BRACKET
        ("\u{300D}", "\u{FF63}"), // RIGHT CORNER BRACKET -> HALFWIDTH RIGHT CORNER BRACKET
        ("\u{3001}", "\u{FF64}"), // IDEOGRAPHIC COMMA -> HALFWIDTH IDEOGRAPHIC COMMA
        ("\u{30FB}", "\u{FF65}"), // KATAKANA MIDDLE DOT -> HALFWIDTH KATAKANA MIDDLE DOT
        ("\u{30FC}", "\u{FF70}"), // KATAKANA-HIRAGANA PROLONGED SOUND MARK -> HALFWIDTH KATAKANA-HIRAGANA PROLONGED SOUND MARK
        ("\u{309B}", "\u{FF9E}"), // KATAKANA-HIRAGANA VOICED SOUND MARK -> HALFWIDTH KATAKANA VOICED SOUND MARK
        ("\u{309C}", "\u{FF9F}"), // KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK -> HALFWIDTH KATAKANA SEMI-VOICED SOUND MARK
    ];

    // Add katakana mappings from main table
    for entry in HIRAGANA_KATAKANA_TABLE {
        if let Some(halfwidth) = entry.halfwidth {
            result.push((entry.katakana.base, halfwidth.base));
        }
    }

    // Add small kana mappings
    for entry in HIRAGANA_KATAKANA_SMALL_TABLE {
        if let Some(halfwidth) = entry.halfwidth {
            result.push((entry.katakana, halfwidth));
        }
    }

    result
}

/// JIS X 0201 GR (Graphics Right) character mappings: katakana fullwidth to halfwidth
static JISX0201_GR_TABLE: LazyLock<Vec<(&'static str, &'static str)>> =
    LazyLock::new(generate_gr_table);

/// Generate voiced letters table from shared hira_kata_table at runtime
fn generate_voiced_letters_table() -> Vec<(&'static str, &'static str)> {
    let mut result = Vec::new();

    for entry in HIRAGANA_KATAKANA_TABLE {
        if let Some(halfwidth) = entry.halfwidth {
            if let Some(voiced) = entry.katakana.voiced {
                if let Some(halfwidth_voiced) = halfwidth.voiced {
                    result.push((voiced, halfwidth_voiced));
                }
            }
            if let Some(semivoiced) = entry.katakana.semivoiced {
                if let Some(halfwidth_semivoiced) = halfwidth.semivoiced {
                    result.push((semivoiced, halfwidth_semivoiced));
                }
            }
        }
    }

    result
}

/// Voiced katakana letters that can be decomposed into base + voiced mark
static VOICED_LETTERS_TABLE: LazyLock<Vec<(&'static str, &'static str)>> =
    LazyLock::new(generate_voiced_letters_table);

/// Generate hiragana to halfwidth mappings from shared hira_kata_table at runtime
fn generate_hiragana_mappings() -> Vec<(&'static str, &'static str)> {
    let mut result = Vec::new();

    // Add main table hiragana mappings
    for entry in HIRAGANA_KATAKANA_TABLE {
        if let Some(halfwidth) = entry.halfwidth {
            result.push((entry.hiragana.base, halfwidth.base));
            if let Some(voiced) = entry.hiragana.voiced {
                if let Some(halfwidth_voiced) = halfwidth.voiced {
                    result.push((voiced, halfwidth_voiced));
                }
            }
            if let Some(semivoiced) = entry.hiragana.semivoiced {
                if let Some(halfwidth_semivoiced) = halfwidth.semivoiced {
                    result.push((semivoiced, halfwidth_semivoiced));
                }
            }
        }
    }

    // Add small kana mappings
    for entry in HIRAGANA_KATAKANA_SMALL_TABLE {
        if let Some(halfwidth) = entry.halfwidth {
            result.push((entry.hiragana, halfwidth));
        }
    }

    result
}

/// Hiragana to halfwidth katakana mappings
static HIRAGANA_TO_HALFWIDTH_TABLE: LazyLock<Vec<(&'static str, &'static str)>> =
    LazyLock::new(generate_hiragana_mappings);

/// Special punctuation mappings
static SPECIAL_PUNCTUATIONS_TABLE: &[(&str, &str)] = &[
    ("\u{30A0}", "\u{003D}"), // KATAKANA-HIRAGANA DOUBLE HYPHEN -> EQUALS SIGN
];

/// GL override options for ambiguous characters
static JISX0201_GL_OVERRIDES: &[(&str, &str, &str)] = &[
    ("u005cAsYenSign", "\u{FFE5}", "\u{005C}"), // YEN SIGN -> REVERSE SOLIDUS
    ("u005cAsBackslash", "\u{FF3C}", "\u{005C}"), // FULLWIDTH REVERSE SOLIDUS -> REVERSE SOLIDUS
    ("u007eAsFullwidthTilde", "\u{FF5E}", "\u{007E}"), // FULLWIDTH TILDE -> TILDE
    ("u007eAsWaveDash", "\u{301C}", "\u{007E}"), // WAVE DASH -> TILDE
    ("u007eAsOverline", "\u{203E}", "\u{007E}"), // OVERLINE -> TILDE
    ("u007eAsFullwidthMacron", "\u{FFE3}", "\u{007E}"), // FULLWIDTH MACRON -> TILDE
    ("u00a5AsYenSign", "\u{FFE5}", "\u{00A5}"), // FULLWIDTH YEN SIGN -> YEN SIGN
];

/// Cache key type for mapping caches
type CacheKey = (
    bool, // convert_gl
    bool, // convert_gr
    bool, // convert_unsafe_specials
    bool, // convert_hiraganas
    bool, // u005c_as_yen_sign
    bool, // u005c_as_backslash
    bool, // u007e_as_fullwidth_tilde
    bool, // u007e_as_wave_dash
    bool, // u007e_as_overline
    bool, // u007e_as_fullwidth_macron
    bool, // u00a5_as_yen_sign
);

/// Global cache for forward mappings
pub static FWD_MAPPINGS_CACHE: LazyLock<
    RwLock<HashMap<CacheKey, HashMap<&'static str, &'static str>>>,
> = LazyLock::new(|| RwLock::new(HashMap::new()));

/// Global cache for reverse mappings
pub static REV_MAPPINGS_CACHE: LazyLock<
    RwLock<HashMap<CacheKey, HashMap<&'static str, &'static str>>>,
> = LazyLock::new(|| RwLock::new(HashMap::new()));

/// Global cache for voiced reverse mappings
#[allow(clippy::type_complexity)]
pub static VOICED_REV_MAPPINGS_CACHE: LazyLock<
    RwLock<HashMap<CacheKey, HashMap<&'static str, HashMap<&'static str, &'static str>>>>,
> = LazyLock::new(|| RwLock::new(HashMap::new()));

trait CacheKeyGenerator {
    /// Generate cache key for the transliterator options
    fn generate_cache_key(&self) -> CacheKey;
}

/// Get forward mappings from cache or build new ones
pub fn get_fwd_mappings(
    options: &Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorOptions,
) -> HashMap<&'static str, &'static str> {
    let cache_key = options.generate_cache_key();

    // Try to read from cache first
    {
        let cache = FWD_MAPPINGS_CACHE.read().unwrap();
        if let Some(mappings) = cache.get(&cache_key) {
            return mappings.clone();
        }
    }

    // Build new mappings and cache them
    let mappings = options.build_forward_mappings();
    {
        let mut cache = FWD_MAPPINGS_CACHE.write().unwrap();
        cache.insert(cache_key, mappings.clone());
    }

    mappings
}

/// Get reverse mappings from cache or build new ones
pub fn get_rev_mappings(
    options: &Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorOptions,
) -> HashMap<&'static str, &'static str> {
    let cache_key = options.generate_cache_key();

    // Try to read from cache first
    {
        let cache = REV_MAPPINGS_CACHE.read().unwrap();
        if let Some(mappings) = cache.get(&cache_key) {
            return mappings.clone();
        }
    }

    // Build new mappings and cache them
    let mappings = options.build_reverse_mappings();
    {
        let mut cache = REV_MAPPINGS_CACHE.write().unwrap();
        cache.insert(cache_key, mappings.clone());
    }

    mappings
}

/// Get voiced reverse mappings from cache or build new ones
fn get_voiced_rev_mappings(
    options: &Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorOptions,
) -> HashMap<&'static str, HashMap<&'static str, &'static str>> {
    let cache_key = options.generate_cache_key();

    // Try to read from cache first
    {
        let cache = VOICED_REV_MAPPINGS_CACHE.read().unwrap();
        if let Some(mappings) = cache.get(&cache_key) {
            return mappings.clone();
        }
    }

    // Build new mappings and cache them
    let mappings = options.build_voiced_reverse_mappings();
    {
        let mut cache = VOICED_REV_MAPPINGS_CACHE.write().unwrap();
        cache.insert(cache_key, mappings.clone());
    }

    mappings
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct Jisx0201AndAlikeTransliteratorOptions {
    /// Convert characters belonging to GL area (alphanumerics and symbols)
    pub convert_gl: bool,
    /// Convert characters belonging to GR area (katakanas)
    pub convert_gr: bool,
    /// Convert hiraganas to/from katakanas
    pub convert_hiraganas: bool,
    /// Combine voiced sound marks with base characters
    pub combine_voiced_sound_marks: bool,
    /// Convert unsafe special characters like KATAKANA-HIRAGANA DOUBLE HYPHEN
    pub convert_unsafe_specials: Option<bool>,
    /// Treat U+005C as YEN SIGN
    pub u005c_as_yen_sign: Option<bool>,
    /// Treat U+005C verbatim as backslash
    pub u005c_as_backslash: Option<bool>,
    /// Convert U+007E to FULLWIDTH TILDE
    pub u007e_as_fullwidth_tilde: Option<bool>,
    /// Convert U+007E to WAVE DASH
    pub u007e_as_wave_dash: Option<bool>,
    /// Convert U+007E to OVERLINE
    pub u007e_as_overline: Option<bool>,
    /// Convert U+007E to FULLWIDTH MACRON
    pub u007e_as_fullwidth_macron: Option<bool>,
    /// Convert U+00A5 to REVERSE SOLIDUS
    pub u00a5_as_yen_sign: Option<bool>,
}

impl Default for Jisx0201AndAlikeTransliteratorOptions {
    fn default() -> Self {
        Self {
            convert_gl: true,
            convert_gr: true,
            convert_unsafe_specials: None,
            convert_hiraganas: false,
            combine_voiced_sound_marks: true,
            u005c_as_yen_sign: None,
            u005c_as_backslash: None,
            u007e_as_fullwidth_tilde: None,
            u007e_as_wave_dash: None,
            u007e_as_overline: None,
            u007e_as_fullwidth_macron: None,
            u00a5_as_yen_sign: None,
        }
    }
}

impl Jisx0201AndAlikeTransliteratorOptions {
    fn build_fullwidth_to_halfwidth_options(
        &self,
    ) -> Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorOptions {
        Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorOptions {
            convert_gl: self.convert_gl,
            convert_gr: self.convert_gr,
            convert_hiraganas: self.convert_hiraganas,
            convert_unsafe_specials: self.convert_unsafe_specials.unwrap_or(true),
            u005c_as_yen_sign: self
                .u005c_as_yen_sign
                .unwrap_or_else(|| self.u00a5_as_yen_sign.is_none()),
            u005c_as_backslash: self.u005c_as_backslash.unwrap_or(false),
            u007e_as_fullwidth_tilde: self.u007e_as_fullwidth_tilde.unwrap_or(true),
            u007e_as_wave_dash: self.u007e_as_wave_dash.unwrap_or(true),
            u007e_as_overline: self.u007e_as_overline.unwrap_or(false),
            u007e_as_fullwidth_macron: self.u007e_as_fullwidth_macron.unwrap_or(false),
            u00a5_as_yen_sign: self.u00a5_as_yen_sign.unwrap_or(false),
        }
    }

    fn build_halfwidth_to_fullwidth_options(
        &self,
    ) -> Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorOptions {
        Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorOptions {
            convert_gl: self.convert_gl,
            convert_gr: self.convert_gr,
            combine_voiced_sound_marks: self.combine_voiced_sound_marks,
            convert_unsafe_specials: self.convert_unsafe_specials.unwrap_or(false),
            u005c_as_yen_sign: self
                .u005c_as_yen_sign
                .unwrap_or_else(|| self.u005c_as_backslash.is_none()),
            u005c_as_backslash: self.u005c_as_backslash.unwrap_or(false),
            u007e_as_fullwidth_tilde: self.u007e_as_fullwidth_tilde.unwrap_or_else(|| {
                self.u007e_as_wave_dash.is_none()
                    && self.u007e_as_overline.is_none()
                    && self.u007e_as_fullwidth_macron.is_none()
            }),
            u007e_as_wave_dash: self.u007e_as_wave_dash.unwrap_or(false),
            u007e_as_overline: self.u007e_as_overline.unwrap_or(false),
            u007e_as_fullwidth_macron: self.u007e_as_fullwidth_macron.unwrap_or(false),
            u00a5_as_yen_sign: self.u00a5_as_yen_sign.unwrap_or(false),
        }
    }
}

impl From<&Jisx0201AndAlikeTransliteratorOptions>
    for Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorOptions
{
    fn from(options: &Jisx0201AndAlikeTransliteratorOptions) -> Self {
        options.build_fullwidth_to_halfwidth_options()
    }
}

impl From<Jisx0201AndAlikeTransliteratorOptions>
    for Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorOptions
{
    fn from(options: Jisx0201AndAlikeTransliteratorOptions) -> Self {
        (&options).into()
    }
}

impl From<&Jisx0201AndAlikeTransliteratorOptions>
    for Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorOptions
{
    fn from(options: &Jisx0201AndAlikeTransliteratorOptions) -> Self {
        options.build_halfwidth_to_fullwidth_options()
    }
}

impl From<Jisx0201AndAlikeTransliteratorOptions>
    for Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorOptions
{
    fn from(options: Jisx0201AndAlikeTransliteratorOptions) -> Self {
        (&options).into()
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorOptions {
    /// Convert characters belonging to GL area (alphanumerics and symbols)
    pub convert_gl: bool,
    /// Convert characters belonging to GR area (katakanas)
    pub convert_gr: bool,
    /// Convert hiraganas to/from katakanas
    pub convert_hiraganas: bool,
    /// Convert unsafe special characters like KATAKANA-HIRAGANA DOUBLE HYPHEN
    pub convert_unsafe_specials: bool,
    /// Treat U+005C as YEN SIGN
    pub u005c_as_yen_sign: bool,
    /// Treat U+005C verbatim as backslash
    pub u005c_as_backslash: bool,
    /// Convert U+007E to FULLWIDTH TILDE
    pub u007e_as_fullwidth_tilde: bool,
    /// Convert U+007E to WAVE DASH
    pub u007e_as_wave_dash: bool,
    /// Convert U+007E to OVERLINE
    pub u007e_as_overline: bool,
    /// Convert U+007E to FULLWIDTH MACRON
    pub u007e_as_fullwidth_macron: bool,
    /// Convert U+00A5 to REVERSE SOLIDUS
    pub u00a5_as_yen_sign: bool,
}

impl Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorOptions {
    fn build_forward_mappings(&self) -> HashMap<&'static str, &'static str> {
        let mut mappings = HashMap::new();

        if self.convert_gl {
            for (from, to) in JISX0201_GL_TABLE {
                mappings.insert(*from, *to);
            }

            // Apply GL overrides
            for (option_name, from, to) in JISX0201_GL_OVERRIDES {
                let should_apply = match *option_name {
                    "u005cAsYenSign" => self.u005c_as_yen_sign,
                    "u005cAsBackslash" => self.u005c_as_backslash,
                    "u007eAsFullwidthTilde" => self.u007e_as_fullwidth_tilde,
                    "u007eAsWaveDash" => self.u007e_as_wave_dash,
                    "u007eAsOverline" => self.u007e_as_overline,
                    "u007eAsFullwidthMacron" => self.u007e_as_fullwidth_macron,
                    "u00a5AsYenSign" => self.u00a5_as_yen_sign,
                    _ => false,
                };
                if should_apply {
                    mappings.insert(*from, *to);
                }
            }
        }

        if self.convert_gr {
            for (from, to) in JISX0201_GR_TABLE.iter() {
                mappings.insert(*from, *to);
            }
            for (from, to) in VOICED_LETTERS_TABLE.iter() {
                mappings.insert(*from, *to);
            }
            // Add combining marks
            mappings.insert("\u{3099}", "\u{FF9E}"); // COMBINING KATAKANA-HIRAGANA VOICED SOUND MARK
            mappings.insert("\u{309A}", "\u{FF9F}"); // COMBINING KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK
        }

        if self.convert_unsafe_specials {
            for (from, to) in SPECIAL_PUNCTUATIONS_TABLE {
                mappings.insert(*from, *to);
            }
        }

        if self.convert_hiraganas {
            for (from, to) in HIRAGANA_TO_HALFWIDTH_TABLE.iter() {
                mappings.insert(*from, *to);
            }
        }

        mappings
    }
}

impl CacheKeyGenerator for Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorOptions {
    fn generate_cache_key(&self) -> CacheKey {
        (
            self.convert_gl,
            self.convert_gr,
            self.convert_unsafe_specials,
            self.convert_hiraganas,
            self.u005c_as_yen_sign,
            self.u005c_as_backslash,
            self.u007e_as_fullwidth_tilde,
            self.u007e_as_wave_dash,
            self.u007e_as_overline,
            self.u007e_as_fullwidth_macron,
            self.u00a5_as_yen_sign,
        )
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorOptions {
    /// Convert characters belonging to GL area (alphanumerics and symbols)
    pub convert_gl: bool,
    /// Convert characters belonging to GR area (katakanas)
    pub convert_gr: bool,
    /// Combine voiced sound marks with base characters
    pub combine_voiced_sound_marks: bool,
    /// Convert unsafe special characters like KATAKANA-HIRAGANA DOUBLE HYPHEN
    pub convert_unsafe_specials: bool,
    /// Treat U+005C as YEN SIGN
    pub u005c_as_yen_sign: bool,
    /// Treat U+005C verbatim as backslash
    pub u005c_as_backslash: bool,
    /// Convert U+007E to FULLWIDTH TILDE
    pub u007e_as_fullwidth_tilde: bool,
    /// Convert U+007E to WAVE DASH
    pub u007e_as_wave_dash: bool,
    /// Convert U+007E to OVERLINE
    pub u007e_as_overline: bool,
    /// Convert U+007E to FULLWIDTH MACRON
    pub u007e_as_fullwidth_macron: bool,
    /// Convert U+00A5 to REVERSE SOLIDUS
    pub u00a5_as_yen_sign: bool,
}

impl Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorOptions {
    fn build_reverse_mappings(&self) -> HashMap<&'static str, &'static str> {
        let mut mappings = HashMap::new();

        if self.convert_gl {
            for (from, to) in JISX0201_GL_TABLE {
                mappings.insert(*to, *from);
            }

            // Apply GL overrides in reverse
            for (option_name, from, to) in JISX0201_GL_OVERRIDES {
                let should_apply = match *option_name {
                    "u005cAsYenSign" => self.u005c_as_yen_sign,
                    "u005cAsBackslash" => self.u005c_as_backslash,
                    "u007eAsFullwidthTilde" => self.u007e_as_fullwidth_tilde,
                    "u007eAsWaveDash" => self.u007e_as_wave_dash,
                    "u007eAsOverline" => self.u007e_as_overline,
                    "u007eAsFullwidthMacron" => self.u007e_as_fullwidth_macron,
                    "u00a5AsYenSign" => self.u00a5_as_yen_sign,
                    _ => false,
                };
                if should_apply {
                    mappings.insert(*to, *from);
                }
            }
        }

        if self.convert_gr {
            for (from, to) in JISX0201_GR_TABLE.iter() {
                mappings.insert(*to, *from);
            }
        }

        if self.convert_unsafe_specials {
            for (from, to) in SPECIAL_PUNCTUATIONS_TABLE {
                mappings.insert(*to, *from);
            }
        }

        mappings
    }

    fn build_voiced_reverse_mappings(
        &self,
    ) -> HashMap<&'static str, HashMap<&'static str, &'static str>> {
        let mut voiced_mappings = HashMap::new();

        if self.convert_gr && self.combine_voiced_sound_marks {
            for (from, to) in VOICED_LETTERS_TABLE.iter() {
                // Parse the two-character sequence (base + mark)
                let indices = to.char_indices().map(|(i, _)| i).collect::<Vec<_>>();
                if indices.len() == 2 {
                    let mark_str = &to[indices[1]..];
                    let base_str = &to[..indices[1]];
                    // Find the string slices for these characters
                    voiced_mappings
                        .entry(base_str)
                        .or_insert_with(HashMap::new)
                        .insert(mark_str, *from);
                }
            }
        }

        voiced_mappings
    }
}

impl CacheKeyGenerator for Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorOptions {
    fn generate_cache_key(&self) -> CacheKey {
        (
            self.convert_gl,
            self.convert_gr,
            self.convert_unsafe_specials,
            self.combine_voiced_sound_marks,
            self.u005c_as_yen_sign,
            self.u005c_as_backslash,
            self.u007e_as_fullwidth_tilde,
            self.u007e_as_wave_dash,
            self.u007e_as_overline,
            self.u007e_as_fullwidth_macron,
            self.u00a5_as_yen_sign,
        )
    }
}

#[derive(Debug, Clone)]
pub struct Jisx0201AndAlikeHalfwidthToFullwidthTransliterator(
    Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorOptions,
);

impl Transliterator for Jisx0201AndAlikeHalfwidthToFullwidthTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        chars: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mappings = get_rev_mappings(&self.0);
        let voiced_mappings = get_voiced_rev_mappings(&self.0);
        let mut result = Vec::new();
        let mut i = 0;

        while i < chars.len() {
            let char = chars[i];

            if char.c.is_empty() {
                // Preserve sentinel
                result.push(char);
                i += 1;
                continue;
            }

            // Check for voiced sound mark combination
            if self.0.combine_voiced_sound_marks && i + 1 < chars.len() {
                let next_char = chars[i + 1];
                if let Some(mark_mappings) = voiced_mappings.get(char.c.as_ref()) {
                    if let Some(&combined) = mark_mappings.get(next_char.c.as_ref()) {
                        let new_char =
                            pool.new_char_from(Cow::Borrowed(combined), char.offset, char);
                        result.push(new_char);
                        i += 2; // Skip both characters
                        continue;
                    }
                }
            }

            // Regular mapping
            if let Some(&mapped) = mappings.get(char.c.as_ref()) {
                let new_char = pool.new_char_from(Cow::Borrowed(mapped), char.offset, char);
                result.push(new_char);
            } else {
                result.push(char);
            }

            i += 1;
        }

        Ok(result)
    }
}

#[derive(Debug, Clone)]
pub struct Jisx0201AndAlikeFullwidthToHalfwidthTransliterator(
    Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorOptions,
);

impl Transliterator for Jisx0201AndAlikeFullwidthToHalfwidthTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        chars: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mappings = get_fwd_mappings(&self.0);
        let mut result = Vec::new();

        for &char in chars {
            if char.c.is_empty() {
                // Preserve sentinel
                result.push(char);
                continue;
            }

            if let Some(&mapped) = mappings.get(char.c.as_ref()) {
                let new_char = pool.new_char_from(Cow::Borrowed(mapped), char.offset, char);
                result.push(new_char);
            } else {
                result.push(char);
            }
        }

        Ok(result)
    }
}

pub struct Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorFactory(
    pub Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorOptions,
);

impl TransliteratorFactory for Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorFactory {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(
            Jisx0201AndAlikeHalfwidthToFullwidthTransliterator(self.0.clone()),
        ))
    }
}

pub struct Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorFactory(
    pub Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorOptions,
);

impl TransliteratorFactory for Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorFactory {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(
            Jisx0201AndAlikeFullwidthToHalfwidthTransliterator(self.0.clone()),
        ))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::char::from_chars;

    #[test]
    fn test_fullwidth_to_halfwidth_basic() {
        let options =
            Jisx0201AndAlikeTransliteratorOptions::default().build_fullwidth_to_halfwidth_options();
        let transliterator = Jisx0201AndAlikeFullwidthToHalfwidthTransliterator(options);
        let mut pool = CharPool::new();

        let test_cases = &[
            ("Ａ", "A"), // FULLWIDTH A -> A
            ("１", "1"), // FULLWIDTH 1 -> 1
            ("！", "!"), // FULLWIDTH ! -> !
            ("カ", "ｶ"), // KATAKANA KA -> HALFWIDTH KATAKANA KA
        ];

        for (input, expected) in test_cases {
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_halfwidth_to_fullwidth_basic() {
        let options = Jisx0201AndAlikeTransliteratorOptions::default();
        let transliterator = Jisx0201AndAlikeHalfwidthToFullwidthTransliterator(
            options.build_halfwidth_to_fullwidth_options(),
        );
        let mut pool = CharPool::new();

        let test_cases = &[
            ("A", "Ａ"), // A -> FULLWIDTH A
            ("1", "１"), // 1 -> FULLWIDTH 1
            ("!", "！"), // ! -> FULLWIDTH !
            ("ｶ", "カ"), // HALFWIDTH KATAKANA KA -> KATAKANA KA
        ];

        for (input, expected) in test_cases {
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_voiced_sound_marks() {
        let options = Jisx0201AndAlikeTransliteratorOptions {
            combine_voiced_sound_marks: true,
            ..Default::default()
        };
        let transliterator = Jisx0201AndAlikeFullwidthToHalfwidthTransliterator(
            options.build_fullwidth_to_halfwidth_options(),
        );
        let mut pool = CharPool::new();

        let test_cases = &[
            ("ガ", "ｶﾞ"), // GA -> KA + VOICED MARK
            ("パ", "ﾊﾟ"), // PA -> HA + SEMI-VOICED MARK
        ];

        for (input, expected) in test_cases {
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_hiragana_conversion() {
        let options = Jisx0201AndAlikeTransliteratorOptions {
            convert_hiraganas: true,
            ..Default::default()
        };
        let transliterator = Jisx0201AndAlikeFullwidthToHalfwidthTransliterator(
            options.build_fullwidth_to_halfwidth_options(),
        );
        let mut pool = CharPool::new();

        let test_cases = &[
            ("あ", "ｱ"), // HIRAGANA A -> HALFWIDTH KATAKANA A
            ("が", "ｶﾞ"), // HIRAGANA GA -> KA + VOICED MARK
        ];

        for (input, expected) in test_cases {
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_preserves_unmapped_characters() {
        let options = Jisx0201AndAlikeTransliteratorOptions::default();
        let transliterator = Jisx0201AndAlikeFullwidthToHalfwidthTransliterator(
            options.build_fullwidth_to_halfwidth_options(),
        );
        let mut pool = CharPool::new();

        let test_cases = &[
            ("漢", "漢"), // KANJI should be preserved
            ("🎌", "🎌"), // EMOJI should be preserved
        ];

        for (input, expected) in test_cases {
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_caching_functionality() {
        // Clear caches for clean test
        {
            let mut fwd_cache = FWD_MAPPINGS_CACHE.write().unwrap();
            let mut rev_cache = REV_MAPPINGS_CACHE.write().unwrap();
            fwd_cache.clear();
            rev_cache.clear();
        }

        // Create first instance with default options
        let options1 = Jisx0201AndAlikeTransliteratorOptions::default();
        let _mappings1 = get_fwd_mappings(&(&options1).into());
        let _rev_mappings1 = get_rev_mappings(&(&options1).into());

        let cache_sizes_1 = {
            let fwd_cache = FWD_MAPPINGS_CACHE.read().unwrap();
            let rev_cache = REV_MAPPINGS_CACHE.read().unwrap();
            (fwd_cache.len(), rev_cache.len())
        };

        // Create second instance with same options - should use cache
        let options2 = Jisx0201AndAlikeTransliteratorOptions::default();
        let _mappings2 = get_fwd_mappings(&(&options2).into());
        let _rev_mappings2 = get_rev_mappings(&(&options2).into());

        let cache_sizes_2 = {
            let fwd_cache = FWD_MAPPINGS_CACHE.read().unwrap();
            let rev_cache = REV_MAPPINGS_CACHE.read().unwrap();
            (fwd_cache.len(), rev_cache.len())
        };

        // Cache sizes should be the same for identical options
        assert_eq!(
            cache_sizes_1, cache_sizes_2,
            "Cache should not grow for identical options"
        );

        // Create third instance with different options - should create new cache entry
        let options3 = Jisx0201AndAlikeTransliteratorOptions {
            convert_hiraganas: true,
            ..Default::default()
        };
        let _mappings3 = get_fwd_mappings(&options3.build_fullwidth_to_halfwidth_options());
        let _rev_mappings3 = get_rev_mappings(&options3.build_halfwidth_to_fullwidth_options());

        let cache_sizes_3 = {
            let fwd_cache = FWD_MAPPINGS_CACHE.read().unwrap();
            let rev_cache = REV_MAPPINGS_CACHE.read().unwrap();
            (fwd_cache.len(), rev_cache.len())
        };

        // Create third instance with different options - should create new cache entry
        let options4 = Jisx0201AndAlikeTransliteratorOptions {
            combine_voiced_sound_marks: true,
            ..Default::default()
        };
        let _mappings4 = get_fwd_mappings(&options4.build_fullwidth_to_halfwidth_options());
        let _rev_mappings4 = get_rev_mappings(&options4.build_halfwidth_to_fullwidth_options());

        let cache_sizes_4 = {
            let fwd_cache = FWD_MAPPINGS_CACHE.read().unwrap();
            let rev_cache = REV_MAPPINGS_CACHE.read().unwrap();
            (fwd_cache.len(), rev_cache.len())
        };

        // Cache should grow for different options
        assert!(
            cache_sizes_3.0 > cache_sizes_2.0,
            "Forward cache should grow for different options"
        );
        assert!(
            cache_sizes_3.1 == cache_sizes_2.1,
            "Reverse cache shouldn't grow"
        );
        assert!(
            cache_sizes_4.0 == cache_sizes_3.0,
            "Forward cache shouldn't grow"
        );
        assert!(
            cache_sizes_4.1 == cache_sizes_3.1,
            "Reverse cache should grow for different options"
        );
    }

    #[test]
    fn test_jisx0201_halfwidth_to_fullwidth_factory() {
        let options = Jisx0201AndAlikeTransliteratorOptions::default();
        let factory = Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorFactory(
            options.build_halfwidth_to_fullwidth_options(),
        );
        let factory_result = factory.new_transliterator();
        assert!(factory_result.is_ok());

        let transliterator = factory_result.unwrap();

        // Test that it converts halfwidth to fullwidth
        let test_cases = &[("123", "１２３"), ("abc", "ａｂｃ"), ("!", "！"), ("", "")];

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
    fn test_jisx0201_fullwidth_to_halfwidth_factory() {
        let options = Jisx0201AndAlikeTransliteratorOptions::default();
        let factory = Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorFactory(
            options.build_fullwidth_to_halfwidth_options(),
        );
        let factory_result = factory.new_transliterator();
        assert!(factory_result.is_ok());

        let transliterator = factory_result.unwrap();

        // Test that it converts fullwidth to halfwidth
        let test_cases = &[("１２３", "123"), ("ａｂｃ", "abc"), ("！", "!"), ("", "")];

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
}
