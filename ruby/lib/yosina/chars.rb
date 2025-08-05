# frozen_string_literal: true

module Yosina
  # Character array building and string conversion utilities
  module Chars
    # Build a character array from a string, handling IVS/SVS sequences
    #
    # This function properly handles Ideographic Variation Sequences (IVS) and
    # Standardized Variation Sequences (SVS) by combining base characters with
    # their variation selectors into single Char objects.
    #
    # @param input_str [String] The input string to convert to character array
    # @return [Chars] A list of Char objects representing the input string,
    #   with a sentinel empty character at the end
    def self.build_char_array(input_str)
      result = []
      offset = 0
      prev_char = nil
      prev_codepoint = nil

      input_str.each_char do |char|
        codepoint = char.ord

        if prev_char && prev_codepoint
          # Check if current character is a variation selector
          # Variation selectors are in ranges: U+FE00-U+FE0F, U+E0100-U+E01EF
          if (0xFE00..0xFE0F).cover?(codepoint) || (0xE0100..0xE01EF).cover?(codepoint)
            # Combine previous character with variation selector
            combined_char = prev_char + char
            result << Char.new(c: combined_char, offset: offset)
            offset += combined_char.length
            prev_char = prev_codepoint = nil
            next
          end

          # Previous character was not followed by a variation selector
          result << Char.new(c: prev_char, offset: offset)
          offset += prev_char.length
        end

        # Store current character for next iteration
        prev_char = char
        prev_codepoint = codepoint
      end

      # Handle the last character if any
      if prev_char
        result << Char.new(c: prev_char, offset: offset)
        offset += prev_char.length
      end

      # Add sentinel empty character
      result << Char.new(c: '', offset: offset)

      class << result
        include Chars
      end

      result
    end

    # Convert an array of characters back to a string
    #
    # This function filters out sentinel characters (empty strings) that are
    # used internally by the transliteration system.
    #
    # @param chars [Enumerable<Char>] An array of Char objects
    # @return [String] A string composed of the non-empty characters
    def self.as_s(chars)
      chars.reject { |char| char.c.empty? }.map(&:c).join
    end

    # Create an enumerator that yields characters from the input
    #
    # @param &block [Proc] A block that yields characters to the enumerator
    # @return [Enumerator] An enumerator that yields Char objects
    def self.enum(&block)
      e = Enumerator.new { |y| block.call(y) }
      class << e
        include Chars
      end
      e
    end

    def to_s
      Chars.as_s(self)
    end

    %i[
      chunk_while
      partition
      slice_before
      slice_when
    ].each do |chunker|
      define_method(chunker) do |*args, &block|
        e = super.send(:chunker, *args, &block)
        e.map do |slice|
          class << slice
            include Chars
          end
          slice
        end
      end
    end

    %i[
      chain
      find_all
      drop
      drop_while
      entries
      filter
      grep
      grep_v
      reject
      select
      sort
      sort_by
      take
      take_while
      to_a
    ].each do |method|
      define_method(method) do |*args, &block|
        e = super(*args, &block)
        class << e
          include Chars
        end
        e
      end
    end

    def chunk(&block)
      e = super(&block)
      e.map do |g, slice|
        class << slice
          include Chars
        end
        [g, slice]
      end
    end

    def group_by(&block)
      e = super(&block)
      e.transform_values do |slice|
        class << slice
          include Chars
        end
        slice
      end
    end
  end
end
