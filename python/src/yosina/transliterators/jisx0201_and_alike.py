"""JIS X 0201 and alike transliterator for fullwidth/halfwidth conversion."""

from collections import defaultdict
from collections.abc import Iterable, Set
from dataclasses import dataclass
from functools import cache
from typing import Literal

from ..chars import Char
from .hira_kata_table import HIRAGANA_KATAKANA_SMALL_TABLE, HIRAGANA_KATAKANA_TABLE

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

Overrides = Literal[
    "u005c_as_yen_sign",
    "u005c_as_backslash",
    "u007e_as_fullwidth_tilde",
    "u007e_as_wave_dash",
    "u007e_as_overline",
    "u007e_as_fullwidth_macron",
    "u00a5_as_yen_sign",
]

# Special GL overrides
JISX0201_GL_OVERRIDES: dict[Overrides, list[tuple[str, str]]] = {
    "u005c_as_yen_sign": [("\uffe5", "\u005c")],  # ￥ to \
    "u005c_as_backslash": [("\uff3c", "\u005c")],  # ＼ to \
    "u007e_as_fullwidth_tilde": [("\uff5e", "\u007e")],  # ～ to ~
    "u007e_as_wave_dash": [("\u301c", "\u007e")],  # 〜 to ~
    "u007e_as_overline": [("\u203e", "\u007e")],  # ‾ to ~
    "u007e_as_fullwidth_macron": [("\uffe3", "\u007e")],  # ￣ to ~
    "u00a5_as_yen_sign": [("\uffe5", "\u00a5")],  # ￥ to ¥
}


# Generate GR table from shared table
def _generate_gr_table() -> list[tuple[str, str]]:
    """Generate GR table from shared hiragana-katakana table."""
    result: list[tuple[str, str]] = [
        ("\u3002", "\uff61"),  # 。 to ｡
        ("\u300c", "\uff62"),  # 「 to ｢
        ("\u300d", "\uff63"),  # 」 to ｣
        ("\u3001", "\uff64"),  # 、 to ､
        ("\u30fb", "\uff65"),  # ・ to ･
        ("\u30fc", "\uff70"),  # ー to ｰ
        ("\u309b", "\uff9e"),  # ゛ to ﾞ
        ("\u309c", "\uff9f"),  # ゜to ﾟ
    ]
    # Add katakana mappings from main table
    for _, katakana, halfwidth in HIRAGANA_KATAKANA_TABLE:
        if halfwidth is not None:
            result.append((katakana[0], halfwidth))
    # Add small kana mappings
    for _, katakana, halfwidth in HIRAGANA_KATAKANA_SMALL_TABLE:
        if halfwidth is not None:
            result.append((katakana, halfwidth))
    return result


# GR area mapping table (fullwidth katakana to halfwidth katakana)
JISX0201_GR_TABLE = _generate_gr_table()


# Generate voiced letters table from shared table
def _generate_voiced_letters_table() -> list[tuple[str, str]]:
    """Generate voiced letters table from shared hiragana-katakana table."""
    result: list[tuple[str, str]] = []
    for _, katakana, halfwidth in HIRAGANA_KATAKANA_TABLE:
        if halfwidth is not None:
            if katakana[1] is not None:  # Has voiced form
                result.append((katakana[1], f"{halfwidth}\uff9e"))
            if katakana[2] is not None:  # Has semi-voiced form
                result.append((katakana[2], f"{halfwidth}\uff9f"))
    return result


# Voiced letters (dakuten/handakuten combinations)
VOICED_LETTERS_TABLE = _generate_voiced_letters_table()


# Generate hiragana mappings from shared table
def _generate_hiragana_mappings() -> dict[str, str]:
    """Generate hiragana mappings from shared hiragana-katakana table."""
    result: dict[str, str] = {}
    # Add main table hiragana mappings
    for hiragana, _, halfwidth in HIRAGANA_KATAKANA_TABLE:
        if halfwidth is not None:
            result[hiragana[0]] = halfwidth
            if hiragana[1] is not None:  # Has voiced form
                result[hiragana[1]] = f"{halfwidth}\uff9e"
            if hiragana[2] is not None:  # Has semi-voiced form
                result[hiragana[2]] = f"{halfwidth}\uff9f"
    # Add small kana mappings
    for hiragana, _, halfwidth in HIRAGANA_KATAKANA_SMALL_TABLE:
        if halfwidth is not None:
            result[hiragana] = halfwidth
    return result


# Hiragana mappings (for convert_hiraganas option)
HIRAGANA_MAPPINGS = _generate_hiragana_mappings()

# Special punctuations
SPECIAL_PUNCTUATIONS_TABLE = [("\u30a0", "\u003d")]  # ゠ to =


@dataclass(frozen=True)
class _OptionsBase:
    convert_gl: bool
    convert_gr: bool
    convert_unsafe_specials: bool
    u005c_as_yen_sign: bool
    u005c_as_backslash: bool
    u007e_as_fullwidth_tilde: bool
    u007e_as_wave_dash: bool
    u007e_as_overline: bool
    u007e_as_fullwidth_macron: bool
    u00a5_as_yen_sign: bool

    def overrides(self) -> Set[Overrides]:
        """Get enabled overrides as an iterable."""
        retval: set[Overrides] = set()
        if self.u005c_as_yen_sign:
            retval.add("u005c_as_yen_sign")
        if self.u005c_as_backslash:
            retval.add("u005c_as_backslash")
        if self.u007e_as_fullwidth_tilde:
            retval.add("u007e_as_fullwidth_tilde")
        if self.u007e_as_wave_dash:
            retval.add("u007e_as_wave_dash")
        if self.u007e_as_overline:
            retval.add("u007e_as_overline")
        if self.u007e_as_fullwidth_macron:
            retval.add("u007e_as_fullwidth_macron")
        if self.u00a5_as_yen_sign:
            retval.add("u00a5_as_yen_sign")
        return retval


@dataclass(frozen=True)
class _ForwardOptions(_OptionsBase):
    convert_hiraganas: bool


@dataclass(frozen=True)
class _ReverseOptions(_OptionsBase):
    combine_voiced_sound_marks: bool


@cache
def _get_fwd_mappings(options: _ForwardOptions) -> dict[str, str]:
    """Get forward mappings from cache or build new ones."""

    # Build new mappings
    mappings: dict[str, str] = {}

    if options.convert_gl:
        # Add basic GL mappings
        mappings.update(dict(JISX0201_GL_TABLE))

        # Add override mappings
        for k in options.overrides():
            mappings.update(dict(JISX0201_GL_OVERRIDES[k]))

        if options.convert_unsafe_specials:
            mappings.update(dict(SPECIAL_PUNCTUATIONS_TABLE))

    if options.convert_gr:
        # Add basic GR mappings
        mappings.update(dict(JISX0201_GR_TABLE))
        mappings.update(dict(VOICED_LETTERS_TABLE))
        # Add combining marks
        mappings["\u3099"] = "\uff9e"  # combining dakuten
        mappings["\u309a"] = "\uff9f"  # combining handakuten

        if options.convert_hiraganas:
            mappings.update(HIRAGANA_MAPPINGS)

    return mappings


@cache
def _get_rev_mappings(options: _ReverseOptions) -> dict[str, str]:
    """Get reverse mappings from cache or build new ones."""
    # Build new mappings
    mappings: dict[str, str] = {}

    if options.convert_gl:
        # Add basic GL reverse mappings
        for fw, hw in JISX0201_GL_TABLE:
            mappings[hw] = fw

        # Add override reverse mappings
        for k in options.overrides():
            for fw, hw in JISX0201_GL_OVERRIDES[k]:
                mappings[hw] = fw

        if options.convert_unsafe_specials:
            for fw, hw in SPECIAL_PUNCTUATIONS_TABLE:
                mappings[hw] = fw

    if options.convert_gr:
        # Add basic GR reverse mappings
        for fw, hw in JISX0201_GR_TABLE:
            mappings[hw] = fw

    return mappings


@cache
def _get_voiced_rev_mappings() -> dict[str, dict[str, str]]:
    voiced_rev_mappings = defaultdict[str, dict[str, str]](dict)
    for fw, hw in VOICED_LETTERS_TABLE:
        voiced_rev_mappings[hw[0]][hw[1]] = fw
    return voiced_rev_mappings


def _convert_fullwidth_to_halfwidth(options: _ForwardOptions, chars: Iterable[Char]) -> Iterable[Char]:
    """Convert fullwidth characters to halfwidth."""
    # Get cached mappings
    fwd_mappings = _get_fwd_mappings(options)
    offset = 0
    for char in chars:
        mapped = fwd_mappings.get(char.c)
        if mapped is not None:
            yield Char(c=mapped, offset=offset, source=char)
            offset += len(mapped)
        else:
            yield char.with_offset(offset)
            offset += len(char.c)


def _convert_halfwidth_to_fullwidth(options: _ReverseOptions, chars: Iterable[Char]) -> Iterable[Char]:
    """Convert halfwidth characters to fullwidth."""
    rev_mappings = _get_rev_mappings(options)
    voiced_rev_mappings = (
        _get_voiced_rev_mappings() if options.combine_voiced_sound_marks and options.convert_gr else None
    )

    chars_iter = iter(chars)
    pending_char = None
    offset = 0
    for char in chars_iter:
        if pending_char is not None:
            # Check if this char can combine with the pending one
            base_char, voice_mappings = pending_char
            combined = voice_mappings.get(char.c)
            if combined is not None:
                # Yield the combined character
                yield Char(c=combined, offset=offset, source=base_char)
                pending_char = None
                offset += len(combined)
                continue
            else:
                # Can't combine, yield the pending character first
                mapped = rev_mappings.get(base_char.c)
                if mapped is not None:
                    yield Char(c=mapped, offset=offset, source=base_char)
                    offset += len(mapped)
                else:
                    yield base_char.with_offset(offset)
                    offset += len(base_char.c)
                pending_char = None

        # Check if this character might start a combination
        if voiced_rev_mappings is not None and char.c in voiced_rev_mappings:
            pending_char = (char, voiced_rev_mappings[char.c])
        else:
            # Normal mapping
            mapped = rev_mappings.get(char.c)
            if mapped is not None:
                yield Char(c=mapped, offset=offset, source=char)
                offset += len(mapped)
            else:
                yield char.with_offset(offset)
                offset += len(char.c)

    # Handle any remaining pending character
    if pending_char is not None:
        base_char, _ = pending_char
        mapped = rev_mappings.get(base_char.c)
        if mapped is not None:
            yield Char(c=mapped, offset=offset, source=base_char)
            offset += len(mapped)
        else:
            yield base_char.with_offset(offset)
            offset += len(base_char.c)


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

    options: _ForwardOptions | _ReverseOptions

    def __init__(
        self,
        *,
        fullwidth_to_halfwidth: bool = True,
        convert_gl: bool = True,
        convert_gr: bool = True,
        convert_hiraganas: bool = False,
        combine_voiced_sound_marks: bool = True,
        convert_unsafe_specials: bool | None = None,
        u005c_as_yen_sign: bool | None = None,
        u005c_as_backslash: bool | None = None,
        u007e_as_fullwidth_tilde: bool | None = None,
        u007e_as_wave_dash: bool | None = None,
        u007e_as_overline: bool | None = None,
        u007e_as_fullwidth_macron: bool | None = None,
        u00a5_as_yen_sign: bool | None = None,
    ) -> None:
        """Initialize the transliterator with options.

        :param fullwidth_to_halfwidth: Whether to convert fullwidth to halfwidth. Defaults to True.
        :param convert_gl: Whether to convert GL characters. Defaults to True.
        :param convert_gr: Whether to convert GR characters (hankaku kana). Defaults to True.
        :param convert_hiraganas: Convert hiraganas. Defaults to False.
        :param combine_voiced_sound_marks: Combine voiced sound marks. Defaults to True.
        :param convert_unsafe_specials: Convert U+30A0 to U+003D. Defaults to False
                                        if ``fullwidth_to_halfwidth`` is ``True``, ``False`` otherwise.
        :param u005c_as_yen_sign: Whether to treat backslash as yen sign.
                                  Defaults to True, if
                                  - *Fullwidth to halfwidth mode*: neither ``005c_as_yen_sign`` nor
                                    ``u005c_as_backslash`` is explictly set to any value.
                                  - *Halfwidth to fullwidth mode*: neither ``u005c_as_yen_sign`` nor
                                    ``u005c_as_backslash`` is explicitly set to any value.
        :param u005c_as_backslash: Whether to treat U+005C verbatim. Defaults to False.
        :param u007e_as_fullwidth_tilde: Convert U+007E to U+FF5E. Defaults to True
                                  - *Fullwidth to halfwidth mode**: if not explicitly set to any value.
                                  - *Halfwidth to fullwidth mode**: neither ``u007e_as_fullwidth_tilde``,
                                    ``u007e_as_wave_dash``, ``u007e_as_overline``, nor
                                    ``u007e_as_fullwidth_macron`` is explicitly set to any value.
        :param u007e_as_wave_dash: Convert U+007E to U+301C. Defaults to False.
        :param u007e_as_overline: Convert U+007E to U+203E. Defaults to False.
        :param u007e_as_fullwidth_macron: Convert U+007E to U+FFE3. Defaults to False.
        :param u00a5_as_yen_sign: Convert U+00A5 to U+005C.
                                  - *Fullwidth to halfwidth mode*: defaults to False.
                                  - *Halfwidth to fullwidth mode*: defaults to True.
        """
        if fullwidth_to_halfwidth:
            self.options = _ForwardOptions(
                convert_gl=convert_gl,
                convert_gr=convert_gr,
                convert_unsafe_specials=convert_unsafe_specials if convert_unsafe_specials is not None else True,
                u005c_as_yen_sign=u005c_as_yen_sign if u005c_as_yen_sign is not None else u00a5_as_yen_sign is None,
                u005c_as_backslash=u005c_as_backslash if u005c_as_backslash is not None else False,
                u007e_as_fullwidth_tilde=u007e_as_fullwidth_tilde if u007e_as_fullwidth_tilde is not None else True,
                u007e_as_wave_dash=u007e_as_wave_dash if u007e_as_wave_dash is not None else True,
                u007e_as_overline=u007e_as_overline if u007e_as_overline is not None else False,
                u007e_as_fullwidth_macron=u007e_as_fullwidth_macron if u007e_as_fullwidth_macron is not None else False,
                u00a5_as_yen_sign=u00a5_as_yen_sign if u00a5_as_yen_sign is not None else False,
                convert_hiraganas=convert_hiraganas,
            )
        else:
            self.options = _ReverseOptions(
                convert_gl=convert_gl,
                convert_gr=convert_gr,
                convert_unsafe_specials=convert_unsafe_specials if convert_unsafe_specials is not None else False,
                u005c_as_yen_sign=u005c_as_yen_sign if u005c_as_yen_sign is not None else u005c_as_backslash is None,
                u005c_as_backslash=u005c_as_backslash if u005c_as_backslash is not None else False,
                u007e_as_fullwidth_tilde=u007e_as_fullwidth_tilde
                if u007e_as_fullwidth_tilde is not None
                else (u007e_as_wave_dash is None and u007e_as_overline is None and u007e_as_fullwidth_macron is None),
                u007e_as_wave_dash=u007e_as_wave_dash if u007e_as_wave_dash is not None else False,
                u007e_as_overline=u007e_as_overline if u007e_as_overline is not None else False,
                u007e_as_fullwidth_macron=u007e_as_fullwidth_macron if u007e_as_fullwidth_macron is not None else False,
                u00a5_as_yen_sign=u00a5_as_yen_sign if u00a5_as_yen_sign is not None else True,
                combine_voiced_sound_marks=combine_voiced_sound_marks,
            )

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Convert between fullwidth and halfwidth characters."""
        if isinstance(self.options, _ForwardOptions):
            yield from _convert_fullwidth_to_halfwidth(self.options, input_chars)
        else:
            yield from _convert_halfwidth_to_fullwidth(self.options, input_chars)
