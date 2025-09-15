import '../char.dart';
import '../transliterator.dart';
import 'hyphens_data.dart';

/// Hyphen character normalization transliterator.
///
/// This transliterator substitutes commoner counterparts for hyphens and a number of symbols.
/// It handles various dash/hyphen symbols and normalizes them to those common in Japanese
/// writing based on the precedence order.
class HyphensTransliterator implements Transliterator {
  /// Creates a hyphens transliterator with optional precedence configuration.
  ///
  /// [precedence] specifies the order of character set preferences when
  /// multiple replacements are available. Valid values include:
  /// - 'jisx0208_90': JIS X 0208:1990 standard (default)
  /// - 'jisx0208_90_windows': Windows variant of JIS X 0208:1990
  /// - 'jisx0201': JIS X 0201 standard
  ///
  /// If not specified, defaults to ['jisx0208_90'].
  HyphensTransliterator({
    List<String>? precedence,
  }) : precedence = precedence ?? _defaultPrecedence;

  /// Default precedence order for replacement selection.
  static const _defaultPrecedence = ['jisx0208_90'];

  /// The precedence order for selecting replacements.
  ///
  /// When multiple replacement options are available for a character,
  /// the first matching option in this list will be used.
  final List<String> precedence;

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    var offset = 0;
    for (final char in inputChars) {
      final record = hyphensData[char.c];
      if (record != null) {
        final replacement = _getReplacement(record);
        if (replacement != null && replacement != char.c) {
          yield Char(replacement, offset, char);
          offset += replacement.length;
        } else {
          yield char.withOffset(offset);
          offset += char.c.length;
        }
      } else {
        yield char.withOffset(offset);
        offset += char.c.length;
      }
    }
  }

  /// Gets the appropriate replacement for a character based on precedence.
  ///
  /// Iterates through the precedence list and returns the first available
  /// replacement from the record. Returns null if no replacement is found.
  String? _getReplacement(Map<String, String?> record) {
    for (final mappingType in precedence) {
      final replacement = record[mappingType];
      if (replacement != null) {
        return replacement;
      }
    }
    return null;
  }
}
