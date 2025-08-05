#!/usr/bin/env python3
"""
Advanced usage example for Yosina Python library.
This example demonstrates complex text processing scenarios.
"""

from yosina import make_transliterator, TransliterationRecipe


def main() -> None:
    """Demonstrate advanced transliteration scenarios."""
    print("=== Advanced Yosina Python Usage Examples ===\n")

    # 1. Web scraping text normalization
    print("1. Web Scraping Text Normalization")
    print("   (Typical use case: cleaning scraped Japanese web content)")

    web_scraping_recipe = TransliterationRecipe(
        kanji_old_new=True,
        replace_spaces=True,
        replace_suspicious_hyphens_to_prolonged_sound_marks=True,
        replace_ideographic_annotations=True,
        replace_radicals=True,
        combine_decomposed_hiraganas_and_katakanas=True,
    )

    normalizer = make_transliterator(web_scraping_recipe)

    # Simulate messy web content
    messy_content = [
        ("これは　テスト です。", "Mixed spaces from different sources"),
        ("コンピューター-プログラム", "Suspicious hyphens in katakana"),
        ("古い漢字：廣島、檜、國", "Old-style kanji forms"),
        ("部首：⺅⻌⽊", "CJK radicals instead of regular kanji"),
    ]

    for text, description in messy_content:
        cleaned = normalizer(text)
        print(f"  {description}:")
        print(f"    Before: '{text}'")
        print(f"    After:  '{cleaned}'")
        print()

    # 2. Document standardization
    print("2. Document Standardization")
    print("   (Use case: preparing documents for consistent formatting)")

    document_recipe = TransliterationRecipe(
        to_fullwidth=True,
        replace_spaces=True,
        kanji_old_new=True,
        combine_decomposed_hiraganas_and_katakanas=True,
    )

    normalizer = make_transliterator(document_recipe)

    document_samples = [
        ("Hello World 123", "ASCII text to full-width"),
        ("カ゛", "Decomposed katakana with combining mark"),
        ("檜原村", "Old kanji in place names"),
    ]

    for text, description in document_samples:
        standardized = normalizer(text)
        print(f"  {description}:")
        print(f"    Input:  '{text}'")
        print(f"    Output: '{standardized}'")
        print()

    # 3. Search index preparation
    print("3. Search Index Preparation")
    print("   (Use case: normalizing text for search engines)")

    search_recipe = TransliterationRecipe(
        kanji_old_new=True,
        replace_spaces=True,
        to_halfwidth=True,
        replace_suspicious_hyphens_to_prolonged_sound_marks=True,
    )

    normalizer = make_transliterator(search_recipe)

    search_samples = [
        ("東京スカイツリー", "Famous landmark name"),
        ("プログラミング言語", "Technical terms"),
        ("コンピューター-サイエンス", "Academic field with suspicious hyphen"),
    ]

    for text, description in search_samples:
        normalized = normalizer(text)
        print(f"  {description}:")
        print(f"    Original:   '{text}'")
        print(f"    Normalized: '{normalized}'")
        print()

    # 4. Custom pipeline example
    print("4. Custom Processing Pipeline")
    print("   (Use case: step-by-step text transformation)")

    # Create multiple transliterators for pipeline processing
    steps = [
        ("Spaces", [("spaces", {})]),
        (
            "Old Kanji",
            [
                ("ivs-svs-base", {"mode": "ivs-or-svs", "charset": "unijis_2004"}),
                ("kanji-old-new", {}),
                ("ivs-svs-base", {"mode": "base", "charset": "unijis_2004"}),
            ],
        ),
        (
            "Width",
            [
                ("jisx0201-and-alike", {"u005c_as_yen_sign": False}),
            ],
        ),
        (
            "ProlongedSoundMarks",
            [
                ("prolonged-sound-marks", {}),
            ],
        ),
    ]

    transliterators = [(name, make_transliterator(config)) for name, config in steps]

    pipeline_text = "hello\u3000world ﾃｽﾄ 檜-システム"
    current_text = pipeline_text

    print(f"  Starting text: '{current_text}'")

    for step_name, transliterator in transliterators:
        previous_text = current_text
        current_text = transliterator(current_text)
        if previous_text != current_text:
            print(f"  After {step_name}: '{current_text}'")

    print(f"  Final result: '{current_text}'")

    # 5. Unicode normalization showcase
    print("\n5. Unicode Normalization Showcase")
    print("   (Demonstrating various Unicode edge cases)")

    unicode_recipe = TransliterationRecipe(
        replace_spaces=True,
        replace_mathematical_alphanumerics=True,
        replace_radicals=True,
    )

    normalizer = make_transliterator(unicode_recipe)

    unicode_samples = [
        ("\u2003\u2002\u2000", "Various em/en spaces"),
        ("\u3000\u00a0\u202f", "Ideographic and narrow spaces"),
        ("⺅⻌⽊", "CJK radicals"),
        ("\U0001d400\U0001d401\U0001d402", "Mathematical bold letters"),
    ]

    print("\n   Processing text samples with character codes:\n")
    for text, description in unicode_samples:
        print(f"   {description}:")
        print(f"     Original: '{text}'")

        # Show character codes for clarity
        char_codes = " ".join(f"U+{ord(c):04X}" for c in text)
        print(f"     Codes:    {char_codes}")

        normalized = normalizer(text)
        print(f"     Result:   '{normalized}'")
        print()

    # 6. Performance considerations
    print("6. Performance Considerations")
    print("   (Reusing transliterators for better performance)")

    perf_recipe = TransliterationRecipe(
        kanji_old_new=True,
        replace_spaces=True,
    )

    perf_transliterator = make_transliterator(perf_recipe)

    # Simulate processing multiple texts
    texts = [
        "これはテストです",
        "檜原村は美しい",
        "hello　world",
        "プログラミング",
    ]

    print(f"  Processing {len(texts)} texts with the same transliterator:")
    for i, text in enumerate(texts, 1):
        result = perf_transliterator(text)
        print(f"    {i}: '{text}' → '{result}'")

    print("\n=== Advanced Examples Complete ===")


if __name__ == "__main__":
    main()
