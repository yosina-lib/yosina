import 'char.dart';

/// Utility class for working with character sequences.
class Chars {
  /// Converts a string to an iterable of [Char] objects.
  static Iterable<Char> fromString(String input) sync* {
    var offset = 0;
    final runes = input.runes.toList();

    for (var i = 0; i < runes.length; i++) {
      final rune = runes[i];
      final char = String.fromCharCode(rune);

      // Handle surrogate pairs
      if (_isHighSurrogate(rune) &&
          i + 1 < runes.length &&
          _isLowSurrogate(runes[i + 1])) {
        final lowSurrogate = runes[i + 1];
        final fullChar = String.fromCharCodes([rune, lowSurrogate]);
        yield Char(fullChar, offset);
        offset += fullChar.length;
        i++; // Skip the low surrogate
      } else {
        yield Char(char, offset);
        offset += char.length;
      }
    }
  }

  /// Converts an iterable of [Char] objects back to a string.
  static String charsToString(Iterable<Char> chars) {
    final buffer = StringBuffer();
    for (final char in chars) {
      buffer.write(char.c);
    }
    return buffer.toString();
  }

  static bool _isHighSurrogate(int codeUnit) {
    return codeUnit >= 0xD800 && codeUnit <= 0xDBFF;
  }

  static bool _isLowSurrogate(int codeUnit) {
    return codeUnit >= 0xDC00 && codeUnit <= 0xDFFF;
  }
}

/// Extension methods for Iterable<Char>
extension CharsIterableExtension on Iterable<Char> {
  /// Converts this iterable of Char objects to a string.
  String charsToString() => Chars.charsToString(this);
}
