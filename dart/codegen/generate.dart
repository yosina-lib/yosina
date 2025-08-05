import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;

/// Main code generator for Yosina Dart transliterators.
class YosinaCodeGenerator {
  YosinaCodeGenerator() {
    final scriptDir = path.dirname(Platform.script.toFilePath());
    final projectRoot = path.dirname(scriptDir);
    dataRoot = path.join(path.dirname(projectRoot), 'data');
    destRoot = path.join(projectRoot, 'lib', 'src', 'transliterators');
  }
  late final String dataRoot;
  late final String destRoot;

  Future<void> generate() async {
    print('Loading datasets from: $dataRoot');
    print('Writing output to: $destRoot');

    await _generateSimpleTransliterators();
    await _generateComplexTransliterators();
    await _generateRegistry();

    print('Code generation complete!');
  }

  Future<void> _generateSimpleTransliterators() async {
    final transliterators = [
      (
        'spaces',
        'Spaces',
        'Replace various space characters with plain whitespace.',
        'spaces.json'
      ),
      (
        'radicals',
        'Radicals',
        'Replace Kangxi radicals with equivalent CJK ideographs.',
        'radicals.json'
      ),
      (
        'mathematical_alphanumerics',
        'MathematicalAlphanumerics',
        'Replace mathematical alphanumeric symbols with plain characters.',
        'mathematical-alphanumerics.json'
      ),
      (
        'ideographic_annotations',
        'IdeographicAnnotations',
        'Replace ideographic annotation marks used in traditional translation.',
        'ideographic-annotation-marks.json'
      ),
      (
        'kanji_old_new',
        'KanjiOldNew',
        'Replace old-style kanji with modern equivalents.',
        'kanji-old-new-form.json'
      ),
    ];

    for (final (identifier, className, description, dataFile)
        in transliterators) {
      await _generateSimpleTransliterator(
          identifier, className, description, dataFile);
    }

    // Generate complex transliterators
    await _generateHyphensTransliteratorData();
    await _generateIvsSvsBaseTransliteratorData();
    await _generateCombinedTransliterator();
    await _generateCircledOrSquaredTransliteratorData();
  }

  Future<void> _generateComplexTransliterators() async {
    // Complex transliterators will be implemented manually
  }

  Future<void> _generateSimpleTransliterator(
    String identifier,
    String className,
    String description,
    String dataFile,
  ) async {
    final dataPath = path.join(dataRoot, dataFile);
    final file = File(dataPath);
    if (!await file.exists()) {
      print('Warning: Data file not found: $dataPath');
      return;
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString);

    Map<String, String> mappings;
    if (identifier == 'kanji_old_new') {
      mappings = _convertKanjiOldNewData(data);
    } else {
      mappings = _convertDataToMappings(data as Map<String, dynamic>);
    }

    final output =
        _renderSimpleTransliterator(className, description, mappings);

    final filename = '${_snakeCase(identifier)}_transliterator.dart';
    final filepath = path.join(destRoot, filename);

    final destDir = Directory(destRoot);
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }

    await File(filepath).writeAsString(output);
    print('Generated: $filename');
  }

  Map<String, String> _convertDataToMappings(Map<String, dynamic> data) {
    final mappings = <String, String>{};
    for (final entry in data.entries) {
      final from = entry.key;
      final to = entry.value;

      final fromStr = from.startsWith('U+') ? from : 'U+$from';
      if (to == null) {
        mappings[_convertUnicodeNotation(fromStr)] = '';
      } else {
        final toStr = to.toString().startsWith('U+') ? to.toString() : 'U+$to';
        mappings[_convertUnicodeNotation(fromStr)] =
            _convertUnicodeNotation(toStr);
      }
    }
    return mappings;
  }

  Map<String, String> _convertKanjiOldNewData(dynamic data) {
    final mappings = <String, String>{};

    if (data is List) {
      for (final tuple in data) {
        if (tuple is List && tuple.length == 2) {
          final oldRecord = tuple[0];
          final newRecord = tuple[1];

          final oldChar = _convertIvsRecord(oldRecord);
          final newChar = _convertIvsRecord(newRecord);

          if (oldChar != null && newChar != null) {
            mappings[oldChar] = newChar;
          }
        }
      }
    }

    return mappings;
  }

  String? _convertIvsRecord(dynamic record) {
    if (record is Map && record['ivs'] is List) {
      final buffer = StringBuffer();
      for (final codepoint in record['ivs']) {
        if (codepoint is String) {
          buffer.write(_convertUnicodeNotation(codepoint));
        }
      }
      final result = buffer.toString();
      return result.isEmpty ? null : result;
    }
    return null;
  }

  int _unicodeToCodepoint(String unicode) {
    final match = RegExp(r'^U\+([0-9A-Fa-f]+)$').firstMatch(unicode);
    if (match != null) {
      return int.parse(match.group(1)!, radix: 16);
    }
    throw ArgumentError('Invalid Unicode notation: $unicode');
  }

  String _convertUnicodeNotation(String unicode) {
    return String.fromCharCode(_unicodeToCodepoint(unicode));
  }

  String _escapeString(String str) {
    final buffer = StringBuffer();
    for (final rune in str.runes) {
      if (rune > 127) {
        buffer.write('\\u{${rune.toRadixString(16)}}');
      } else {
        switch (rune) {
          case 0x22: // "
            buffer.write('\\"');
            break;
          case 0x5C: // \
            buffer.write('\\\\');
            break;
          case 0x0A: // \n
            buffer.write('\\n');
            break;
          case 0x0D: // \r
            buffer.write('\\r');
            break;
          case 0x09: // \t
            buffer.write('\\t');
            break;
          case 0x27: // '
            buffer.write("\\'");
            break;
          default:
            buffer.writeCharCode(rune);
            break;
        }
      }
    }
    return buffer.toString();
  }

  String _renderSimpleTransliterator(
    String className,
    String description,
    Map<String, String> mappings,
  ) {
    final buffer = StringBuffer();

    // Generate mappings
    // ignore: cascade_invocations
    buffer.writeln('  static const _mappings = <String, String>{');
    for (final entry in mappings.entries) {
      final from = _escapeString(entry.key);
      final to = _escapeString(entry.value);
      buffer.writeln("    '$from': '$to',");
    }
    buffer.writeln('  };');

    return '''
// GENERATED CODE - DO NOT MODIFY BY HAND

import '../char.dart';
import '../transliterator.dart';

/// $description
class ${className}Transliterator implements Transliterator {
${buffer.toString()}
  const ${className}Transliterator([Map<String, dynamic> options = const {}]);

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
''';
  }

  Future<void> _generateHyphensTransliteratorData() async {
    final dataPath = path.join(dataRoot, 'hyphens.json');
    final file = File(dataPath);
    if (!await file.exists()) {
      print('Warning: Hyphens data file not found: $dataPath');
      return;
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString) as List<dynamic>;

    final output = _renderHyphensTransliteratorData(data);

    final filename = 'hyphens_data.dart';
    final filepath = path.join(destRoot, filename);

    await File(filepath).writeAsString(output);
    print('Generated: $filename');
  }

  String _renderHyphensTransliteratorData(List<dynamic> data) {
    final buffer = StringBuffer();
    // ignore: cascade_invocations
    buffer
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln()
      ..writeln('/// Hyphens transliterator data.')
      ..writeln('const hyphensData = <String, Map<String, String?>>{');

    for (final record in data) {
      if (record is Map) {
        final codeChar = _convertUnicodeNotation(record['code']);
        final code = _escapeString(codeChar);

        buffer.writeln("  '$code': {");

        final mappings = [
          'ascii',
          'jisx0201',
          'jisx0208-1978',
          'jisx0208-1978-windows',
          'jisx0208-verbatim'
        ];
        for (final mapping in mappings) {
          final value = record[mapping];
          final key = mapping.replaceAll('-', '_').replaceAll('1978', '90');

          if (value != null) {
            String? convertedValue;
            if (value is List && value.isNotEmpty) {
              convertedValue = _convertUnicodeNotation(value[0]);
            } else if (value is String) {
              convertedValue = _convertUnicodeNotation(value);
            }

            if (convertedValue != null) {
              buffer.writeln("    '$key': '${_escapeString(convertedValue)}',");
            } else {
              buffer.writeln("    '$key': null,");
            }
          } else {
            buffer.writeln("    '$key': null,");
          }
        }

        buffer.writeln('  },');
      }
    }

    buffer.writeln('};');

    return buffer.toString();
  }

  Future<void> _generateIvsSvsBaseTransliteratorData() async {
    final dataPath = path.join(dataRoot, 'ivs-svs-base-mappings.json');
    final file = File(dataPath);
    if (!await file.exists()) {
      print('Warning: IVS/SVS data file not found: $dataPath');
      return;
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString) as List<dynamic>;

    // Generate binary data file
    await _generateIvsSvsBinaryData(data);
  }

  Future<void> _generateIvsSvsBinaryData(List<dynamic> data) async {
    final outputPath = path.join(destRoot, 'ivs_svs_base.data.dart');

    final buffer = BytesBuilder();

    // Write record count
    // ignore: cascade_invocations
    buffer.add(_int32ToBytes(data.length));

    for (final record in data) {
      if (record is Map) {
        // IVS (2 ints)
        var ivsCodepoint1 = 0;
        var ivsCodepoint2 = 0;
        if (record['ivs'] is List) {
          final ivs = record['ivs'] as List;
          if (ivs.isNotEmpty) {
            ivsCodepoint1 = _unicodeToCodepoint(ivs[0]);
            if (ivs.length >= 2) {
              ivsCodepoint2 = _unicodeToCodepoint(ivs[1]);
            }
          }
        }
        buffer
          ..add(_int32ToBytes(ivsCodepoint1))
          ..add(_int32ToBytes(ivsCodepoint2));

        // SVS (2 ints)
        var svsCodepoint1 = 0;
        var svsCodepoint2 = 0;
        if (record['svs'] is List) {
          final svs = record['svs'] as List;
          if (svs.isNotEmpty) {
            svsCodepoint1 = _unicodeToCodepoint(svs[0]);
            if (svs.length >= 2) {
              svsCodepoint2 = _unicodeToCodepoint(svs[1]);
            }
          }
        }
        buffer
          ..add(_int32ToBytes(svsCodepoint1))
          ..add(_int32ToBytes(svsCodepoint2));

        // Base90 (1 int)
        final base90Codepoint = record['base90'] != null
            ? _unicodeToCodepoint(record['base90'])
            : 0;
        buffer.add(_int32ToBytes(base90Codepoint));

        // Base2004 (1 int)
        final base2004Codepoint = record['base2004'] != null
            ? _unicodeToCodepoint(record['base2004'])
            : 0;
        buffer.add(_int32ToBytes(base2004Codepoint));
      }
    }

    final base64Bytes =
        base64Encode(ZLibEncoder().encodeBytes(buffer.toBytes()));

    final output = '''
// GENERATED CODE - DO NOT MODIFY BY HAND

final data =
    '$base64Bytes';
''';

    await File(outputPath).writeAsString(output);

    print('Generated data file: $outputPath');
  }

  Uint8List _int32ToBytes(int value) {
    final buffer = Uint8List(4);
    buffer[0] = (value >> 24) & 0xFF;
    buffer[1] = (value >> 16) & 0xFF;
    buffer[2] = (value >> 8) & 0xFF;
    buffer[3] = value & 0xFF;
    return buffer;
  }

  Future<void> _generateCombinedTransliterator() async {
    final dataPath = path.join(dataRoot, 'combined-chars.json');
    final file = File(dataPath);
    if (!await file.exists()) {
      print('Warning: Combined data file not found: $dataPath');
      return;
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString) as Map<String, dynamic>;

    final mappings = <String, List<String>>{};
    for (final entry in data.entries) {
      final fromChar = _convertUnicodeNotation(entry.key);
      final toChars = entry.value
          .toString()
          .runes
          .map((r) => String.fromCharCode(r))
          .toList();
      mappings[fromChar] = toChars;
    }

    final output = _renderCombinedTransliterator(mappings);

    final filename = 'combined_transliterator.dart';
    final filepath = path.join(destRoot, filename);

    await File(filepath).writeAsString(output);
    print('Generated: $filename');
  }

  String _renderCombinedTransliterator(Map<String, List<String>> mappings) {
    final buffer = StringBuffer();
    // ignore: cascade_invocations
    buffer.writeln('  static const _mappings = <String, List<String>>{');
    for (final entry in mappings.entries) {
      final from = _escapeString(entry.key);
      final toList = entry.value.map((s) => "'${_escapeString(s)}'").join(', ');
      buffer.writeln("    '$from': [$toList],");
    }
    buffer.writeln('  };');

    return '''
// GENERATED CODE - DO NOT MODIFY BY HAND

import '../char.dart';
import '../transliterator.dart';

/// Replace single characters with arrays of characters.
class CombinedTransliterator implements Transliterator {
${buffer.toString()}
  const CombinedTransliterator([Map<String, dynamic> options = const {}]);

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    var offset = 0;
    for (final char in inputChars) {
      final replacement = _mappings[char.c];
      if (replacement != null) {
        for (final replacementChar in replacement) {
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
''';
  }

  Future<void> _generateCircledOrSquaredTransliteratorData() async {
    final dataPath = path.join(dataRoot, 'circled-or-squared.json');
    final file = File(dataPath);
    if (!await file.exists()) {
      print('Warning: Circled-or-squared data file not found: $dataPath');
      return;
    }

    final jsonString = await file.readAsString();
    final data = json.decode(jsonString) as Map<String, dynamic>;

    final output = _renderCircledOrSquaredTransliteratorData(data);

    final filename = 'circled_or_squared_data.dart';
    final filepath = path.join(destRoot, filename);

    await File(filepath).writeAsString(output);
    print('Generated: $filename');
  }

  String _renderCircledOrSquaredTransliteratorData(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    // ignore: cascade_invocations
    buffer
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln()
      ..writeln('/// Circled or squared transliterator data.')
      ..writeln('const circledOrSquaredData = <String, Map<String, dynamic>>{');

    for (final entry in data.entries) {
      final fromChar = _convertUnicodeNotation(entry.key);
      final from = _escapeString(fromChar);
      final record = entry.value as Map<String, dynamic>;

      final rendering = _escapeString(record['rendering'] ?? '');
      final type = record['type'] ?? '';
      final emoji = record['emoji'] == true;

      buffer
        ..writeln("  '$from': {")
        ..writeln("    'rendering': '$rendering',")
        ..writeln("    'type': '$type',")
        ..writeln("    'emoji': $emoji,")
        ..writeln('  },');
    }

    buffer.writeln('};');

    return buffer.toString();
  }

  String _snakeCase(String s) {
    return s
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst(RegExp(r'^_'), '');
  }

  Future<void> _generateRegistry() async {
    // List of generated transliterators
    final generatedTransliterators = [
      ('spaces', 'SpacesTransliterator'),
      ('radicals', 'RadicalsTransliterator'),
      ('mathematicalAlphanumerics', 'MathematicalAlphanumericsTransliterator'),
      ('ideographicAnnotations', 'IdeographicAnnotationsTransliterator'),
      ('kanjiOldNew', 'KanjiOldNewTransliterator'),
      ('combined', 'CombinedTransliterator'),
    ];

    final buffer = StringBuffer();

    // File header
    // ignore: cascade_invocations
    buffer
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln()
      ..writeln('import \'transliterator_registry.dart\';');

    // Imports for generated transliterators
    for (final (identifier, _) in generatedTransliterators) {
      final filename = _snakeCase(identifier);
      buffer.writeln(
          'import \'transliterators/${filename}_transliterator.dart\';');
    }

    buffer
      ..writeln()
      ..writeln(
          '/// Register all generated transliterators with the given registry.')
      ..writeln(
          'void registerGeneratedTransliterators(TransliteratorRegistry registry) {')
      ..writeln('  registry');

    // Register each transliterator
    for (int i = 0; i < generatedTransliterators.length; i++) {
      final (identifier, className) = generatedTransliterators[i];
      if (i == generatedTransliterators.length - 1) {
        buffer.writeln(
            '    ..register(\'$identifier\', (options) => $className());');
      } else {
        buffer.writeln(
            '    ..register(\'$identifier\', (options) => $className())');
      }
    }

    buffer.writeln('}');

    // Write the file
    final registryPath =
        path.join(path.dirname(destRoot), 'generated_registry.dart');
    await File(registryPath).writeAsString(buffer.toString());
    print('Generated: generated_registry.dart');
  }
}

Future<void> main() async {
  final generator = YosinaCodeGenerator();
  await generator.generate();
}
