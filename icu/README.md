# ICU Transliterators for Yosina

This directory contains ICU (International Components for Unicode) transliteration rules that approximate the Yosina transliterators. These rule files can be used with ICU4C, ICU4J, or any other ICU implementation.

> **Important:** The ICU rules are a simplified, static approximation of the native Yosina implementations. Configuration options that exist in the native libraries are baked into fixed rule sets here. For applications requiring the full feature set, use the native implementations in the respective language directories.

## Structure

- `codegen/` - Python scripts for generating ICU rules from data files
- `rules/` - ICU transliteration rule files
- `tests/` - ICU4J-based test suite

## Transliterators

### Full-fidelity (no known behavioral differences)

These transliterators produce identical results to the native implementations under default options:

| Rule file | Description |
|---|---|
| `spaces.txt` | Replace various Unicode space characters with ASCII space |
| `radicals.txt` | Replace Kangxi radicals with equivalent CJK ideographs |
| `mathematical_alphanumerics.txt` | Replace mathematical alphanumeric symbols with plain characters |
| `ideographic_annotations.txt` | Replace ideographic annotation marks |
| `combined.txt` | Decompose combined characters (e.g. ㍿ → 株式会社) |
| `circled_or_squared.txt` | Decompose circled and squared characters |
| `hira_to_kata.txt` | Convert hiragana to katakana |
| `kata_to_hira.txt` | Convert katakana to hiragana |
| `roman_numerals.txt` | Decompose Unicode Roman numerals to ASCII letters (e.g. Ⅲ → III) |
| `small_hirakatas.txt` | Replace small kana with normal-sized equivalents (e.g. ァ → ア) |
| `archaic_hirakatas.txt` | Replace archaic kana (hentaigana) with modern equivalents |

### Generated from data with caveats

| Rule file | Description |
|---|---|
| `kanji_old_new.txt` | Replace old-style kanji with modern equivalents |
| `hyphens.txt` | Normalize various hyphen-like characters to ASCII hyphen |
| `ivs_svs_base_unijis_90.txt` | IVS/SVS to base character mappings (UniJIS-90) |
| `ivs_svs_base_unijis_2004.txt` | IVS/SVS to base character mappings (UniJIS-2004) |

**kanji_old_new** contains both IVS-tagged rules (base char + variation selector → target) and plain base character rules. The native implementations select the charset at runtime, while the ICU version includes both IVS-tagged and base-character mappings in a single file.

**hyphens** maps all hyphen-like characters to ASCII hyphen-minus (U+002D). The native implementation supports selecting from multiple target mappings (ASCII, JIS, etc.); the ICU version is hardcoded to the ASCII target.

**ivs_svs_base** is split into two separate rule files (one per charset). The native implementation selects the charset at runtime via a configuration option.

### Simplified transliterators (behavioral differences from native)

These transliterators have known behavioral differences due to ICU's rule-based engine limitations or simplification of configuration options.

#### `prolonged_sound_marks.txt`

Replaces hyphen-like characters with prolonged sound marks (ー/ｰ) after katakana.

| Difference | Native | ICU |
|---|---|---|
| Hiragana context | Replaces hyphens after hiragana vowels with ー | Does not replace after hiragana |
| `allow_prolonged_hatsuon` | Configurable — allows prolonging ん/ン/ﾝ | Not supported |
| `allow_prolonged_sokuon` | Configurable — allows prolonging っ/ッ/ｯ | Not supported |
| `skip_already_transliterated_chars` | Tracks transliteration history to avoid re-processing | Not possible in stateless ICU rules |
| `replace_prolonged_marks_following_alnums` | Configurable — replaces hyphens between alphanumerics | Not supported |

#### `japanese_iteration_marks.txt`

Replaces iteration marks (ゝ, ゞ, ヽ, ヾ, 々) with repeated characters.

| Difference | Native | ICU |
|---|---|---|
| Hatsuon before iteration mark | んゝ, ンヽ → left unchanged | んゝ → んん, ンヽ → ンン (over-matches) |
| Sokuon before iteration mark | っゝ, ッヽ → left unchanged | っゝ → っっ, ッヽ → ッッ (over-matches) |
| Semivoiced before iteration mark | ぱゝ, パヽ → left unchanged | ぱゝ → ぱぱ, パヽ → パパ (over-matches) |
| CJK Extensions B–G (々) | Supported (U+20000–U+3134F) | Not covered — only CJK Unified Ideographs (U+4E00–U+9FFF) and Extension A (U+3400–U+4DBF) |

#### `hira_kata_composition.txt`

Composes base characters with non-combining voiced/semi-voiced marks (゛ U+309B, ゜ U+309C). Combining marks (U+3099, U+309A) are intentionally not handled because ICU can compose those via standard NFC normalization. Chain with `::NFC;` to handle both types.

| Difference | Native | ICU |
|---|---|---|
| Default target | Combining marks (U+3099, U+309A) | Non-combining marks (゛ U+309B, ゜ U+309C) |
| `compose_non_combining_marks` | Opt-in via option | Always on (the only mode) |
| Combining marks | Always handled | Delegated to `::NFC;` — chain with `::NFC;` for full coverage |

#### `historical_hirakatas.txt`

Converts historical kana to modern equivalents. The ICU version implements only the "simple" conversion mode.

| Difference | Native | ICU |
|---|---|---|
| Hiragana mode | "simple" (ゐ→い), "decompose" (ゐ→うぃ), or "skip" | "simple" only |
| Katakana mode | "simple" (ヰ→イ), "decompose" (ヰ→ウィ), or "skip" | "simple" only |
| Voiced historical katakana | "decompose" (ヷ→ヴァ, ヸ→ヴィ, ヹ→ヴェ, ヺ→ヴォ) or "skip" | Always skipped (left unchanged) |

#### `jisx0201_and_alike.txt`

Converts fullwidth characters to halfwidth equivalents. The ICU version implements only the default forward (fullwidth → halfwidth) direction.

| Difference | Native | ICU |
|---|---|---|
| Direction | Bidirectional (`fullwidth_to_halfwidth` option) | Fullwidth → halfwidth only |
| `convert_hiraganas` | Configurable — converts hiragana to halfwidth katakana | Not supported (hiragana left unchanged) |
| `convert_gl` / `convert_gr` | Independently toggleable | Always converts both |
| Character overrides | 7 configurable overrides for U+005C, U+007E, U+00A5 handling | Hardcoded to defaults (`u005c_as_yen_sign`, `u007e_as_fullwidth_tilde`) |
| `combine_voiced_sound_marks` | Configurable in reverse direction | Not applicable (no reverse direction) |
| `convert_unsafe_specials` | Configurable | Not supported |

### Not implemented

The **recipe** system (chaining multiple transliterators into a pipeline) is not provided as a single ICU rule file. ICU's `CompoundTransliterator` can be used to chain individual rule files, but the Yosina recipe configuration (with its option propagation) is not replicated.

## Generating Rules

To regenerate the auto-generated ICU rules from the data files:

```bash
cd icu/codegen
python3 generate_icu_rules.py
```

This regenerates: `spaces`, `radicals`, `mathematical_alphanumerics`, `ideographic_annotations`, `kanji_old_new`, `hyphens`, `ivs_svs_base_*`, `combined`, `circled_or_squared`, `small_hirakatas`, `archaic_hirakatas`, and `roman_numerals`.

The following rule files are maintained manually: `prolonged_sound_marks`, `japanese_iteration_marks`, `hira_kata_composition`, `historical_hirakatas`.

The following are generated by one-off scripts (from `hira_kata_table.py` and `jisx0201_and_alike.py` tables): `hira_to_kata`, `kata_to_hira`, `jisx0201_and_alike`.

## Using ICU Rules

See [`examples/icu4c/`](../examples/icu4c/) and [`examples/icu4j/`](../examples/icu4j/) for complete, runnable examples.

### ICU4C (C++)

```cpp
#include <unicode/translit.h>
#include <unicode/unistr.h>
#include <fstream>
#include <sstream>
#include <memory>
#include <string>

std::string loadRules(const std::string& filename) {
    std::ifstream file(filename);
    std::stringstream buffer;
    buffer << file.rdbuf();
    return buffer.str();
}

// Create and use a single transliterator
UErrorCode status = U_ZERO_ERROR;
UParseError parseError;
icu::UnicodeString rules =
    icu::UnicodeString::fromUTF8(loadRules("rules/spaces.txt"));
std::unique_ptr<icu::Transliterator> trans(
    icu::Transliterator::createFromRules(
        "Spaces", rules, UTRANS_FORWARD, parseError, status));

icu::UnicodeString text = icu::UnicodeString::fromUTF8(u8"Hello\u3000World");
trans->transliterate(text);
// text is now "Hello World" with regular space
```

### ICU4J (Java)

```java
import com.ibm.icu.text.Transliterator;
import java.nio.file.Files;
import java.nio.file.Path;

String rules = Files.readString(Path.of("rules/spaces.txt"));
Transliterator trans = Transliterator.createFromRules(
    "Spaces", rules, Transliterator.FORWARD);

String result = trans.transliterate("Hello\u3000World");
// result is now "Hello World" with regular space
```

## Running Tests

```bash
cd icu/tests
gradle test
```

See `tests/README.md` for details.
