"""Shared hiragana-katakana mapping table."""

# Main hiragana-katakana table with [hiragana, katakana, halfwidth] structure
HIRAGANA_KATAKANA_TABLE: list[
    tuple[tuple[str, str | None, str | None], tuple[str, str | None, str | None], str | None]
] = [
    # Vowels
    (("\u3042", None, None), ("\u30a2", None, None), "\uff71"),  # あ, ア
    (("\u3044", None, None), ("\u30a4", None, None), "\uff72"),  # い, イ
    (("\u3046", "\u3094", None), ("\u30a6", "\u30f4", None), "\uff73"),  # う, ウ
    (("\u3048", None, None), ("\u30a8", None, None), "\uff74"),  # え, エ
    (("\u304a", None, None), ("\u30aa", None, None), "\uff75"),  # お, オ
    # K-row
    (("\u304b", "\u304c", None), ("\u30ab", "\u30ac", None), "\uff76"),  # か, カ
    (("\u304d", "\u304e", None), ("\u30ad", "\u30ae", None), "\uff77"),  # き, キ
    (("\u304f", "\u3050", None), ("\u30af", "\u30b0", None), "\uff78"),  # く, ク
    (("\u3051", "\u3052", None), ("\u30b1", "\u30b2", None), "\uff79"),  # け, ケ
    (("\u3053", "\u3054", None), ("\u30b3", "\u30b4", None), "\uff7a"),  # こ, コ
    # S-row
    (("\u3055", "\u3056", None), ("\u30b5", "\u30b6", None), "\uff7b"),  # さ, サ
    (("\u3057", "\u3058", None), ("\u30b7", "\u30b8", None), "\uff7c"),  # し, シ
    (("\u3059", "\u305a", None), ("\u30b9", "\u30ba", None), "\uff7d"),  # す, ス
    (("\u305b", "\u305c", None), ("\u30bb", "\u30bc", None), "\uff7e"),  # せ, セ
    (("\u305d", "\u305e", None), ("\u30bd", "\u30be", None), "\uff7f"),  # そ, ソ
    # T-row
    (("\u305f", "\u3060", None), ("\u30bf", "\u30c0", None), "\uff80"),  # た, タ
    (("\u3061", "\u3062", None), ("\u30c1", "\u30c2", None), "\uff81"),  # ち, チ
    (("\u3064", "\u3065", None), ("\u30c4", "\u30c5", None), "\uff82"),  # つ, ツ
    (("\u3066", "\u3067", None), ("\u30c6", "\u30c7", None), "\uff83"),  # て, テ
    (("\u3068", "\u3069", None), ("\u30c8", "\u30c9", None), "\uff84"),  # と, ト
    # N-row
    (("\u306a", None, None), ("\u30ca", None, None), "\uff85"),  # な, ナ
    (("\u306b", None, None), ("\u30cb", None, None), "\uff86"),  # に, ニ
    (("\u306c", None, None), ("\u30cc", None, None), "\uff87"),  # ぬ, ヌ
    (("\u306d", None, None), ("\u30cd", None, None), "\uff88"),  # ね, ネ
    (("\u306e", None, None), ("\u30ce", None, None), "\uff89"),  # の, ノ
    # H-row
    (("\u306f", "\u3070", "\u3071"), ("\u30cf", "\u30d0", "\u30d1"), "\uff8a"),  # は, ハ
    (("\u3072", "\u3073", "\u3074"), ("\u30d2", "\u30d3", "\u30d4"), "\uff8b"),  # ひ, ヒ
    (("\u3075", "\u3076", "\u3077"), ("\u30d5", "\u30d6", "\u30d7"), "\uff8c"),  # ふ, フ
    (("\u3078", "\u3079", "\u307a"), ("\u30d8", "\u30d9", "\u30da"), "\uff8d"),  # へ, ヘ
    (("\u307b", "\u307c", "\u307d"), ("\u30db", "\u30dc", "\u30dd"), "\uff8e"),  # ほ, ホ
    # M-row
    (("\u307e", None, None), ("\u30de", None, None), "\uff8f"),  # ま, マ
    (("\u307f", None, None), ("\u30df", None, None), "\uff90"),  # み, ミ
    (("\u3080", None, None), ("\u30e0", None, None), "\uff91"),  # む, ム
    (("\u3081", None, None), ("\u30e1", None, None), "\uff92"),  # め, メ
    (("\u3082", None, None), ("\u30e2", None, None), "\uff93"),  # も, モ
    # Y-row
    (("\u3084", None, None), ("\u30e4", None, None), "\uff94"),  # や, ヤ
    (("\u3086", None, None), ("\u30e6", None, None), "\uff95"),  # ゆ, ユ
    (("\u3088", None, None), ("\u30e8", None, None), "\uff96"),  # よ, ヨ
    # R-row
    (("\u3089", None, None), ("\u30e9", None, None), "\uff97"),  # ら, ラ
    (("\u308a", None, None), ("\u30ea", None, None), "\uff98"),  # り, リ
    (("\u308b", None, None), ("\u30eb", None, None), "\uff99"),  # る, ル
    (("\u308c", None, None), ("\u30ec", None, None), "\uff9a"),  # れ, レ
    (("\u308d", None, None), ("\u30ed", None, None), "\uff9b"),  # ろ, ロ
    # W-row
    (("\u308f", None, None), ("\u30ef", "\u30f7", None), "\uff9c"),  # わ, ワ
    (("\u3090", None, None), ("\u30f0", "\u30f8", None), None),  # ゐ, ヰ
    (("\u3091", None, None), ("\u30f1", "\u30f9", None), None),  # ゑ, ヱ
    (("\u3092", None, None), ("\u30f2", "\u30fa", None), "\uff66"),  # を, ヲ
    (("\u3093", None, None), ("\u30f3", None, None), "\uff9d"),  # ん, ン
]

# Small kana table
HIRAGANA_KATAKANA_SMALL_TABLE: list[tuple[str, str, str | None]] = [
    ("\u3041", "\u30a1", "\uff67"),  # ぁ, ァ
    ("\u3043", "\u30a3", "\uff68"),  # ぃ, ィ
    ("\u3045", "\u30a5", "\uff69"),  # ぅ, ゥ
    ("\u3047", "\u30a7", "\uff6a"),  # ぇ, ェ
    ("\u3049", "\u30a9", "\uff6b"),  # ぉ, ォ
    ("\u3063", "\u30c3", "\uff6f"),  # っ, ッ
    ("\u3083", "\u30e3", "\uff6c"),  # ゃ, ャ
    ("\u3085", "\u30e5", "\uff6d"),  # ゅ, ュ
    ("\u3087", "\u30e7", "\uff6e"),  # ょ, ョ
    ("\u308e", "\u30ee", None),  # ゎ, ヮ
    ("\u3095", "\u30f5", None),  # ゕ, ヵ
    ("\u3096", "\u30f6", None),  # ゖ, ヶ
]


# Generate voiced character mappings
def _generate_voiced_characters() -> list[tuple[str, str]]:
    """Generate voiced character mappings from the table."""
    result: list[tuple[str, str]] = []
    for hiragana, katakana, _ in HIRAGANA_KATAKANA_TABLE:
        if hiragana[1] is not None:
            result.append((hiragana[0], hiragana[1]))
        if katakana[1] is not None:
            result.append((katakana[0], katakana[1]))
    # Add iteration marks
    result.extend(
        [
            ("\u309d", "\u309e"),  # ゝ -> ゞ
            ("\u30fd", "\u30fe"),  # ヽ -> ヾ
            ("\u3031", "\u3032"),  # 〱 -> 〲 (vertical hiragana)
            ("\u3033", "\u3034"),  # 〳 -> 〴 (vertical katakana)
        ]
    )
    return result


# Generate semi-voiced character mappings
def _generate_semi_voiced_characters() -> list[tuple[str, str]]:
    """Generate semi-voiced character mappings from the table."""
    result: list[tuple[str, str]] = []
    for hiragana, katakana, _ in HIRAGANA_KATAKANA_TABLE:
        if hiragana[2] is not None:
            result.append((hiragana[0], hiragana[2]))
        if katakana[2] is not None:
            result.append((katakana[0], katakana[2]))
    return result


VOICED_CHARACTERS = _generate_voiced_characters()
SEMI_VOICED_CHARACTERS = _generate_semi_voiced_characters()
