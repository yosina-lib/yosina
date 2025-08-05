import 'char.dart';

/// Base interface for all transliterators.
abstract class Transliterator {
  /// Transforms the input characters.
  Iterable<Char> call(Iterable<Char> inputChars);
}
