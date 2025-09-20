import pytest

from yosina.chars import build_char_list, from_chars
from yosina.transliterators.roman_numerals import Transliterator as RomanNumeralsTransliterator
from yosina.types import Transliterator


@pytest.fixture
def transliterator() -> RomanNumeralsTransliterator:
    return RomanNumeralsTransliterator()


@pytest.mark.parametrize(
    "expected,input_str,description",
    [
        ("I", "Ⅰ", "Roman I"),
        ("II", "Ⅱ", "Roman II"),
        ("III", "Ⅲ", "Roman III"),
        ("IV", "Ⅳ", "Roman IV"),
        ("V", "Ⅴ", "Roman V"),
        ("VI", "Ⅵ", "Roman VI"),
        ("VII", "Ⅶ", "Roman VII"),
        ("VIII", "Ⅷ", "Roman VIII"),
        ("IX", "Ⅸ", "Roman IX"),
        ("X", "Ⅹ", "Roman X"),
        ("XI", "Ⅺ", "Roman XI"),
        ("XII", "Ⅻ", "Roman XII"),
        ("L", "Ⅼ", "Roman L"),
        ("C", "Ⅽ", "Roman C"),
        ("D", "Ⅾ", "Roman D"),
        ("M", "Ⅿ", "Roman M"),
    ],
)
def test_uppercase_roman_numerals(
    transliterator: Transliterator, expected: str, input_str: str, description: str
) -> None:
    """Test conversion of uppercase Roman numerals to ASCII."""
    chars = build_char_list(input_str)
    result = transliterator(chars)
    assert from_chars(result) == expected


@pytest.mark.parametrize(
    "expected,input_str,description",
    [
        ("i", "ⅰ", "Roman i"),
        ("ii", "ⅱ", "Roman ii"),
        ("iii", "ⅲ", "Roman iii"),
        ("iv", "ⅳ", "Roman iv"),
        ("v", "ⅴ", "Roman v"),
        ("vi", "ⅵ", "Roman vi"),
        ("vii", "ⅶ", "Roman vii"),
        ("viii", "ⅷ", "Roman viii"),
        ("ix", "ⅸ", "Roman ix"),
        ("x", "ⅹ", "Roman x"),
        ("xi", "ⅺ", "Roman xi"),
        ("xii", "ⅻ", "Roman xii"),
        ("l", "ⅼ", "Roman l"),
        ("c", "ⅽ", "Roman c"),
        ("d", "ⅾ", "Roman d"),
        ("m", "ⅿ", "Roman m"),
    ],
)
def test_lowercase_roman_numerals(
    transliterator: Transliterator, expected: str, input_str: str, description: str
) -> None:
    """Test conversion of lowercase Roman numerals to ASCII."""
    chars = build_char_list(input_str)
    result = transliterator(chars)
    assert from_chars(result) == expected


@pytest.mark.parametrize(
    "expected,input_str,description",
    [
        ("Year XII", "Year Ⅻ", "Year with Roman numeral"),
        ("Chapter iv", "Chapter ⅳ", "Chapter with lowercase Roman"),
        ("Section III.A", "Section Ⅲ.A", "Section with Roman and period"),
        ("I II III", "Ⅰ Ⅱ Ⅲ", "Multiple uppercase Romans"),
        ("i, ii, iii", "ⅰ, ⅱ, ⅲ", "Multiple lowercase Romans"),
    ],
)
def test_mixed_text(transliterator: Transliterator, expected: str, input_str: str, description: str) -> None:
    """Test handling of mixed text with Roman numerals."""
    chars = build_char_list(input_str)
    result = transliterator(chars)
    assert from_chars(result) == expected


@pytest.mark.parametrize(
    "expected,input_str,description",
    [
        ("", "", "Empty string"),
        ("ABC123", "ABC123", "No Roman numerals"),
        ("IIIIII", "ⅠⅡⅢ", "Consecutive Romans"),
    ],
)
def test_edge_cases(transliterator: Transliterator, expected: str, input_str: str, description: str) -> None:
    """Test edge cases."""
    chars = build_char_list(input_str)
    result = transliterator(chars)
    assert from_chars(result) == expected
