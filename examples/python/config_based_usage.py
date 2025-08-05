#!/usr/bin/env python3
"""
Configuration-based usage example for Yosina Python library.
This example demonstrates using direct transliterator configurations.
"""

from yosina import make_transliterator


def main() -> None:
    """Demonstrate transliteration using direct configurations."""
    print("=== Yosina Python Configuration-based Usage Example ===\n")

    # Create transliterator with direct configurations
    configs = [
        ("spaces", {}),
        ("prolonged-sound-marks", {"replace_prolonged_marks_following_alnums": True}),
        ("jisx0201-and-alike", {}),
    ]

    transliterator = make_transliterator(configs)

    print("--- Configuration-based Transliteration ---")

    # Test cases demonstrating different transformations
    test_cases = [
        ("hello　world", "Space normalization"),
        ("カタカナーテスト", "Prolonged sound mark handling"),
        ("ＡＢＣ１２３", "Full-width conversion"),
        ("ﾊﾝｶｸ ｶﾀｶﾅ", "Half-width katakana conversion"),
    ]

    for test_text, description in test_cases:
        result = transliterator(test_text)
        print(f"{description}:")
        print(f"  Input:  '{test_text}'")
        print(f"  Output: '{result}'")
        print()

    # Demonstrate individual transliterators
    print("--- Individual Transliterator Examples ---")

    # Spaces only
    spaces_only = make_transliterator([("spaces", {})])
    space_test = "hello　world　test"  # ideographic spaces
    print(f"Spaces only: '{space_test}' → '{spaces_only(space_test)}'")

    # Kanji old-new only
    kanji_only = make_transliterator(
        [
            ("ivs-svs-base", {"mode": "ivs-or-svs", "charset": "unijis_2004"}),
            ("kanji-old-new", {}),
            ("ivs-svs-base", {"mode": "base", "charset": "unijis_2004"}),
        ]
    )
    kanji_test = "廣島檜"
    print(f"Kanji only: '{kanji_test}' → '{kanji_only(kanji_test)}'")

    # JIS X 0201 conversion only
    jisx0201_only = make_transliterator(
        [("jisx0201-and-alike", {})],
    )
    jisx_test = "ﾊﾛｰ ﾜｰﾙﾄﾞ"
    print(f"JIS X 0201 only: '{jisx_test}' → '{jisx0201_only(jisx_test)}'")


if __name__ == "__main__":
    main()
