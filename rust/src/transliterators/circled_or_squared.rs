use crate::char::{Char, CharPool};
use crate::transliterator::{
    TransliterationError, Transliterator, TransliteratorFactory, TransliteratorFactoryError,
};
use serde::{Deserialize, Serialize};

include!("./circled_or_squared_data.rs");

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct CircledOrSquaredTransliteratorOptions {
    pub include_emojis: bool,
}

impl Default for CircledOrSquaredTransliteratorOptions {
    fn default() -> Self {
        Self {
            include_emojis: true,
        }
    }
}

pub struct CircledOrSquaredTransliterator {
    include_emojis: bool,
}

impl CircledOrSquaredTransliterator {
    pub fn new(options: CircledOrSquaredTransliteratorOptions) -> Self {
        Self {
            include_emojis: options.include_emojis,
        }
    }
}

impl Transliterator for CircledOrSquaredTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        input: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mut result = Vec::new();
        let mut offset = 0;

        for &input_char in input {
            if input_char.c.is_empty() {
                // Preserve sentinel characters
                result.push(input_char);
                continue;
            }

            let char_str = input_char.c.as_ref();

            // Check if this character has a mapping
            if let Some(record) = MAPPINGS.get(char_str) {
                // Skip emoji characters if include_emojis is false
                if !self.include_emojis && record.emoji {
                    let nc = pool.new_with_offset(input_char, offset);
                    offset += nc.c.len();
                    result.push(nc);
                    continue;
                }

                // Create the replacement based on type and rendering
                let replacement = match record.type_.as_str() {
                    "circle" => format!("({})", record.rendering),
                    "square" => format!("[{}]", record.rendering),
                    _ => record.rendering.clone(), // fallback to just the rendering
                };

                // Create new character with the replacement string
                let nc =
                    pool.new_char_from(std::borrow::Cow::Owned(replacement), offset, input_char);
                offset += nc.c.len();
                result.push(nc);
            } else {
                // Character not in mapping, keep as-is
                let nc = pool.new_with_offset(input_char, offset);
                offset += nc.c.len();
                result.push(nc);
            }
        }

        Ok(result)
    }
}

pub struct CircledOrSquaredTransliteratorFactory {
    options: CircledOrSquaredTransliteratorOptions,
}

impl CircledOrSquaredTransliteratorFactory {
    pub fn new(options: CircledOrSquaredTransliteratorOptions) -> Self {
        Self { options }
    }
}

impl TransliteratorFactory for CircledOrSquaredTransliteratorFactory {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(CircledOrSquaredTransliterator::new(
            self.options.clone(),
        )))
    }
}
