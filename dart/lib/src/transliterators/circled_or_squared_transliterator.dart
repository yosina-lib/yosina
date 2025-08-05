import '../char.dart';
import '../transliterator.dart';
import 'circled_or_squared_data.dart';

/// Replace circled or squared characters with templated forms.
class CircledOrSquaredTransliterator implements Transliterator {
  CircledOrSquaredTransliterator({
    Map<String, String>? templates,
    this.includeEmojis = false,
  }) : templates = {
          'circle': templates?['circle'] ?? '(?)',
          'square': templates?['square'] ?? '[?]',
        };
  final Map<String, String> templates;
  final bool includeEmojis;

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    var offset = 0;
    for (final char in inputChars) {
      final record = circledOrSquaredData[char.c];
      if (record != null) {
        // Skip emoji characters if not included
        if (record['emoji'] == true && !includeEmojis) {
          yield char.withOffset(offset);
          offset += char.c.length;
          continue;
        }

        // Get template
        final template = templates[record['type']] ?? '?';
        final replacement = template.replaceAll('?', record['rendering'] ?? '');

        if (replacement.isEmpty) {
          yield char.withOffset(offset);
          offset += char.c.length;
          continue;
        }

        // Yield each character in the replacement string
        for (final rune in replacement.runes) {
          final replacementChar = String.fromCharCode(rune);
          yield Char(replacementChar, offset, char);
          offset += replacementChar.length;
        }
      } else {
        yield char.withOffset(offset);
        offset += char.c.length;
      }
    }
  }
}
