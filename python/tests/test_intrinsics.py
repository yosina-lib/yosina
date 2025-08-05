"""Tests for intrinsics functionality ported from TypeScript."""

from yosina.chars import build_char_list, from_chars
from yosina.intrinsics import make_chained_transliterator


def test_make_chained_transliterator():
    """Test creating chained transliterators."""
    # This test mirrors the JavaScript test from intrinsics.test.ts
    transliterator = make_chained_transliterator(
        [
            "mathematical-alphanumerics",
            "hyphens",
            ("prolonged-sound-marks", {"replace_prolonged_marks_following_alnums": True}),
        ]
    )

    input_str = "\U0001d583１\u002d\u002d\u002d１\u002d\u30fc\U0001d7d9勇気爆発ﾊﾞ\u2015ﾝプレイバ\u2015ン１\u30fc\u30fc"
    expected = "X１\uff0d\uff0d\uff0d１\uff0d\uff0d1勇気爆発ﾊﾞ\uff70ﾝプレイバ\u30fcン１\uff0d\uff0d"

    result = from_chars(transliterator(build_char_list(input_str)))
    assert result == expected
