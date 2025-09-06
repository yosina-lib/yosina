/// Represents a character with its offset and source information.
class Char {
  /// Creates a character with its position and source information.
  ///
  /// - [c] is the character string value
  /// - [offset] is the position in the output stream
  /// - [source] is the optional source character this was derived from
  const Char(this.c, this.offset, [this.source]);

  /// The character string.
  final String c;

  /// The offset in the output stream.
  final int offset;

  /// The source character this was derived from.
  final Char? source;

  /// Whether this character has been transliterated from its original form.
  ///
  /// Returns true if this character's value differs from any of its source
  /// characters in the transformation chain, false otherwise.
  bool get isTransliterated {
    var c = this;
    for (;;) {
      final s = c.source;
      if (s == null) break;
      if (s.c != c.c) return true;
      c = s;
    }
    return false;
  }

  /// Creates a new Char with a different offset.
  Char withOffset(int newOffset) => Char(c, newOffset, this);

  @override
  String toString() =>
      'Char($c, offset: $offset, source: ${source?.toString() ?? "null"})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Char &&
          runtimeType == other.runtimeType &&
          c == other.c &&
          offset == other.offset;

  @override
  int get hashCode => c.hashCode ^ offset.hashCode;
}
