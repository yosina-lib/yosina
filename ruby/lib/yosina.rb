# frozen_string_literal: true

require_relative 'yosina/version'
require_relative 'yosina/char'
require_relative 'yosina/transliterator'
require_relative 'yosina/chars'
require_relative 'yosina/recipes'
require_relative 'yosina/transliterators'

# Main module for Yosina text transliteration library
module Yosina
  class Error < StandardError; end
  class TransliteratorFactoryError < Error; end
  class TransliterationError < Error; end

  # Frontend convenience function to create a string-to-string transliterator
  # from a recipe or a list of configs.
  #
  # @param configs_or_recipe [Array<TransliteratorConfig>, Array<String>, TransliterationRecipe]
  #   A recipe or a list of transliterator configs/names
  # @return [Proc] A transliterator function that takes a string and returns a string
  def self.make_transliterator(configs_or_recipe)
    configs = case configs_or_recipe
              when TransliterationRecipe
                configs_or_recipe.build_transliterator_configs.map do |config_array|
                  TransliteratorConfig.new(config_array[0], config_array[1])
                end
              when Array
                configs_or_recipe.map do |item|
                  case item
                  when String, Symbol
                    TransliteratorConfig.new(item)
                  when Array
                    TransliteratorConfig.new(item[0], item[1])
                  else
                    item
                  end
                end
              else
                raise ArgumentError, 'configs_or_recipe must be Array or TransliterationRecipe'
              end

    transliterator = create_chained_transliterator(configs)

    proc do |input|
      chars = Chars.build_char_array(input)
      result_chars = transliterator.call(chars)
      result_chars.to_s
    end
  end

  private_class_method def self.create_chained_transliterator(configs)
    transliterators = configs.map do |config|
      factory = Transliterators.get_factory(config.name)
      raise TransliteratorFactoryError, "Unknown transliterator: #{config.name}" unless factory

      factory.call(config.options || {})
    end

    ChainedTransliterator.new(transliterators)
  end
end
