"""Tests for Japanese iteration marks transliterator."""

import pytest

from yosina.chars import build_char_list, from_chars
from yosina.transliterators.japanese_iteration_marks import (
    Transliterator as JapaneseIterationMarksTransliterator,
)


@pytest.mark.parametrize(
    "input_str,expected",
    [
        # Hiragana repetition mark ゝ - valid cases
        ("かゝ", "かか"),
        ("きゝ", "きき"),
        ("すゝ", "すす"),
        ("たゝ", "たた"),
        ("なゝ", "なな"),
        ("はゝ", "はは"),
        ("まゝ", "まま"),
        ("やゝ", "やや"),
        ("らゝ", "らら"),
        ("わゝ", "わわ"),
        # Hiragana repetition mark ゝ - invalid cases (should remain unchanged)
        ("んゝ", "んゝ"),  # hatsuon cannot be repeated
        ("っゝ", "っゝ"),  # sokuon cannot be repeated
        ("ぱゝ", "ぱゝ"),  # semi-voiced character cannot be repeated
        # Voiced character followed by unvoiced iteration mark
        ("がゝ", "がか"),  # voiced character followed by unvoiced mark
        ("づゝ", "づつ"),  # voiced character can be iterated as unvoiced
        # Hiragana voiced repetition mark ゞ - valid cases
        ("かゞ", "かが"),
        ("きゞ", "きぎ"),
        ("くゞ", "くぐ"),
        ("さゞ", "さざ"),
        ("しゞ", "しじ"),
        ("たゞ", "ただ"),
        ("はゞ", "はば"),
        # Hiragana voiced repetition mark ゞ - invalid cases
        ("あゞ", "あゞ"),  # 'あ' cannot be voiced
        ("んゞ", "んゞ"),  # hatsuon cannot be repeated
        ("っゞ", "っゞ"),  # sokuon cannot be repeated
        # Voiced character followed by voiced iteration mark
        ("がゞ", "がが"),  # already voiced character
        # Katakana repetition mark ヽ - valid cases
        ("カヽ", "カカ"),
        ("キヽ", "キキ"),
        ("スヽ", "スス"),
        ("タヽ", "タタ"),
        # Katakana repetition mark ヽ - invalid cases
        ("ンヽ", "ンヽ"),  # hatsuon cannot be repeated
        ("ッヽ", "ッヽ"),  # sokuon cannot be repeated
        ("パヽ", "パヽ"),  # semi-voiced character cannot be repeated
        # Katakana voiced repetition mark ヾ - valid cases
        ("カヾ", "カガ"),
        ("キヾ", "キギ"),
        ("クヾ", "クグ"),
        ("サヾ", "サザ"),
        ("タヾ", "タダ"),
        ("ハヾ", "ハバ"),
        # Katakana voiced repetition mark ヾ - invalid cases
        ("アヾ", "アヾ"),  # 'ア' cannot be voiced
        # Katakana voiced character with iteration marks
        ("ガヾ", "ガガ"),  # already voiced character
        # Kanji repetition mark 々 - valid cases
        ("人々", "人人"),
        ("山々", "山山"),
        ("木々", "木木"),
        ("日々", "日日"),
        # Kanji repetition mark 々 - invalid cases
        ("か々", "か々"),  # hiragana before 々
        ("カ々", "カ々"),  # katakana before 々
        # Edge cases and combinations
        ("かゝきゝ", "かかきき"),
        ("かゞきゞ", "かがきぎ"),
        ("カヽキヽ", "カカキキ"),
        ("カヾキヾ", "カガキギ"),
        ("人々山々", "人人山山"),
        # Mixed script cases
        ("こゝろ、コヽロ、其々", "こころ、ココロ、其其"),
        # No previous character cases
        ("ゝ", "ゝ"),  # no previous character
        ("ゞ", "ゞ"),  # no previous character
        ("ヽ", "ヽ"),  # no previous character
        ("ヾ", "ヾ"),  # no previous character
        ("々", "々"),  # no previous character
        # Complex sentences
        ("私はこゝで勉強します", "私はここで勉強します"),
        ("トヽロのキヽ", "トトロのキキ"),
        ("山々の木々", "山山の木木"),
        # Vertical kana repeat marks (U+3031, U+3032, U+3033, U+3034)
        # U+3031 〱 - vertical hiragana repeat mark
        ("か〱", "かか"),
        ("き〱", "きき"),
        ("が〱", "がか"),  # voiced character followed by unvoiced vertical mark
        ("ん〱", "ん〱"),  # hatsuon cannot be repeated
        ("っ〱", "っ〱"),  # sokuon cannot be repeated
        # U+3032 〲 - vertical hiragana voiced repeat mark
        ("か〲", "かが"),
        ("き〲", "きぎ"),
        ("が〲", "がが"),  # voiced character followed by voiced vertical mark
        ("あ〲", "あ〲"),  # 'あ' cannot be voiced
        # U+3033 〳 - vertical katakana repeat mark
        ("カ〳", "カカ"),
        ("キ〳", "キキ"),
        ("ガ〳", "ガカ"),  # voiced character followed by unvoiced vertical mark
        ("ン〳", "ン〳"),  # hatsuon cannot be repeated
        ("ッ〳", "ッ〳"),  # sokuon cannot be repeated
        # U+3034 〴 - vertical katakana voiced repeat mark
        ("カ〴", "カガ"),
        ("キ〴", "キギ"),
        ("ガ〴", "ガガ"),  # voiced character followed by voiced vertical mark
        ("ア〴", "ア〴"),  # 'ア' cannot be voiced
        # Mixed vertical marks with regular text
        ("こ〱もコ〳ロも", "ここもココロも"),
        ("は〲とハ〴", "はばとハバ"),
        # Vertical marks at beginning (no previous character)
        ("〱", "〱"),  # no previous character
        ("〲", "〲"),  # no previous character
        ("〳", "〳"),  # no previous character
        ("〴", "〴"),  # no previous character
        # Katakana voiced
        ("ガヽ", "ガカ"),  # voiced katakana with unvoiced iteration mark
    ],
)
def test_japanese_iteration_marks(input_str: str, expected: str) -> None:
    """Test Japanese iteration marks transliteration."""
    transliterator = JapaneseIterationMarksTransliterator()
    result = from_chars(transliterator(build_char_list(input_str)))
    assert result == expected
