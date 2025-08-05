#!/usr/bin/env python3
"""
Basic usage example for Yosina Python library.
This example demonstrates the fundamental transliteration functionality.
"""

from yosina import make_transliterator, TransliteratorRecipe


def main() -> None:
    """Demonstrate basic transliteration using recipes."""
    print("=== Yosina Python Basic Usage Example ===\n")

    # Create a simple recipe for kanji old-to-new conversion
    recipe = TransliteratorRecipe(kanji_old_new=True)
    transliterator = make_transliterator(recipe)

    # Test text with old-style kanji
    test_text = "舊字體の變換テスト"
    result = transliterator(test_text)

    print(f"Original: {test_text}")
    print(f"Result:   {result}")

    # More comprehensive example
    print("\n--- Comprehensive Example ---")

    comprehensive_recipe = TransliteratorRecipe(
        kanji_old_new=True,
        replace_spaces=True,
        replace_suspicious_hyphens_to_prolonged_sound_marks=True,
        to_fullwidth=True,
        combine_decomposed_hiraganas_and_katakanas=True,
        replace_radicals=True,
        replace_circled_or_squared_characters=True,
        replace_combined_characters=True,
    )

    comprehensive_transliterator = make_transliterator(comprehensive_recipe)

    # Test with various Japanese text issues
    test_cases = [
        ("hello　world", "Ideographic space"),
        ("カタカナ-テスト", "Suspicious hyphen"),
        ("ABC123", "Half-width to full-width"),
        ("舊字體の變換テスト", "Old kanji"),
        ("ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana"),
        ("①②③ⒶⒷⒸ", "Circled characters"),
        ("㋿㍿", "CJK compatibility characters"),
    ]

    for test_case, description in test_cases:
        result = comprehensive_transliterator(test_case)
        print(f"{description}: '{test_case}' → '{result}'")


if __name__ == "__main__":
    main()
