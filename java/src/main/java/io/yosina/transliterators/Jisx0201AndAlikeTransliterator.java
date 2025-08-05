package io.yosina.transliterators;

import io.yosina.Char;
import io.yosina.CharIterator;
import io.yosina.CodePointTuple;
import io.yosina.Transliterator;
import io.yosina.annotations.RegisteredTransliterator;
import java.util.HashMap;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Objects;
import java.util.Optional;

/**
 * JIS X 0201 and alike transliterator for fullwidth/halfwidth conversion.
 *
 * <p>This module deals with conversion between the following character sets:
 *
 * <p>- Half-width group: - Alphabets, numerics, and symbols: U+0020 - U+007E, U+00A5, and U+203E. -
 * Half-width katakanas: U+FF61 - U+FF9F. - Full-width group: - Full-width alphabets, numerics, and
 * symbols: U+FF01 - U+FF5E, U+FFE3, and U+FFE5. - Wave dash: U+301C. - Hiraganas: U+3041 - U+3094.
 * - Katakanas: U+30A1 - U+30F7 and U+30FA. - Hiragana/katakana voicing marks: U+309B, U+309C, and
 * U+30FC. - Japanese punctuations: U+3001, U+3002, U+30A0, and U+30FB.
 */
@RegisteredTransliterator(name = "jisx0201-and-alike")
public class Jisx0201AndAlikeTransliterator implements Transliterator {

    // GL area mapping table (fullwidth to halfwidth)
    private static final String[][] JISX0201_GL_TABLE = {
        {"\u3000", "\u0020"}, // ideographic space -> space
        {"\uff01", "\u0021"}, // fullwidth exclamation -> !
        {"\uff02", "\""}, // fullwidth quotation mark
        {"\uff03", "\u0023"}, // fullwidth number sign -> #
        {"\uff04", "\u0024"}, // fullwidth dollar -> $
        {"\uff05", "\u0025"}, // fullwidth percent -> %
        {"\uff06", "\u0026"}, // fullwidth ampersand -> &
        {"\uff07", "\u0027"}, // fullwidth apostrophe -> '
        {"\uff08", "\u0028"}, // fullwidth left paren -> (
        {"\uff09", "\u0029"}, // fullwidth right paren -> )
        {"\uff0a", "\u002a"}, // fullwidth asterisk -> *
        {"\uff0b", "\u002b"}, // fullwidth plus -> +
        {"\uff0c", "\u002c"}, // fullwidth comma -> ,
        {"\uff0d", "\u002d"}, // fullwidth minus -> -
        {"\uff0e", "\u002e"}, // fullwidth period -> .
        {"\uff0f", "\u002f"}, // fullwidth slash -> /
        {"\uff10", "\u0030"}, // fullwidth 0 -> 0
        {"\uff11", "\u0031"}, // fullwidth 1 -> 1
        {"\uff12", "\u0032"}, // fullwidth 2 -> 2
        {"\uff13", "\u0033"}, // fullwidth 3 -> 3
        {"\uff14", "\u0034"}, // fullwidth 4 -> 4
        {"\uff15", "\u0035"}, // fullwidth 5 -> 5
        {"\uff16", "\u0036"}, // fullwidth 6 -> 6
        {"\uff17", "\u0037"}, // fullwidth 7 -> 7
        {"\uff18", "\u0038"}, // fullwidth 8 -> 8
        {"\uff19", "\u0039"}, // fullwidth 9 -> 9
        {"\uff1a", "\u003a"}, // fullwidth colon -> :
        {"\uff1b", "\u003b"}, // fullwidth semicolon -> ;
        {"\uff1c", "\u003c"}, // fullwidth less-than -> <
        {"\uff1d", "\u003d"}, // fullwidth equals -> =
        {"\uff1e", "\u003e"}, // fullwidth greater-than -> >
        {"\uff1f", "\u003f"}, // fullwidth question -> ?
        {"\uff20", "\u0040"}, // fullwidth at -> @
        {"\uff21", "\u0041"}, // fullwidth A -> A
        {"\uff22", "\u0042"}, // fullwidth B -> B
        {"\uff23", "\u0043"}, // fullwidth C -> C
        {"\uff24", "\u0044"}, // fullwidth D -> D
        {"\uff25", "\u0045"}, // fullwidth E -> E
        {"\uff26", "\u0046"}, // fullwidth F -> F
        {"\uff27", "\u0047"}, // fullwidth G -> G
        {"\uff28", "\u0048"}, // fullwidth H -> H
        {"\uff29", "\u0049"}, // fullwidth I -> I
        {"\uff2a", "\u004a"}, // fullwidth J -> J
        {"\uff2b", "\u004b"}, // fullwidth K -> K
        {"\uff2c", "\u004c"}, // fullwidth L -> L
        {"\uff2d", "\u004d"}, // fullwidth M -> M
        {"\uff2e", "\u004e"}, // fullwidth N -> N
        {"\uff2f", "\u004f"}, // fullwidth O -> O
        {"\uff30", "\u0050"}, // fullwidth P -> P
        {"\uff31", "\u0051"}, // fullwidth Q -> Q
        {"\uff32", "\u0052"}, // fullwidth R -> R
        {"\uff33", "\u0053"}, // fullwidth S -> S
        {"\uff34", "\u0054"}, // fullwidth T -> T
        {"\uff35", "\u0055"}, // fullwidth U -> U
        {"\uff36", "\u0056"}, // fullwidth V -> V
        {"\uff37", "\u0057"}, // fullwidth W -> W
        {"\uff38", "\u0058"}, // fullwidth X -> X
        {"\uff39", "\u0059"}, // fullwidth Y -> Y
        {"\uff3a", "\u005a"}, // fullwidth Z -> Z
        {"\uff3b", "\u005b"}, // fullwidth left bracket -> [
        {"\uff3d", "\u005d"}, // fullwidth right bracket -> ]
        {"\uff3e", "\u005e"}, // fullwidth circumflex -> ^
        {"\uff3f", "\u005f"}, // fullwidth underscore -> _
        {"\uff40", "\u0060"}, // fullwidth grave -> `
        {"\uff41", "\u0061"}, // fullwidth a -> a
        {"\uff42", "\u0062"}, // fullwidth b -> b
        {"\uff43", "\u0063"}, // fullwidth c -> c
        {"\uff44", "\u0064"}, // fullwidth d -> d
        {"\uff45", "\u0065"}, // fullwidth e -> e
        {"\uff46", "\u0066"}, // fullwidth f -> f
        {"\uff47", "\u0067"}, // fullwidth g -> g
        {"\uff48", "\u0068"}, // fullwidth h -> h
        {"\uff49", "\u0069"}, // fullwidth i -> i
        {"\uff4a", "\u006a"}, // fullwidth j -> j
        {"\uff4b", "\u006b"}, // fullwidth k -> k
        {"\uff4c", "\u006c"}, // fullwidth l -> l
        {"\uff4d", "\u006d"}, // fullwidth m -> m
        {"\uff4e", "\u006e"}, // fullwidth n -> n
        {"\uff4f", "\u006f"}, // fullwidth o -> o
        {"\uff50", "\u0070"}, // fullwidth p -> p
        {"\uff51", "\u0071"}, // fullwidth q -> q
        {"\uff52", "\u0072"}, // fullwidth r -> r
        {"\uff53", "\u0073"}, // fullwidth s -> s
        {"\uff54", "\u0074"}, // fullwidth t -> t
        {"\uff55", "\u0075"}, // fullwidth u -> u
        {"\uff56", "\u0076"}, // fullwidth v -> v
        {"\uff57", "\u0077"}, // fullwidth w -> w
        {"\uff58", "\u0078"}, // fullwidth x -> x
        {"\uff59", "\u0079"}, // fullwidth y -> y
        {"\uff5a", "\u007a"}, // fullwidth z -> z
        {"\uff5b", "\u007b"}, // fullwidth left brace -> {
        {"\uff5c", "\u007c"}, // fullwidth vertical bar -> |
        {"\uff5d", "\u007d"}, // fullwidth right brace -> }
    };

    // GR area mapping table (fullwidth to halfwidth)
    private static final String[][] JISX0201_GR_TABLE = {
        {"\u3002", "\uff61"}, // ideographic period -> halfwidth
        // ideographic period
        {"\u300c", "\uff62"}, // left corner bracket -> halfwidth left corner bracket
        {"\u300d", "\uff63"}, // right corner bracket -> halfwidth right corner bracket
        {"\u3001", "\uff64"}, // ideographic comma -> halfwidth ideographic comma
        {"\u30fb", "\uff65"}, // katakana middle dot -> halfwidth katakana middle dot
        {"\u30fc", "\uff70"}, // katakana prolonged sound -> halfwidth katakana prolonged sound
        {"\u309b", "\uff9e"}, // voiced sound mark -> halfwidth voiced sound mark
        {"\u309c", "\uff9f"}, // semi-voiced sound mark -> halfwidth semi-voiced sound mark
        // Small kana
        {"\u30a1", "\uff67"}, // small katakana A -> halfwidth small katakana A
        {"\u30a3", "\uff68"}, // small katakana I -> halfwidth small katakana I
        {"\u30a5", "\uff69"}, // small katakana U -> halfwidth small katakana U
        {"\u30a7", "\uff6a"}, // small katakana E -> halfwidth small katakana E
        {"\u30a9", "\uff6b"}, // small katakana O -> halfwidth small katakana O
        {"\u30e3", "\uff6c"}, // small katakana YA -> halfwidth small katakana YA
        {"\u30e5", "\uff6d"}, // small katakana YU -> halfwidth small katakana YU
        {"\u30e7", "\uff6e"}, // small katakana YO -> halfwidth small katakana YO
        {"\u30c3", "\uff6f"}, // small katakana TU -> halfwidth small katakana TU
        // Vowels
        {"\u30a2", "\uff71"}, // katakana A -> halfwidth katakana A
        {"\u30a4", "\uff72"}, // katakana I -> halfwidth katakana I
        {"\u30a6", "\uff73"}, // katakana U -> halfwidth katakana U
        {"\u30a8", "\uff74"}, // katakana E -> halfwidth katakana E
        {"\u30aa", "\uff75"}, // katakana O -> halfwidth katakana O
        // K-row
        {"\u30ab", "\uff76"}, // katakana KA -> halfwidth katakana KA
        {"\u30ad", "\uff77"}, // katakana KI -> halfwidth katakana KI
        {"\u30af", "\uff78"}, // katakana KU -> halfwidth katakana KU
        {"\u30b1", "\uff79"}, // katakana KE -> halfwidth katakana KE
        {"\u30b3", "\uff7a"}, // katakana KO -> halfwidth katakana KO
        // S-row
        {"\u30b5", "\uff7b"}, // katakana SA -> halfwidth katakana SA
        {"\u30b7", "\uff7c"}, // katakana SI -> halfwidth katakana SI
        {"\u30b9", "\uff7d"}, // katakana SU -> halfwidth katakana SU
        {"\u30bb", "\uff7e"}, // katakana SE -> halfwidth katakana SE
        {"\u30bd", "\uff7f"}, // katakana SO -> halfwidth katakana SO
        // T-row
        {"\u30bf", "\uff80"}, // katakana TA -> halfwidth katakana TA
        {"\u30c1", "\uff81"}, // katakana TI -> halfwidth katakana TI
        {"\u30c4", "\uff82"}, // katakana TU -> halfwidth katakana TU
        {"\u30c6", "\uff83"}, // katakana TE -> halfwidth katakana TE
        {"\u30c8", "\uff84"}, // katakana TO -> halfwidth katakana TO
        // N-row
        {"\u30ca", "\uff85"}, // katakana NA -> halfwidth katakana NA
        {"\u30cb", "\uff86"}, // katakana NI -> halfwidth katakana NI
        {"\u30cc", "\uff87"}, // katakana NU -> halfwidth katakana NU
        {"\u30cd", "\uff88"}, // katakana NE -> halfwidth katakana NE
        {"\u30ce", "\uff89"}, // katakana NO -> halfwidth katakana NO
        // H-row
        {"\u30cf", "\uff8a"}, // katakana HA -> halfwidth katakana HA
        {"\u30d2", "\uff8b"}, // katakana HI -> halfwidth katakana HI
        {"\u30d5", "\uff8c"}, // katakana HU -> halfwidth katakana HU
        {"\u30d8", "\uff8d"}, // katakana HE -> halfwidth katakana HE
        {"\u30db", "\uff8e"}, // katakana HO -> halfwidth katakana HO
        // M-row
        {"\u30de", "\uff8f"}, // katakana MA -> halfwidth katakana MA
        {"\u30df", "\uff90"}, // katakana MI -> halfwidth katakana MI
        {"\u30e0", "\uff91"}, // katakana MU -> halfwidth katakana MU
        {"\u30e1", "\uff92"}, // katakana ME -> halfwidth katakana ME
        {"\u30e2", "\uff93"}, // katakana MO -> halfwidth katakana MO
        // Y-row
        {"\u30e4", "\uff94"}, // katakana YA -> halfwidth katakana YA
        {"\u30e6", "\uff95"}, // katakana YU -> halfwidth katakana YU
        {"\u30e8", "\uff96"}, // katakana YO -> halfwidth katakana YO
        // R-row
        {"\u30e9", "\uff97"}, // katakana RA -> halfwidth katakana RA
        {"\u30ea", "\uff98"}, // katakana RI -> halfwidth katakana RI
        {"\u30eb", "\uff99"}, // katakana RU -> halfwidth katakana RU
        {"\u30ec", "\uff9a"}, // katakana RE -> halfwidth katakana RE
        {"\u30ed", "\uff9b"}, // katakana RO -> halfwidth katakana RO
        // W-row
        {"\u30ef", "\uff9c"}, // katakana WA -> halfwidth katakana WA
        {"\u30f3", "\uff9d"}, // katakana N -> halfwidth katakana N
        {"\u30f2", "\uff66"}, // katakana WO -> halfwidth katakana WO
    };

    // Voiced letters table
    private static final String[][] VOICED_LETTERS_TABLE = {
        {"\u30f4", "\uff73\uff9e"}, // katakana VU -> U + voiced
        // mark
        // G-row
        {"\u30ac", "\uff76\uff9e"}, // katakana GA -> KA + voiced mark
        {"\u30ae", "\uff77\uff9e"}, // katakana GI -> KI + voiced mark
        {"\u30b0", "\uff78\uff9e"}, // katakana GU -> KU + voiced mark
        {"\u30b2", "\uff79\uff9e"}, // katakana GE -> KE + voiced mark
        {"\u30b4", "\uff7a\uff9e"}, // katakana GO -> KO + voiced mark
        // Z-row
        {"\u30b6", "\uff7b\uff9e"}, // katakana ZA -> SA + voiced mark
        {"\u30b8", "\uff7c\uff9e"}, // katakana ZI -> SI + voiced mark
        {"\u30ba", "\uff7d\uff9e"}, // katakana ZU -> SU + voiced mark
        {"\u30bc", "\uff7e\uff9e"}, // katakana ZE -> SE + voiced mark
        {"\u30be", "\uff7f\uff9e"}, // katakana ZO -> SO + voiced mark
        // D-row
        {"\u30c0", "\uff80\uff9e"}, // katakana DA -> TA + voiced mark
        {"\u30c2", "\uff81\uff9e"}, // katakana DI -> TI + voiced mark
        {"\u30c5", "\uff82\uff9e"}, // katakana DU -> TU + voiced mark
        {"\u30c7", "\uff83\uff9e"}, // katakana DE -> TE + voiced mark
        {"\u30c9", "\uff84\uff9e"}, // katakana DO -> TO + voiced mark
        // B-row
        {"\u30d0", "\uff8a\uff9e"}, // katakana BA -> HA + voiced mark
        {"\u30d3", "\uff8b\uff9e"}, // katakana BI -> HI + voiced mark
        {"\u30d6", "\uff8c\uff9e"}, // katakana BU -> HU + voiced mark
        {"\u30d9", "\uff8d\uff9e"}, // katakana BE -> HE + voiced mark
        {"\u30dc", "\uff8e\uff9e"}, // katakana BO -> HO + voiced mark
        // P-row
        {"\u30d1", "\uff8a\uff9f"}, // katakana PA -> HA + semi-voiced mark
        {"\u30d4", "\uff8b\uff9f"}, // katakana PI -> HI + semi-voiced mark
        {"\u30d7", "\uff8c\uff9f"}, // katakana PU -> HU + semi-voiced mark
        {"\u30da", "\uff8d\uff9f"}, // katakana PE -> HE + semi-voiced mark
        {"\u30dd", "\uff8e\uff9f"}, // katakana PO -> HO + semi-voiced mark
        {"\u30fa", "\uff66\uff9e"}, // katakana WO + voiced mark
    };

    // Hiragana mappings
    private static final String[][] HIRAGANA_TABLE = {
        // Small hiragana
        {"\u3041", "\uff67"}, // small hiragana A -> halfwidth small katakana A
        {"\u3043", "\uff68"}, // small hiragana I -> halfwidth small katakana I
        {"\u3045", "\uff69"}, // small hiragana U -> halfwidth small katakana U
        {"\u3047", "\uff6a"}, // small hiragana E -> halfwidth small katakana E
        {"\u3049", "\uff6b"}, // small hiragana O -> halfwidth small katakana O
        {"\u3083", "\uff6c"}, // small hiragana YA -> halfwidth small katakana YA
        {"\u3085", "\uff6d"}, // small hiragana YU -> halfwidth small katakana YU
        {"\u3087", "\uff6e"}, // small hiragana YO -> halfwidth small katakana YO
        {"\u3063", "\uff6f"}, // small hiragana TU -> halfwidth small katakana TU
        // Vowels
        {"\u3042", "\uff71"}, // hiragana A -> halfwidth katakana A
        {"\u3044", "\uff72"}, // hiragana I -> halfwidth katakana I
        {"\u3046", "\uff73"}, // hiragana U -> halfwidth katakana U
        {"\u3048", "\uff74"}, // hiragana E -> halfwidth katakana E
        {"\u304a", "\uff75"}, // hiragana O -> halfwidth katakana O
        // K-row
        {"\u304b", "\uff76"}, // hiragana KA -> halfwidth katakana KA
        {"\u304d", "\uff77"}, // hiragana KI -> halfwidth katakana KI
        {"\u304f", "\uff78"}, // hiragana KU -> halfwidth katakana KU
        {"\u3051", "\uff79"}, // hiragana KE -> halfwidth katakana KE
        {"\u3053", "\uff7a"}, // hiragana KO -> halfwidth katakana KO
        // S-row
        {"\u3055", "\uff7b"}, // hiragana SA -> halfwidth katakana SA
        {"\u3057", "\uff7c"}, // hiragana SI -> halfwidth katakana SI
        {"\u3059", "\uff7d"}, // hiragana SU -> halfwidth katakana SU
        {"\u305b", "\uff7e"}, // hiragana SE -> halfwidth katakana SE
        {"\u305d", "\uff7f"}, // hiragana SO -> halfwidth katakana SO
        // T-row
        {"\u305f", "\uff80"}, // hiragana TA -> halfwidth katakana TA
        {"\u3061", "\uff81"}, // hiragana TI -> halfwidth katakana TI
        {"\u3064", "\uff82"}, // hiragana TU -> halfwidth katakana TU
        {"\u3066", "\uff83"}, // hiragana TE -> halfwidth katakana TE
        {"\u3068", "\uff84"}, // hiragana TO -> halfwidth katakana TO
        // N-row
        {"\u306a", "\uff85"}, // hiragana NA -> halfwidth katakana NA
        {"\u306b", "\uff86"}, // hiragana NI -> halfwidth katakana NI
        {"\u306c", "\uff87"}, // hiragana NU -> halfwidth katakana NU
        {"\u306d", "\uff88"}, // hiragana NE -> halfwidth katakana NE
        {"\u306e", "\uff89"}, // hiragana NO -> halfwidth katakana NO
        // H-row
        {"\u306f", "\uff8a"}, // hiragana HA -> halfwidth katakana HA
        {"\u3072", "\uff8b"}, // hiragana HI -> halfwidth katakana HI
        {"\u3075", "\uff8c"}, // hiragana HU -> halfwidth katakana HU
        {"\u3078", "\uff8d"}, // hiragana HE -> halfwidth katakana HE
        {"\u307b", "\uff8e"}, // hiragana HO -> halfwidth katakana HO
        // M-row
        {"\u307e", "\uff8f"}, // hiragana MA -> halfwidth katakana MA
        {"\u307f", "\uff90"}, // hiragana MI -> halfwidth katakana MI
        {"\u3080", "\uff91"}, // hiragana MU -> halfwidth katakana MU
        {"\u3081", "\uff92"}, // hiragana ME -> halfwidth katakana ME
        {"\u3082", "\uff93"}, // hiragana MO -> halfwidth katakana MO
        // Y-row
        {"\u3084", "\uff94"}, // hiragana YA -> halfwidth katakana YA
        {"\u3086", "\uff95"}, // hiragana YU -> halfwidth katakana YU
        {"\u3088", "\uff96"}, // hiragana YO -> halfwidth katakana YO
        // R-row
        {"\u3089", "\uff97"}, // hiragana RA -> halfwidth katakana RA
        {"\u308a", "\uff98"}, // hiragana RI -> halfwidth katakana RI
        {"\u308b", "\uff99"}, // hiragana RU -> halfwidth katakana RU
        {"\u308c", "\uff9a"}, // hiragana RE -> halfwidth katakana RE
        {"\u308d", "\uff9b"}, // hiragana RO -> halfwidth katakana RO
        // W-row
        {"\u308f", "\uff9c"}, // hiragana WA -> halfwidth katakana WA
        {"\u3093", "\uff9d"}, // hiragana N -> halfwidth katakana N
        {"\u3092", "\uff66"}, // hiragana WO -> halfwidth katakana WO
        // Voiced
        {"\u3094", "\uff73\uff9e"}, // hiragana VU -> U + voiced mark
        // Voiced K (G)
        {"\u304c", "\uff76\uff9e"}, // hiragana GA -> KA + voiced mark
        {"\u304e", "\uff77\uff9e"}, // hiragana GI -> KI + voiced mark
        {"\u3050", "\uff78\uff9e"}, // hiragana GU -> KU + voiced mark
        {"\u3052", "\uff79\uff9e"}, // hiragana GE -> KE + voiced mark
        {"\u3054", "\uff7a\uff9e"}, // hiragana GO -> KO + voiced mark
        // Voiced S (Z)
        {"\u3056", "\uff7b\uff9e"}, // hiragana ZA -> SA + voiced mark
        {"\u3058", "\uff7c\uff9e"}, // hiragana ZI -> SI + voiced mark
        {"\u305a", "\uff7d\uff9e"}, // hiragana ZU -> SU + voiced mark
        {"\u305c", "\uff7e\uff9e"}, // hiragana ZE -> SE + voiced mark
        {"\u305e", "\uff7f\uff9e"}, // hiragana ZO -> SO + voiced mark
        // Voiced T (D)
        {"\u3060", "\uff80\uff9e"}, // hiragana DA -> TA + voiced mark
        {"\u3062", "\uff81\uff9e"}, // hiragana DI -> TI + voiced mark
        {"\u3065", "\uff82\uff9e"}, // hiragana DU -> TU + voiced mark
        {"\u3067", "\uff83\uff9e"}, // hiragana DE -> TE + voiced mark
        {"\u3069", "\uff84\uff9e"}, // hiragana DO -> TO + voiced mark
        // Voiced H (B)
        {"\u3070", "\uff8a\uff9e"}, // hiragana BA -> HA + voiced mark
        {"\u3073", "\uff8b\uff9e"}, // hiragana BI -> HI + voiced mark
        {"\u3076", "\uff8c\uff9e"}, // hiragana BU -> HU + voiced mark
        {"\u3079", "\uff8d\uff9e"}, // hiragana BE -> HE + voiced mark
        {"\u307c", "\uff8e\uff9e"}, // hiragana BO -> HO + voiced mark
        // Half-voiced H (P)
        {"\u3071", "\uff8a\uff9f"}, // hiragana PA -> HA + semi-voiced mark
        {"\u3074", "\uff8b\uff9f"}, // hiragana PI -> HI + semi-voiced mark
        {"\u3077", "\uff8c\uff9f"}, // hiragana PU -> HU + semi-voiced mark
        {"\u307a", "\uff8d\uff9f"}, // hiragana PE -> HE + semi-voiced mark
        {"\u307d", "\uff8e\uff9f"}, // hiragana PO -> HO + semi-voiced mark
    };

    // Special punctuations
    private static final String[][] SPECIAL_PUNCTUATIONS_TABLE = {
        {"\u30a0", "\u003d"}, // katakana-hiragana double
        // hyphen -> equals sign
    };

    // GL overrides
    private static final Map<String, String[][]> GL_OVERRIDES = new HashMap<>();

    static {
        GL_OVERRIDES.put("u005cAsYenSign", new String[][] {{"\uffe5", "\\"}});
        GL_OVERRIDES.put("u005cAsBackslash", new String[][] {{"\uff3c", "\\"}});
        GL_OVERRIDES.put("u007eAsFullwidthTilde", new String[][] {{"\uff5e", "\u007e"}});
        GL_OVERRIDES.put("u007eAsWaveDash", new String[][] {{"\u301c", "\u007e"}});
        GL_OVERRIDES.put("u007eAsOverline", new String[][] {{"\u203e", "\u007e"}});
        GL_OVERRIDES.put("u007eAsFullwidthMacron", new String[][] {{"\uffe3", "\u007e"}});
        GL_OVERRIDES.put("u00a5AsYenSign", new String[][] {{"\uffe5", "\u00a5"}});
    }

    /** Options for configuring the behavior of Jisx0201AndAlikeTransliterator. */
    public static class Options {
        private boolean fullwidthToHalfwidth;
        private boolean convertGL = true;
        private boolean convertGR = true;
        private Optional<Boolean> convertUnsafeSpecials = Optional.empty();
        private boolean convertHiraganas = false;
        private boolean combineVoicedSoundMarks = true;
        private Optional<Boolean> u005cAsYenSign = Optional.empty();
        private Optional<Boolean> u005cAsBackslash = Optional.empty();
        private Optional<Boolean> u007eAsFullwidthTilde = Optional.empty();
        private Optional<Boolean> u007eAsWaveDash = Optional.empty();
        private Optional<Boolean> u007eAsOverline = Optional.empty();
        private Optional<Boolean> u007eAsFullwidthMacron = Optional.empty();
        private Optional<Boolean> u00a5AsYenSign = Optional.empty();

        /**
         * Creates a new Options instance with default settings. By default, fullwidth to halfwidth
         * conversion is enabled with GL and GR conversion.
         */
        public Options() {
            this(true);
        }

        /**
         * Creates a new Options instance with the specified conversion direction.
         *
         * @param fullwidthToHalfwidth if true, convert fullwidth to halfwidth; if false, convert
         *     halfwidth to fullwidth
         */
        public Options(boolean fullwidthToHalfwidth) {
            this.fullwidthToHalfwidth = fullwidthToHalfwidth;
        }

        private Options(ForwardOptions forwardOptions) {
            this.fullwidthToHalfwidth = true;
            this.convertGL = forwardOptions.convertGL;
            this.convertGR = forwardOptions.convertGR;
            this.convertUnsafeSpecials = Optional.of(forwardOptions.convertUnsafeSpecials);
            this.convertHiraganas = forwardOptions.convertHiraganas;
            this.u005cAsYenSign = Optional.of(forwardOptions.u005cAsYenSign);
            this.u005cAsBackslash = Optional.of(forwardOptions.u005cAsBackslash);
            this.u007eAsFullwidthTilde = Optional.of(forwardOptions.u007eAsFullwidthTilde);
            this.u007eAsWaveDash = Optional.of(forwardOptions.u007eAsWaveDash);
            this.u007eAsOverline = Optional.of(forwardOptions.u007eAsOverline);
            this.u007eAsFullwidthMacron = Optional.of(forwardOptions.u007eAsFullwidthMacron);
            this.u00a5AsYenSign = Optional.of(forwardOptions.u00a5AsYenSign);
        }

        private Options(ReverseOptions reverseOptions) {
            this.fullwidthToHalfwidth = true;
            this.convertGL = reverseOptions.convertGL;
            this.convertGR = reverseOptions.convertGR;
            this.convertUnsafeSpecials = Optional.of(reverseOptions.convertUnsafeSpecials);
            this.combineVoicedSoundMarks = reverseOptions.combineVoicedSoundMarks;
            this.u005cAsYenSign = Optional.of(reverseOptions.u005cAsYenSign);
            this.u005cAsBackslash = Optional.of(reverseOptions.u005cAsBackslash);
            this.u007eAsFullwidthTilde = Optional.of(reverseOptions.u007eAsFullwidthTilde);
            this.u007eAsWaveDash = Optional.of(reverseOptions.u007eAsWaveDash);
            this.u007eAsOverline = Optional.of(reverseOptions.u007eAsOverline);
            this.u007eAsFullwidthMacron = Optional.of(reverseOptions.u007eAsFullwidthMacron);
            this.u00a5AsYenSign = Optional.of(reverseOptions.u00a5AsYenSign);
        }

        private Options copy() {
            final Options options = new Options();
            options.fullwidthToHalfwidth = this.fullwidthToHalfwidth;
            options.convertGL = this.convertGL;
            options.convertGR = this.convertGR;
            options.convertUnsafeSpecials = this.convertUnsafeSpecials;
            options.convertHiraganas = this.convertHiraganas;
            options.combineVoicedSoundMarks = this.combineVoicedSoundMarks;
            options.u005cAsYenSign = this.u005cAsYenSign;
            options.u005cAsBackslash = this.u005cAsBackslash;
            options.u007eAsFullwidthTilde = this.u007eAsFullwidthTilde;
            options.u007eAsWaveDash = this.u007eAsWaveDash;
            options.u007eAsOverline = this.u007eAsOverline;
            options.u007eAsFullwidthMacron = this.u007eAsFullwidthMacron;
            options.u00a5AsYenSign = this.u00a5AsYenSign;
            return options;
        }

        /**
         * Returns whether the conversion is from fullwidth to halfwidth.
         *
         * @return true if converting fullwidth to halfwidth, false otherwise
         */
        public boolean isFullwidthToHalfwidth() {
            return fullwidthToHalfwidth;
        }

        /**
         * Returns whether GL area characters should be converted.
         *
         * @return true if GL area characters should be converted, false otherwise
         */
        public boolean isConvertGL() {
            return convertGL;
        }

        /**
         * Returns whether GR area characters should be converted.
         *
         * @return true if GR area characters should be converted, false otherwise
         */
        public boolean isConvertGR() {
            return convertGR;
        }

        /**
         * Returns whether unsafe special characters should be converted.
         *
         * @return true if unsafe special characters should be converted, false otherwise
         */
        public Optional<Boolean> isConvertUnsafeSpecials() {
            return convertUnsafeSpecials;
        }

        /**
         * Returns whether hiragana characters should be converted.
         *
         * @return true if hiragana characters should be converted, false otherwise
         */
        public boolean isConvertHiraganas() {
            return convertHiraganas;
        }

        /**
         * Returns whether voiced sound marks should be combined.
         *
         * @return true if voiced sound marks should be combined, false otherwise
         */
        public boolean isCombineVoicedSoundMarks() {
            return combineVoicedSoundMarks;
        }

        /**
         * Returns whether backslash (U+005C) should be treated as yen sign.
         *
         * @return true if backslash should be treated as yen sign, false otherwise
         */
        public Optional<Boolean> isU005cAsYenSign() {
            return u005cAsYenSign;
        }

        /**
         * Returns whether backslash (U+005C) should be treated as backslash.
         *
         * @return true if backslash should be treated as backslash, false otherwise
         */
        public Optional<Boolean> isU005cAsBackslash() {
            return u005cAsBackslash;
        }

        /**
         * Returns whether tilde (U+007E) should be treated as fullwidth tilde.
         *
         * @return true if tilde should be treated as fullwidth tilde, false otherwise
         */
        public Optional<Boolean> isU007eAsFullwidthTilde() {
            return u007eAsFullwidthTilde;
        }

        /**
         * Returns whether tilde (U+007E) should be treated as wave dash.
         *
         * @return true if tilde should be treated as wave dash, false otherwise
         */
        public Optional<Boolean> isU007eAsWaveDash() {
            return u007eAsWaveDash;
        }

        /**
         * Returns whether tilde (U+007E) should be treated as overline.
         *
         * @return true if tilde should be treated as overline, false otherwise
         */
        public Optional<Boolean> isU007eAsOverline() {
            return u007eAsOverline;
        }

        /**
         * Returns whether tilde (U+007E) should be treated as fullwidth macron.
         *
         * @return true if tilde should be treated as fullwidth macron, false otherwise
         */
        public Optional<Boolean> isU007eAsFullwidthMacron() {
            return u007eAsFullwidthMacron;
        }

        /**
         * Returns whether yen sign (U+00A5) should be treated as yen sign.
         *
         * @return true if yen sign should be treated as yen sign, false otherwise
         */
        public Optional<Boolean> isU00a5AsYenSign() {
            return u00a5AsYenSign;
        }

        /**
         * Creates a new Options instance with the specified fullwidth to halfwidth setting.
         *
         * @param fullwidthToHalfwidth the new fullwidth to halfwidth setting
         * @return a new Options instance with the updated setting
         */
        public Options withFullwidthToHalfwidth(boolean fullwidthToHalfwidth) {
            final Options options = copy();
            options.fullwidthToHalfwidth = fullwidthToHalfwidth;
            return options;
        }

        /**
         * Creates a new Options instance with the specified GL conversion setting.
         *
         * @param convertGL the new GL conversion setting
         * @return a new Options instance with the updated setting
         */
        public Options withConvertGL(boolean convertGL) {
            final Options options = copy();
            options.convertGL = convertGL;
            return options;
        }

        /**
         * Creates a new Options instance with the specified GR conversion setting.
         *
         * @param convertGR the new GR conversion setting
         * @return a new Options instance with the updated setting
         */
        public Options withConvertGR(boolean convertGR) {
            final Options options = copy();
            options.convertGR = convertGR;
            return options;
        }

        /**
         * Creates a new Options instance with the specified unsafe specials conversion setting.
         *
         * @param convertUnsafeSpecials the new unsafe specials conversion setting
         * @return a new Options instance with the updated setting
         */
        public Options withConvertUnsafeSpecials(boolean convertUnsafeSpecials) {
            final Options options = copy();
            options.convertUnsafeSpecials = Optional.of(convertUnsafeSpecials);
            return options;
        }

        /**
         * Creates a new Options instance with the specified hiragana conversion setting.
         *
         * @param convertHiraganas the new hiragana conversion setting
         * @return a new Options instance with the updated setting
         */
        public Options withConvertHiraganas(boolean convertHiraganas) {
            final Options options = copy();
            options.convertHiraganas = convertHiraganas;
            return options;
        }

        /**
         * Creates a new Options instance with the specified voiced sound marks combination setting.
         *
         * @param combineVoicedSoundMarks the new voiced sound marks combination setting
         * @return a new Options instance with the updated setting
         */
        public Options withCombineVoicedSoundMarks(boolean combineVoicedSoundMarks) {
            final Options options = copy();
            options.combineVoicedSoundMarks = combineVoicedSoundMarks;
            return options;
        }

        /**
         * Creates a new Options instance with the specified backslash as yen sign setting.
         *
         * @param u005cAsYenSign the new backslash as yen sign setting
         * @return a new Options instance with the updated setting
         */
        public Options withU005cAsYenSign(boolean u005cAsYenSign) {
            final Options options = copy();
            options.u005cAsYenSign = Optional.of(u005cAsYenSign);
            return options;
        }

        /**
         * Creates a new Options instance with the specified backslash as backslash setting.
         *
         * @param u005cAsBackslash the new backslash as backslash setting
         * @return a new Options instance with the updated setting
         */
        public Options withU005cAsBackslash(boolean u005cAsBackslash) {
            final Options options = copy();
            options.u005cAsBackslash = Optional.of(u005cAsBackslash);
            return options;
        }

        /**
         * Creates a new Options instance with the specified tilde as fullwidth tilde setting.
         *
         * @param u007eAsFullwidthTilde the new tilde as fullwidth tilde setting
         * @return a new Options instance with the updated setting
         */
        public Options withU007eAsFullwidthTilde(boolean u007eAsFullwidthTilde) {
            final Options options = copy();
            options.u007eAsFullwidthTilde = Optional.of(u007eAsFullwidthTilde);
            return options;
        }

        /**
         * Creates a new Options instance with the specified tilde as wave dash setting.
         *
         * @param u007eAsWaveDash the new tilde as wave dash setting
         * @return a new Options instance with the updated setting
         */
        public Options withU007eAsWaveDash(boolean u007eAsWaveDash) {
            final Options options = copy();
            options.u007eAsWaveDash = Optional.of(u007eAsWaveDash);
            return options;
        }

        /**
         * Creates a new Options instance with the specified tilde as overline setting.
         *
         * @param u007eAsOverline the new tilde as overline setting
         * @return a new Options instance with the updated setting
         */
        public Options withU007eAsOverline(boolean u007eAsOverline) {
            final Options options = copy();
            options.u007eAsOverline = Optional.of(u007eAsOverline);
            return options;
        }

        /**
         * Creates a new Options instance with the specified tilde as fullwidth macron setting.
         *
         * @param u007eAsFullwidthMacron the new tilde as fullwidth macron setting
         * @return a new Options instance with the updated setting
         */
        public Options withU007eAsFullwidthMacron(boolean u007eAsFullwidthMacron) {
            final Options options = copy();
            options.u007eAsFullwidthMacron = Optional.of(u007eAsFullwidthMacron);
            return options;
        }

        /**
         * Creates a new Options instance with the specified yen sign as yen sign setting.
         *
         * @param u00a5AsYenSign the new yen sign as yen sign setting
         * @return a new Options instance with the updated setting
         */
        public Options withU00a5AsYenSign(boolean u00a5AsYenSign) {
            final Options options = copy();
            options.u00a5AsYenSign = Optional.of(u00a5AsYenSign);
            return options;
        }

        private ForwardOptions buildForwardOptions() {
            return new ForwardOptions(
                    this.convertGL,
                    this.convertGR,
                    this.convertUnsafeSpecials.orElse(true),
                    this.convertHiraganas,
                    this.u005cAsYenSign.orElseGet(() -> this.u00a5AsYenSign.isEmpty()),
                    this.u005cAsBackslash.orElse(false),
                    this.u007eAsFullwidthTilde.orElse(true),
                    this.u007eAsWaveDash.orElse(true),
                    this.u007eAsOverline.orElse(false),
                    this.u007eAsFullwidthMacron.orElse(false),
                    this.u00a5AsYenSign.orElse(false));
        }

        private ReverseOptions buildReverseOptions() {
            return new ReverseOptions(
                    this.convertGL,
                    this.convertGR,
                    this.convertUnsafeSpecials.orElse(false),
                    this.combineVoicedSoundMarks,
                    this.u005cAsYenSign.orElseGet(() -> this.u005cAsBackslash.isEmpty()),
                    this.u005cAsBackslash.orElse(false),
                    this.u007eAsFullwidthTilde.orElseGet(
                            () ->
                                    this.u007eAsWaveDash.isEmpty()
                                            && this.u007eAsOverline.isEmpty()
                                            && this.u007eAsFullwidthMacron.isEmpty()),
                    this.u007eAsWaveDash.orElse(false),
                    this.u007eAsOverline.orElse(false),
                    this.u007eAsFullwidthMacron.orElse(false),
                    this.u00a5AsYenSign.orElse(true));
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            Options options = (Options) obj;
            return fullwidthToHalfwidth == options.fullwidthToHalfwidth
                    && convertGL == options.convertGL
                    && convertGR == options.convertGR
                    && convertUnsafeSpecials.equals(options.convertUnsafeSpecials)
                    && convertHiraganas == options.convertHiraganas
                    && combineVoicedSoundMarks == options.combineVoicedSoundMarks
                    && u005cAsYenSign.equals(options.u005cAsYenSign)
                    && u005cAsBackslash.equals(options.u005cAsBackslash)
                    && u007eAsFullwidthTilde.equals(options.u007eAsFullwidthTilde)
                    && u007eAsWaveDash.equals(options.u007eAsWaveDash)
                    && u007eAsOverline.equals(options.u007eAsOverline)
                    && u007eAsFullwidthMacron.equals(options.u007eAsFullwidthMacron)
                    && u00a5AsYenSign.equals(options.u00a5AsYenSign);
        }

        @Override
        public int hashCode() {
            return Objects.hash(
                    fullwidthToHalfwidth,
                    convertGL,
                    convertGR,
                    convertUnsafeSpecials,
                    convertHiraganas,
                    combineVoicedSoundMarks,
                    u005cAsYenSign,
                    u005cAsBackslash,
                    u007eAsFullwidthTilde,
                    u007eAsWaveDash,
                    u007eAsOverline,
                    u007eAsFullwidthMacron,
                    u00a5AsYenSign);
        }
    }

    /** Fullwidth to halfwidth conversion options */
    private static class ForwardOptions {
        private final boolean convertGL;
        private final boolean convertGR;
        private final boolean convertUnsafeSpecials;
        private final boolean convertHiraganas;
        private final boolean u005cAsYenSign;
        private final boolean u005cAsBackslash;
        private final boolean u007eAsFullwidthTilde;
        private final boolean u007eAsWaveDash;
        private final boolean u007eAsOverline;
        private final boolean u007eAsFullwidthMacron;
        private final boolean u00a5AsYenSign;

        @Override
        public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            ForwardOptions that = (ForwardOptions) obj;
            return convertGL == that.convertGL
                    && convertGR == that.convertGR
                    && convertUnsafeSpecials == that.convertUnsafeSpecials
                    && convertHiraganas == that.convertHiraganas
                    && u005cAsYenSign == that.u005cAsYenSign
                    && u005cAsBackslash == that.u005cAsBackslash
                    && u007eAsFullwidthTilde == that.u007eAsFullwidthTilde
                    && u007eAsWaveDash == that.u007eAsWaveDash
                    && u007eAsOverline == that.u007eAsOverline
                    && u007eAsFullwidthMacron == that.u007eAsFullwidthMacron
                    && u00a5AsYenSign == that.u00a5AsYenSign;
        }

        @Override
        public int hashCode() {
            return convertGL
                    ? 1
                    : 0
                            + (convertGR ? 2 : 0)
                            + (convertUnsafeSpecials ? 4 : 0)
                            + (convertHiraganas ? 8 : 0)
                            + (u005cAsYenSign ? 16 : 0)
                            + (u005cAsBackslash ? 32 : 0)
                            + (u007eAsFullwidthTilde ? 64 : 0)
                            + (u007eAsWaveDash ? 128 : 0)
                            + (u007eAsOverline ? 256 : 0)
                            + (u007eAsFullwidthMacron ? 512 : 0)
                            + (u00a5AsYenSign ? 1024 : 0);
        }

        private ForwardOptions(
                boolean convertGL,
                boolean convertGR,
                boolean convertUnsafeSpecials,
                boolean convertHiraganas,
                boolean u005cAsYenSign,
                boolean u005cAsBackslash,
                boolean u007eAsFullwidthTilde,
                boolean u007eAsWaveDash,
                boolean u007eAsOverline,
                boolean u007eAsFullwidthMacron,
                boolean u00a5AsYenSign) {
            this.convertGL = convertGL;
            this.convertGR = convertGR;
            this.convertUnsafeSpecials = convertUnsafeSpecials;
            this.convertHiraganas = convertHiraganas;
            this.u005cAsYenSign = u005cAsYenSign;
            this.u005cAsBackslash = u005cAsBackslash;
            this.u007eAsFullwidthTilde = u007eAsFullwidthTilde;
            this.u007eAsWaveDash = u007eAsWaveDash;
            this.u007eAsOverline = u007eAsOverline;
            this.u007eAsFullwidthMacron = u007eAsFullwidthMacron;
            this.u00a5AsYenSign = u00a5AsYenSign;
        }
    }

    /** Halfwidth to fullwidth conversion options */
    private static class ReverseOptions {
        private final boolean convertGL;
        private final boolean convertGR;
        private final boolean convertUnsafeSpecials;
        private final boolean combineVoicedSoundMarks;
        private final boolean u005cAsYenSign;
        private final boolean u005cAsBackslash;
        private final boolean u007eAsFullwidthTilde;
        private final boolean u007eAsWaveDash;
        private final boolean u007eAsOverline;
        private final boolean u007eAsFullwidthMacron;
        private final boolean u00a5AsYenSign;

        @Override
        public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            ReverseOptions that = (ReverseOptions) obj;
            return convertGL == that.convertGL
                    && convertGR == that.convertGR
                    && convertUnsafeSpecials == that.convertUnsafeSpecials
                    && combineVoicedSoundMarks == that.combineVoicedSoundMarks
                    && u005cAsYenSign == that.u005cAsYenSign
                    && u005cAsBackslash == that.u005cAsBackslash
                    && u007eAsFullwidthTilde == that.u007eAsFullwidthTilde
                    && u007eAsWaveDash == that.u007eAsWaveDash
                    && u007eAsOverline == that.u007eAsOverline
                    && u007eAsFullwidthMacron == that.u007eAsFullwidthMacron
                    && u00a5AsYenSign == that.u00a5AsYenSign;
        }

        @Override
        public int hashCode() {
            return convertGL
                    ? 1
                    : 0
                            + (convertGR ? 2 : 0)
                            + (convertUnsafeSpecials ? 4 : 0)
                            + (combineVoicedSoundMarks ? 8 : 0)
                            + (u005cAsYenSign ? 16 : 0)
                            + (u005cAsBackslash ? 32 : 0)
                            + (u007eAsFullwidthTilde ? 64 : 0)
                            + (u007eAsWaveDash ? 128 : 0)
                            + (u007eAsOverline ? 256 : 0)
                            + (u007eAsFullwidthMacron ? 512 : 0)
                            + (u00a5AsYenSign ? 1024 : 0);
        }

        private ReverseOptions(
                boolean convertGL,
                boolean convertGR,
                boolean convertUnsafeSpecials,
                boolean combineVoicedSoundMarks,
                boolean u005cAsYenSign,
                boolean u005cAsBackslash,
                boolean u007eAsFullwidthTilde,
                boolean u007eAsWaveDash,
                boolean u007eAsOverline,
                boolean u007eAsFullwidthMacron,
                boolean u00a5AsYenSign) {
            this.convertGL = convertGL;
            this.convertGR = convertGR;
            this.convertUnsafeSpecials = convertUnsafeSpecials;
            this.combineVoicedSoundMarks = combineVoicedSoundMarks;
            this.u005cAsYenSign = u005cAsYenSign;
            this.u005cAsBackslash = u005cAsBackslash;
            this.u007eAsFullwidthTilde = u007eAsFullwidthTilde;
            this.u007eAsWaveDash = u007eAsWaveDash;
            this.u007eAsOverline = u007eAsOverline;
            this.u007eAsFullwidthMacron = u007eAsFullwidthMacron;
            this.u00a5AsYenSign = u00a5AsYenSign;
        }
    }

    private final Optional<ForwardOptions> forwardOptions;
    private final Optional<ReverseOptions> reverseOptions;

    /** Creates a new Jisx0201AndAlikeTransliterator with default options. */
    public Jisx0201AndAlikeTransliterator() {
        this(new Options());
    }

    /**
     * Creates a new Jisx0201AndAlikeTransliterator with the specified options.
     *
     * @param options the options for configuring the transliterator behavior
     */
    public Jisx0201AndAlikeTransliterator(Options options) {
        this.forwardOptions =
                options.fullwidthToHalfwidth
                        ? Optional.of(options.buildForwardOptions())
                        : Optional.empty();
        this.reverseOptions =
                options.fullwidthToHalfwidth
                        ? Optional.empty()
                        : Optional.of(options.buildReverseOptions());
    }

    /**
     * Returns the normalized options for this transliterator.
     *
     * @return the normalized options
     */
    public Options getOptions() {
        return this.forwardOptions
                .map(Options::new)
                .or(() -> this.reverseOptions.map(Options::new))
                .orElseThrow();
    }

    private Map<Integer, String> buildForwardMappings(ForwardOptions opts) {
        Map<Integer, String> mappings = new HashMap<>();

        if (opts.convertGL) {
            // Add basic GL mappings
            for (String[] pair : JISX0201_GL_TABLE) {
                int codePoint = pair[0].codePointAt(0);
                mappings.put(codePoint, pair[1]);
            }

            // Add GL overrides
            if (opts.u005cAsYenSign) {
                addMappings(mappings, GL_OVERRIDES.get("u005cAsYenSign"));
            }
            if (opts.u005cAsBackslash) {
                addMappings(mappings, GL_OVERRIDES.get("u005cAsBackslash"));
            }
            if (opts.u007eAsFullwidthTilde) {
                addMappings(mappings, GL_OVERRIDES.get("u007eAsFullwidthTilde"));
            }
            if (opts.u007eAsWaveDash) {
                addMappings(mappings, GL_OVERRIDES.get("u007eAsWaveDash"));
            }
            if (opts.u007eAsOverline) {
                addMappings(mappings, GL_OVERRIDES.get("u007eAsOverline"));
            }
            if (opts.u007eAsFullwidthMacron) {
                addMappings(mappings, GL_OVERRIDES.get("u007eAsFullwidthMacron"));
            }
            if (opts.u00a5AsYenSign) {
                addMappings(mappings, GL_OVERRIDES.get("u00a5AsYenSign"));
            }
            if (opts.convertUnsafeSpecials) {
                for (String[] pair : SPECIAL_PUNCTUATIONS_TABLE) {
                    int codePoint = pair[0].codePointAt(0);
                    mappings.put(codePoint, pair[1]);
                }
            }
        }

        if (opts.convertGR) {
            // Add basic GR mappings
            for (String[] pair : JISX0201_GR_TABLE) {
                int codePoint = pair[0].codePointAt(0);
                mappings.put(codePoint, pair[1]);
            }
            // Add voiced letters
            for (String[] pair : VOICED_LETTERS_TABLE) {
                int codePoint = pair[0].codePointAt(0);
                mappings.put(codePoint, pair[1]);
            }
            // Add combining marks
            mappings.put(0x3099, "\uff9e"); // combining dakuten
            mappings.put(0x309a, "\uff9f"); // combining handakuten

            if (opts.convertHiraganas) {
                for (String[] pair : HIRAGANA_TABLE) {
                    int codePoint = pair[0].codePointAt(0);
                    mappings.put(codePoint, pair[1]);
                }
            }
        }

        return mappings;
    }

    private Map<Integer, Integer> buildReverseMappings(ReverseOptions opts) {
        Map<Integer, Integer> mappings = new HashMap<>();

        if (opts.convertGL) {
            // Add basic GL reverse mappings
            for (String[] pair : JISX0201_GL_TABLE) {
                int fromCodePoint = pair[1].codePointAt(0);
                int toCodePoint = pair[0].codePointAt(0);
                mappings.put(fromCodePoint, toCodePoint);
            }

            // Add GL overrides in reverse
            if (opts.u005cAsYenSign) {
                addReverseMappings(mappings, GL_OVERRIDES.get("u005cAsYenSign"));
            }
            if (opts.u005cAsBackslash) {
                addReverseMappings(mappings, GL_OVERRIDES.get("u005cAsBackslash"));
            }
            if (opts.u007eAsFullwidthTilde) {
                addReverseMappings(mappings, GL_OVERRIDES.get("u007eAsFullwidthTilde"));
            }
            if (opts.u007eAsWaveDash) {
                addReverseMappings(mappings, GL_OVERRIDES.get("u007eAsWaveDash"));
            }
            if (opts.u007eAsOverline) {
                addReverseMappings(mappings, GL_OVERRIDES.get("u007eAsOverline"));
            }
            if (opts.u007eAsFullwidthMacron) {
                addReverseMappings(mappings, GL_OVERRIDES.get("u007eAsFullwidthMacron"));
            }
            if (opts.u00a5AsYenSign) {
                addReverseMappings(mappings, GL_OVERRIDES.get("u00a5AsYenSign"));
            }
            if (opts.convertUnsafeSpecials) {
                for (String[] pair : SPECIAL_PUNCTUATIONS_TABLE) {
                    int fromCodePoint = pair[1].codePointAt(0);
                    int toCodePoint = pair[0].codePointAt(0);
                    mappings.put(fromCodePoint, toCodePoint);
                }
            }
        }

        if (opts.convertGR) {
            // Add basic GR reverse mappings
            for (String[] pair : JISX0201_GR_TABLE) {
                int fromCodePoint = pair[1].codePointAt(0);
                int toCodePoint = pair[0].codePointAt(0);
                mappings.put(fromCodePoint, toCodePoint);
            }
        }

        return mappings;
    }

    private Map<Integer, Map<Integer, Integer>> buildVoicedReverseMappings(ReverseOptions opts) {
        Map<Integer, Map<Integer, Integer>> mappings = new HashMap<>();

        if (opts.convertGR && opts.combineVoicedSoundMarks) {
            for (String[] pair : VOICED_LETTERS_TABLE) {
                // Parse the two-character sequence (base + mark)
                String halfwidth = pair[1];
                if (halfwidth.length() == 2) {
                    int baseChar = halfwidth.codePointAt(0);
                    int markChar = halfwidth.codePointAt(Character.charCount(baseChar));
                    int fullwidthChar = pair[0].codePointAt(0);

                    mappings.computeIfAbsent(baseChar, k -> new HashMap<>())
                            .put(markChar, fullwidthChar);
                }
            }
        }

        return mappings;
    }

    private void addMappings(Map<Integer, String> mappings, String[][] pairs) {
        if (pairs != null) {
            for (String[] pair : pairs) {
                int codePoint = pair[0].codePointAt(0);
                mappings.put(codePoint, pair[1]);
            }
        }
    }

    private void addReverseMappings(Map<Integer, Integer> mappings, String[][] pairs) {
        if (pairs != null) {
            for (String[] pair : pairs) {
                int fromCodePoint = pair[1].codePointAt(0);
                int toCodePoint = pair[0].codePointAt(0);
                mappings.put(fromCodePoint, toCodePoint);
            }
        }
    }

    /**
     * Transliterates the input by converting between fullwidth and halfwidth characters.
     *
     * @param input the input character iterator
     * @return a new character iterator with converted characters
     */
    @Override
    public CharIterator transliterate(CharIterator input) {
        return this.forwardOptions
                .map(
                        (options) -> {
                            final Map<Integer, String> forwardMappings =
                                    buildForwardMappings(options);
                            return (CharIterator)
                                    new FullwidthToHalfwidthIterator(forwardMappings, input);
                        })
                .or(
                        () ->
                                this.reverseOptions.map(
                                        (options) -> {
                                            final Map<Integer, Integer> reverseMappings =
                                                    buildReverseMappings(options);
                                            final Map<Integer, Map<Integer, Integer>>
                                                    voicedReverseMappings =
                                                            buildVoicedReverseMappings(options);
                                            return new HalfwidthToFullwidthIterator(
                                                    reverseMappings, voicedReverseMappings, input);
                                        }))
                .orElseThrow();
    }

    private class FullwidthToHalfwidthIterator implements CharIterator {
        private final Map<Integer, String> forwardMappings;
        private final CharIterator input;
        private String pending;
        private int pendingOffset;
        private Char pendingSource;
        private int offset = 0;

        public FullwidthToHalfwidthIterator(
                Map<Integer, String> forwardMappings, CharIterator input) {
            this.forwardMappings = forwardMappings;
            this.input = input;
        }

        @Override
        public boolean hasNext() {
            return (pending != null && pendingOffset < pending.length()) || input.hasNext();
        }

        @Override
        public Char next() {
            if (!hasNext()) {
                throw new NoSuchElementException();
            }

            // Return pending character if available
            if (pending != null && pendingOffset < pending.length()) {
                int codePoint = pending.codePointAt(pendingOffset);
                pendingOffset += Character.charCount(codePoint);
                Char result = new Char(CodePointTuple.of(codePoint), offset, pendingSource);
                offset += result.charCount();
                return result;
            }

            // Get next character from input
            Char c = input.next();
            if (c.isSentinel()) {
                return c.withOffset(offset);
            }

            CodePointTuple tuple = c.get();
            if (tuple.size() != 1) {
                Char result = c.withOffset(offset);
                offset += result.charCount();
                return result;
            }

            int codePoint = tuple.get(0);
            String mapped = forwardMappings.get(codePoint);

            if (mapped != null) {
                // Multi-character mapping
                if (mapped.length() > Character.charCount(mapped.codePointAt(0))) {
                    pending = mapped;
                    pendingOffset = 0;
                    pendingSource = c;
                    // Return first character
                    int firstCodePoint = mapped.codePointAt(0);
                    pendingOffset = Character.charCount(firstCodePoint);
                    Char result = new Char(CodePointTuple.of(firstCodePoint), offset, c);
                    offset += result.charCount();
                    return result;
                } else {
                    // Single character mapping
                    int mappedCodePoint = mapped.codePointAt(0);
                    Char result = new Char(CodePointTuple.of(mappedCodePoint), offset, c);
                    offset += result.charCount();
                    return result;
                }
            }

            // No mapping, return original
            Char result = c.withOffset(offset);
            offset += result.charCount();
            return result;
        }

        @Override
        public long estimateSize() {
            return input.estimateSize();
        }
    }

    private class HalfwidthToFullwidthIterator implements CharIterator {
        private final Map<Integer, Integer> reverseMappings;
        private final Map<Integer, Map<Integer, Integer>> voicedReverseMappings;
        private final CharIterator input;
        private Char pending;
        private int offset = 0;

        public HalfwidthToFullwidthIterator(
                Map<Integer, Integer> reverseMappings,
                Map<Integer, Map<Integer, Integer>> voicedReverseMappings,
                CharIterator input) {
            this.reverseMappings = reverseMappings;
            this.voicedReverseMappings = voicedReverseMappings;
            this.input = input;
        }

        @Override
        public boolean hasNext() {
            return pending != null || input.hasNext();
        }

        @Override
        public Char next() {
            if (!hasNext()) {
                throw new NoSuchElementException();
            }

            Char c;
            if (pending != null) {
                c = pending;
                pending = null;
            } else {
                c = input.next();
            }

            if (c.isSentinel()) {
                return c.withOffset(offset);
            }

            CodePointTuple tuple = c.get();
            if (tuple.size() != 1) {
                Char result = c.withOffset(offset);
                offset += result.charCount();
                return result;
            }

            int codePoint = tuple.get(0);

            // Check for voiced sound mark combination
            if (!voicedReverseMappings.isEmpty() && voicedReverseMappings.containsKey(codePoint)) {
                if (input.hasNext()) {
                    Char next = input.next();
                    if (!next.isSentinel() && next.get().size() == 1) {
                        int nextCodePoint = next.get().get(0);
                        Map<Integer, Integer> markMappings = voicedReverseMappings.get(codePoint);
                        Integer combined = markMappings.get(nextCodePoint);
                        if (combined != null) {
                            Char result = new Char(CodePointTuple.of(combined), offset, c);
                            offset += result.charCount();
                            return result;
                        }
                    }
                    // No combination, set next as pending
                    pending = next;
                }
            }

            // Regular mapping
            Integer mapped = reverseMappings.get(codePoint);
            if (mapped != null) {
                Char result = new Char(CodePointTuple.of(mapped), offset, c);
                offset += result.charCount();
                return result;
            }

            // No mapping, return original
            Char result = c.withOffset(offset);
            offset += result.charCount();
            return result;
        }

        @Override
        public long estimateSize() {
            return input.estimateSize();
        }
    }
}
