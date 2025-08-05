// GENERATED CODE - DO NOT MODIFY BY HAND

import '../char.dart';
import '../transliterator.dart';

/// Replace various space characters with plain whitespace.
class SpacesTransliterator implements Transliterator {
  const SpacesTransliterator([Map<String, dynamic> options = const {}]);
  static const _mappings = <String, String>{
    '\u{a0}': ' ',
    '\u{180e}': '',
    '\u{2000}': ' ',
    '\u{2001}': ' ',
    '\u{2002}': ' ',
    '\u{2003}': ' ',
    '\u{2004}': ' ',
    '\u{2005}': ' ',
    '\u{2006}': ' ',
    '\u{2007}': ' ',
    '\u{2008}': ' ',
    '\u{2009}': ' ',
    '\u{200a}': ' ',
    '\u{200b}': ' ',
    '\u{202f}': ' ',
    '\u{205f}': ' ',
    '\u{3000}': ' ',
    '\u{3164}': ' ',
    '\u{ffa0}': ' ',
    '\u{feff}': '',
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
