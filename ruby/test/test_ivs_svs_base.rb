# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/yosina'

class TestIvsSvsBase < Minitest::Test
  # Test constants for variation selectors
  VS1 = "\u{fe00}"
  VS16 = "\u{fe0f}"
  VS17 = "\u{e0100}"
  VS18 = "\u{e0101}"
  VS256 = "\u{e01ef}"

  # Test characters
  KUZU = "\u{845b}"  # 葛
  TSUJI = "\u{8fbb}"  # 辻
  KATSU = "\u{559d}"   # 喝
  KATSU_CJK_COMPAT = "\u{fa36}" # 喝 (CJK Compatibility char)

  # Base mode tests (IVS/SVS -> base)
  def test_ivs_to_base_character_unijis2004
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                charset: 'unijis_2004'
                                                              })

    input_str = KUZU + VS17
    expected = KUZU + VS17 # Should keep unmapped selector in unijis2004

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "IVS to base (unijis2004) - should keep unmapped selector"
  end

  def test_svs_to_base_character_unijis2004
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                charset: 'unijis_2004'
                                                              })

    input_str = KUZU + VS1
    expected = KUZU + VS1 # Should keep unmapped selector in unijis2004

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "SVS to base (unijis2004) - should keep unmapped selector"
  end

  def test_ivs_to_base_character_unijis90
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                charset: 'unijis_90'
                                                              })

    input_str = KUZU + VS17
    expected = KUZU # Should remove mapped selector in unijis90

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "IVS to base (unijis90) - should remove mapped selector"
  end

  def test_svs_to_base_character_unijis90
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                charset: 'unijis_90'
                                                              })

    input_str = KATSU + VS18
    expected = KATSU_CJK_COMPAT # Should map to compatibility character

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "SVS to base (unijis90) - should map to compatibility character"
  end

  def test_drop_variation_selector_altogether
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                drop_selectors_altogether: true,
                                                                charset: 'unijis_2004'
                                                              })

    input_str = KUZU + VS17
    expected = KUZU # Should drop all selectors

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Should drop all variation selectors when drop_selectors_altogether is true"
  end

  def test_unknown_variation_selector_drop_if_flag_set
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                drop_selectors_altogether: true,
                                                                charset: 'unijis_2004'
                                                              })

    input_str = "A" + VS16 # A + VS16 (unknown combination)
    expected = "A" # Should drop unknown selector

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Should drop unknown variation selector when drop_selectors_altogether is true"
  end

  def test_unknown_variation_selector_keep_if_flag_not_set
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                drop_selectors_altogether: false,
                                                                charset: 'unijis_2004'
                                                              })

    input_str = "A" + VS16 # A + VS16 (unknown combination)
    expected = "A" + VS16 # Should keep unknown selector

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Should keep unknown variation selector when drop_selectors_altogether is false"
  end

  # IvsOrSvs mode tests (base -> IVS/SVS)
  def test_base_to_ivs_unijis2004
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'ivs-or-svs',
                                                                charset: 'unijis_2004',
                                                                prefer_svs: false
                                                              })

    input_str = KATSU_CJK_COMPAT
    expected = KATSU + VS18 # Should map to IVS

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Base to IVS (unijis2004) - should add VS18 to 喝"
  end

  def test_base_to_svs_unijis2004_with_prefer_svs
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'ivs-or-svs',
                                                                charset: 'unijis_2004',
                                                                prefer_svs: true
                                                              })

    input_str = KATSU_CJK_COMPAT
    expected = KATSU + VS1 # Should prefer SVS over IVS

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Base to SVS (unijis2004) - should prefer SVS when prefer_svs is true"
  end

  def test_base_to_ivs_unijis90
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'ivs-or-svs',
                                                                charset: 'unijis_90',
                                                                prefer_svs: false
                                                              })

    input_str = KATSU_CJK_COMPAT
    expected = KATSU + VS18 # Should map to IVS

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Base to IVS (unijis90) - should add VS18 to 喝"
  end

  def test_base_to_svs_unijis90_with_prefer_svs
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'ivs-or-svs',
                                                                charset: 'unijis_90',
                                                                prefer_svs: true
                                                              })

    input_str = KATSU_CJK_COMPAT
    expected = KATSU + VS1 # Should prefer SVS

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Base to SVS (unijis90) - should prefer SVS when prefer_svs is true"
  end

  # Edge cases
  def test_empty_string
    transliterator = Yosina::Transliterators::IvsSvsBase.call

    input_str = ""
    expected = ""

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Empty string should remain empty"
  end

  def test_string_with_no_ivs_svs_characters
    transliterator = Yosina::Transliterators::IvsSvsBase.call

    input_str = "Hello, World!"
    expected = "Hello, World!"

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "String without IVS/SVS should remain unchanged"
  end

  def test_mixed_content_with_ivs
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                charset: 'unijis_90'
                                                              })

    input_str = "Text " + KUZU + VS17 + " more text"
    expected = "Text " + KUZU + " more text"

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Mixed content should only transform IVS/SVS parts"
  end

  def test_multiple_variation_selectors
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                charset: 'unijis_2004'
                                                              })

    input_str = KUZU + VS18 + TSUJI + VS18
    expected = KUZU + TSUJI # Both should be processed

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Multiple variation selectors should be processed"
  end

  def test_variation_selector_at_start_of_string
    transliterator = Yosina::Transliterators::IvsSvsBase.call

    input_str = VS1 + "text"
    expected = VS1 + "text"  # Standalone VS should not be affected

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Standalone variation selector should not be affected"
  end

  def test_consecutive_variation_selectors
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                charset: 'unijis_2004'
                                                              })

    input_str = KUZU + VS18 + VS1
    expected = KUZU + VS1  # Only first VS should be processed with base char

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Only first variation selector should be processed with base character"
  end

  # Default options test
  def test_default_options
    transliterator = Yosina::Transliterators::IvsSvsBase.call

    # Should default to base mode, unijis_2004 charset, not drop_selectors_altogether
    assert_equal 'base', transliterator.mode
    assert_equal 'unijis_2004', transliterator.charset
    assert_equal false, transliterator.drop_selectors_altogether
    assert_equal false, transliterator.prefer_svs
  end

  # Variation selector ranges test
  def test_variation_selector_ranges
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                drop_selectors_altogether: true,
                                                                charset: 'unijis_2004'
                                                              })

    test_cases = [
      ["A" + VS1, "A"],      # VS1 (U+FE00)
      ["A" + VS16, "A"],     # VS16 (U+FE0F)
      ["A" + VS17, "A"],     # IVS VS17 (U+E0100)
      ["A" + VS256, "A"],    # IVS VS256 (U+E01EF)
      ["AB", "AB"],          # Non-VS character after base
      ["A\uFDFF", "A\uFDFF"], # Character just before VS range
      ["A\uFE10", "A\uFE10"], # Character just after VS range
    ]

    test_cases.each do |input, expected|
      chars = Yosina::Chars.build_char_array(input)
      result_chars = transliterator.call(chars)
      result = result_chars.to_s

      assert_equal expected, result, "Variation selector range test failed for: #{input.inspect}"
    end
  end

  # Unicode normalization tests
  def test_precomposed_character_with_vs
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                drop_selectors_altogether: true,
                                                                charset: 'unijis_2004'
                                                              })

    input_str = "é" + VS1  # é (U+00E9) + VS1
    expected = "é"

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Precomposed character with VS should drop VS"
  end

  def test_surrogate_pair_handling
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                drop_selectors_altogether: true,
                                                                charset: 'unijis_2004'
                                                              })

    input_str = "𠮷" + VS1  # 𠮷 (U+20BB7) + VS1
    expected = "𠮷"

    chars = Yosina::Chars.build_char_array(input_str)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    assert_equal expected, result, "Surrogate pair with VS should drop VS"
  end

  # Performance test with large input
  def test_performance_with_large_input
    transliterator = Yosina::Transliterators::IvsSvsBase.call

    # Create large input with various IVS/SVS characters
    large_input = ("Text " + KUZU + VS18 + " and " + TSUJI + VS18 + " mixed ") * 100

    chars = Yosina::Chars.build_char_array(large_input)
    result_chars = transliterator.call(chars)
    result = result_chars.to_s

    refute_empty result, "Expected non-empty result for large input"
    assert_includes result, KUZU, "Should contain base characters"
    refute_includes result, VS18, "Should not contain IVS in base mode"
  end

  # Test chaining with other transliterators
  def test_combination_with_kanji_old_new
    # This test would require KanjiOldNew implementation to work properly
    # For now, just test that the chain doesn't break
    ivs_add = Yosina::Transliterators::IvsSvsBase.call({ mode: 'ivs-or-svs' })
    ivs_remove = Yosina::Transliterators::IvsSvsBase.call({ mode: 'base' })

    input_str = "test"

    # Chain the transliterators
    chars = Yosina::Chars.build_char_array(input_str)
    step1_chars = ivs_add.call(chars)
    result_chars = ivs_remove.call(step1_chars)
    result = result_chars.to_s

    assert_equal input_str, result, "Chained transliterators should work on simple text"
  end

  # Test that transliterator instances have expected interface
  def test_transliterator_interface
    transliterator = Yosina::Transliterators::IvsSvsBase.call({
                                                                mode: 'base',
                                                                drop_selectors_altogether: true,
                                                                charset: 'unijis_90',
                                                                prefer_svs: true
                                                              })

    assert_respond_to transliterator, :call
    assert_respond_to transliterator, :mode
    assert_respond_to transliterator, :drop_selectors_altogether
    assert_respond_to transliterator, :charset
    assert_respond_to transliterator, :prefer_svs

    assert_equal 'base', transliterator.mode
    assert_equal true, transliterator.drop_selectors_altogether
    assert_equal 'unijis_90', transliterator.charset
    assert_equal true, transliterator.prefer_svs
  end
end
