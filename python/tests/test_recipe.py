"""Tests for transliterator recipe functionality."""

import pytest

from yosina import make_transliterator
from yosina.recipes import Mapping, TransliterationRecipe, build_transliterator_configs_from_recipe


class TestBasicRecipe:
    """Test basic recipe functionality."""

    def test_empty_recipe(self):
        """Test that empty recipe creates no transliterators."""
        recipe = TransliterationRecipe()
        configs = build_transliterator_configs_from_recipe(recipe)
        assert len(configs) == 0

    def test_default_values(self):
        """Test default values for all recipe fields."""
        recipe = TransliterationRecipe()
        assert recipe.kanji_old_new is False
        assert recipe.replace_suspicious_hyphens_to_prolonged_sound_marks is False
        assert recipe.replace_combined_characters is False
        assert recipe.replace_circled_or_squared_characters is False
        assert recipe.replace_ideographic_annotations is False
        assert recipe.replace_radicals is False
        assert recipe.replace_spaces is False
        assert recipe.replace_hyphens is False
        assert recipe.replace_mathematical_alphanumerics is False
        assert recipe.replace_roman_numerals is False
        assert recipe.combine_decomposed_hiraganas_and_katakanas is False
        assert recipe.to_fullwidth is False
        assert recipe.to_halfwidth is False
        assert recipe.remove_ivs_svs is False
        assert recipe.charset == "unijis_2004"


class TestIndividualTransliterators:
    """Test individual transliterator configurations."""

    def test_kanji_old_new(self):
        """Test kanji_old_new configuration with IVS/SVS."""
        recipe = TransliterationRecipe(kanji_old_new=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        # Should contain kanji-old-new and IVS/SVS configurations
        config_names = [c[0] for c in configs]
        assert "kanji-old-new" in config_names
        assert "ivs-svs-base" in config_names

        # Should have at least 3 configs: ivs-or-svs, kanji-old-new, base
        assert len(configs) >= 3

    def test_prolonged_sound_marks(self):
        """Test replace_suspicious_hyphens_to_prolonged_sound_marks configuration."""
        recipe = TransliterationRecipe(replace_suspicious_hyphens_to_prolonged_sound_marks=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config = next((c for c in configs if c[0] == "prolonged-sound-marks"), None)
        assert config is not None
        assert config[1]["replace_prolonged_marks_following_alnums"] is True

    def test_circled_or_squared(self):
        """Test replace_circled_or_squared_characters configuration."""
        recipe = TransliterationRecipe(replace_circled_or_squared_characters=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config = next((c for c in configs if c[0] == "circled-or-squared"), None)
        assert config is not None
        assert config[1]["include_emojis"] is True

    def test_circled_or_squared_exclude_emojis(self):
        """Test replace_circled_or_squared_characters with exclude-emojis option."""
        recipe = TransliterationRecipe(replace_circled_or_squared_characters="exclude-emojis")
        configs = build_transliterator_configs_from_recipe(recipe)

        config = next((c for c in configs if c[0] == "circled-or-squared"), None)
        assert config is not None
        assert config[1]["include_emojis"] is False

    def test_combined(self):
        """Test replace_combined_characters configuration."""
        recipe = TransliterationRecipe(replace_combined_characters=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config_names = [c[0] for c in configs]
        assert "combined" in config_names

    def test_ideographic_annotations(self):
        """Test replace_ideographic_annotations configuration."""
        recipe = TransliterationRecipe(replace_ideographic_annotations=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config_names = [c[0] for c in configs]
        assert "ideographic-annotations" in config_names

    def test_radicals(self):
        """Test replace_radicals configuration."""
        recipe = TransliterationRecipe(replace_radicals=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config_names = [c[0] for c in configs]
        assert "radicals" in config_names

    def test_spaces(self):
        """Test replace_spaces configuration."""
        recipe = TransliterationRecipe(replace_spaces=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config_names = [c[0] for c in configs]
        assert "spaces" in config_names

    def test_mathematical_alphanumerics(self):
        """Test replace_mathematical_alphanumerics configuration."""
        recipe = TransliterationRecipe(replace_mathematical_alphanumerics=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config_names = [c[0] for c in configs]
        assert "mathematical-alphanumerics" in config_names

    def test_roman_numerals(self):
        """Test replace_roman_numerals configuration."""
        recipe = TransliterationRecipe(replace_roman_numerals=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config_names = [c[0] for c in configs]
        assert "roman-numerals" in config_names

    def test_hira_kata_composition(self):
        """Test combine_decomposed_hiraganas_and_katakanas configuration."""
        recipe = TransliterationRecipe(combine_decomposed_hiraganas_and_katakanas=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config = next((c for c in configs if c[0] == "hira-kata-composition"), None)
        assert config is not None
        assert config[1]["compose_non_combining_marks"] is True


class TestComplexOptions:
    """Test complex option configurations."""

    def test_hyphens_default_precedence(self):
        """Test replace_hyphens with default precedence."""
        recipe = TransliterationRecipe(replace_hyphens=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config = next((c for c in configs if c[0] == "hyphens"), None)
        assert config is not None
        assert config[1]["precedence"] == ["jisx0208_90_windows", "jisx0201"]

    def test_hyphens_custom_precedence(self):
        """Test replace_hyphens with custom precedence."""
        custom_precedence: list[Mapping] = ["jisx0201", "jisx0208_90_windows"]
        recipe = TransliterationRecipe(replace_hyphens=custom_precedence)
        configs = build_transliterator_configs_from_recipe(recipe)

        config = next((c for c in configs if c[0] == "hyphens"), None)
        assert config is not None
        assert config[1]["precedence"] == custom_precedence

    def test_to_fullwidth_basic(self):
        """Test to_fullwidth basic configuration."""
        recipe = TransliterationRecipe(to_fullwidth=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config = next((c for c in configs if c[0] == "jisx0201-and-alike"), None)
        assert config is not None
        assert config[1]["fullwidth_to_halfwidth"] is False
        assert config[1]["u005c_as_yen_sign"] is False

    def test_to_fullwidth_yen_sign(self):
        """Test to_fullwidth with u005c-as-yen-sign option."""
        recipe = TransliterationRecipe(to_fullwidth="u005c-as-yen-sign")
        configs = build_transliterator_configs_from_recipe(recipe)

        config = next((c for c in configs if c[0] == "jisx0201-and-alike"), None)
        assert config is not None
        assert config[1]["fullwidth_to_halfwidth"] is False
        assert config[1]["u005c_as_yen_sign"] is True

    def test_to_halfwidth_basic(self):
        """Test to_halfwidth basic configuration."""
        recipe = TransliterationRecipe(to_halfwidth=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config = next((c for c in configs if c[0] == "jisx0201-and-alike"), None)
        assert config is not None
        assert config[1]["fullwidth_to_halfwidth"] is True
        assert config[1]["convert_gl"] is True
        assert config[1]["convert_gr"] is False

    def test_to_halfwidth_hankaku_kana(self):
        """Test to_halfwidth with hankaku-kana option."""
        recipe = TransliterationRecipe(to_halfwidth="hankaku-kana")
        configs = build_transliterator_configs_from_recipe(recipe)

        config = next((c for c in configs if c[0] == "jisx0201-and-alike"), None)
        assert config is not None
        assert config[1]["fullwidth_to_halfwidth"] is True
        assert config[1]["convert_gl"] is True
        assert config[1]["convert_gr"] is True

    def test_remove_ivs_svs_basic(self):
        """Test remove_ivs_svs basic configuration."""
        recipe = TransliterationRecipe(remove_ivs_svs=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        # Should have two ivs-svs-base configs
        ivs_svs_configs = [c for c in configs if c[0] == "ivs-svs-base"]
        assert len(ivs_svs_configs) == 2

        # Check modes
        modes = [c[1]["mode"] for c in ivs_svs_configs]
        assert "ivs-or-svs" in modes
        assert "base" in modes

        # Check drop_selectors_altogether is False for basic mode
        base_config = next(c for c in ivs_svs_configs if c[1]["mode"] == "base")
        assert base_config[1]["drop_selectors_altogether"] is False

    def test_remove_ivs_svs_drop_all(self):
        """Test remove_ivs_svs with drop-all-selectors option."""
        recipe = TransliterationRecipe(remove_ivs_svs="drop-all-selectors")
        configs = build_transliterator_configs_from_recipe(recipe)

        # Find base mode config
        base_config = next(c for c in configs if c[0] == "ivs-svs-base" and c[1]["mode"] == "base")
        assert base_config[1]["drop_selectors_altogether"] is True

    def test_charset_configuration(self):
        """Test charset configuration."""
        recipe = TransliterationRecipe(kanji_old_new=True, charset="adobe_japan1")
        configs = build_transliterator_configs_from_recipe(recipe)

        # Find the ivs-svs-base config with mode "base" which should have charset
        base_config = next(c for c in configs if c[0] == "ivs-svs-base" and c[1].get("mode") == "base")
        assert base_config[1]["charset"] == "adobe_japan1"


class TestOrderVerification:
    """Test transliterator ordering."""

    def test_circled_or_squared_and_combined_order(self):
        """Test the order of circled-or-squared and combined transliterators."""
        recipe = TransliterationRecipe(replace_circled_or_squared_characters=True, replace_combined_characters=True)
        configs = build_transliterator_configs_from_recipe(recipe)

        config_names = [c[0] for c in configs]

        # Both should be present
        assert "circled-or-squared" in config_names
        assert "combined" in config_names

        # The actual order in Python is combined first, then circled-or-squared
        # This is because insert_middle inserts at the beginning of the tail list
        circled_pos = config_names.index("circled-or-squared")
        combined_pos = config_names.index("combined")
        assert combined_pos < circled_pos

    def test_comprehensive_ordering(self):
        """Test comprehensive ordering with multiple transliterators."""
        recipe = TransliterationRecipe(
            kanji_old_new=True,
            replace_suspicious_hyphens_to_prolonged_sound_marks=True,
            replace_circled_or_squared_characters=True,
            replace_combined_characters=True,
            replace_spaces=True,
            combine_decomposed_hiraganas_and_katakanas=True,
            to_halfwidth=True,
        )
        configs = build_transliterator_configs_from_recipe(recipe)

        config_names = [c[0] for c in configs]

        # Verify some key orderings
        # hira-kata-composition should be early (head insertion)
        assert "hira-kata-composition" in config_names

        # jisx0201-and-alike should be at the end (tail insertion)
        assert config_names[-1] == "jisx0201-and-alike"

        # Verify circled-or-squared and combined are in the correct order
        if "circled-or-squared" in config_names and "combined" in config_names:
            circled_pos = config_names.index("circled-or-squared")
            combined_pos = config_names.index("combined")
            # In Python's implementation, combined comes before circled-or-squared
            assert combined_pos < circled_pos


class TestMutualExclusion:
    """Test mutually exclusive options."""

    def test_fullwidth_halfwidth_mutual_exclusion(self):
        """Test that to_fullwidth and to_halfwidth are mutually exclusive."""
        recipe = TransliterationRecipe(to_fullwidth=True, to_halfwidth=True)

        with pytest.raises(ValueError) as exc_info:
            build_transliterator_configs_from_recipe(recipe)

        assert "mutually exclusive" in str(exc_info.value)


class TestComprehensiveConfiguration:
    """Test comprehensive recipe configurations."""

    def test_all_transliterators_enabled(self):
        """Test recipe with all transliterators enabled."""
        recipe = TransliterationRecipe(
            kanji_old_new=True,
            replace_suspicious_hyphens_to_prolonged_sound_marks=True,
            replace_combined_characters=True,
            replace_circled_or_squared_characters=True,
            replace_ideographic_annotations=True,
            replace_radicals=True,
            replace_spaces=True,
            replace_hyphens=True,
            replace_mathematical_alphanumerics=True,
            replace_roman_numerals=True,
            combine_decomposed_hiraganas_and_katakanas=True,
            to_halfwidth="hankaku-kana",
            remove_ivs_svs="drop-all-selectors",
            charset="adobe_japan1",
        )

        configs = build_transliterator_configs_from_recipe(recipe)
        config_names = [c[0] for c in configs]

        # Verify all expected transliterators are present
        expected_transliterators = [
            "ivs-svs-base",  # appears twice
            "kanji-old-new",
            "prolonged-sound-marks",
            "circled-or-squared",
            "combined",
            "ideographic-annotations",
            "radicals",
            "spaces",
            "hyphens",
            "mathematical-alphanumerics",
            "roman-numerals",
            "hira-kata-composition",
            "jisx0201-and-alike",
        ]

        for expected in expected_transliterators:
            assert expected in config_names, f"Missing transliterator: {expected}"

        # Verify specific configurations
        hyphens_config = next(c for c in configs if c[0] == "hyphens")
        assert hyphens_config[1]["precedence"] == ["jisx0208_90_windows", "jisx0201"]

        jisx_config = next(c for c in configs if c[0] == "jisx0201-and-alike")
        assert jisx_config[1]["convert_gr"] is True

        # Count ivs-svs-base occurrences
        ivs_svs_count = sum(1 for c in configs if c[0] == "ivs-svs-base")
        assert ivs_svs_count == 2


class TestFunctionalIntegration:
    """Test functional integration with actual transliteration."""

    def test_basic_transliteration(self):
        """Test basic transliteration with recipe."""
        recipe = TransliterationRecipe(
            replace_circled_or_squared_characters=True,
            replace_combined_characters=True,
            replace_spaces=True,
            replace_mathematical_alphanumerics=True,
            replace_roman_numerals=True,
        )
        transliterator = make_transliterator(recipe)

        # Test mixed content
        test_cases = [
            ("①", "(1)"),  # Circled number
            ("⑴", "(1)"),  # Parenthesized number (combined)
            ("𝐇𝐞𝐥𝐥𝐨", "Hello"),  # Mathematical alphanumerics
            ("　", " "),  # Full-width space
            ("Ⅲ", "III"),  # Roman numeral (uppercase)
            ("ⅸ", "ix"),  # Roman numeral (lowercase)
        ]

        for input_text, expected in test_cases:
            result = transliterator(input_text)
            assert result == expected, f"Failed for {input_text}: got {result}, expected {expected}"

    def test_exclude_emojis_functional(self):
        """Test exclude-emojis functionality."""
        recipe = TransliterationRecipe(replace_circled_or_squared_characters="exclude-emojis")
        transliterator = make_transliterator(recipe)

        # Regular circled characters should still work
        assert transliterator("①") == "(1)"
        assert transliterator("Ⓐ") == "(A)"

        # Non-emoji squared letters should still be processed
        assert transliterator("🅰") == "[A]"

        # Emoji characters should not be processed
        assert transliterator("🆘") == "🆘"  # Should remain unchanged

    def test_to_fullwidth_must_come_before_hira_kata(self):
        """Test that to_fullwidth comes before hira_kata in config order."""
        recipe = TransliterationRecipe(
            to_fullwidth=True,
            hira_kata="kata-to-hira",
        )
        configs = build_transliterator_configs_from_recipe(recipe)

        assert len(configs) == 2
        assert configs[0][0] == "jisx0201-and-alike"
        assert configs[1][0] == "hira-kata"

        # Test the actual transliteration works correctly
        transliterator = make_transliterator(recipe)
        assert transliterator("ｶﾀｶﾅ") == "かたかな"
