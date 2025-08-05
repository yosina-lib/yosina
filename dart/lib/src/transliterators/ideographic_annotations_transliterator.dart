// GENERATED CODE - DO NOT MODIFY BY HAND

import '../char.dart';
import '../transliterator.dart';

/// Replace ideographic annotation marks used in traditional translation.
class IdeographicAnnotationsTransliterator implements Transliterator {
  const IdeographicAnnotationsTransliterator(
      [Map<String, dynamic> options = const {}]);
  static const _mappings = <String, String>{
    '\u{3192}': '\u{4e00}',
    '\u{3193}': '\u{4e8c}',
    '\u{3194}': '\u{4e09}',
    '\u{3195}': '\u{56db}',
    '\u{3196}': '\u{4e0a}',
    '\u{3197}': '\u{4e2d}',
    '\u{3198}': '\u{4e0b}',
    '\u{3199}': '\u{7532}',
    '\u{319a}': '\u{4e59}',
    '\u{319b}': '\u{4e19}',
    '\u{319c}': '\u{4e01}',
    '\u{319d}': '\u{5929}',
    '\u{319e}': '\u{5730}',
    '\u{319f}': '\u{4eba}',
  };

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    var offset = 0;
    for (final char in inputChars) {
      final replacement = _mappings[char.c];
      if (replacement != null) {
        yield Char(replacement, offset, char);
        offset += replacement.length;
      } else {
        yield char.withOffset(offset);
        offset += char.c.length;
      }
    }
  }
}
