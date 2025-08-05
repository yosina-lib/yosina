"""Tests for JIS X 0201 and fullwidth/halfwidth conversion transliterator."""

from typing import Any

import pytest

from yosina.chars import build_char_list, from_chars
from yosina.transliterators.jisx0201_and_alike import Transliterator as Jisx0201AndAlikeTransliterator


@pytest.mark.parametrize(
    "input_str,expected,options",
    [
        # Basic fullwidth to halfwidth conversion - no conversion
        (
            "字！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝〜ァィゥェォャュョッヵヶアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー\u30a0",
            "字！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝〜ァィゥェォャュョッヵヶアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー\u30a0",
            {
                "fullwidth_to_halfwidth": True,
                "convert_gl": False,
                "convert_gr": False,
            },
        ),
        # Convert GL (Graphics Left) - ASCII characters
        (
            "字！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝〜ァィゥェォャュョッヵヶアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー\u30a0",
            "字!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ァィゥェォャュョッヵヶアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー=",
            {
                "fullwidth_to_halfwidth": True,
                "convert_gl": True,
                "convert_gr": False,
            },
        ),
        # Convert GR (Graphics Right) - Katakana characters
        (
            "字！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝〜ァィゥェォャュョッヵヶアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー\u30a0",
            "字！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝〜ｧｨｩｪｫｬｭｮｯヵヶｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ\u30a0",
            {
                "fullwidth_to_halfwidth": True,
                "convert_gl": False,
                "convert_gr": True,
            },
        ),
        # Convert both GL and GR
        (
            "字！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝〜ァィゥェォャュョッヵヶアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー\u30a0",
            "字!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ｧｨｩｪｫｬｭｮｯヵヶｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ=",
            {
                "fullwidth_to_halfwidth": True,
                "convert_gl": True,
                "convert_gr": True,
            },
        ),
        # Convert both GL and GR, without unsafe specials
        (
            "字！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝〜ァィゥェォャュョッヵヶアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー\u30a0",
            "字!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ｧｨｩｪｫｬｭｮｯヵヶｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ\u30a0",
            {
                "fullwidth_to_halfwidth": True,
                "convert_unsafe_specials": False,
                "convert_gl": True,
                "convert_gr": True,
            },
        ),
    ],
)
def test_fullwidth_to_halfwidth_conversion(input_str: str, expected: str, options: dict[str, Any]) -> None:
    """Test fullwidth to halfwidth conversion."""
    transliterator = Jisx0201AndAlikeTransliterator(**options)
    result = from_chars(transliterator(build_char_list(input_str)))
    assert result == expected


@pytest.mark.parametrize(
    "input_str,expected,options",
    [
        # Katakana conversion without voice marks combining
        (
            "字ァィゥェォャュョッヵヶアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー\u30a0",
            "字ｧｨｩｪｫｬｭｮｯヵヶｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ\u30a0",
            {
                "fullwidth_to_halfwidth": True,
                "convert_unsafe_specials": False,
                "convert_hiraganas": False,
            },
        ),
        # Hiragana preservation
        (
            "ぁぃぅぇぉゃゅょっあいうえおかきくけこがぎぐげごさしすせそざじずぜぞたちつてとだぢづでどなにぬねのはひふへほばびぶべぼぱぴぷぺぽまみむめもらりるれろやゆよわをんー\u30a0",
            "ぁぃぅぇぉゃゅょっあいうえおかきくけこがぎぐげごさしすせそざじずぜぞたちつてとだぢづでどなにぬねのはひふへほばびぶべぼぱぴぷぺぽまみむめもらりるれろやゆよわをんｰ\u30a0",
            {
                "fullwidth_to_halfwidth": True,
                "convert_unsafe_specials": False,
                "convert_hiraganas": False,
            },
        ),
        # Convert unsafe specials (U+30A0 -> =)
        (
            "ァィゥェォャュョッヵヶアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー\u30a0",
            "ｧｨｩｪｫｬｭｮｯヵヶｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ=",
            {
                "fullwidth_to_halfwidth": True,
                "convert_unsafe_specials": True,
                "convert_hiraganas": False,
            },
        ),
        # Convert hiraganas to halfwidth katakana
        (
            "ぁぃぅぇぉゃゅょっあいうえおかきくけこがぎぐげごさしすせそざじずぜぞたちつてとだぢづでどなにぬねのはひふへほばびぶべぼぱぴぷぺぽまみむめもらりるれろやゆよわをんー\u30a0",
            "ｧｨｩｪｫｬｭｮｯｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ\u30a0",
            {
                "fullwidth_to_halfwidth": True,
                "convert_unsafe_specials": False,
                "convert_hiraganas": True,
            },
        ),
        # Convert hiraganas and unsafe specials
        (
            "ぁぃぅぇぉゃゅょっあいうえおかきくけこがぎぐげごさしすせそざじずぜぞたちつてとだぢづでどなにぬねのはひふへほばびぶべぼぱぴぷぺぽまみむめもらりるれろやゆよわをんー\u30a0",
            "ｧｨｩｪｫｬｭｮｯｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ=",
            {
                "fullwidth_to_halfwidth": True,
                "convert_unsafe_specials": True,
                "convert_hiraganas": True,
            },
        ),
        # Special character conversions
        ("＼", "\\", {"fullwidth_to_halfwidth": True, "u005c_as_backslash": True}),
    ],
)
def test_fullwidth_to_halfwidth_special_options(input_str: str, expected: str, options: dict[str, Any]) -> None:
    """Test fullwidth to halfwidth conversion with special options."""
    transliterator = Jisx0201AndAlikeTransliterator(**options)
    result = from_chars(transliterator(build_char_list(input_str)))
    assert result == expected


@pytest.mark.parametrize(
    "input_str,expected,options",
    [
        # Halfwidth to fullwidth without voice mark combining
        (
            "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ｧｨｩｪｫｬｭｮｯｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ",
            "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ァィゥェォャュョッアイウエオカキクケコカ゛キ゛ク゛ケ゛コ゛サシスセソサ゛シ゛ス゛セ゛ソ゛タチツテトタ゛チ゛ツ゛テ゛ト゛ナニヌネノハヒフヘホハ゛ヒ゛フ゛ヘ゛ホ゛ハ゜ヒ゜フ゜ヘ゜ホ゜マミムメモラリルレロヤユヨワヲンー",
            {
                "fullwidth_to_halfwidth": False,
                "convert_gl": False,
                "convert_gr": True,
                "combine_voiced_sound_marks": False,
            },
        ),
        # Halfwidth to fullwidth with voice mark combining
        (
            "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ｧｨｩｪｫｬｭｮｯｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ",
            "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ァィゥェォャュョッアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー",
            {
                "fullwidth_to_halfwidth": False,
                "convert_gl": False,
                "convert_gr": True,
                "combine_voiced_sound_marks": True,
            },
        ),
        # Convert GL + GR with voice mark combining
        (
            "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ｧｨｩｪｫｬｭｮｯｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ",
            "！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［￥］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝\uff5eァィゥェォャュョッアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー",
            {
                "fullwidth_to_halfwidth": False,
                "convert_gl": True,
                "convert_gr": True,
                "combine_voiced_sound_marks": True,
            },
        ),
        # Yen sign conversion
        (
            "¥",
            "￥",
            {
                "fullwidth_to_halfwidth": False,
                "convert_gl": True,
                "convert_gr": True,
                "combine_voiced_sound_marks": True,
            },
        ),
        # Backslash with special handling
        (
            "!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~ｧｨｩｪｫｬｭｮｯｱｲｳｴｵｶｷｸｹｺｶﾞｷﾞｸﾞｹﾞｺﾞｻｼｽｾｿｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾁﾂﾃﾄﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟﾏﾐﾑﾒﾓﾗﾘﾙﾚﾛﾔﾕﾖﾜｦﾝｰ",
            "！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［＼］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝\uff5eァィゥェォャュョッアイウエオカキクケコガギグゲゴサシスセソザジズゼゾタチツテトダヂヅデドナニヌネノハヒフヘホバビブベボパピプペポマミムメモラリルレロヤユヨワヲンー",
            {
                "fullwidth_to_halfwidth": False,
                "convert_gl": True,
                "convert_gr": True,
                "combine_voiced_sound_marks": True,
                "u005c_as_backslash": True,
            },
        ),
        # Tilde as wave dash
        (
            "~",
            "\u301c",
            {
                "fullwidth_to_halfwidth": False,
                "convert_gl": True,
                "convert_gr": True,
                "combine_voiced_sound_marks": True,
                "u007e_as_wave_dash": True,
            },
        ),
    ],
)
def test_halfwidth_to_fullwidth_conversion(input_str: str, expected: str, options: dict[str, Any]) -> None:
    """Test halfwidth to fullwidth conversion."""
    transliterator = Jisx0201AndAlikeTransliterator(**options)
    result = from_chars(transliterator(build_char_list(input_str)))
    assert result == expected
