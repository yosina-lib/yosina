use yosina::char::CharPool;
use yosina::transliterator::TransliteratorFactory;
use yosina::transliterators::JapaneseIterationMarksTransliteratorOptions;

fn main() {
    // Create a transliterator instance
    let options = JapaneseIterationMarksTransliteratorOptions::default();
    let transliterator = options.new_transliterator().unwrap();

    // Example texts with iteration marks
    let examples = vec![
        ("さゝ", "Hiragana repetition"),
        ("はゞ", "Hiragana voiced repetition"),
        ("ココヽロ", "Katakana repetition"),
        ("ウヾ", "Katakana voiced repetition"),
        ("人々", "Kanji repetition"),
        ("日々の暮らし", "Daily life with kanji repetition"),
        ("こゝろ、コヽロ、其々", "Mixed text"),
    ];

    for (input, description) in examples {
        println!("\n{description}: {input}");

        // Create a character pool and build character array
        let mut pool = CharPool::new();
        let input_chars = pool.build_char_array(input);

        // Transliterate
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();

        // Convert back to string
        let result_string = yosina::char::from_chars(result.iter().cloned());

        println!("  → {result_string}");
    }

    println!("\nInvalid combinations (remain unchanged):");

    let invalid_examples = vec![
        ("カゝ", "Hiragana mark after katakana"),
        ("かヽ", "Katakana mark after hiragana"),
        ("んゝ", "Cannot repeat hatsuon"),
        ("っゝ", "Cannot repeat sokuon"),
        ("がゞ", "Cannot voice already voiced character"),
    ];

    for (input, description) in invalid_examples {
        let mut pool = CharPool::new();
        let input_chars = pool.build_char_array(input);
        let result = transliterator
            .transliterate(&mut pool, &input_chars)
            .unwrap();
        let result_string = yosina::char::from_chars(result.iter().cloned());

        println!("  {input} → {result_string} ({description})");
    }
}
