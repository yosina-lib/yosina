import { isTransliterated } from "../intrinsics.js";
import type { Char } from "../types.js";

type CharType = number;

const OTHER = 0x00;
const HIRAGANA = 0x20;
const KATAKANA = 0x40;
const ALPHABET = 0x60;
const DIGIT = 0x80;
const EITHER = 0xa0;
const HALFWIDTH = 1 << 0;
const VOWEL_ENDED = 1 << 1;
const HATSUON = 1 << 2;
const SOKUON = 1 << 3;
const PROLONGED_SOUND_MARK = 1 << 4;
const HALFWIDTH_DIGIT = DIGIT | HALFWIDTH;
const FULLWIDTH_DIGIT = DIGIT;
const HALFWIDTH_ALPHABET = ALPHABET | HALFWIDTH;
const FULLWIDTH_ALPHABET = ALPHABET;
const ORDINARY_HIRAGANA = HIRAGANA | VOWEL_ENDED;
const ORDINARY_KATAKANA = KATAKANA | VOWEL_ENDED;
const ORDINARY_HALFWIDTH_KATAKANA = KATAKANA | VOWEL_ENDED | HALFWIDTH;

const specials: Map<number, CharType> = new Map([
  [0xff70, KATAKANA | PROLONGED_SOUND_MARK | HALFWIDTH],
  [0x30fc, EITHER | PROLONGED_SOUND_MARK],
  [0x3063, HIRAGANA | SOKUON],
  [0x3093, HIRAGANA | HATSUON],
  [0x30c3, HIRAGANA | SOKUON],
  [0x30f3, KATAKANA | HATSUON],
  [0xff6f, KATAKANA | SOKUON | HALFWIDTH],
  [0xff9d, KATAKANA | HATSUON | HALFWIDTH],
]);

const getCharType = (c: number): CharType => {
  if (c >= 0x30 && c <= 0x39) {
    return HALFWIDTH_DIGIT;
  }
  if (c >= 0xff10 && c <= 0xff19) {
    return FULLWIDTH_DIGIT;
  }
  if ((c >= 0x41 && c <= 0x5a) || (c >= 0x61 && c <= 0x7a)) {
    return HALFWIDTH_ALPHABET;
  }
  if ((c >= 0xff21 && c <= 0xff3a) || (c >= 0xff41 && c <= 0xff5a)) {
    return FULLWIDTH_ALPHABET;
  }
  {
    const v = specials.get(c);
    if (v) {
      return v;
    }
  }
  if ((c >= 0x3041 && c <= 0x309c) || c === 0x309f) {
    return ORDINARY_HIRAGANA;
  }
  if ((c >= 0x30a1 && c <= 0x30fa) || (c >= 0x30fd && c <= 0x30ff)) {
    return ORDINARY_KATAKANA;
  }
  if ((c >= 0xff66 && c <= 0xff6f) || (c >= 0xff71 && c <= 0xff9f)) {
    return ORDINARY_HALFWIDTH_KATAKANA;
  }
  return OTHER;
};

const isAlnum = (c: CharType) => {
  const masked = c & 0xe0;
  return masked === ALPHABET || masked === DIGIT;
};
const isHalfwidth = (c: CharType) => (c & HALFWIDTH) !== 0;

export type Options = {
  skipAlreadyTransliteratedChars?: boolean;
  allowProlongedHatsuon?: boolean;
  allowProlongedSokuon?: boolean;
  replaceProlongedMarksFollowingAlnums?: boolean;
};

const isHyphenLike = (c: string) =>
  c === "\u{002d}" ||
  c === "\u{2010}" ||
  c === "\u{2014}" ||
  c === "\u{2015}" ||
  c === "\u{2212}" ||
  c === "\u{ff0d}" ||
  c === "\u{ff70}" ||
  c === "\u{30fc}";

export default (options: Options) => {
  let prolongables: CharType = VOWEL_ENDED | PROLONGED_SOUND_MARK;
  if (options.allowProlongedHatsuon) {
    prolongables |= HATSUON;
  }
  if (options.allowProlongedSokuon) {
    prolongables |= SOKUON;
  }
  return function* (chars: Iterable<Char>) {
    let offset = 0;
    let processedCharsInLookahead = false;
    let lookaheadBuf: Char[] = [];
    let lastNonProlongedChar: [Char, CharType] | undefined;
    for (const c of chars) {
      if (lookaheadBuf.length > 0) {
        if (isHyphenLike(c.c)) {
          processedCharsInLookahead ||= c.source !== undefined;
          lookaheadBuf.push(c);
          continue;
        }
        const prevNonProlongedChar = lastNonProlongedChar;
        lastNonProlongedChar = [c, getCharType(c.c.codePointAt(0) ?? -1)];
        if (
          (prevNonProlongedChar === undefined || isAlnum(prevNonProlongedChar[1])) &&
          (!options.skipAlreadyTransliteratedChars || !processedCharsInLookahead)
        ) {
          const cc = (
            prevNonProlongedChar === undefined
              ? isHalfwidth(lastNonProlongedChar[1])
              : isHalfwidth(prevNonProlongedChar[1])
          )
            ? "\u{002d}"
            : "\u{ff0d}";
          for (const c of lookaheadBuf) {
            yield { c: cc, offset, source: c };
            offset += cc.length;
          }
        } else {
          for (const c of lookaheadBuf) {
            yield { c: c.c, offset, source: c };
            offset += c.c.length;
          }
        }
        lookaheadBuf = [];
        yield { c: c.c, offset, source: c };
        offset += c.c.length;
        lastNonProlongedChar = [c, getCharType(c.c.codePointAt(0) ?? -1)];
        processedCharsInLookahead = false;
        continue;
      }
      if (isHyphenLike(c.c)) {
        const should_process = !options.skipAlreadyTransliteratedChars || !isTransliterated(c);
        if (should_process && lastNonProlongedChar !== undefined) {
          if ((prolongables & lastNonProlongedChar[1]) !== 0) {
            const cc = isHalfwidth(lastNonProlongedChar[1]) ? "\u{ff70}" : "\u{30fc}";
            yield { c: cc, offset, source: c };
            offset += cc.length;
            continue;
          } else {
            if (options.replaceProlongedMarksFollowingAlnums && isAlnum(lastNonProlongedChar[1])) {
              lookaheadBuf.push(c);
              continue;
            }
          }
        }
      } else {
        lastNonProlongedChar = [c, getCharType(c.c.codePointAt(0) ?? -1)];
      }
      yield { c: c.c, offset, source: c };
      offset += c.c.length;
    }
  };
};
