use serde::{Deserialize, Serialize};
use std::borrow::Cow;
use std::collections::HashMap;
use std::sync::{LazyLock, RwLock};

use crate::char::{Char, CharPool};
use crate::transliterator::{Transliterator, TransliteratorFactory};
use crate::{TransliterationError, TransliteratorFactoryError};

/// JIS X 0201 GL (Graphics Left) character mappings: fullwidth to halfwidth
static JISX0201_GL_TABLE: &[(&str, &str)] = &[
    ("\u{3000}", "\u{0020}"), // IDEOGRAPHIC SPACE -> SPACE
    ("\u{FF01}", "\u{0021}"), // FULLWIDTH EXCLAMATION MARK -> EXCLAMATION MARK
    ("\u{FF02}", "\u{0022}"), // FULLWIDTH QUOTATION MARK -> QUOTATION MARK
    ("\u{FF03}", "\u{0023}"), // FULLWIDTH NUMBER SIGN -> NUMBER SIGN
    ("\u{FF04}", "\u{0024}"), // FULLWIDTH DOLLAR SIGN -> DOLLAR SIGN
    ("\u{FF05}", "\u{0025}"), // FULLWIDTH PERCENT SIGN -> PERCENT SIGN
    ("\u{FF06}", "\u{0026}"), // FULLWIDTH AMPERSAND -> AMPERSAND
    ("\u{FF07}", "\u{0027}"), // FULLWIDTH APOSTROPHE -> APOSTROPHE
    ("\u{FF08}", "\u{0028}"), // FULLWIDTH LEFT PARENTHESIS -> LEFT PARENTHESIS
    ("\u{FF09}", "\u{0029}"), // FULLWIDTH RIGHT PARENTHESIS -> RIGHT PARENTHESIS
    ("\u{FF0A}", "\u{002A}"), // FULLWIDTH ASTERISK -> ASTERISK
    ("\u{FF0B}", "\u{002B}"), // FULLWIDTH PLUS SIGN -> PLUS SIGN
    ("\u{FF0C}", "\u{002C}"), // FULLWIDTH COMMA -> COMMA
    ("\u{FF0D}", "\u{002D}"), // FULLWIDTH HYPHEN-MINUS -> HYPHEN-MINUS
    ("\u{FF0E}", "\u{002E}"), // FULLWIDTH FULL STOP -> FULL STOP
    ("\u{FF0F}", "\u{002F}"), // FULLWIDTH SOLIDUS -> SOLIDUS
    ("\u{FF10}", "\u{0030}"), // FULLWIDTH DIGIT ZERO -> DIGIT ZERO
    ("\u{FF11}", "\u{0031}"), // FULLWIDTH DIGIT ONE -> DIGIT ONE
    ("\u{FF12}", "\u{0032}"), // FULLWIDTH DIGIT TWO -> DIGIT TWO
    ("\u{FF13}", "\u{0033}"), // FULLWIDTH DIGIT THREE -> DIGIT THREE
    ("\u{FF14}", "\u{0034}"), // FULLWIDTH DIGIT FOUR -> DIGIT FOUR
    ("\u{FF15}", "\u{0035}"), // FULLWIDTH DIGIT FIVE -> DIGIT FIVE
    ("\u{FF16}", "\u{0036}"), // FULLWIDTH DIGIT SIX -> DIGIT SIX
    ("\u{FF17}", "\u{0037}"), // FULLWIDTH DIGIT SEVEN -> DIGIT SEVEN
    ("\u{FF18}", "\u{0038}"), // FULLWIDTH DIGIT EIGHT -> DIGIT EIGHT
    ("\u{FF19}", "\u{0039}"), // FULLWIDTH DIGIT NINE -> DIGIT NINE
    ("\u{FF1A}", "\u{003A}"), // FULLWIDTH COLON -> COLON
    ("\u{FF1B}", "\u{003B}"), // FULLWIDTH SEMICOLON -> SEMICOLON
    ("\u{FF1C}", "\u{003C}"), // FULLWIDTH LESS-THAN SIGN -> LESS-THAN SIGN
    ("\u{FF1D}", "\u{003D}"), // FULLWIDTH EQUALS SIGN -> EQUALS SIGN
    ("\u{FF1E}", "\u{003E}"), // FULLWIDTH GREATER-THAN SIGN -> GREATER-THAN SIGN
    ("\u{FF1F}", "\u{003F}"), // FULLWIDTH QUESTION MARK -> QUESTION MARK
    ("\u{FF20}", "\u{0040}"), // FULLWIDTH COMMERCIAL AT -> COMMERCIAL AT
    ("\u{FF21}", "\u{0041}"), // FULLWIDTH LATIN CAPITAL LETTER A -> LATIN CAPITAL LETTER A
    ("\u{FF22}", "\u{0042}"), // FULLWIDTH LATIN CAPITAL LETTER B -> LATIN CAPITAL LETTER B
    ("\u{FF23}", "\u{0043}"), // FULLWIDTH LATIN CAPITAL LETTER C -> LATIN CAPITAL LETTER C
    ("\u{FF24}", "\u{0044}"), // FULLWIDTH LATIN CAPITAL LETTER D -> LATIN CAPITAL LETTER D
    ("\u{FF25}", "\u{0045}"), // FULLWIDTH LATIN CAPITAL LETTER E -> LATIN CAPITAL LETTER E
    ("\u{FF26}", "\u{0046}"), // FULLWIDTH LATIN CAPITAL LETTER F -> LATIN CAPITAL LETTER F
    ("\u{FF27}", "\u{0047}"), // FULLWIDTH LATIN CAPITAL LETTER G -> LATIN CAPITAL LETTER G
    ("\u{FF28}", "\u{0048}"), // FULLWIDTH LATIN CAPITAL LETTER H -> LATIN CAPITAL LETTER H
    ("\u{FF29}", "\u{0049}"), // FULLWIDTH LATIN CAPITAL LETTER I -> LATIN CAPITAL LETTER I
    ("\u{FF2A}", "\u{004A}"), // FULLWIDTH LATIN CAPITAL LETTER J -> LATIN CAPITAL LETTER J
    ("\u{FF2B}", "\u{004B}"), // FULLWIDTH LATIN CAPITAL LETTER K -> LATIN CAPITAL LETTER K
    ("\u{FF2C}", "\u{004C}"), // FULLWIDTH LATIN CAPITAL LETTER L -> LATIN CAPITAL LETTER L
    ("\u{FF2D}", "\u{004D}"), // FULLWIDTH LATIN CAPITAL LETTER M -> LATIN CAPITAL LETTER M
    ("\u{FF2E}", "\u{004E}"), // FULLWIDTH LATIN CAPITAL LETTER N -> LATIN CAPITAL LETTER N
    ("\u{FF2F}", "\u{004F}"), // FULLWIDTH LATIN CAPITAL LETTER O -> LATIN CAPITAL LETTER O
    ("\u{FF30}", "\u{0050}"), // FULLWIDTH LATIN CAPITAL LETTER P -> LATIN CAPITAL LETTER P
    ("\u{FF31}", "\u{0051}"), // FULLWIDTH LATIN CAPITAL LETTER Q -> LATIN CAPITAL LETTER Q
    ("\u{FF32}", "\u{0052}"), // FULLWIDTH LATIN CAPITAL LETTER R -> LATIN CAPITAL LETTER R
    ("\u{FF33}", "\u{0053}"), // FULLWIDTH LATIN CAPITAL LETTER S -> LATIN CAPITAL LETTER S
    ("\u{FF34}", "\u{0054}"), // FULLWIDTH LATIN CAPITAL LETTER T -> LATIN CAPITAL LETTER T
    ("\u{FF35}", "\u{0055}"), // FULLWIDTH LATIN CAPITAL LETTER U -> LATIN CAPITAL LETTER U
    ("\u{FF36}", "\u{0056}"), // FULLWIDTH LATIN CAPITAL LETTER V -> LATIN CAPITAL LETTER V
    ("\u{FF37}", "\u{0057}"), // FULLWIDTH LATIN CAPITAL LETTER W -> LATIN CAPITAL LETTER W
    ("\u{FF38}", "\u{0058}"), // FULLWIDTH LATIN CAPITAL LETTER X -> LATIN CAPITAL LETTER X
    ("\u{FF39}", "\u{0059}"), // FULLWIDTH LATIN CAPITAL LETTER Y -> LATIN CAPITAL LETTER Y
    ("\u{FF3A}", "\u{005A}"), // FULLWIDTH LATIN CAPITAL LETTER Z -> LATIN CAPITAL LETTER Z
    ("\u{FF3B}", "\u{005B}"), // FULLWIDTH LEFT SQUARE BRACKET -> LEFT SQUARE BRACKET
    ("\u{FF3D}", "\u{005D}"), // FULLWIDTH RIGHT SQUARE BRACKET -> RIGHT SQUARE BRACKET
    ("\u{FF3E}", "\u{005E}"), // FULLWIDTH CIRCUMFLEX ACCENT -> CIRCUMFLEX ACCENT
    ("\u{FF3F}", "\u{005F}"), // FULLWIDTH LOW LINE -> LOW LINE
    ("\u{FF40}", "\u{0060}"), // FULLWIDTH GRAVE ACCENT -> GRAVE ACCENT
    ("\u{FF41}", "\u{0061}"), // FULLWIDTH LATIN SMALL LETTER A -> LATIN SMALL LETTER A
    ("\u{FF42}", "\u{0062}"), // FULLWIDTH LATIN SMALL LETTER B -> LATIN SMALL LETTER B
    ("\u{FF43}", "\u{0063}"), // FULLWIDTH LATIN SMALL LETTER C -> LATIN SMALL LETTER C
    ("\u{FF44}", "\u{0064}"), // FULLWIDTH LATIN SMALL LETTER D -> LATIN SMALL LETTER D
    ("\u{FF45}", "\u{0065}"), // FULLWIDTH LATIN SMALL LETTER E -> LATIN SMALL LETTER E
    ("\u{FF46}", "\u{0066}"), // FULLWIDTH LATIN SMALL LETTER F -> LATIN SMALL LETTER F
    ("\u{FF47}", "\u{0067}"), // FULLWIDTH LATIN SMALL LETTER G -> LATIN SMALL LETTER G
    ("\u{FF48}", "\u{0068}"), // FULLWIDTH LATIN SMALL LETTER H -> LATIN SMALL LETTER H
    ("\u{FF49}", "\u{0069}"), // FULLWIDTH LATIN SMALL LETTER I -> LATIN SMALL LETTER I
    ("\u{FF4A}", "\u{006A}"), // FULLWIDTH LATIN SMALL LETTER J -> LATIN SMALL LETTER J
    ("\u{FF4B}", "\u{006B}"), // FULLWIDTH LATIN SMALL LETTER K -> LATIN SMALL LETTER K
    ("\u{FF4C}", "\u{006C}"), // FULLWIDTH LATIN SMALL LETTER L -> LATIN SMALL LETTER L
    ("\u{FF4D}", "\u{006D}"), // FULLWIDTH LATIN SMALL LETTER M -> LATIN SMALL LETTER M
    ("\u{FF4E}", "\u{006E}"), // FULLWIDTH LATIN SMALL LETTER N -> LATIN SMALL LETTER N
    ("\u{FF4F}", "\u{006F}"), // FULLWIDTH LATIN SMALL LETTER O -> LATIN SMALL LETTER O
    ("\u{FF50}", "\u{0070}"), // FULLWIDTH LATIN SMALL LETTER P -> LATIN SMALL LETTER P
    ("\u{FF51}", "\u{0071}"), // FULLWIDTH LATIN SMALL LETTER Q -> LATIN SMALL LETTER Q
    ("\u{FF52}", "\u{0072}"), // FULLWIDTH LATIN SMALL LETTER R -> LATIN SMALL LETTER R
    ("\u{FF53}", "\u{0073}"), // FULLWIDTH LATIN SMALL LETTER S -> LATIN SMALL LETTER S
    ("\u{FF54}", "\u{0074}"), // FULLWIDTH LATIN SMALL LETTER T -> LATIN SMALL LETTER T
    ("\u{FF55}", "\u{0075}"), // FULLWIDTH LATIN SMALL LETTER U -> LATIN SMALL LETTER U
    ("\u{FF56}", "\u{0076}"), // FULLWIDTH LATIN SMALL LETTER V -> LATIN SMALL LETTER V
    ("\u{FF57}", "\u{0077}"), // FULLWIDTH LATIN SMALL LETTER W -> LATIN SMALL LETTER W
    ("\u{FF58}", "\u{0078}"), // FULLWIDTH LATIN SMALL LETTER X -> LATIN SMALL LETTER X
    ("\u{FF59}", "\u{0079}"), // FULLWIDTH LATIN SMALL LETTER Y -> LATIN SMALL LETTER Y
    ("\u{FF5A}", "\u{007A}"), // FULLWIDTH LATIN SMALL LETTER Z -> LATIN SMALL LETTER Z
    ("\u{FF5B}", "\u{007B}"), // FULLWIDTH LEFT CURLY BRACKET -> LEFT CURLY BRACKET
    ("\u{FF5C}", "\u{007C}"), // FULLWIDTH VERTICAL LINE -> VERTICAL LINE
    ("\u{FF5D}", "\u{007D}"), // FULLWIDTH RIGHT CURLY BRACKET -> RIGHT CURLY BRACKET
];

/// JIS X 0201 GR (Graphics Right) character mappings: katakana fullwidth to halfwidth
static JISX0201_GR_TABLE: &[(&str, &str)] = &[
    ("\u{3001}", "\u{FF64}"), // IDEOGRAPHIC COMMA -> HALFWIDTH IDEOGRAPHIC COMMA
    ("\u{3002}", "\u{FF61}"), // IDEOGRAPHIC FULL STOP -> HALFWIDTH IDEOGRAPHIC FULL STOP
    ("\u{300C}", "\u{FF62}"), // LEFT CORNER BRACKET -> HALFWIDTH LEFT CORNER BRACKET
    ("\u{300D}", "\u{FF63}"), // RIGHT CORNER BRACKET -> HALFWIDTH RIGHT CORNER BRACKET
    ("\u{309B}", "\u{FF9E}"), // KATAKANA-HIRAGANA VOICED SOUND MARK -> HALFWIDTH KATAKANA VOICED SOUND MARK
    ("\u{309C}", "\u{FF9F}"), // KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK -> HALFWIDTH KATAKANA SEMI-VOICED SOUND MARK
    ("\u{30A1}", "\u{FF67}"), // KATAKANA LETTER SMALL A -> HALFWIDTH KATAKANA LETTER SMALL A
    ("\u{30A2}", "\u{FF71}"), // KATAKANA LETTER A -> HALFWIDTH KATAKANA LETTER A
    ("\u{30A3}", "\u{FF68}"), // KATAKANA LETTER SMALL I -> HALFWIDTH KATAKANA LETTER SMALL I
    ("\u{30A4}", "\u{FF72}"), // KATAKANA LETTER I -> HALFWIDTH KATAKANA LETTER I
    ("\u{30A5}", "\u{FF69}"), // KATAKANA LETTER SMALL U -> HALFWIDTH KATAKANA LETTER SMALL U
    ("\u{30A6}", "\u{FF73}"), // KATAKANA LETTER U -> HALFWIDTH KATAKANA LETTER U
    ("\u{30A7}", "\u{FF6A}"), // KATAKANA LETTER SMALL E -> HALFWIDTH KATAKANA LETTER SMALL E
    ("\u{30A8}", "\u{FF74}"), // KATAKANA LETTER E -> HALFWIDTH KATAKANA LETTER E
    ("\u{30A9}", "\u{FF6B}"), // KATAKANA LETTER SMALL O -> HALFWIDTH KATAKANA LETTER SMALL O
    ("\u{30AA}", "\u{FF75}"), // KATAKANA LETTER O -> HALFWIDTH KATAKANA LETTER O
    ("\u{30AB}", "\u{FF76}"), // KATAKANA LETTER KA -> HALFWIDTH KATAKANA LETTER KA
    ("\u{30AD}", "\u{FF77}"), // KATAKANA LETTER KI -> HALFWIDTH KATAKANA LETTER KI
    ("\u{30AF}", "\u{FF78}"), // KATAKANA LETTER KU -> HALFWIDTH KATAKANA LETTER KU
    ("\u{30B1}", "\u{FF79}"), // KATAKANA LETTER KE -> HALFWIDTH KATAKANA LETTER KE
    ("\u{30B3}", "\u{FF7A}"), // KATAKANA LETTER KO -> HALFWIDTH KATAKANA LETTER KO
    ("\u{30B5}", "\u{FF7B}"), // KATAKANA LETTER SA -> HALFWIDTH KATAKANA LETTER SA
    ("\u{30B7}", "\u{FF7C}"), // KATAKANA LETTER SI -> HALFWIDTH KATAKANA LETTER SI
    ("\u{30B9}", "\u{FF7D}"), // KATAKANA LETTER SU -> HALFWIDTH KATAKANA LETTER SU
    ("\u{30BB}", "\u{FF7E}"), // KATAKANA LETTER SE -> HALFWIDTH KATAKANA LETTER SE
    ("\u{30BD}", "\u{FF7F}"), // KATAKANA LETTER SO -> HALFWIDTH KATAKANA LETTER SO
    ("\u{30BF}", "\u{FF80}"), // KATAKANA LETTER TA -> HALFWIDTH KATAKANA LETTER TA
    ("\u{30C1}", "\u{FF81}"), // KATAKANA LETTER TI -> HALFWIDTH KATAKANA LETTER TI
    ("\u{30C3}", "\u{FF6F}"), // KATAKANA LETTER SMALL TU -> HALFWIDTH KATAKANA LETTER SMALL TU
    ("\u{30C4}", "\u{FF82}"), // KATAKANA LETTER TU -> HALFWIDTH KATAKANA LETTER TU
    ("\u{30C6}", "\u{FF83}"), // KATAKANA LETTER TE -> HALFWIDTH KATAKANA LETTER TE
    ("\u{30C8}", "\u{FF84}"), // KATAKANA LETTER TO -> HALFWIDTH KATAKANA LETTER TO
    ("\u{30CA}", "\u{FF85}"), // KATAKANA LETTER NA -> HALFWIDTH KATAKANA LETTER NA
    ("\u{30CB}", "\u{FF86}"), // KATAKANA LETTER NI -> HALFWIDTH KATAKANA LETTER NI
    ("\u{30CC}", "\u{FF87}"), // KATAKANA LETTER NU -> HALFWIDTH KATAKANA LETTER NU
    ("\u{30CD}", "\u{FF88}"), // KATAKANA LETTER NE -> HALFWIDTH KATAKANA LETTER NE
    ("\u{30CE}", "\u{FF89}"), // KATAKANA LETTER NO -> HALFWIDTH KATAKANA LETTER NO
    ("\u{30CF}", "\u{FF8A}"), // KATAKANA LETTER HA -> HALFWIDTH KATAKANA LETTER HA
    ("\u{30D2}", "\u{FF8B}"), // KATAKANA LETTER HI -> HALFWIDTH KATAKANA LETTER HI
    ("\u{30D5}", "\u{FF8C}"), // KATAKANA LETTER HU -> HALFWIDTH KATAKANA LETTER HU
    ("\u{30D8}", "\u{FF8D}"), // KATAKANA LETTER HE -> HALFWIDTH KATAKANA LETTER HE
    ("\u{30DB}", "\u{FF8E}"), // KATAKANA LETTER HO -> HALFWIDTH KATAKANA LETTER HO
    ("\u{30DE}", "\u{FF8F}"), // KATAKANA LETTER MA -> HALFWIDTH KATAKANA LETTER MA
    ("\u{30DF}", "\u{FF90}"), // KATAKANA LETTER MI -> HALFWIDTH KATAKANA LETTER MI
    ("\u{30E0}", "\u{FF91}"), // KATAKANA LETTER MU -> HALFWIDTH KATAKANA LETTER MU
    ("\u{30E1}", "\u{FF92}"), // KATAKANA LETTER ME -> HALFWIDTH KATAKANA LETTER ME
    ("\u{30E2}", "\u{FF93}"), // KATAKANA LETTER MO -> HALFWIDTH KATAKANA LETTER MO
    ("\u{30E3}", "\u{FF6C}"), // KATAKANA LETTER SMALL YA -> HALFWIDTH KATAKANA LETTER SMALL YA
    ("\u{30E4}", "\u{FF94}"), // KATAKANA LETTER YA -> HALFWIDTH KATAKANA LETTER YA
    ("\u{30E5}", "\u{FF6D}"), // KATAKANA LETTER SMALL YU -> HALFWIDTH KATAKANA LETTER SMALL YU
    ("\u{30E6}", "\u{FF95}"), // KATAKANA LETTER YU -> HALFWIDTH KATAKANA LETTER YU
    ("\u{30E7}", "\u{FF6E}"), // KATAKANA LETTER SMALL YO -> HALFWIDTH KATAKANA LETTER SMALL YO
    ("\u{30E8}", "\u{FF96}"), // KATAKANA LETTER YO -> HALFWIDTH KATAKANA LETTER YO
    ("\u{30E9}", "\u{FF97}"), // KATAKANA LETTER RA -> HALFWIDTH KATAKANA LETTER RA
    ("\u{30EA}", "\u{FF98}"), // KATAKANA LETTER RI -> HALFWIDTH KATAKANA LETTER RI
    ("\u{30EB}", "\u{FF99}"), // KATAKANA LETTER RU -> HALFWIDTH KATAKANA LETTER RU
    ("\u{30EC}", "\u{FF9A}"), // KATAKANA LETTER RE -> HALFWIDTH KATAKANA LETTER RE
    ("\u{30ED}", "\u{FF9B}"), // KATAKANA LETTER RO -> HALFWIDTH KATAKANA LETTER RO
    ("\u{30EF}", "\u{FF9C}"), // KATAKANA LETTER WA -> HALFWIDTH KATAKANA LETTER WA
    ("\u{30F2}", "\u{FF66}"), // KATAKANA LETTER WO -> HALFWIDTH KATAKANA LETTER WO
    ("\u{30F3}", "\u{FF9D}"), // KATAKANA LETTER N -> HALFWIDTH KATAKANA LETTER N
    ("\u{30FB}", "\u{FF65}"), // KATAKANA MIDDLE DOT -> HALFWIDTH KATAKANA MIDDLE DOT
    ("\u{30FC}", "\u{FF70}"), // KATAKANA-HIRAGANA PROLONGED SOUND MARK -> HALFWIDTH KATAKANA-HIRAGANA PROLONGED SOUND MARK
];

/// Voiced katakana letters that can be decomposed into base + voiced mark
static VOICED_LETTERS_TABLE: &[(&str, &str)] = &[
    ("\u{30AC}", "\u{FF76}\u{FF9E}"), // GA -> KA + VOICED MARK
    ("\u{30AE}", "\u{FF77}\u{FF9E}"), // GI -> KI + VOICED MARK
    ("\u{30B0}", "\u{FF78}\u{FF9E}"), // GU -> KU + VOICED MARK
    ("\u{30B2}", "\u{FF79}\u{FF9E}"), // GE -> KE + VOICED MARK
    ("\u{30B4}", "\u{FF7A}\u{FF9E}"), // GO -> KO + VOICED MARK
    ("\u{30B6}", "\u{FF7B}\u{FF9E}"), // ZA -> SA + VOICED MARK
    ("\u{30B8}", "\u{FF7C}\u{FF9E}"), // ZI -> SI + VOICED MARK
    ("\u{30BA}", "\u{FF7D}\u{FF9E}"), // ZU -> SU + VOICED MARK
    ("\u{30BC}", "\u{FF7E}\u{FF9E}"), // ZE -> SE + VOICED MARK
    ("\u{30BE}", "\u{FF7F}\u{FF9E}"), // ZO -> SO + VOICED MARK
    ("\u{30C0}", "\u{FF80}\u{FF9E}"), // DA -> TA + VOICED MARK
    ("\u{30C2}", "\u{FF81}\u{FF9E}"), // DI -> TI + VOICED MARK
    ("\u{30C5}", "\u{FF82}\u{FF9E}"), // DU -> TU + VOICED MARK
    ("\u{30C7}", "\u{FF83}\u{FF9E}"), // DE -> TE + VOICED MARK
    ("\u{30C9}", "\u{FF84}\u{FF9E}"), // DO -> TO + VOICED MARK
    ("\u{30D0}", "\u{FF8A}\u{FF9E}"), // BA -> HA + VOICED MARK
    ("\u{30D1}", "\u{FF8A}\u{FF9F}"), // PA -> HA + SEMI-VOICED MARK
    ("\u{30D3}", "\u{FF8B}\u{FF9E}"), // BI -> HI + VOICED MARK
    ("\u{30D4}", "\u{FF8B}\u{FF9F}"), // PI -> HI + SEMI-VOICED MARK
    ("\u{30D6}", "\u{FF8C}\u{FF9E}"), // BU -> HU + VOICED MARK
    ("\u{30D7}", "\u{FF8C}\u{FF9F}"), // PU -> HU + SEMI-VOICED MARK
    ("\u{30D9}", "\u{FF8D}\u{FF9E}"), // BE -> HE + VOICED MARK
    ("\u{30DA}", "\u{FF8D}\u{FF9F}"), // PE -> HE + SEMI-VOICED MARK
    ("\u{30DC}", "\u{FF8E}\u{FF9E}"), // BO -> HO + VOICED MARK
    ("\u{30DD}", "\u{FF8E}\u{FF9F}"), // PO -> HO + SEMI-VOICED MARK
    ("\u{30F4}", "\u{FF73}\u{FF9E}"), // VU -> U + VOICED MARK
    ("\u{30FA}", "\u{FF66}\u{FF9E}"), // WO + VOICED MARK
];

/// Hiragana to halfwidth katakana mappings
static HIRAGANA_TO_HALFWIDTH_TABLE: &[(&str, &str)] = &[
    ("\u{3041}", "\u{FF67}"), // HIRAGANA LETTER SMALL A -> HALFWIDTH KATAKANA LETTER SMALL A
    ("\u{3042}", "\u{FF71}"), // HIRAGANA LETTER A -> HALFWIDTH KATAKANA LETTER A
    ("\u{3043}", "\u{FF68}"), // HIRAGANA LETTER SMALL I -> HALFWIDTH KATAKANA LETTER SMALL I
    ("\u{3044}", "\u{FF72}"), // HIRAGANA LETTER I -> HALFWIDTH KATAKANA LETTER I
    ("\u{3045}", "\u{FF69}"), // HIRAGANA LETTER SMALL U -> HALFWIDTH KATAKANA LETTER SMALL U
    ("\u{3046}", "\u{FF73}"), // HIRAGANA LETTER U -> HALFWIDTH KATAKANA LETTER U
    ("\u{3047}", "\u{FF6A}"), // HIRAGANA LETTER SMALL E -> HALFWIDTH KATAKANA LETTER SMALL E
    ("\u{3048}", "\u{FF74}"), // HIRAGANA LETTER E -> HALFWIDTH KATAKANA LETTER E
    ("\u{3049}", "\u{FF6B}"), // HIRAGANA LETTER SMALL O -> HALFWIDTH KATAKANA LETTER SMALL O
    ("\u{304A}", "\u{FF75}"), // HIRAGANA LETTER O -> HALFWIDTH KATAKANA LETTER O
    ("\u{304B}", "\u{FF76}"), // HIRAGANA LETTER KA -> HALFWIDTH KATAKANA LETTER KA
    ("\u{304C}", "\u{FF76}\u{FF9E}"), // HIRAGANA LETTER GA -> KA + VOICED MARK
    ("\u{304D}", "\u{FF77}"), // HIRAGANA LETTER KI -> HALFWIDTH KATAKANA LETTER KI
    ("\u{304E}", "\u{FF77}\u{FF9E}"), // HIRAGANA LETTER GI -> KI + VOICED MARK
    ("\u{304F}", "\u{FF78}"), // HIRAGANA LETTER KU -> HALFWIDTH KATAKANA LETTER KU
    ("\u{3050}", "\u{FF78}\u{FF9E}"), // HIRAGANA LETTER GU -> KU + VOICED MARK
    ("\u{3051}", "\u{FF79}"), // HIRAGANA LETTER KE -> HALFWIDTH KATAKANA LETTER KE
    ("\u{3052}", "\u{FF79}\u{FF9E}"), // HIRAGANA LETTER GE -> KE + VOICED MARK
    ("\u{3053}", "\u{FF7A}"), // HIRAGANA LETTER KO -> HALFWIDTH KATAKANA LETTER KO
    ("\u{3054}", "\u{FF7A}\u{FF9E}"), // HIRAGANA LETTER GO -> KO + VOICED MARK
    ("\u{3055}", "\u{FF7B}"), // HIRAGANA LETTER SA -> HALFWIDTH KATAKANA LETTER SA
    ("\u{3056}", "\u{FF7B}\u{FF9E}"), // HIRAGANA LETTER ZA -> SA + VOICED MARK
    ("\u{3057}", "\u{FF7C}"), // HIRAGANA LETTER SI -> HALFWIDTH KATAKANA LETTER SI
    ("\u{3058}", "\u{FF7C}\u{FF9E}"), // HIRAGANA LETTER ZI -> SI + VOICED MARK
    ("\u{3059}", "\u{FF7D}"), // HIRAGANA LETTER SU -> HALFWIDTH KATAKANA LETTER SU
    ("\u{305A}", "\u{FF7D}\u{FF9E}"), // HIRAGANA LETTER ZU -> SU + VOICED MARK
    ("\u{305B}", "\u{FF7E}"), // HIRAGANA LETTER SE -> HALFWIDTH KATAKANA LETTER SE
    ("\u{305C}", "\u{FF7E}\u{FF9E}"), // HIRAGANA LETTER ZE -> SE + VOICED MARK
    ("\u{305D}", "\u{FF7F}"), // HIRAGANA LETTER SO -> HALFWIDTH KATAKANA LETTER SO
    ("\u{305E}", "\u{FF7F}\u{FF9E}"), // HIRAGANA LETTER ZO -> SO + VOICED MARK
    ("\u{305F}", "\u{FF80}"), // HIRAGANA LETTER TA -> HALFWIDTH KATAKANA LETTER TA
    ("\u{3060}", "\u{FF80}\u{FF9E}"), // HIRAGANA LETTER DA -> TA + VOICED MARK
    ("\u{3061}", "\u{FF81}"), // HIRAGANA LETTER TI -> HALFWIDTH KATAKANA LETTER TI
    ("\u{3062}", "\u{FF81}\u{FF9E}"), // HIRAGANA LETTER DI -> TI + VOICED MARK
    ("\u{3063}", "\u{FF6F}"), // HIRAGANA LETTER SMALL TU -> HALFWIDTH KATAKANA LETTER SMALL TU
    ("\u{3064}", "\u{FF82}"), // HIRAGANA LETTER TU -> HALFWIDTH KATAKANA LETTER TU
    ("\u{3065}", "\u{FF82}\u{FF9E}"), // HIRAGANA LETTER DU -> TU + VOICED MARK
    ("\u{3066}", "\u{FF83}"), // HIRAGANA LETTER TE -> HALFWIDTH KATAKANA LETTER TE
    ("\u{3067}", "\u{FF83}\u{FF9E}"), // HIRAGANA LETTER DE -> TE + VOICED MARK
    ("\u{3068}", "\u{FF84}"), // HIRAGANA LETTER TO -> HALFWIDTH KATAKANA LETTER TO
    ("\u{3069}", "\u{FF84}\u{FF9E}"), // HIRAGANA LETTER DO -> TO + VOICED MARK
    ("\u{306A}", "\u{FF85}"), // HIRAGANA LETTER NA -> HALFWIDTH KATAKANA LETTER NA
    ("\u{306B}", "\u{FF86}"), // HIRAGANA LETTER NI -> HALFWIDTH KATAKANA LETTER NI
    ("\u{306C}", "\u{FF87}"), // HIRAGANA LETTER NU -> HALFWIDTH KATAKANA LETTER NU
    ("\u{306D}", "\u{FF88}"), // HIRAGANA LETTER NE -> HALFWIDTH KATAKANA LETTER NE
    ("\u{306E}", "\u{FF89}"), // HIRAGANA LETTER NO -> HALFWIDTH KATAKANA LETTER NO
    ("\u{306F}", "\u{FF8A}"), // HIRAGANA LETTER HA -> HALFWIDTH KATAKANA LETTER HA
    ("\u{3070}", "\u{FF8A}\u{FF9E}"), // HIRAGANA LETTER BA -> HA + VOICED MARK
    ("\u{3071}", "\u{FF8A}\u{FF9F}"), // HIRAGANA LETTER PA -> HA + SEMI-VOICED MARK
    ("\u{3072}", "\u{FF8B}"), // HIRAGANA LETTER HI -> HALFWIDTH KATAKANA LETTER HI
    ("\u{3073}", "\u{FF8B}\u{FF9E}"), // HIRAGANA LETTER BI -> HI + VOICED MARK
    ("\u{3074}", "\u{FF8B}\u{FF9F}"), // HIRAGANA LETTER PI -> HI + SEMI-VOICED MARK
    ("\u{3075}", "\u{FF8C}"), // HIRAGANA LETTER HU -> HALFWIDTH KATAKANA LETTER HU
    ("\u{3076}", "\u{FF8C}\u{FF9E}"), // HIRAGANA LETTER BU -> HU + VOICED MARK
    ("\u{3077}", "\u{FF8C}\u{FF9F}"), // HIRAGANA LETTER PU -> HU + SEMI-VOICED MARK
    ("\u{3078}", "\u{FF8D}"), // HIRAGANA LETTER HE -> HALFWIDTH KATAKANA LETTER HE
    ("\u{3079}", "\u{FF8D}\u{FF9E}"), // HIRAGANA LETTER BE -> HE + VOICED MARK
    ("\u{307A}", "\u{FF8D}\u{FF9F}"), // HIRAGANA LETTER PE -> HE + SEMI-VOICED MARK
    ("\u{307B}", "\u{FF8E}"), // HIRAGANA LETTER HO -> HALFWIDTH KATAKANA LETTER HO
    ("\u{307C}", "\u{FF8E}\u{FF9E}"), // HIRAGANA LETTER BO -> HO + VOICED MARK
    ("\u{307D}", "\u{FF8E}\u{FF9F}"), // HIRAGANA LETTER PO -> HO + SEMI-VOICED MARK
    ("\u{307E}", "\u{FF8F}"), // HIRAGANA LETTER MA -> HALFWIDTH KATAKANA LETTER MA
    ("\u{307F}", "\u{FF90}"), // HIRAGANA LETTER MI -> HALFWIDTH KATAKANA LETTER MI
    ("\u{3080}", "\u{FF91}"), // HIRAGANA LETTER MU -> HALFWIDTH KATAKANA LETTER MU
    ("\u{3081}", "\u{FF92}"), // HIRAGANA LETTER ME -> HALFWIDTH KATAKANA LETTER ME
    ("\u{3082}", "\u{FF93}"), // HIRAGANA LETTER MO -> HALFWIDTH KATAKANA LETTER MO
    ("\u{3083}", "\u{FF6C}"), // HIRAGANA LETTER SMALL YA -> HALFWIDTH KATAKANA LETTER SMALL YA
    ("\u{3084}", "\u{FF94}"), // HIRAGANA LETTER YA -> HALFWIDTH KATAKANA LETTER YA
    ("\u{3085}", "\u{FF6D}"), // HIRAGANA LETTER SMALL YU -> HALFWIDTH KATAKANA LETTER SMALL YU
    ("\u{3086}", "\u{FF95}"), // HIRAGANA LETTER YU -> HALFWIDTH KATAKANA LETTER YU
    ("\u{3087}", "\u{FF6E}"), // HIRAGANA LETTER SMALL YO -> HALFWIDTH KATAKANA LETTER SMALL YO
    ("\u{3088}", "\u{FF96}"), // HIRAGANA LETTER YO -> HALFWIDTH KATAKANA LETTER YO
    ("\u{3089}", "\u{FF97}"), // HIRAGANA LETTER RA -> HALFWIDTH KATAKANA LETTER RA
    ("\u{308A}", "\u{FF98}"), // HIRAGANA LETTER RI -> HALFWIDTH KATAKANA LETTER RI
    ("\u{308B}", "\u{FF99}"), // HIRAGANA LETTER RU -> HALFWIDTH KATAKANA LETTER RU
    ("\u{308C}", "\u{FF9A}"), // HIRAGANA LETTER RE -> HALFWIDTH KATAKANA LETTER RE
    ("\u{308D}", "\u{FF9B}"), // HIRAGANA LETTER RO -> HALFWIDTH KATAKANA LETTER RO
    ("\u{308F}", "\u{FF9C}"), // HIRAGANA LETTER WA -> HALFWIDTH KATAKANA LETTER WA
    ("\u{3092}", "\u{FF66}"), // HIRAGANA LETTER WO -> HALFWIDTH KATAKANA LETTER WO
    ("\u{3093}", "\u{FF9D}"), // HIRAGANA LETTER N -> HALFWIDTH KATAKANA LETTER N
    ("\u{3094}", "\u{FF73}\u{FF9E}"), // HIRAGANA LETTER VU -> U + VOICED MARK
];

/// Special punctuation mappings
static SPECIAL_PUNCTUATIONS_TABLE: &[(&str, &str)] = &[
    ("\u{30A0}", "\u{003D}"), // KATAKANA-HIRAGANA DOUBLE HYPHEN -> EQUALS SIGN
];

/// GL override options for ambiguous characters
static JISX0201_GL_OVERRIDES: &[(&str, &str, &str)] = &[
    ("u005cAsYenSign", "\u{FFE5}", "\u{005C}"), // YEN SIGN -> REVERSE SOLIDUS
    ("u005cAsBackslash", "\u{FF3C}", "\u{005C}"), // FULLWIDTH REVERSE SOLIDUS -> REVERSE SOLIDUS
    ("u007eAsFullwidthTilde", "\u{FF5E}", "\u{007E}"), // FULLWIDTH TILDE -> TILDE
    ("u007eAsWaveDash", "\u{301C}", "\u{007E}"), // WAVE DASH -> TILDE
    ("u007eAsOverline", "\u{203E}", "\u{007E}"), // OVERLINE -> TILDE
    ("u007eAsFullwidthMacron", "\u{FFE3}", "\u{007E}"), // FULLWIDTH MACRON -> TILDE
    ("u00a5AsYenSign", "\u{FFE5}", "\u{00A5}"), // FULLWIDTH YEN SIGN -> YEN SIGN
];

/// Cache key type for mapping caches
type CacheKey = (
    bool, // convert_gl
    bool, // convert_gr
    bool, // convert_unsafe_specials
    bool, // convert_hiraganas
    bool, // u005c_as_yen_sign
    bool, // u005c_as_backslash
    bool, // u007e_as_fullwidth_tilde
    bool, // u007e_as_wave_dash
    bool, // u007e_as_overline
    bool, // u007e_as_fullwidth_macron
    bool, // u00a5_as_yen_sign
);

/// Global cache for forward mappings
pub static FWD_MAPPINGS_CACHE: LazyLock<
    RwLock<HashMap<CacheKey, HashMap<&'static str, &'static str>>>,
> = LazyLock::new(|| RwLock::new(HashMap::new()));

/// Global cache for reverse mappings
pub static REV_MAPPINGS_CACHE: LazyLock<
    RwLock<HashMap<CacheKey, HashMap<&'static str, &'static str>>>,
> = LazyLock::new(|| RwLock::new(HashMap::new()));

/// Global cache for voiced reverse mappings
#[allow(clippy::type_complexity)]
pub static VOICED_REV_MAPPINGS_CACHE: LazyLock<
    RwLock<HashMap<CacheKey, HashMap<&'static str, HashMap<&'static str, &'static str>>>>,
> = LazyLock::new(|| RwLock::new(HashMap::new()));

/// Generate cache key from options
fn generate_cache_key(options: &Jisx0201AndAlikeTransliteratorOptions) -> CacheKey {
    (
        options.convert_gl,
        options.convert_gr,
        options.convert_unsafe_specials,
        options.convert_hiraganas,
        options.u005c_as_yen_sign,
        options.u005c_as_backslash,
        options.u007e_as_fullwidth_tilde,
        options.u007e_as_wave_dash,
        options.u007e_as_overline,
        options.u007e_as_fullwidth_macron,
        options.u00a5_as_yen_sign,
    )
}

/// Get forward mappings from cache or build new ones
pub fn get_fwd_mappings(
    options: &Jisx0201AndAlikeTransliteratorOptions,
) -> HashMap<&'static str, &'static str> {
    let cache_key = generate_cache_key(options);

    // Try to read from cache first
    {
        let cache = FWD_MAPPINGS_CACHE.read().unwrap();
        if let Some(mappings) = cache.get(&cache_key) {
            return mappings.clone();
        }
    }

    // Build new mappings and cache them
    let mappings = options.build_forward_mappings();
    {
        let mut cache = FWD_MAPPINGS_CACHE.write().unwrap();
        cache.insert(cache_key, mappings.clone());
    }

    mappings
}

/// Get reverse mappings from cache or build new ones
pub fn get_rev_mappings(
    options: &Jisx0201AndAlikeTransliteratorOptions,
) -> HashMap<&'static str, &'static str> {
    let cache_key = generate_cache_key(options);

    // Try to read from cache first
    {
        let cache = REV_MAPPINGS_CACHE.read().unwrap();
        if let Some(mappings) = cache.get(&cache_key) {
            return mappings.clone();
        }
    }

    // Build new mappings and cache them
    let mappings = options.build_reverse_mappings();
    {
        let mut cache = REV_MAPPINGS_CACHE.write().unwrap();
        cache.insert(cache_key, mappings.clone());
    }

    mappings
}

/// Get voiced reverse mappings from cache or build new ones
fn get_voiced_rev_mappings(
    options: &Jisx0201AndAlikeTransliteratorOptions,
) -> HashMap<&'static str, HashMap<&'static str, &'static str>> {
    let cache_key = generate_cache_key(options);

    // Try to read from cache first
    {
        let cache = VOICED_REV_MAPPINGS_CACHE.read().unwrap();
        if let Some(mappings) = cache.get(&cache_key) {
            return mappings.clone();
        }
    }

    // Build new mappings and cache them
    let mappings = options.build_voiced_reverse_mappings();
    {
        let mut cache = VOICED_REV_MAPPINGS_CACHE.write().unwrap();
        cache.insert(cache_key, mappings.clone());
    }

    mappings
}

/// Helper function to find a character in the GR table
fn find_char_in_table(c: &str) -> Option<&'static str> {
    JISX0201_GR_TABLE
        .binary_search_by(|(from, _)| (*from).cmp(c))
        .ok()
        .map(|i| JISX0201_GR_TABLE[i].1)
}

/// Helper function to find a voiced/semi-voiced mark
fn find_mark_in_table(char: &str) -> Option<&'static str> {
    match char {
        "\u{FF9E}" => Some("\u{FF9E}"), // HALFWIDTH KATAKANA VOICED SOUND MARK
        "\u{FF9F}" => Some("\u{FF9F}"), // HALFWIDTH KATAKANA SEMI-VOICED SOUND MARK
        _ => None,
    }
}

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
pub struct Jisx0201AndAlikeTransliteratorOptions {
    /// Convert characters belonging to GL area (alphanumerics and symbols)
    pub convert_gl: bool,
    /// Convert characters belonging to GR area (katakanas)
    pub convert_gr: bool,
    /// Convert unsafe special characters like KATAKANA-HIRAGANA DOUBLE HYPHEN
    pub convert_unsafe_specials: bool,
    /// Convert hiraganas to/from katakanas
    pub convert_hiraganas: bool,
    /// Combine voiced sound marks with base characters
    pub combine_voiced_sound_marks: bool,
    /// Treat U+005C as YEN SIGN
    pub u005c_as_yen_sign: bool,
    /// Treat U+005C verbatim as backslash
    pub u005c_as_backslash: bool,
    /// Convert U+007E to FULLWIDTH TILDE
    pub u007e_as_fullwidth_tilde: bool,
    /// Convert U+007E to WAVE DASH
    pub u007e_as_wave_dash: bool,
    /// Convert U+007E to OVERLINE
    pub u007e_as_overline: bool,
    /// Convert U+007E to FULLWIDTH MACRON
    pub u007e_as_fullwidth_macron: bool,
    /// Convert U+00A5 to REVERSE SOLIDUS
    pub u00a5_as_yen_sign: bool,
}

impl Default for Jisx0201AndAlikeTransliteratorOptions {
    fn default() -> Self {
        Self {
            convert_gl: true,
            convert_gr: true,
            convert_unsafe_specials: false,
            convert_hiraganas: false,
            combine_voiced_sound_marks: true,
            u005c_as_yen_sign: true,
            u005c_as_backslash: false,
            u007e_as_fullwidth_tilde: true,
            u007e_as_wave_dash: false,
            u007e_as_overline: false,
            u007e_as_fullwidth_macron: false,
            u00a5_as_yen_sign: true,
        }
    }
}

impl Jisx0201AndAlikeTransliteratorOptions {
    fn build_forward_mappings(&self) -> HashMap<&'static str, &'static str> {
        let mut mappings = HashMap::new();

        if self.convert_gl {
            for (from, to) in JISX0201_GL_TABLE {
                mappings.insert(*from, *to);
            }

            // Apply GL overrides
            for (option_name, from, to) in JISX0201_GL_OVERRIDES {
                let should_apply = match *option_name {
                    "u005cAsYenSign" => self.u005c_as_yen_sign,
                    "u005cAsBackslash" => self.u005c_as_backslash,
                    "u007eAsFullwidthTilde" => self.u007e_as_fullwidth_tilde,
                    "u007eAsWaveDash" => self.u007e_as_wave_dash,
                    "u007eAsOverline" => self.u007e_as_overline,
                    "u007eAsFullwidthMacron" => self.u007e_as_fullwidth_macron,
                    "u00a5AsYenSign" => self.u00a5_as_yen_sign,
                    _ => false,
                };
                if should_apply {
                    mappings.insert(*from, *to);
                }
            }
        }

        if self.convert_gr {
            for (from, to) in JISX0201_GR_TABLE {
                mappings.insert(*from, *to);
            }
            for (from, to) in VOICED_LETTERS_TABLE {
                mappings.insert(*from, *to);
            }
            // Add combining marks
            mappings.insert("\u{3099}", "\u{FF9E}"); // COMBINING KATAKANA-HIRAGANA VOICED SOUND MARK
            mappings.insert("\u{309A}", "\u{FF9F}"); // COMBINING KATAKANA-HIRAGANA SEMI-VOICED SOUND MARK
        }

        if self.convert_unsafe_specials {
            for (from, to) in SPECIAL_PUNCTUATIONS_TABLE {
                mappings.insert(*from, *to);
            }
        }

        if self.convert_hiraganas {
            for (from, to) in HIRAGANA_TO_HALFWIDTH_TABLE {
                mappings.insert(*from, *to);
            }
        }

        mappings
    }

    fn build_reverse_mappings(&self) -> HashMap<&'static str, &'static str> {
        let mut mappings = HashMap::new();

        if self.convert_gl {
            for (from, to) in JISX0201_GL_TABLE {
                mappings.insert(*to, *from);
            }

            // Apply GL overrides in reverse
            for (option_name, from, to) in JISX0201_GL_OVERRIDES {
                let should_apply = match *option_name {
                    "u005cAsYenSign" => self.u005c_as_yen_sign,
                    "u005cAsBackslash" => self.u005c_as_backslash,
                    "u007eAsFullwidthTilde" => self.u007e_as_fullwidth_tilde,
                    "u007eAsWaveDash" => self.u007e_as_wave_dash,
                    "u007eAsOverline" => self.u007e_as_overline,
                    "u007eAsFullwidthMacron" => self.u007e_as_fullwidth_macron,
                    "u00a5AsYenSign" => self.u00a5_as_yen_sign,
                    _ => false,
                };
                if should_apply {
                    mappings.insert(*to, *from);
                }
            }
        }

        if self.convert_gr {
            for (from, to) in JISX0201_GR_TABLE {
                mappings.insert(*to, *from);
            }
        }

        if self.convert_unsafe_specials {
            for (from, to) in SPECIAL_PUNCTUATIONS_TABLE {
                mappings.insert(*to, *from);
            }
        }

        mappings
    }

    fn build_voiced_reverse_mappings(
        &self,
    ) -> HashMap<&'static str, HashMap<&'static str, &'static str>> {
        let mut voiced_mappings = HashMap::new();

        if self.convert_gr && self.combine_voiced_sound_marks {
            for (from, to) in VOICED_LETTERS_TABLE {
                // Parse the two-character sequence (base + mark)
                let chars: Vec<char> = to.chars().collect();
                if chars.len() == 2 {
                    let base_char = chars[0].to_string();
                    let mark_char = chars[1].to_string();

                    // Find the string slices for these characters
                    if let (Some(base_str), Some(mark_str)) = (
                        find_char_in_table(&base_char),
                        find_mark_in_table(&mark_char),
                    ) {
                        voiced_mappings
                            .entry(base_str)
                            .or_insert_with(HashMap::new)
                            .insert(mark_str, *from);
                    }
                }
            }
        }

        voiced_mappings
    }
}

#[derive(Debug, Clone)]
pub struct Jisx0201AndAlikeHalfwidthToFullwidthTransliterator(
    Jisx0201AndAlikeTransliteratorOptions,
);

impl Transliterator for Jisx0201AndAlikeHalfwidthToFullwidthTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        chars: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mappings = get_rev_mappings(&self.0);
        let voiced_mappings = get_voiced_rev_mappings(&self.0);
        let mut result = Vec::new();
        let mut i = 0;

        while i < chars.len() {
            let char = chars[i];

            if char.c.is_empty() {
                // Preserve sentinel
                result.push(char);
                i += 1;
                continue;
            }

            // Check for voiced sound mark combination
            if self.0.combine_voiced_sound_marks && i + 1 < chars.len() {
                let next_char = chars[i + 1];
                if let Some(mark_mappings) = voiced_mappings.get(char.c.as_ref()) {
                    if let Some(&combined) = mark_mappings.get(next_char.c.as_ref()) {
                        let new_char =
                            pool.new_char_from(Cow::Borrowed(combined), char.offset, char);
                        result.push(new_char);
                        i += 2; // Skip both characters
                        continue;
                    }
                }
            }

            // Regular mapping
            if let Some(&mapped) = mappings.get(char.c.as_ref()) {
                let new_char = pool.new_char_from(Cow::Borrowed(mapped), char.offset, char);
                result.push(new_char);
            } else {
                result.push(char);
            }

            i += 1;
        }

        Ok(result)
    }
}

#[derive(Debug, Clone)]
pub struct Jisx0201AndAlikeFullwidthToHalfwidthTransliterator(
    Jisx0201AndAlikeTransliteratorOptions,
);

impl Transliterator for Jisx0201AndAlikeFullwidthToHalfwidthTransliterator {
    fn transliterate<'a, 'b>(
        &self,
        pool: &mut CharPool<'a, 'b>,
        chars: &[&'a Char<'a, 'b>],
    ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
        let mappings = get_fwd_mappings(&self.0);
        let mut result = Vec::new();

        for &char in chars {
            if char.c.is_empty() {
                // Preserve sentinel
                result.push(char);
                continue;
            }

            if let Some(&mapped) = mappings.get(char.c.as_ref()) {
                let new_char = pool.new_char_from(Cow::Borrowed(mapped), char.offset, char);
                result.push(new_char);
            } else {
                result.push(char);
            }
        }

        Ok(result)
    }
}

pub struct Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorFactory(
    pub Jisx0201AndAlikeTransliteratorOptions,
);

impl TransliteratorFactory for Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorFactory {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(
            Jisx0201AndAlikeHalfwidthToFullwidthTransliterator(self.0.clone()),
        ))
    }
}

pub struct Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorFactory(
    pub Jisx0201AndAlikeTransliteratorOptions,
);

impl TransliteratorFactory for Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorFactory {
    fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
        Ok(Box::new(
            Jisx0201AndAlikeFullwidthToHalfwidthTransliterator(self.0.clone()),
        ))
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::char::from_chars;

    #[test]
    fn test_fullwidth_to_halfwidth_basic() {
        let options = Jisx0201AndAlikeTransliteratorOptions::default();
        let transliterator = Jisx0201AndAlikeFullwidthToHalfwidthTransliterator(options);
        let mut pool = CharPool::new();

        let test_cases = &[
            ("Ａ", "A"), // FULLWIDTH A -> A
            ("１", "1"), // FULLWIDTH 1 -> 1
            ("！", "!"), // FULLWIDTH ! -> !
            ("カ", "ｶ"), // KATAKANA KA -> HALFWIDTH KATAKANA KA
        ];

        for (input, expected) in test_cases {
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_halfwidth_to_fullwidth_basic() {
        let options = Jisx0201AndAlikeTransliteratorOptions::default();
        let transliterator = Jisx0201AndAlikeHalfwidthToFullwidthTransliterator(options);
        let mut pool = CharPool::new();

        let test_cases = &[
            ("A", "Ａ"), // A -> FULLWIDTH A
            ("1", "１"), // 1 -> FULLWIDTH 1
            ("!", "！"), // ! -> FULLWIDTH !
            ("ｶ", "カ"), // HALFWIDTH KATAKANA KA -> KATAKANA KA
        ];

        for (input, expected) in test_cases {
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_voiced_sound_marks() {
        let options = Jisx0201AndAlikeTransliteratorOptions {
            combine_voiced_sound_marks: true,
            ..Default::default()
        };
        let transliterator = Jisx0201AndAlikeFullwidthToHalfwidthTransliterator(options);
        let mut pool = CharPool::new();

        let test_cases = &[
            ("ガ", "ｶﾞ"), // GA -> KA + VOICED MARK
            ("パ", "ﾊﾟ"), // PA -> HA + SEMI-VOICED MARK
        ];

        for (input, expected) in test_cases {
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_hiragana_conversion() {
        let options = Jisx0201AndAlikeTransliteratorOptions {
            convert_hiraganas: true,
            ..Default::default()
        };
        let transliterator = Jisx0201AndAlikeFullwidthToHalfwidthTransliterator(options);
        let mut pool = CharPool::new();

        let test_cases = &[
            ("あ", "ｱ"), // HIRAGANA A -> HALFWIDTH KATAKANA A
            ("が", "ｶﾞ"), // HIRAGANA GA -> KA + VOICED MARK
        ];

        for (input, expected) in test_cases {
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_preserves_unmapped_characters() {
        let options = Jisx0201AndAlikeTransliteratorOptions::default();
        let transliterator = Jisx0201AndAlikeFullwidthToHalfwidthTransliterator(options);
        let mut pool = CharPool::new();

        let test_cases = &[
            ("漢", "漢"), // KANJI should be preserved
            ("🎌", "🎌"), // EMOJI should be preserved
        ];

        for (input, expected) in test_cases {
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().filter(|c| !c.c.is_empty()).copied());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_caching_functionality() {
        // Clear caches for clean test
        {
            let mut fwd_cache = FWD_MAPPINGS_CACHE.write().unwrap();
            let mut rev_cache = REV_MAPPINGS_CACHE.write().unwrap();
            fwd_cache.clear();
            rev_cache.clear();
        }

        // Create first instance with default options
        let options1 = Jisx0201AndAlikeTransliteratorOptions::default();
        let _mappings1 = get_fwd_mappings(&options1);
        let _rev_mappings1 = get_rev_mappings(&options1);

        let cache_sizes_1 = {
            let fwd_cache = FWD_MAPPINGS_CACHE.read().unwrap();
            let rev_cache = REV_MAPPINGS_CACHE.read().unwrap();
            (fwd_cache.len(), rev_cache.len())
        };

        // Create second instance with same options - should use cache
        let options2 = Jisx0201AndAlikeTransliteratorOptions::default();
        let _mappings2 = get_fwd_mappings(&options2);
        let _rev_mappings2 = get_rev_mappings(&options2);

        let cache_sizes_2 = {
            let fwd_cache = FWD_MAPPINGS_CACHE.read().unwrap();
            let rev_cache = REV_MAPPINGS_CACHE.read().unwrap();
            (fwd_cache.len(), rev_cache.len())
        };

        // Cache sizes should be the same for identical options
        assert_eq!(
            cache_sizes_1, cache_sizes_2,
            "Cache should not grow for identical options"
        );

        // Create third instance with different options - should create new cache entry
        let options3 = Jisx0201AndAlikeTransliteratorOptions {
            convert_hiraganas: true,
            ..Default::default()
        };
        let _mappings3 = get_fwd_mappings(&options3);
        let _rev_mappings3 = get_rev_mappings(&options3);

        let cache_sizes_3 = {
            let fwd_cache = FWD_MAPPINGS_CACHE.read().unwrap();
            let rev_cache = REV_MAPPINGS_CACHE.read().unwrap();
            (fwd_cache.len(), rev_cache.len())
        };

        // Cache should grow for different options
        assert!(
            cache_sizes_3.0 > cache_sizes_2.0,
            "Forward cache should grow for different options"
        );
        assert!(
            cache_sizes_3.1 > cache_sizes_2.1,
            "Reverse cache should grow for different options"
        );

        println!(
            "✅ Caching test passed! Final cache sizes: FWD={}, REV={}",
            cache_sizes_3.0, cache_sizes_3.1
        );
    }

    #[test]
    fn test_jisx0201_halfwidth_to_fullwidth_factory() {
        let options = Jisx0201AndAlikeTransliteratorOptions::default();
        let factory = Jisx0201AndAlikeHalfwidthToFullwidthTransliteratorFactory(options);
        let factory_result = factory.new_transliterator();
        assert!(factory_result.is_ok());

        let transliterator = factory_result.unwrap();

        // Test that it converts halfwidth to fullwidth
        let test_cases = &[("123", "１２３"), ("abc", "ａｂｃ"), ("!", "！"), ("", "")];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().cloned());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }

    #[test]
    fn test_jisx0201_fullwidth_to_halfwidth_factory() {
        let options = Jisx0201AndAlikeTransliteratorOptions::default();
        let factory = Jisx0201AndAlikeFullwidthToHalfwidthTransliteratorFactory(options);
        let factory_result = factory.new_transliterator();
        assert!(factory_result.is_ok());

        let transliterator = factory_result.unwrap();

        // Test that it converts fullwidth to halfwidth
        let test_cases = &[("１２３", "123"), ("ａｂｃ", "abc"), ("！", "!"), ("", "")];

        // Test each case
        for (input, expected) in test_cases {
            let mut pool = CharPool::new();
            let input_chars = pool.build_char_array(input);
            let result = transliterator
                .transliterate(&mut pool, &input_chars)
                .unwrap();
            let result_string = from_chars(result.iter().cloned());
            assert_eq!(result_string, *expected, "Failed for input '{input}'");
        }
    }
}
