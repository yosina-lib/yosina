import 'char.dart';

/// Utility class for working with character sequences.
class Chars {
  /// Converts a string to an iterable of [Char] objects.
  static Iterable<Char> fromString(String input) sync* {
    var offset = 0;
    int? prev;
    for (final rune in input.runes) {
      if (prev != null) {
        if (isVariantSelector(rune)) {
          final c = String.fromCharCode(prev) + String.fromCharCode(rune);
          yield Char(c, offset);
          offset += c.length;
          prev = null;
          continue;
        }
        final c = String.fromCharCode(prev);
        yield Char(c, offset);
        offset += c.length;
      }
      prev = rune;
    }
    if (prev != null) {
      final c = String.fromCharCode(prev);
      yield Char(c, offset);
      offset += c.length;
    }
    yield Char('', offset);
  }

  /// Converts an iterable of [Char] objects back to a string.
  static String charsToString(Iterable<Char> chars) {
    final buffer = StringBuffer();
    for (final char in chars) {
      buffer.write(char.c);
    }
    return buffer.toString();
  }

  /// Checks if a Unicode code point is a variant selector.
  ///
  /// Variant selectors are special Unicode characters that modify the appearance
  /// of the preceding character. This includes:
  /// - Standard Variation Selectors (U+FE00 to U+FE0F)
  /// - Ideographic Variation Selectors (U+E0100 to U+E01EF)
  ///
  /// Returns true if [rune] is a variant selector, false otherwise.
  static bool isVariantSelector(int rune) {
    return 0xFE00 <= rune && rune <= 0xFE0F ||
        0xE0100 <= rune && rune <= 0xE01EF;
  }
}

/// Extension methods for Iterable<Char>
extension CharsIterableExtension on Iterable<Char> {
  /// Converts this iterable of Char objects to a string.
  String charsToString() => Chars.charsToString(this);
}
