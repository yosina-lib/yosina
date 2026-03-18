"""Tests for historical-hirakatas transliterator."""

from yosina.chars import build_char_list
from yosina.transliterators.historical_hirakatas import Transliterator


class TestSimpleHiragana:
    """Tests for simple hiragana conversion (default)."""

    def test_basic(self) -> None:
        transliterator = Transliterator()
        chars = build_char_list("ゐゑ")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "いえ"

    def test_passthrough(self) -> None:
        transliterator = Transliterator()
        chars = build_char_list("あいう")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "あいう"

    def test_mixed(self) -> None:
        transliterator = Transliterator()
        chars = build_char_list("あゐいゑう")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "あいいえう"


class TestDecomposeHiragana:
    def test_decompose(self) -> None:
        transliterator = Transliterator(hiraganas="decompose", katakanas="skip")
        chars = build_char_list("ゐゑ")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "うぃうぇ"


class TestSkipHiragana:
    def test_skip(self) -> None:
        transliterator = Transliterator(hiraganas="skip", katakanas="skip")
        chars = build_char_list("ゐゑ")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ゐゑ"


class TestSimpleKatakana:
    def test_basic(self) -> None:
        transliterator = Transliterator()
        chars = build_char_list("ヰヱ")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "イエ"


class TestDecomposeKatakana:
    def test_decompose(self) -> None:
        transliterator = Transliterator(hiraganas="skip", katakanas="decompose")
        chars = build_char_list("ヰヱ")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ウィウェ"


class TestVoicedKatakanaDecompose:
    def test_decompose(self) -> None:
        transliterator = Transliterator(hiraganas="skip", katakanas="skip", voiced_katakanas="decompose")
        chars = build_char_list("ヷヸヹヺ")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ヴァヴィヴェヴォ"


class TestVoicedKatakanaSkip:
    def test_skip(self) -> None:
        transliterator = Transliterator(hiraganas="skip", katakanas="skip")
        chars = build_char_list("ヷヸヹヺ")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ヷヸヹヺ"


class TestAllDecompose:
    def test_all(self) -> None:
        transliterator = Transliterator(
            hiraganas="decompose",
            katakanas="decompose",
            voiced_katakanas="decompose",
        )
        chars = build_char_list("ゐゑヰヱヷヸヹヺ")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "うぃうぇウィウェヴァヴィヴェヴォ"


class TestAllSkip:
    def test_all(self) -> None:
        transliterator = Transliterator(hiraganas="skip", katakanas="skip", voiced_katakanas="skip")
        chars = build_char_list("ゐゑヰヱヷヸヹヺ")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ゐゑヰヱヷヸヹヺ"


class TestDecomposedVoicedKatakanaInput:
    """Tests that decomposed voiced katakana (base + combining dakuten) is handled
    identically to the precomposed form."""

    def test_decomposed_input_with_decompose_mode(self) -> None:
        """Decomposed ワ+゙ ヰ+゙ ヱ+゙ ヲ+゙ should convert like composed ヷヸヹヺ."""
        transliterator = Transliterator(hiraganas="skip", katakanas="skip", voiced_katakanas="decompose")
        chars = build_char_list("ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ウ\u3099ァウ\u3099ィウ\u3099ェウ\u3099ォ"

    def test_decomposed_input_with_skip_mode(self) -> None:
        """Decomposed voiced katakana with skip mode should pass through unchanged."""
        transliterator = Transliterator(hiraganas="skip", katakanas="skip", voiced_katakanas="skip")
        chars = build_char_list("ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099"

    def test_decomposed_voiced_not_split_from_base(self) -> None:
        """ヰ+゙ must be treated as ヸ (voiced), not as ヰ (katakana) + separate ゙."""
        transliterator = Transliterator(hiraganas="skip", katakanas="simple", voiced_katakanas="skip")
        chars = build_char_list("ヰ\u3099")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ヰ\u3099"

    def test_decomposed_voiced_with_decompose(self) -> None:
        """ヰ+゙ with voiced_katakanas=decompose should produce ウ+゙+ィ (decomposed)."""
        transliterator = Transliterator(hiraganas="skip", katakanas="skip", voiced_katakanas="decompose")
        chars = build_char_list("ヰ\u3099")
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ウ\u3099ィ"


class TestEmptyInput:
    def test_empty(self) -> None:
        transliterator = Transliterator()
        chars = build_char_list("")
        result = "".join(char.c for char in transliterator(chars))
        assert result == ""
