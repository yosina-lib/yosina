"""Hiragana-Katakana composition transliterator."""

from collections.abc import Iterable

from ..chars import Char

__all__ = ["Transliterator"]

# Voiced character mappings (base -> voiced)
VOICED_CHARACTERS = [
    ("\u304b", "\u304c"),  # か -> が
    ("\u304d", "\u304e"),  # き -> ぎ
    ("\u304f", "\u3050"),  # く -> ぐ
    ("\u3051", "\u3052"),  # け -> げ
    ("\u3053", "\u3054"),  # こ -> ご
    ("\u3055", "\u3056"),  # さ -> ざ
    ("\u3057", "\u3058"),  # し -> じ
    ("\u3059", "\u305a"),  # す -> ず
    ("\u305b", "\u305c"),  # せ -> ぜ
    ("\u305d", "\u305e"),  # そ -> ぞ
    ("\u305f", "\u3060"),  # た -> だ
    ("\u3061", "\u3062"),  # ち -> ぢ
    ("\u3064", "\u3065"),  # つ -> づ
    ("\u3066", "\u3067"),  # て -> で
    ("\u3068", "\u3069"),  # と -> ど
    ("\u306f", "\u3070"),  # は -> ば
    ("\u3072", "\u3073"),  # ひ -> び
    ("\u3075", "\u3076"),  # ふ -> ぶ
    ("\u3078", "\u3079"),  # へ -> べ
    ("\u307b", "\u307c"),  # ほ -> ぼ
    ("\u3046", "\u3094"),  # う -> ゔ
    ("\u309d", "\u309e"),  # ゝ -> ゞ
    # Katakana
    ("\u30ab", "\u30ac"),  # カ -> ガ
    ("\u30ad", "\u30ae"),  # キ -> ギ
    ("\u30af", "\u30b0"),  # ク -> グ
    ("\u30b1", "\u30b2"),  # ケ -> ゲ
    ("\u30b3", "\u30b4"),  # コ -> ゴ
    ("\u30b5", "\u30b6"),  # サ -> ザ
    ("\u30b7", "\u30b8"),  # シ -> ジ
    ("\u30b9", "\u30ba"),  # ス -> ズ
    ("\u30bb", "\u30bc"),  # セ -> ゼ
    ("\u30bd", "\u30be"),  # ソ -> ゾ
    ("\u30bf", "\u30c0"),  # タ -> ダ
    ("\u30c1", "\u30c2"),  # チ -> ヂ
    ("\u30c4", "\u30c5"),  # ツ -> ヅ
    ("\u30c6", "\u30c7"),  # テ -> デ
    ("\u30c8", "\u30c9"),  # ト -> ド
    ("\u30cf", "\u30d0"),  # ハ -> バ
    ("\u30d2", "\u30d3"),  # ヒ -> ビ
    ("\u30d5", "\u30d6"),  # フ -> ブ
    ("\u30d8", "\u30d9"),  # ヘ -> ベ
    ("\u30db", "\u30dc"),  # ホ -> ボ
    ("\u30a6", "\u30f4"),  # ウ -> ヴ
    ("\u30ef", "\u30f7"),  # ワ -> ヷ
    ("\u30f0", "\u30f8"),  # ヰ -> ヸ
    ("\u30f1", "\u30f9"),  # ヱ -> ヹ
    ("\u30f2", "\u30fa"),  # ヲ -> ヺ
    ("\u30fd", "\u30fe"),  # ヽ -> ヾ
]

# Semi-voiced character mappings (base -> semi-voiced)
SEMI_VOICED_CHARACTERS = [
    ("\u306f", "\u3071"),  # は -> ぱ
    ("\u3072", "\u3074"),  # ひ -> ぴ
    ("\u3075", "\u3077"),  # ふ -> ぷ
    ("\u3078", "\u307a"),  # へ -> ぺ
    ("\u307b", "\u307d"),  # ほ -> ぽ
    # Katakana
    ("\u30cf", "\u30d1"),  # ハ -> パ
    ("\u30d2", "\u30d4"),  # ヒ -> ピ
    ("\u30d5", "\u30d7"),  # フ -> プ
    ("\u30d8", "\u30da"),  # ヘ -> ペ
    ("\u30db", "\u30dd"),  # ホ -> ポ
]


class Transliterator:
    """Hiragana-Katakana composition transliterator.

    Combines decomposed hiragana and katakana characters into their composed
    equivalents. For example, か + ゛becomes が.
    """

    compose_non_combining_marks: bool
    table: dict[str, dict[str, str]]

    def __init__(self, *, compose_non_combining_marks: bool = False) -> None:
        """Initialize the transliterator with options.

        :param compose_non_combining_marks: Whether to also compose non-combining
                marks (゛ and ゜) in addition to combining marks (゛and ゜).
                Defaults to False.
        """
        self.compose_non_combining_marks = compose_non_combining_marks
        self.table = self._build_table()

    def _build_table(self) -> dict[str, dict[str, str]]:
        """Build the lookup table from the character arrays."""
        # Build voiced table
        voiced_table = {base: voiced for base, voiced in VOICED_CHARACTERS}

        # Build semi-voiced table
        semi_voiced_table = {base: semi_voiced for base, semi_voiced in SEMI_VOICED_CHARACTERS}

        table = {
            "\u3099": voiced_table,  # combining voiced mark
            "\u309a": semi_voiced_table,  # combining semi-voiced mark
        }

        # Add non-combining marks if enabled
        if self.compose_non_combining_marks:
            table["\u309b"] = voiced_table  # non-combining voiced mark
            table["\u309c"] = semi_voiced_table  # non-combining semi-voiced mark

        return table

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Compose decomposed hiragana and katakana characters."""
        offset = 0
        pending_char: Char | None = None

        for char in input_chars:
            if pending_char is not None:
                # Check if current char is a combining mark
                mark_table = self.table.get(char.c)
                if mark_table is not None:
                    composed = mark_table.get(pending_char.c)
                    if composed is not None:
                        yield Char(c=composed, offset=offset, source=pending_char)
                        offset += len(composed)
                        pending_char = None
                        continue
                # No composition, yield pending char
                yield pending_char.with_offset(offset)
                offset += len(pending_char.c)
            pending_char = char

        # Handle any remaining character
        if pending_char is not None:
            yield pending_char.with_offset(offset)
            offset += len(pending_char.c)
