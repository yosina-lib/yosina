# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

# Test basic recipe functionality
class TestBasicRecipe < Minitest::Test
  def test_empty_recipe
    recipe = Yosina::TransliterationRecipe.new
    configs = recipe.build_transliterator_configs
    assert_empty configs, 'Empty recipe should produce empty config list'
  end

  def test_default_values
    recipe = Yosina::TransliterationRecipe.new
    assert_equal false, recipe.kanji_old_new
    assert_equal false, recipe.replace_suspicious_hyphens_to_prolonged_sound_marks
    assert_equal false, recipe.replace_combined_characters
    assert_equal false, recipe.replace_circled_or_squared_characters
    assert_equal false, recipe.replace_ideographic_annotations
    assert_equal false, recipe.replace_radicals
    assert_equal false, recipe.replace_spaces
    assert_equal false, recipe.replace_hyphens
    assert_equal false, recipe.replace_mathematical_alphanumerics
    assert_equal false, recipe.combine_decomposed_hiraganas_and_katakanas
    assert_equal false, recipe.to_fullwidth
    assert_equal false, recipe.to_halfwidth
    assert_equal false, recipe.remove_ivs_svs
    assert_equal 'unijis_2004', recipe.charset
  end
end

# Test individual transliterator configurations
class TestIndividualTransliterators < Minitest::Test
  def test_kanji_old_new
    recipe = Yosina::TransliterationRecipe.new(kanji_old_new: true)
    configs = recipe.build_transliterator_configs

    # Should contain kanji-old-new and IVS/SVS configurations
    assert contains_config(configs, :kanji_old_new), 'Should contain kanji_old_new'
    assert contains_config(configs, :ivs_svs_base), 'Should contain ivs_svs_base for kanji_old_new'

    # Should have at least 3 configs: ivs-or-svs, kanji-old-new, base
    assert configs.length >= 3, 'Should have multiple configs for kanji-old-new'
  end

  def test_prolonged_sound_marks
    recipe = Yosina::TransliterationRecipe.new(replace_suspicious_hyphens_to_prolonged_sound_marks: true)
    configs = recipe.build_transliterator_configs

    assert contains_config(configs, :prolonged_sound_marks), 'Should contain prolonged_sound_marks'

    # Verify options are set correctly
    config = find_config(configs, :prolonged_sound_marks)
    refute_nil config
    assert_equal true, config[1][:replace_prolonged_marks_following_alnums]
  end

  def test_circled_or_squared
    recipe = Yosina::TransliterationRecipe.new(replace_circled_or_squared_characters: true)
    configs = recipe.build_transliterator_configs

    assert contains_config(configs, :circled_or_squared)
    config = find_config(configs, :circled_or_squared)
    refute_nil config
    assert_equal true, config[1][:include_emojis]
  end

  def test_circled_or_squared_exclude_emojis
    recipe = Yosina::TransliterationRecipe.new(replace_circled_or_squared_characters: 'exclude-emojis')
    configs = recipe.build_transliterator_configs

    assert contains_config(configs, :circled_or_squared)
    config = find_config(configs, :circled_or_squared)
    refute_nil config
    assert_equal false, config[1][:include_emojis]
  end

  def test_combined
    recipe = Yosina::TransliterationRecipe.new(replace_combined_characters: true)
    configs = recipe.build_transliterator_configs

    assert contains_config(configs, :combined)
  end

  def test_ideographic_annotations
    recipe = Yosina::TransliterationRecipe.new(replace_ideographic_annotations: true)
    configs = recipe.build_transliterator_configs
    assert contains_config(configs, :ideographic_annotations)
  end

  def test_radicals
    recipe = Yosina::TransliterationRecipe.new(replace_radicals: true)
    configs = recipe.build_transliterator_configs
    assert contains_config(configs, :radicals)
  end

  def test_spaces
    recipe = Yosina::TransliterationRecipe.new(replace_spaces: true)
    configs = recipe.build_transliterator_configs
    assert contains_config(configs, :spaces)
  end

  def test_mathematical_alphanumerics
    recipe = Yosina::TransliterationRecipe.new(replace_mathematical_alphanumerics: true)
    configs = recipe.build_transliterator_configs
    assert contains_config(configs, :mathematical_alphanumerics)
  end

  def test_hira_kata_composition
    recipe = Yosina::TransliterationRecipe.new(combine_decomposed_hiraganas_and_katakanas: true)
    configs = recipe.build_transliterator_configs

    assert contains_config(configs, :hira_kata_composition)
    config = find_config(configs, :hira_kata_composition)
    refute_nil config
    assert_equal true, config[1][:compose_non_combining_marks]
  end
end

# Test complex option configurations
class TestComplexOptions < Minitest::Test
  def test_hyphens_default_precedence
    recipe = Yosina::TransliterationRecipe.new(replace_hyphens: true)
    configs = recipe.build_transliterator_configs

    assert contains_config(configs, :hyphens)

    config = find_config(configs, :hyphens)
    refute_nil config
    expected = [:jisx0208_90_windows, :jisx0201]
    assert_equal expected, config[1][:precedence]
  end

  def test_hyphens_custom_precedence
    custom_precedence = [:jisx0201, :jisx0208_90_windows]
    recipe = Yosina::TransliterationRecipe.new(replace_hyphens: custom_precedence)
    configs = recipe.build_transliterator_configs

    config = find_config(configs, :hyphens)
    refute_nil config
    assert_equal custom_precedence, config[1][:precedence]
  end

  def test_to_fullwidth_basic
    recipe = Yosina::TransliterationRecipe.new(to_fullwidth: true)
    configs = recipe.build_transliterator_configs

    assert contains_config(configs, :jisx0201_and_alike)
    config = find_config(configs, :jisx0201_and_alike)
    refute_nil config
    assert_equal false, config[1][:fullwidth_to_halfwidth]
    assert_equal false, config[1][:u005c_as_yen_sign]
  end

  def test_to_fullwidth_yen_sign
    recipe = Yosina::TransliterationRecipe.new(to_fullwidth: 'u005c-as-yen-sign')
    configs = recipe.build_transliterator_configs

    config = find_config(configs, :jisx0201_and_alike)
    refute_nil config
    assert_equal true, config[1][:u005c_as_yen_sign]
  end

  def test_to_halfwidth_basic
    recipe = Yosina::TransliterationRecipe.new(to_halfwidth: true)
    configs = recipe.build_transliterator_configs

    config = find_config(configs, :jisx0201_and_alike)
    refute_nil config
    assert_equal true, config[1][:fullwidth_to_halfwidth]
    assert_equal true, config[1][:convert_gl]
    assert_equal false, config[1][:convert_gr]
  end

  def test_to_halfwidth_hankaku_kana
    recipe = Yosina::TransliterationRecipe.new(to_halfwidth: 'hankaku-kana')
    configs = recipe.build_transliterator_configs

    config = find_config(configs, :jisx0201_and_alike)
    refute_nil config
    assert_equal true, config[1][:convert_gr]
  end

  def test_remove_ivs_svs_basic
    recipe = Yosina::TransliterationRecipe.new(remove_ivs_svs: true)
    configs = recipe.build_transliterator_configs

    # Should have two ivs-svs-base configs
    ivs_svs_configs = configs.select { |config| config[0] == :ivs_svs_base }
    assert_equal 2, ivs_svs_configs.length

    # Check modes
    modes = ivs_svs_configs.map { |c| c[1][:mode] }
    assert_includes modes, 'ivs-or-svs'
    assert_includes modes, 'base'

    # Check drop_selectors_altogether is false for basic mode
    base_config = ivs_svs_configs.find { |c| c[1][:mode] == 'base' }
    assert_equal false, base_config[1][:drop_selectors_altogether]
  end

  def test_remove_ivs_svs_drop_all
    recipe = Yosina::TransliterationRecipe.new(remove_ivs_svs: 'drop-all-selectors')
    configs = recipe.build_transliterator_configs

    base_config = configs.find { |config| config[0] == :ivs_svs_base && config[1][:mode] == 'base' }
    refute_nil base_config
    assert_equal true, base_config[1][:drop_selectors_altogether], 'Should drop all selectors'
  end

  def test_charset_configuration
    recipe = Yosina::TransliterationRecipe.new(kanji_old_new: true, charset: 'adobe_japan1')
    configs = recipe.build_transliterator_configs

    # Find the ivs-svs-base config with mode "base" which should have charset
    base_config = configs.find { |c| c[0] == :ivs_svs_base && c[1][:mode] == 'base' }
    refute_nil base_config
    assert_equal 'adobe_japan1', base_config[1][:charset]
  end
end

# Test transliterator ordering
class TestOrderVerification < Minitest::Test
  def test_circled_or_squared_and_combined_order
    recipe = Yosina::TransliterationRecipe.new(
      replace_circled_or_squared_characters: true,
      replace_combined_characters: true
    )
    configs = recipe.build_transliterator_configs

    config_names = configs.map { |c| c[0] }
    
    # Both should be present
    assert_includes config_names, :circled_or_squared
    assert_includes config_names, :combined
    
    # In Ruby's implementation, combined comes before circled-or-squared
    # due to how insert_middle works
    circled_pos = config_names.index(:circled_or_squared)
    combined_pos = config_names.index(:combined)
    assert combined_pos < circled_pos
  end

  def test_comprehensive_ordering
    recipe = Yosina::TransliterationRecipe.new(
      kanji_old_new: true,
      replace_suspicious_hyphens_to_prolonged_sound_marks: true,
      replace_spaces: true,
      combine_decomposed_hiraganas_and_katakanas: true,
      to_halfwidth: true
    )
    configs = recipe.build_transliterator_configs

    # Find positions of key transliterators to verify ordering
    hira_kata_pos = find_config_position(configs, :hira_kata_composition)
    kanji_pos = find_config_position(configs, :kanji_old_new)
    prolonged_pos = find_config_position(configs, :prolonged_sound_marks)
    spaces_pos = find_config_position(configs, :spaces)
    jisx0201_pos = find_config_position(configs, :jisx0201_and_alike)

    # Verify some key orderings
    # hira-kata-composition should be early (head insertion)
    assert hira_kata_pos >= 0
    
    # jisx0201-and-alike should be at the end (tail insertion)
    assert_equal configs.length - 1, jisx0201_pos
    
    # All should be present
    assert spaces_pos >= 0
    assert prolonged_pos >= 0
    assert kanji_pos >= 0
  end
end

# Test mutually exclusive options
class TestMutualExclusion < Minitest::Test
  def test_fullwidth_halfwidth_mutual_exclusion
    recipe = Yosina::TransliterationRecipe.new(to_fullwidth: true, to_halfwidth: true)
    
    error = assert_raises(ArgumentError) do
      recipe.build_transliterator_configs
    end
    
    assert_includes error.message, 'mutually exclusive'
  end
end

# Test comprehensive recipe configurations
class TestComprehensiveConfiguration < Minitest::Test
  def test_all_transliterators_enabled
    recipe = Yosina::TransliterationRecipe.new(
      combine_decomposed_hiraganas_and_katakanas: true,
      kanji_old_new: true,
      remove_ivs_svs: 'drop-all-selectors',
      replace_hyphens: true,
      replace_ideographic_annotations: true,
      replace_suspicious_hyphens_to_prolonged_sound_marks: true,
      replace_radicals: true,
      replace_spaces: true,
      replace_circled_or_squared_characters: true,
      replace_combined_characters: true,
      replace_mathematical_alphanumerics: true,
      to_halfwidth: 'hankaku-kana',
      charset: 'adobe_japan1'
    )
    configs = recipe.build_transliterator_configs

    config_names = configs.map { |config| config[0] }
    
    # Verify all expected transliterators are present
    expected_transliterators = [
      :ivs_svs_base,  # appears twice
      :kanji_old_new,
      :prolonged_sound_marks,
      :circled_or_squared,
      :combined,
      :ideographic_annotations,
      :radicals,
      :spaces,
      :hyphens,
      :mathematical_alphanumerics,
      :hira_kata_composition,
      :jisx0201_and_alike
    ]
    
    expected_transliterators.each do |expected|
      assert_includes config_names, expected, "Missing transliterator: #{expected}"
    end

    # Verify specific configurations
    hyphens_config = find_config(configs, :hyphens)
    assert_equal [:jisx0208_90_windows, :jisx0201], hyphens_config[1][:precedence]
    
    jisx_config = find_config(configs, :jisx0201_and_alike)
    assert_equal true, jisx_config[1][:convert_gr]
    
    # Count ivs-svs-base occurrences
    ivs_svs_count = configs.count { |c| c[0] == :ivs_svs_base }
    assert_equal 2, ivs_svs_count
  end
end

# Test functional integration with actual transliteration
class TestFunctionalIntegration < Minitest::Test
  def test_basic_transliteration
    recipe = Yosina::TransliterationRecipe.new(
      replace_circled_or_squared_characters: true,
      replace_combined_characters: true,
      replace_spaces: true,
      replace_mathematical_alphanumerics: true
    )
    transliterator = Yosina.make_transliterator(recipe)
    
    # Test mixed content
    test_cases = [
      ["\u2460", '(1)'],  # Circled number
      ["\u2474", '(1)'],  # Parenthesized number (combined)
      ["\u{1d407}\u{1d41e}\u{1d425}\u{1d425}\u{1d428}", 'Hello'],  # Mathematical alphanumerics
      ["\u3000", ' '],  # Full-width space
    ]
    
    test_cases.each do |input_text, expected|
      result = transliterator.call(input_text)
      assert_equal expected, result, "Failed for #{input_text}: got #{result}, expected #{expected}"
    end
  end
  
  def test_exclude_emojis_functional
    recipe = Yosina::TransliterationRecipe.new(replace_circled_or_squared_characters: 'exclude-emojis')
    transliterator = Yosina.make_transliterator(recipe)
    
    # Regular circled characters should still work
    assert_equal '(1)', transliterator.call("\u2460")
    assert_equal '(A)', transliterator.call("\u24b6")
    
    # Non-emoji squared letters should still be processed
    assert_equal '[A]', transliterator.call("\u{1f170}")
    
    # Emoji characters should not be processed
    assert_equal "\u{1f198}", transliterator.call("\u{1f198}")  # Should remain unchanged
  end
end

# Shared helper module
module TestHelpers
  private

  # Helper methods
  def contains_config(configs, name)
    configs.any? { |config| config[0] == name }
  end

  def find_config(configs, name)
    configs.find { |config| config[0] == name }
  end

  def find_config_position(configs, name)
    configs.find_index { |config| config[0] == name } || -1
  end
end

# Include helpers in all test classes
class TestBasicRecipe
  include TestHelpers
end

class TestIndividualTransliterators
  include TestHelpers
end

class TestComplexOptions
  include TestHelpers
end

class TestOrderVerification
  include TestHelpers
end

class TestMutualExclusion
  include TestHelpers
end

class TestComprehensiveConfiguration
  include TestHelpers
end

class TestFunctionalIntegration
  include TestHelpers
end