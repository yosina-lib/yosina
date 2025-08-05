use yosina::char::{from_chars, CharPool};
use yosina::transliterator::Transliterator;
use yosina::transliterators::CombinedTransliterator;

fn test_transliterate(input: &str) -> String {
    let mut pool = CharPool::new();
    let chars = pool.build_char_array(input);
    let transliterator = CombinedTransliterator::new();
    let result = transliterator.transliterate(&mut pool, &chars).unwrap();
    from_chars(result)
}

#[test]
fn test_null_symbol_to_nul() {
    assert_eq!(test_transliterate("␀"), "NUL");
}

#[test]
fn test_start_of_heading_to_soh() {
    assert_eq!(test_transliterate("␁"), "SOH");
}

#[test]
fn test_start_of_text_to_stx() {
    assert_eq!(test_transliterate("␂"), "STX");
}

#[test]
fn test_backspace_to_bs() {
    assert_eq!(test_transliterate("␈"), "BS");
}

#[test]
fn test_horizontal_tab_to_ht() {
    assert_eq!(test_transliterate("␉"), "HT");
}

#[test]
fn test_carriage_return_to_cr() {
    assert_eq!(test_transliterate("␍"), "CR");
}

#[test]
fn test_space_symbol_to_sp() {
    assert_eq!(test_transliterate("␠"), "SP");
}

#[test]
fn test_delete_symbol_to_del() {
    assert_eq!(test_transliterate("␡"), "DEL");
}

#[test]
fn test_parenthesized_number_1() {
    assert_eq!(test_transliterate("⑴"), "(1)");
}

#[test]
fn test_parenthesized_number_5() {
    assert_eq!(test_transliterate("⑹"), "(6)");
}

#[test]
fn test_parenthesized_number_10() {
    assert_eq!(test_transliterate("⑽"), "(10)");
}

#[test]
fn test_parenthesized_number_20() {
    assert_eq!(test_transliterate("⒇"), "(20)");
}

#[test]
fn test_period_number_1() {
    assert_eq!(test_transliterate("⒈"), "1.");
}

#[test]
fn test_period_number_10() {
    assert_eq!(test_transliterate("⒑"), "10.");
}

#[test]
fn test_period_number_20() {
    assert_eq!(test_transliterate("⒛"), "20.");
}

#[test]
fn test_parenthesized_letter_a() {
    assert_eq!(test_transliterate("⒜"), "(a)");
}

#[test]
fn test_parenthesized_letter_z() {
    assert_eq!(test_transliterate("⒵"), "(z)");
}

#[test]
fn test_parenthesized_kanji_ichi() {
    assert_eq!(test_transliterate("㈠"), "(一)");
}

#[test]
fn test_parenthesized_kanji_getsu() {
    assert_eq!(test_transliterate("㈪"), "(月)");
}

#[test]
fn test_parenthesized_kanji_kabu() {
    assert_eq!(test_transliterate("㈱"), "(株)");
}

#[test]
fn test_japanese_unit_apaato() {
    assert_eq!(test_transliterate("㌀"), "アパート");
}

#[test]
fn test_japanese_unit_kiro() {
    assert_eq!(test_transliterate("㌔"), "キロ");
}

#[test]
fn test_japanese_unit_meetoru() {
    assert_eq!(test_transliterate("㍍"), "メートル");
}

#[test]
fn test_scientific_unit_hpa() {
    assert_eq!(test_transliterate("㍱"), "hPa");
}

#[test]
fn test_scientific_unit_khz() {
    assert_eq!(test_transliterate("㎑"), "kHz");
}

#[test]
fn test_scientific_unit_kg() {
    assert_eq!(test_transliterate("㎏"), "kg");
}

#[test]
fn test_combined_control_and_numbers() {
    assert_eq!(test_transliterate("␉⑴␠⒈"), "HT(1)SP1.");
}

#[test]
fn test_combined_with_regular_text() {
    assert_eq!(test_transliterate("Hello ⑴ World ␉"), "Hello (1) World HT");
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
fn test_sequence_of_combined_characters() {
    assert_eq!(test_transliterate("␀␁␂␃␄"), "NULSOHSTXETXEOT");
}

#[test]
fn test_japanese_months() {
    assert_eq!(test_transliterate("㋀㋁㋂"), "1月2月3月");
}

#[test]
fn test_japanese_units_combinations() {
    assert_eq!(test_transliterate("㌀㌁㌂"), "アパートアルファアンペア");
}

#[test]
fn test_scientific_measurements() {
    assert_eq!(test_transliterate("\u{3378}\u{3379}\u{337a}"), "dm2dm3IU");
}

#[test]
fn test_mixed_content() {
    assert_eq!(
        test_transliterate("Text ⑴ with ␉ combined ㈱ characters ㍍"),
        "Text (1) with HT combined (株) characters メートル"
    );
}

#[test]
fn test_unicode_characters_preserved() {
    assert_eq!(
        test_transliterate("こんにちは⑴世界␉です"),
        "こんにちは(1)世界HTです"
    );
}

#[test]
fn test_newline_and_tab_preserved() {
    assert_eq!(test_transliterate("Line1\nLine2\tTab"), "Line1\nLine2\tTab");
}
