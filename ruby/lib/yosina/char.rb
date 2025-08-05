# frozen_string_literal: true

module Yosina
  # Represents a character with metadata for transliteration
  class Char
    attr_accessor :c, :offset, :source

    # Initialize a new character
    #
    # @param c [String] The character string
    # @param offset [Integer] The offset position in the original text
    # @param source [Char, nil] Optional reference to the original character
    # rubocop:disable Naming/MethodParameterName
    def initialize(c:, offset:, source: nil)
      @c = c
      @offset = offset
      @source = source
    end
    # rubocop:enable Naming/MethodParameterName

    def ==(other)
      return false unless other.is_a?(Char)

      c == other.c && offset == other.offset && source == other.source
    end

    def to_s
      c
    end

    def inspect
      "#<Yosina::Char c=#{c.inspect} offset=#{offset} source=#{source&.inspect}>"
    end
  end
end
