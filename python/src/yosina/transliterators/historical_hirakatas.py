"""Historical hiragana/katakana conversion transliterator.

Converts historical hiragana/katakana characters to their modern equivalents.
"""

from collections.abc import Iterable
from typing import Literal

from ..chars import Char

__all__ = ["Transliterator"]

ConversionMode = Literal["simple", "decompose", "skip"]

_HISTORICAL_HIRAGANA_MAPPINGS: dict[str, dict[str, str]] = {
    "\u3090": {"simple": "\u3044", "decompose": "\u3046\u3043"},  # ゐ → い / うぃ
    "\u3091": {"simple": "\u3048", "decompose": "\u3046\u3047"},  # ゑ → え / うぇ
}

_HISTORICAL_KATAKANA_MAPPINGS: dict[str, dict[str, str]] = {
    "\u30f0": {"simple": "\u30a4", "decompose": "\u30a6\u30a3"},  # ヰ → イ / ウィ
    "\u30f1": {"simple": "\u30a8", "decompose": "\u30a6\u30a7"},  # ヱ → エ / ウェ
}

_VOICED_HISTORICAL_KANA_MAPPINGS: dict[str, str] = {
    "\u30f7": "\u30a1",  # ヷ → ァ
    "\u30f8": "\u30a3",  # ヸ → ィ
    "\u30f9": "\u30a7",  # ヹ → ェ
    "\u30fa": "\u30a9",  # ヺ → ォ
}

_VOICED_HISTORICAL_KANA_DECOMPOSED_MAPPINGS: dict[str, str] = {
    "\u30ef": "\u30a1",  # ヷ → ァ
    "\u30f0": "\u30a3",  # ヸ → ィ
    "\u30f1": "\u30a7",  # ヹ → ェ
    "\u30f2": "\u30a9",  # ヺ → ォ
}

_COMBINING_DAKUTEN = "\u3099"
_VU = "\u30f4"
_U = "\u30a6"


class Transliterator:
    """Historical hiragana/katakana conversion transliterator.

    Converts historical hiragana/katakana characters to their modern equivalents.
    """

    hiraganas: ConversionMode
    katakanas: ConversionMode
    voiced_katakanas: Literal["decompose", "skip"]

    def __init__(
        self,
        *,
        hiraganas: ConversionMode = "simple",
        katakanas: ConversionMode = "simple",
        voiced_katakanas: Literal["decompose", "skip"] = "skip",
    ) -> None:
        """Initialize the transliterator with options.

        :param hiraganas: How to convert historical hiragana (ゐ, ゑ).
            "simple" maps to modern equivalents, "decompose" expands to phonetic components,
            "skip" leaves them unchanged. Defaults to "simple".
        :param katakanas: How to convert historical katakana (ヰ, ヱ).
            "simple" maps to modern equivalents, "decompose" expands to phonetic components,
            "skip" leaves them unchanged. Defaults to "simple".
        :param voiced_katakanas: How to convert voiced historical katakana
            (ヷ, ヸ, ヹ, ヺ). "decompose" expands to ヴ + vowel, "skip" leaves them unchanged.
            Defaults to "skip".
        """
        self.hiraganas = hiraganas
        self.katakanas = katakanas
        self.voiced_katakanas = voiced_katakanas

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Convert historical hiragana/katakana to modern equivalents."""
        offset = 0
        pending: Char | None = None
        for char in input_chars:
            if pending is None:
                pending = char
                continue
            if char.c == _COMBINING_DAKUTEN:
                # Check if pending char could be a decomposed voiced base
                decomposed = _VOICED_HISTORICAL_KANA_DECOMPOSED_MAPPINGS.get(pending.c)
                if self.voiced_katakanas == "skip" or decomposed is None:
                    yield pending.with_offset(offset)
                    offset += len(pending.c)
                    pending = char
                    continue
                yield Char(c=_U, offset=offset, source=pending)
                offset += len(_U)
                yield char.with_offset(offset)
                offset += len(char.c)
                yield Char(c=decomposed, offset=offset, source=pending)
                offset += len(decomposed)
                pending = None
                continue
            yield from self._emit_char(pending, offset)
            offset += self._char_len(pending)
            pending = char

        # Flush any remaining buffered char
        if pending is not None:
            yield from self._emit_char(pending, offset)

    def _char_len(self, char: Char) -> int:
        """Return the output length of a char after processing."""
        hira = _HISTORICAL_HIRAGANA_MAPPINGS.get(char.c)
        if hira is not None and self.hiraganas != "skip":
            return len(hira[self.hiraganas])
        kata = _HISTORICAL_KATAKANA_MAPPINGS.get(char.c)
        if kata is not None and self.katakanas != "skip":
            return len(kata[self.katakanas])
        if self.voiced_katakanas == "decompose":
            voiced = _VOICED_HISTORICAL_KANA_MAPPINGS.get(char.c)
            if voiced is not None:
                return len(_VU) + len(voiced)
        return len(char.c)

    def _emit_char(self, char: Char, offset: int) -> Iterable[Char]:
        """Emit a single char through the normal mapping logic."""
        # Historical hiragana
        hira_mapping = _HISTORICAL_HIRAGANA_MAPPINGS.get(char.c)
        if hira_mapping is not None and self.hiraganas != "skip":
            replacement = hira_mapping[self.hiraganas]
            yield Char(c=replacement, offset=offset, source=char)
            return

        # Historical katakana
        kata_mapping = _HISTORICAL_KATAKANA_MAPPINGS.get(char.c)
        if kata_mapping is not None and self.katakanas != "skip":
            replacement = kata_mapping[self.katakanas]
            yield Char(c=replacement, offset=offset, source=char)
            return

        # Voiced historical katakana (composed form)
        if self.voiced_katakanas == "decompose":
            decomposed = _VOICED_HISTORICAL_KANA_MAPPINGS.get(char.c)
            if decomposed is not None:
                yield Char(c=_VU, offset=offset, source=char)
                yield Char(c=decomposed, offset=offset + len(_VU), source=char)
                return

        yield char.with_offset(offset)
