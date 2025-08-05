import 'chained_transliterator.dart';
import 'char.dart';
import 'transliteration_recipe.dart';
import 'transliterator_registry.dart';

/// Configuration for a single transliterator.
class TransliteratorConfig {
  const TransliteratorConfig(this.name, [this.options = const {}]);

  factory TransliteratorConfig.fromMap(Map<String, dynamic> map) {
    return TransliteratorConfig(
      map['name'] as String,
      (map['options'] as Map<String, dynamic>?) ?? const {},
    );
  }

  final String name;
  final Map<String, dynamic> options;
}

/// Base interface for all transliterators.
abstract class Transliterator {
  /// Transforms the input characters.
  Iterable<Char> call(Iterable<Char> inputChars);

  /// Create a transliterator from a list of transliterator names.
  static Transliterator withList(List<String> names,
      [TransliteratorRegistry? registry]) {
    registry ??= TransliteratorRegistry.defaultRegistry;
    final configs = names.map((name) => TransliteratorConfig(name)).toList();
    return withConfigs(configs, registry);
  }

  /// Create a transliterator from a list of configuration maps.
  static Transliterator withMap(List<Map<String, dynamic>> configMaps,
      [TransliteratorRegistry? registry]) {
    registry ??= TransliteratorRegistry.defaultRegistry;
    final configs = configMaps
        .map((config) => TransliteratorConfig.fromMap(config))
        .toList();
    return withConfigs(configs, registry);
  }

  /// Create a transliterator from a list of configurations.
  static Transliterator withConfigs(List<TransliteratorConfig> configs,
      [TransliteratorRegistry? registry]) {
    final reg = registry ?? TransliteratorRegistry.defaultRegistry;

    if (configs.isEmpty) {
      throw ArgumentError(
          'Configs must contain at least one transliterator config');
    }

    if (configs.length == 1) {
      return reg.create(configs[0].name, configs[0].options);
    }

    final transliterators = configs
        .map((config) => reg.create(config.name, config.options))
        .toList();

    return ChainedTransliterator(transliterators);
  }

  /// Create a transliterator from a recipe.
  static Transliterator withRecipe(TransliterationRecipe recipe,
      [TransliteratorRegistry? registry]) {
    return withConfigs(recipe.buildTransliteratorConfigs(), registry);
  }
}
