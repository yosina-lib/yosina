"""JIS X 0201 and alike transliterator for fullwidth/halfwidth conversion."""

from collections.abc import Iterable
from functools import cache

from ..chars import Char

__all__ = ["Transliterator"]

# Type alias for cache key
CacheKey = tuple[bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool]

# GL area mapping table (fullwidth to halfwidth)
JISX0201_GL_TABLE = [
    ("\u3000", "\u0020"),  # Ideographic space to space
    ("\uff01", "\u0021"),  # ！ to !
    ("\uff02", "\u0022"),  # ＂ to "
    ("\uff03", "\u0023"),  # ＃ to #
    ("\uff04", "\u0024"),  # ＄ to $
    ("\uff05", "\u0025"),  # ％ to %
    ("\uff06", "\u0026"),  # ＆ to &
    ("\uff07", "\u0027"),  # ＇ to '
    ("\uff08", "\u0028"),  # （ to (
    ("\uff09", "\u0029"),  # ） to )
    ("\uff0a", "\u002a"),  # ＊ to *
    ("\uff0b", "\u002b"),  # ＋ to +
    ("\uff0c", "\u002c"),  # ， to ,
    ("\uff0d", "\u002d"),  # － to -
    ("\uff0e", "\u002e"),  # ． to .
    ("\uff0f", "\u002f"),  # ／ to /
    ("\uff10", "\u0030"),  # ０ to 0
    ("\uff11", "\u0031"),  # １ to 1
    ("\uff12", "\u0032"),  # ２ to 2
    ("\uff13", "\u0033"),  # ３ to 3
    ("\uff14", "\u0034"),  # ４ to 4
    ("\uff15", "\u0035"),  # ５ to 5
    ("\uff16", "\u0036"),  # ６ to 6
    ("\uff17", "\u0037"),  # ７ to 7
    ("\uff18", "\u0038"),  # ８ to 8
    ("\uff19", "\u0039"),  # ９ to 9
    ("\uff1a", "\u003a"),  # ： to :
    ("\uff1b", "\u003b"),  # ； to ;
    ("\uff1c", "\u003c"),  # ＜ to <
    ("\uff1d", "\u003d"),  # ＝ to =
    ("\uff1e", "\u003e"),  # ＞ to >
    ("\uff1f", "\u003f"),  # ？ to ?
    ("\uff20", "\u0040"),  # ＠ to @
    ("\uff21", "\u0041"),  # Ａ to A
    ("\uff22", "\u0042"),  # Ｂ to B
    ("\uff23", "\u0043"),  # Ｃ to C
    ("\uff24", "\u0044"),  # Ｄ to D
    ("\uff25", "\u0045"),  # Ｅ to E
    ("\uff26", "\u0046"),  # Ｆ to F
    ("\uff27", "\u0047"),  # Ｇ to G
    ("\uff28", "\u0048"),  # Ｈ to H
    ("\uff29", "\u0049"),  # Ｉ to I
    ("\uff2a", "\u004a"),  # Ｊ to J
    ("\uff2b", "\u004b"),  # Ｋ to K
    ("\uff2c", "\u004c"),  # Ｌ to L
    ("\uff2d", "\u004d"),  # Ｍ to M
    ("\uff2e", "\u004e"),  # Ｎ to N
    ("\uff2f", "\u004f"),  # Ｏ to O
    ("\uff30", "\u0050"),  # Ｐ to P
    ("\uff31", "\u0051"),  # Ｑ to Q
    ("\uff32", "\u0052"),  # Ｒ to R
    ("\uff33", "\u0053"),  # Ｓ to S
    ("\uff34", "\u0054"),  # Ｔ to T
    ("\uff35", "\u0055"),  # Ｕ to U
    ("\uff36", "\u0056"),  # Ｖ to V
    ("\uff37", "\u0057"),  # Ｗ to W
    ("\uff38", "\u0058"),  # Ｘ to X
    ("\uff39", "\u0059"),  # Ｙ to Y
    ("\uff3a", "\u005a"),  # Ｚ to Z
    ("\uff3b", "\u005b"),  # ［ to [
    ("\uff3d", "\u005d"),  # ］ to ]
    ("\uff3e", "\u005e"),  # ＾ to ^
    ("\uff3f", "\u005f"),  # ＿ to _
    ("\uff40", "\u0060"),  # ｀ to `
    ("\uff41", "\u0061"),  # ａ to a
    ("\uff42", "\u0062"),  # ｂ to b
    ("\uff43", "\u0063"),  # ｃ to c
    ("\uff44", "\u0064"),  # ｄ to d
    ("\uff45", "\u0065"),  # ｅ to e
    ("\uff46", "\u0066"),  # ｆ to f
    ("\uff47", "\u0067"),  # ｇ to g
    ("\uff48", "\u0068"),  # ｈ to h
    ("\uff49", "\u0069"),  # ｉ to i
    ("\uff4a", "\u006a"),  # ｊ to j
    ("\uff4b", "\u006b"),  # ｋ to k
    ("\uff4c", "\u006c"),  # ｌ to l
    ("\uff4d", "\u006d"),  # ｍ to m
    ("\uff4e", "\u006e"),  # ｎ to n
    ("\uff4f", "\u006f"),  # ｏ to o
    ("\uff50", "\u0070"),  # ｐ to p
    ("\uff51", "\u0071"),  # ｑ to q
    ("\uff52", "\u0072"),  # ｒ to r
    ("\uff53", "\u0073"),  # ｓ to s
    ("\uff54", "\u0074"),  # ｔ to t
    ("\uff55", "\u0075"),  # ｕ to u
    ("\uff56", "\u0076"),  # ｖ to v
    ("\uff57", "\u0077"),  # ｗ to w
    ("\uff58", "\u0078"),  # ｘ to x
    ("\uff59", "\u0079"),  # ｙ to y
    ("\uff5a", "\u007a"),  # ｚ to z
    ("\uff5b", "\u007b"),  # ｛ to {
    ("\uff5c", "\u007c"),  # ｜ to |
    ("\uff5d", "\u007d"),  # ｝ to }
]

# Special GL overrides
JISX0201_GL_OVERRIDES = {
    "u005c_as_yen_sign": [("\uffe5", "\u005c")],  # ￥ to \
    "u005c_as_backslash": [("\uff3c", "\u005c")],  # ＼ to \
    "u007e_as_fullwidth_tilde": [("\uff5e", "\u007e")],  # ～ to ~
    "u007e_as_wave_dash": [("\u301c", "\u007e")],  # 〜 to ~
    "u007e_as_overline": [("\u203e", "\u007e")],  # ‾ to ~
    "u007e_as_fullwidth_macron": [("\uffe3", "\u007e")],  # ￣ to ~
    "u00a5_as_yen_sign": [("\uffe5", "\u00a5")],  # ￥ to ¥
}

# GR area mapping table (fullwidth katakana to halfwidth katakana)
JISX0201_GR_TABLE = [
    ("\u3002", "\uff61"),  # 。 to ｡
    ("\u300c", "\uff62"),  # 「 to ｢
    ("\u300d", "\uff63"),  # 」 to ｣
    ("\u3001", "\uff64"),  # 、 to ､
    ("\u30fb", "\uff65"),  # ・ to ･
    ("\u30fc", "\uff70"),  # ー to ｰ
    ("\u309b", "\uff9e"),  # ゛ to ﾞ
    ("\u309c", "\uff9f"),  # ゜ to ﾟ
    # Small kana
    ("\u30a1", "\uff67"),  # ァ to ｧ
    ("\u30a3", "\uff68"),  # ィ to ｨ
    ("\u30a5", "\uff69"),  # ゥ to ｩ
    ("\u30a7", "\uff6a"),  # ェ to ｪ
    ("\u30a9", "\uff6b"),  # ォ to ｫ
    ("\u30e3", "\uff6c"),  # ャ to ｬ
    ("\u30e5", "\uff6d"),  # ュ to ｭ
    ("\u30e7", "\uff6e"),  # ョ to ｮ
    ("\u30c3", "\uff6f"),  # ッ to ｯ
    # Vowels
    ("\u30a2", "\uff71"),  # ア to ｱ
    ("\u30a4", "\uff72"),  # イ to ｲ
    ("\u30a6", "\uff73"),  # ウ to ｳ
    ("\u30a8", "\uff74"),  # エ to ｴ
    ("\u30aa", "\uff75"),  # オ to ｵ
    # K-row
    ("\u30ab", "\uff76"),  # カ to ｶ
    ("\u30ad", "\uff77"),  # キ to ｷ
    ("\u30af", "\uff78"),  # ク to ｸ
    ("\u30b1", "\uff79"),  # ケ to ｹ
    ("\u30b3", "\uff7a"),  # コ to ｺ
    # S-row
    ("\u30b5", "\uff7b"),  # サ to ｻ
    ("\u30b7", "\uff7c"),  # シ to ｼ
    ("\u30b9", "\uff7d"),  # ス to ｽ
    ("\u30bb", "\uff7e"),  # セ to ｾ
    ("\u30bd", "\uff7f"),  # ソ to ｿ
    # T-row
    ("\u30bf", "\uff80"),  # タ to ﾀ
    ("\u30c1", "\uff81"),  # チ to ﾁ
    ("\u30c4", "\uff82"),  # ツ to ﾂ
    ("\u30c6", "\uff83"),  # テ to ﾃ
    ("\u30c8", "\uff84"),  # ト to ﾄ
    # N-row
    ("\u30ca", "\uff85"),  # ナ to ﾅ
    ("\u30cb", "\uff86"),  # ニ to ﾆ
    ("\u30cc", "\uff87"),  # ヌ to ﾇ
    ("\u30cd", "\uff88"),  # ネ to ﾈ
    ("\u30ce", "\uff89"),  # ノ to ﾉ
    # H-row
    ("\u30cf", "\uff8a"),  # ハ to ﾊ
    ("\u30d2", "\uff8b"),  # ヒ to ﾋ
    ("\u30d5", "\uff8c"),  # フ to ﾌ
    ("\u30d8", "\uff8d"),  # ヘ to ﾍ
    ("\u30db", "\uff8e"),  # ホ to ﾎ
    # M-row
    ("\u30de", "\uff8f"),  # マ to ﾏ
    ("\u30df", "\uff90"),  # ミ to ﾐ
    ("\u30e0", "\uff91"),  # ム to ﾑ
    ("\u30e1", "\uff92"),  # メ to ﾒ
    ("\u30e2", "\uff93"),  # モ to ﾓ
    # Y-row
    ("\u30e4", "\uff94"),  # ヤ to ﾔ
    ("\u30e6", "\uff95"),  # ユ to ﾕ
    ("\u30e8", "\uff96"),  # ヨ to ﾖ
    # R-row
    ("\u30e9", "\uff97"),  # ラ to ﾗ
    ("\u30ea", "\uff98"),  # リ to ﾘ
    ("\u30eb", "\uff99"),  # ル to ﾙ
    ("\u30ec", "\uff9a"),  # レ to ﾚ
    ("\u30ed", "\uff9b"),  # ロ to ﾛ
    # W-row
    ("\u30ef", "\uff9c"),  # ワ to ﾜ
    ("\u30f3", "\uff9d"),  # ン to ﾝ
    ("\u30f2", "\uff66"),  # ヲ to ｦ
]

# Voiced letters (dakuten/handakuten combinations)
VOICED_LETTERS_TABLE = [
    ("\u30f4", "\uff73\uff9e"),  # ヴ to ｳﾞ
    # G-row (voiced K)
    ("\u30ac", "\uff76\uff9e"),  # ガ to ｶﾞ
    ("\u30ae", "\uff77\uff9e"),  # ギ to ｷﾞ
    ("\u30b0", "\uff78\uff9e"),  # グ to ｸﾞ
    ("\u30b2", "\uff79\uff9e"),  # ゲ to ｹﾞ
    ("\u30b4", "\uff7a\uff9e"),  # ゴ to ｺﾞ
    # Z-row (voiced S)
    ("\u30b6", "\uff7b\uff9e"),  # ザ to ｻﾞ
    ("\u30b8", "\uff7c\uff9e"),  # ジ to ｼﾞ
    ("\u30ba", "\uff7d\uff9e"),  # ズ to ｽﾞ
    ("\u30bc", "\uff7e\uff9e"),  # ゼ to ｾﾞ
    ("\u30be", "\uff7f\uff9e"),  # ゾ to ｿﾞ
    # D-row (voiced T)
    ("\u30c0", "\uff80\uff9e"),  # ダ to ﾀﾞ
    ("\u30c2", "\uff81\uff9e"),  # ヂ to ﾁﾞ
    ("\u30c5", "\uff82\uff9e"),  # ヅ to ﾂﾞ
    ("\u30c7", "\uff83\uff9e"),  # デ to ﾃﾞ
    ("\u30c9", "\uff84\uff9e"),  # ド to ﾄﾞ
    # B-row (voiced H)
    ("\u30d0", "\uff8a\uff9e"),  # バ to ﾊﾞ
    ("\u30d3", "\uff8b\uff9e"),  # ビ to ﾋﾞ
    ("\u30d6", "\uff8c\uff9e"),  # ブ to ﾌﾞ
    ("\u30d9", "\uff8d\uff9e"),  # ベ to ﾍﾞ
    ("\u30dc", "\uff8e\uff9e"),  # ボ to ﾎﾞ
    # P-row (half-voiced H)
    ("\u30d1", "\uff8a\uff9f"),  # パ to ﾊﾟ
    ("\u30d4", "\uff8b\uff9f"),  # ピ to ﾋﾟ
    ("\u30d7", "\uff8c\uff9f"),  # プ to ﾌﾟ
    ("\u30da", "\uff8d\uff9f"),  # ペ to ﾍﾟ
    ("\u30dd", "\uff8e\uff9f"),  # ポ to ﾎﾟ
    # Special
    ("\u30fa", "\uff66\uff9e"),  # ヺ to ｦﾞ
]

# Hiragana mappings (for convert_hiraganas option)
HIRAGANA_MAPPINGS = {
    # Small hiragana
    "\u3041": "\uff67",  # ぁ to ｧ
    "\u3043": "\uff68",  # ぃ to ｨ
    "\u3045": "\uff69",  # ぅ to ｩ
    "\u3047": "\uff6a",  # ぇ to ｪ
    "\u3049": "\uff6b",  # ぉ to ｫ
    "\u3083": "\uff6c",  # ゃ to ｬ
    "\u3085": "\uff6d",  # ゅ to ｭ
    "\u3087": "\uff6e",  # ょ to ｮ
    "\u3063": "\uff6f",  # っ to ｯ
    # Vowels
    "\u3042": "\uff71",  # あ to ｱ
    "\u3044": "\uff72",  # い to ｲ
    "\u3046": "\uff73",  # う to ｳ
    "\u3048": "\uff74",  # え to ｴ
    "\u304a": "\uff75",  # お to ｵ
    # K-row
    "\u304b": "\uff76",  # か to ｶ
    "\u304d": "\uff77",  # き to ｷ
    "\u304f": "\uff78",  # く to ｸ
    "\u3051": "\uff79",  # け to ｹ
    "\u3053": "\uff7a",  # こ to ｺ
    # S-row
    "\u3055": "\uff7b",  # さ to ｻ
    "\u3057": "\uff7c",  # し to ｼ
    "\u3059": "\uff7d",  # す to ｽ
    "\u305b": "\uff7e",  # せ to ｾ
    "\u305d": "\uff7f",  # そ to ｿ
    # T-row
    "\u305f": "\uff80",  # た to ﾀ
    "\u3061": "\uff81",  # ち to ﾁ
    "\u3064": "\uff82",  # つ to ﾂ
    "\u3066": "\uff83",  # て to ﾃ
    "\u3068": "\uff84",  # と to ﾄ
    # N-row
    "\u306a": "\uff85",  # な to ﾅ
    "\u306b": "\uff86",  # に to ﾆ
    "\u306c": "\uff87",  # ぬ to ﾇ
    "\u306d": "\uff88",  # ね to ﾈ
    "\u306e": "\uff89",  # の to ﾉ
    # H-row
    "\u306f": "\uff8a",  # は to ﾊ
    "\u3072": "\uff8b",  # ひ to ﾋ
    "\u3075": "\uff8c",  # ふ to ﾌ
    "\u3078": "\uff8d",  # へ to ﾍ
    "\u307b": "\uff8e",  # ほ to ﾎ
    # M-row
    "\u307e": "\uff8f",  # ま to ﾏ
    "\u307f": "\uff90",  # み to ﾐ
    "\u3080": "\uff91",  # む to ﾑ
    "\u3081": "\uff92",  # め to ﾒ
    "\u3082": "\uff93",  # も to ﾓ
    # Y-row
    "\u3084": "\uff94",  # や to ﾔ
    "\u3086": "\uff95",  # ゆ to ﾕ
    "\u3088": "\uff96",  # よ to ﾖ
    # R-row
    "\u3089": "\uff97",  # ら to ﾗ
    "\u308a": "\uff98",  # り to ﾘ
    "\u308b": "\uff99",  # る to ﾙ
    "\u308c": "\uff9a",  # れ to ﾚ
    "\u308d": "\uff9b",  # ろ to ﾛ
    # W-row
    "\u308f": "\uff9c",  # わ to ﾜ
    "\u3093": "\uff9d",  # ん to ﾝ
    "\u3092": "\uff66",  # を to ｦ
    # Voiced
    "\u3094": "\uff73\uff9e",  # ゔ to ｳﾞ
    # Voiced K (G)
    "\u304c": "\uff76\uff9e",  # が to ｶﾞ
    "\u304e": "\uff77\uff9e",  # ぎ to ｷﾞ
    "\u3050": "\uff78\uff9e",  # ぐ to ｸﾞ
    "\u3052": "\uff79\uff9e",  # げ to ｹﾞ
    "\u3054": "\uff7a\uff9e",  # ご to ｺﾞ
    # Voiced S (Z)
    "\u3056": "\uff7b\uff9e",  # ざ to ｻﾞ
    "\u3058": "\uff7c\uff9e",  # じ to ｼﾞ
    "\u305a": "\uff7d\uff9e",  # ず to ｽﾞ
    "\u305c": "\uff7e\uff9e",  # ぜ to ｾﾞ
    "\u305e": "\uff7f\uff9e",  # ぞ to ｿﾞ
    # Voiced T (D)
    "\u3060": "\uff80\uff9e",  # だ to ﾀﾞ
    "\u3062": "\uff81\uff9e",  # ぢ to ﾁﾞ
    "\u3065": "\uff82\uff9e",  # づ to ﾂﾞ
    "\u3067": "\uff83\uff9e",  # で to ﾃﾞ
    "\u3069": "\uff84\uff9e",  # ど to ﾄﾞ
    # Voiced H (B)
    "\u3070": "\uff8a\uff9e",  # ば to ﾊﾞ
    "\u3073": "\uff8b\uff9e",  # び to ﾋﾞ
    "\u3076": "\uff8c\uff9e",  # ぶ to ﾌﾞ
    "\u3079": "\uff8d\uff9e",  # べ to ﾍﾞ
    "\u307c": "\uff8e\uff9e",  # ぼ to ﾎﾞ
    # Half-voiced H (P)
    "\u3071": "\uff8a\uff9f",  # ぱ to ﾊﾟ
    "\u3074": "\uff8b\uff9f",  # ぴ to ﾋﾟ
    "\u3077": "\uff8c\uff9f",  # ぷ to ﾌﾟ
    "\u307a": "\uff8d\uff9f",  # ぺ to ﾍﾟ
    "\u307d": "\uff8e\uff9f",  # ぽ to ﾎﾟ
}

# Special punctuations
SPECIAL_PUNCTUATIONS_TABLE = [("\u30a0", "\u003d")]  # ゠ to =


# Global cache for mappings
_FWD_MAPPINGS_CACHE: dict[CacheKey, dict[str, str]] = {}
_REV_MAPPINGS_CACHE: dict[CacheKey, dict[str, str]] = {}


@cache
def _generate_cache_key(
    convert_gl: bool,
    convert_gr: bool,
    convert_unsafe_specials: bool,
    convert_hiraganas: bool,
    u005c_as_yen_sign: bool,
    u005c_as_backslash: bool,
    u007e_as_fullwidth_tilde: bool,
    u007e_as_wave_dash: bool,
    u007e_as_overline: bool,
    u007e_as_fullwidth_macron: bool,
    u00a5_as_yen_sign: bool,
) -> CacheKey:
    """Generate a cache key based on configuration options."""
    return (
        convert_gl,
        convert_gr,
        convert_unsafe_specials,
        convert_hiraganas,
        u005c_as_yen_sign,
        u005c_as_backslash,
        u007e_as_fullwidth_tilde,
        u007e_as_wave_dash,
        u007e_as_overline,
        u007e_as_fullwidth_macron,
        u00a5_as_yen_sign,
    )


def _get_fwd_mappings(
    convert_gl: bool,
    convert_gr: bool,
    convert_unsafe_specials: bool,
    convert_hiraganas: bool,
    overrides: dict[str, bool],
) -> dict[str, str]:
    """Get forward mappings from cache or build new ones."""
    cache_key = _generate_cache_key(
        convert_gl=convert_gl,
        convert_gr=convert_gr,
        convert_unsafe_specials=convert_unsafe_specials,
        convert_hiraganas=convert_hiraganas,
        u005c_as_yen_sign=overrides.get("u005c_as_yen_sign", False),
        u005c_as_backslash=overrides.get("u005c_as_backslash", False),
        u007e_as_fullwidth_tilde=overrides.get("u007e_as_fullwidth_tilde", False),
        u007e_as_wave_dash=overrides.get("u007e_as_wave_dash", False),
        u007e_as_overline=overrides.get("u007e_as_overline", False),
        u007e_as_fullwidth_macron=overrides.get("u007e_as_fullwidth_macron", False),
        u00a5_as_yen_sign=overrides.get("u00a5_as_yen_sign", False),
    )

    if cache_key in _FWD_MAPPINGS_CACHE:
        return _FWD_MAPPINGS_CACHE[cache_key]

    # Build new mappings
    mappings: dict[str, str] = {}

    if convert_gl:
        # Add basic GL mappings
        mappings.update(dict(JISX0201_GL_TABLE))

        # Add override mappings
        for key, enabled in overrides.items():
            if enabled and key in JISX0201_GL_OVERRIDES:
                mappings.update(dict(JISX0201_GL_OVERRIDES[key]))

    if convert_gr:
        # Add basic GR mappings
        mappings.update(dict(JISX0201_GR_TABLE))
        mappings.update(dict(VOICED_LETTERS_TABLE))
        # Add combining marks
        mappings["\u3099"] = "\uff9e"  # combining dakuten
        mappings["\u309a"] = "\uff9f"  # combining handakuten

    if convert_unsafe_specials:
        mappings.update(dict(SPECIAL_PUNCTUATIONS_TABLE))

    if convert_hiraganas:
        mappings.update(HIRAGANA_MAPPINGS)

    # Store in cache
    _FWD_MAPPINGS_CACHE[cache_key] = mappings
    return mappings


def _get_rev_mappings(
    convert_gl: bool,
    convert_gr: bool,
    convert_unsafe_specials: bool,
    overrides: dict[str, bool],
) -> dict[str, str]:
    """Get reverse mappings from cache or build new ones."""
    cache_key = _generate_cache_key(
        convert_gl=convert_gl,
        convert_gr=convert_gr,
        convert_unsafe_specials=convert_unsafe_specials,
        convert_hiraganas=False,  # Not used for reverse mappings
        u005c_as_yen_sign=overrides.get("u005c_as_yen_sign", False),
        u005c_as_backslash=overrides.get("u005c_as_backslash", False),
        u007e_as_fullwidth_tilde=overrides.get("u007e_as_fullwidth_tilde", False),
        u007e_as_wave_dash=overrides.get("u007e_as_wave_dash", False),
        u007e_as_overline=overrides.get("u007e_as_overline", False),
        u007e_as_fullwidth_macron=overrides.get("u007e_as_fullwidth_macron", False),
        u00a5_as_yen_sign=overrides.get("u00a5_as_yen_sign", False),
    )

    if cache_key in _REV_MAPPINGS_CACHE:
        return _REV_MAPPINGS_CACHE[cache_key]

    # Build new mappings
    mappings: dict[str, str] = {}

    if convert_gl:
        # Add basic GL reverse mappings
        for fw, hw in JISX0201_GL_TABLE:
            mappings[hw] = fw

        # Add override reverse mappings
        for key, enabled in overrides.items():
            if enabled and key in JISX0201_GL_OVERRIDES:
                for fw, hw in JISX0201_GL_OVERRIDES[key]:
                    mappings[hw] = fw

    if convert_gr:
        # Add basic GR reverse mappings
        for fw, hw in JISX0201_GR_TABLE:
            mappings[hw] = fw

    if convert_unsafe_specials:
        for fw, hw in SPECIAL_PUNCTUATIONS_TABLE:
            mappings[hw] = fw

    # Store in cache
    _REV_MAPPINGS_CACHE[cache_key] = mappings
    return mappings


class Transliterator:
    """JIS X 0201 and alike transliterator for fullwidth/halfwidth conversion.

    This transliterator handles conversion between:
    - Half-width group:
      - Alphabets, numerics, and symbols: U+0020 - U+007E, U+00A5, and U+203E.
      - Half-width katakanas: U+FF61 - U+FF9F.
    - Full-width group:
      - Full-width alphabets, numerics, and symbols: U+FF01 - U+FF5E, U+FFE3, and U+FFE5.
      - Wave dash: U+301C.
      - Hiraganas: U+3041 - U+3094.
      - Katakanas: U+30A1 - U+30F7 and U+30FA.
      - Hiragana/katakana voicing marks: U+309B, U+309C, and U+30FC.
      - Japanese punctuations: U+3001, U+3002, U+30A0, and U+30FB.
    """

    fullwidth_to_halfwidth: bool
    convert_gl: bool
    convert_gr: bool
    convert_unsafe_specials: bool
    convert_hiraganas: bool
    combine_voiced_sound_marks: bool
    overrides: dict[str, bool]
    fwd_mappings: dict[str, str]
    rev_mappings: dict[str, str]
    voiced_rev_mappings: dict[str, dict[str, str]]

    def __init__(
        self,
        *,
        fullwidth_to_halfwidth: bool = True,
        convert_gl: bool = True,
        convert_gr: bool = True,
        u005c_as_yen_sign: bool = False,
        u005c_as_backslash: bool = False,
        u007e_as_fullwidth_tilde: bool = False,
        u007e_as_wave_dash: bool = False,
        u007e_as_overline: bool = False,
        u007e_as_fullwidth_macron: bool = False,
        u00a5_as_yen_sign: bool = False,
        convert_unsafe_specials: bool = False,
        convert_hiraganas: bool = False,
        combine_voiced_sound_marks: bool = False,
    ) -> None:
        """Initialize the transliterator with options.

        :param fullwidth_to_halfwidth: Whether to convert fullwidth to halfwidth. Defaults to True.
        :param convert_gl: Whether to convert GL characters. Defaults to True.
        :param convert_gr: Whether to convert GR characters (hankaku kana). Defaults to True.
        :param u005c_as_yen_sign: Whether to treat backslash as yen sign. Defaults to False.
        :param u005c_as_backslash: Whether to treat U+005C verbatim. Defaults to False.
        :param u007e_as_fullwidth_tilde: Convert U+007E to U+FF5E. Defaults to False.
        :param u007e_as_wave_dash: Convert U+007E to U+301C. Defaults to False.
        :param u007e_as_overline: Convert U+007E to U+203E. Defaults to False.
        :param u007e_as_fullwidth_macron: Convert U+007E to U+FFE3. Defaults to False.
        :param u00a5_as_yen_sign: Convert U+00A5 to U+005C. Defaults to False.
        :param convert_unsafe_specials: Convert U+30A0 to U+003D. Defaults to False.
        :param convert_hiraganas: Convert hiraganas. Defaults to False.
        :param combine_voiced_sound_marks: Combine voiced sound marks. Defaults to False.
        """
        self.fullwidth_to_halfwidth = fullwidth_to_halfwidth
        self.convert_gl = convert_gl
        self.convert_gr = convert_gr
        self.convert_unsafe_specials = convert_unsafe_specials
        self.convert_hiraganas = convert_hiraganas
        self.combine_voiced_sound_marks = combine_voiced_sound_marks

        # Handle overrides
        self.overrides = {}
        if u005c_as_yen_sign:
            self.overrides["u005c_as_yen_sign"] = True
        if u005c_as_backslash:
            self.overrides["u005c_as_backslash"] = True
        if u007e_as_fullwidth_tilde:
            self.overrides["u007e_as_fullwidth_tilde"] = True
        if u007e_as_wave_dash:
            self.overrides["u007e_as_wave_dash"] = True
        if u007e_as_overline:
            self.overrides["u007e_as_overline"] = True
        if u007e_as_fullwidth_macron:
            self.overrides["u007e_as_fullwidth_macron"] = True
        if u00a5_as_yen_sign:
            self.overrides["u00a5_as_yen_sign"] = True

        # Apply defaults based on direction
        if fullwidth_to_halfwidth:
            # Default settings for fullwidth to halfwidth
            if not u005c_as_backslash and not u00a5_as_yen_sign:
                self.overrides.setdefault("u005c_as_yen_sign", True)
                self.overrides.setdefault("u005c_as_backslash", True)
            self.overrides.setdefault("u007e_as_fullwidth_tilde", True)
            self.overrides.setdefault("u007e_as_wave_dash", True)
        else:
            # Default settings for halfwidth to fullwidth
            u005c_as_yen = self.overrides.get("u005c_as_yen_sign", False) or not self.overrides.get(
                "u005c_as_backslash", False
            )
            u007e_as_fw_tilde = self.overrides.get("u007e_as_fullwidth_tilde", False) or not any(
                [
                    self.overrides.get("u007e_as_wave_dash", False),
                    self.overrides.get("u007e_as_overline", False),
                    self.overrides.get("u007e_as_fullwidth_macron", False),
                ]
            )
            self.overrides.setdefault("u005c_as_yen_sign", u005c_as_yen)
            self.overrides.setdefault("u005c_as_backslash", not u005c_as_yen)
            self.overrides.setdefault("u007e_as_fullwidth_tilde", u007e_as_fw_tilde)
            self.overrides.setdefault("u00a5_as_yen_sign", True)

        # Get cached mappings
        self.fwd_mappings = _get_fwd_mappings(
            self.convert_gl,
            self.convert_gr,
            self.convert_unsafe_specials,
            self.convert_hiraganas,
            self.overrides,
        )
        self.rev_mappings = _get_rev_mappings(
            self.convert_gl,
            self.convert_gr,
            self.convert_unsafe_specials,
            self.overrides,
        )

        # Build voiced letters reverse mappings for combining
        self.voiced_rev_mappings = {}
        if self.combine_voiced_sound_marks and self.convert_gr:
            for fw, hw in VOICED_LETTERS_TABLE:
                if len(hw) == 2:
                    base_char = hw[0]
                    voice_mark = hw[1]
                    if base_char not in self.voiced_rev_mappings:
                        self.voiced_rev_mappings[base_char] = {}
                    self.voiced_rev_mappings[base_char][voice_mark] = fw

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Convert between fullwidth and halfwidth characters."""
        if self.fullwidth_to_halfwidth:
            yield from self._convert_fullwidth_to_halfwidth(input_chars)
        else:
            yield from self._convert_halfwidth_to_fullwidth(input_chars)

    def _convert_fullwidth_to_halfwidth(self, chars: Iterable[Char]) -> Iterable[Char]:
        """Convert fullwidth characters to halfwidth."""
        for char in chars:
            mapped = self.fwd_mappings.get(char.c)
            if mapped is not None:
                yield Char(c=mapped, offset=char.offset, source=char)
            else:
                yield char

    def _convert_halfwidth_to_fullwidth(self, chars: Iterable[Char]) -> Iterable[Char]:
        """Convert halfwidth characters to fullwidth."""
        chars_iter = iter(chars)
        pending_char = None

        for char in chars_iter:
            if pending_char is not None:
                # Check if this char can combine with the pending one
                base_char, voice_mappings = pending_char
                combined = voice_mappings.get(char.c)
                if combined is not None:
                    # Yield the combined character
                    yield Char(c=combined, offset=base_char.offset, source=base_char)
                    pending_char = None
                    continue
                else:
                    # Can't combine, yield the pending character first
                    mapped = self.rev_mappings.get(base_char.c)
                    if mapped is not None:
                        yield Char(c=mapped, offset=base_char.offset, source=base_char)
                    else:
                        yield base_char
                    pending_char = None

            # Check if this character might start a combination
            if self.combine_voiced_sound_marks and char.c in self.voiced_rev_mappings:
                pending_char = (char, self.voiced_rev_mappings[char.c])
            else:
                # Normal mapping
                mapped = self.rev_mappings.get(char.c)
                if mapped is not None:
                    yield Char(c=mapped, offset=char.offset, source=char)
                else:
                    yield char

        # Handle any remaining pending character
        if pending_char is not None:
            base_char, _ = pending_char
            mapped = self.rev_mappings.get(base_char.c)
            if mapped is not None:
                yield Char(c=mapped, offset=base_char.offset, source=base_char)
            else:
                yield base_char
