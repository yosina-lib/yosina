// Copyright (c) Yosina. All rights reserved.

namespace Yosina.Transliterators;

/// <summary>
/// Replace circled or squared characters with templated forms.
/// This file is auto-generated. Do not edit manually.
/// </summary>
[RegisteredTransliterator("circled-or-squared")]
public class CircledOrSquaredTransliterator : ITransliterator
{
    private readonly Options options;

    public CircledOrSquaredTransliterator()
        : this(new Options())
    {
    }

    public CircledOrSquaredTransliterator(Options options)
    {
        this.options = options;
    }

    private static readonly Dictionary<int, CircledOrSquaredData> Mappings = new Dictionary<int, CircledOrSquaredData>()
    {
        [0xA9] = new CircledOrSquaredData("C", CharType.Circle, false),
        [0x2117] = new CircledOrSquaredData("P", CharType.Circle, false),
        [0x2460] = new CircledOrSquaredData("1", CharType.Circle, false),
        [0x2461] = new CircledOrSquaredData("2", CharType.Circle, false),
        [0x2462] = new CircledOrSquaredData("3", CharType.Circle, false),
        [0x2463] = new CircledOrSquaredData("4", CharType.Circle, false),
        [0x2464] = new CircledOrSquaredData("5", CharType.Circle, false),
        [0x2465] = new CircledOrSquaredData("6", CharType.Circle, false),
        [0x2466] = new CircledOrSquaredData("7", CharType.Circle, false),
        [0x2467] = new CircledOrSquaredData("8", CharType.Circle, false),
        [0x2468] = new CircledOrSquaredData("9", CharType.Circle, false),
        [0x2469] = new CircledOrSquaredData("10", CharType.Circle, false),
        [0x246A] = new CircledOrSquaredData("11", CharType.Circle, false),
        [0x246B] = new CircledOrSquaredData("12", CharType.Circle, false),
        [0x246C] = new CircledOrSquaredData("13", CharType.Circle, false),
        [0x246D] = new CircledOrSquaredData("14", CharType.Circle, false),
        [0x246E] = new CircledOrSquaredData("15", CharType.Circle, false),
        [0x246F] = new CircledOrSquaredData("16", CharType.Circle, false),
        [0x2470] = new CircledOrSquaredData("17", CharType.Circle, false),
        [0x2471] = new CircledOrSquaredData("18", CharType.Circle, false),
        [0x2472] = new CircledOrSquaredData("19", CharType.Circle, false),
        [0x2473] = new CircledOrSquaredData("20", CharType.Circle, false),
        [0x24B6] = new CircledOrSquaredData("A", CharType.Circle, false),
        [0x24B7] = new CircledOrSquaredData("B", CharType.Circle, false),
        [0x24B8] = new CircledOrSquaredData("C", CharType.Circle, false),
        [0x24B9] = new CircledOrSquaredData("D", CharType.Circle, false),
        [0x24BA] = new CircledOrSquaredData("E", CharType.Circle, false),
        [0x24BB] = new CircledOrSquaredData("F", CharType.Circle, false),
        [0x24BC] = new CircledOrSquaredData("G", CharType.Circle, false),
        [0x24BD] = new CircledOrSquaredData("H", CharType.Circle, false),
        [0x24BE] = new CircledOrSquaredData("I", CharType.Circle, false),
        [0x24BF] = new CircledOrSquaredData("J", CharType.Circle, false),
        [0x24C0] = new CircledOrSquaredData("K", CharType.Circle, false),
        [0x24C1] = new CircledOrSquaredData("L", CharType.Circle, false),
        [0x24C2] = new CircledOrSquaredData("M", CharType.Circle, false),
        [0x24C3] = new CircledOrSquaredData("N", CharType.Circle, false),
        [0x24C4] = new CircledOrSquaredData("O", CharType.Circle, false),
        [0x24C5] = new CircledOrSquaredData("P", CharType.Circle, false),
        [0x24C6] = new CircledOrSquaredData("Q", CharType.Circle, false),
        [0x24C7] = new CircledOrSquaredData("R", CharType.Circle, false),
        [0x24C8] = new CircledOrSquaredData("S", CharType.Circle, false),
        [0x24C9] = new CircledOrSquaredData("T", CharType.Circle, false),
        [0x24CA] = new CircledOrSquaredData("U", CharType.Circle, false),
        [0x24CB] = new CircledOrSquaredData("V", CharType.Circle, false),
        [0x24CC] = new CircledOrSquaredData("W", CharType.Circle, false),
        [0x24CD] = new CircledOrSquaredData("X", CharType.Circle, false),
        [0x24CE] = new CircledOrSquaredData("Y", CharType.Circle, false),
        [0x24CF] = new CircledOrSquaredData("Z", CharType.Circle, false),
        [0x24D0] = new CircledOrSquaredData("a", CharType.Circle, false),
        [0x24D1] = new CircledOrSquaredData("b", CharType.Circle, false),
        [0x24D2] = new CircledOrSquaredData("c", CharType.Circle, false),
        [0x24D3] = new CircledOrSquaredData("d", CharType.Circle, false),
        [0x24D4] = new CircledOrSquaredData("e", CharType.Circle, false),
        [0x24D5] = new CircledOrSquaredData("f", CharType.Circle, false),
        [0x24D6] = new CircledOrSquaredData("g", CharType.Circle, false),
        [0x24D7] = new CircledOrSquaredData("h", CharType.Circle, false),
        [0x24D8] = new CircledOrSquaredData("i", CharType.Circle, false),
        [0x24D9] = new CircledOrSquaredData("j", CharType.Circle, false),
        [0x24DA] = new CircledOrSquaredData("k", CharType.Circle, false),
        [0x24DB] = new CircledOrSquaredData("l", CharType.Circle, false),
        [0x24DC] = new CircledOrSquaredData("m", CharType.Circle, false),
        [0x24DD] = new CircledOrSquaredData("n", CharType.Circle, false),
        [0x24DE] = new CircledOrSquaredData("o", CharType.Circle, false),
        [0x24DF] = new CircledOrSquaredData("p", CharType.Circle, false),
        [0x24E0] = new CircledOrSquaredData("q", CharType.Circle, false),
        [0x24E1] = new CircledOrSquaredData("r", CharType.Circle, false),
        [0x24E2] = new CircledOrSquaredData("s", CharType.Circle, false),
        [0x24E3] = new CircledOrSquaredData("t", CharType.Circle, false),
        [0x24E4] = new CircledOrSquaredData("u", CharType.Circle, false),
        [0x24E5] = new CircledOrSquaredData("v", CharType.Circle, false),
        [0x24E6] = new CircledOrSquaredData("w", CharType.Circle, false),
        [0x24E7] = new CircledOrSquaredData("x", CharType.Circle, false),
        [0x24E8] = new CircledOrSquaredData("y", CharType.Circle, false),
        [0x24E9] = new CircledOrSquaredData("z", CharType.Circle, false),
        [0x24EA] = new CircledOrSquaredData("0", CharType.Circle, false),
        [0x24EB] = new CircledOrSquaredData("11", CharType.Circle, false),
        [0x24EC] = new CircledOrSquaredData("12", CharType.Circle, false),
        [0x24ED] = new CircledOrSquaredData("13", CharType.Circle, false),
        [0x24EE] = new CircledOrSquaredData("14", CharType.Circle, false),
        [0x24EF] = new CircledOrSquaredData("15", CharType.Circle, false),
        [0x24F0] = new CircledOrSquaredData("16", CharType.Circle, false),
        [0x24F1] = new CircledOrSquaredData("17", CharType.Circle, false),
        [0x24F2] = new CircledOrSquaredData("18", CharType.Circle, false),
        [0x24F3] = new CircledOrSquaredData("19", CharType.Circle, false),
        [0x24F4] = new CircledOrSquaredData("20", CharType.Circle, false),
        [0x24F5] = new CircledOrSquaredData("1", CharType.Circle, false),
        [0x24F6] = new CircledOrSquaredData("2", CharType.Circle, false),
        [0x24F7] = new CircledOrSquaredData("3", CharType.Circle, false),
        [0x24F8] = new CircledOrSquaredData("4", CharType.Circle, false),
        [0x24F9] = new CircledOrSquaredData("5", CharType.Circle, false),
        [0x24FA] = new CircledOrSquaredData("6", CharType.Circle, false),
        [0x24FB] = new CircledOrSquaredData("7", CharType.Circle, false),
        [0x24FC] = new CircledOrSquaredData("8", CharType.Circle, false),
        [0x24FD] = new CircledOrSquaredData("9", CharType.Circle, false),
        [0x24FE] = new CircledOrSquaredData("10", CharType.Circle, false),
        [0x24FF] = new CircledOrSquaredData("0", CharType.Circle, false),
        [0x2776] = new CircledOrSquaredData("1", CharType.Circle, false),
        [0x2777] = new CircledOrSquaredData("2", CharType.Circle, false),
        [0x2778] = new CircledOrSquaredData("3", CharType.Circle, false),
        [0x2779] = new CircledOrSquaredData("4", CharType.Circle, false),
        [0x277A] = new CircledOrSquaredData("5", CharType.Circle, false),
        [0x277B] = new CircledOrSquaredData("6", CharType.Circle, false),
        [0x277C] = new CircledOrSquaredData("7", CharType.Circle, false),
        [0x277D] = new CircledOrSquaredData("8", CharType.Circle, false),
        [0x277E] = new CircledOrSquaredData("9", CharType.Circle, false),
        [0x277F] = new CircledOrSquaredData("10", CharType.Circle, false),
        [0x2780] = new CircledOrSquaredData("1", CharType.Circle, false),
        [0x2781] = new CircledOrSquaredData("2", CharType.Circle, false),
        [0x2782] = new CircledOrSquaredData("3", CharType.Circle, false),
        [0x2783] = new CircledOrSquaredData("4", CharType.Circle, false),
        [0x2784] = new CircledOrSquaredData("5", CharType.Circle, false),
        [0x2785] = new CircledOrSquaredData("6", CharType.Circle, false),
        [0x2786] = new CircledOrSquaredData("7", CharType.Circle, false),
        [0x2787] = new CircledOrSquaredData("8", CharType.Circle, false),
        [0x2788] = new CircledOrSquaredData("9", CharType.Circle, false),
        [0x2789] = new CircledOrSquaredData("10", CharType.Circle, false),
        [0x278A] = new CircledOrSquaredData("1", CharType.Circle, false),
        [0x278B] = new CircledOrSquaredData("2", CharType.Circle, false),
        [0x278C] = new CircledOrSquaredData("3", CharType.Circle, false),
        [0x278D] = new CircledOrSquaredData("4", CharType.Circle, false),
        [0x278E] = new CircledOrSquaredData("5", CharType.Circle, false),
        [0x278F] = new CircledOrSquaredData("6", CharType.Circle, false),
        [0x2790] = new CircledOrSquaredData("7", CharType.Circle, false),
        [0x2791] = new CircledOrSquaredData("8", CharType.Circle, false),
        [0x2792] = new CircledOrSquaredData("9", CharType.Circle, false),
        [0x2793] = new CircledOrSquaredData("10", CharType.Circle, false),
        [0x3036] = new CircledOrSquaredData("〒", CharType.Circle, false),
        [0x3244] = new CircledOrSquaredData("問", CharType.Circle, false),
        [0x3245] = new CircledOrSquaredData("幼", CharType.Circle, false),
        [0x3246] = new CircledOrSquaredData("文", CharType.Circle, false),
        [0x3247] = new CircledOrSquaredData("箏", CharType.Circle, false),
        [0x3248] = new CircledOrSquaredData("10", CharType.Circle, false),
        [0x3251] = new CircledOrSquaredData("21", CharType.Circle, false),
        [0x3252] = new CircledOrSquaredData("22", CharType.Circle, false),
        [0x3253] = new CircledOrSquaredData("23", CharType.Circle, false),
        [0x3254] = new CircledOrSquaredData("24", CharType.Circle, false),
        [0x3255] = new CircledOrSquaredData("25", CharType.Circle, false),
        [0x3256] = new CircledOrSquaredData("26", CharType.Circle, false),
        [0x3257] = new CircledOrSquaredData("27", CharType.Circle, false),
        [0x3258] = new CircledOrSquaredData("28", CharType.Circle, false),
        [0x3259] = new CircledOrSquaredData("29", CharType.Circle, false),
        [0x325A] = new CircledOrSquaredData("30", CharType.Circle, false),
        [0x325B] = new CircledOrSquaredData("31", CharType.Circle, false),
        [0x325C] = new CircledOrSquaredData("32", CharType.Circle, false),
        [0x325D] = new CircledOrSquaredData("33", CharType.Circle, false),
        [0x325E] = new CircledOrSquaredData("34", CharType.Circle, false),
        [0x325F] = new CircledOrSquaredData("35", CharType.Circle, false),
        [0x3280] = new CircledOrSquaredData("一", CharType.Circle, false),
        [0x3281] = new CircledOrSquaredData("二", CharType.Circle, false),
        [0x3282] = new CircledOrSquaredData("三", CharType.Circle, false),
        [0x3283] = new CircledOrSquaredData("四", CharType.Circle, false),
        [0x3284] = new CircledOrSquaredData("五", CharType.Circle, false),
        [0x3285] = new CircledOrSquaredData("六", CharType.Circle, false),
        [0x3286] = new CircledOrSquaredData("七", CharType.Circle, false),
        [0x3287] = new CircledOrSquaredData("八", CharType.Circle, false),
        [0x3288] = new CircledOrSquaredData("九", CharType.Circle, false),
        [0x3289] = new CircledOrSquaredData("十", CharType.Circle, false),
        [0x328A] = new CircledOrSquaredData("月", CharType.Circle, false),
        [0x328B] = new CircledOrSquaredData("火", CharType.Circle, false),
        [0x328C] = new CircledOrSquaredData("水", CharType.Circle, false),
        [0x328D] = new CircledOrSquaredData("木", CharType.Circle, false),
        [0x328E] = new CircledOrSquaredData("金", CharType.Circle, false),
        [0x328F] = new CircledOrSquaredData("土", CharType.Circle, false),
        [0x3290] = new CircledOrSquaredData("日", CharType.Circle, false),
        [0x3291] = new CircledOrSquaredData("株", CharType.Circle, false),
        [0x3292] = new CircledOrSquaredData("有", CharType.Circle, false),
        [0x3293] = new CircledOrSquaredData("社", CharType.Circle, false),
        [0x3294] = new CircledOrSquaredData("名", CharType.Circle, false),
        [0x3295] = new CircledOrSquaredData("特", CharType.Circle, false),
        [0x3296] = new CircledOrSquaredData("財", CharType.Circle, false),
        [0x3297] = new CircledOrSquaredData("祝", CharType.Circle, false),
        [0x3298] = new CircledOrSquaredData("労", CharType.Circle, false),
        [0x3299] = new CircledOrSquaredData("秘", CharType.Circle, false),
        [0x329A] = new CircledOrSquaredData("男", CharType.Circle, false),
        [0x329B] = new CircledOrSquaredData("女", CharType.Circle, false),
        [0x329C] = new CircledOrSquaredData("適", CharType.Circle, false),
        [0x329D] = new CircledOrSquaredData("優", CharType.Circle, false),
        [0x329E] = new CircledOrSquaredData("印", CharType.Circle, false),
        [0x329F] = new CircledOrSquaredData("注", CharType.Circle, false),
        [0x32A0] = new CircledOrSquaredData("項", CharType.Circle, false),
        [0x32A1] = new CircledOrSquaredData("休", CharType.Circle, false),
        [0x32A2] = new CircledOrSquaredData("写", CharType.Circle, false),
        [0x32A3] = new CircledOrSquaredData("正", CharType.Circle, false),
        [0x32A4] = new CircledOrSquaredData("上", CharType.Circle, false),
        [0x32A5] = new CircledOrSquaredData("中", CharType.Circle, false),
        [0x32A6] = new CircledOrSquaredData("下", CharType.Circle, false),
        [0x32A7] = new CircledOrSquaredData("左", CharType.Circle, false),
        [0x32A8] = new CircledOrSquaredData("右", CharType.Circle, false),
        [0x32A9] = new CircledOrSquaredData("医", CharType.Circle, false),
        [0x32AA] = new CircledOrSquaredData("宗", CharType.Circle, false),
        [0x32AB] = new CircledOrSquaredData("学", CharType.Circle, false),
        [0x32AC] = new CircledOrSquaredData("監", CharType.Circle, false),
        [0x32AD] = new CircledOrSquaredData("企", CharType.Circle, false),
        [0x32AE] = new CircledOrSquaredData("資", CharType.Circle, false),
        [0x32AF] = new CircledOrSquaredData("協", CharType.Circle, false),
        [0x32B0] = new CircledOrSquaredData("夜", CharType.Circle, false),
        [0x32B1] = new CircledOrSquaredData("36", CharType.Circle, false),
        [0x32B2] = new CircledOrSquaredData("37", CharType.Circle, false),
        [0x32B3] = new CircledOrSquaredData("38", CharType.Circle, false),
        [0x32B4] = new CircledOrSquaredData("39", CharType.Circle, false),
        [0x32B5] = new CircledOrSquaredData("40", CharType.Circle, false),
        [0x32B6] = new CircledOrSquaredData("41", CharType.Circle, false),
        [0x32B7] = new CircledOrSquaredData("42", CharType.Circle, false),
        [0x32B8] = new CircledOrSquaredData("43", CharType.Circle, false),
        [0x32B9] = new CircledOrSquaredData("44", CharType.Circle, false),
        [0x32BA] = new CircledOrSquaredData("45", CharType.Circle, false),
        [0x32BB] = new CircledOrSquaredData("46", CharType.Circle, false),
        [0x32BC] = new CircledOrSquaredData("47", CharType.Circle, false),
        [0x32BD] = new CircledOrSquaredData("48", CharType.Circle, false),
        [0x32BE] = new CircledOrSquaredData("49", CharType.Circle, false),
        [0x32BF] = new CircledOrSquaredData("50", CharType.Circle, false),
        [0x32D0] = new CircledOrSquaredData("ア", CharType.Circle, false),
        [0x32D1] = new CircledOrSquaredData("イ", CharType.Circle, false),
        [0x32D2] = new CircledOrSquaredData("ウ", CharType.Circle, false),
        [0x32D3] = new CircledOrSquaredData("エ", CharType.Circle, false),
        [0x32D4] = new CircledOrSquaredData("オ", CharType.Circle, false),
        [0x32D5] = new CircledOrSquaredData("カ", CharType.Circle, false),
        [0x32D6] = new CircledOrSquaredData("キ", CharType.Circle, false),
        [0x32D7] = new CircledOrSquaredData("ク", CharType.Circle, false),
        [0x32D8] = new CircledOrSquaredData("ケ", CharType.Circle, false),
        [0x32D9] = new CircledOrSquaredData("コ", CharType.Circle, false),
        [0x32DA] = new CircledOrSquaredData("サ", CharType.Circle, false),
        [0x32DB] = new CircledOrSquaredData("シ", CharType.Circle, false),
        [0x32DC] = new CircledOrSquaredData("ス", CharType.Circle, false),
        [0x32DD] = new CircledOrSquaredData("セ", CharType.Circle, false),
        [0x32DE] = new CircledOrSquaredData("ソ", CharType.Circle, false),
        [0x32DF] = new CircledOrSquaredData("タ", CharType.Circle, false),
        [0x32E0] = new CircledOrSquaredData("チ", CharType.Circle, false),
        [0x32E1] = new CircledOrSquaredData("ツ", CharType.Circle, false),
        [0x32E2] = new CircledOrSquaredData("テ", CharType.Circle, false),
        [0x32E3] = new CircledOrSquaredData("ト", CharType.Circle, false),
        [0x32E4] = new CircledOrSquaredData("ナ", CharType.Circle, false),
        [0x32E5] = new CircledOrSquaredData("ニ", CharType.Circle, false),
        [0x32E6] = new CircledOrSquaredData("ヌ", CharType.Circle, false),
        [0x32E7] = new CircledOrSquaredData("ネ", CharType.Circle, false),
        [0x32E8] = new CircledOrSquaredData("ノ", CharType.Circle, false),
        [0x32E9] = new CircledOrSquaredData("ハ", CharType.Circle, false),
        [0x32EA] = new CircledOrSquaredData("ヒ", CharType.Circle, false),
        [0x32EB] = new CircledOrSquaredData("フ", CharType.Circle, false),
        [0x32EC] = new CircledOrSquaredData("ヘ", CharType.Circle, false),
        [0x32ED] = new CircledOrSquaredData("ホ", CharType.Circle, false),
        [0x32EE] = new CircledOrSquaredData("マ", CharType.Circle, false),
        [0x32EF] = new CircledOrSquaredData("ミ", CharType.Circle, false),
        [0x32F0] = new CircledOrSquaredData("ム", CharType.Circle, false),
        [0x32F1] = new CircledOrSquaredData("メ", CharType.Circle, false),
        [0x32F2] = new CircledOrSquaredData("モ", CharType.Circle, false),
        [0x32F3] = new CircledOrSquaredData("ヤ", CharType.Circle, false),
        [0x32F4] = new CircledOrSquaredData("ユ", CharType.Circle, false),
        [0x32F5] = new CircledOrSquaredData("ヨ", CharType.Circle, false),
        [0x32F6] = new CircledOrSquaredData("ラ", CharType.Circle, false),
        [0x32F7] = new CircledOrSquaredData("リ", CharType.Circle, false),
        [0x32F8] = new CircledOrSquaredData("ル", CharType.Circle, false),
        [0x32F9] = new CircledOrSquaredData("レ", CharType.Circle, false),
        [0x32FA] = new CircledOrSquaredData("ロ", CharType.Circle, false),
        [0x32FB] = new CircledOrSquaredData("ワ", CharType.Circle, false),
        [0x32FC] = new CircledOrSquaredData("ヰ", CharType.Circle, false),
        [0x32FD] = new CircledOrSquaredData("ヱ", CharType.Circle, false),
        [0x32FE] = new CircledOrSquaredData("ヲ", CharType.Circle, false),
        [0x1F10B] = new CircledOrSquaredData("0", CharType.Circle, false),
        [0x1F10C] = new CircledOrSquaredData("0", CharType.Circle, false),
        [0x1F12B] = new CircledOrSquaredData("C", CharType.Circle, false),
        [0x1F12C] = new CircledOrSquaredData("R", CharType.Circle, false),
        [0x1F12D] = new CircledOrSquaredData("CD", CharType.Circle, false),
        [0x1F12E] = new CircledOrSquaredData("WZ", CharType.Circle, false),
        [0x1F130] = new CircledOrSquaredData("A", CharType.Square, false),
        [0x1F131] = new CircledOrSquaredData("B", CharType.Square, false),
        [0x1F132] = new CircledOrSquaredData("C", CharType.Square, false),
        [0x1F133] = new CircledOrSquaredData("D", CharType.Square, false),
        [0x1F134] = new CircledOrSquaredData("E", CharType.Square, false),
        [0x1F135] = new CircledOrSquaredData("F", CharType.Square, false),
        [0x1F136] = new CircledOrSquaredData("G", CharType.Square, false),
        [0x1F137] = new CircledOrSquaredData("H", CharType.Square, false),
        [0x1F138] = new CircledOrSquaredData("I", CharType.Square, false),
        [0x1F139] = new CircledOrSquaredData("J", CharType.Square, false),
        [0x1F13A] = new CircledOrSquaredData("K", CharType.Square, false),
        [0x1F13B] = new CircledOrSquaredData("L", CharType.Square, false),
        [0x1F13C] = new CircledOrSquaredData("M", CharType.Square, false),
        [0x1F13D] = new CircledOrSquaredData("N", CharType.Square, false),
        [0x1F13E] = new CircledOrSquaredData("O", CharType.Square, false),
        [0x1F13F] = new CircledOrSquaredData("P", CharType.Square, false),
        [0x1F140] = new CircledOrSquaredData("Q", CharType.Square, false),
        [0x1F141] = new CircledOrSquaredData("R", CharType.Square, false),
        [0x1F142] = new CircledOrSquaredData("S", CharType.Square, false),
        [0x1F143] = new CircledOrSquaredData("T", CharType.Square, false),
        [0x1F144] = new CircledOrSquaredData("U", CharType.Square, false),
        [0x1F145] = new CircledOrSquaredData("V", CharType.Square, false),
        [0x1F146] = new CircledOrSquaredData("W", CharType.Square, false),
        [0x1F147] = new CircledOrSquaredData("X", CharType.Square, false),
        [0x1F148] = new CircledOrSquaredData("Y", CharType.Square, false),
        [0x1F149] = new CircledOrSquaredData("Z", CharType.Square, false),
        [0x1F14A] = new CircledOrSquaredData("HV", CharType.Square, false),
        [0x1F14B] = new CircledOrSquaredData("MV", CharType.Square, false),
        [0x1F14C] = new CircledOrSquaredData("SD", CharType.Square, false),
        [0x1F14D] = new CircledOrSquaredData("SS", CharType.Square, false),
        [0x1F14E] = new CircledOrSquaredData("PPV", CharType.Square, false),
        [0x1F14F] = new CircledOrSquaredData("WC", CharType.Square, false),
        [0x1F150] = new CircledOrSquaredData("A", CharType.Circle, false),
        [0x1F151] = new CircledOrSquaredData("B", CharType.Circle, false),
        [0x1F152] = new CircledOrSquaredData("C", CharType.Circle, false),
        [0x1F153] = new CircledOrSquaredData("D", CharType.Circle, false),
        [0x1F154] = new CircledOrSquaredData("E", CharType.Circle, false),
        [0x1F155] = new CircledOrSquaredData("F", CharType.Circle, false),
        [0x1F156] = new CircledOrSquaredData("G", CharType.Circle, false),
        [0x1F157] = new CircledOrSquaredData("H", CharType.Circle, false),
        [0x1F158] = new CircledOrSquaredData("I", CharType.Circle, false),
        [0x1F159] = new CircledOrSquaredData("J", CharType.Circle, false),
        [0x1F15A] = new CircledOrSquaredData("K", CharType.Circle, false),
        [0x1F15B] = new CircledOrSquaredData("L", CharType.Circle, false),
        [0x1F15C] = new CircledOrSquaredData("M", CharType.Circle, false),
        [0x1F15D] = new CircledOrSquaredData("N", CharType.Circle, false),
        [0x1F15E] = new CircledOrSquaredData("O", CharType.Circle, false),
        [0x1F15F] = new CircledOrSquaredData("P", CharType.Circle, false),
        [0x1F160] = new CircledOrSquaredData("Q", CharType.Circle, false),
        [0x1F161] = new CircledOrSquaredData("R", CharType.Circle, false),
        [0x1F162] = new CircledOrSquaredData("S", CharType.Circle, false),
        [0x1F163] = new CircledOrSquaredData("T", CharType.Circle, false),
        [0x1F164] = new CircledOrSquaredData("U", CharType.Circle, false),
        [0x1F165] = new CircledOrSquaredData("V", CharType.Circle, false),
        [0x1F166] = new CircledOrSquaredData("W", CharType.Circle, false),
        [0x1F167] = new CircledOrSquaredData("X", CharType.Circle, false),
        [0x1F168] = new CircledOrSquaredData("Y", CharType.Circle, false),
        [0x1F169] = new CircledOrSquaredData("Z", CharType.Circle, false),
        [0x1F170] = new CircledOrSquaredData("A", CharType.Square, false),
        [0x1F171] = new CircledOrSquaredData("B", CharType.Square, false),
        [0x1F172] = new CircledOrSquaredData("C", CharType.Square, false),
        [0x1F173] = new CircledOrSquaredData("D", CharType.Square, false),
        [0x1F174] = new CircledOrSquaredData("E", CharType.Square, false),
        [0x1F175] = new CircledOrSquaredData("F", CharType.Square, false),
        [0x1F176] = new CircledOrSquaredData("G", CharType.Square, false),
        [0x1F177] = new CircledOrSquaredData("H", CharType.Square, false),
        [0x1F178] = new CircledOrSquaredData("I", CharType.Square, false),
        [0x1F179] = new CircledOrSquaredData("J", CharType.Square, false),
        [0x1F17A] = new CircledOrSquaredData("K", CharType.Square, false),
        [0x1F17B] = new CircledOrSquaredData("L", CharType.Square, false),
        [0x1F17C] = new CircledOrSquaredData("M", CharType.Square, false),
        [0x1F17D] = new CircledOrSquaredData("N", CharType.Square, false),
        [0x1F17E] = new CircledOrSquaredData("O", CharType.Square, false),
        [0x1F17F] = new CircledOrSquaredData("P", CharType.Square, false),
        [0x1F180] = new CircledOrSquaredData("Q", CharType.Square, false),
        [0x1F181] = new CircledOrSquaredData("R", CharType.Square, false),
        [0x1F182] = new CircledOrSquaredData("S", CharType.Square, false),
        [0x1F183] = new CircledOrSquaredData("T", CharType.Square, false),
        [0x1F184] = new CircledOrSquaredData("U", CharType.Square, false),
        [0x1F185] = new CircledOrSquaredData("V", CharType.Square, false),
        [0x1F186] = new CircledOrSquaredData("W", CharType.Square, false),
        [0x1F187] = new CircledOrSquaredData("X", CharType.Square, false),
        [0x1F188] = new CircledOrSquaredData("Y", CharType.Square, false),
        [0x1F189] = new CircledOrSquaredData("Z", CharType.Square, false),
        [0x1F18B] = new CircledOrSquaredData("IC", CharType.Square, false),
        [0x1F18C] = new CircledOrSquaredData("PA", CharType.Square, false),
        [0x1F18D] = new CircledOrSquaredData("SA", CharType.Square, false),
        [0x1F18E] = new CircledOrSquaredData("AB", CharType.Square, true),
        [0x1F18F] = new CircledOrSquaredData("WC", CharType.Square, false),
        [0x1F190] = new CircledOrSquaredData("DJ", CharType.Square, false),
        [0x1F191] = new CircledOrSquaredData("CL", CharType.Square, true),
        [0x1F192] = new CircledOrSquaredData("COOL", CharType.Square, true),
        [0x1F193] = new CircledOrSquaredData("FREE", CharType.Square, true),
        [0x1F194] = new CircledOrSquaredData("ID", CharType.Square, true),
        [0x1F195] = new CircledOrSquaredData("NEW", CharType.Square, true),
        [0x1F196] = new CircledOrSquaredData("NG", CharType.Square, true),
        [0x1F197] = new CircledOrSquaredData("OK", CharType.Square, true),
        [0x1F198] = new CircledOrSquaredData("SOS", CharType.Square, true),
        [0x1F199] = new CircledOrSquaredData("UP!", CharType.Square, true),
        [0x1F19A] = new CircledOrSquaredData("VS", CharType.Square, true),
        [0x1F19B] = new CircledOrSquaredData("3D", CharType.Square, false),
        [0x1F19C] = new CircledOrSquaredData("2ndScr", CharType.Square, false),
        [0x1F19D] = new CircledOrSquaredData("2K", CharType.Square, false),
        [0x1F19E] = new CircledOrSquaredData("4K", CharType.Square, false),
        [0x1F19F] = new CircledOrSquaredData("8K", CharType.Square, false),
        [0x1F1A0] = new CircledOrSquaredData("5.1", CharType.Square, false),
        [0x1F1A1] = new CircledOrSquaredData("7.1", CharType.Square, false),
        [0x1F1A2] = new CircledOrSquaredData("22.2", CharType.Square, false),
        [0x1F1A3] = new CircledOrSquaredData("60P", CharType.Square, false),
        [0x1F1A4] = new CircledOrSquaredData("120P", CharType.Square, false),
        [0x1F1A5] = new CircledOrSquaredData("d", CharType.Square, false),
        [0x1F1A6] = new CircledOrSquaredData("HC", CharType.Square, false),
        [0x1F1A7] = new CircledOrSquaredData("HDR", CharType.Square, false),
        [0x1F1A8] = new CircledOrSquaredData("Hi-Res", CharType.Square, false),
        [0x1F1A9] = new CircledOrSquaredData("Lossless", CharType.Square, false),
        [0x1F1AA] = new CircledOrSquaredData("SHV", CharType.Square, false),
        [0x1F1AB] = new CircledOrSquaredData("UHD", CharType.Square, false),
        [0x1F1AC] = new CircledOrSquaredData("VOD", CharType.Square, false),
        [0x1F1AD] = new CircledOrSquaredData("M", CharType.Circle, false),
        [0x1F1E6] = new CircledOrSquaredData("A", CharType.Square, false),
        [0x1F1E7] = new CircledOrSquaredData("B", CharType.Square, false),
        [0x1F1E8] = new CircledOrSquaredData("C", CharType.Square, false),
        [0x1F1E9] = new CircledOrSquaredData("D", CharType.Square, false),
        [0x1F1EA] = new CircledOrSquaredData("E", CharType.Square, false),
        [0x1F1EB] = new CircledOrSquaredData("F", CharType.Square, false),
        [0x1F1EC] = new CircledOrSquaredData("G", CharType.Square, false),
        [0x1F1ED] = new CircledOrSquaredData("H", CharType.Square, false),
        [0x1F1EE] = new CircledOrSquaredData("I", CharType.Square, false),
        [0x1F1EF] = new CircledOrSquaredData("J", CharType.Square, false),
        [0x1F1F0] = new CircledOrSquaredData("K", CharType.Square, false),
        [0x1F1F1] = new CircledOrSquaredData("L", CharType.Square, false),
        [0x1F1F2] = new CircledOrSquaredData("M", CharType.Square, false),
        [0x1F1F3] = new CircledOrSquaredData("N", CharType.Square, false),
        [0x1F1F4] = new CircledOrSquaredData("O", CharType.Square, false),
        [0x1F1F5] = new CircledOrSquaredData("P", CharType.Square, false),
        [0x1F1F6] = new CircledOrSquaredData("Q", CharType.Square, false),
        [0x1F1F7] = new CircledOrSquaredData("R", CharType.Square, false),
        [0x1F1F8] = new CircledOrSquaredData("S", CharType.Square, false),
        [0x1F1F9] = new CircledOrSquaredData("T", CharType.Square, false),
        [0x1F1FA] = new CircledOrSquaredData("U", CharType.Square, false),
        [0x1F1FB] = new CircledOrSquaredData("V", CharType.Square, false),
        [0x1F1FC] = new CircledOrSquaredData("W", CharType.Square, false),
        [0x1F1FD] = new CircledOrSquaredData("X", CharType.Square, false),
        [0x1F1FE] = new CircledOrSquaredData("Y", CharType.Square, false),
        [0x1F1FF] = new CircledOrSquaredData("Z", CharType.Square, false),
        [0x1F200] = new CircledOrSquaredData("ほか", CharType.Square, false),
        [0x1F201] = new CircledOrSquaredData("ココ", CharType.Square, true),
        [0x1F202] = new CircledOrSquaredData("サ", CharType.Square, false),
        [0x1F210] = new CircledOrSquaredData("手", CharType.Square, false),
        [0x1F211] = new CircledOrSquaredData("字", CharType.Square, false),
        [0x1F212] = new CircledOrSquaredData("双", CharType.Square, false),
        [0x1F213] = new CircledOrSquaredData("デ", CharType.Square, false),
        [0x1F214] = new CircledOrSquaredData("二", CharType.Square, false),
        [0x1F215] = new CircledOrSquaredData("多", CharType.Square, false),
        [0x1F216] = new CircledOrSquaredData("解", CharType.Square, false),
        [0x1F217] = new CircledOrSquaredData("天", CharType.Square, false),
        [0x1F218] = new CircledOrSquaredData("交", CharType.Square, false),
        [0x1F219] = new CircledOrSquaredData("映", CharType.Square, false),
        [0x1F21A] = new CircledOrSquaredData("無", CharType.Square, true),
        [0x1F21B] = new CircledOrSquaredData("料", CharType.Square, false),
        [0x1F21C] = new CircledOrSquaredData("前", CharType.Square, false),
        [0x1F21D] = new CircledOrSquaredData("後", CharType.Square, false),
        [0x1F21E] = new CircledOrSquaredData("再", CharType.Square, false),
        [0x1F21F] = new CircledOrSquaredData("新", CharType.Square, false),
        [0x1F220] = new CircledOrSquaredData("初", CharType.Square, false),
        [0x1F221] = new CircledOrSquaredData("終", CharType.Square, false),
        [0x1F222] = new CircledOrSquaredData("生", CharType.Square, false),
        [0x1F223] = new CircledOrSquaredData("販", CharType.Square, false),
        [0x1F224] = new CircledOrSquaredData("声", CharType.Square, false),
        [0x1F225] = new CircledOrSquaredData("吹", CharType.Square, false),
        [0x1F226] = new CircledOrSquaredData("演", CharType.Square, false),
        [0x1F227] = new CircledOrSquaredData("投", CharType.Square, false),
        [0x1F228] = new CircledOrSquaredData("捕", CharType.Square, false),
        [0x1F229] = new CircledOrSquaredData("一", CharType.Square, false),
        [0x1F22A] = new CircledOrSquaredData("三", CharType.Square, false),
        [0x1F22B] = new CircledOrSquaredData("遊", CharType.Square, false),
        [0x1F22C] = new CircledOrSquaredData("左", CharType.Square, false),
        [0x1F22D] = new CircledOrSquaredData("中", CharType.Square, false),
        [0x1F22E] = new CircledOrSquaredData("右", CharType.Square, false),
        [0x1F22F] = new CircledOrSquaredData("指", CharType.Square, true),
        [0x1F230] = new CircledOrSquaredData("走", CharType.Square, false),
        [0x1F231] = new CircledOrSquaredData("打", CharType.Square, false),
        [0x1F232] = new CircledOrSquaredData("禁", CharType.Square, true),
        [0x1F233] = new CircledOrSquaredData("空", CharType.Square, true),
        [0x1F234] = new CircledOrSquaredData("合", CharType.Square, true),
        [0x1F235] = new CircledOrSquaredData("満", CharType.Square, true),
        [0x1F236] = new CircledOrSquaredData("有", CharType.Square, true),
        [0x1F237] = new CircledOrSquaredData("月", CharType.Square, false),
        [0x1F238] = new CircledOrSquaredData("申", CharType.Square, true),
        [0x1F239] = new CircledOrSquaredData("割", CharType.Square, true),
        [0x1F23A] = new CircledOrSquaredData("営", CharType.Square, true),
        [0x1F23B] = new CircledOrSquaredData("配", CharType.Square, false),
        [0x1F250] = new CircledOrSquaredData("得", CharType.Circle, true),
        [0x1F251] = new CircledOrSquaredData("可", CharType.Circle, true),
        [0x1F6BE] = new CircledOrSquaredData("WC", CharType.Square, true),
    };

    public IEnumerable<Character> Transliterate(IEnumerable<Character> input)
    {
        return new CircledOrSquaredCharEnumerator(input.GetEnumerator(), Mappings, this.options);
    }

    public class Options
    {
        public Options()
        {
            this.TemplateForCircled = "(?)";
            this.TemplateForSquared = "[?]";
            this.IncludeEmojis = false;
        }

        public string TemplateForCircled { get; set; }

        public string TemplateForSquared { get; set; }

        public bool IncludeEmojis { get; set; }
    }

    private enum CharType
    {
        Circle,
        Square,
    }

    private record CircledOrSquaredData
    {
        public string Rendering { get; init; }

        public CharType Type { get; init; }

        public bool Emoji { get; init; }

        public CircledOrSquaredData(string rendering, CharType type, bool emoji)
        {
            this.Rendering = rendering;
            this.Type = type;
            this.Emoji = emoji;
        }
    }

    private class CircledOrSquaredCharEnumerator : IEnumerable<Character>, IEnumerator<Character>
    {
        private readonly IEnumerator<Character> input;
        private readonly Dictionary<int, CircledOrSquaredData> mappings;
        private readonly Options options;
        private int offset;
        private bool disposed;
        private readonly Queue<Character> queue = new Queue<Character>();

        public CircledOrSquaredCharEnumerator(IEnumerator<Character> input, Dictionary<int, CircledOrSquaredData> mappings, Options options)
        {
            this.input = input;
            this.mappings = mappings;
            this.options = options;
        }

        public Character Current { get; private set; } = null!;

        object System.Collections.IEnumerator.Current => this.Current;

        public bool MoveNext()
        {
            if (this.disposed)
            {
                return false;
            }

            // If we have queued characters from a previous expansion, return them first
            if (this.queue.Count > 0)
            {
                this.Current = this.queue.Dequeue();
                return true;
            }

            if (!this.input.MoveNext())
            {
                return false;
            }

            var c = this.input.Current;
            if (c.IsSentinel)
            {
                this.Current = c.WithOffset(this.offset);
                return true;
            }

            CircledOrSquaredData? data;
            if (c.CodePoint.Size() == 1 && this.mappings.TryGetValue(c.CodePoint.First, out data))
            {
                // Skip emoji characters if not included
                if (data.Emoji && !this.options.IncludeEmojis)
                {
                    this.Current = c.WithOffset(this.offset);
                    this.offset += this.Current.CharCount;
                    return true;
                }

                // Get template
                string template = data.Type == CharType.Circle ? this.options.TemplateForCircled : this.options.TemplateForSquared;
                var replacement = template.Replace("?", data.Rendering);

                if (string.IsNullOrEmpty(replacement))
                {
                    this.Current = c.WithOffset(this.offset);
                    this.offset += this.Current.CharCount;
                    return true;
                }

                // Create characters for each replacement character
                var chars = replacement.Select((ch, index) =>
                    new Character((ch, -1), this.offset + index, c)).ToArray();

                if (chars.Length > 0)
                {
                    this.Current = chars[0];
                    this.offset += chars[0].CharCount;

                    // Queue the remaining characters
                    for (int i = 1; i < chars.Length; i++)
                    {
                        this.queue.Enqueue(chars[i].WithOffset(this.offset));
                        this.offset += chars[i].CharCount;
                    }
                }
                else
                {
                    this.Current = c.WithOffset(this.offset);
                    this.offset += this.Current.CharCount;
                }
            }
            else
            {
                this.Current = c.WithOffset(this.offset);
                this.offset += this.Current.CharCount;
            }

            return true;
        }

        public void Reset()
        {
            this.input.Reset();
            this.offset = 0;
            this.queue.Clear();
        }

        public void Dispose()
        {
            if (!this.disposed)
            {
                this.input.Dispose();
                this.disposed = true;
            }
        }

        public System.Collections.Generic.IEnumerator<Character> GetEnumerator() => this;

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator() => this;
    }
}
