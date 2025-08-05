"""IVS/SVS base transliterator."""

from __future__ import annotations

from collections.abc import Callable, Iterable
from typing import Literal

from ..chars import Char
from .ivs_svs_base_data import (
    IvsSvsBaseRecord,
    get_base_to_variants_mappings,
    get_variants_to_base_mappings,
)

__all__ = ["Transliterator"]

Charset = Literal["unijis_90", "unijis_2004"]
Mode = Literal["ivs-or-svs", "base"]


class ForwardTransliterator:
    """Forward iterator to handle IVS/SVS sequences."""

    base_to_variants: dict[str, IvsSvsBaseRecord]
    prefer_svs: bool

    def __call__(
        self,
        input_chars: Iterable[Char],
    ) -> Iterable[Char]:
        offset = 0
        for char in input_chars:
            # Try to add IVS/SVS selectors to base characters
            record = self.base_to_variants.get(char.c)
            replacement = None
            if record is not None:
                if self.prefer_svs and record.svs is not None:
                    replacement = record.svs
                else:
                    replacement = record.ivs
            if replacement is not None:
                yield Char(c=replacement, offset=offset, source=char)
                offset += len(replacement)
            else:
                yield Char(c=char.c, offset=offset, source=char.source)
                offset += len(char.c)

    def __init__(
        self,
        base_to_variants: dict[str, IvsSvsBaseRecord],
        prefer_svs: bool,
    ) -> None:
        """Initialize the forward transliterator with options.

        :param base_to_variants: Mapping of base characters to their IVS/SVS variants.
        :param prefer_svs: Whether to prefer SVS over IVS when both exist.
        """
        self.base_to_variants = base_to_variants
        self.prefer_svs = prefer_svs


class ReverseTransliterator:
    """Reverse iterator to handle IVS/SVS sequences."""

    variants_to_base: dict[str, IvsSvsBaseRecord]
    charset: Charset
    drop_selectors_altogether: bool

    def __call__(
        self,
        input_chars: Iterable[Char],
    ) -> Iterable[Char]:
        offset = 0
        for char in input_chars:
            replacement = None

            # Try to remove IVS/SVS selectors
            record = self.variants_to_base.get(char.c)
            if record is not None:
                if self.charset == "unijis_2004" and record.base2004 is not None:
                    replacement = record.base2004
                elif self.charset == "unijis_90" and record.base90 is not None:
                    replacement = record.base90

            if replacement is None and self.drop_selectors_altogether and len(char.c) > 1:
                # Still no replacement found, try to remove variation selectors manually
                second_char = char.c[1]
                if ("\ufe00" <= second_char <= "\ufe0f") or ("\U000e0100" <= second_char <= "\U000e01ef"):
                    replacement = char.c[0]

            if replacement is not None:
                yield Char(c=replacement, offset=offset, source=char)
                offset += len(replacement)
            else:
                yield Char(c=char.c, offset=offset, source=char.source)
                offset += len(char.c)

    def __init__(
        self,
        variants_to_base: dict[str, IvsSvsBaseRecord],
        charset: Charset,
        drop_selectors_altogether: bool,
    ) -> None:
        """Initialize the reverse transliterator with options.

        :param variants_to_base: Mapping of IVS/SVS characters to their base forms.
        :param charset: The charset to use for base mappings.
        :param drop_selectors_altogether: Whether to drop all selectors.
        """
        self.variants_to_base = variants_to_base
        self.charset = charset
        self.drop_selectors_altogether = drop_selectors_altogether


class Transliterator:
    """IVS/SVS base transliterator.

    This transliterator handles Ideographic Variation Sequences (IVS) and
    Standardized Variation Sequences (SVS) based on Adobe-Japan1 mappings.
    It can either add variation selectors to kanji or remove them to get base forms.
    """

    mode: Mode
    drop_selectors_altogether: bool
    charset: Charset
    prefer_svs: bool
    _inner: Callable[[Iterable[Char]], Iterable[Char]]

    def __init__(
        self,
        *,
        mode: Mode = "base",
        drop_selectors_altogether: bool = False,
        charset: Charset = "unijis_2004",
        prefer_svs: bool = False,
    ) -> None:
        """Initialize the transliterator with options.

        :param mode: The mode of operation ("ivs-or-svs", "base"). Defaults to "base".
                     - "ivs-or-svs": Add IVS/SVS selectors to kanji characters
                     - "base": Remove IVS/SVS selectors to get base characters
        :param drop_selectors_altogether: Whether to drop all selectors when mode is "base". Defaults to False.
        :param charset: The charset to use for base mappings ("unijis_90" or "unijis_2004"). Defaults to "unijis_2004".
        :param prefer_svs: When mode is "ivs-or-svs", prefer SVS over IVS if both exist. Defaults to False.
        """
        self.mode = mode
        self.drop_selectors_altogether = drop_selectors_altogether
        self.charset = charset
        self.prefer_svs = prefer_svs
        if self.mode == "ivs-or-svs":
            self._inner = ForwardTransliterator(
                get_base_to_variants_mappings(self.charset),
                self.prefer_svs,
            )
        else:
            self._inner = ReverseTransliterator(
                get_variants_to_base_mappings(),
                self.charset,
                self.drop_selectors_altogether,
            )

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Handle IVS/SVS sequences."""
        return self._inner(input_chars)
