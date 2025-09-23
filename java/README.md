# Yosina Java

A Java port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a library for Japanese text transliteration that provides various text normalization and conversion features commonly needed when processing Japanese text.

## Usage

### Using Recipes (Recommended)

```java
import io.yosina.Yosina;
import io.yosina.TransliterationRecipe;
import java.util.function.Function;

// Create a recipe with desired transformations
TransliterationRecipe recipe = new TransliterationRecipe()
    .withKanjiOldNew(true)
    .withReplaceSpaces(true)
    .withReplaceSuspiciousHyphensToProlongedSoundMarks(true)
    .withReplaceCircledOrSquaredCharacters(
        TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.ENABLED)
    .withReplaceCombinedCharacters(true)
    .withHiraKata("hira-to-kata")  // Convert hiragana to katakana
    .withReplaceJapaneseIterationMarks(true)  // Expand iteration marks
    .withToFullwidth(TransliterationRecipe.ToFullwidthOptions.ENABLED);

// Create the transliterator
Function<String, String> transliterator = Yosina.makeTransliterator(recipe);

// Use it with various special characters
String input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"; // circled numbers, letters, space, combined characters
String result = transliterator.apply(input);
System.out.println(result); // "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

// Convert old kanji to new
String oldKanji = "舊字體";
result = transliterator.apply(oldKanji);
System.out.println(result); // "旧字体"

// Convert half-width katakana to full-width
String halfWidth = "ﾃｽﾄﾓｼﾞﾚﾂ";
result = transliterator.apply(halfWidth);
System.out.println(result); // "テストモジレツ"

// Demonstrate hiragana to katakana conversion with iteration marks
String mixedText = "学問のすゝめ";
result = transliterator.apply(mixedText);
System.out.println(result); // "学問ノススメ"
```

### Using Direct Configuration

```java
import io.yosina.Yosina;
import java.util.List;
import java.util.function.Function;

// Configure with direct transliterator configs
List<Yosina.TransliteratorConfig> configs = List.of(
    new Yosina.TransliteratorConfig("kanji-old-new"),
    new Yosina.TransliteratorConfig("spaces"),
    new Yosina.TransliteratorConfig("prolonged-sound-marks"),
    new Yosina.TransliteratorConfig("circled-or-squared"),
    new Yosina.TransliteratorConfig("combined")
);

Function<String, String> transliterator = Yosina.makeTransliterator(configs);
String result = transliterator.apply("some japanese text");
```

## Requirements

- Java 17 or higher

## Installation

### Gradle

```gradle
dependencies {
    implementation 'io.yosina:yosina:0.2.0'
}
```

## Available Transliterators

### 1. **Circled or Squared** (`circled-or-squared`)
Converts circled or squared characters to their plain equivalents.
- Options: `templates` (custom rendering), `includeEmojis` (include emoji characters)
- Example: `①②③` → `(1)(2)(3)`, `㊙㊗` → `(秘)(祝)`

### 2. **Combined** (`combined`)
Expands combined characters into their individual character sequences.
- Example: `㍻` (Heisei era) → `平成`, `㈱` → `(株)`

### 3. **Hiragana-Katakana Composition** (`hira-kata-composition`)
Combines decomposed hiraganas and katakanas into composed equivalents.
- Options: `composeNonCombiningMarks` (compose non-combining marks)
- Example: `か + ゙` → `が`, `ヘ + ゜` → `ペ`

### 4. **Hiragana-Katakana** (`hira-kata`)
Converts between hiragana and katakana scripts bidirectionally.
- Options: `mode` ("hira-to-kata" or "kata-to-hira")
- Example: `ひらがな` → `ヒラガナ` (hira-to-kata)

### 5. **Hyphens** (`hyphens`)
Replaces various dash/hyphen symbols with common ones used in Japanese.
- Options: `precedence` (mapping priority order)
- Available mappings: "ascii", "jisx0201", "jisx0208_90", "jisx0208_90_windows", "jisx0208_verbatim"
- Example: `2019—2020` (em dash) → `2019-2020`

### 6. **Ideographic Annotations** (`ideographic-annotations`)
Replaces ideographic annotations used in traditional Chinese-to-Japanese translation.
- Example: `㆖㆘` → `上下`

### 7. **IVS-SVS Base** (`ivs-svs-base`)
Handles Ideographic and Standardized Variation Selectors.
- Options: `charset`, `mode` ("ivs-or-svs" or "base"), `preferSVS`, `dropSelectorsAltogether`
- Example: `葛󠄀` (葛 + IVS) → `葛`

### 8. **Japanese Iteration Marks** (`japanese-iteration-marks`)
Expands iteration marks by repeating the preceding character.
- Example: `時々` → `時時`, `いすゞ` → `いすず`

### 9. **JIS X 0201 and Alike** (`jisx0201-and-alike`)
Handles half-width/full-width character conversion.
- Options: `fullwidthToHalfwidth`, `convertGL` (alphanumerics/symbols), `convertGR` (katakana), `u005cAsYenSign`
- Example: `ABC123` → `ＡＢＣ１２３`, `ｶﾀｶﾅ` → `カタカナ`

### 10. **Kanji Old-New** (`kanji-old-new`)
Converts old-style kanji (旧字体) to modern forms (新字体).
- Example: `舊字體の變換` → `旧字体の変換`

### 11. **Mathematical Alphanumerics** (`mathematical-alphanumerics`)
Normalizes mathematical alphanumeric symbols to plain ASCII.
- Example: `𝐀𝐁𝐂` (mathematical bold) → `ABC`

### 12. **Prolonged Sound Marks** (`prolonged-sound-marks`)
Handles contextual conversion between hyphens and prolonged sound marks.
- Options: `skipAlreadyTransliteratedChars`, `allowProlongedHatsuon`, `allowProlongedSokuon`, `replaceProlongedMarksFollowingAlnums`
- Example: `イ−ハト−ヴォ` (with hyphen) → `イーハトーヴォ` (prolonged mark)

### 13. **Radicals** (`radicals`)
Converts CJK radical characters to their corresponding ideographs.
- Example: `⾔⾨⾷` (Kangxi radicals) → `言門食`

### 14. **Spaces** (`spaces`)
Normalizes various Unicode space characters to standard ASCII space.
- Example: `A　B` (ideographic space) → `A B`

### 15. **Roman Numerals** (`roman-numerals`)
Converts Unicode Roman numeral characters to their ASCII letter equivalents.
- Example: `Ⅰ Ⅱ Ⅲ` → `I II III`, `ⅰ ⅱ ⅲ` → `i ii iii`

## Building from Source

Gradle 8.0 or higher is required to build the Java library.

```bash
git clone https://github.com/yosina-lib/yosina.git
cd yosina/java
gradle build
```

We don't bundle Gradle wrapper in the repository, so you need to have Gradle installed on your system.

### Code Generation

The Java implementation uses a code generation system to create transliterators from JSON data files:

```bash
# Generate transliterator source code
gradle :codegen:run

# Build the main library
gradle build
```

## Testing

```bash
gradle test
```

## API Documentation

The library provides a simple functional interface through the `Yosina` class:

### `Yosina.makeTransliterator(String name)`
Creates a transliterator function with default options.

### `Yosina.makeTransliterator(String name, Object options)`
Creates a transliterator function with custom options.

### `Yosina.makeTransliterator(List<TransliteratorConfig> configs)`
Creates a chained transliterator from multiple configurations.

### Low-level API

For more control, you can use the transliterator classes directly:

```java
import io.yosina.Chars;
import io.yosina.CharIterator;
import io.yosina.transliterators.HiraKataCompositionTransliterator;

HiraKataCompositionTransliterator transliterator = new HiraKataCompositionTransliterator();
CharIterator input = Chars.of("input text").iterator();
CharIterator result = transliterator.transliterate(input);
String output = result.string();
```

## License

MIT License. See the main project repository for details.

## Contributing

Contributions are welcome! Please ensure that any changes maintain compatibility with other language implementations and follow the existing code style.
