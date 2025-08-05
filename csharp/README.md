# Yosina C#

A C# port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a transliteration library that specifically deals with the letters and symbols used in Japanese writing.

## Usage

### Using Recipes (Recommended)

```csharp
using Yosina;

// Create a recipe with desired transformations
var recipe = new TransliterationRecipe
{
    KanjiOldNew = true,
    ReplaceSpaces = true,
    ReplaceSuspiciousHyphensToProlongedSoundMarks = true,
    ReplaceCircledOrSquaredCharacters = TransliterationRecipe.ReplaceCircledOrSquaredCharactersOptions.Enabled,
    ReplaceCombinedCharacters = true,
    HiraKata = "hira-to-kata",  // Convert hiragana to katakana
    ReplaceJapaneseIterationMarks = true,  // Expand iteration marks
    ToFullwidth = TransliterationRecipe.ToFullwidthOptions.Enabled
};

// Create the transliterator
var transliterator = Entrypoint.MakeTransliterator(recipe);

// Use it with various special characters
var input = "①②③　ⒶⒷⒸ　㍿㍑㌠㋿"; // circled numbers, letters, ideographic space, combined characters
var result = transliterator(input);
Console.WriteLine(result); // "（１）（２）（３）　（Ａ）（Ｂ）（Ｃ）　株式会社リットルサンチーム令和"

// Convert old kanji to new
var oldKanji = "舊字體";
result = transliterator(oldKanji);
Console.WriteLine(result); // "旧字体"

// Convert half-width katakana to full-width
var halfWidth = "ﾃｽﾄﾓｼﾞﾚﾂ";
result = transliterator(halfWidth);
Console.WriteLine(result); // "テストモジレツ"

// Demonstrate hiragana to katakana conversion with iteration marks
var mixedText = "学問のすゝめ";
result = transliterator(mixedText);
Console.WriteLine(result); // "学問ノススメ"
```

### Using Direct Configuration

```csharp
using Yosina;

// Configure with direct transliterator configs
var configs = new[]
{
    new TransliteratorConfig("kanji-old-new"),
    new TransliteratorConfig("spaces"),
    new TransliteratorConfig("prolonged-sound-marks"),
    new TransliteratorConfig("circled-or-squared"),
    new TransliteratorConfig("combined")
};

var transliterator = Entrypoint.MakeTransliterator(configs);
var result = transliterator("some japanese text");
Console.WriteLine(result);
```

### Advanced Usage with Options

```csharp
using Yosina;
using Yosina.Transliterators;

// Use with specific options
var jisTransliterator = Entrypoint.MakeTransliterator(
    new TransliteratorConfig("jisx0201-and-alike", new Jisx0201AndAlikeTransliterator.Options
    {
        FullwidthToHalfwidth = true,
        ConvertGL = true
    })
);

var jisResult = jisTransliterator("Ｈｅｌｌｏ　Ｗｏｒｌｄ！"); // Full-width ASCII
Console.WriteLine(jisResult); // "Hello World!"
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

## Development

### Projects

- **Yosina**: Main library containing core transliterators and generated code
- **Yosina.Tests**: Unit tests for the library
- **Yosina.Codegen**: Code generation tool for creating transliterators from JSON data

### Code Generation

The C# implementation includes a code generation system that creates transliterator classes from JSON data files in the `../data` directory.

### Running Code Generation

```bash
dotnet run --project src/Yosina.Codegen
```

### Building and Testing

#### Build the solution:
```bash
dotnet build
```

#### Run tests:
```bash
dotnet test
```

### Create NuGet package:

```bash
dotnet pack
```

### Format Code

```bash
dotnet format
```

### Linting

```bash
dotnet format --verify-no-changes
```
