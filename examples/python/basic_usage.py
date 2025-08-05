#!/usr/bin/env python3
"""
Basic usage example for Yosina Python library.
This example demonstrates the fundamental transliteration functionality
as shown in the README documentation.
"""

from yosina import make_transliterator, TransliteratorRecipe


def main() -> None:
    """Demonstrate basic transliteration using recipes."""
    print("=== Yosina Python Basic Usage Example ===\n")

    # Create a recipe with desired transformations (matching README example)
    recipe = TransliteratorRecipe(
        kanji_old_new=True,
        replace_spaces=True,
        replace_suspicious_hyphens_to_prolonged_sound_marks=True,
        replace_circled_or_squared_characters=True,
        replace_combined_characters=True,
        to_fullwidth=True,
    )
    
    # Create the transliterator
    transliterator = make_transliterator(recipe)
    
    # Use it with various special characters (matching README example)
    input_text = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"  # circled numbers, letters, space, combined characters
    result = transliterator(input_text)
    
    print(f"Input:  {input_text}")
    print(f"Output: {result}")
    print("Expected: （１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和")
    
    # Convert old kanji to new
    print("\n--- Old Kanji to New ---")
    old_kanji = "舊字體"
    result = transliterator(old_kanji)
    print(f"Input:  {old_kanji}")
    print(f"Output: {result}")
    print("Expected: 旧字体")
    
    # Convert half-width katakana to full-width
    print("\n--- Half-width to Full-width ---")
    half_width = "ﾃｽﾄﾓｼﾞﾚﾂ"
    result = transliterator(half_width)
    print(f"Input:  {half_width}")
    print(f"Output: {result}")
    print("Expected: テストモジレツ")

if __name__ == "__main__":
    main()
