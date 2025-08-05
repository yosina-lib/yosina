import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import '../char.dart';
import '../transliterator.dart';

/// IVS/SVS base transliterator.
///
/// This transliterator handles Ideographic Variation Sequences (IVS) and
/// Standardized Variation Sequences (SVS) by either adding or removing variation selectors.
class IvsSvsBaseTransliterator implements Transliterator {
  IvsSvsBaseTransliterator({
    this.mode = 'base',
    this.charset = 'unijis_2004',
    this.preferSvs = false,
    this.dropSelectorsAltogether = false,
  }) {
    _loadDataIfNeeded();
  }
  static const _recordSize = 24; // 6 integers * 4 bytes each
  static List<_IvsSvsRecord>? _records;
  static bool _dataLoaded = false;

  // Options
  final String mode; // "base" or "ivs-or-svs"
  final String charset; // "unijis_90" or "unijis_2004"
  final bool preferSvs;
  final bool dropSelectorsAltogether;

  static void _loadDataIfNeeded() {
    if (_dataLoaded) return;

    try {
      // Try to load the binary data file
      final scriptPath = Platform.script.toFilePath();
      final libPath = path.dirname(path.dirname(scriptPath));
      final dataPath =
          path.join(libPath, 'src', 'transliterators', 'ivs_svs_base.data');

      final file = File(dataPath);
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        _records = _parseData(bytes);
      } else {
        // If data file doesn't exist, use empty records
        _records = [];
      }
    } catch (e) {
      // If loading fails, use empty records
      _records = [];
    }

    _dataLoaded = true;
  }

  static List<_IvsSvsRecord> _parseData(Uint8List bytes) {
    final byteData = ByteData.view(bytes.buffer);
    final recordCount = byteData.getUint32(0);
    final records = <_IvsSvsRecord>[];

    var offset = 4;
    for (var i = 0; i < recordCount; i++) {
      final ivs1 = byteData.getUint32(offset);
      final ivs2 = byteData.getUint32(offset + 4);
      final svs1 = byteData.getUint32(offset + 8);
      final svs2 = byteData.getUint32(offset + 12);
      final base90 = byteData.getUint32(offset + 16);
      final base2004 = byteData.getUint32(offset + 20);

      records.add(_IvsSvsRecord(
        ivs: [ivs1, ivs2],
        svs: [svs1, svs2],
        base90: base90,
        base2004: base2004,
      ));

      offset += _recordSize;
    }

    return records;
  }

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    // If dropSelectorsAltogether is true, we need to process even without records
    if ((_records == null || _records!.isEmpty) && !dropSelectorsAltogether) {
      yield* inputChars;
      return;
    }

    if (mode == 'base') {
      yield* _toBase(inputChars);
    } else {
      yield* _toIvsOrSvs(inputChars);
    }
  }

  Iterable<Char> _toBase(Iterable<Char> inputChars) sync* {
    var offset = 0;
    final iterator = inputChars.iterator;
    Char? pending;

    while (pending != null || iterator.moveNext()) {
      final char = pending ?? iterator.current;
      pending = null;

      if (dropSelectorsAltogether) {
        // Check if this is a variation selector
        if (_isVariationSelector(char.c)) {
          continue; // Skip the selector
        }
      }

      var matched = false;

      // Check if this character starts an IVS or SVS sequence
      if (iterator.moveNext()) {
        final nextChar = iterator.current;

        // Check if next character is a variation selector
        if (_isVariationSelector(nextChar.c)) {
          if (dropSelectorsAltogether) {
            // When dropping selectors altogether, just yield the base character
            yield char.withOffset(offset);
            offset += char.c.length;
            matched = true;
            // nextChar is already consumed, no need to set pending
          } else {
            final codepoint1 = char.c.isNotEmpty ? char.c.codeUnitAt(0) : 0;
            final codepoint2 =
                nextChar.c.isNotEmpty ? nextChar.c.codeUnitAt(0) : 0;

            // Look for matching record
            if (_records != null) {
              for (final record in _records!) {
                if ((record.ivs[0] == codepoint1 &&
                        record.ivs[1] == codepoint2) ||
                    (record.svs[0] == codepoint1 &&
                        record.svs[1] == codepoint2)) {
                  // Found a match, replace with base character
                  final baseCodepoint = charset == 'unijis_2004'
                      ? record.base2004
                      : record.base90;
                  if (baseCodepoint > 0) {
                    final replacement = String.fromCharCode(baseCodepoint);
                    yield Char(replacement, offset, char);
                    offset += replacement.length;
                    matched = true;
                    break;
                  }
                }
              }
            }

            if (!matched) {
              // No matching record found, save nextChar for next iteration
              pending = nextChar;
            }
          }
        } else {
          // Next char is not a variation selector, save it for next iteration
          pending = nextChar;
        }
      }

      if (!matched) {
        yield char.withOffset(offset);
        offset += char.c.length;
      }
    }
  }

  Iterable<Char> _toIvsOrSvs(Iterable<Char> inputChars) sync* {
    var offset = 0;

    for (final char in inputChars) {
      var matched = false;
      final codepoint = char.c.isNotEmpty ? char.c.codeUnitAt(0) : 0;

      // Look for a record with matching base character
      if (_records != null) {
        for (final record in _records!) {
          final baseCodepoint =
              charset == 'unijis_2004' ? record.base2004 : record.base90;

          if (baseCodepoint == codepoint) {
            // Found a match, add variation selector
            int selector1, selector2;

            if (preferSvs && record.svs[0] > 0) {
              selector1 = record.svs[0];
              selector2 = record.svs[1];
            } else if (record.ivs[0] > 0) {
              selector1 = record.ivs[0];
              selector2 = record.ivs[1];
            } else if (record.svs[0] > 0) {
              selector1 = record.svs[0];
              selector2 = record.svs[1];
            } else {
              continue;
            }

            // Yield the base character
            yield char.withOffset(offset);
            offset += char.c.length;

            // Yield the variation selector(s)
            final selector1Char = String.fromCharCode(selector1);
            yield Char(selector1Char, offset, char);
            offset += selector1Char.length;

            if (selector2 > 0) {
              final selector2Char = String.fromCharCode(selector2);
              yield Char(selector2Char, offset, char);
              offset += selector2Char.length;
            }

            matched = true;
            break;
          }
        }
      }

      if (!matched) {
        yield char.withOffset(offset);
        offset += char.c.length;
      }
    }
  }

  bool _isVariationSelector(String char) {
    if (char.isEmpty) return false;
    final codepoint = char.codeUnitAt(0);

    // IVS range: U+E0100 to U+E01EF
    // SVS range: U+FE00 to U+FE0F
    // Additional selectors: U+E0100 to U+E01EF
    return (codepoint >= 0xFE00 && codepoint <= 0xFE0F) ||
        (codepoint >= 0xE0100 && codepoint <= 0xE01EF);
  }
}

class _IvsSvsRecord {
  const _IvsSvsRecord({
    required this.ivs,
    required this.svs,
    required this.base90,
    required this.base2004,
  });
  final List<int> ivs;
  final List<int> svs;
  final int base90;
  final int base2004;
}
