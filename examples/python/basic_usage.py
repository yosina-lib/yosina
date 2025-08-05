#!/usr/bin/env python3
"""
Basic usage example for Yosina Python library.
This example demonstrates the fundamental transliteration functionality
as shown in the README documentation.
"""

from yosina import make_transliterator, TransliterationRecipe


def main() -> None:
    """Demonstrate basic transliteration using recipes."""
    print("=== Yosina Python Basic Usage Example ===\n")

    # Create a recipe with desired transformations (matching README example)
    recipe = TransliterationRecipe(
        kanji_old_new=True,
        replace_spaces=True,
        replace_suspicious_hyphens_to_prolonged_sound_marks=True,
        replace_circled_or_squared_characters=True,
        replace_combined_characters=True,
        replace_japanese_iteration_marks=True,  # Expand iteration marks
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
    
    # Demonstrate Japanese iteration marks expansion
    print("\n--- Japanese Iteration Marks Examples ---")
    iteration_examples = [
        "佐々木",  # kanji iteration
        "すゝき",  # hiragana iteration
        "いすゞ",  # hiragana voiced iteration
        "サヽキ",  # katakana iteration
        "ミスヾ",  # katakana voiced iteration
    ]
    
    for text in iteration_examples:
        result = transliterator(text)
        print(f"{text} → {result}")
    
    # Demonstrate hiragana to katakana conversion separately
    print("\n--- Hiragana to Katakana Conversion ---")
    # Create a separate recipe for just hiragana to katakana conversion
    hira_kata_recipe = TransliterationRecipe(
        hira_kata="hira-to-kata",  # Convert hiragana to katakana
    )
    
    hira_kata_transliterator = make_transliterator(hira_kata_recipe)
    
    hira_kata_examples = [
        "ひらがな",  # pure hiragana
        "これはひらがなです",  # hiragana sentence
        "ひらがなとカタカナ",  # mixed hiragana and katakana
    ]
    
    for text in hira_kata_examples:
        result = hira_kata_transliterator(text)
        print(f"{text} → {result}")
    
    # Also demonstrate katakana to hiragana conversion
    print("\n--- Katakana to Hiragana Conversion ---")
    kata_hira_recipe = TransliterationRecipe(
        hira_kata="kata-to-hira",  # Convert katakana to hiragana
    )
    
    kata_hira_transliterator = make_transliterator(kata_hira_recipe)
    
    kata_hira_examples = [
        "カタカナ",  # pure katakana
        "コレハカタカナデス",  # katakana sentence
        "カタカナとひらがな",  # mixed katakana and hiragana
    ]
    
    for text in kata_hira_examples:
        result = kata_hira_transliterator(text)
        print(f"{text} → {result}")

if __name__ == "__main__":
    main()
