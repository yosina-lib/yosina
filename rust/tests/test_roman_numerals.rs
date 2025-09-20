use yosina::char::{from_chars, CharPool};
use yosina::transliterator::Transliterator;
use yosina::transliterators::RomanNumeralsTransliterator;

fn test_transliterate(input: &str) -> String {
    let mut pool = CharPool::new();
    let chars = pool.build_char_array(input);
    let transliterator = RomanNumeralsTransliterator::new();
    let result = transliterator.transliterate(&mut pool, &chars).unwrap();
    from_chars(result)
}

// Test data for uppercase Roman numerals
const UPPERCASE_TEST_CASES: &[(&str, &str, &str)] = &[
    ("Ⅰ", "I", "Roman I"),
    ("Ⅱ", "II", "Roman II"),
    ("Ⅲ", "III", "Roman III"),
    ("Ⅳ", "IV", "Roman IV"),
    ("Ⅴ", "V", "Roman V"),
    ("Ⅵ", "VI", "Roman VI"),
    ("Ⅶ", "VII", "Roman VII"),
    ("Ⅷ", "VIII", "Roman VIII"),
    ("Ⅸ", "IX", "Roman IX"),
    ("Ⅹ", "X", "Roman X"),
    ("Ⅺ", "XI", "Roman XI"),
    ("Ⅻ", "XII", "Roman XII"),
    ("Ⅼ", "L", "Roman L"),
    ("Ⅽ", "C", "Roman C"),
    ("Ⅾ", "D", "Roman D"),
    ("Ⅿ", "M", "Roman M"),
];

// Test data for lowercase Roman numerals
const LOWERCASE_TEST_CASES: &[(&str, &str, &str)] = &[
    ("ⅰ", "i", "Roman i"),
    ("ⅱ", "ii", "Roman ii"),
    ("ⅲ", "iii", "Roman iii"),
    ("ⅳ", "iv", "Roman iv"),
    ("ⅴ", "v", "Roman v"),
    ("ⅵ", "vi", "Roman vi"),
    ("ⅶ", "vii", "Roman vii"),
    ("ⅷ", "viii", "Roman viii"),
    ("ⅸ", "ix", "Roman ix"),
    ("ⅹ", "x", "Roman x"),
    ("ⅺ", "xi", "Roman xi"),
    ("ⅻ", "xii", "Roman xii"),
    ("ⅼ", "l", "Roman l"),
    ("ⅽ", "c", "Roman c"),
    ("ⅾ", "d", "Roman d"),
    ("ⅿ", "m", "Roman m"),
];

// Test data for mixed text cases
const MIXED_TEXT_TEST_CASES: &[(&str, &str, &str)] = &[
    ("Year Ⅻ", "Year XII", "Year with Roman numeral"),
    ("Chapter ⅳ", "Chapter iv", "Chapter with lowercase Roman"),
    (
        "Section Ⅲ.A",
        "Section III.A",
        "Section with Roman and period",
    ),
    ("Ⅰ Ⅱ Ⅲ", "I II III", "Multiple uppercase Romans"),
    ("ⅰ, ⅱ, ⅲ", "i, ii, iii", "Multiple lowercase Romans"),
];

// Test data for edge cases
const EDGE_TEST_CASES: &[(&str, &str, &str)] = &[
    ("", "", "Empty string"),
    ("ABC123", "ABC123", "No Roman numerals"),
    ("ⅠⅡⅢ", "IIIIII", "Consecutive Romans"),
    (
        "Book Ⅰ: Chapter ⅰ, Section Ⅱ.ⅲ and Part Ⅳ",
        "Book I: Chapter i, Section II.iii and Part IV",
        "Complex mixed text with multiple Romans",
    ),
];

#[test]
fn test_uppercase_roman_numerals() {
    for (input, expected, description) in UPPERCASE_TEST_CASES {
        let result = test_transliterate(input);
        assert_eq!(result, *expected, "Failed for test case: {}", description);
    }
}

#[test]
fn test_lowercase_roman_numerals() {
    for (input, expected, description) in LOWERCASE_TEST_CASES {
        let result = test_transliterate(input);
        assert_eq!(result, *expected, "Failed for test case: {}", description);
    }
}

#[test]
fn test_mixed_text() {
    for (input, expected, description) in MIXED_TEXT_TEST_CASES {
        let result = test_transliterate(input);
        assert_eq!(result, *expected, "Failed for test case: {}", description);
    }
}

#[test]
fn test_edge_cases() {
    for (input, expected, description) in EDGE_TEST_CASES {
        let result = test_transliterate(input);
        assert_eq!(result, *expected, "Failed for test case: {}", description);
    }
}
