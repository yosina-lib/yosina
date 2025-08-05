"""Tests for combined transliterator chains."""

from yosina.chars import build_char_list, from_chars
from yosina.transliterators.ivs_svs_base import Transliterator as IvsSvsBaseTransliterator
from yosina.transliterators.kanji_old_new import Transliterator as KanjiOldNewTransliterator


def test_combination_kanji_ivs_chain():
    """Test combination of kanji-old-new and IVS/SVS transliterators."""
    # First apply IVS mode to add variation selector
    ivs_add = IvsSvsBaseTransliterator(mode="ivs-or-svs")

    # Then apply kanji old-new conversion
    kanji_convert = KanjiOldNewTransliterator()

    # Finally apply IVS base mode to remove selectors
    ivs_remove = IvsSvsBaseTransliterator(mode="base")

    # Chain the transliterators: input -> ivs_add -> kanji_convert -> ivs_remove
    input_chars = build_char_list("檜")
    step1 = ivs_add(input_chars)
    step2 = kanji_convert(step1)
    result = ivs_remove(step2)

    assert from_chars(result) == "桧"
