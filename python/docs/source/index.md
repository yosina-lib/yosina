# Yosina

Yosina is a transliteration library that specifically deals with the letters and symbols used in Japanese writing. Japanese has a long history with its unique writing system which not only incorporates different kinds of characters, such as those from Chinese and English, but is also influenced by various writing systems, including German and French. There also lie quite complicated consequences in the Japanese standards of coded character sets, which is still causing uncertainties even after the Unicode standard was deployed widely.

The name "Yosina" is taken from the old Japanese adverb "Yoshina-ni", which means suitably, appropriately, or "as you think best". Developers tackling Japanese texts should have always wondered why that many variations exist for the same letter, and once wished there would be a thing that lets them forget all the gotchas. Yosina was named in the hope it will be a way for the developers to better handle such texts.

Yosina can handle various Japanese text transformations including:

- **Conversion between half-width and full-width**: Convert half-width katakana and symbols to their full-width counterparts, and vice versa.

    ![Conversion example](_static/assets/conversion-example1.svg)

    ![Conversion example](_static/assets/conversion-example2.svg)

- **Visually-ambiguous character handling**: Contextually replace hyphen-minuses between katakana/hiragana with long-vowel marks and vice versa.

    ![Conversion example](_static/assets/conversion-example3.svg)

    ![Conversion example](_static/assets/conversion-example4.svg)

- **Old-style to new-style kanji conversion**: Transform old-style glyphs (旧字体; kyu-ji-tai) to modern forms (新字体; shin-ji-tai).

    ![Conversion example](_static/assets/conversion-example5.svg)

Additionally, Yosina supports:

- **CJK radicals normalization**: Convert Kangxi radicals to equivalent CJK ideographs
- **Space normalization**: Standardize various space characters
- **Ideographic annotation replacement**: Handle traditional Chinese-to-Japanese translation marks
- **Hiragana/Katakana composition**: Combine decomposed characters into composed forms
- **IVS/SVS handling**: Process Ideographic and Standardized Variation Sequences
- **Mathematical alphanumeric symbols**: Normalize mathematical notation characters


```{toctree}
:maxdepth: 2
:caption: Contents:

api
```
