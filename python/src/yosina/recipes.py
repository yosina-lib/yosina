"""Recipe-based transliterator configuration."""

from __future__ import annotations

from collections.abc import Sequence
from dataclasses import dataclass
from typing import Literal

from .transliterators import TransliteratorConfig

__all__ = ["TransliteratorRecipe", "build_transliterator_configs_from_recipe"]

Charset = Literal["unijis_2004", "adobe_japan1"]
Mapping = Literal["jisx0208_90_windows", "jisx0201"]


@dataclass(frozen=True)
class TransliteratorRecipe:
    """Configuration recipe for building transliterator chains."""

    kanji_old_new: bool = False
    """Replace codepoints that correspond to old-style kanji glyphs (旧字体; kyu-ji-tai)
    with their modern equivalents (新字体; shin-ji-tai).

    Example:
        Input:  "舊字體の變換"
        Output: "旧字体の変換"
    """

    replace_suspicious_hyphens_to_prolonged_sound_marks: bool = False
    """Replace "suspicious" hyphens with prolonged sound marks, and vice versa.

    Example:
        Input:  "データーベース"
        Output: "データーベース" (no change when followed by ー)
        Input:  "スーパ−" (with hyphen-minus)
        Output: "スーパー" (becomes prolonged sound mark)
    """

    replace_combined_characters: bool = False
    """Replace combined characters with their corresponding characters.

    Example:
        Input:  "㍻" (single character for Heisei era)
        Output: "平成"
        Input:  "㈱"
        Output: "(株)"
    """

    replace_circled_or_squared_characters: bool | Literal["exclude-emojis"] = False
    """Replace circled or squared characters with their corresponding templates.

    Example:
        Input:  "①②③"
        Output: "(1)(2)(3)"
        Input:  "㊙㊗"
        Output: "(秘)(祝)"
    """

    replace_ideographic_annotations: bool = False
    """Replace ideographic annotations used in the traditional method of
    Chinese-to-Japanese translation devised in ancient Japan.

    Example:
        Input:  "㆖㆘" (ideographic annotations)
        Output: "上下"
    """

    replace_radicals: bool = False
    """Replace codepoints for the Kang Xi radicals whose glyphs resemble those of
    CJK ideographs with the CJK ideograph counterparts.

    Example:
        Input:  "⾔⾨⾷" (Kangxi radicals)
        Output: "言門食" (CJK ideographs)
    """

    replace_spaces: bool = False
    """Replace various space characters with plain whitespaces or empty strings.

    Example:
        Input:  "A　B" (ideographic space U+3000)
        Output: "A B" (half-width space)
        Input:  "A B" (non-breaking space U+00A0)
        Output: "A B" (regular space)
    """

    replace_hyphens: bool | list[Mapping] = False
    """Replace various dash or hyphen symbols with those common in Japanese writing.

    Example:
        Input:  "2019—2020" (em dash)
        Output: "2019-2020" (hyphen-minus)
        Input:  "A–B" (en dash)
        Output: "A-B"
    """

    replace_mathematical_alphanumerics: bool = False
    """Replace mathematical alphanumerics with their plain ASCII equivalents.

    Example:
        Input:  "𝐀𝐁𝐂" (mathematical bold)
        Output: "ABC"
        Input:  "𝟏𝟐𝟑" (mathematical bold digits)
        Output: "123"
    """

    combine_decomposed_hiraganas_and_katakanas: bool = False
    """Combine decomposed hiraganas and katakanas into single counterparts.

    Example:
        Input:  "が" (か + ゙)
        Output: "が" (single character)
        Input:  "ヘ゜" (ヘ + ゜)
        Output: "ペ" (single character)
    """

    to_fullwidth: bool | Literal["u005c-as-yen-sign"] = False
    """Replace half-width characters to fullwidth equivalents.
    Specify "u005c-as-yen-sign" to treat backslash (U+005C) as yen sign in JIS X 0201.

    Example:
        Input:  "ABC123"
        Output: "ＡＢＣ１２３"
        Input:  "ｶﾀｶﾅ"
        Output: "カタカナ"
    """

    to_halfwidth: bool | Literal["hankaku-kana"] = False
    """Replace full-width characters with their half-width equivalents.
    Specify "hankaku-kana" to handle half-width katakanas too.

    Example:
        Input:  "ＡＢＣ１２３"
        Output: "ABC123"
        Input:  "カタカナ" (with hankaku-kana)
        Output: "ｶﾀｶﾅ"
    """

    remove_ivs_svs: bool | Literal["drop-all-selectors"] = False
    """Replace CJK ideographs followed by IVSes and SVSes with those without selectors
    based on Adobe-Japan1 character mappings.
    Specify "drop-all-selectors" to get rid of all selectors from the result.

    Example:
        Input:  "葛󠄀" (葛 + IVS U+E0100)
        Output: "葛" (without selector)
        Input:  "辻󠄀" (辻 + IVS)
        Output: "辻"
    """

    charset: Charset = "unijis_2004"
    """Charset assumed during IVS/SVS transliteration. Default is "unijis_2004"."""


class _TransliteratorConfigListBuilder:
    """Internal builder for creating lists of transliterator configurations."""

    head: Sequence[TransliteratorConfig]
    tail: Sequence[TransliteratorConfig]

    def __init__(
        self,
        head: Sequence[TransliteratorConfig] = (),
        tail: Sequence[TransliteratorConfig] = (),
    ) -> None:
        self.head = head
        self.tail = tail

    def insert_head(self, config: TransliteratorConfig, force_replace: bool = False) -> _TransliteratorConfigListBuilder:
        """Insert config at the head of the chain."""
        i = next((i for i, c in enumerate(self.head) if c[0] == config[0]), -1)
        if i >= 0 and not force_replace:
            return self

        return _TransliteratorConfigListBuilder(
            head=(
                (*self.head[:i], config, *self.head[i + 1 :])
                if i >= 0
                else (
                    *self.head,
                    config,
                )
            ),
            tail=self.tail,
        )

    def insert_middle(
        self, config: TransliteratorConfig, force_replace: bool = False
    ) -> _TransliteratorConfigListBuilder:
        """Insert config in the middle (tail list, at beginning)."""
        i = next((i for i, c in enumerate(self.tail) if c[0] == config[0]), -1)
        if i >= 0 and not force_replace:
            return self

        return _TransliteratorConfigListBuilder(
            head=self.head,
            tail=(
                (*self.tail[:i], config, *self.tail[i + 1 :])
                if i >= 0
                else (
                    config,
                    *self.tail,
                )
            ),
        )

    def insert_tail(self, config: TransliteratorConfig, force_replace: bool = False) -> _TransliteratorConfigListBuilder:
        """Insert config at the tail of the chain."""
        i = next((i for i, c in enumerate(self.tail) if c[0] == config[0]), -1)
        if i >= 0 and not force_replace:
            return self

        return _TransliteratorConfigListBuilder(
            head=self.head,
            tail=(
                (*self.tail[:i], config, *self.tail[i + 1 :])
                if i >= 0
                else (
                    *self.tail,
                    config,
                )
            ),
        )

    def _apply_remove_ivs_svs_inner(
        self,
        drop_selectors_altogether: bool,
        charset: Charset,
    ) -> _TransliteratorConfigListBuilder:
        """Helper to add IVS/SVS removal configurations."""
        ctx = self
        ctx = ctx.insert_head(("ivs-svs-base", {"mode": "ivs-or-svs"}), True)
        ctx = ctx.insert_tail(
            (
                "ivs-svs-base",
                {
                    "mode": "base",
                    "drop_selectors_altogether": drop_selectors_altogether,
                    "charset": charset,
                },
            ),
            True,
        )
        return ctx

    def apply_kanji_old_new(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        ctx = self
        if recipe.kanji_old_new:
            ctx = self._apply_remove_ivs_svs_inner(False, recipe.charset)
            ctx = ctx.insert_middle(("kanji-old-new", {}))
        return ctx

    def apply_replace_suspicious_hyphens_to_prolonged_sound_marks(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        ctx = self
        if recipe.replace_suspicious_hyphens_to_prolonged_sound_marks:
            ctx = ctx.insert_middle(
                (
                    "prolonged-sound-marks",
                    {"replace_prolonged_marks_following_alnums": True},
                )
            )
        return ctx

    def apply_replace_combined_characters(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        ctx = self
        if recipe.replace_combined_characters:
            ctx = ctx.insert_middle(("combined", {}))
        return ctx

    def apply_replace_circled_or_squared_characters(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        ctx = self
        if recipe.replace_circled_or_squared_characters:
            ctx = ctx.insert_middle(
                (
                    "circled-or-squared",
                    {
                        "include_emojis": recipe.replace_circled_or_squared_characters != "exclude-emojis",
                    },
                )
            )
        return ctx

    def apply_replace_ideographic_annotations(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        ctx = self
        if recipe.replace_ideographic_annotations:
            ctx = ctx.insert_middle(("ideographic-annotations", {}))
        return ctx

    def apply_replace_radicals(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        ctx = self
        if recipe.replace_radicals:
            ctx = ctx.insert_middle(("radicals", {}))
        return ctx

    def apply_replace_spaces(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        ctx = self
        if recipe.replace_spaces:
            ctx = ctx.insert_middle(("spaces", {}))
        return ctx

    def apply_replace_hyphens(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        ctx = self
        if recipe.replace_hyphens:
            precedence = (
                ["jisx0208_90_windows", "jisx0201"]
                if isinstance(recipe.replace_hyphens, bool)
                else recipe.replace_hyphens
            )
            ctx = ctx.insert_middle(("hyphens", {"precedence": precedence}))
        return ctx

    def apply_replace_mathematical_alphanumerics(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        ctx = self
        if recipe.replace_mathematical_alphanumerics:
            ctx = ctx.insert_middle(("mathematical-alphanumerics", {}))
        return ctx

    def apply_combine_decomposed_hiraganas_and_katakanas(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        ctx = self
        if recipe.combine_decomposed_hiraganas_and_katakanas:
            ctx = ctx.insert_middle(("hira-kata-composition", {"compose_non_combining_marks": True}))
        return ctx

    def apply_to_fullwidth(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        ctx = self
        if recipe.to_fullwidth:
            ctx = ctx.insert_tail(
                (
                    "jisx0201-and-alike",
                    {
                        "fullwidth_to_halfwidth": False,
                        "combine_voiced_sound_marks": True,
                        "u005c_as_yen_sign": recipe.to_fullwidth == "u005c-as-yen-sign",
                    },
                )
            )
        return ctx

    def apply_to_halfwidth(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        """Apply the to_halfwidth transformation."""
        ctx = self
        if recipe.to_halfwidth:
            ctx = ctx.insert_tail(
                (
                    "jisx0201-and-alike",
                    {
                        "fullwidth_to_halfwidth": True,
                        "convert_gl": True,
                        "convert_gr": recipe.to_halfwidth == "hankaku-kana",
                    },
                )
            )
        return ctx

    def apply_remove_ivs_svs(
        self,
        recipe: TransliteratorRecipe,
    ) -> _TransliteratorConfigListBuilder:
        """Apply the remove_ivs_svs transformation."""
        ctx = self
        if recipe.remove_ivs_svs:
            ctx = ctx._apply_remove_ivs_svs_inner(
                recipe.remove_ivs_svs == "drop-all-selectors",
                recipe.charset,
            )
        return ctx

    def build(self) -> Sequence[TransliteratorConfig]:
        """Build the final configuration list."""
        return (*self.head, *self.tail)


def build_transliterator_configs_from_recipe(
    recipe: TransliteratorRecipe,
) -> Sequence[TransliteratorConfig]:
    """Build an array of TransliteratorConfig from a recipe object.

    :param recipe: A TransliteratorRecipe object specifying the desired transformations
    :returns: A list of TransliteratorConfig that can be passed to make_chained_transliterator
    :raises ValueError: If the recipe contains mutually exclusive options
    """
    ctx = _TransliteratorConfigListBuilder()

    # Check for mutually exclusive options
    errors: list[str] = []
    if recipe.to_fullwidth and recipe.to_halfwidth:
        errors.append("to_fullwidth and to_halfwidth are mutually exclusive")

    if errors:
        raise ValueError("; ".join(errors))

    # Must keep the application order to comply with the specification.
    ctx = ctx.apply_kanji_old_new(recipe)
    ctx = ctx.apply_replace_suspicious_hyphens_to_prolonged_sound_marks(recipe)
    ctx = ctx.apply_replace_circled_or_squared_characters(recipe)
    ctx = ctx.apply_replace_combined_characters(recipe)
    ctx = ctx.apply_replace_ideographic_annotations(recipe)
    ctx = ctx.apply_replace_radicals(recipe)
    ctx = ctx.apply_replace_spaces(recipe)
    ctx = ctx.apply_replace_hyphens(recipe)
    ctx = ctx.apply_replace_mathematical_alphanumerics(recipe)
    ctx = ctx.apply_combine_decomposed_hiraganas_and_katakanas(recipe)
    ctx = ctx.apply_to_fullwidth(recipe)
    ctx = ctx.apply_to_halfwidth(recipe)
    ctx = ctx.apply_remove_ivs_svs(recipe)

    return ctx.build()
