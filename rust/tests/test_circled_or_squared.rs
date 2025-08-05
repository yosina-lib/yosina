use yosina::char::{from_chars, CharPool};
use yosina::transliterator::Transliterator;
use yosina::transliterators::{
    CircledOrSquaredTransliterator, CircledOrSquaredTransliteratorOptions,
};

fn test_transliterate(input: &str) -> String {
    let options = CircledOrSquaredTransliteratorOptions {
        include_emojis: true,
    };
    let mut pool = CharPool::new();
    let chars = pool.build_char_array(input);
    let transliterator = CircledOrSquaredTransliterator::new(options);
    let result = transliterator.transliterate(&mut pool, &chars).unwrap();
    from_chars(result)
}

fn test_transliterate_with_options(input: &str, include_emojis: bool) -> String {
    let options = CircledOrSquaredTransliteratorOptions { include_emojis };
    let mut pool = CharPool::new();
    let chars = pool.build_char_array(input);
    let transliterator = CircledOrSquaredTransliterator::new(options);
    let result = transliterator.transliterate(&mut pool, &chars).unwrap();
    from_chars(result)
}

#[test]
fn test_circled_number_1() {
    assert_eq!(test_transliterate("①"), "(1)");
}

#[test]
fn test_circled_number_2() {
    assert_eq!(test_transliterate("②"), "(2)");
}

#[test]
fn test_circled_number_20() {
    assert_eq!(test_transliterate("⑳"), "(20)");
}

#[test]
fn test_circled_number_0() {
    assert_eq!(test_transliterate("⓪"), "(0)");
}

#[test]
fn test_circled_uppercase_a() {
    assert_eq!(test_transliterate("Ⓐ"), "(A)");
}

#[test]
fn test_circled_uppercase_z() {
    assert_eq!(test_transliterate("Ⓩ"), "(Z)");
}

#[test]
fn test_circled_lowercase_a() {
    assert_eq!(test_transliterate("ⓐ"), "(a)");
}

#[test]
fn test_circled_lowercase_z() {
    assert_eq!(test_transliterate("ⓩ"), "(z)");
}

#[test]
fn test_circled_kanji_ichi() {
    assert_eq!(test_transliterate("㊀"), "(一)");
}

#[test]
fn test_circled_kanji_getsu() {
    assert_eq!(test_transliterate("㊊"), "(月)");
}

#[test]
fn test_circled_kanji_yoru() {
    assert_eq!(test_transliterate("㊰"), "(夜)");
}

#[test]
fn test_circled_katakana_a() {
    assert_eq!(test_transliterate("㋐"), "(ア)");
}

#[test]
fn test_circled_katakana_wo() {
    assert_eq!(test_transliterate("㋾"), "(ヲ)");
}

#[test]
fn test_squared_letter_a() {
    assert_eq!(test_transliterate("🅰"), "[A]");
}

#[test]
fn test_squared_letter_z() {
    assert_eq!(test_transliterate("🆉"), "[Z]");
}

#[test]
fn test_regional_indicator_a() {
    assert_eq!(test_transliterate("🇦"), "[A]");
}

#[test]
fn test_regional_indicator_z() {
    assert_eq!(test_transliterate("🇿"), "[Z]");
}

#[test]
fn test_emoji_exclusion_default() {
    assert_eq!(test_transliterate("🆂🅾🆂"), "[S][O][S]");
}

#[test]
fn test_empty_string() {
    assert_eq!(test_transliterate(""), "");
}

#[test]
fn test_unmapped_characters() {
    let input = "hello world 123 abc こんにちは";
    assert_eq!(test_transliterate(input), input);
}

#[test]
fn test_mixed_content() {
    assert_eq!(
        test_transliterate("Hello ① World Ⓐ Test"),
        "Hello (1) World (A) Test"
    );
}

#[test]
fn test_sequence_of_circled_numbers() {
    assert_eq!(test_transliterate("①②③④⑤"), "(1)(2)(3)(4)(5)");
}

#[test]
fn test_sequence_of_circled_letters() {
    assert_eq!(test_transliterate("ⒶⒷⒸ"), "(A)(B)(C)");
}

#[test]
fn test_mixed_circles_and_squares() {
    assert_eq!(test_transliterate("①🅰②🅱"), "(1)[A](2)[B]");
}

#[test]
fn test_circled_kanji_sequence() {
    assert_eq!(test_transliterate("㊀㊁㊂㊃㊄"), "(一)(二)(三)(四)(五)");
}

#[test]
fn test_japanese_text_with_circled_elements() {
    assert_eq!(
        test_transliterate("項目①は重要で、項目②は補足です。"),
        "項目(1)は重要で、項目(2)は補足です。"
    );
}

#[test]
fn test_numbered_list_with_circled_numbers() {
    assert_eq!(
        test_transliterate("①準備\n②実行\n③確認"),
        "(1)準備\n(2)実行\n(3)確認"
    );
}

#[test]
fn test_large_circled_numbers() {
    assert_eq!(test_transliterate("㊱㊲㊳"), "(36)(37)(38)");
}

#[test]
fn test_circled_numbers_up_to_50() {
    assert_eq!(test_transliterate("㊿"), "(50)");
}

#[test]
fn test_special_circled_characters() {
    assert_eq!(test_transliterate("🄴🅂"), "[E][S]");
}

#[test]
fn test_include_emojis_true() {
    assert_eq!(test_transliterate_with_options("🆘", true), "[SOS]");
}

#[test]
fn test_include_emojis_false() {
    assert_eq!(test_transliterate_with_options("🆘", false), "🆘");
}

#[test]
fn test_mixed_emoji_and_non_emoji_with_include_emojis_true() {
    assert_eq!(test_transliterate_with_options("①🅰②", true), "(1)[A](2)");
}

#[test]
fn test_mixed_emoji_and_non_emoji_with_include_emojis_false() {
    assert_eq!(test_transliterate_with_options("①🆘②", false), "(1)🆘(2)");
}

#[test]
fn test_unicode_characters_preserved() {
    assert_eq!(
        test_transliterate("こんにちは①世界🅰です"),
        "こんにちは(1)世界[A]です"
    );
}

#[test]
fn test_other_emoji_preserved() {
    assert_eq!(test_transliterate("😀①😊"), "😀(1)😊");
}

#[test]
fn test_newlines_and_tabs_preserved() {
    assert_eq!(test_transliterate("Line1\n①\tLine2"), "Line1\n(1)\tLine2");
}
