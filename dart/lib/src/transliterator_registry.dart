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
typedef TransliteratorFactory = Transliterator Function(
    Map<String, dynamic> options);

/// Registry for transliterator factories.
class TransliteratorRegistry {
  final Map<String, TransliteratorFactory> _factories = {};

  /// The default registry instance with all built-in transliterators.
  static final TransliteratorRegistry _defaultRegistry = _createDefault();

  /// Register a transliterator factory.
  void register(String name, TransliteratorFactory factory) {
    _factories[name] = factory;
  }

  /// Create a transliterator by name.
  Transliterator create(String name,
      [Map<String, dynamic> options = const {}]) {
    final factory = _factories[name];
    if (factory == null) {
      throw ArgumentError('Unknown transliterator: $name');
    }
    return factory(options);
  }

  /// Check if a transliterator is registered.
  bool hasTransliterator(String name) {
    return _factories.containsKey(name);
  }

  /// Get all registered transliterator names.
  List<String> get registeredNames => _factories.keys.toList();

  /// The default registry with all built-in transliterators.
  /// This property returns a statically initialized instance for better performance.
  static TransliteratorRegistry get defaultRegistry => _defaultRegistry;

  /// Private method to create the default registry.
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
          'jisX0201AndAlike',
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
