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

    # Check if the character is a sentinel (empty character)
    #
    # @return [Boolean] true if the character is empty, false otherwise
    def sentinel?
      @c.empty?
    end

    # Create a new Char with a different offset
    #
    # @param offset [Integer] The new offset for the character
    # @return [Char] A new Char instance with the updated offset
    def with_offset(offset)
      Char.new(c: @c, offset: offset, source: self)
    end

    # Check if the character has been transliterated
    #
    # @return [Boolean] true if the character has a source, false otherwise
    def transliterated?
      c = self
      loop do
        s = c.source
        break if s.nil?
        return true if c.c != s.c

        c = s
      end
      false
    end

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
