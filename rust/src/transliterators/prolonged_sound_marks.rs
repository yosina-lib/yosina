use serde::{Deserialize, Serialize};
use std::borrow::Cow;

use crate::char::{Char, CharPool};
use crate::transliterator::{Transliterator, TransliteratorFactory};
use crate::{TransliterationError, TransliteratorFactoryError};

/// Character type flags for classifying Japanese characters
#[derive(Debug, Clone, Copy, PartialEq)]
struct CharType(u8);

impl CharType {
    const OTHER: CharType = CharType(0x00);
    const HIRAGANA: CharType = CharType(0x20);
    const KATAKANA: CharType = CharType(0x40);
    const ALPHABET: CharType = CharType(0x60);
    const DIGIT: CharType = CharType(0x80);
    const EITHER: CharType = CharType(0xa0);

    const HALFWIDTH: CharType = CharType(1 << 0);
    const VOWEL_ENDED: CharType = CharType(1 << 1);
    const HATSUON: CharType = CharType(1 << 2);
    const SOKUON: CharType = CharType(1 << 3);
    const PROLONGED_SOUND_MARK: CharType = CharType(1 << 4);

    // Compound types
    const HALFWIDTH_DIGIT: CharType = CharType(Self::DIGIT.0 | Self::HALFWIDTH.0);
    const FULLWIDTH_DIGIT: CharType = CharType(Self::DIGIT.0);
    const HALFWIDTH_ALPHABET: CharType = CharType(Self::ALPHABET.0 | Self::HALFWIDTH.0);
    const FULLWIDTH_ALPHABET: CharType = CharType(Self::ALPHABET.0);
    const ORDINARY_HIRAGANA: CharType = CharType(Self::HIRAGANA.0 | Self::VOWEL_ENDED.0);
    const ORDINARY_KATAKANA: CharType = CharType(Self::KATAKANA.0 | Self::VOWEL_ENDED.0);
    const ORDINARY_HALFWIDTH_KATAKANA: CharType =
        CharType(Self::KATAKANA.0 | Self::VOWEL_ENDED.0 | Self::HALFWIDTH.0);

    fn is_alnum(&self) -> bool {
        let masked = self.0 & 0xe0;
        masked == CharType::ALPHABET.0 || masked == CharType::DIGIT.0
    }

    fn is_halfwidth(&self) -> bool {
        self.0 & CharType::HALFWIDTH.0 != 0
    }

    /// Special character mappings for character type detection
    fn get_special_char_type(codepoint: u32) -> Option<Self> {
        match codepoint {
            0xff70 => {
                Some(CharType::KATAKANA | CharType::PROLONGED_SOUND_MARK | CharType::HALFWIDTH)
            }
            0x30fc => Some(CharType::EITHER | CharType::PROLONGED_SOUND_MARK),
            0x3063 => Some(CharType::HIRAGANA | CharType::SOKUON),
            0x3093 => Some(CharType::HIRAGANA | CharType::HATSUON),
            0x30c3 => Some(CharType::KATAKANA | CharType::SOKUON),
            0x30f3 => Some(CharType::KATAKANA | CharType::HATSUON),
            0xff6f => Some(CharType::KATAKANA | CharType::SOKUON | CharType::HALFWIDTH),
            0xff9d => Some(CharType::KATAKANA | CharType::HATSUON | CharType::HALFWIDTH),
            _ => None,
        }
    }

    /// Determine the character type for a given Unicode codepoint
    fn from_codepoint(codepoint: u32) -> Self {
        // Check digits
        if (0x30..=0x39).contains(&codepoint) {
            return CharType::HALFWIDTH_DIGIT;
        }
        if (0xff10..=0xff19).contains(&codepoint) {
            return CharType::FULLWIDTH_DIGIT;
        }

        // Check alphabet
        if (0x41..=0x5a).contains(&codepoint) || (0x61..=0x7a).contains(&codepoint) {
            return CharType::HALFWIDTH_ALPHABET;
        }
        if (0xff21..=0xff3a).contains(&codepoint) || (0xff41..=0xff5a).contains(&codepoint) {
            return CharType::FULLWIDTH_ALPHABET;
        }

        // Check special characters
        if let Some(special_type) = Self::get_special_char_type(codepoint) {
            return special_type;
        }

        // Check hiragana
        if (0x3041..=0x309c).contains(&codepoint) || codepoint == 0x309f {
            return CharType::ORDINARY_HIRAGANA;
        }

        // Check katakana
        if (0x30a1..=0x30fa).contains(&codepoint) || (0x30fd..=0x30ff).contains(&codepoint) {
            return CharType::ORDINARY_KATAKANA;
        }

        // Check halfwidth katakana
        if (0xff66..=0xff6f).contains(&codepoint) || (0xff71..=0xff9f).contains(&codepoint) {
            return CharType::ORDINARY_HALFWIDTH_KATAKANA;
        }

        CharType::OTHER
    }
}

impl std::ops::BitOr for CharType {
    type Output = CharType;

    fn bitor(self, rhs: CharType) -> CharType {
        CharType(self.0 | rhs.0)
    }
}

impl std::ops::BitOrAssign for CharType {
    fn bitor_assign(&mut self, rhs: CharType) {
        self.0 |= rhs.0;
    }
}

/// Options for the prolonged sound marks transliterator
#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub struct ProlongedSoundMarksTransliteratorOptions {
    /// Skip characters that have already been transliterated
    #[serde(default)]
    pub skip_already_transliterated_chars: bool,

    /// Allow prolonged hatsuon (ん/ン) characters
    #[serde(default)]
    pub allow_prolonged_hatsuon: bool,

    /// Allow prolonged sokuon (っ/ッ) characters
    #[serde(default)]
    pub allow_prolonged_sokuon: bool,

    /// Replace prolonged voice marks following an alphanumeric
    #[serde(default)]
    pub replace_prolonged_marks_following_alnums: bool,
}

#[derive(Debug, Clone)]
pub struct ProlongedSoundMarksTransliterator {
    options: ProlongedSoundMarksTransliteratorOptions,
    prolongables: CharType,
}

impl ProlongedSoundMarksTransliterator {
    pub fn new(options: ProlongedSoundMarksTransliteratorOptions) -> Self {
        let mut prolongables = CharType::VOWEL_ENDED | CharType::PROLONGED_SOUND_MARK;

        if options.allow_prolonged_hatsuon {
            prolongables |= CharType::HATSUON;
        }
        if options.allow_prolonged_sokuon {
            prolongables |= CharType::SOKUON;
        }

        Self {
            options,
            prolongables,
        }
    }

    /// Check if a character is a prolonged sound mark or dash
    fn is_prolonged_mark(c: &str) -> bool {
        matches!(
            c,
            "\u{002D}" | // HYPHEN-MINUS
            "\u{2010}" | // HYPHEN
            "\u{2014}" | // EM DASH
            "\u{2015}" | // HORIZONTAL BAR
            "\u{2212}" | // MINUS SIGN
            "\u{FF0D}" | // FULLWIDTH HYPHEN-MINUS
            "\u{FF70}" | // HALFWIDTH KATAKANA PROLONGED SOUND MARK
            "\u{30FC}" // KATAKANA PROLONGED SOUND MARK
        )
    }
}

impl Transliterator for ProlongedSoundMarksTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        chars: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mut result = Vec::new();
        let mut lookahead_buf: Vec<&'a Char<'a, 'b>> = Vec::new();
        let mut last_non_prolonged_char: Option<(&'a Char<'a, 'b>, CharType)> = None;
        let mut processed_chars_in_lookahead = false;
        let mut offset = 0;

        for &current_char in chars {
            // Skip sentinel characters
            if current_char.c.is_empty() {
                result.push(current_char);
                continue;
            }

            // Handle lookahead buffer - when we've accumulated potential prolonged marks
            if !lookahead_buf.is_empty() {
                if Self::is_prolonged_mark(current_char.c.as_ref()) {
                    // Continue accumulating prolonged marks
                    if current_char.source.is_some() {
                        processed_chars_in_lookahead = true;
                    }
                    lookahead_buf.push(current_char);
                } else {
                    // Process the accumulated lookahead buffer
                    let prev_non_prolonged_char = last_non_prolonged_char;
                    let current_codepoint = current_char.c.chars().next().unwrap() as u32;
                    let current_char_type = CharType::from_codepoint(current_codepoint);
                    last_non_prolonged_char = Some((current_char, current_char_type));

                    if (prev_non_prolonged_char.is_none()
                        || prev_non_prolonged_char.unwrap().1.is_alnum())
                        && (!self.options.skip_already_transliterated_chars
                            || !processed_chars_in_lookahead)
                    {
                        let replacement = if match prev_non_prolonged_char {
                            Some(c) => c.1.is_halfwidth(),
                            None => current_char_type.is_halfwidth(),
                        } {
                            "\u{002D}" // HYPHEN-MINUS
                        } else {
                            "\u{FF0D}" // FULLWIDTH HYPHEN-MINUS
                        };

                        // Replace all marks in lookahead buffer with the chosen replacement
                        for &lookahead_char in &lookahead_buf {
                            let new_char = pool.new_char_from(
                                Cow::Borrowed(replacement),
                                offset,
                                lookahead_char,
                            );
                            offset += replacement.len();
                            result.push(new_char);
                        }
                    } else {
                        // Not between alphanumeric characters - preserve original
                        for &lookahead_char in &lookahead_buf {
                            let new_char = pool.new_with_offset(lookahead_char, offset);
                            offset += lookahead_char.c.len();
                            result.push(new_char);
                        }
                    }
                    lookahead_buf.clear();
                    result.push(current_char);
                    processed_chars_in_lookahead = false;
                }
                continue;
            }

            // Check if current character is a prolonged mark
            if Self::is_prolonged_mark(current_char.c.as_ref()) {
                // Check if we should process this prolonged mark
                let should_process = !self.options.skip_already_transliterated_chars
                    || current_char.source.is_none();
                if should_process {
                    if let Some(last_non_prolonged_char) = last_non_prolonged_char {
                        let (_last_char, last_char_type) = last_non_prolonged_char;
                        // Check if character is suitable for prolonged sound mark replacement
                        if (self.prolongables.0 & last_char_type.0) != 0 {
                            // Japanese character that can be prolonged
                            let replacement = if last_char_type.is_halfwidth() {
                                "\u{FF70}" // HALFWIDTH KATAKANA PROLONGED SOUND MARK
                            } else {
                                "\u{30FC}" // KATAKANA PROLONGED SOUND MARK
                            };

                            let nc = pool.new_char_from(
                                Cow::Borrowed(replacement),
                                offset,
                                current_char,
                            );
                            offset += replacement.len();
                            result.push(nc);
                            continue;
                        } else {
                            // Not a Japanese character
                            if self.options.replace_prolonged_marks_following_alnums
                                && last_char_type.is_alnum()
                            {
                                lookahead_buf.push(current_char);
                                continue;
                            }
                        }
                    }
                }
            } else {
                // Regular character - update last non-prolonged character
                let codepoint = current_char.c.chars().next().unwrap() as u32;
                let char_type = CharType::from_codepoint(codepoint);
                last_non_prolonged_char = Some((current_char, char_type));
            }

            // Default: preserve the original character
            result.push(pool.new_with_offset(current_char, offset));
        }

        Ok(result)
    }
}

impl TransliteratorFactory for ProlongedSoundMarksTransliteratorOptions {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(ProlongedSoundMarksTransliterator::new(
            self.clone(),
        )))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::char::{from_chars, CharPool};

    #[test]
    fn test_basic_prolonged_sound_replacement() {
        let options = ProlongedSoundMarksTransliteratorOptions::default();
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test basic hiragana prolonged sound replacement
        let input_chars = pool.build_char_array("かー");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should replace ー with ー (normalized prolonged sound mark)
        assert_eq!(result.len(), 3); // か + ー + sentinel
        assert_eq!(result[0].c, "か");
        assert_eq!(result[1].c, "\u{30FC}"); // KATAKANA PROLONGED SOUND MARK
        assert!(result[2].c.is_empty()); // sentinel
    }

    #[test]
    fn test_katakana_prolonged_sound_replacement() {
        let options = ProlongedSoundMarksTransliteratorOptions::default();
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test katakana prolonged sound replacement
        let input_chars = pool.build_char_array("カー");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 3);
        assert_eq!(result[0].c, "カ");
        assert_eq!(result[1].c, "\u{30FC}"); // KATAKANA PROLONGED SOUND MARK
        assert!(result[2].c.is_empty()); // sentinel
    }

    #[test]
    fn test_halfwidth_katakana_prolonged_sound() {
        let options = ProlongedSoundMarksTransliteratorOptions::default();
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test halfwidth katakana - should use halfwidth prolonged mark
        let input_chars = pool.build_char_array("ｶｰ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 3);
        assert_eq!(result[0].c, "ｶ");
        assert_eq!(result[1].c, "\u{FF70}"); // HALFWIDTH KATAKANA PROLONGED SOUND MARK
        assert!(result[2].c.is_empty()); // sentinel
    }

    #[test]
    fn test_hyphen_replacement_between_alphabet() {
        let options = ProlongedSoundMarksTransliteratorOptions {
            replace_prolonged_marks_following_alnums: true,
            ..Default::default()
        };
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test hyphen between alphabetic characters
        let input_chars = pool.build_char_array("a-b");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 4);
        assert_eq!(result[0].c, "a");
        assert_eq!(result[1].c, "\u{002D}"); // HYPHEN-MINUS (halfwidth)
        assert_eq!(result[2].c, "b");
        assert!(result[3].c.is_empty()); // sentinel
    }

    #[test]
    fn test_em_dash_replacement_between_fullwidth() {
        let options = ProlongedSoundMarksTransliteratorOptions {
            replace_prolonged_marks_following_alnums: true,
            ..Default::default()
        };
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test em dash between fullwidth characters
        let input_chars = pool.build_char_array("ａ—ｂ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 4);
        assert_eq!(result[0].c, "ａ");
        assert_eq!(result[1].c, "\u{FF0D}"); // FULLWIDTH HYPHEN-MINUS
        assert_eq!(result[2].c, "ｂ");
        assert!(result[3].c.is_empty()); // sentinel
    }

    #[test]
    fn test_allow_prolonged_hatsuon() {
        let options = ProlongedSoundMarksTransliteratorOptions {
            allow_prolonged_hatsuon: true,
            ..Default::default()
        };
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test prolonged hatsuon (ん)
        let input_chars = pool.build_char_array("んー");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 3);
        assert_eq!(result[0].c, "ん");
        assert_eq!(result[1].c, "\u{30FC}"); // Should be replaced
        assert!(result[2].c.is_empty()); // sentinel
    }

    #[test]
    fn test_allow_prolonged_sokuon() {
        let options = ProlongedSoundMarksTransliteratorOptions {
            allow_prolonged_sokuon: true,
            ..Default::default()
        };
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test prolonged sokuon (っ)
        let input_chars = pool.build_char_array("っー");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 3);
        assert_eq!(result[0].c, "っ");
        assert_eq!(result[1].c, "\u{30FC}"); // Should be replaced
        assert!(result[2].c.is_empty()); // sentinel
    }

    #[test]
    fn test_no_replacement_for_non_japanese() {
        let options = ProlongedSoundMarksTransliteratorOptions::default();
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test that non-Japanese characters don't trigger replacement
        let input_chars = pool.build_char_array("x-y");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should preserve original hyphen
        assert_eq!(result.len(), 4);
        assert_eq!(result[0].c, "x");
        assert_eq!(result[1].c, "-"); // Original hyphen preserved
        assert_eq!(result[2].c, "y");
        assert!(result[3].c.is_empty()); // sentinel
    }

    #[test]
    fn test_multiple_dashes_replacement() {
        let options = ProlongedSoundMarksTransliteratorOptions {
            replace_prolonged_marks_following_alnums: true,
            ..Default::default()
        };
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test multiple consecutive dashes
        let input_chars = pool.build_char_array("a--b");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 5);
        assert_eq!(result[0].c, "a");
        assert_eq!(result[1].c, "\u{002D}"); // Both dashes should be replaced
        assert_eq!(result[2].c, "\u{002D}");
        assert_eq!(result[3].c, "b");
        assert!(result[4].c.is_empty()); // sentinel
    }

    #[test]
    fn test_skip_already_transliterated() {
        let options = ProlongedSoundMarksTransliteratorOptions {
            skip_already_transliterated_chars: true,
            ..Default::default()
        };
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Create a character that has a source (already transliterated)
        let input_chars = pool.build_char_array("か");
        let source_char = input_chars[0];

        // Create a new character with a dash that has source tracking
        let dash_char = pool.new_char_from(Cow::Borrowed("-"), 1, source_char);

        let chars_with_source = vec![source_char, dash_char, input_chars[1]]; // include sentinel
        let result = transliterator
            .transliterate(&mut pool, &chars_with_source)
            .unwrap();

        // The dash should not be processed because it has source tracking
        assert_eq!(result.len(), 3);
        assert_eq!(result[0].c, "か");
        assert_eq!(result[1].c, "-"); // Should be preserved
        assert!(result[2].c.is_empty()); // sentinel
    }

    #[test]
    fn test_mixed_script_text() {
        let options = ProlongedSoundMarksTransliteratorOptions::default();
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test mixed Japanese and non-Japanese text
        let input_chars = pool.build_char_array("コーヒー");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 5); // コ + ー + ヒ + ー + sentinel
        assert_eq!(result[0].c, "コ");
        assert_eq!(result[1].c, "\u{30FC}"); // First prolonged mark
        assert_eq!(result[2].c, "ヒ");
        assert_eq!(result[3].c, "\u{30FC}"); // Second prolonged mark
        assert!(result[4].c.is_empty()); // sentinel
    }

    #[test]
    fn test_no_replacement_without_preceding_char() {
        let options = ProlongedSoundMarksTransliteratorOptions::default();
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test dash at beginning - should not be replaced
        let input_chars = pool.build_char_array("-か");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 3);
        assert_eq!(result[0].c, "-"); // Should be preserved
        assert_eq!(result[1].c, "か");
        assert!(result[2].c.is_empty()); // sentinel
    }

    #[test]
    fn test_character_type_detection() {
        // Test various character type detections
        assert_eq!(
            CharType::from_codepoint('a' as u32),
            CharType::HALFWIDTH_ALPHABET
        );
        assert_eq!(
            CharType::from_codepoint('ａ' as u32),
            CharType::FULLWIDTH_ALPHABET
        );
        assert_eq!(
            CharType::from_codepoint('1' as u32),
            CharType::HALFWIDTH_DIGIT
        );
        assert_eq!(
            CharType::from_codepoint('１' as u32),
            CharType::FULLWIDTH_DIGIT
        );
        assert_eq!(
            CharType::from_codepoint('あ' as u32),
            CharType::ORDINARY_HIRAGANA
        );
        assert_eq!(
            CharType::from_codepoint('ア' as u32),
            CharType::ORDINARY_KATAKANA
        );
        assert_eq!(
            CharType::from_codepoint('ｱ' as u32),
            CharType::ORDINARY_HALFWIDTH_KATAKANA
        );

        // Test special characters
        assert_eq!(
            CharType::from_codepoint(0x30fc),
            CharType::EITHER | CharType::PROLONGED_SOUND_MARK
        );
        assert_eq!(
            CharType::from_codepoint(0xff70),
            CharType::KATAKANA | CharType::PROLONGED_SOUND_MARK | CharType::HALFWIDTH
        );
        assert_eq!(
            CharType::from_codepoint(0x3093),
            CharType::HIRAGANA | CharType::HATSUON
        );
        assert_eq!(
            CharType::from_codepoint(0x3063),
            CharType::HIRAGANA | CharType::SOKUON
        );
    }

    #[test]
    fn test_fullwidth_hyphen_replacement_in_katakana() {
        let options = ProlongedSoundMarksTransliteratorOptions::default();
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test case 1: イ－ハト－ヴォ with fullwidth hyphen-minus
        let input_chars = pool.build_char_array("イ\u{FF0D}ハト\u{FF0D}ヴォ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 8); // イ + ー + ハ + ト + ー + ヴ + ォ + sentinel
        assert_eq!(result[0].c, "イ");
        assert_eq!(result[1].c, "\u{30FC}"); // Should be replaced with prolonged sound mark
        assert_eq!(result[2].c, "ハ");
        assert_eq!(result[3].c, "ト");
        assert_eq!(result[4].c, "\u{30FC}"); // Should be replaced with prolonged sound mark
        assert_eq!(result[5].c, "ヴ");
        assert_eq!(result[6].c, "ォ");
        assert!(result[7].c.is_empty()); // sentinel

        // Test case 2: カトラリ－ with fullwidth hyphen-minus at end
        let input_chars2 = pool.build_char_array("カトラリ\u{FF0D}");
        let result2 = transliterator
            .transliterate(&mut pool, &input_chars2)
            .unwrap();

        assert_eq!(result2.len(), 6); // カ + ト + ラ + リ + ー + sentinel
        assert_eq!(result2[0].c, "カ");
        assert_eq!(result2[1].c, "ト");
        assert_eq!(result2[2].c, "ラ");
        assert_eq!(result2[3].c, "リ");
        assert_eq!(result2[4].c, "\u{30FC}"); // Should be replaced with prolonged sound mark
        assert!(result2[5].c.is_empty()); // sentinel
    }

    #[test]
    fn test_hyphen_minus_replacement_in_katakana() {
        let options = ProlongedSoundMarksTransliteratorOptions::default();
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test case 1: イ-ハト-ヴォ with regular hyphen-minus
        let input_chars = pool.build_char_array("イ\u{002D}ハト\u{002D}ヴォ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        assert_eq!(result.len(), 8);
        assert_eq!(result[0].c, "イ");
        assert_eq!(result[1].c, "\u{30FC}"); // Should be replaced with prolonged sound mark
        assert_eq!(result[2].c, "ハ");
        assert_eq!(result[3].c, "ト");
        assert_eq!(result[4].c, "\u{30FC}"); // Should be replaced with prolonged sound mark
        assert_eq!(result[5].c, "ヴ");
        assert_eq!(result[6].c, "ォ");
        assert!(result[7].c.is_empty()); // sentinel

        // Test case 2: カトラリ- with regular hyphen-minus at end
        let input_chars2 = pool.build_char_array("カトラリ\u{002D}");
        let result2 = transliterator
            .transliterate(&mut pool, &input_chars2)
            .unwrap();

        assert_eq!(result2.len(), 6);
        assert_eq!(result2[0].c, "カ");
        assert_eq!(result2[1].c, "ト");
        assert_eq!(result2[2].c, "ラ");
        assert_eq!(result2[3].c, "リ");
        assert_eq!(result2[4].c, "\u{30FC}"); // Should be replaced with prolonged sound mark
        assert!(result2[5].c.is_empty()); // sentinel
    }

    #[test]
    fn test_prolonged_marks_following_digits_no_replacement() {
        let options = ProlongedSoundMarksTransliteratorOptions::default();
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test with replace_prolonged_marks_following_alnums disabled (default)
        let input_chars = pool.build_char_array("1\u{30FC}\u{FF0D}2\u{30FC}3");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should preserve all characters as-is
        assert_eq!(result.len(), 7);
        assert_eq!(result[0].c, "1");
        assert_eq!(result[1].c, "\u{30FC}");
        assert_eq!(result[2].c, "\u{FF0D}");
        assert_eq!(result[3].c, "2");
        assert_eq!(result[4].c, "\u{30FC}");
        assert_eq!(result[5].c, "3");
        assert!(result[6].c.is_empty()); // sentinel
    }

    #[test]
    fn test_prolonged_marks_following_digits_with_replacement() {
        let options = ProlongedSoundMarksTransliteratorOptions {
            replace_prolonged_marks_following_alnums: true,
            ..Default::default()
        };
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test with replace_prolonged_marks_following_alnums enabled
        let input_chars = pool.build_char_array("1\u{30FC}\u{FF0D}2\u{30FC}3");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should replace prolonged marks with hyphens between digits
        assert_eq!(result.len(), 7);
        assert_eq!(result[0].c, "1");
        assert_eq!(result[1].c, "\u{002D}"); // Replaced with halfwidth hyphen
        assert_eq!(result[2].c, "\u{002D}"); // Replaced with halfwidth hyphen
        assert_eq!(result[3].c, "2");
        assert_eq!(result[4].c, "\u{002D}"); // Replaced with halfwidth hyphen
        assert_eq!(result[5].c, "3");
        assert!(result[6].c.is_empty()); // sentinel
    }

    #[test]
    fn test_prolonged_marks_following_fullwidth_digits_with_replacement() {
        let options = ProlongedSoundMarksTransliteratorOptions {
            replace_prolonged_marks_following_alnums: true,
            ..Default::default()
        };
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test with fullwidth digits
        let input_chars = pool.build_char_array("\u{FF11}\u{30FC}\u{FF0D}\u{FF12}\u{30FC}\u{FF13}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should replace prolonged marks with fullwidth hyphens between fullwidth digits
        assert_eq!(result.len(), 7);
        assert_eq!(result[0].c, "\u{FF11}"); // Fullwidth 1
        assert_eq!(result[1].c, "\u{FF0D}"); // Replaced with fullwidth hyphen
        assert_eq!(result[2].c, "\u{FF0D}"); // Already fullwidth hyphen
        assert_eq!(result[3].c, "\u{FF12}"); // Fullwidth 2
        assert_eq!(result[4].c, "\u{FF0D}"); // Replaced with fullwidth hyphen
        assert_eq!(result[5].c, "\u{FF13}"); // Fullwidth 3
        assert!(result[6].c.is_empty()); // sentinel
    }

    #[test]
    fn test_sokuon_without_allow_prolonged() {
        let options = ProlongedSoundMarksTransliteratorOptions::default();
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test sokuon (っ) without allow_prolonged_sokuon
        let input_chars = pool.build_char_array("ウッ\u{FF0D}ウン\u{FF0D}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should not replace after sokuon
        assert_eq!(result.len(), 7);
        assert_eq!(result[0].c, "ウ");
        assert_eq!(result[1].c, "ッ");
        assert_eq!(result[2].c, "\u{FF0D}"); // Should remain as fullwidth hyphen
        assert_eq!(result[3].c, "ウ");
        assert_eq!(result[4].c, "ン");
        assert_eq!(result[5].c, "\u{FF0D}"); // Should remain as fullwidth hyphen
    }

    #[test]
    fn test_sokuon_with_allow_prolonged() {
        let options = ProlongedSoundMarksTransliteratorOptions {
            allow_prolonged_sokuon: true,
            ..Default::default()
        };
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test sokuon (っ) with allow_prolonged_sokuon
        let input_chars = pool.build_char_array("ウッ\u{FF0D}ウン\u{FF0D}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should replace after sokuon but not after hatsuon
        assert_eq!(result.len(), 7);
        assert_eq!(result[0].c, "ウ");
        assert_eq!(result[1].c, "ッ");
        assert_eq!(result[2].c, "\u{30FC}"); // Should be replaced with prolonged mark
        assert_eq!(result[3].c, "ウ");
        assert_eq!(result[4].c, "ン");
        assert_eq!(result[5].c, "\u{FF0D}"); // Should remain as fullwidth hyphen
    }

    #[test]
    fn test_hatsuon_with_allow_prolonged() {
        let options = ProlongedSoundMarksTransliteratorOptions {
            allow_prolonged_hatsuon: true,
            ..Default::default()
        };
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test hatsuon (ン) with allow_prolonged_hatsuon
        let input_chars = pool.build_char_array("ウッ\u{FF0D}ウン\u{FF0D}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should not replace after sokuon but should replace after hatsuon
        assert_eq!(result.len(), 7);
        assert_eq!(result[0].c, "ウ");
        assert_eq!(result[1].c, "ッ");
        assert_eq!(result[2].c, "\u{FF0D}"); // Should remain as fullwidth hyphen
        assert_eq!(result[3].c, "ウ");
        assert_eq!(result[4].c, "ン");
        assert_eq!(result[5].c, "\u{30FC}"); // Should be replaced with prolonged mark
    }

    #[test]
    fn test_both_sokuon_and_hatsuon_allowed() {
        let options = ProlongedSoundMarksTransliteratorOptions {
            allow_prolonged_sokuon: true,
            allow_prolonged_hatsuon: true,
            ..Default::default()
        };
        let transliterator = ProlongedSoundMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Test with both options enabled
        let input_chars = pool.build_char_array("ウッ\u{FF0D}ウン\u{FF0D}");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Should replace after both sokuon and hatsuon
        assert_eq!(result.len(), 7);
        assert_eq!(result[0].c, "ウ");
        assert_eq!(result[1].c, "ッ");
        assert_eq!(result[2].c, "\u{30FC}"); // Should be replaced with prolonged mark
        assert_eq!(result[3].c, "ウ");
        assert_eq!(result[4].c, "ン");
        assert_eq!(result[5].c, "\u{30FC}"); // Should be replaced with prolonged mark
    }

    #[test]
    fn test_prolonged_sound_marks_factory() {
        let options = ProlongedSoundMarksTransliteratorOptions::default();
        let factory_result = options.new_transliterator();
        assert!(factory_result.is_ok());

        let transliterator = factory_result.unwrap();

        // Test that it preserves input (since it's a stub implementation)
        let test_cases = &[
            ("おかあさん", "おかあさん"),
            ("ラーメン", "ラーメン"),
            ("スーパー", "スーパー"),
            ("", ""),
        ];

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
