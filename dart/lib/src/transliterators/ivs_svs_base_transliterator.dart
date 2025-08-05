import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import '../char.dart';
import '../transliterator.dart';
import './charset.dart';
import './ivs_svs_base.data.dart';

/// IVS/SVS base transliterator.
///
/// This transliterator handles Ideographic Variation Sequences (IVS) and
/// Standardized Variation Sequences (SVS) by either adding or removing variation selectors.
class IvsSvsBaseTransliterator implements Transliterator {
  IvsSvsBaseTransliterator({
    this.mode = 'base',
    this.charset = Charset.unijis2004,
    this.preferSvs = false,
    this.dropSelectorsAltogether = false,
  });

  static List<_IvsSvsRecord>? _records;
  static Map<Charset, Map<String, String>> revMappingsCache = {};
  static Map<(Charset, bool), Map<String, String>> fwdMappingsCache = {};

  // Options
  final String mode; // "base" or "ivs-or-svs"
  final Charset charset;
  final bool preferSvs;
  final bool dropSelectorsAltogether;

  static List<_IvsSvsRecord> _getRecords() {
    if (_records != null) return _records!;
    final bytes = ZLibDecoder().decodeBytes(base64Decode(data));
    _records = _parseData(bytes);
    return _records!;
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
        ivs: String.fromCharCodes([ivs1, ivs2]),
        svs: svs1 != 0 ? String.fromCharCodes([svs1, svs2]) : null,
        base90: base90 != 0 ? String.fromCharCode(base90) : null,
        base2004: base2004 != 0 ? String.fromCharCode(base2004) : null,
      ));

      offset += 24;
    }

    return records;
  }

  Map<String, String> _getFwdMappings() {
    final key = (charset, preferSvs);
    var mappings = fwdMappingsCache[key];
    if (mappings != null) return mappings;
    mappings = <String, String>{};

    for (final record in _getRecords()) {
      final base =
          charset == Charset.unijis90 ? record.base90 : record.base2004;
      if (base != null) {
        if (record.svs != null && preferSvs) {
          mappings[base] = record.svs!;
        } else {
          mappings[base] = record.ivs;
        }
      }
    }
    fwdMappingsCache[key] = mappings;
    return mappings;
  }

  Map<String, String> _getRevMappings() {
    var mappings = revMappingsCache[charset];
    if (mappings != null) return mappings;
    mappings = <String, String>{};
    for (final record in _getRecords()) {
      final base =
          charset == Charset.unijis90 ? record.base90 : record.base2004;
      if (base != null) {
        mappings[record.ivs] = base;
        if (record.svs != null) {
          mappings[record.svs!] = base;
        }
      }
    }
    revMappingsCache[charset] = mappings;
    return mappings;
  }

  @override
  Iterable<Char> call(Iterable<Char> inputChars) sync* {
    if (mode == 'base') {
      yield* _toBase(inputChars);
    } else {
      yield* _toIvsOrSvs(inputChars);
    }
  }

  Iterable<Char> _toIvsOrSvs(Iterable<Char> inputChars) sync* {
    final mappings = _getFwdMappings();

    var offset = 0;
    for (final char in inputChars) {
      final replacement = mappings[char.c];
      if (replacement != null) {
        yield Char(replacement, offset, char);
        offset += replacement.length;
      } else {
        yield char.withOffset(offset);
        offset += char.c.length;
      }
    }
  }

  Iterable<Char> _toBase(Iterable<Char> inputChars) sync* {
    final mappings = _getRevMappings();

    var offset = 0;
    for (final char in inputChars) {
      final replacement = mappings[char.c];
      if (replacement != null) {
        // If we have a mapping, yield the base character
        yield Char(replacement, offset, char);
        offset += replacement.length;
      } else if (dropSelectorsAltogether && char.c.length > 1) {
        final c = String.fromCharCode(char.c.runes.first);
        yield Char(c, offset, char);
        offset += c.length;
      } else {
        yield char.withOffset(offset);
        offset += char.c.length;
      }
    }
  }
}

class _IvsSvsRecord {
  const _IvsSvsRecord({
    required this.ivs,
    required this.svs,
    required this.base90,
    required this.base2004,
  });
  final String ivs;
  final String? svs;
  final String? base90;
  final String? base2004;
}
