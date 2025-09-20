# frozen_string_literal: true

require_relative 'transliterators/spaces'
require_relative 'transliterators/kanji_old_new'
require_relative 'transliterators/radicals'
require_relative 'transliterators/roman_numerals'
require_relative 'transliterators/ideographic_annotations'
require_relative 'transliterators/mathematical_alphanumerics'
require_relative 'transliterators/prolonged_sound_marks'
require_relative 'transliterators/hyphens'
require_relative 'transliterators/hira_kata'
require_relative 'transliterators/hira_kata_composition'
require_relative 'transliterators/ivs_svs_base'
require_relative 'transliterators/jisx0201_and_alike'
require_relative 'transliterators/circled_or_squared'
require_relative 'transliterators/combined'
require_relative 'transliterators/japanese_iteration_marks'

module Yosina
  # Registry for transliterator factories
  module Transliterators
    FACTORIES = {
      spaces: Transliterators::Spaces,
      kanji_old_new: Transliterators::KanjiOldNew,
      radicals: Transliterators::Radicals,
      roman_numerals: Transliterators::RomanNumerals,
      ideographic_annotations: Transliterators::IdeographicAnnotations,
      mathematical_alphanumerics: Transliterators::MathematicalAlphanumerics,
      prolonged_sound_marks: Transliterators::ProlongedSoundMarks,
      hyphens: Transliterators::Hyphens,
      hira_kata: Transliterators::HiraKata,
      hira_kata_composition: Transliterators::HiraKataComposition,
      ivs_svs_base: Transliterators::IvsSvsBase,
      jisx0201_and_alike: Transliterators::Jisx0201AndAlike,
      combined: Transliterators::Combined,
      circled_or_squared: CircledOrSquared,
      japanese_iteration_marks: Transliterators::JapaneseIterationMarks
    }.freeze

    # Get a transliterator factory by name
    #
    # @param name [String, Symbol] The name of the transliterator
    # @return [Module, nil] The transliterator factory module or nil if not found
    def self.get_factory(name)
      if name.is_a?(String)
        # Convert string to symbol format (e.g. 'kanji-old-new' -> :kanji_old_new)
        name = name.gsub('-', '_').to_sym
      end
      FACTORIES[name]
    end

    # List all available transliterator names
    #
    # @return [Array<Symbol>] Array of available transliterator names
    def self.available_transliterators
      FACTORIES.keys
    end
  end
end
