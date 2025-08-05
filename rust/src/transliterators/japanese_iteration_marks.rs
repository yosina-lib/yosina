use serde::{Deserialize, Serialize};
use std::borrow::Cow;
use std::collections::HashSet;

use crate::char::{Char, CharPool};
use crate::transliterator::{Transliterator, TransliteratorFactory};
use crate::{TransliterationError, TransliteratorFactoryError};

/// Iteration mark characters
const HIRAGANA_ITERATION_MARK: char = '\u{309d}'; // ゝ
const HIRAGANA_VOICED_ITERATION_MARK: char = '\u{309e}'; // ゞ
const KATAKANA_ITERATION_MARK: char = '\u{30fd}'; // ヽ
const KATAKANA_VOICED_ITERATION_MARK: char = '\u{30fe}'; // ヾ
const KANJI_ITERATION_MARK: char = '\u{3005}'; // 々
                                               // Vertical iteration mark characters
const VERTICAL_HIRAGANA_ITERATION_MARK: char = '\u{3031}'; // 〱
const VERTICAL_HIRAGANA_VOICED_ITERATION_MARK: char = '\u{3032}'; // 〲
const VERTICAL_KATAKANA_ITERATION_MARK: char = '\u{3033}'; // 〳
const VERTICAL_KATAKANA_VOICED_ITERATION_MARK: char = '\u{3034}'; // 〴

/// Character type for classifying Japanese characters
#[derive(Debug, Clone, Copy, PartialEq)]
enum CharType {
    Other,
    Hiragana,
    Katakana,
    Kanji,
    Voiced,
    SemiVoiced,
    Hatsuon,
    Sokuon,
}

/// Options for the Japanese iteration marks transliterator
#[derive(Debug, Default, Clone, PartialEq, Deserialize, Serialize)]
pub struct JapaneseIterationMarksTransliteratorOptions {
    // Currently no options, but keeping structure for consistency and future extensibility
}

#[derive(Debug, Clone)]
pub struct JapaneseIterationMarksTransliterator {
    _options: JapaneseIterationMarksTransliteratorOptions,
}

impl JapaneseIterationMarksTransliterator {
    pub fn new(options: JapaneseIterationMarksTransliteratorOptions) -> Self {
        Self { _options: options }
    }

    /// Check if a character is an iteration mark
    fn is_iteration_mark(c: char) -> bool {
        matches!(
            c,
            HIRAGANA_ITERATION_MARK
                | HIRAGANA_VOICED_ITERATION_MARK
                | KATAKANA_ITERATION_MARK
                | KATAKANA_VOICED_ITERATION_MARK
                | KANJI_ITERATION_MARK
                | VERTICAL_HIRAGANA_ITERATION_MARK
                | VERTICAL_HIRAGANA_VOICED_ITERATION_MARK
                | VERTICAL_KATAKANA_ITERATION_MARK
                | VERTICAL_KATAKANA_VOICED_ITERATION_MARK
        )
    }

    /// Get the character type for a given character
    fn get_char_type(c: char) -> CharType {
        // Hatsuon (ん/ン)
        if c == 'ん' || c == 'ン' {
            return CharType::Hatsuon;
        }

        // Sokuon (っ/ッ)
        if c == 'っ' || c == 'ッ' {
            return CharType::Sokuon;
        }

        // Check if voiced
        if Self::is_voiced_char(c) {
            return CharType::Voiced;
        }

        // Check if semi-voiced
        if Self::is_semi_voiced_char(c) {
            return CharType::SemiVoiced;
        }

        // Hiragana range (excluding small characters and special marks)
        if ('\u{3041}'..='\u{3096}').contains(&c) {
            return CharType::Hiragana;
        }

        // Katakana range (excluding small characters and special marks)
        if ('\u{30a1}'..='\u{30fa}').contains(&c) {
            return CharType::Katakana;
        }

        // Halfwidth katakana range
        if ('\u{ff66}'..='\u{ff9f}').contains(&c) {
            return CharType::Katakana;
        }

        // CJK Unified Ideographs (common kanji range)
        if ('\u{4e00}'..='\u{9fff}').contains(&c)
            || ('\u{3400}'..='\u{4dbf}').contains(&c)
            || ('\u{20000}'..='\u{2a6df}').contains(&c)
            || ('\u{2a700}'..='\u{2b73f}').contains(&c)
            || ('\u{2b740}'..='\u{2b81f}').contains(&c)
            || ('\u{2b820}'..='\u{2ceaf}').contains(&c)
            || ('\u{2ceb0}'..='\u{2ebef}').contains(&c)
            || ('\u{30000}'..='\u{3134f}').contains(&c)
        {
            return CharType::Kanji;
        }

        CharType::Other
    }

    /// Check if a character is voiced (has dakuten)
    fn is_voiced_char(c: char) -> bool {
        // Lazy static to compute voiced chars once
        use std::sync::OnceLock;
        static VOICED_CHARS: OnceLock<HashSet<char>> = OnceLock::new();

        let voiced = VOICED_CHARS.get_or_init(|| {
            let mut set = HashSet::new();
            // Add all voiced characters from the voicing mappings
            for &voiced_char in [
                // From hiragana voicing
                'が', 'ぎ', 'ぐ', 'げ', 'ご', 'ざ', 'じ', 'ず', 'ぜ', 'ぞ', 'だ', 'ぢ', 'づ', 'で',
                'ど', 'ば', 'び', 'ぶ', 'べ', 'ぼ', // From katakana voicing
                'ガ', 'ギ', 'グ', 'ゲ', 'ゴ', 'ザ', 'ジ', 'ズ', 'ゼ', 'ゾ', 'ダ', 'ヂ', 'ヅ', 'デ',
                'ド', 'バ', 'ビ', 'ブ', 'ベ', 'ボ', 'ヴ',
            ]
            .iter()
            {
                set.insert(voiced_char);
            }
            set
        });

        voiced.contains(&c)
    }

    /// Check if a character is semi-voiced (has handakuten)
    fn is_semi_voiced_char(c: char) -> bool {
        matches!(
            c,
            // Hiragana semi-voiced
            'ぱ' | 'ぴ' | 'ぷ' | 'ぺ' | 'ぽ'
                // Katakana semi-voiced
                | 'パ' | 'ピ' | 'プ' | 'ペ' | 'ポ'
        )
    }

    /// Apply voicing to a hiragana character if possible
    fn voice_hiragana(c: char) -> Option<char> {
        match c {
            'か' => Some('が'),
            'き' => Some('ぎ'),
            'く' => Some('ぐ'),
            'け' => Some('げ'),
            'こ' => Some('ご'),
            'さ' => Some('ざ'),
            'し' => Some('じ'),
            'す' => Some('ず'),
            'せ' => Some('ぜ'),
            'そ' => Some('ぞ'),
            'た' => Some('だ'),
            'ち' => Some('ぢ'),
            'つ' => Some('づ'),
            'て' => Some('で'),
            'と' => Some('ど'),
            'は' => Some('ば'),
            'ひ' => Some('び'),
            'ふ' => Some('ぶ'),
            'へ' => Some('べ'),
            'ほ' => Some('ぼ'),
            _ => None,
        }
    }

    /// Apply voicing to a katakana character if possible
    fn voice_katakana(c: char) -> Option<char> {
        match c {
            'カ' => Some('ガ'),
            'キ' => Some('ギ'),
            'ク' => Some('グ'),
            'ケ' => Some('ゲ'),
            'コ' => Some('ゴ'),
            'サ' => Some('ザ'),
            'シ' => Some('ジ'),
            'ス' => Some('ズ'),
            'セ' => Some('ゼ'),
            'ソ' => Some('ゾ'),
            'タ' => Some('ダ'),
            'チ' => Some('ヂ'),
            'ツ' => Some('ヅ'),
            'テ' => Some('デ'),
            'ト' => Some('ド'),
            'ハ' => Some('バ'),
            'ヒ' => Some('ビ'),
            'フ' => Some('ブ'),
            'ヘ' => Some('ベ'),
            'ホ' => Some('ボ'),
            'ウ' => Some('ヴ'),
            _ => None,
        }
    }

    /// Remove voicing from a hiragana character if possible
    fn unvoice_hiragana(c: char) -> Option<char> {
        match c {
            'が' => Some('か'),
            'ぎ' => Some('き'),
            'ぐ' => Some('く'),
            'げ' => Some('け'),
            'ご' => Some('こ'),
            'ざ' => Some('さ'),
            'じ' => Some('し'),
            'ず' => Some('す'),
            'ぜ' => Some('せ'),
            'ぞ' => Some('そ'),
            'だ' => Some('た'),
            'ぢ' => Some('ち'),
            'づ' => Some('つ'),
            'で' => Some('て'),
            'ど' => Some('と'),
            'ば' => Some('は'),
            'び' => Some('ひ'),
            'ぶ' => Some('ふ'),
            'べ' => Some('へ'),
            'ぼ' => Some('ほ'),
            _ => None,
        }
    }

    /// Remove voicing from a katakana character if possible
    fn unvoice_katakana(c: char) -> Option<char> {
        match c {
            'ガ' => Some('カ'),
            'ギ' => Some('キ'),
            'グ' => Some('ク'),
            'ゲ' => Some('ケ'),
            'ゴ' => Some('コ'),
            'ザ' => Some('サ'),
            'ジ' => Some('シ'),
            'ズ' => Some('ス'),
            'ゼ' => Some('セ'),
            'ゾ' => Some('ソ'),
            'ダ' => Some('タ'),
            'ヂ' => Some('チ'),
            'ヅ' => Some('ツ'),
            'デ' => Some('テ'),
            'ド' => Some('ト'),
            'バ' => Some('ハ'),
            'ビ' => Some('ヒ'),
            'ブ' => Some('フ'),
            'ベ' => Some('ヘ'),
            'ボ' => Some('ホ'),
            'ヴ' => Some('ウ'),
            _ => None,
        }
    }
}

impl Transliterator for JapaneseIterationMarksTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        chars: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mut result = Vec::new();
        let mut prev_char: Option<(&'a Char<'a, 'b>, CharType)> = None;
        let mut prev_was_iteration_mark = false;
        let mut offset = 0;

        for &current_char in chars {
            // Skip sentinel characters
            if current_char.c.is_empty() {
                result.push(current_char);
                continue;
            }

            // Get the first character (assuming single character strings for now)
            if let Some(c) = current_char.c.chars().next() {
                if Self::is_iteration_mark(c) {
                    // Check if previous character was also an iteration mark
                    if prev_was_iteration_mark {
                        // Don't replace consecutive iteration marks
                        let new_char = pool.new_with_offset(current_char, offset);
                        offset += new_char.c.len();
                        result.push(new_char);
                        prev_was_iteration_mark = true;
                        continue;
                    }

                    // We have an iteration mark, check if we can replace it
                    if let Some((prev, prev_type)) = prev_char {
                        if let Some(prev_c) = prev.c.chars().next() {
                            let replacement = match c {
                                HIRAGANA_ITERATION_MARK | VERTICAL_HIRAGANA_ITERATION_MARK => {
                                    // Repeat previous hiragana
                                    match prev_type {
                                        CharType::Hiragana => Some(prev_c.to_string()),
                                        CharType::Voiced => {
                                            // Voiced character followed by unvoiced iteration mark
                                            Self::unvoice_hiragana(prev_c).map(|ch| ch.to_string())
                                        }
                                        _ => None,
                                    }
                                }
                                HIRAGANA_VOICED_ITERATION_MARK
                                | VERTICAL_HIRAGANA_VOICED_ITERATION_MARK => {
                                    // Repeat previous hiragana with voicing
                                    match prev_type {
                                        CharType::Hiragana => {
                                            Self::voice_hiragana(prev_c).map(|ch| ch.to_string())
                                        }
                                        CharType::Voiced => {
                                            // Voiced character followed by voiced iteration mark
                                            Some(prev_c.to_string())
                                        }
                                        _ => None,
                                    }
                                }
                                KATAKANA_ITERATION_MARK | VERTICAL_KATAKANA_ITERATION_MARK => {
                                    // Repeat previous katakana
                                    match prev_type {
                                        CharType::Katakana => Some(prev_c.to_string()),
                                        CharType::Voiced => {
                                            // Voiced character followed by unvoiced iteration mark
                                            Self::unvoice_katakana(prev_c).map(|ch| ch.to_string())
                                        }
                                        _ => None,
                                    }
                                }
                                KATAKANA_VOICED_ITERATION_MARK
                                | VERTICAL_KATAKANA_VOICED_ITERATION_MARK => {
                                    // Repeat previous katakana with voicing
                                    match prev_type {
                                        CharType::Katakana => {
                                            Self::voice_katakana(prev_c).map(|ch| ch.to_string())
                                        }
                                        CharType::Voiced => {
                                            // Voiced character followed by voiced iteration mark
                                            Some(prev_c.to_string())
                                        }
                                        _ => None,
                                    }
                                }
                                KANJI_ITERATION_MARK => {
                                    // Repeat previous kanji
                                    if prev_type == CharType::Kanji {
                                        Some(prev_c.to_string())
                                    } else {
                                        None
                                    }
                                }
                                _ => None,
                            };

                            if let Some(replacement_str) = replacement {
                                // Create a new character with the replacement
                                let new_char = pool.new_char_from(
                                    Cow::Owned(replacement_str),
                                    offset,
                                    current_char,
                                );
                                offset += new_char.c.len();
                                result.push(new_char);
                                prev_was_iteration_mark = true;
                                // Don't update prev_char - keep the original one
                                // This ensures consecutive iteration marks work correctly
                                continue;
                            }
                        }
                    }

                    // Couldn't replace the iteration mark
                    let new_char = pool.new_with_offset(current_char, offset);
                    offset += new_char.c.len();
                    result.push(new_char);
                    prev_was_iteration_mark = true;
                } else {
                    // Not an iteration mark
                    let new_char = pool.new_with_offset(current_char, offset);
                    offset += new_char.c.len();
                    result.push(new_char);

                    // Update previous character info
                    let char_type = Self::get_char_type(c);
                    prev_char = Some((current_char, char_type));
                    prev_was_iteration_mark = false;
                }
            } else {
                // Empty character content, just pass through
                result.push(pool.new_with_offset(current_char, offset));
                prev_was_iteration_mark = false;
            }
        }

        Ok(result)
    }
}

impl TransliteratorFactory for JapaneseIterationMarksTransliteratorOptions {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(JapaneseIterationMarksTransliterator::new(
            self.clone(),
        )))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::char::from_chars;

    #[test]
    fn test_hiragana_repetition_basic() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("さゝ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "ささ");
    }

    #[test]
    fn test_hiragana_voiced_repetition() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("はゞ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "はば");
    }

    #[test]
    fn test_hiragana_repetition_multiple() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("みゝこゝろ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "みみこころ");
    }

    #[test]
    fn test_katakana_repetition_basic() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("サヽ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "ササ");
    }

    #[test]
    fn test_katakana_voiced_repetition() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ハヾ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "ハバ");
    }

    #[test]
    fn test_katakana_u_voicing() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ウヾ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "ウヴ");
    }

    #[test]
    fn test_kanji_repetition_basic() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("人々");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "人人");
    }

    #[test]
    fn test_kanji_repetition_multiple() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("日々月々年々");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "日日月月年年");
    }

    #[test]
    fn test_invalid_hiragana_mark_after_katakana() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("カゝ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "カゝ");
    }

    #[test]
    fn test_invalid_katakana_mark_after_hiragana() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("かヽ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "かヽ");
    }

    #[test]
    fn test_iteration_mark_at_start() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ゝあ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "ゝあ");
    }

    #[test]
    fn test_consecutive_iteration_marks() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("さゝゝ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "ささゝ");
    }

    #[test]
    fn test_hatsuon_cannot_repeat() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Hiragana hatsuon
        let input_chars = pool.build_char_array("んゝ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());
        assert_eq!(result_string, "んゝ");

        // Katakana hatsuon
        let input_chars = pool.build_char_array("ンヽ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());
        assert_eq!(result_string, "ンヽ");
    }

    #[test]
    fn test_sokuon_cannot_repeat() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        // Hiragana sokuon
        let input_chars = pool.build_char_array("っゝ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());
        assert_eq!(result_string, "っゝ");

        // Katakana sokuon
        let input_chars = pool.build_char_array("ッヽ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());
        assert_eq!(result_string, "ッヽ");
    }

    #[test]
    fn test_voiced_character_cannot_voice_again() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("がゞ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        // This behavior was changed - voiced character with voiced iteration mark now repeats
        assert_eq!(result_string, "がが");
    }

    #[test]
    fn test_semi_voiced_character_cannot_voice() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ぱゞ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "ぱゞ");
    }

    #[test]
    fn test_mixed_text() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("こゝろ、コヽロ、其々");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "こころ、ココロ、其其");
    }

    #[test]
    fn test_iteration_marks_in_sentence() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("日々の暮らしはさゝやかだがウヾしい");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "日日の暮らしはささやかだがウヴしい");
    }

    #[test]
    fn test_halfwidth_katakana() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("ｻヽ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "ｻｻ");
    }

    #[test]
    fn test_no_voicing_possible() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("あゞ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "あゞ");
    }

    #[test]
    fn test_voicing_all_consonants() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("かゞたゞはゞさゞ");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "かがただはばさざ");
    }

    #[test]
    fn test_empty_string() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let non_sentinel_chars: Vec<_> = result.iter().filter(|c| !c.c.is_empty()).collect();

        assert!(non_sentinel_chars.is_empty());
    }

    #[test]
    fn test_sentinel_handling() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let transliterator = JapaneseIterationMarksTransliterator::new(options);
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

    #[test]
    fn test_factory() {
        let options = JapaneseIterationMarksTransliteratorOptions::default();
        let factory_result = options.new_transliterator();
        assert!(factory_result.is_ok());

        let transliterator = factory_result.unwrap();
        let mut pool = CharPool::new();

        let input_chars = pool.build_char_array("人々");
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = from_chars(result.iter().cloned());

        assert_eq!(result_string, "人人");
    }
}
