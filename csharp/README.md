# Yosina C#

A C# port of the Yosina Japanese text transliteration library.

## Overview

Yosina is a transliteration library that specifically deals with the letters and symbols used in Japanese writing.

## Usage

```csharp
using Yosina;
using Yosina.Transliterators;

// Simple usage with Entrypoint.MakeTransliterator
var transliterator = Entrypoint.MakeTransliterator(
    new TransliteratorConfig("spaces"),
    new TransliteratorConfig("circled-or-squared"),
    new TransliteratorConfig("hyphens")
);

var result = transliterator("Hello　World①②③"); // Full-width space and circled numbers
// Result: "Hello World123"

// Use individual transliterator
var spacesTransliterator = new SpacesTransliterator();
var input = "Hello　World"; // ideographic space
var charList = Characters.CharacterList(input);
var transliteratedChars = spacesTransliterator.Transliterate(charList);
var output = transliteratedChars.AsString();
// Result: "Hello World"

// Use with options
var jisTransliterator = Entrypoint.MakeTransliterator(
    new TransliteratorConfig("jisx0201-and-alike", new JisX0201AndAlikeTransliterator.Options
    {
        FullwidthToHalfwidth = true,
        ConvertGL = true
    })
);

var jisResult = jisTransliterator("Ｈｅｌｌｏ　Ｗｏｒｌｄ！"); // Full-width ASCII
// Result: "Hello World!"

// Chain multiple transliterators manually
var chain = new ChainedTransliterator(
    new SpacesTransliterator(),
    new CircledOrSquaredTransliterator(),
    new HyphensTransliterator()
);
var chainInput = Characters.CharacterList("Test　①②③");
var chainResult = chain.Transliterate(chainInput).AsString();
// Result: "Test 123"
```

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
