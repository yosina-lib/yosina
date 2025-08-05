<?php

declare(strict_types=1);

namespace Yosina\Transliterators;

use Yosina\Char;
use Yosina\TransliteratorInterface;

/**
 * JIS X 0201 and alike transliterator for fullwidth/halfwidth conversion.
 *
 * This transliterator handles conversion between:
 * - Half-width group:
 *   - Alphabets, numerics, and symbols: U+0020 - U+007E, U+00A5, and U+203E.
 *   - Half-width katakanas: U+FF61 - U+FF9F.
 * - Full-width group:
 *   - Full-width alphabets, numerics, and symbols: U+FF01 - U+FF5E, U+FFE3, and U+FFE5.
 *   - Wave dash: U+301C.
 *   - Hiraganas: U+3041 - U+3094.
 *   - Katakanas: U+30A1 - U+30F7 and U+30FA.
 *   - Hiragana/katakana voicing marks: U+309B, U+309C, and U+30FC.
 *   - Japanese punctuations: U+3001, U+3002, U+30A0, and U+30FB.
 */
class JisX0201AndAlikeTransliterator implements TransliteratorInterface
{
    /** @var array<string,string> GL area mapping table (fullwidth to halfwidth) */
    private const JISX0201_GL_TABLE = [
        "\u{3000}" => "\u{0020}",  // Ideographic space to space
        "\u{ff01}" => "\u{0021}",  // ！ to !
        "\u{ff02}" => "\u{0022}",  // ＂ to "
        "\u{ff03}" => "\u{0023}",  // ＃ to #
        "\u{ff04}" => "\u{0024}",  // ＄ to $
        "\u{ff05}" => "\u{0025}",  // ％ to %
        "\u{ff06}" => "\u{0026}",  // ＆ to &
        "\u{ff07}" => "\u{0027}",  // ＇ to '
        "\u{ff08}" => "\u{0028}",  // （ to (
        "\u{ff09}" => "\u{0029}",  // ） to )
        "\u{ff0a}" => "\u{002a}",  // ＊ to *
        "\u{ff0b}" => "\u{002b}",  // ＋ to +
        "\u{ff0c}" => "\u{002c}",  // ， to ,
        "\u{ff0d}" => "\u{002d}",  // － to -
        "\u{ff0e}" => "\u{002e}",  // ． to .
        "\u{ff0f}" => "\u{002f}",  // ／ to /
        "\u{ff10}" => "\u{0030}",  // ０ to 0
        "\u{ff11}" => "\u{0031}",  // １ to 1
        "\u{ff12}" => "\u{0032}",  // ２ to 2
        "\u{ff13}" => "\u{0033}",  // ３ to 3
        "\u{ff14}" => "\u{0034}",  // ４ to 4
        "\u{ff15}" => "\u{0035}",  // ５ to 5
        "\u{ff16}" => "\u{0036}",  // ６ to 6
        "\u{ff17}" => "\u{0037}",  // ７ to 7
        "\u{ff18}" => "\u{0038}",  // ８ to 8
        "\u{ff19}" => "\u{0039}",  // ９ to 9
        "\u{ff1a}" => "\u{003a}",  // ： to :
        "\u{ff1b}" => "\u{003b}",  // ； to ;
        "\u{ff1c}" => "\u{003c}",  // ＜ to <
        "\u{ff1d}" => "\u{003d}",  // ＝ to =
        "\u{ff1e}" => "\u{003e}",  // ＞ to >
        "\u{ff1f}" => "\u{003f}",  // ？ to ?
        "\u{ff20}" => "\u{0040}",  // ＠ to @
        "\u{ff21}" => "\u{0041}",  // Ａ to A
        "\u{ff22}" => "\u{0042}",  // Ｂ to B
        "\u{ff23}" => "\u{0043}",  // Ｃ to C
        "\u{ff24}" => "\u{0044}",  // Ｄ to D
        "\u{ff25}" => "\u{0045}",  // Ｅ to E
        "\u{ff26}" => "\u{0046}",  // Ｆ to F
        "\u{ff27}" => "\u{0047}",  // Ｇ to G
        "\u{ff28}" => "\u{0048}",  // Ｈ to H
        "\u{ff29}" => "\u{0049}",  // Ｉ to I
        "\u{ff2a}" => "\u{004a}",  // Ｊ to J
        "\u{ff2b}" => "\u{004b}",  // Ｋ to K
        "\u{ff2c}" => "\u{004c}",  // Ｌ to L
        "\u{ff2d}" => "\u{004d}",  // Ｍ to M
        "\u{ff2e}" => "\u{004e}",  // Ｎ to N
        "\u{ff2f}" => "\u{004f}",  // Ｏ to O
        "\u{ff30}" => "\u{0050}",  // Ｐ to P
        "\u{ff31}" => "\u{0051}",  // Ｑ to Q
        "\u{ff32}" => "\u{0052}",  // Ｒ to R
        "\u{ff33}" => "\u{0053}",  // Ｓ to S
        "\u{ff34}" => "\u{0054}",  // Ｔ to T
        "\u{ff35}" => "\u{0055}",  // Ｕ to U
        "\u{ff36}" => "\u{0056}",  // Ｖ to V
        "\u{ff37}" => "\u{0057}",  // Ｗ to W
        "\u{ff38}" => "\u{0058}",  // Ｘ to X
        "\u{ff39}" => "\u{0059}",  // Ｙ to Y
        "\u{ff3a}" => "\u{005a}",  // Ｚ to Z
        "\u{ff3b}" => "\u{005b}",  // ［ to [
        "\u{ff3d}" => "\u{005d}",  // ］ to ]
        "\u{ff3e}" => "\u{005e}",  // ＾ to ^
        "\u{ff3f}" => "\u{005f}",  // ＿ to _
        "\u{ff40}" => "\u{0060}",  // ｀ to `
        "\u{ff41}" => "\u{0061}",  // ａ to a
        "\u{ff42}" => "\u{0062}",  // ｂ to b
        "\u{ff43}" => "\u{0063}",  // ｃ to c
        "\u{ff44}" => "\u{0064}",  // ｄ to d
        "\u{ff45}" => "\u{0065}",  // ｅ to e
        "\u{ff46}" => "\u{0066}",  // ｆ to f
        "\u{ff47}" => "\u{0067}",  // ｇ to g
        "\u{ff48}" => "\u{0068}",  // ｈ to h
        "\u{ff49}" => "\u{0069}",  // ｉ to i
        "\u{ff4a}" => "\u{006a}",  // ｊ to j
        "\u{ff4b}" => "\u{006b}",  // ｋ to k
        "\u{ff4c}" => "\u{006c}",  // ｌ to l
        "\u{ff4d}" => "\u{006d}",  // ｍ to m
        "\u{ff4e}" => "\u{006e}",  // ｎ to n
        "\u{ff4f}" => "\u{006f}",  // ｏ to o
        "\u{ff50}" => "\u{0070}",  // ｐ to p
        "\u{ff51}" => "\u{0071}",  // ｑ to q
        "\u{ff52}" => "\u{0072}",  // ｒ to r
        "\u{ff53}" => "\u{0073}",  // ｓ to s
        "\u{ff54}" => "\u{0074}",  // ｔ to t
        "\u{ff55}" => "\u{0075}",  // ｕ to u
        "\u{ff56}" => "\u{0076}",  // ｖ to v
        "\u{ff57}" => "\u{0077}",  // ｗ to w
        "\u{ff58}" => "\u{0078}",  // ｘ to x
        "\u{ff59}" => "\u{0079}",  // ｙ to y
        "\u{ff5a}" => "\u{007a}",  // ｚ to z
        "\u{ff5b}" => "\u{007b}",  // ｛ to {
        "\u{ff5c}" => "\u{007c}",  // ｜ to |
        "\u{ff5d}" => "\u{007d}",  // ｝ to }
    ];

    /** @var array<string,array<string,string>> Special GL overrides */
    private const JISX0201_GL_OVERRIDES = [
        'u005cAsYenSign' => ["\u{ffe5}" => "\u{005c}"],  // ￥ to \
        'u005cAsBackslash' => ["\u{ff3c}" => "\u{005c}"],  // ＼ to \
        'u007eAsFullwidthTilde' => ["\u{ff5e}" => "\u{007e}"],  // ～ to ~
        'u007eAsWaveDash' => ["\u{301c}" => "\u{007e}"],  // 〜 to ~
        'u007eAsOverline' => ["\u{203e}" => "\u{007e}"],  // ‾ to ~
        'u007eAsFullwidthMacron' => ["\u{ffe3}" => "\u{007e}"],  // ￣ to ~
        'u00a5AsYenSign' => ["\u{ffe5}" => "\u{00a5}"],  // ￥ to ¥
    ];

    /** @var array<string,string> GR area mapping table (fullwidth katakana to halfwidth katakana) */
    private const JISX0201_GR_TABLE = [
        "\u{3002}" => "\u{ff61}",  // 。 to ｡
        "\u{300c}" => "\u{ff62}",  // 「 to ｢
        "\u{300d}" => "\u{ff63}",  // 」 to ｣
        "\u{3001}" => "\u{ff64}",  // 、 to ､
        "\u{30fb}" => "\u{ff65}",  // ・ to ･
        "\u{30fc}" => "\u{ff70}",  // ー to ｰ
        "\u{309b}" => "\u{ff9e}",  // ゛ to ﾞ
        "\u{309c}" => "\u{ff9f}",  // ゜ to ﾟ
        // Small kana
        "\u{30a1}" => "\u{ff67}",  // ァ to ｧ
        "\u{30a3}" => "\u{ff68}",  // ィ to ｨ
        "\u{30a5}" => "\u{ff69}",  // ゥ to ｩ
        "\u{30a7}" => "\u{ff6a}",  // ェ to ｪ
        "\u{30a9}" => "\u{ff6b}",  // ォ to ｫ
        "\u{30e3}" => "\u{ff6c}",  // ャ to ｬ
        "\u{30e5}" => "\u{ff6d}",  // ュ to ｭ
        "\u{30e7}" => "\u{ff6e}",  // ョ to ｮ
        "\u{30c3}" => "\u{ff6f}",  // ッ to ｯ
        // Vowels
        "\u{30a2}" => "\u{ff71}",  // ア to ｱ
        "\u{30a4}" => "\u{ff72}",  // イ to ｲ
        "\u{30a6}" => "\u{ff73}",  // ウ to ｳ
        "\u{30a8}" => "\u{ff74}",  // エ to ｴ
        "\u{30aa}" => "\u{ff75}",  // オ to ｵ
        // K-row
        "\u{30ab}" => "\u{ff76}",  // カ to ｶ
        "\u{30ad}" => "\u{ff77}",  // キ to ｷ
        "\u{30af}" => "\u{ff78}",  // ク to ｸ
        "\u{30b1}" => "\u{ff79}",  // ケ to ｹ
        "\u{30b3}" => "\u{ff7a}",  // コ to ｺ
        // S-row
        "\u{30b5}" => "\u{ff7b}",  // サ to ｻ
        "\u{30b7}" => "\u{ff7c}",  // シ to ｼ
        "\u{30b9}" => "\u{ff7d}",  // ス to ｽ
        "\u{30bb}" => "\u{ff7e}",  // セ to ｾ
        "\u{30bd}" => "\u{ff7f}",  // ソ to ｿ
        // T-row
        "\u{30bf}" => "\u{ff80}",  // タ to ﾀ
        "\u{30c1}" => "\u{ff81}",  // チ to ﾁ
        "\u{30c4}" => "\u{ff82}",  // ツ to ﾂ
        "\u{30c6}" => "\u{ff83}",  // テ to ﾃ
        "\u{30c8}" => "\u{ff84}",  // ト to ﾄ
        // N-row
        "\u{30ca}" => "\u{ff85}",  // ナ to ﾅ
        "\u{30cb}" => "\u{ff86}",  // ニ to ﾆ
        "\u{30cc}" => "\u{ff87}",  // ヌ to ﾇ
        "\u{30cd}" => "\u{ff88}",  // ネ to ﾈ
        "\u{30ce}" => "\u{ff89}",  // ノ to ﾉ
        // H-row
        "\u{30cf}" => "\u{ff8a}",  // ハ to ﾊ
        "\u{30d2}" => "\u{ff8b}",  // ヒ to ﾋ
        "\u{30d5}" => "\u{ff8c}",  // フ to ﾌ
        "\u{30d8}" => "\u{ff8d}",  // ヘ to ﾍ
        "\u{30db}" => "\u{ff8e}",  // ホ to ﾎ
        // M-row
        "\u{30de}" => "\u{ff8f}",  // マ to ﾏ
        "\u{30df}" => "\u{ff90}",  // ミ to ﾐ
        "\u{30e0}" => "\u{ff91}",  // ム to ﾑ
        "\u{30e1}" => "\u{ff92}",  // メ to ﾒ
        "\u{30e2}" => "\u{ff93}",  // モ to ﾓ
        // Y-row
        "\u{30e4}" => "\u{ff94}",  // ヤ to ﾔ
        "\u{30e6}" => "\u{ff95}",  // ユ to ﾕ
        "\u{30e8}" => "\u{ff96}",  // ヨ to ﾖ
        // R-row
        "\u{30e9}" => "\u{ff97}",  // ラ to ﾗ
        "\u{30ea}" => "\u{ff98}",  // リ to ﾘ
        "\u{30eb}" => "\u{ff99}",  // ル to ﾙ
        "\u{30ec}" => "\u{ff9a}",  // レ to ﾚ
        "\u{30ed}" => "\u{ff9b}",  // ロ to ﾛ
        // W-row
        "\u{30ef}" => "\u{ff9c}",  // ワ to ﾜ
        "\u{30f3}" => "\u{ff9d}",  // ン to ﾝ
        "\u{30f2}" => "\u{ff66}",  // ヲ to ｦ
    ];

    /** @var array<string,string> Voiced letters (dakuten/handakuten combinations) */
    private const VOICED_LETTERS_TABLE = [
        "\u{30f4}" => "\u{ff73}\u{ff9e}",  // ヴ to ｳﾞ
        // G-row (voiced K)
        "\u{30ac}" => "\u{ff76}\u{ff9e}",  // ガ to ｶﾞ
        "\u{30ae}" => "\u{ff77}\u{ff9e}",  // ギ to ｷﾞ
        "\u{30b0}" => "\u{ff78}\u{ff9e}",  // グ to ｸﾞ
        "\u{30b2}" => "\u{ff79}\u{ff9e}",  // ゲ to ｹﾞ
        "\u{30b4}" => "\u{ff7a}\u{ff9e}",  // ゴ to ｺﾞ
        // Z-row (voiced S)
        "\u{30b6}" => "\u{ff7b}\u{ff9e}",  // ザ to ｻﾞ
        "\u{30b8}" => "\u{ff7c}\u{ff9e}",  // ジ to ｼﾞ
        "\u{30ba}" => "\u{ff7d}\u{ff9e}",  // ズ to ｽﾞ
        "\u{30bc}" => "\u{ff7e}\u{ff9e}",  // ゼ to ｾﾞ
        "\u{30be}" => "\u{ff7f}\u{ff9e}",  // ゾ to ｿﾞ
        // D-row (voiced T)
        "\u{30c0}" => "\u{ff80}\u{ff9e}",  // ダ to ﾀﾞ
        "\u{30c2}" => "\u{ff81}\u{ff9e}",  // ヂ to ﾁﾞ
        "\u{30c5}" => "\u{ff82}\u{ff9e}",  // ヅ to ﾂﾞ
        "\u{30c7}" => "\u{ff83}\u{ff9e}",  // デ to ﾃﾞ
        "\u{30c9}" => "\u{ff84}\u{ff9e}",  // ド to ﾄﾞ
        // B-row (voiced H)
        "\u{30d0}" => "\u{ff8a}\u{ff9e}",  // バ to ﾊﾞ
        "\u{30d3}" => "\u{ff8b}\u{ff9e}",  // ビ to ﾋﾞ
        "\u{30d6}" => "\u{ff8c}\u{ff9e}",  // ブ to ﾌﾞ
        "\u{30d9}" => "\u{ff8d}\u{ff9e}",  // ベ to ﾍﾞ
        "\u{30dc}" => "\u{ff8e}\u{ff9e}",  // ボ to ﾎﾞ
        // P-row (half-voiced H)
        "\u{30d1}" => "\u{ff8a}\u{ff9f}",  // パ to ﾊﾟ
        "\u{30d4}" => "\u{ff8b}\u{ff9f}",  // ピ to ﾋﾟ
        "\u{30d7}" => "\u{ff8c}\u{ff9f}",  // プ to ﾌﾟ
        "\u{30da}" => "\u{ff8d}\u{ff9f}",  // ペ to ﾍﾟ
        "\u{30dd}" => "\u{ff8e}\u{ff9f}",  // ポ to ﾎﾟ
        // Special
        "\u{30fa}" => "\u{ff66}\u{ff9e}",  // ヺ to ｦﾞ
    ];

    /** @var array<string,string> Hiragana mappings (for convertHiraganas option) */
    private const HIRAGANA_MAPPINGS = [
        // Small hiragana
        "\u{3041}" => "\u{ff67}",  // ぁ to ｧ
        "\u{3043}" => "\u{ff68}",  // ぃ to ｨ
        "\u{3045}" => "\u{ff69}",  // ぅ to ｩ
        "\u{3047}" => "\u{ff6a}",  // ぇ to ｪ
        "\u{3049}" => "\u{ff6b}",  // ぉ to ｫ
        "\u{3083}" => "\u{ff6c}",  // ゃ to ｬ
        "\u{3085}" => "\u{ff6d}",  // ゅ to ｭ
        "\u{3087}" => "\u{ff6e}",  // ょ to ｮ
        "\u{3063}" => "\u{ff6f}",  // っ to ｯ
        // Vowels
        "\u{3042}" => "\u{ff71}",  // あ to ｱ
        "\u{3044}" => "\u{ff72}",  // い to ｲ
        "\u{3046}" => "\u{ff73}",  // う to ｳ
        "\u{3048}" => "\u{ff74}",  // え to ｴ
        "\u{304a}" => "\u{ff75}",  // お to ｵ
        // K-row
        "\u{304b}" => "\u{ff76}",  // か to ｶ
        "\u{304d}" => "\u{ff77}",  // き to ｷ
        "\u{304f}" => "\u{ff78}",  // く to ｸ
        "\u{3051}" => "\u{ff79}",  // け to ｹ
        "\u{3053}" => "\u{ff7a}",  // こ to ｺ
        // S-row
        "\u{3055}" => "\u{ff7b}",  // さ to ｻ
        "\u{3057}" => "\u{ff7c}",  // し to ｼ
        "\u{3059}" => "\u{ff7d}",  // す to ｽ
        "\u{305b}" => "\u{ff7e}",  // せ to ｾ
        "\u{305d}" => "\u{ff7f}",  // そ to ｿ
        // T-row
        "\u{305f}" => "\u{ff80}",  // た to ﾀ
        "\u{3061}" => "\u{ff81}",  // ち to ﾁ
        "\u{3064}" => "\u{ff82}",  // つ to ﾂ
        "\u{3066}" => "\u{ff83}",  // て to ﾃ
        "\u{3068}" => "\u{ff84}",  // と to ﾄ
        // N-row
        "\u{306a}" => "\u{ff85}",  // な to ﾅ
        "\u{306b}" => "\u{ff86}",  // に to ﾆ
        "\u{306c}" => "\u{ff87}",  // ぬ to ﾇ
        "\u{306d}" => "\u{ff88}",  // ね to ﾈ
        "\u{306e}" => "\u{ff89}",  // の to ﾉ
        // H-row
        "\u{306f}" => "\u{ff8a}",  // は to ﾊ
        "\u{3072}" => "\u{ff8b}",  // ひ to ﾋ
        "\u{3075}" => "\u{ff8c}",  // ふ to ﾌ
        "\u{3078}" => "\u{ff8d}",  // へ to ﾍ
        "\u{307b}" => "\u{ff8e}",  // ほ to ﾎ
        // M-row
        "\u{307e}" => "\u{ff8f}",  // ま to ﾏ
        "\u{307f}" => "\u{ff90}",  // み to ﾐ
        "\u{3080}" => "\u{ff91}",  // む to ﾑ
        "\u{3081}" => "\u{ff92}",  // め to ﾒ
        "\u{3082}" => "\u{ff93}",  // も to ﾓ
        // Y-row
        "\u{3084}" => "\u{ff94}",  // や to ﾔ
        "\u{3086}" => "\u{ff95}",  // ゆ to ﾕ
        "\u{3088}" => "\u{ff96}",  // よ to ﾖ
        // R-row
        "\u{3089}" => "\u{ff97}",  // ら to ﾗ
        "\u{308a}" => "\u{ff98}",  // り to ﾘ
        "\u{308b}" => "\u{ff99}",  // る to ﾙ
        "\u{308c}" => "\u{ff9a}",  // れ to ﾚ
        "\u{308d}" => "\u{ff9b}",  // ろ to ﾛ
        // W-row
        "\u{308f}" => "\u{ff9c}",  // わ to ﾜ
        "\u{3093}" => "\u{ff9d}",  // ん to ﾝ
        "\u{3092}" => "\u{ff66}",  // を to ｦ
        // Voiced
        "\u{3094}" => "\u{ff73}\u{ff9e}",  // ゔ to ｳﾞ
        // Voiced K (G)
        "\u{304c}" => "\u{ff76}\u{ff9e}",  // が to ｶﾞ
        "\u{304e}" => "\u{ff77}\u{ff9e}",  // ぎ to ｷﾞ
        "\u{3050}" => "\u{ff78}\u{ff9e}",  // ぐ to ｸﾞ
        "\u{3052}" => "\u{ff79}\u{ff9e}",  // げ to ｹﾞ
        "\u{3054}" => "\u{ff7a}\u{ff9e}",  // ご to ｺﾞ
        // Voiced S (Z)
        "\u{3056}" => "\u{ff7b}\u{ff9e}",  // ざ to ｻﾞ
        "\u{3058}" => "\u{ff7c}\u{ff9e}",  // じ to ｼﾞ
        "\u{305a}" => "\u{ff7d}\u{ff9e}",  // ず to ｽﾞ
        "\u{305c}" => "\u{ff7e}\u{ff9e}",  // ぜ to ｾﾞ
        "\u{305e}" => "\u{ff7f}\u{ff9e}",  // ぞ to ｿﾞ
        // Voiced T (D)
        "\u{3060}" => "\u{ff80}\u{ff9e}",  // だ to ﾀﾞ
        "\u{3062}" => "\u{ff81}\u{ff9e}",  // ぢ to ﾁﾞ
        "\u{3065}" => "\u{ff82}\u{ff9e}",  // づ to ﾂﾞ
        "\u{3067}" => "\u{ff83}\u{ff9e}",  // で to ﾃﾞ
        "\u{3069}" => "\u{ff84}\u{ff9e}",  // ど to ﾄﾞ
        // Voiced H (B)
        "\u{3070}" => "\u{ff8a}\u{ff9e}",  // ば to ﾊﾞ
        "\u{3073}" => "\u{ff8b}\u{ff9e}",  // び to ﾋﾞ
        "\u{3076}" => "\u{ff8c}\u{ff9e}",  // ぶ to ﾌﾞ
        "\u{3079}" => "\u{ff8d}\u{ff9e}",  // べ to ﾍﾞ
        "\u{307c}" => "\u{ff8e}\u{ff9e}",  // ぼ to ﾎﾞ
        // Half-voiced H (P)
        "\u{3071}" => "\u{ff8a}\u{ff9f}",  // ぱ to ﾊﾟ
        "\u{3074}" => "\u{ff8b}\u{ff9f}",  // ぴ to ﾋﾟ
        "\u{3077}" => "\u{ff8c}\u{ff9f}",  // ぷ to ﾌﾟ
        "\u{307a}" => "\u{ff8d}\u{ff9f}",  // ぺ to ﾍﾟ
        "\u{307d}" => "\u{ff8e}\u{ff9f}",  // ぽ to ﾎﾟ
    ];

    /** @var array<string,string> Special punctuations */
    private const SPECIAL_PUNCTUATIONS_TABLE = [
        "\u{30a0}" => "\u{003d}",  // ゠ to =
    ];

    private bool $fullwidthToHalfwidth;
    private bool $convertGL;
    private bool $convertGR;
    private bool $convertUnsafeSpecials;
    private bool $convertHiraganas;
    private bool $combineVoicedSoundMarks;

    /**
     * @var array<string, bool>
     */
    private array $overrides;

    /**
     * @var array<string, string>
     */
    private array $fwdMappings;

    /**
     * @var array<string, string>
     */
    private array $revMappings;

    /**
     * @var array<string, array<string, string>>
     */
    private array $voicedRevMappings;

    /**
     * Cache for forward mappings indexed by configuration key
     * @var array<string, array<string, string>>
     */
    private static array $fwdMappingsCache = [];

    /**
     * Cache for reverse mappings indexed by configuration key
     * @var array<string, array<string, string>>
     */
    private static array $revMappingsCache = [];

    /**
     * Cache for voiced reverse mappings indexed by configuration key
     * @var array<string, array<string, array<string, string>>>
     */
    private static array $voicedRevMappingsCache = [];

    /**
    * @param array{fullwidthToHalfwidth?:bool,convertGL?:bool,convertGR?:bool,convertUnsafeSpecials?:bool,convertHiraganas?:bool,combineVoicedSoundMarks?:bool,u005cAsYenSign?:bool,u005cAsBackslash?:bool,u007eAsFullwidthTilde?:bool,u007eAsWaveDash?:bool,u007eAsOverline?:bool,u007eAsFullwidthMacron?:bool,u00a5AsYenSign?:bool} $options
     */
    public function __construct(array $options = [])
    {
        $this->fullwidthToHalfwidth = $options['fullwidthToHalfwidth'] ?? true;
        $this->convertGL = $options['convertGL'] ?? true;
        $this->convertGR = $options['convertGR'] ?? true;
        $this->convertUnsafeSpecials = $options['convertUnsafeSpecials'] ?? false;
        $this->convertHiraganas = $options['convertHiraganas'] ?? false;
        $this->combineVoicedSoundMarks = $options['combineVoicedSoundMarks'] ?? false;

        // Handle overrides
        $this->overrides = [];
        if ($options['u005cAsYenSign'] ?? false) {
            $this->overrides['u005cAsYenSign'] = true;
        }
        if ($options['u005cAsBackslash'] ?? false) {
            $this->overrides['u005cAsBackslash'] = true;
        }
        if ($options['u007eAsFullwidthTilde'] ?? false) {
            $this->overrides['u007eAsFullwidthTilde'] = true;
        }
        if ($options['u007eAsWaveDash'] ?? false) {
            $this->overrides['u007eAsWaveDash'] = true;
        }
        if ($options['u007eAsOverline'] ?? false) {
            $this->overrides['u007eAsOverline'] = true;
        }
        if ($options['u007eAsFullwidthMacron'] ?? false) {
            $this->overrides['u007eAsFullwidthMacron'] = true;
        }
        if ($options['u00a5AsYenSign'] ?? false) {
            $this->overrides['u00a5AsYenSign'] = true;
        }

        // Apply defaults based on direction
        if ($this->fullwidthToHalfwidth) {
            // Default settings for fullwidth to halfwidth
            if (!($options['u005cAsBackslash'] ?? false) && !($options['u00a5AsYenSign'] ?? false)) {
                $this->overrides['u005cAsYenSign'] = $this->overrides['u005cAsYenSign'] ?? true;
                $this->overrides['u005cAsBackslash'] = $this->overrides['u005cAsBackslash'] ?? true;
            }
            $this->overrides['u007eAsFullwidthTilde'] = $this->overrides['u007eAsFullwidthTilde'] ?? true;
            $this->overrides['u007eAsWaveDash'] = $this->overrides['u007eAsWaveDash'] ?? true;
        } else {
            // Default settings for halfwidth to fullwidth
            $u005cAsYen = ($this->overrides['u005cAsYenSign'] ?? false) ||
                          !($this->overrides['u005cAsBackslash'] ?? false);
            $u007eAsFwTilde = ($this->overrides['u007eAsFullwidthTilde'] ?? false) ||
                              !($this->overrides['u007eAsWaveDash'] ?? false) &&
                              !($this->overrides['u007eAsOverline'] ?? false) &&
                              !($this->overrides['u007eAsFullwidthMacron'] ?? false);

            $this->overrides['u005cAsYenSign'] = $this->overrides['u005cAsYenSign'] ?? $u005cAsYen;
            $this->overrides['u005cAsBackslash'] = $this->overrides['u005cAsBackslash'] ?? !$u005cAsYen;
            $this->overrides['u007eAsFullwidthTilde'] = $this->overrides['u007eAsFullwidthTilde'] ?? $u007eAsFwTilde;
            $this->overrides['u00a5AsYenSign'] = $this->overrides['u00a5AsYenSign'] ?? true;
        }

        // Build mappings using cache
        $cacheKey = $this->generateCacheKey();
        $this->fwdMappings = $this->getFwdMappings($cacheKey);
        $this->revMappings = $this->getRevMappings($cacheKey);
        $this->voicedRevMappings = $this->getVoicedRevMappings($cacheKey);
    }

    /**
     * Generate a cache key based on current configuration
     */
    private function generateCacheKey(): string
    {
        return sprintf(
            '%d-%d-%d-%d-%d-%d-%d-%d-%d-%d-%d-%d',
            (int) $this->convertGL,
            (int) $this->convertGR,
            (int) $this->convertUnsafeSpecials,
            (int) $this->convertHiraganas,
            (int) $this->combineVoicedSoundMarks,
            (int) ($this->overrides['u005cAsYenSign'] ?? false),
            (int) ($this->overrides['u005cAsBackslash'] ?? false),
            (int) ($this->overrides['u007eAsFullwidthTilde'] ?? false),
            (int) ($this->overrides['u007eAsWaveDash'] ?? false),
            (int) ($this->overrides['u007eAsOverline'] ?? false),
            (int) ($this->overrides['u007eAsFullwidthMacron'] ?? false),
            (int) ($this->overrides['u00a5AsYenSign'] ?? false),
        );
    }

    /**
     * Get forward mappings with caching
     * @return array<string,string>
     */
    private function getFwdMappings(string $cacheKey): array
    {
        if (!isset(self::$fwdMappingsCache[$cacheKey])) {
            self::$fwdMappingsCache[$cacheKey] = $this->buildFwdMappings();
        }
        return self::$fwdMappingsCache[$cacheKey];
    }

    /**
     * Get reverse mappings with caching
     * @return array<string,string>
     */
    private function getRevMappings(string $cacheKey): array
    {
        if (!isset(self::$revMappingsCache[$cacheKey])) {
            self::$revMappingsCache[$cacheKey] = $this->buildRevMappings();
        }
        return self::$revMappingsCache[$cacheKey];
    }

    /**
     * Get voiced reverse mappings with caching
     * @return array<string, array<string, string>>
     */
    private function getVoicedRevMappings(string $cacheKey): array
    {
        if (!isset(self::$voicedRevMappingsCache[$cacheKey])) {
            self::$voicedRevMappingsCache[$cacheKey] = $this->buildVoicedRevMappings();
        }
        return self::$voicedRevMappingsCache[$cacheKey];
    }

    /**
     * @return array<string,string>
     */
    private function buildFwdMappings(): array
    {
        $mappings = [];

        if ($this->convertGL) {
            // Add basic GL mappings
            $mappings = array_merge($mappings, self::JISX0201_GL_TABLE);

            // Add override mappings
            foreach ($this->overrides as $key => $enabled) {
                if ($enabled && isset(self::JISX0201_GL_OVERRIDES[$key])) {
                    $mappings = array_merge($mappings, self::JISX0201_GL_OVERRIDES[$key]);
                }
            }
        }

        if ($this->convertGR) {
            // Add basic GR mappings
            $mappings = array_merge($mappings, self::JISX0201_GR_TABLE);
            $mappings = array_merge($mappings, self::VOICED_LETTERS_TABLE);
            // Add combining marks
            $mappings["\u{3099}"] = "\u{ff9e}";  // combining dakuten
            $mappings["\u{309a}"] = "\u{ff9f}";  // combining handakuten
        }

        if ($this->convertUnsafeSpecials) {
            $mappings = array_merge($mappings, self::SPECIAL_PUNCTUATIONS_TABLE);
        }

        if ($this->convertHiraganas) {
            $mappings = array_merge($mappings, self::HIRAGANA_MAPPINGS);
        }

        return $mappings;
    }

    /**
     * @return array<string,string>
     */
    private function buildRevMappings(): array
    {
        /** @var array<string,string> */
        $mappings = [];

        if ($this->convertGL) {
            // Add basic GL reverse mappings
            /** @var array<string,string> This annotation is required to work around a PHPStan bug */
            $mappings = array_merge($mappings, array_flip(self::JISX0201_GL_TABLE));

            // Add override reverse mappings
            foreach ($this->overrides as $key => $enabled) {
                if ($enabled && isset(self::JISX0201_GL_OVERRIDES[$key])) {
                    $mappings = array_merge($mappings, array_flip(self::JISX0201_GL_OVERRIDES[$key]));
                }
            }
        }

        if ($this->convertGR) {
            // Add basic GR reverse mappings
            $mappings = array_merge($mappings, array_flip(self::JISX0201_GR_TABLE));
        }

        if ($this->convertUnsafeSpecials) {
            $mappings = array_merge($mappings, array_flip(self::SPECIAL_PUNCTUATIONS_TABLE));
        }

        return $mappings;
    }

    /**
     * @return array<string, array<string, string>>
     */
    private function buildVoicedRevMappings(): array
    {
        $mappings = [];

        if ($this->combineVoicedSoundMarks && $this->convertGR) {
            foreach (self::VOICED_LETTERS_TABLE as $fw => $hw) {
                if (mb_strlen($hw) === 2) {
                    $baseChar = mb_substr($hw, 0, 1);
                    $voiceMark = mb_substr($hw, 1, 1);
                    if (!isset($mappings[$baseChar])) {
                        $mappings[$baseChar] = [];
                    }
                    $mappings[$baseChar][$voiceMark] = $fw;
                }
            }
        }

        return $mappings;
    }

    /**
     * @param iterable<Char> $inputChars
     * @return iterable<Char>
     */
    public function __invoke(iterable $inputChars): iterable
    {
        if ($this->fullwidthToHalfwidth) {
            return $this->convertFullwidthToHalfwidth($inputChars);
        } else {
            return $this->convertHalfwidthToFullwidth($inputChars);
        }
    }

    /**
     * @param iterable<Char> $chars
     * @return iterable<Char>
     */
    private function convertFullwidthToHalfwidth(iterable $chars): iterable
    {
        foreach ($chars as $char) {
            $mapped = $this->fwdMappings[$char->c] ?? null;
            if ($mapped !== null) {
                yield new Char($mapped, $char->offset, $char);
            } else {
                yield $char;
            }
        }
    }

    /**
     * @param iterable<Char> $chars
     * @return iterable<Char>
     */
    private function convertHalfwidthToFullwidth(iterable $chars): iterable
    {
        $pendingChar = null;

        foreach ($chars as $char) {
            if ($pendingChar !== null) {
                // Check if this char can combine with the pending one
                [$baseChar, $voiceMappings] = $pendingChar;
                $combined = $voiceMappings[$char->c] ?? null;
                if ($combined !== null) {
                    // Yield the combined character
                    yield new Char($combined, $baseChar->offset, $baseChar);
                    $pendingChar = null;
                    continue;
                } else {
                    // Can't combine, yield the pending character first
                    $mapped = $this->revMappings[$baseChar->c] ?? null;
                    if ($mapped !== null) {
                        yield new Char($mapped, $baseChar->offset, $baseChar);
                    } else {
                        yield $baseChar;
                    }
                    $pendingChar = null;
                }
            }

            // Check if this character might start a combination
            if (isset($this->voicedRevMappings[$char->c])) {
                $pendingChar = [$char, $this->voicedRevMappings[$char->c]];
            } else {
                // Normal mapping
                $mapped = $this->revMappings[$char->c] ?? null;
                if ($mapped !== null) {
                    yield new Char($mapped, $char->offset, $char);
                } else {
                    yield $char;
                }
            }
        }

        // Handle any remaining pending character
        if ($pendingChar !== null) {
            [$baseChar, $_] = $pendingChar;
            $mapped = $this->revMappings[$baseChar->c] ?? null;
            if ($mapped !== null) {
                yield new Char($mapped, $baseChar->offset, $baseChar);
            } else {
                yield $baseChar;
            }
        }
    }
}
