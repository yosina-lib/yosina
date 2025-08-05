# frozen_string_literal: true

# Main module for Yosina text transliteration library
module Yosina
  # Internal builder for creating lists of transliterator configurations
  class TransliteratorConfigListBuilder
    attr_reader :head, :tail

    def initialize(head: [], tail: [])
      @head = head.dup
      @tail = tail.dup
    end

    # Insert config at the head of the chain
    def insert_head(config, force_replace: false)
      idx = @head.find_index { |c| c[0] == config[0] }
      if idx
        @head[idx] = config if force_replace
      else
        @head.unshift(config)
      end
      self
    end

    # Insert config in the middle (tail list, at beginning)
    def insert_middle(config, force_replace: false)
      idx = @tail.find_index { |c| c[0] == config[0] }
      if idx
        @tail[idx] = config if force_replace
      else
        @tail.unshift(config)
      end
      self
    end

    # Insert config at the tail of the chain
    def insert_tail(config, force_replace: false)
      idx = @tail.find_index { |c| c[0] == config[0] }
      if idx
        @tail[idx] = config if force_replace
      else
        @tail.push(config)
      end
      self
    end

    # Build the final configuration list
    def build
      @head + @tail
    end
  end

  # Configuration recipe for building transliterator chains
  class TransliterationRecipe
    attr_accessor :kanji_old_new, :hira_kata, :replace_japanese_iteration_marks,
                  :replace_suspicious_hyphens_to_prolonged_sound_marks,
                  :replace_combined_characters, :replace_circled_or_squared_characters,
                  :replace_ideographic_annotations, :replace_radicals, :replace_spaces,
                  :replace_hyphens, :replace_mathematical_alphanumerics,
                  :combine_decomposed_hiraganas_and_katakanas, :to_fullwidth, :to_halfwidth,
                  :remove_ivs_svs, :charset

    # Initialize a new transliterator recipe
    #
    # @param kanji_old_new [Boolean] Replace old-style kanji glyphs with modern equivalents
    #   @example
    #     # Input:  "舊字體の變換"
    #     # Output: "旧字体の変換"
    # @param hira_kata [String, nil] Convert between hiragana and katakana scripts
    #   @example
    #     # Input:  "ひらがな" (with 'hira-to-kata')
    #     # Output: "ヒラガナ"
    #     # Input:  "カタカナ" (with 'kata-to-hira')
    #     # Output: "かたかな"
    # @param replace_japanese_iteration_marks [Boolean] Replace Japanese iteration marks with the characters
    #     they represent
    #   @example
    #     # Input:  "時々"
    #     # Output: "時時"
    #     # Input:  "いすゞ"
    #     # Output: "いすず"
    # @param replace_suspicious_hyphens_to_prolonged_sound_marks [Boolean] Replace suspicious hyphens with prolonged
    #     sound marks
    #   @example
    #     # Input:  "スーパ-" (with hyphen-minus)
    #     # Output: "スーパー" (becomes prolonged sound mark)
    # @param replace_combined_characters [Boolean] Replace combined characters with their corresponding characters
    #   @example
    #     # Input:  "㍻" (single character for Heisei era)
    #     # Output: "平成"
    #     # Input:  "㈱"
    #     # Output: "(株)"
    # @param replace_circled_or_squared_characters [Boolean, String] Replace circled or squared characters with
    #     templates
    #   @example
    #     # Input:  "①②③"
    #     # Output: "(1)(2)(3)"
    #     # Input:  "㊙㊗"
    #     # Output: "(秘)(祝)"
    # @param replace_ideographic_annotations [Boolean] Replace ideographic annotations
    #   @example
    #     # Input:  "㆖㆘" (ideographic annotations)
    #     # Output: "上下"
    # @param replace_radicals [Boolean] Replace Kangxi radicals with CJK ideographs
    #   @example
    #     # Input:  "⾔⾨⾷" (Kangxi radicals)
    #     # Output: "言門食" (CJK ideographs)
    # @param replace_spaces [Boolean] Replace various space characters
    #   @example
    #     # Input:  "A　B" (ideographic space U+3000)
    #     # Output: "A B" (half-width space)
    #     # Input:  "A B" (non-breaking space U+00A0)
    #     # Output: "A B" (regular space)
    # @param replace_hyphens [Boolean, Array<String>] Replace various dash/hyphen symbols
    #   @example
    #     # Input:  "2019—2020" (em dash)
    #     # Output: "2019-2020" (hyphen-minus)
    #     # Input:  "A–B" (en dash)
    #     # Output: "A-B"
    # @param replace_mathematical_alphanumerics [Boolean] Replace mathematical alphanumerics
    #   @example
    #     # Input:  "𝐀𝐁𝐂" (mathematical bold)
    #     # Output: "ABC"
    #     # Input:  "𝟏𝟐𝟑" (mathematical bold digits)
    #     # Output: "123"
    # @param combine_decomposed_hiraganas_and_katakanas [Boolean] Combine decomposed hiraganas/katakanas
    #   @example
    #     # Input:  "が" (か + ゙)
    #     # Output: "が" (single character)
    #     # Input:  "ヘ゜" (ヘ + ゜)
    #     # Output: "ペ" (single character)
    # @param to_fullwidth [Boolean, String] Replace half-width with fullwidth characters
    #   @example
    #     # Input:  "ABC123"
    #     # Output: "ＡＢＣ１２３"
    #     # Input:  "ｶﾀｶﾅ"
    #     # Output: "カタカナ"
    # @param to_halfwidth [Boolean, String] Replace full-width with half-width characters
    #   @example
    #     # Input:  "ＡＢＣ１２３"
    #     # Output: "ABC123"
    #     # Input:  "カタカナ" (with hankaku-kana)
    #     # Output: "ｶﾀｶﾅ"
    # @param remove_ivs_svs [Boolean, String] Remove IVS/SVS selectors
    #   @example
    #     # Input:  "葛󠄀" (葛 + IVS U+E0100)
    #     # Output: "葛" (without selector)
    #     # Input:  "辻󠄀" (辻 + IVS)
    #     # Output: "辻"
    # @param charset [String] Charset for IVS/SVS transliteration
    # rubocop:disable Metrics/ParameterLists
    def initialize(kanji_old_new: false, hira_kata: nil, replace_japanese_iteration_marks: false,
                   replace_suspicious_hyphens_to_prolonged_sound_marks: false,
                   replace_combined_characters: false, replace_circled_or_squared_characters: false,
                   replace_ideographic_annotations: false, replace_radicals: false,
                   replace_spaces: false, replace_hyphens: false,
                   replace_mathematical_alphanumerics: false,
                   combine_decomposed_hiraganas_and_katakanas: false,
                   to_fullwidth: false, to_halfwidth: false, remove_ivs_svs: false,
                   charset: 'unijis_2004')
      @kanji_old_new = kanji_old_new
      @hira_kata = hira_kata
      @replace_japanese_iteration_marks = replace_japanese_iteration_marks
      @replace_suspicious_hyphens_to_prolonged_sound_marks = replace_suspicious_hyphens_to_prolonged_sound_marks
      @replace_combined_characters = replace_combined_characters
      @replace_circled_or_squared_characters = replace_circled_or_squared_characters
      @replace_ideographic_annotations = replace_ideographic_annotations
      @replace_radicals = replace_radicals
      @replace_spaces = replace_spaces
      @replace_hyphens = replace_hyphens
      @replace_mathematical_alphanumerics = replace_mathematical_alphanumerics
      @combine_decomposed_hiraganas_and_katakanas = combine_decomposed_hiraganas_and_katakanas
      @to_fullwidth = to_fullwidth
      @to_halfwidth = to_halfwidth
      @remove_ivs_svs = remove_ivs_svs
      @charset = charset
    end
    # rubocop:enable Metrics/ParameterLists

    # Build transliterator configurations from this recipe
    #
    # @return [Array<Array>] Array of transliterator configurations
    # @raise [ArgumentError] If the recipe contains mutually exclusive options
    def build_transliterator_configs
      # Check for mutually exclusive options
      errors = []
      errors << 'to_fullwidth and to_halfwidth are mutually exclusive' if to_fullwidth && to_halfwidth

      raise ArgumentError, errors.join('; ') unless errors.empty?

      ctx = TransliteratorConfigListBuilder.new

      # Apply transformations in the specified order
      ctx = apply_kanji_old_new(ctx)
      ctx = apply_replace_suspicious_hyphens_to_prolonged_sound_marks(ctx)
      ctx = apply_replace_circled_or_squared_characters(ctx)
      ctx = apply_replace_combined_characters(ctx)
      ctx = apply_replace_ideographic_annotations(ctx)
      ctx = apply_replace_radicals(ctx)
      ctx = apply_replace_spaces(ctx)
      ctx = apply_replace_hyphens(ctx)
      ctx = apply_replace_mathematical_alphanumerics(ctx)
      ctx = apply_combine_decomposed_hiraganas_and_katakanas(ctx)
      ctx = apply_to_fullwidth(ctx)
      ctx = apply_hira_kata(ctx)
      ctx = apply_replace_japanese_iteration_marks(ctx)
      ctx = apply_to_halfwidth(ctx)
      ctx = apply_remove_ivs_svs(ctx)

      ctx.build
    end

    private

    def remove_ivs_svs_helper(ctx, drop_all_selectors)
      # First insert IVS-or-SVS mode at head
      ctx = ctx.insert_head([:ivs_svs_base, { mode: 'ivs-or-svs', charset: @charset }], force_replace: true)
      # Then insert base mode at tail
      ctx.insert_tail(
        [:ivs_svs_base,
         { mode: 'base', drop_selectors_altogether: drop_all_selectors, charset: @charset }], force_replace: true
      )
    end

    def apply_kanji_old_new(ctx)
      if @kanji_old_new
        ctx = remove_ivs_svs_helper(ctx, false)
        ctx.insert_middle([:kanji_old_new, {}])
      else
        ctx
      end
    end

    def apply_hira_kata(ctx)
      if @hira_kata
        ctx.insert_middle([:hira_kata, { mode: @hira_kata }])
      else
        ctx
      end
    end

    def apply_replace_japanese_iteration_marks(ctx)
      if @replace_japanese_iteration_marks
        # Insert HiraKataComposition at head to ensure composed forms
        ctx = ctx.insert_head([:hira_kata_composition, { compose_non_combining_marks: true }])
        # Then insert the japanese-iteration-marks in the middle
        ctx.insert_middle([:japanese_iteration_marks, {}])
      else
        ctx
      end
    end

    def apply_replace_suspicious_hyphens_to_prolonged_sound_marks(ctx)
      if @replace_suspicious_hyphens_to_prolonged_sound_marks
        ctx.insert_middle([:prolonged_sound_marks, { replace_prolonged_marks_following_alnums: true }])
      else
        ctx
      end
    end

    def apply_replace_combined_characters(ctx)
      ctx.insert_middle([:combined, {}]) if @replace_combined_characters
      ctx
    end

    def apply_replace_circled_or_squared_characters(ctx)
      if @replace_circled_or_squared_characters
        include_emojis = @replace_circled_or_squared_characters != 'exclude-emojis'
        ctx.insert_middle([:circled_or_squared, { include_emojis: include_emojis }])
      else
        ctx
      end
    end

    def apply_replace_ideographic_annotations(ctx)
      if @replace_ideographic_annotations
        ctx.insert_middle([:ideographic_annotations, {}])
      else
        ctx
      end
    end

    def apply_replace_radicals(ctx)
      if @replace_radicals
        ctx.insert_middle([:radicals, {}])
      else
        ctx
      end
    end

    def apply_replace_spaces(ctx)
      if @replace_spaces
        ctx.insert_middle([:spaces, {}])
      else
        ctx
      end
    end

    def apply_replace_hyphens(ctx)
      if @replace_hyphens
        precedence = @replace_hyphens.is_a?(Array) ? @replace_hyphens : %i[jisx0208_90_windows jisx0201]
        ctx.insert_middle([:hyphens, { precedence: precedence }])
      else
        ctx
      end
    end

    def apply_replace_mathematical_alphanumerics(ctx)
      if @replace_mathematical_alphanumerics
        ctx.insert_middle([:mathematical_alphanumerics, {}])
      else
        ctx
      end
    end

    def apply_combine_decomposed_hiraganas_and_katakanas(ctx)
      if @combine_decomposed_hiraganas_and_katakanas
        ctx.insert_head([:hira_kata_composition, { compose_non_combining_marks: true }])
      else
        ctx
      end
    end

    def apply_to_fullwidth(ctx)
      if @to_fullwidth
        u005c_as_yen_sign = @to_fullwidth == 'u005c-as-yen-sign'
        ctx.insert_tail([:jisx0201_and_alike, { fullwidth_to_halfwidth: false, u005c_as_yen_sign: u005c_as_yen_sign }])
      end
      ctx
    end

    def apply_to_halfwidth(ctx)
      if @to_halfwidth
        convert_gr = @to_halfwidth == 'hankaku-kana'
        ctx.insert_tail([:jisx0201_and_alike,
                         { fullwidth_to_halfwidth: true, convert_gl: true, convert_gr: convert_gr }])
      else
        ctx
      end
    end

    def apply_remove_ivs_svs(ctx)
      if @remove_ivs_svs
        drop_all_selectors = @remove_ivs_svs == 'drop-all-selectors'
        remove_ivs_svs_helper(ctx, drop_all_selectors)
      else
        ctx
      end
    end
  end

  # Build an array of transliterator configs from a recipe object
  #
  # @param recipe [TransliterationRecipe] A TransliterationRecipe object
  # @return [Array<Array>] Array of transliterator configurations
  def self.build_transliterator_configs_from_recipe(recipe)
    recipe.build_transliterator_configs
  end
end
