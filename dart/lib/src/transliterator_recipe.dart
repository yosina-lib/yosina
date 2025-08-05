import 'chained_transliterator.dart';
import 'transliterator.dart';
import 'transliterator_registry.dart';

// MARK: - Option Classes

/// Options for full-width conversion.
class ToFullwidthOptions {
  const ToFullwidthOptions({
    required this.enabled,
    required this.u005cAsYenSign,
  });

  const ToFullwidthOptions.disabled()
      : enabled = false,
        u005cAsYenSign = false;

  const ToFullwidthOptions.enabled()
      : enabled = true,
        u005cAsYenSign = false;

  const ToFullwidthOptions.u005cAsYenSign()
      : enabled = true,
        u005cAsYenSign = true;

  final bool enabled;
  final bool u005cAsYenSign;

  bool get isEnabled => enabled;
  bool get isU005cAsYenSign => u005cAsYenSign;

  static ToFullwidthOptions fromBool(bool enabled) {
    return enabled
        ? const ToFullwidthOptions.enabled()
        : const ToFullwidthOptions.disabled();
  }
}

/// Options for half-width conversion.
class ToHalfwidthOptions {
  const ToHalfwidthOptions({
    required this.enabled,
    required this.hankakuKana,
  });

  const ToHalfwidthOptions.disabled()
      : enabled = false,
        hankakuKana = false;

  const ToHalfwidthOptions.enabled()
      : enabled = true,
        hankakuKana = false;

  const ToHalfwidthOptions.hankakuKana()
      : enabled = true,
        hankakuKana = true;

  final bool enabled;
  final bool hankakuKana;

  bool get isEnabled => enabled;
  bool get isHankakuKana => hankakuKana;

  static ToHalfwidthOptions fromBool(bool enabled) {
    return enabled
        ? const ToHalfwidthOptions.enabled()
        : const ToHalfwidthOptions.disabled();
  }
}

/// Options for IVS/SVS removal.
class RemoveIvsSvsOptions {
  const RemoveIvsSvsOptions({
    required this.enabled,
    required this.dropAllSelectors,
  });

  const RemoveIvsSvsOptions.disabled()
      : enabled = false,
        dropAllSelectors = false;

  const RemoveIvsSvsOptions.enabled()
      : enabled = true,
        dropAllSelectors = false;

  const RemoveIvsSvsOptions.dropAllSelectors()
      : enabled = true,
        dropAllSelectors = true;

  final bool enabled;
  final bool dropAllSelectors;

  bool get isEnabled => enabled;
  bool get isDropAllSelectors => dropAllSelectors;

  static RemoveIvsSvsOptions fromBool(bool enabled) {
    return enabled
        ? const RemoveIvsSvsOptions.enabled()
        : const RemoveIvsSvsOptions.disabled();
  }
}

/// Options for hyphens replacement.
class ReplaceHyphensOptions {
  const ReplaceHyphensOptions({
    required this.enabled,
    this.precedence,
  });

  const ReplaceHyphensOptions.disabled()
      : enabled = false,
        precedence = null;

  const ReplaceHyphensOptions.enabled()
      : enabled = true,
        precedence = const ['jisx0208_90_windows', 'jisx0201'];

  final bool enabled;
  final List<String>? precedence;

  bool get isEnabled => enabled;

  static ReplaceHyphensOptions withPrecedence(List<String> precedence) {
    return ReplaceHyphensOptions(enabled: true, precedence: precedence);
  }

  static ReplaceHyphensOptions fromBool(bool enabled) {
    return enabled
        ? const ReplaceHyphensOptions.enabled()
        : const ReplaceHyphensOptions.disabled();
  }
}

/// Options for circled or squared characters replacement.
class ReplaceCircledOrSquaredCharactersOptions {
  const ReplaceCircledOrSquaredCharactersOptions({
    required this.enabled,
    required this.includeEmojis,
  });

  const ReplaceCircledOrSquaredCharactersOptions.disabled()
      : enabled = false,
        includeEmojis = false;

  const ReplaceCircledOrSquaredCharactersOptions.enabled()
      : enabled = true,
        includeEmojis = true;

  const ReplaceCircledOrSquaredCharactersOptions.excludeEmojis()
      : enabled = true,
        includeEmojis = false;

  final bool enabled;
  final bool includeEmojis;

  bool get isEnabled => enabled;

  static ReplaceCircledOrSquaredCharactersOptions fromBool(bool enabled) {
    return enabled
        ? const ReplaceCircledOrSquaredCharactersOptions.enabled()
        : const ReplaceCircledOrSquaredCharactersOptions.disabled();
  }
}

// MARK: - TransliteratorConfig

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

// MARK: - TransliteratorRecipe

/// Represents a recipe for creating transliterators.
///
/// This class provides both low-level (direct config list) and high-level
/// (declarative options) ways to configure transliterator chains.
class TransliteratorRecipe {
  const TransliteratorRecipe(this.configs);

  /// Create a recipe from a list of transliterator names.
  factory TransliteratorRecipe.fromNames(List<String> names) {
    return TransliteratorRecipe(
      names.map((name) => TransliteratorConfig(name)).toList(),
    );
  }

  /// Create a recipe from a map of transliterator configurations.
  factory TransliteratorRecipe.fromMap(List<Map<String, dynamic>> configs) {
    return TransliteratorRecipe(
      configs.map((config) => TransliteratorConfig.fromMap(config)).toList(),
    );
  }

  /// Create a recipe using high-level configuration options.
  ///
  /// This factory provides a declarative way to configure complex transliterator
  /// chains using semantic options that are automatically converted to the
  /// appropriate transliterator configurations.
  factory TransliteratorRecipe.withOptions({
    bool kanjiOldNew = false,
    bool replaceSuspiciousHyphensToProlongedSoundMarks = false,
    bool replaceCombinedCharacters = false,
    ReplaceCircledOrSquaredCharactersOptions replaceCircledOrSquaredCharacters =
        const ReplaceCircledOrSquaredCharactersOptions.disabled(),
    bool replaceIdeographicAnnotations = false,
    bool replaceRadicals = false,
    bool replaceSpaces = false,
    ReplaceHyphensOptions replaceHyphens =
        const ReplaceHyphensOptions.disabled(),
    bool replaceMathematicalAlphanumerics = false,
    bool combineDecomposedHiraganasAndKatakanas = false,
    ToFullwidthOptions toFullwidth = const ToFullwidthOptions.disabled(),
    ToHalfwidthOptions toHalfwidth = const ToHalfwidthOptions.disabled(),
    RemoveIvsSvsOptions removeIvsSvs = const RemoveIvsSvsOptions.disabled(),
    String charset = 'unijis_2004',
  }) {
    // Check for mutually exclusive options
    final errors = <String>[];
    if (toFullwidth.isEnabled && toHalfwidth.isEnabled) {
      errors.add('toFullwidth and toHalfwidth are mutually exclusive');
    }

    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join('; '));
    }

    final builder = _TransliteratorConfigListBuilder();

    // Apply transformations in the specified order
    _applyKanjiOldNew(builder, kanjiOldNew, removeIvsSvs, charset);
    _applyReplaceSuspiciousHyphensToProlongedSoundMarks(
        builder, replaceSuspiciousHyphensToProlongedSoundMarks);
    _applyReplaceCircledOrSquaredCharacters(
        builder, replaceCircledOrSquaredCharacters);
    _applyReplaceCombinedCharacters(builder, replaceCombinedCharacters);
    _applyReplaceIdeographicAnnotations(builder, replaceIdeographicAnnotations);
    _applyReplaceRadicals(builder, replaceRadicals);
    _applyReplaceSpaces(builder, replaceSpaces);
    _applyReplaceHyphens(builder, replaceHyphens);
    _applyReplaceMathematicalAlphanumerics(
        builder, replaceMathematicalAlphanumerics);
    _applyCombineDecomposedHiraganasAndKatakanas(
        builder, combineDecomposedHiraganasAndKatakanas);
    _applyToFullwidth(builder, toFullwidth);
    _applyToHalfwidth(builder, toHalfwidth);
    _applyRemoveIvsSvs(builder, removeIvsSvs, charset);

    return TransliteratorRecipe(builder.build());
  }

  final List<TransliteratorConfig> configs;

  /// Create a transliterator from this recipe using the given registry.
  Transliterator create(TransliteratorRegistry registry) {
    if (configs.isEmpty) {
      throw ArgumentError(
          'Recipe must contain at least one transliterator config');
    }

    if (configs.length == 1) {
      return registry.create(configs[0].name, configs[0].options);
    }

    final transliterators = configs
        .map((config) => registry.create(config.name, config.options))
        .toList();

    return ChainedTransliterator(transliterators);
  }

  // Private helper methods for applying transformations

  static void _removeIvsSvsHelper(_TransliteratorConfigListBuilder ctx,
      bool dropAllSelectors, String charset) {
    // First insert IVS-or-SVS mode at head
    ctx.insertHead(
      TransliteratorConfig('ivsSvsBase', {
        'mode': 'ivs-or-svs',
        'charset': charset,
      }),
      forceReplace: true,
    );
    ctx.insertTail(
      TransliteratorConfig('ivsSvsBase', {
        'mode': 'base',
        'dropSelectorsAltogether': dropAllSelectors,
        'charset': charset,
      }),
      forceReplace: true,
    );
  }

  static void _applyKanjiOldNew(_TransliteratorConfigListBuilder ctx,
      bool kanjiOldNew, RemoveIvsSvsOptions removeIvsSvs, String charset) {
    if (kanjiOldNew) {
      if (!removeIvsSvs.isEnabled) {
        _removeIvsSvsHelper(ctx, false, charset);
      }
      ctx.insertMiddle(
        const TransliteratorConfig('kanjiOldNew'),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceSuspiciousHyphensToProlongedSoundMarks(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('prolongedSoundMarks', {
          'replaceProlongedMarksFollowingAlnums': true,
        }),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceIdeographicAnnotations(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('ideographicAnnotations'),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceRadicals(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('radicals'),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceSpaces(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('spaces'),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceHyphens(
      _TransliteratorConfigListBuilder ctx, ReplaceHyphensOptions options) {
    if (options.isEnabled) {
      final Map<String, dynamic> configOptions =
          options.precedence != null ? {'precedence': options.precedence} : {};
      ctx.insertMiddle(
        TransliteratorConfig('hyphens', configOptions),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceMathematicalAlphanumerics(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('mathematicalAlphanumerics'),
        forceReplace: false,
      );
    }
  }

  static void _applyCombineDecomposedHiraganasAndKatakanas(
      _TransliteratorConfigListBuilder ctx, bool combine) {
    if (combine) {
      ctx.insertHead(
        const TransliteratorConfig('hiraKataComposition', {
          'decomposeFirst': true,
        }),
        forceReplace: false,
      );
    }
  }

  static void _applyToFullwidth(
      _TransliteratorConfigListBuilder ctx, ToFullwidthOptions options) {
    if (options.isEnabled) {
      ctx.insertTail(
        TransliteratorConfig('jisX0201AndAlike', {
          'fullwidthToHalfwidth': false,
          'u005cAsYenSign': options.isU005cAsYenSign,
        }),
        forceReplace: false,
      );
    }
  }

  static void _applyToHalfwidth(
      _TransliteratorConfigListBuilder ctx, ToHalfwidthOptions options) {
    if (options.isEnabled) {
      ctx.insertTail(
        TransliteratorConfig('jisX0201AndAlike', {
          'fullwidthToHalfwidth': true,
          'convertGL': true,
          'convertGR': options.isHankakuKana,
        }),
        forceReplace: false,
      );
    }
  }

  static void _applyRemoveIvsSvs(_TransliteratorConfigListBuilder ctx,
      RemoveIvsSvsOptions options, String charset) {
    if (options.isEnabled) {
      _removeIvsSvsHelper(ctx, options.isDropAllSelectors, charset);
    }
  }

  static void _applyReplaceCombinedCharacters(
      _TransliteratorConfigListBuilder ctx, bool replace) {
    if (replace) {
      ctx.insertMiddle(
        const TransliteratorConfig('combined'),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceCircledOrSquaredCharacters(
      _TransliteratorConfigListBuilder ctx,
      ReplaceCircledOrSquaredCharactersOptions options) {
    if (options.isEnabled) {
      ctx.insertMiddle(
        TransliteratorConfig('circledOrSquared', {
          'includeEmojis': options.includeEmojis,
        }),
        forceReplace: false,
      );
    }
  }
}

// MARK: - Internal Builder

/// Internal builder for creating lists of transliterator configurations.
class _TransliteratorConfigListBuilder {
  final List<TransliteratorConfig> _head = [];
  final List<TransliteratorConfig> _tail = [];

  void insertHead(TransliteratorConfig config, {required bool forceReplace}) {
    final existingIndex = _findConfigIndex(_head, config.name);

    if (existingIndex >= 0) {
      if (forceReplace) {
        _head[existingIndex] = config;
      }
    } else {
      _head.insert(0, config);
    }
  }

  void insertMiddle(TransliteratorConfig config, {required bool forceReplace}) {
    final existingIndex = _findConfigIndex(_tail, config.name);

    if (existingIndex >= 0) {
      if (forceReplace) {
        _tail[existingIndex] = config;
      }
    } else {
      _tail.insert(0, config); // Insert at beginning of tail (middle position)
    }
  }

  void insertTail(TransliteratorConfig config, {required bool forceReplace}) {
    final existingIndex = _findConfigIndex(_tail, config.name);

    if (existingIndex >= 0) {
      if (forceReplace) {
        _tail[existingIndex] = config;
      }
    } else {
      _tail.add(config);
    }
  }

  int _findConfigIndex(List<TransliteratorConfig> configs, String name) {
    for (var i = 0; i < configs.length; i++) {
      if (configs[i].name == name) {
        return i;
      }
    }
    return -1;
  }

  List<TransliteratorConfig> build() {
    return [..._head, ..._tail];
  }
}
