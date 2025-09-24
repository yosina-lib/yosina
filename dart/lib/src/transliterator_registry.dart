import 'generated_registry.dart';
import 'transliterator.dart';
// Manual transliterators
import 'transliterators/charset.dart';
import 'transliterators/circled_or_squared_transliterator.dart';
import 'transliterators/hira_kata_composition_transliterator.dart';
import 'transliterators/hira_kata_transliterator.dart';
import 'transliterators/hyphens_transliterator.dart';
import 'transliterators/ivs_svs_base_transliterator.dart';
import 'transliterators/japanese_iteration_marks_transliterator.dart';
import 'transliterators/jisx0201_and_alike_transliterator.dart';
import 'transliterators/prolonged_sound_marks_transliterator.dart';

/// Factory function for creating transliterators.
///
/// Takes a map of options and returns a configured [Transliterator] instance.
/// The available options depend on the specific transliterator implementation.
typedef TransliteratorFactory = Transliterator Function(
    Map<String, dynamic> options);

/// Registry for transliterator factories.
///
/// This class manages a collection of transliterator factories, allowing
/// transliterators to be created by name with optional configuration.
/// A default registry with all built-in transliterators is available
/// via [defaultRegistry].
class TransliteratorRegistry {
  final Map<String, TransliteratorFactory> _factories = {};

  /// The default registry instance with all built-in transliterators.
  static final TransliteratorRegistry _defaultRegistry = _createDefault();

  /// Registers a transliterator factory with the given name.
  ///
  /// - [name] is the identifier for the transliterator
  /// - [factory] is the function that creates transliterator instances
  ///
  /// If a factory with the same name already exists, it will be replaced.
  void register(String name, TransliteratorFactory factory) {
    _factories[name] = factory;
  }

  /// Creates a transliterator by name with optional configuration.
  ///
  /// - [name] is the identifier of the transliterator to create
  /// - [options] is an optional map of configuration parameters
  ///
  /// Throws [ArgumentError] if no transliterator is registered with the given name.
  Transliterator create(String name,
      [Map<String, dynamic> options = const {}]) {
    final factory = _factories[name];
    if (factory == null) {
      throw ArgumentError('Unknown transliterator: $name');
    }
    return factory(options);
  }

  /// Checks if a transliterator with the given name is registered.
  ///
  /// Returns true if a factory exists for [name], false otherwise.
  bool hasTransliterator(String name) {
    return _factories.containsKey(name);
  }

  /// Gets all registered transliterator names.
  ///
  /// Returns a list of all transliterator identifiers that can be used
  /// with the [create] method.
  List<String> get registeredNames => _factories.keys.toList();

  /// The default registry with all built-in transliterators.
  /// This property returns a statically initialized instance for better performance.
  static TransliteratorRegistry get defaultRegistry => _defaultRegistry;

  /// Creates the default registry with all built-in transliterators.
  ///
  /// This includes both manually implemented transliterators and
  /// automatically generated ones.
  static TransliteratorRegistry _createDefault() {
    final registry = TransliteratorRegistry();

    // Register manual transliterators
    // ignore: cascade_invocations
    registry
      ..register(
          'circledOrSquared',
          (options) => CircledOrSquaredTransliterator(
                templates: options['templates'] as Map<String, String>?,
                includeEmojis: options['includeEmojis'] as bool? ?? false,
              ))
      ..register('hiraKata',
          (options) => HiraKataTransliterator(mode: options['mode']))
      ..register(
          'hiraKataComposition',
          (options) => HiraKataCompositionTransliterator(
                composeNonCombiningMarks:
                    options['composeNonCombiningMarks'] as bool? ?? false,
              ))
      ..register(
          'hyphens',
          (options) => HyphensTransliterator(
                precedence:
                    (options['precedence'] as List<dynamic>?)?.cast<String>(),
              ))
      ..register(
          'ivsSvsBase',
          (options) => IvsSvsBaseTransliterator(
                mode: options['mode'] as String? ?? 'base',
                charset: options['charset'] as Charset? ?? Charset.unijis2004,
                preferSvs: options['preferSvs'] as bool? ?? false,
                dropSelectorsAltogether:
                    options['dropSelectorsAltogether'] as bool? ?? false,
              ))
      ..register(
          'jisx0201AndAlike',
          (options) => Jisx0201AndAlikeTransliterator(
                fullwidthToHalfwidth:
                    options['fullwidthToHalfwidth'] as bool? ?? true,
                convertGL: options['convertGL'] as bool? ?? true,
                convertGR: options['convertGR'] as bool? ?? true,
                convertHiraganas: options['convertHiraganas'] as bool? ?? false,
                combineVoicedSoundMarks:
                    options['combineVoicedSoundMarks'] as bool? ?? true,
                convertUnsafeSpecials:
                    options['convertUnsafeSpecials'] as bool?,
                u005cAsYenSign: options['u005cAsYenSign'] as bool?,
                u005cAsBackslash: options['u005cAsBackslash'] as bool?,
                u007eAsFullwidthTilde:
                    options['u007eAsFullwidthTilde'] as bool?,
                u007eAsWaveDash: options['u007eAsWaveDash'] as bool?,
                u007eAsOverline: options['u007eAsOverline'] as bool?,
                u007eAsFullwidthMacron:
                    options['u007eAsFullwidthMacron'] as bool?,
                u00a5AsYenSign: options['u00a5AsYenSign'] as bool?,
              ))
      ..register(
          'prolongedSoundMarks',
          (options) => ProlongedSoundMarksTransliterator(
                skipAlreadyTransliteratedChars:
                    options['skipAlreadyTransliteratedChars'] as bool? ?? false,
                allowProlongedHatsuon:
                    options['allowProlongedHatsuon'] as bool? ?? false,
                allowProlongedSokuon:
                    options['allowProlongedSokuon'] as bool? ?? false,
                replaceProlongedMarksFollowingAlnums:
                    options['replaceProlongedMarksFollowingAlnums'] as bool? ??
                        false,
              ))
      ..register('japaneseIterationMarks',
          (options) => JapaneseIterationMarksTransliterator());

    // Register generated transliterators
    registerGeneratedTransliterators(registry);

    return registry;
  }
}
