import 'char.dart';
import 'transliterator.dart';

/// A transliterator that chains multiple transliterators together.
class ChainedTransliterator implements Transliterator {
  /// Creates a chained transliterator that applies multiple transliterators in sequence.
  ///
  /// The [transliterators] parameter is a list of transliterators that will be
  /// applied in order. Each transliterator receives the output of the previous one.
  const ChainedTransliterator(this.transliterators);
  /// The list of transliterators to apply in sequence.
  ///
  /// Each transliterator in this list will be called with the output from
  /// the previous transliterator, creating a pipeline of transformations.
  final List<Transliterator> transliterators;

  @override
  Iterable<Char> call(Iterable<Char> inputChars) {
    var result = inputChars;
    for (final transliterator in transliterators) {
      result = transliterator(result);
    }
    return result;
  }
}
