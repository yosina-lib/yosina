import '../char.dart';
import '../transliterator.dart';
import 'circled_or_squared_data.dart';

/// Transliterator that replaces circled or squared characters with templated representations.
///
/// This transliterator converts enclosed alphanumeric characters (characters enclosed in
/// circles or squares) to a normalized template format. This is useful for text normalization
/// when you want to convert decorative enclosed characters to a standard representation.
///
/// Example conversions:
/// - ① → (1) or custom template
/// - ㊀ → (日) or custom template
/// - 🄰 → [A] or custom template
///
/// The transliterator handles both Unicode enclosed characters and emoji-style enclosed
/// characters based on the configuration.
class CircledOrSquaredTransliterator implements Transliterator {
  /// Creates a new instance of [CircledOrSquaredTransliterator].
  ///
  /// [templates] - Optional custom templates for replacement. If not provided, defaults to:
  ///   - 'circle': '(?)'  where ? is replaced with the enclosed character
  ///   - 'square': '[?]'  where ? is replaced with the enclosed character
  ///
  /// [includeEmojis] - Whether to include emoji-style enclosed characters in the conversion.
  ///   Defaults to false. When false, emoji enclosed characters are left unchanged.
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
