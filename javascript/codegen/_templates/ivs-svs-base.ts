/***
 * This module implements a transliterator that replaces characters accompanied by IVSes and SVSes to their base characters, or vice versa.
 *
 * @module
 */
type Char = {
  c: string;
  offset: number;
  source: Char | undefined;
};

type IVSSVSBaseMapping = {
  ivs: string;
  svs: string | undefined;
  base: string | undefined;
};

type IVSSVSBaseMappingSet = {
  unijis_90: Record<string, IVSSVSBaseMapping>;
  unijis_2004: Record<string, IVSSVSBaseMapping>;
};

const IVS_0 = 0;
const IVS_1 = 1;
const SVS_0 = 2;
const SVS_1 = 3;
const BASE90 = 4;
const BASE2004 = 5;

const mappings: string = "";

const charsMappedToPUA = [
  "𠀋",
  "𠂉",
  "𠂊",
  "𠂢",
  "𠂤",
  "𠂰",
  "𠃵",
  "𠅘",
  "𠆢",
  "𠈓",
  "𠌫",
  "𠍱",
  "𠎁",
  "𠏹",
  "𠑊",
  "𠔉",
  "𠔿",
  "𠖱",
  "𠗖",
  "𠘑",
  "𠘨",
  "𠛬",
  "𠝏",
  "𠟈",
  "𠠇",
  "𠠺",
  "𠢹",
  "𠤎",
  "𠥼",
  "𠦄",
  "𠦝",
  "𠩤",
  "𠫓",
  "𠬝",
  "𠮟",
  "𠮷",
  "𠵅",
  "𠵘",
  "𠷡",
  "𠹤",
  "𠹭",
  "𠺕",
  "𠽟",
  "𡈁",
  "𡈽",
  "𡉕",
  "𡉴",
  "𡉻",
  "𡋗",
  "𡋤",
  "𡋽",
  "𡌛",
  "𡌶",
  "𡍄",
  "𡏄",
  "𡑭",
  "𡑮",
  "𡗗",
  "𡙇",
  "𡚴",
  "𡜆",
  "𡝂",
  "𡢽",
  "𡧃",
  "𡨚",
  "𡱖",
  "𡴭",
  "𡵅",
  "𡵢",
  "𡵸",
  "𡶒",
  "𡶜",
  "𡶡",
  "𡶷",
  "𡷠",
  "𡸳",
  "𡸴",
  "𡼞",
  "𡽶",
  "𡿺",
  "𢅻",
  "𢈘",
  "𢌞",
  "𢎭",
  "𢘉",
  "𢛳",
  "𢡛",
  "𢢫",
  "𢦏",
  "𢪸",
  "𢭆",
  "𢭏",
  "𢭐",
  "𢮦",
  "𢰝",
  "𢰤",
  "𢷡",
  "𢹂",
  "𢿫",
  "𣆶",
  "𣇃",
  "𣇄",
  "𣇵",
  "𣍲",
  "𣏌",
  "𣏐",
  "𣏒",
  "𣏓",
  "𣏕",
  "𣏚",
  "𣏟",
  "𣏤",
  "𣏾",
  "𣑊",
  "𣑋",
  "𣑑",
  "𣑥",
  "𣓤",
  "𣕚",
  "𣖔",
  "𣗄",
  "𣘸",
  "𣘹",
  "𣘺",
  "𣙇",
  "𣜌",
  "𣜜",
  "𣜿",
  "𣝣",
  "𣝤",
  "𣟧",
  "𣟿",
  "𣠤",
  "𣠽",
  "𣪘",
  "𣱿",
  "𣲾",
  "𣳾",
  "𣴀",
  "𣴎",
  "𣵀",
  "𣷓",
  "𣷹",
  "𣷺",
  "𣽾",
  "𤁋",
  "𤂖",
  "𤄃",
  "𤇆",
  "𤇾",
  "𤋮",
  "𤎼",
  "𤏐",
  "𤘩",
  "𤚥",
  "𤟱",
  "𤢖",
  "𤩍",
  "𤭖",
  "𤭯",
  "𤰖",
  "𤴔",
  "𤸄",
  "𤸎",
  "𤸷",
  "𤹪",
  "𤺋",
  "𤿲",
  "𥁊",
  "𥁕",
  "𥄢",
  "𥆩",
  "𥇍",
  "𥇥",
  "𥈞",
  "𥉌",
  "𥐮",
  "𥒎",
  "𥓙",
  "𥔎",
  "𥖧",
  "𥙿",
  "𥝱",
  "𥞩",
  "𥞴",
  "𥡴",
  "𥧄",
  "𥧌",
  "𥧔",
  "𥫗",
  "𥫣",
  "𥫤",
  "𥫱",
  "𥮲",
  "𥱋",
  "𥱤",
  "𥶡",
  "𥸮",
  "𥹖",
  "𥹢",
  "𥹥",
  "𥻂",
  "𥻘",
  "𥻨",
  "𥼣",
  "𥽜",
  "𥿔",
  "𥿠",
  "𥿻",
  "𦀌",
  "𦀗",
  "𦁠",
  "𦃭",
  "𦈢",
  "𦉪",
  "𦉰",
  "𦊆",
  "𦍌",
  "𦐂",
  "𦙾",
  "𦚰",
  "𦜝",
  "𦣝",
  "𦣪",
  "𦥑",
  "𦥯",
  "𦦙",
  "𦧝",
  "𦨞",
  "𦩘",
  "𦪌",
  "𦪷",
  "𦫿",
  "𦰩",
  "𦱳",
  "𦲞",
  "𦳝",
  "𦹀",
  "𦹥",
  "𦾔",
  "𦿶",
  "𦿷",
  "𦿸",
  "𧃴",
  "𧄍",
  "𧄹",
  "𧏚",
  "𧏛",
  "𧏾",
  "𧐐",
  "𧑉",
  "𧘔",
  "𧘕",
  "𧘱",
  "𧚄",
  "𧚓",
  "𧜎",
  "𧜣",
  "𧝒",
  "𧦅",
  "𧦴",
  "𧪄",
  "𧮳",
  "𧮾",
  "𧯇",
  "𧰼",
  "𧲸",
  "𧵳",
  "𧶠",
  "𧸐",
  "𧾷",
  "𨂊",
  "𨂻",
  "𨉷",
  "𨊂",
  "𨋳",
  "𨏍",
  "𨐌",
  "𨑕",
  "𨕫",
  "𨗈",
  "𨗉",
  "𨛗",
  "𨛺",
  "𨥆",
  "𨥉",
  "𨥫",
  "𨦇",
  "𨦈",
  "𨦺",
  "𨦻",
  "𨨞",
  "𨨩",
  "𨩃",
  "𨩱",
  "𨪙",
  "𨫍",
  "𨫝",
  "𨫤",
  "𨯁",
  "𨯯",
  "𨳝",
  "𨴐",
  "𨵱",
  "𨷻",
  "𨸗",
  "𨸟",
  "𨸶",
  "𨺉",
  "𨻫",
  "𨻶",
  "𨼲",
  "𨿸",
  "𩊠",
  "𩊱",
  "𩒐",
  "𩗏",
  "𩙿",
  "𩛰",
  "𩜙",
  "𩝐",
  "𩣆",
  "𩩲",
  "𩵋",
  "𩷛",
  "𩸕",
  "𩸽",
  "𩹉",
  "𩺊",
  "𩻄",
  "𩻛",
  "𩻩",
  "𩿎",
  "𩿗",
  "𪀚",
  "𪀯",
  "𪂂",
  "𪃹",
  "𪆐",
  "𪊲",
  "𪎌",
  "𪐷",
  "𪗱",
  "𪘂",
  "𪘚",
  "𪚲",
  "𪧦",
  "𫝆",
  "𫝑",
  "𫝓",
  "𫝚",
  "𫝜",
  "𫝥",
  "𫝶",
  "𫝷",
  "𫝼",
  "𫞂",
  "𫞉",
  "𫞋",
  "𫞎",
  "𫞔",
  "𫞬",
  "𫞯",
  "𫞽",
  "𫟉",
  "𫟏",
  "𫟒",
  "𫟘",
  "𫟰",
  "𫠍",
  "𫠗",
  "𫠚",
  "𭕄",
  "𮉸",
  "𮕩",
  "𮛪",
  "你",
  "兔",
  "再",
  "冤",
  "冬",
  "割",
  "勺",
  "卿",
  "周",
  "善",
  "城",
  "姬",
  "寃",
  "将",
  "屠",
  "巽",
  "形",
  "彫",
  "慈",
  "憲",
  "成",
  "拔",
  "冕",
  "杞",
  "杓",
  "桒",
  "栟",
  "槪",
  "櫛",
  "沿",
  "浩",
  "滋",
  "潮",
  "炭",
  "爨",
  "爵",
  "眞",
  "真",
  "絣",
  "芽",
  "諭",
  "軔",
  "輸",
  "嶲",
  "𱍐",
  "\u{e0100}",
  "\u{e0101}",
  "\u{e0102}",
  "\u{e0103}",
  "\u{e0104}",
  "\u{e0105}",
  "\u{e0106}",
  "\u{e0107}",
  "\u{e0108}",
  "\u{e0109}",
  "\u{e010a}",
  "\u{e010b}",
  "\u{e010c}",
  "\u{e010d}",
  "\u{e010e}",
];

const getMappings = (() => {
  let _mappings: IVSSVSBaseMappingSet | undefined;

  return (): IVSSVSBaseMappingSet => {
    if (_mappings === undefined) {
      _mappings = {
        unijis_90: {},
        unijis_2004: {},
      };
      let i = 0;
      let ivs: string | undefined;
      let svs: string | undefined;
      let base90: string | undefined;
      let base2004: string | undefined;
      for (let c of mappings) {
        const cc = c.codePointAt(0) as number;
        if (cc >= 0xe000 && cc <= 0xf8ff) {
          c = charsMappedToPUA[cc - 0xe000];
        }
        switch (i++) {
          case IVS_0:
            if (cc) {
              ivs = c;
            } else {
              ++i;
            }
            break;
          case IVS_1:
            ivs += c;
            break;
          case SVS_0:
            if (cc) {
              svs = c;
            } else {
              ++i;
            }
            break;
          case SVS_1:
            svs += c;
            break;
          case BASE90:
            base90 = cc ? c : undefined;
            break;
          case BASE2004: {
            base2004 = cc ? c : undefined;
            if (ivs === undefined) {
              continue;
            }
            if (base90 !== undefined) {
              const r = { ivs, svs, base: base90 };
              _mappings.unijis_90[ivs] = r;
              if (svs !== undefined) {
                _mappings.unijis_90[svs] = r;
              }
              _mappings.unijis_90[base90] = r;
            }
            if (base2004 !== undefined) {
              const r = { ivs, svs, base: base2004 };
              _mappings.unijis_2004[ivs] = r;
              if (svs !== undefined) {
                _mappings.unijis_2004[svs] = r;
              }
              _mappings.unijis_2004[base2004] = r;
            }
            i = 0;
            ivs = svs = base90 = base2004 = undefined;
            break;
          }
        }
      }
    }
    return _mappings;
  };
})();

/**
 * Charset assumed in the transliteration.
 */
export type Charset = "unijis_90" | "unijis_2004";

/**
 * Options for the transliterator.
 */
export type Options = {
  /** Character set based on which the substitution will be performed. */
  charset?: Charset;
  /** Transliteration mode. `"ivs-or-svs"` for the decoration of Kanji characters with the adjacent IVSes / SVSes, or `"base"` for the removal of IVSes and SVSes from the decorated Kanjis. */
  mode: "ivs-or-svs" | "base";
  /** For a given Kanji codepoint, if there are an SVS and an IVS that specify the same glyph, prefer the SVS over the IVS. */
  preferSVS?: boolean;
  /** When the mode is `"base"`, get rid of all the selectors from the result, regardless of being contained in the mappings. */
  dropSelectorsAltogether?: boolean;
};

/**
 * Default charset base on which the transliteration will be performed.
 */
export const DEFAULT_CHARSET = "unijis_2004";

/**
 * Replaces characters accompanied by IVSes and SVSes to their base characters, or vice versa.
 *
 * @param options Options for the transliterator.
 */
export default (options: Options): ((_: Iterable<Char>) => Iterable<Char>) => {
  const charset = options.charset ?? DEFAULT_CHARSET;
  const m = getMappings()[charset];
  const a = ((): ((c: Char) => string | undefined) => {
    switch (options.mode ?? "base") {
      case "ivs-or-svs":
        return options.preferSVS
          ? (c) => {
              const r = m[c.c];
              return r && (r.svs ?? r.ivs);
            }
          : (c) => m[c.c]?.ivs;
      case "base":
        return options.dropSelectorsAltogether
          ? (c) => {
              const base = m[c.c]?.base;
              if (base !== undefined) {
                base;
              }
              const cc = c.c.codePointAt(0);
              return cc !== undefined ? String.fromCodePoint(cc) : "";
            }
          : (c) => m[c.c]?.base;
    }
  })();
  return function* (in_: Iterable<Char>) {
    let offset = 0;
    for (const c of in_) {
      const cc = a(c) ?? c.c;
      yield { c: cc, offset: offset, source: c };
      offset += cc.length;
    }
  };
};
