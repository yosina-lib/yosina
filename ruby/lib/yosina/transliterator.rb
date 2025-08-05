# frozen_string_literal: true

module Yosina
  # Configuration for a transliterator
  class TransliteratorConfig
    attr_accessor :name, :options

    # Initialize a new transliterator configuration
    #
    # @param name [String, Symbol] The name of the transliterator
    # @param options [Hash, nil] Configuration options for the transliterator
    def initialize(name, options = nil)
      @name = name
      @options = options
    end
  end

  # Base class for all transliterators
  class BaseTransliterator
    # Transliterate an array of characters
    #
    # @param input_chars [Enumerable<Char>] The characters to transliterate
    # @return [Enumerable<Char>] The transliterated characters
    def call(input_chars)
      raise NotImplementedError, 'Subclasses must implement call method'
    end
  end

  # Chains multiple transliterators together
  class ChainedTransliterator < BaseTransliterator
    # Initialize a chained transliterator
    #
    # @param transliterators [Array<BaseTransliterator>] The transliterators to chain
    def initialize(transliterators)
      super()
      @transliterators = transliterators
    end

    # Apply all transliterators in sequence
    #
    # @param input_chars [Enumerable<Char>] The characters to transliterate
    # @return [Enumerable<Char>] The transliterated characters
    def call(input_chars)
      @transliterators.reduce(input_chars) do |chars, transliterator|
        transliterator.call(chars)
      end
    end
  end
end
