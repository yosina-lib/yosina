using System.Collections.Generic;
using System.Linq;

namespace Yosina.Transliterators;

/// <summary>
/// Replace circled or squared characters with templated forms.
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator("circled-or-squared")]
public class CircledOrSquaredTransliterator : ITransliterator
{
    private readonly Options _options;

    public CircledOrSquaredTransliterator() : this(new Options()) { }

    public CircledOrSquaredTransliterator(Options options)
    {
        _options = options ?? throw new System.ArgumentNullException(nameof(options));
    }

    private static readonly Dictionary<int, CircledOrSquaredData> _mappings = new Dictionary<int, CircledOrSquaredData>()
    {
        [0x2460] = new CircledOrSquaredData("1", "circle", false),
        [0x2461] = new CircledOrSquaredData("2", "circle", false),
        [0x2462] = new CircledOrSquaredData("3", "circle", false),
        [0x2463] = new CircledOrSquaredData("4", "circle", false),
        [0x2464] = new CircledOrSquaredData("5", "circle", false),
        [0x2465] = new CircledOrSquaredData("6", "circle", false),
        [0x2466] = new CircledOrSquaredData("7", "circle", false),
        [0x2467] = new CircledOrSquaredData("8", "circle", false),
        [0x2468] = new CircledOrSquaredData("9", "circle", false),
        [0x2469] = new CircledOrSquaredData("10", "circle", false),
        [0x246A] = new CircledOrSquaredData("11", "circle", false),
        [0x246B] = new CircledOrSquaredData("12", "circle", false),
        [0x246C] = new CircledOrSquaredData("13", "circle", false),
        [0x246D] = new CircledOrSquaredData("14", "circle", false),
        [0x246E] = new CircledOrSquaredData("15", "circle", false),
        [0x246F] = new CircledOrSquaredData("16", "circle", false),
        [0x2470] = new CircledOrSquaredData("17", "circle", false),
        [0x2471] = new CircledOrSquaredData("18", "circle", false),
        [0x2472] = new CircledOrSquaredData("19", "circle", false),
        [0x2473] = new CircledOrSquaredData("20", "circle", false),
        [0x24B6] = new CircledOrSquaredData("A", "circle", false),
        [0x24B7] = new CircledOrSquaredData("B", "circle", false),
        [0x24B8] = new CircledOrSquaredData("C", "circle", false),
        [0x24B9] = new CircledOrSquaredData("D", "circle", false),
        [0x24BA] = new CircledOrSquaredData("E", "circle", false),
        [0x24BB] = new CircledOrSquaredData("F", "circle", false),
        [0x24BC] = new CircledOrSquaredData("G", "circle", false),
        [0x24BD] = new CircledOrSquaredData("H", "circle", false),
        [0x24BE] = new CircledOrSquaredData("I", "circle", false),
        [0x24BF] = new CircledOrSquaredData("J", "circle", false),
        [0x24C0] = new CircledOrSquaredData("K", "circle", false),
        [0x24C1] = new CircledOrSquaredData("L", "circle", false),
        [0x24C2] = new CircledOrSquaredData("M", "circle", false),
        [0x24C3] = new CircledOrSquaredData("N", "circle", false),
        [0x24C4] = new CircledOrSquaredData("O", "circle", false),
        [0x24C5] = new CircledOrSquaredData("P", "circle", false),
        [0x24C6] = new CircledOrSquaredData("Q", "circle", false),
        [0x24C7] = new CircledOrSquaredData("R", "circle", false),
        [0x24C8] = new CircledOrSquaredData("S", "circle", false),
        [0x24C9] = new CircledOrSquaredData("T", "circle", false),
        [0x24CA] = new CircledOrSquaredData("U", "circle", false),
        [0x24CB] = new CircledOrSquaredData("V", "circle", false),
        [0x24CC] = new CircledOrSquaredData("W", "circle", false),
        [0x24CD] = new CircledOrSquaredData("X", "circle", false),
        [0x24CE] = new CircledOrSquaredData("Y", "circle", false),
        [0x24CF] = new CircledOrSquaredData("Z", "circle", false),
        [0x24D0] = new CircledOrSquaredData("a", "circle", false),
        [0x24D1] = new CircledOrSquaredData("b", "circle", false),
        [0x24D2] = new CircledOrSquaredData("c", "circle", false),
        [0x24D3] = new CircledOrSquaredData("d", "circle", false),
        [0x24D4] = new CircledOrSquaredData("e", "circle", false),
        [0x24D5] = new CircledOrSquaredData("f", "circle", false),
        [0x24D6] = new CircledOrSquaredData("g", "circle", false),
        [0x24D7] = new CircledOrSquaredData("h", "circle", false),
        [0x24D8] = new CircledOrSquaredData("i", "circle", false),
        [0x24D9] = new CircledOrSquaredData("j", "circle", false),
        [0x24DA] = new CircledOrSquaredData("k", "circle", false),
        [0x24DB] = new CircledOrSquaredData("l", "circle", false),
        [0x24DC] = new CircledOrSquaredData("m", "circle", false),
        [0x24DD] = new CircledOrSquaredData("n", "circle", false),
        [0x24DE] = new CircledOrSquaredData("o", "circle", false),
        [0x24DF] = new CircledOrSquaredData("p", "circle", false),
        [0x24E0] = new CircledOrSquaredData("q", "circle", false),
        [0x24E1] = new CircledOrSquaredData("r", "circle", false),
        [0x24E2] = new CircledOrSquaredData("s", "circle", false),
        [0x24E3] = new CircledOrSquaredData("t", "circle", false),
        [0x24E4] = new CircledOrSquaredData("u", "circle", false),
        [0x24E5] = new CircledOrSquaredData("v", "circle", false),
        [0x24E6] = new CircledOrSquaredData("w", "circle", false),
        [0x24E7] = new CircledOrSquaredData("x", "circle", false),
        [0x24E8] = new CircledOrSquaredData("y", "circle", false),
        [0x24E9] = new CircledOrSquaredData("z", "circle", false),
        [0x24EA] = new CircledOrSquaredData("0", "circle", false),
        [0x24EB] = new CircledOrSquaredData("11", "circle", false),
        [0x24EC] = new CircledOrSquaredData("12", "circle", false),
        [0x24ED] = new CircledOrSquaredData("13", "circle", false),
        [0x24EE] = new CircledOrSquaredData("14", "circle", false),
        [0x24EF] = new CircledOrSquaredData("15", "circle", false),
        [0x24F0] = new CircledOrSquaredData("16", "circle", false),
        [0x24F1] = new CircledOrSquaredData("17", "circle", false),
        [0x24F2] = new CircledOrSquaredData("18", "circle", false),
        [0x24F3] = new CircledOrSquaredData("19", "circle", false),
        [0x24F4] = new CircledOrSquaredData("20", "circle", false),
        [0x24F5] = new CircledOrSquaredData("1", "circle", false),
        [0x24F6] = new CircledOrSquaredData("2", "circle", false),
        [0x24F7] = new CircledOrSquaredData("3", "circle", false),
        [0x24F8] = new CircledOrSquaredData("4", "circle", false),
        [0x24F9] = new CircledOrSquaredData("5", "circle", false),
        [0x24FA] = new CircledOrSquaredData("6", "circle", false),
        [0x24FB] = new CircledOrSquaredData("7", "circle", false),
        [0x24FC] = new CircledOrSquaredData("8", "circle", false),
        [0x24FD] = new CircledOrSquaredData("9", "circle", false),
        [0x24FE] = new CircledOrSquaredData("10", "circle", false),
        [0x24FF] = new CircledOrSquaredData("0", "circle", false),
        [0x2776] = new CircledOrSquaredData("1", "circle", false),
        [0x2777] = new CircledOrSquaredData("2", "circle", false),
        [0x2778] = new CircledOrSquaredData("3", "circle", false),
        [0x2779] = new CircledOrSquaredData("4", "circle", false),
        [0x277A] = new CircledOrSquaredData("5", "circle", false),
        [0x277B] = new CircledOrSquaredData("6", "circle", false),
        [0x277C] = new CircledOrSquaredData("7", "circle", false),
        [0x277D] = new CircledOrSquaredData("8", "circle", false),
        [0x277E] = new CircledOrSquaredData("9", "circle", false),
        [0x277F] = new CircledOrSquaredData("10", "circle", false),
        [0x2780] = new CircledOrSquaredData("1", "circle", false),
        [0x2781] = new CircledOrSquaredData("2", "circle", false),
        [0x2782] = new CircledOrSquaredData("3", "circle", false),
        [0x2783] = new CircledOrSquaredData("4", "circle", false),
        [0x2784] = new CircledOrSquaredData("5", "circle", false),
        [0x2785] = new CircledOrSquaredData("6", "circle", false),
        [0x2786] = new CircledOrSquaredData("7", "circle", false),
        [0x2787] = new CircledOrSquaredData("8", "circle", false),
        [0x2788] = new CircledOrSquaredData("9", "circle", false),
        [0x2789] = new CircledOrSquaredData("10", "circle", false),
        [0x278A] = new CircledOrSquaredData("1", "circle", false),
        [0x278B] = new CircledOrSquaredData("2", "circle", false),
        [0x278C] = new CircledOrSquaredData("3", "circle", false),
        [0x278D] = new CircledOrSquaredData("4", "circle", false),
        [0x278E] = new CircledOrSquaredData("5", "circle", false),
        [0x278F] = new CircledOrSquaredData("6", "circle", false),
        [0x2790] = new CircledOrSquaredData("7", "circle", false),
        [0x2791] = new CircledOrSquaredData("8", "circle", false),
        [0x2792] = new CircledOrSquaredData("9", "circle", false),
        [0x2793] = new CircledOrSquaredData("10", "circle", false),
        [0x3244] = new CircledOrSquaredData("問", "circle", false),
        [0x3245] = new CircledOrSquaredData("幼", "circle", false),
        [0x3246] = new CircledOrSquaredData("文", "circle", false),
        [0x3247] = new CircledOrSquaredData("箏", "circle", false),
        [0x3248] = new CircledOrSquaredData("21", "circle", false),
        [0x3252] = new CircledOrSquaredData("22", "circle", false),
        [0x3253] = new CircledOrSquaredData("23", "circle", false),
        [0x3254] = new CircledOrSquaredData("24", "circle", false),
        [0x3255] = new CircledOrSquaredData("25", "circle", false),
        [0x3256] = new CircledOrSquaredData("26", "circle", false),
        [0x3257] = new CircledOrSquaredData("27", "circle", false),
        [0x3258] = new CircledOrSquaredData("28", "circle", false),
        [0x3259] = new CircledOrSquaredData("29", "circle", false),
        [0x325A] = new CircledOrSquaredData("30", "circle", false),
        [0x325B] = new CircledOrSquaredData("31", "circle", false),
        [0x325C] = new CircledOrSquaredData("32", "circle", false),
        [0x325D] = new CircledOrSquaredData("33", "circle", false),
        [0x325E] = new CircledOrSquaredData("34", "circle", false),
        [0x325F] = new CircledOrSquaredData("35", "circle", false),
        [0x3280] = new CircledOrSquaredData("一", "circle", false),
        [0x3281] = new CircledOrSquaredData("二", "circle", false),
        [0x3282] = new CircledOrSquaredData("三", "circle", false),
        [0x3283] = new CircledOrSquaredData("四", "circle", false),
        [0x3284] = new CircledOrSquaredData("五", "circle", false),
        [0x3285] = new CircledOrSquaredData("六", "circle", false),
        [0x3286] = new CircledOrSquaredData("七", "circle", false),
        [0x3287] = new CircledOrSquaredData("八", "circle", false),
        [0x3288] = new CircledOrSquaredData("九", "circle", false),
        [0x3289] = new CircledOrSquaredData("十", "circle", false),
        [0x328A] = new CircledOrSquaredData("月", "circle", false),
        [0x328B] = new CircledOrSquaredData("火", "circle", false),
        [0x328C] = new CircledOrSquaredData("水", "circle", false),
        [0x328D] = new CircledOrSquaredData("木", "circle", false),
        [0x328E] = new CircledOrSquaredData("金", "circle", false),
        [0x328F] = new CircledOrSquaredData("土", "circle", false),
        [0x3290] = new CircledOrSquaredData("日", "circle", false),
        [0x3291] = new CircledOrSquaredData("株", "circle", false),
        [0x3292] = new CircledOrSquaredData("有", "circle", false),
        [0x3293] = new CircledOrSquaredData("社", "circle", false),
        [0x3294] = new CircledOrSquaredData("名", "circle", false),
        [0x3295] = new CircledOrSquaredData("特", "circle", false),
        [0x3296] = new CircledOrSquaredData("財", "circle", false),
        [0x3297] = new CircledOrSquaredData("祝", "circle", false),
        [0x3298] = new CircledOrSquaredData("労", "circle", false),
        [0x3299] = new CircledOrSquaredData("秘", "circle", false),
        [0x329A] = new CircledOrSquaredData("男", "circle", false),
        [0x329B] = new CircledOrSquaredData("女", "circle", false),
        [0x329C] = new CircledOrSquaredData("適", "circle", false),
        [0x329D] = new CircledOrSquaredData("優", "circle", false),
        [0x329E] = new CircledOrSquaredData("印", "circle", false),
        [0x329F] = new CircledOrSquaredData("注", "circle", false),
        [0x32A0] = new CircledOrSquaredData("項", "circle", false),
        [0x32A1] = new CircledOrSquaredData("休", "circle", false),
        [0x32A2] = new CircledOrSquaredData("写", "circle", false),
        [0x32A3] = new CircledOrSquaredData("正", "circle", false),
        [0x32A4] = new CircledOrSquaredData("上", "circle", false),
        [0x32A5] = new CircledOrSquaredData("中", "circle", false),
        [0x32A6] = new CircledOrSquaredData("下", "circle", false),
        [0x32A7] = new CircledOrSquaredData("左", "circle", false),
        [0x32A8] = new CircledOrSquaredData("右", "circle", false),
        [0x32A9] = new CircledOrSquaredData("医", "circle", false),
        [0x32AA] = new CircledOrSquaredData("宗", "circle", false),
        [0x32AB] = new CircledOrSquaredData("学", "circle", false),
        [0x32AC] = new CircledOrSquaredData("監", "circle", false),
        [0x32AD] = new CircledOrSquaredData("企", "circle", false),
        [0x32AE] = new CircledOrSquaredData("資", "circle", false),
        [0x32AF] = new CircledOrSquaredData("協", "circle", false),
        [0x32B0] = new CircledOrSquaredData("夜", "circle", false),
        [0x32B1] = new CircledOrSquaredData("36", "circle", false),
        [0x32B2] = new CircledOrSquaredData("37", "circle", false),
        [0x32B3] = new CircledOrSquaredData("38", "circle", false),
        [0x32B4] = new CircledOrSquaredData("39", "circle", false),
        [0x32B5] = new CircledOrSquaredData("40", "circle", false),
        [0x32B6] = new CircledOrSquaredData("41", "circle", false),
        [0x32B7] = new CircledOrSquaredData("42", "circle", false),
        [0x32B8] = new CircledOrSquaredData("43", "circle", false),
        [0x32B9] = new CircledOrSquaredData("44", "circle", false),
        [0x32BA] = new CircledOrSquaredData("45", "circle", false),
        [0x32BB] = new CircledOrSquaredData("46", "circle", false),
        [0x32BC] = new CircledOrSquaredData("47", "circle", false),
        [0x32BD] = new CircledOrSquaredData("48", "circle", false),
        [0x32BE] = new CircledOrSquaredData("49", "circle", false),
        [0x32BF] = new CircledOrSquaredData("50", "circle", false),
        [0x32D0] = new CircledOrSquaredData("ア", "circle", false),
        [0x32D1] = new CircledOrSquaredData("イ", "circle", false),
        [0x32D2] = new CircledOrSquaredData("ウ", "circle", false),
        [0x32D3] = new CircledOrSquaredData("エ", "circle", false),
        [0x32D4] = new CircledOrSquaredData("オ", "circle", false),
        [0x32D5] = new CircledOrSquaredData("カ", "circle", false),
        [0x32D6] = new CircledOrSquaredData("キ", "circle", false),
        [0x32D7] = new CircledOrSquaredData("ク", "circle", false),
        [0x32D8] = new CircledOrSquaredData("ケ", "circle", false),
        [0x32D9] = new CircledOrSquaredData("コ", "circle", false),
        [0x32DA] = new CircledOrSquaredData("サ", "circle", false),
        [0x32DB] = new CircledOrSquaredData("シ", "circle", false),
        [0x32DC] = new CircledOrSquaredData("ス", "circle", false),
        [0x32DD] = new CircledOrSquaredData("セ", "circle", false),
        [0x32DE] = new CircledOrSquaredData("ソ", "circle", false),
        [0x32DF] = new CircledOrSquaredData("タ", "circle", false),
        [0x32E0] = new CircledOrSquaredData("チ", "circle", false),
        [0x32E1] = new CircledOrSquaredData("ツ", "circle", false),
        [0x32E2] = new CircledOrSquaredData("テ", "circle", false),
        [0x32E3] = new CircledOrSquaredData("ト", "circle", false),
        [0x32E4] = new CircledOrSquaredData("ナ", "circle", false),
        [0x32E5] = new CircledOrSquaredData("ニ", "circle", false),
        [0x32E6] = new CircledOrSquaredData("ヌ", "circle", false),
        [0x32E7] = new CircledOrSquaredData("ネ", "circle", false),
        [0x32E8] = new CircledOrSquaredData("ノ", "circle", false),
        [0x32E9] = new CircledOrSquaredData("ハ", "circle", false),
        [0x32EA] = new CircledOrSquaredData("ヒ", "circle", false),
        [0x32EB] = new CircledOrSquaredData("フ", "circle", false),
        [0x32EC] = new CircledOrSquaredData("ヘ", "circle", false),
        [0x32ED] = new CircledOrSquaredData("ホ", "circle", false),
        [0x32EE] = new CircledOrSquaredData("マ", "circle", false),
        [0x32EF] = new CircledOrSquaredData("ミ", "circle", false),
        [0x32F0] = new CircledOrSquaredData("ム", "circle", false),
        [0x32F1] = new CircledOrSquaredData("メ", "circle", false),
        [0x32F2] = new CircledOrSquaredData("モ", "circle", false),
        [0x32F3] = new CircledOrSquaredData("ヤ", "circle", false),
        [0x32F4] = new CircledOrSquaredData("ユ", "circle", false),
        [0x32F5] = new CircledOrSquaredData("ヨ", "circle", false),
        [0x32F6] = new CircledOrSquaredData("ラ", "circle", false),
        [0x32F7] = new CircledOrSquaredData("リ", "circle", false),
        [0x32F8] = new CircledOrSquaredData("ル", "circle", false),
        [0x32F9] = new CircledOrSquaredData("レ", "circle", false),
        [0x32FA] = new CircledOrSquaredData("ロ", "circle", false),
        [0x32FB] = new CircledOrSquaredData("ワ", "circle", false),
        [0x32FC] = new CircledOrSquaredData("ヰ", "circle", false),
        [0x32FD] = new CircledOrSquaredData("ヱ", "circle", false),
        [0x32FE] = new CircledOrSquaredData("ヲ", "circle", false),
        [0x1F10B] = new CircledOrSquaredData("0", "circle", false),
        [0x1F10C] = new CircledOrSquaredData("0", "circle", false),
        [0x1F12B] = new CircledOrSquaredData("C", "circle", false),
        [0x1F12C] = new CircledOrSquaredData("R", "circle", false),
        [0x1F12D] = new CircledOrSquaredData("CD", "circle", false),
        [0x1F12E] = new CircledOrSquaredData("WZ", "circle", false),
        [0x1F130] = new CircledOrSquaredData("A", "square", false),
        [0x1F131] = new CircledOrSquaredData("B", "square", false),
        [0x1F132] = new CircledOrSquaredData("C", "square", false),
        [0x1F133] = new CircledOrSquaredData("D", "square", false),
        [0x1F134] = new CircledOrSquaredData("E", "square", false),
        [0x1F135] = new CircledOrSquaredData("F", "square", false),
        [0x1F136] = new CircledOrSquaredData("G", "square", false),
        [0x1F137] = new CircledOrSquaredData("H", "square", false),
        [0x1F138] = new CircledOrSquaredData("I", "square", false),
        [0x1F139] = new CircledOrSquaredData("J", "square", false),
        [0x1F13A] = new CircledOrSquaredData("K", "square", false),
        [0x1F13B] = new CircledOrSquaredData("L", "square", false),
        [0x1F13C] = new CircledOrSquaredData("M", "square", false),
        [0x1F13D] = new CircledOrSquaredData("N", "square", false),
        [0x1F13E] = new CircledOrSquaredData("O", "square", false),
        [0x1F13F] = new CircledOrSquaredData("P", "square", false),
        [0x1F140] = new CircledOrSquaredData("Q", "square", false),
        [0x1F141] = new CircledOrSquaredData("R", "square", false),
        [0x1F142] = new CircledOrSquaredData("S", "square", false),
        [0x1F143] = new CircledOrSquaredData("T", "square", false),
        [0x1F144] = new CircledOrSquaredData("U", "square", false),
        [0x1F145] = new CircledOrSquaredData("V", "square", false),
        [0x1F146] = new CircledOrSquaredData("W", "square", false),
        [0x1F147] = new CircledOrSquaredData("X", "square", false),
        [0x1F148] = new CircledOrSquaredData("Y", "square", false),
        [0x1F149] = new CircledOrSquaredData("Z", "square", false),
        [0x1F14A] = new CircledOrSquaredData("HV", "square", false),
        [0x1F14B] = new CircledOrSquaredData("MV", "square", false),
        [0x1F14C] = new CircledOrSquaredData("SD", "square", false),
        [0x1F14D] = new CircledOrSquaredData("SS", "square", false),
        [0x1F14E] = new CircledOrSquaredData("PPV", "square", false),
        [0x1F14F] = new CircledOrSquaredData("WC", "square", false),
        [0x1F150] = new CircledOrSquaredData("A", "circle", false),
        [0x1F151] = new CircledOrSquaredData("B", "circle", false),
        [0x1F152] = new CircledOrSquaredData("C", "circle", false),
        [0x1F153] = new CircledOrSquaredData("D", "circle", false),
        [0x1F154] = new CircledOrSquaredData("E", "circle", false),
        [0x1F155] = new CircledOrSquaredData("F", "circle", false),
        [0x1F156] = new CircledOrSquaredData("G", "circle", false),
        [0x1F157] = new CircledOrSquaredData("H", "circle", false),
        [0x1F158] = new CircledOrSquaredData("I", "circle", false),
        [0x1F159] = new CircledOrSquaredData("J", "circle", false),
        [0x1F15A] = new CircledOrSquaredData("K", "circle", false),
        [0x1F15B] = new CircledOrSquaredData("L", "circle", false),
        [0x1F15C] = new CircledOrSquaredData("M", "circle", false),
        [0x1F15D] = new CircledOrSquaredData("N", "circle", false),
        [0x1F15E] = new CircledOrSquaredData("O", "circle", false),
        [0x1F15F] = new CircledOrSquaredData("P", "circle", false),
        [0x1F160] = new CircledOrSquaredData("Q", "circle", false),
        [0x1F161] = new CircledOrSquaredData("R", "circle", false),
        [0x1F162] = new CircledOrSquaredData("S", "circle", false),
        [0x1F163] = new CircledOrSquaredData("T", "circle", false),
        [0x1F164] = new CircledOrSquaredData("U", "circle", false),
        [0x1F165] = new CircledOrSquaredData("V", "circle", false),
        [0x1F166] = new CircledOrSquaredData("W", "circle", false),
        [0x1F167] = new CircledOrSquaredData("X", "circle", false),
        [0x1F168] = new CircledOrSquaredData("Y", "circle", false),
        [0x1F169] = new CircledOrSquaredData("Z", "circle", false),
        [0x1F16D] = new CircledOrSquaredData("CC", "circle", false),
        [0x1F170] = new CircledOrSquaredData("A", "square", false),
        [0x1F171] = new CircledOrSquaredData("B", "square", false),
        [0x1F172] = new CircledOrSquaredData("C", "square", false),
        [0x1F173] = new CircledOrSquaredData("D", "square", false),
        [0x1F174] = new CircledOrSquaredData("E", "square", false),
        [0x1F175] = new CircledOrSquaredData("F", "square", false),
        [0x1F176] = new CircledOrSquaredData("G", "square", false),
        [0x1F177] = new CircledOrSquaredData("H", "square", false),
        [0x1F178] = new CircledOrSquaredData("I", "square", false),
        [0x1F179] = new CircledOrSquaredData("J", "square", false),
        [0x1F17A] = new CircledOrSquaredData("K", "square", false),
        [0x1F17B] = new CircledOrSquaredData("L", "square", false),
        [0x1F17C] = new CircledOrSquaredData("M", "square", false),
        [0x1F17D] = new CircledOrSquaredData("N", "square", false),
        [0x1F17E] = new CircledOrSquaredData("O", "square", false),
        [0x1F17F] = new CircledOrSquaredData("P", "square", false),
        [0x1F180] = new CircledOrSquaredData("Q", "square", false),
        [0x1F181] = new CircledOrSquaredData("R", "square", false),
        [0x1F182] = new CircledOrSquaredData("S", "square", false),
        [0x1F183] = new CircledOrSquaredData("T", "square", false),
        [0x1F184] = new CircledOrSquaredData("U", "square", false),
        [0x1F185] = new CircledOrSquaredData("V", "square", false),
        [0x1F186] = new CircledOrSquaredData("W", "square", false),
        [0x1F187] = new CircledOrSquaredData("X", "square", false),
        [0x1F188] = new CircledOrSquaredData("Y", "square", false),
        [0x1F189] = new CircledOrSquaredData("Z", "square", false),
        [0x1F18B] = new CircledOrSquaredData("IC", "square", false),
        [0x1F18C] = new CircledOrSquaredData("PA", "square", false),
        [0x1F18D] = new CircledOrSquaredData("SA", "square", false),
        [0x1F18E] = new CircledOrSquaredData("AB", "square", true),
        [0x1F18F] = new CircledOrSquaredData("WC", "square", false),
        [0x1F190] = new CircledOrSquaredData("DJ", "square", false),
        [0x1F191] = new CircledOrSquaredData("CL", "square", true),
        [0x1F192] = new CircledOrSquaredData("COOL", "square", true),
        [0x1F193] = new CircledOrSquaredData("FREE", "square", true),
        [0x1F194] = new CircledOrSquaredData("ID", "square", true),
        [0x1F195] = new CircledOrSquaredData("NEW", "square", true),
        [0x1F196] = new CircledOrSquaredData("NG", "square", true),
        [0x1F197] = new CircledOrSquaredData("OK", "square", true),
        [0x1F198] = new CircledOrSquaredData("SOS", "square", true),
        [0x1F199] = new CircledOrSquaredData("UP!", "square", true),
        [0x1F19A] = new CircledOrSquaredData("VS", "square", true),
        [0x1F19B] = new CircledOrSquaredData("3D", "square", false),
        [0x1F19C] = new CircledOrSquaredData("2ndScr", "square", false),
        [0x1F19D] = new CircledOrSquaredData("2K", "square", false),
        [0x1F19E] = new CircledOrSquaredData("4K", "square", false),
        [0x1F19F] = new CircledOrSquaredData("8K", "square", false),
        [0x1F1A0] = new CircledOrSquaredData("5.1", "square", false),
        [0x1F1A1] = new CircledOrSquaredData("7.1", "square", false),
        [0x1F1A2] = new CircledOrSquaredData("22.2", "square", false),
        [0x1F1A3] = new CircledOrSquaredData("60P", "square", false),
        [0x1F1A4] = new CircledOrSquaredData("120P", "square", false),
        [0x1F1A5] = new CircledOrSquaredData("d", "square", false),
        [0x1F1A6] = new CircledOrSquaredData("HC", "square", false),
        [0x1F1A7] = new CircledOrSquaredData("HDR", "square", false),
        [0x1F1A8] = new CircledOrSquaredData("Hi-Res", "square", false),
        [0x1F1A9] = new CircledOrSquaredData("Lossless", "square", false),
        [0x1F1AA] = new CircledOrSquaredData("SHV", "square", false),
        [0x1F1AB] = new CircledOrSquaredData("UHD", "square", false),
        [0x1F1AC] = new CircledOrSquaredData("VOD", "square", false),
        [0x1F1AD] = new CircledOrSquaredData("VOD", "square", false),
        [0x1F1E6] = new CircledOrSquaredData("A", "square", false),
        [0x1F1E7] = new CircledOrSquaredData("B", "square", false),
        [0x1F1E8] = new CircledOrSquaredData("C", "square", false),
        [0x1F1E9] = new CircledOrSquaredData("D", "square", false),
        [0x1F1EA] = new CircledOrSquaredData("E", "square", false),
        [0x1F1EB] = new CircledOrSquaredData("F", "square", false),
        [0x1F1EC] = new CircledOrSquaredData("G", "square", false),
        [0x1F1ED] = new CircledOrSquaredData("H", "square", false),
        [0x1F1EE] = new CircledOrSquaredData("I", "square", false),
        [0x1F1EF] = new CircledOrSquaredData("J", "square", false),
        [0x1F1F0] = new CircledOrSquaredData("K", "square", false),
        [0x1F1F1] = new CircledOrSquaredData("L", "square", false),
        [0x1F1F2] = new CircledOrSquaredData("M", "square", false),
        [0x1F1F3] = new CircledOrSquaredData("N", "square", false),
        [0x1F1F4] = new CircledOrSquaredData("O", "square", false),
        [0x1F1F5] = new CircledOrSquaredData("P", "square", false),
        [0x1F1F6] = new CircledOrSquaredData("Q", "square", false),
        [0x1F1F7] = new CircledOrSquaredData("R", "square", false),
        [0x1F1F8] = new CircledOrSquaredData("S", "square", false),
        [0x1F1F9] = new CircledOrSquaredData("T", "square", false),
        [0x1F1FA] = new CircledOrSquaredData("U", "square", false),
        [0x1F1FB] = new CircledOrSquaredData("V", "square", false),
        [0x1F1FC] = new CircledOrSquaredData("W", "square", false),
        [0x1F1FD] = new CircledOrSquaredData("X", "square", false),
        [0x1F1FE] = new CircledOrSquaredData("Y", "square", false),
        [0x1F1FF] = new CircledOrSquaredData("Z", "square", false),
        [0x1F6BE] = new CircledOrSquaredData("WC", "square", true),
    };

    public IEnumerable<Char> Transliterate(IEnumerable<Char> input)
    {
        return new CircledOrSquaredCharEnumerator(input, _mappings, _options);
    }

    public class Options
    {
        public Options()
        {
            TemplateForCircled = "(?)";
            TemplateForSquared = "[?]";
            IncludeEmojis = false;
        }

        public string TemplateForCircled { get; set; }

        public string TemplateForSquared { get; set; }

        public bool IncludeEmojis { get; set; }
    }

    private class CircledOrSquaredData
    {
        public string Rendering { get; set; }
        public string Type { get; set; }
        public bool Emoji { get; set; }

        public CircledOrSquaredData(string rendering, string type, bool emoji)
        {
            Rendering = rendering;
            Type = type;
            Emoji = emoji;
        }
    }

    private class CircledOrSquaredCharEnumerator : IEnumerable<Char>
    {
        private readonly IEnumerable<Char> _input;
        private readonly Dictionary<int, CircledOrSquaredData> _mappings;
        private readonly Options _options;
        private int _offset = 0;
        private bool _disposed = false;
        private readonly Queue<Char> _queue = new Queue<Char>();
        private Char _source = null;

        public CircledOrSquaredCharEnumerator(IEnumerable<Char> input, Dictionary<int, CircledOrSquaredData> mappings, Options options)
        {
            _input = input ?? throw new System.ArgumentNullException(nameof(input));
            _mappings = mappings ?? throw new System.ArgumentNullException(nameof(mappings));
            _options = options ?? throw new System.ArgumentNullException(nameof(options));
        }

        public int Count => _input.Count;

        public Char Current { get; private set; }

        object System.Collections.IEnumerator.Current => Current;

        public bool MoveNext()
        {
            if (_disposed) return false;

            // If we have queued characters from a previous expansion, return them first
            if (_queue.Count > 0)
            {
                Current = _queue.Dequeue();
                return true;
            }

            if (!_input.MoveNext()) return false;

            var c = _input.Current;
            if (c.IsSentinel)
            {
                Current = c.WithOffset(_offset);
                return true;
            }

            CircledOrSquaredData data;
            if (c.CodePoint.Size == 1 && _mappings.TryGetValue(c.CodePoint.First, out data))
            {
                // Skip emoji characters if not included
                if (data.Emoji && !_options.IncludeEmojis)
                {
                    Current = c.WithOffset(_offset);
                    _offset += Current.CharCount;
                    return true;
                }

                // Get template
                string template = data.Type == "circle" ? _options.TemplateForCircled : _options.TemplateForSquared;
                var replacement = template.Replace("?", data.Rendering);
                
                if (string.IsNullOrEmpty(replacement))
                {
                    Current = c.WithOffset(_offset);
                    _offset += Current.CharCount;
                    return true;
                }

                _source = c;
                
                // Create characters for each replacement character
                var chars = replacement.Select((ch, index) => 
                    new Char(CodePointTuple.Of(ch), _offset + index, c)).ToArray();
                
                if (chars.Length > 0)
                {
                    Current = chars[0];
                    _offset += chars[0].CharCount;
                    
                    // Queue the remaining characters
                    for (int i = 1; i < chars.Length; i++)
                    {
                        _queue.Enqueue(chars[i].WithOffset(_offset));
                        _offset += chars[i].CharCount;
                    }
                }
                else
                {
                    Current = c.WithOffset(_offset);
                    _offset += Current.CharCount;
                }
            }
            else
            {
                Current = c.WithOffset(_offset);
                _offset += Current.CharCount;
            }

            return true;
        }

        public void Reset()
        {
            _input.Reset();
            _offset = 0;
            _queue.Clear();
            _source = null;
        }

        public void Dispose()
        {
            if (!_disposed)
            {
                _input?.Dispose();
                _disposed = true;
            }
        }

        public System.Collections.Generic.IEnumerator<Char> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }
}