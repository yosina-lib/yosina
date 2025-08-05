import 'transliterator.dart';
import 'transliterators/charset.dart';

// MARK: - Option Classes

/// Options for full-width conversion.
/// Options for converting characters to their fullwidth equivalents.
///
/// Controls which character types should be converted to fullwidth forms.
/// Fullwidth characters are typically used in East Asian typography.
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
/// Options for converting characters to their halfwidth equivalents.
///
/// Controls which character types should be converted to halfwidth forms.
/// Halfwidth characters are single-byte width characters commonly used in ASCII.
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
/// Options for removing Ideographic Variation Sequences (IVS) and Standardized Variation Sequences (SVS).
///
/// Controls which types of variation sequences should be removed from the text.
/// These sequences are used to specify glyph variants in Unicode.
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
/// Options for replacing various hyphen-like characters.
///
/// Controls which types of hyphens and dashes should be replaced with a standard hyphen.
/// This helps normalize different dash characters used across various input methods.
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
/// Options for replacing circled or squared characters with their normal equivalents.
///
/// Controls which types of enclosed characters should be replaced.
/// These include characters enclosed in circles or squares, commonly used in East Asian typography.
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

// MARK: - TransliterationRecipe

/// Represents a recipe for creating transliterators.
///
/// This class is a value object that holds configuration options
/// and can build a list of TransliteratorConfig objects.
class TransliterationRecipe {
  TransliterationRecipe({
    this.kanjiOldNew = false,
    this.hiraKata,
    this.replaceJapaneseIterationMarks = false,
    this.replaceSuspiciousHyphensToProlongedSoundMarks = false,
    this.replaceCombinedCharacters = false,
    this.replaceCircledOrSquaredCharacters =
        const ReplaceCircledOrSquaredCharactersOptions.disabled(),
    this.replaceIdeographicAnnotations = false,
    this.replaceRadicals = false,
    this.replaceSpaces = false,
    this.replaceHyphens = const ReplaceHyphensOptions.disabled(),
    this.replaceMathematicalAlphanumerics = false,
    this.combineDecomposedHiraganasAndKatakanas = false,
    this.toFullwidth = const ToFullwidthOptions.disabled(),
    this.toHalfwidth = const ToHalfwidthOptions.disabled(),
    this.removeIvsSvs = const RemoveIvsSvsOptions.disabled(),
    this.charset = Charset.unijis2004,
  }) {
    // Check for mutually exclusive options
    final errors = <String>[];
    if (toFullwidth.isEnabled && toHalfwidth.isEnabled) {
      errors.add('toFullwidth and toHalfwidth are mutually exclusive');
    }

    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join('; '));
    }
  }

  final bool kanjiOldNew;
  final String? hiraKata;
  final bool replaceJapaneseIterationMarks;
  final bool replaceSuspiciousHyphensToProlongedSoundMarks;
  final bool replaceCombinedCharacters;
  final ReplaceCircledOrSquaredCharactersOptions
      replaceCircledOrSquaredCharacters;
  final bool replaceIdeographicAnnotations;
  final bool replaceRadicals;
  final bool replaceSpaces;
  final ReplaceHyphensOptions replaceHyphens;
  final bool replaceMathematicalAlphanumerics;
  final bool combineDecomposedHiraganasAndKatakanas;
  final ToFullwidthOptions toFullwidth;
  final ToHalfwidthOptions toHalfwidth;
  final RemoveIvsSvsOptions removeIvsSvs;
  final Charset charset;

  /// Build a list of transliterator configurations from this recipe.
  List<TransliteratorConfig> buildTransliteratorConfigs() {
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
    _applyHiraKata(builder, hiraKata);
    _applyReplaceJapaneseIterationMarks(builder, replaceJapaneseIterationMarks);
    _applyToHalfwidth(builder, toHalfwidth);
    _applyRemoveIvsSvs(builder, removeIvsSvs, charset);

    return builder.build();
  }

  // Private helper methods for applying transformations

  static void _removeIvsSvsHelper(_TransliteratorConfigListBuilder ctx,
      bool dropAllSelectors, Charset charset) {
    // First insert IVS-or-SVS mode at head
    ctx
      ..insertHead(
        TransliteratorConfig('ivsSvsBase', {
          'mode': 'ivs-or-svs',
          'charset': charset,
        }),
        forceReplace: true,
      )
      ..insertTail(
        TransliteratorConfig('ivsSvsBase', {
          'mode': 'base',
          'dropSelectorsAltogether': dropAllSelectors,
          'charset': charset,
        }),
        forceReplace: true,
      );
  }

  static void _applyKanjiOldNew(_TransliteratorConfigListBuilder ctx,
      bool kanjiOldNew, RemoveIvsSvsOptions removeIvsSvs, Charset charset) {
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

  static void _applyHiraKata(
      _TransliteratorConfigListBuilder ctx, String? hiraKata) {
    if (hiraKata != null) {
      ctx.insertMiddle(
        TransliteratorConfig('hiraKata', {'mode': hiraKata}),
        forceReplace: false,
      );
    }
  }

  static void _applyReplaceJapaneseIterationMarks(
      _TransliteratorConfigListBuilder ctx,
      bool replaceJapaneseIterationMarks) {
    if (replaceJapaneseIterationMarks) {
      // Insert HiraKataComposition at head to ensure composed forms
      ctx
        ..insertHead(
          const TransliteratorConfig('hiraKataComposition', {
            'composeNonCombiningMarks': true,
          }),
          forceReplace: false,
        )
        // Then insert the japanese-iteration-marks in the middle
        ..insertMiddle(
          const TransliteratorConfig('japaneseIterationMarks'),
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
      RemoveIvsSvsOptions options, Charset charset) {
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
