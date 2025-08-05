"""Hiragana-Katakana composition transliterator."""

from collections.abc import Iterable

from ..chars import Char

__all__ = ["Transliterator"]

# Composition table mapping decomposed characters to composed ones
COMPOSITION_TABLE = [
    # Hiragana with dakuten (voiced sound mark)
    ("\u304b\u3099", "\u304c"),  # か + ゙ -> が
    ("\u304d\u3099", "\u304e"),  # き + ゙ -> ぎ
    ("\u304f\u3099", "\u3050"),  # く + ゙ -> ぐ
    ("\u3051\u3099", "\u3052"),  # け + ゙ -> げ
    ("\u3053\u3099", "\u3054"),  # こ + ゙ -> ご
    ("\u3055\u3099", "\u3056"),  # さ + ゙ -> ざ
    ("\u3057\u3099", "\u3058"),  # し + ゙ -> じ
    ("\u3059\u3099", "\u305a"),  # す + ゙ -> ず
    ("\u305b\u3099", "\u305c"),  # せ + ゙ -> ぜ
    ("\u305d\u3099", "\u305e"),  # そ + ゙ -> ぞ
    ("\u305f\u3099", "\u3060"),  # た + ゙ -> だ
    ("\u3061\u3099", "\u3062"),  # ち + ゙ -> ぢ
    ("\u3064\u3099", "\u3065"),  # つ + ゙ -> づ
    ("\u3066\u3099", "\u3067"),  # て + ゙ -> で
    ("\u3068\u3099", "\u3069"),  # と + ゙ -> ど
    ("\u306f\u3099", "\u3070"),  # は + ゙ -> ば
    ("\u3072\u3099", "\u3073"),  # ひ + ゙ -> び
    ("\u3075\u3099", "\u3076"),  # ふ + ゙ -> ぶ
    ("\u3078\u3099", "\u3079"),  # へ + ゙ -> べ
    ("\u307b\u3099", "\u307c"),  # ほ + ゙ -> ぼ
    # Hiragana with handakuten (semi-voiced sound mark)
    ("\u306f\u309a", "\u3071"),  # は + ゚ -> ぱ
    ("\u3072\u309a", "\u3074"),  # ひ + ゚ -> ぴ
    ("\u3075\u309a", "\u3077"),  # ふ + ゚ -> ぷ
    ("\u3078\u309a", "\u307a"),  # へ + ゚ -> ぺ
    ("\u307b\u309a", "\u307d"),  # ほ + ゚ -> ぽ
    # Special hiragana
    ("\u3046\u3099", "\u3094"),  # う + ゙ -> ゔ
    ("\u309d\u3099", "\u309e"),  # ゝ + ゙ -> ゞ
    # Katakana with dakuten
    ("\u30ab\u3099", "\u30ac"),  # カ + ゙ -> ガ
    ("\u30ad\u3099", "\u30ae"),  # キ + ゙ -> ギ
    ("\u30af\u3099", "\u30b0"),  # ク + ゙ -> グ
    ("\u30b1\u3099", "\u30b2"),  # ケ + ゙ -> ゲ
    ("\u30b3\u3099", "\u30b4"),  # コ + ゙ -> ゴ
    ("\u30b5\u3099", "\u30b6"),  # サ + ゙ -> ザ
    ("\u30b7\u3099", "\u30b8"),  # シ + ゙ -> ジ
    ("\u30b9\u3099", "\u30ba"),  # ス + ゙ -> ズ
    ("\u30bb\u3099", "\u30bc"),  # セ + ゙ -> ゼ
    ("\u30bd\u3099", "\u30be"),  # ソ + ゙ -> ゾ
    ("\u30bf\u3099", "\u30c0"),  # タ + ゙ -> ダ
    ("\u30c1\u3099", "\u30c2"),  # チ + ゙ -> ヂ
    ("\u30c4\u3099", "\u30c5"),  # ツ + ゙ -> ヅ
    ("\u30c6\u3099", "\u30c7"),  # テ + ゙ -> デ
    ("\u30c8\u3099", "\u30c9"),  # ト + ゙ -> ド
    ("\u30cf\u3099", "\u30d0"),  # ハ + ゙ -> バ
    ("\u30d2\u3099", "\u30d3"),  # ヒ + ゙ -> ビ
    ("\u30d5\u3099", "\u30d6"),  # フ + ゙ -> ブ
    ("\u30d8\u3099", "\u30d9"),  # ヘ + ゙ -> ベ
    ("\u30db\u3099", "\u30dc"),  # ホ + ゙ -> ボ
    # Katakana with handakuten
    ("\u30cf\u309a", "\u30d1"),  # ハ + ゚ -> パ
    ("\u30d2\u309a", "\u30d4"),  # ヒ + ゚ -> ピ
    ("\u30d5\u309a", "\u30d7"),  # フ + ゚ -> プ
    ("\u30d8\u309a", "\u30da"),  # ヘ + ゚ -> ペ
    ("\u30db\u309a", "\u30dd"),  # ホ + ゚ -> ポ
    # Special katakana
    ("\u30a6\u3099", "\u30f4"),  # ウ + ゙ -> ヴ
    ("\u30ef\u3099", "\u30f7"),  # ワ + ゙ -> ヷ
    ("\u30f0\u3099", "\u30f8"),  # ヰ + ゙ -> ヸ
    ("\u30f1\u3099", "\u30f9"),  # ヱ + ゙ -> ヹ
    ("\u30f2\u3099", "\u30fa"),  # ヲ + ゙ -> ヺ
]


class Transliterator:
    """Hiragana-Katakana composition transliterator.

    Combines decomposed hiragana and katakana characters into their composed
    equivalents. For example, か + ゙ becomes が.
    """

    compose_non_combining_marks: bool
    composition_mappings: dict[str, dict[str, str]]

    def __init__(self, *, compose_non_combining_marks: bool = True) -> None:
        """Initialize the transliterator with options.

        :param compose_non_combining_marks: Whether to also compose non-combining
                marks (゛ and ゜) in addition to combining marks (゙ and ゚).
                Defaults to True.
        """
        self.compose_non_combining_marks = compose_non_combining_marks
        self.composition_mappings = self._build_composition_mappings()

    def _build_composition_mappings(self) -> dict[str, dict[str, str]]:
        """Build the composition mapping trie structure."""
        mappings: dict[str, dict[str, str]] = {}

        for decomposed, composed in COMPOSITION_TABLE:
            base_char = decomposed[0]
            modifier = decomposed[1]

            if base_char not in mappings:
                mappings[base_char] = {}
            mappings[base_char][modifier] = composed

            # If compose_non_combining_marks is True, also handle non-combining marks
            if self.compose_non_combining_marks:
                # Convert combining marks to non-combining marks
                # ゙ (U+3099) -> ゛ (U+309B)
                # ゚ (U+309A) -> ゜ (U+309C)
                if modifier == "\u3099":  # combining voiced sound mark
                    mappings[base_char]["\u309b"] = composed  # non-combining voiced
                elif modifier == "\u309a":  # combining semi-voiced sound mark
                    mappings[base_char]["\u309c"] = composed  # non-combining semi-voiced

        return mappings

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Compose decomposed hiragana and katakana characters."""
        offset = 0
        prev_char: Char | None = None
        prev_mappings: dict[str, str] | None = None

        for char in input_chars:
            # Check if we have a pending base character and this could be a modifier
            if prev_mappings is not None and prev_char is not None:
                composed = prev_mappings.get(char.c)
                if composed is not None:
                    # Found a composition, yield the composed character
                    yield Char(c=composed, offset=offset, source=prev_char)
                    offset += len(composed)
                    prev_char = prev_mappings = None
                    continue

                # No composition found, yield the previous character
                yield Char(c=prev_char.c, offset=offset, source=prev_char)
                offset += len(prev_char.c)
                prev_char = prev_mappings = None

            # Check if this character can be a base for composition
            mappings = self.composition_mappings.get(char.c)
            if mappings is not None:
                # This character might be composed with the next one
                prev_char = char
                prev_mappings = mappings
                continue

            # Regular character, just pass it through
            yield Char(c=char.c, offset=offset, source=char)
            offset += len(char.c)

        # Handle any remaining character
        if prev_char is not None:
            yield Char(c=prev_char.c, offset=offset, source=prev_char)
            offset += len(prev_char.c)
