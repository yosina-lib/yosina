use crate::transliterator::{
    ChainedTransliterator, Transliterator, TransliteratorFactory, TransliteratorFactoryError,
};
use crate::transliterators::TransliteratorConfig;

#[derive(Debug, Clone, PartialEq)]
pub struct TransliteratorConfigBuilder {
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

impl TransliteratorFactory for Vec<TransliteratorConfig> {
    /// Create a chained transliterator from a list of configs
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        let transliterators = self
            .iter()
            .map(|config| config.new_transliterator())
            .collect::<Result<Vec<_>, _>>()?;
        if transliterators.is_empty() {
            return Err(TransliteratorFactoryError::new(
                "at least one transliterator must be specified".to_string(),
            ));
        }
        Ok(Box::new(ChainedTransliterator(transliterators)))
    }
}

#[cfg(test)]
mod tests {
    use super::TransliteratorConfig;
    use crate::char::{from_chars, CharPool};
    use crate::transliterator::TransliteratorFactory as _;
    use crate::transliterators::{
        HiraKataCompositionTransliteratorOptions, ProlongedSoundMarksTransliteratorOptions,
    };

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
