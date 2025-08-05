/// Represents different character set standards for Japanese text processing.
///
/// These character sets define which kanji characters and their variants
/// should be used during transliteration operations.
enum Charset {
  /// JIS90 (JIS X 0208:1990) character set standard.
  ///
  /// This standard uses the character forms established in 1990,
  /// which generally prefer traditional character variants.
  unijis90,

  /// JIS2004 (JIS X 0213:2004) character set standard.
  ///
  /// This is a more recent standard that includes additional characters
  /// and updated character forms compared to JIS90. It supports a wider
  /// range of kanji variants and is better suited for modern Japanese text.
  unijis2004,
}
