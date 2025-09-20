use yosina::make_transliterator;
use yosina::recipes::{
    RemoveIVSSVSOptions, ReplaceCircledOrSquaredCharactersOptions, ReplaceHyphensOptions,
    ToFullWidthOptions, ToHalfwidthOptions, TransliterationRecipe,
};
use yosina::transliterators::{Charset, HyphensTransliterationVariant};

#[test]
fn test_empty_recipe() {
    let recipe = TransliterationRecipe::default();
    let configs = recipe.build().unwrap();

    assert!(configs.is_empty());
}

#[test]
fn test_default_values() {
    let recipe = TransliterationRecipe::default();

    assert!(!recipe.kanji_old_new);
    assert!(!recipe.replace_suspicious_hyphens_to_prolonged_sound_marks);
    assert!(!recipe.replace_combined_characters);
    assert_eq!(
        recipe.replace_circled_or_squared_characters,
        ReplaceCircledOrSquaredCharactersOptions::No
    );
    assert!(!recipe.replace_ideographic_annotations);
    assert!(!recipe.replace_radicals);
    assert!(!recipe.replace_spaces);
    assert_eq!(recipe.replace_hyphens, ReplaceHyphensOptions::No);
    assert!(!recipe.replace_mathematical_alphanumerics);
    assert!(!recipe.replace_roman_numerals);
    assert!(!recipe.combine_decomposed_hiraganas_and_katakanas);
    assert_eq!(recipe.to_fullwidth, ToFullWidthOptions::No);
    assert_eq!(recipe.to_halfwidth, ToHalfwidthOptions::No);
    assert_eq!(recipe.remove_ivs_svs, RemoveIVSSVSOptions::No);
    assert_eq!(recipe.charset, Charset::Unijis2004);
}

#[test]
fn test_kanji_old_new_with_ivs_svs() {
    let recipe = TransliterationRecipe {
        kanji_old_new: true,
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    // Should contain kanji-old-new and IVS/SVS configurations
    let has_kanji = configs
        .iter()
        .any(|c| matches!(c, yosina::TransliteratorConfig::KanjiOldNew));
    let has_ivs_svs = configs
        .iter()
        .any(|c| matches!(c, yosina::TransliteratorConfig::IvsSvsBase(_)));
    assert!(has_kanji);
    assert!(has_ivs_svs);

    // Should have at least 3 configs: ivs-or-svs, kanji-old-new, base
    assert!(configs.len() >= 3);
}

#[test]
fn test_prolonged_sound_marks() {
    let recipe = TransliterationRecipe {
        replace_suspicious_hyphens_to_prolonged_sound_marks: true,
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    assert_eq!(configs.len(), 1);
    assert!(
        matches!(&configs[0], yosina::TransliteratorConfig::ProlongedSoundMarks(opts) if opts.replace_prolonged_marks_following_alnums)
    );
}

#[test]
fn test_circled_or_squared() {
    let recipe = TransliterationRecipe {
        replace_circled_or_squared_characters: ReplaceCircledOrSquaredCharactersOptions::Yes {
            exclude_emojis: false,
        },
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    assert_eq!(configs.len(), 1);
    assert!(
        matches!(&configs[0], yosina::TransliteratorConfig::CircledOrSquared(opts) if opts.include_emojis)
    );
}

#[test]
fn test_circled_or_squared_exclude_emojis() {
    let recipe = TransliterationRecipe {
        replace_circled_or_squared_characters: ReplaceCircledOrSquaredCharactersOptions::Yes {
            exclude_emojis: true,
        },
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    assert_eq!(configs.len(), 1);
    assert!(
        matches!(&configs[0], yosina::TransliteratorConfig::CircledOrSquared(opts) if !opts.include_emojis)
    );
}

#[test]
fn test_combined() {
    let recipe = TransliterationRecipe {
        replace_combined_characters: true,
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    assert_eq!(configs.len(), 1);
    assert!(matches!(
        &configs[0],
        yosina::TransliteratorConfig::Combined
    ));
}

#[test]
fn test_ideographic_annotations() {
    let recipe = TransliterationRecipe {
        replace_ideographic_annotations: true,
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    assert_eq!(configs.len(), 1);
    assert!(matches!(
        &configs[0],
        yosina::TransliteratorConfig::IdeographicAnnotations
    ));
}

#[test]
fn test_radicals() {
    let recipe = TransliterationRecipe {
        replace_radicals: true,
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    assert_eq!(configs.len(), 1);
    assert!(matches!(
        &configs[0],
        yosina::TransliteratorConfig::Radicals
    ));
}

#[test]
fn test_spaces() {
    let recipe = TransliterationRecipe {
        replace_spaces: true,
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    assert_eq!(configs.len(), 1);
    assert!(matches!(&configs[0], yosina::TransliteratorConfig::Spaces));
}

#[test]
fn test_mathematical_alphanumerics() {
    let recipe = TransliterationRecipe {
        replace_mathematical_alphanumerics: true,
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    assert_eq!(configs.len(), 1);
    assert!(matches!(
        &configs[0],
        yosina::TransliteratorConfig::MathematicalAlphanumerics
    ));
}

#[test]
fn test_roman_numerals() {
    let recipe = TransliterationRecipe {
        replace_roman_numerals: true,
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    assert_eq!(configs.len(), 1);
    assert!(matches!(
        &configs[0],
        yosina::TransliteratorConfig::RomanNumerals
    ));
}

#[test]
fn test_hira_kata_composition() {
    let recipe = TransliterationRecipe {
        combine_decomposed_hiraganas_and_katakanas: true,
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    assert_eq!(configs.len(), 1);
    assert!(
        matches!(&configs[0], yosina::TransliteratorConfig::HiraKataComposition(opts) if opts.compose_non_combining_marks)
    );
}

#[test]
fn test_hyphens_default_precedence() {
    let recipe = TransliterationRecipe {
        replace_hyphens: ReplaceHyphensOptions::Yes {
            precedence: vec![
                HyphensTransliterationVariant::Jisx0208_90Windows,
                HyphensTransliterationVariant::Jisx0201,
            ],
        },
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    assert_eq!(configs.len(), 1);
    if let yosina::TransliteratorConfig::Hyphens(opts) = &configs[0] {
        assert_eq!(opts.precedence.len(), 2);
        assert_eq!(
            opts.precedence[0],
            HyphensTransliterationVariant::Jisx0208_90Windows
        );
        assert_eq!(opts.precedence[1], HyphensTransliterationVariant::Jisx0201);
    } else {
        panic!("Expected Hyphens config");
    }
}

#[test]
fn test_hyphens_custom_precedence() {
    let custom_precedence = vec![
        HyphensTransliterationVariant::Jisx0201,
        HyphensTransliterationVariant::Ascii,
    ];
    let recipe = TransliterationRecipe {
        replace_hyphens: ReplaceHyphensOptions::Yes {
            precedence: custom_precedence.clone(),
        },
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    if let yosina::TransliteratorConfig::Hyphens(opts) = &configs[0] {
        assert_eq!(opts.precedence, custom_precedence);
    } else {
        panic!("Expected Hyphens config");
    }
}

#[test]
fn test_to_fullwidth_basic() {
    let recipe = TransliterationRecipe {
        to_fullwidth: ToFullWidthOptions::Yes {
            u005c_as_yen_sign: false,
        },
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    assert_eq!(configs.len(), 1);
    if let yosina::TransliteratorConfig::Jisx0201AndAlike {
        fullwidth_to_halfwidth: _,
        options: opts,
    } = &configs[0]
    {
        assert!(!opts.u005c_as_yen_sign.unwrap());
    } else {
        panic!("Expected Jisx0201AndAlike config, got {:?}", configs[0]);
    }
}

#[test]
fn test_to_fullwidth_yen_sign() {
    let recipe = TransliterationRecipe {
        to_fullwidth: ToFullWidthOptions::Yes {
            u005c_as_yen_sign: true,
        },
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    if let yosina::TransliteratorConfig::Jisx0201AndAlike {
        fullwidth_to_halfwidth: _,
        options: opts,
    } = &configs[0]
    {
        assert!(opts.u005c_as_yen_sign.unwrap());
    } else {
        panic!("Expected Jisx0201AndAlike config, got {:?}", configs[0]);
    }
}

#[test]
fn test_to_halfwidth_basic() {
    let recipe = TransliterationRecipe {
        to_halfwidth: ToHalfwidthOptions::Yes {
            hankaku_kana: false,
        },
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    if let yosina::TransliteratorConfig::Jisx0201AndAlike {
        fullwidth_to_halfwidth: _,
        options: opts,
    } = &configs[0]
    {
        assert!(opts.convert_gl);
        assert!(!opts.convert_gr);
    } else {
        panic!("Expected Jisx0201AndAlike config");
    }
}

#[test]
fn test_to_halfwidth_hankaku_kana() {
    let recipe = TransliterationRecipe {
        to_halfwidth: ToHalfwidthOptions::Yes { hankaku_kana: true },
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    if let yosina::TransliteratorConfig::Jisx0201AndAlike {
        fullwidth_to_halfwidth: _,
        options: opts,
    } = &configs[0]
    {
        assert!(opts.convert_gr);
    } else {
        panic!("Expected Jisx0201AndAlike config");
    }
}

#[test]
fn test_remove_ivs_svs_basic() {
    let recipe = TransliterationRecipe {
        remove_ivs_svs: RemoveIVSSVSOptions::Yes {
            drop_all_selectors: false,
        },
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    // Should have two ivs-svs-base configs
    let ivs_svs_configs: Vec<_> = configs
        .iter()
        .filter_map(|c| match c {
            yosina::TransliteratorConfig::IvsSvsBase(opts) => Some(opts),
            _ => None,
        })
        .collect();
    assert_eq!(ivs_svs_configs.len(), 2);

    // Check modes
    let has_ivs_or_svs = ivs_svs_configs.iter().any(|opts| {
        matches!(
            opts.mode,
            yosina::transliterators::IvsSvsBaseMode::IvsOrSvs(_)
        )
    });
    let has_base = ivs_svs_configs
        .iter()
        .any(|opts| matches!(opts.mode, yosina::transliterators::IvsSvsBaseMode::Base));
    assert!(has_ivs_or_svs);
    assert!(has_base);

    // Check drop_selectors_altogether is false for base mode
    for opts in &ivs_svs_configs {
        if matches!(opts.mode, yosina::transliterators::IvsSvsBaseMode::Base) {
            assert!(!opts.drop_selectors_altogether);
        }
    }
}

#[test]
fn test_remove_ivs_svs_drop_all() {
    let recipe = TransliterationRecipe {
        remove_ivs_svs: RemoveIVSSVSOptions::Yes {
            drop_all_selectors: true,
        },
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    // Find base mode config
    for config in &configs {
        if let yosina::TransliteratorConfig::IvsSvsBase(opts) = config {
            if matches!(opts.mode, yosina::transliterators::IvsSvsBaseMode::Base) {
                assert!(opts.drop_selectors_altogether);
            }
        }
    }
}

#[test]
fn test_charset_configuration() {
    let recipe = TransliterationRecipe {
        kanji_old_new: true,
        charset: Charset::Unijis90,
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    // Find the ivs-svs-base config with mode "base" which should have charset
    for config in &configs {
        if let yosina::TransliteratorConfig::IvsSvsBase(opts) = config {
            if matches!(opts.mode, yosina::transliterators::IvsSvsBaseMode::Base) {
                assert_eq!(opts.charset, Charset::Unijis90);
            }
        }
    }
}

#[test]
fn test_circled_or_squared_and_combined_order() {
    let recipe = TransliterationRecipe {
        replace_circled_or_squared_characters: ReplaceCircledOrSquaredCharactersOptions::Yes {
            exclude_emojis: false,
        },
        replace_combined_characters: true,
        ..Default::default()
    };
    let configs = recipe.build().unwrap();

    // Find positions
    let circled_pos = configs
        .iter()
        .position(|c| matches!(c, yosina::TransliteratorConfig::CircledOrSquared(_)));
    let combined_pos = configs
        .iter()
        .position(|c| matches!(c, yosina::TransliteratorConfig::Combined));

    assert!(circled_pos.is_some());
    assert!(combined_pos.is_some());
    assert!(combined_pos.unwrap() < circled_pos.unwrap());
}

#[test]
fn test_comprehensive_ordering() {
    let recipe = TransliterationRecipe {
        kanji_old_new: true,
        replace_suspicious_hyphens_to_prolonged_sound_marks: true,
        replace_spaces: true,
        combine_decomposed_hiraganas_and_katakanas: true,
        to_halfwidth: ToHalfwidthOptions::Yes {
            hankaku_kana: false,
        },
        ..Default::default()
    };

    let configs = recipe.build().unwrap();

    // Verify some key orderings
    let has_hira_kata = configs
        .iter()
        .any(|c| matches!(c, yosina::TransliteratorConfig::HiraKataComposition(_)));
    let has_jisx0201 = configs.iter().any(|c| {
        matches!(
            c,
            yosina::TransliteratorConfig::Jisx0201AndAlike {
                fullwidth_to_halfwidth: _,
                options: _
            }
        )
    });
    let has_spaces = configs
        .iter()
        .any(|c| matches!(c, yosina::TransliteratorConfig::Spaces));
    let has_prolonged = configs
        .iter()
        .any(|c| matches!(c, yosina::TransliteratorConfig::ProlongedSoundMarks(_)));
    let has_kanji = configs
        .iter()
        .any(|c| matches!(c, yosina::TransliteratorConfig::KanjiOldNew));

    assert!(has_hira_kata);
    assert!(has_jisx0201);
    assert!(has_spaces);
    assert!(has_prolonged);
    assert!(has_kanji);

    // jisx0201-and-alike should be at the end (tail insertion)
    assert!(matches!(
        configs.last().unwrap(),
        yosina::TransliteratorConfig::Jisx0201AndAlike {
            fullwidth_to_halfwidth: _,
            options: _
        }
    ));
}

#[test]
fn test_fullwidth_halfwidth_mutual_exclusion() {
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
    assert!(result.is_err());
    assert!(result
        .unwrap_err()
        .to_string()
        .contains("mutually exclusive"));
}

#[test]
fn test_all_transliterators_enabled() {
    let recipe = TransliterationRecipe {
        combine_decomposed_hiraganas_and_katakanas: true,
        kanji_old_new: true,
        remove_ivs_svs: RemoveIVSSVSOptions::Yes {
            drop_all_selectors: true,
        },
        replace_hyphens: ReplaceHyphensOptions::Yes {
            precedence: vec![
                HyphensTransliterationVariant::Jisx0208_90Windows,
                HyphensTransliterationVariant::Jisx0201,
            ],
        },
        replace_ideographic_annotations: true,
        replace_suspicious_hyphens_to_prolonged_sound_marks: true,
        replace_radicals: true,
        replace_spaces: true,
        replace_circled_or_squared_characters: ReplaceCircledOrSquaredCharactersOptions::Yes {
            exclude_emojis: false,
        },
        replace_combined_characters: true,
        replace_mathematical_alphanumerics: true,
        replace_roman_numerals: true,
        to_halfwidth: ToHalfwidthOptions::Yes { hankaku_kana: true },
        charset: Charset::Unijis90,
        ..Default::default()
    };

    let configs = recipe.build().unwrap();

    // Verify all expected transliterators are present
    #[allow(clippy::type_complexity)]
    let expected_counts: &[(usize, Box<dyn Fn(&yosina::TransliteratorConfig) -> bool>)] = &[
        (
            2,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(c, yosina::TransliteratorConfig::IvsSvsBase(_))
            }),
        ),
        (
            1,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(c, yosina::TransliteratorConfig::KanjiOldNew)
            }),
        ),
        (
            1,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(c, yosina::TransliteratorConfig::ProlongedSoundMarks(_))
            }),
        ),
        (
            1,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(c, yosina::TransliteratorConfig::CircledOrSquared(_))
            }),
        ),
        (
            1,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(c, yosina::TransliteratorConfig::Combined)
            }),
        ),
        (
            1,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(c, yosina::TransliteratorConfig::IdeographicAnnotations)
            }),
        ),
        (
            1,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(c, yosina::TransliteratorConfig::Radicals)
            }),
        ),
        (
            1,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(c, yosina::TransliteratorConfig::Spaces)
            }),
        ),
        (
            1,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(c, yosina::TransliteratorConfig::Hyphens(_))
            }),
        ),
        (
            1,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(c, yosina::TransliteratorConfig::MathematicalAlphanumerics)
            }),
        ),
        (
            1,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(c, yosina::TransliteratorConfig::RomanNumerals)
            }),
        ),
        (
            1,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(c, yosina::TransliteratorConfig::HiraKataComposition(_))
            }),
        ),
        (
            1,
            Box::new(|c: &yosina::TransliteratorConfig| {
                matches!(
                    c,
                    yosina::TransliteratorConfig::Jisx0201AndAlike {
                        fullwidth_to_halfwidth: _,
                        options: _
                    }
                )
            }),
        ),
    ];

    for (expected_count, predicate) in expected_counts {
        let count = configs.iter().filter(|c| predicate(c)).count();
        assert_eq!(count, *expected_count);
    }

    // Verify specific configurations
    let hyphens_config = configs
        .iter()
        .find_map(|c| match c {
            yosina::TransliteratorConfig::Hyphens(opts) => Some(opts),
            _ => None,
        })
        .unwrap();
    assert_eq!(
        hyphens_config.precedence[0],
        HyphensTransliterationVariant::Jisx0208_90Windows
    );
    assert_eq!(
        hyphens_config.precedence[1],
        HyphensTransliterationVariant::Jisx0201
    );

    let jisx_config = configs
        .iter()
        .find_map(|c| match c {
            yosina::TransliteratorConfig::Jisx0201AndAlike {
                fullwidth_to_halfwidth: _,
                options: opts,
            } => Some(opts),
            _ => None,
        })
        .unwrap();
    assert!(jisx_config.convert_gr);
}

#[test]
fn test_basic_transliteration() {
    let recipe = TransliterationRecipe {
        replace_circled_or_squared_characters: ReplaceCircledOrSquaredCharactersOptions::Yes {
            exclude_emojis: false,
        },
        replace_combined_characters: true,
        replace_spaces: true,
        replace_mathematical_alphanumerics: true,
        ..Default::default()
    };

    let transliterator = make_transliterator(&recipe).unwrap();

    // Test mixed content
    let test_cases = vec![
        ("①", "(1)"),       // Circled number
        ("⑴", "(1)"),       // Parenthesized number (combined)
        ("𝐇𝐞𝐥𝐥𝐨", "Hello"), // Mathematical alphanumerics
        ("　", " "),        // Full-width space
    ];

    for (input, expected) in test_cases {
        let result = transliterator(input).unwrap();
        assert_eq!(result, expected);
    }
}

#[test]
fn test_exclude_emojis_functional() {
    let recipe = TransliterationRecipe {
        replace_circled_or_squared_characters: ReplaceCircledOrSquaredCharactersOptions::Yes {
            exclude_emojis: true,
        },
        ..Default::default()
    };

    let transliterator = make_transliterator(&recipe).unwrap();

    // Regular circled characters should still work
    assert_eq!(transliterator("①").unwrap(), "(1)");
    assert_eq!(transliterator("Ⓐ").unwrap(), "(A)");

    // Non-emoji squared letters should still be processed
    assert_eq!(transliterator("🅰").unwrap(), "[A]");

    // Emoji characters should not be processed
    assert_eq!(transliterator("🆘").unwrap(), "🆘");
}

#[test]
fn test_roman_numerals_functional() {
    let recipe = TransliterationRecipe {
        replace_roman_numerals: true,
        ..Default::default()
    };

    let transliterator = make_transliterator(&recipe).unwrap();

    // Test roman numeral conversion
    let test_cases = vec![
        ("Ⅰ", "I"),                       // Uppercase I
        ("Ⅻ", "XII"),                     // Uppercase XII
        ("ⅰ", "i"),                       // Lowercase i
        ("ⅻ", "xii"),                     // Lowercase xii
        ("Chapter Ⅴ", "Chapter V"),       // Mixed text
        ("Section ⅲ.A", "Section iii.A"), // Mixed text with punctuation
    ];

    for (input, expected) in test_cases {
        let result = transliterator(input).unwrap();
        assert_eq!(result, expected, "Failed for input '{}'", input);
    }
}
