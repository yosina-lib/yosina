# Yosina C#

A C# port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a transliteration library that specifically deals with the letters and symbols used in Japanese writing.

## Usage

### Using Recipes (Recommended)

```csharp
using Yosina;

// Create a recipe with desired transformations
var recipe = new TransliteratorRecipe
{
    KanjiOldNew = true,
    ReplaceSpaces = true,
    ReplaceSuspiciousHyphensToProlongedSoundMarks = true,
    ReplaceCircledOrSquaredCharacters = TransliteratorRecipe.ReplaceCircledOrSquaredCharactersOptions.Enabled,
    ReplaceCombinedCharacters = true,
    ToFullwidth = TransliteratorRecipe.ToFullwidthOptions.Enabled
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
    new TransliteratorConfig("jisx0201-and-alike", new JisX0201AndAlikeTransliterator.Options
    {
        FullwidthToHalfwidth = true,
        ConvertGL = true
    })
);

var jisResult = jisTransliterator("Ｈｅｌｌｏ　Ｗｏｒｌｄ！"); // Full-width ASCII
Console.WriteLine(jisResult); // "Hello World!"
```

## Available Transliterators

### jisx0201-and-alike

Handles conversion between fullwidth and halfwidth characters based on JIS X 0201 character encoding standards. This transliterator is essential for normalizing Japanese text that may contain a mix of fullwidth and halfwidth characters.

**Features:**
- Converts between fullwidth ASCII/Latin characters (U+FF01-U+FF5E) and halfwidth ASCII (U+0020-U+007E)
- Handles fullwidth/halfwidth Katakana conversion
- Optionally converts Hiragana to halfwidth Katakana
- Manages voiced sound marks (dakuten/handakuten) with optional combination
- Handles special symbols with various override options

**Example:**
```csharp
using Yosina;
using Yosina.Transliterators;

// Configure for fullwidth to halfwidth conversion
var options = new JisX0201AndAlikeTransliterator.Options
{
    FullwidthToHalfwidth = true,      // Convert fullwidth → halfwidth (default: true)
    ConvertGL = true,                  // Convert ASCII/Latin characters (default: true)
    ConvertGR = true,                  // Convert Katakana characters (default: true)
    ConvertHiraganas = false,          // Convert Hiragana to halfwidth Katakana (default: false)
    CombineVoicedSoundMarks = true,    // Combine base + voiced marks (default: true)
    ConvertUnsafeSpecials = false,     // Convert special punctuation (default: false)
    // Ambiguous character handling
    U005cAsYenSign = false,            // Treat backslash as yen sign
    U007eAsWaveDash = true,            // Treat tilde as wave dash
    U00a5AsYenSign = true              // Treat ¥ as yen sign
};

var transliterator = Entrypoint.MakeTransliterator(
    new TransliteratorConfig("jisx0201-and-alike", options)
);

// Fullwidth to halfwidth conversion
Console.WriteLine(transliterator("ＡＢＣ１２３"));  // "ABC123"
Console.WriteLine(transliterator("カタカナ"));       // "ｶﾀｶﾅ"
Console.WriteLine(transliterator("ガギグゲゴ"));     // "ｶﾞｷﾞｸﾞｹﾞｺﾞ"

// Reverse direction (halfwidth to fullwidth)
var reverseOptions = new JisX0201AndAlikeTransliterator.Options
{
    FullwidthToHalfwidth = false
};
var reverseTransliterator = Entrypoint.MakeTransliterator(
    new TransliteratorConfig("jisx0201-and-alike", reverseOptions)
);
Console.WriteLine(reverseTransliterator("ｶﾀｶﾅ ABC"));  // "カタカナ　ＡＢＣ"
```

### ivs-svs-base

Handles Ideographic Variation Sequences (IVS) and Standardized Variation Sequences (SVS) for CJK characters, particularly Japanese Kanji. This is crucial for proper display and normalization of Japanese text variants.

**Features:**
- Adds or removes IVS/SVS selectors to/from base Kanji characters
- Supports different Japanese Industrial Standards (JIS) versions
- Handles variation selectors U+FE00-U+FE0F and U+E0100-U+E01EF
- Essential for text normalization and consistent display across systems

**Example:**
```csharp
using Yosina;
using Yosina.Transliterators;

// Add IVS/SVS selectors to base characters
var addOptions = new IvsSvsBaseTransliterator.Options
{
    Mode = IvsSvsBaseTransliterator.Mode.IvsOrSvs,           // Add selectors (default)
    Charset = IvsSvsBaseTransliterator.Charset.Unijis2004,   // Use JIS 2004 mappings (default)
    PreferSvs = false                                         // Prefer SVS over IVS when both exist (default: false)
};

var addTransliterator = Entrypoint.MakeTransliterator(
    new TransliteratorConfig("ivs-svs-base", addOptions)
);

// Example: Add variation selector to differentiate kanji variants
var baseKanji = "辻";
var withVariant = addTransliterator(baseKanji);  // Adds appropriate variation selector

// Remove IVS/SVS selectors from characters
var removeOptions = new IvsSvsBaseTransliterator.Options
{
    Mode = IvsSvsBaseTransliterator.Mode.Base,         // Remove selectors
    Charset = IvsSvsBaseTransliterator.Charset.Unijis90,  // Use JIS 90 mappings
    DropSelectorsAltogether = true                      // Remove all selectors even if not in mapping
};

var removeTransliterator = Entrypoint.MakeTransliterator(
    new TransliteratorConfig("ivs-svs-base", removeOptions)
);

// Remove variation selectors to get base character
var kanjiWithSelector = "辻\uE0100";  // Kanji with IVS selector
var baseOnly = removeTransliterator(kanjiWithSelector);  // "辻" (base character only)
```

### Other Available Transliterators

- `kanji-old-new`: Converts old kanji forms to new kanji forms
- `spaces`: Normalizes various space characters
- `prolonged-sound-marks`: Handles prolonged sound marks (ー)
- `circled-or-squared`: Converts circled/squared characters to their base forms
- `combined`: Expands combined characters (e.g., ㍿ → 株式会社)
- `hira-kata-composition`: Combines hiragana/katakana with voiced marks
- `hyphens`: Normalizes hyphen-like characters
- `ideographic-annotations`: Handles ideographic annotation marks
- `mathematical-alphanumerics`: Normalizes mathematical notation
- `radicals`: Converts Kangxi radicals to equivalent ideographs

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
