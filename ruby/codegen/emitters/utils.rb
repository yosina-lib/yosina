# frozen_string_literal: true

def _to_unicode_escapes_inner(str)
  special_char_exists = false
  [
    str.codepoints.map do |codepoint|
      if codepoint > 127
        special_char_exists = true
        # rubocop:disable Style/FormatString
        '\\u{%x}' % codepoint
        # rubocop:enable Style/FormatString
      elsif [34, 39, 92].include?(codepoint)
        special_char_exists = true
        "\\#{codepoint.chr}"
      else
        codepoint.chr
      end
    end.join,
    special_char_exists
  ]
end

# Convert a string to use Unicode escape sequences for non-ASCII characters
def to_unicode_escapes(str)
  _to_unicode_escapes_inner(str)
end

def to_string_literal(str)
  result, special_char_exists = _to_unicode_escapes_inner(str)
  if special_char_exists
    "\"#{result}\""
  else
    "'#{result}'"
  end
end

def dedent(shift, lines)
  lines.lines.map do |l|
    if l[0, shift].each_char.all? { |c| c == ' ' }
      l[shift..]
    else
      l
    end
  end.join
end
