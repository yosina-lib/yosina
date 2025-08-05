"""Tests for hira-kata transliterator."""

from yosina.chars import build_char_list
from yosina.transliterators.hira_kata import Transliterator


class TestHiraToKata:
    """Tests for hiragana to katakana conversion."""

    def test_basic(self) -> None:
        """Test basic hiragana conversion."""
        transliterator = Transliterator(mode="hira-to-kata")
        input_text = "あいうえお"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "アイウエオ"

    def test_voiced(self) -> None:
        """Test voiced hiragana conversion."""
        transliterator = Transliterator(mode="hira-to-kata")
        input_text = "がぎぐげご"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ガギグゲゴ"

    def test_semi_voiced(self) -> None:
        """Test semi-voiced hiragana conversion."""
        transliterator = Transliterator(mode="hira-to-kata")
        input_text = "ぱぴぷぺぽ"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "パピプペポ"

    def test_small(self) -> None:
        """Test small hiragana conversion."""
        transliterator = Transliterator(mode="hira-to-kata")
        input_text = "ぁぃぅぇぉっゃゅょ"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ァィゥェォッャュョ"

    def test_mixed(self) -> None:
        """Test mixed text conversion."""
        transliterator = Transliterator(mode="hira-to-kata")
        input_text = "あいうえお123ABCアイウエオ"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "アイウエオ123ABCアイウエオ"

    def test_sentence(self) -> None:
        """Test sentence conversion."""
        transliterator = Transliterator(mode="hira-to-kata")
        input_text = "こんにちは、世界！"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "コンニチハ、世界！"


class TestKataToHira:
    """Tests for katakana to hiragana conversion."""

    def test_basic(self) -> None:
        """Test basic katakana conversion."""
        transliterator = Transliterator(mode="kata-to-hira")
        input_text = "アイウエオ"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "あいうえお"

    def test_voiced(self) -> None:
        """Test voiced katakana conversion."""
        transliterator = Transliterator(mode="kata-to-hira")
        input_text = "ガギグゲゴ"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "がぎぐげご"

    def test_semi_voiced(self) -> None:
        """Test semi-voiced katakana conversion."""
        transliterator = Transliterator(mode="kata-to-hira")
        input_text = "パピプペポ"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ぱぴぷぺぽ"

    def test_small(self) -> None:
        """Test small katakana conversion."""
        transliterator = Transliterator(mode="kata-to-hira")
        input_text = "ァィゥェォッャュョ"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ぁぃぅぇぉっゃゅょ"

    def test_mixed(self) -> None:
        """Test mixed text conversion."""
        transliterator = Transliterator(mode="kata-to-hira")
        input_text = "アイウエオ123ABCあいうえお"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "あいうえお123ABCあいうえお"

    def test_sentence(self) -> None:
        """Test sentence conversion."""
        transliterator = Transliterator(mode="kata-to-hira")
        input_text = "コンニチハ、世界！"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "こんにちは、世界！"

    def test_vu(self) -> None:
        """Test vu character conversion."""
        transliterator = Transliterator(mode="kata-to-hira")
        input_text = "ヴ"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ゔ"

    def test_special_unchanged(self) -> None:
        """Test special katakana characters remain unchanged."""
        transliterator = Transliterator(mode="kata-to-hira")
        input_text = "ヷヸヹヺ"
        chars = build_char_list(input_text)
        result = "".join(char.c for char in transliterator(chars))
        assert result == "ヷヸヹヺ"
