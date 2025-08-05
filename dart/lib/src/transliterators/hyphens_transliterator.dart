import '../char.dart';
import '../transliterator.dart';
import 'hyphens_data.dart';

/// Hyphen character normalization transliterator.
///
/// This transliterator substitutes commoner counterparts for hyphens and a number of symbols.
/// It handles various dash/hyphen symbols and normalizes them to those common in Japanese
/// writing based on the precedence order.
class HyphensTransliterator implements Transliterator {
  HyphensTransliterator({
    List<String>? precedence,
  }) : precedence = precedence ?? _defaultPrecedence;
  static const _defaultPrecedence = ['jisx0208_90'];

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
