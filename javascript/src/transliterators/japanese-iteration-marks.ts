import type { Char } from "../types.js";
import { semivoicedCharacters, voicedCharacters } from "./hira-kata-table.js";

export type Options = Record<string, never>;

enum CharType {
  OTHER,
  HIRAGANA,
  HIRAGANA_HATSUON,
  HIRAGANA_SOKUON,
  HIRAGANA_ITERATION_MARK,
  HIRAGANA_VOICED,
  HIRAGANA_VOICED_ITERATION_MARK,
  HIRAGANA_SEMIVOICED,
  KATAKANA,
  KATAKANA_HATSUON,
  KATAKANA_SOKUON,
  KATAKANA_ITERATION_MARK,
  KATAKANA_VOICED,
  KATAKANA_VOICED_ITERATION_MARK,
  KATAKANA_SEMIVOICED,
  KANJI,
  KANJI_ITERATION_MARK,
}

// Create lookup maps from the existing tables
// biome-ignore lint/style/noNonNullAssertion: safe
const voicingMap = new Map<number, string>(voicedCharacters.map(([h, k]) => [h.codePointAt(0)!, k]));

// biome-ignore lint/style/noNonNullAssertion: safe
const unvoicingMap = new Map<number, string>(voicedCharacters.map(([h, k]) => [k.codePointAt(0)!, h]));

// Helper function to check if a character is a hiragana
const isHiragana = (codepoint: number): boolean => {
  return codepoint >= 0x3041 && codepoint <= 0x3096;
};

// Helper function to check if a character is a katakana
const isKatakana = (codepoint: number): boolean => {
  return codepoint >= 0x30a1 && codepoint <= 0x30f6;
};

const voicedChars = new Map<number, CharType>(
  voicedCharacters
    .map(([_, c]): [number, CharType] => {
      // biome-ignore lint/style/noNonNullAssertion: safe
      const codepoint = c.codePointAt(0)!;
      return [codepoint, isHiragana(codepoint) ? CharType.HIRAGANA_VOICED : CharType.KATAKANA_VOICED];
    })
    .concat(
      semivoicedCharacters.map(([_, c]): [number, CharType] => {
        // biome-ignore lint/style/noNonNullAssertion: safe
        const codepoint = c.codePointAt(0)!;
        return [codepoint, isHiragana(codepoint) ? CharType.HIRAGANA_SEMIVOICED : CharType.KATAKANA_SEMIVOICED];
      }),
    ),
);

// Helper function to check if a character is a kanji
const isKanji = (codepoint: number): boolean => {
  return (
    (codepoint >= 0x4e00 && codepoint <= 0x9fff) || // CJK Unified Ideographs
    (codepoint >= 0x3400 && codepoint <= 0x4dbf) || // CJK Extension A
    (codepoint >= 0x20000 && codepoint <= 0x2a6df) || // CJK Extension B
    (codepoint >= 0x2a700 && codepoint <= 0x2b73f) || // CJK Extension C
    (codepoint >= 0x2b740 && codepoint <= 0x2b81f) || // CJK Extension D
    (codepoint >= 0x2b820 && codepoint <= 0x2ceaf) || // CJK Extension E
    (codepoint >= 0x2ceb0 && codepoint <= 0x2ebef) || // CJK Extension F
    (codepoint >= 0x30000 && codepoint <= 0x3134f) // CJK Extension G
  );
};

const getCharType = (char: string): CharType => {
  const codepoint = char.codePointAt(0);
  if (codepoint === undefined) {
    return CharType.OTHER;
  }
  if (isKanji(codepoint)) {
    return CharType.KANJI;
  }
  if (char.length !== 1) {
    return CharType.OTHER;
  }
  switch (codepoint) {
    case 0x3093: // ん
      return CharType.HIRAGANA_HATSUON;
    case 0x30f3: // ン
      return CharType.KATAKANA_HATSUON;
    case 0x3063: // っ
      return CharType.HIRAGANA_SOKUON;
    case 0x30c3: // ッ
      return CharType.KATAKANA_SOKUON;
    case 0x309d: // ゝ
    case 0x3031: // 〱
      return CharType.HIRAGANA_ITERATION_MARK;
    case 0x309e: // ゞ
    case 0x3032: // 〲
      return CharType.HIRAGANA_VOICED_ITERATION_MARK;
    case 0x30fd: // ヽ
    case 0x3033: // 〳
      return CharType.KATAKANA_ITERATION_MARK;
    case 0x30fe: // ヾ
    case 0x3034: // 〴
      return CharType.KATAKANA_VOICED_ITERATION_MARK;
    case 0x3005: // 々
      return CharType.KANJI_ITERATION_MARK;
  }
  if (isHiragana(codepoint)) {
    return voicedChars.get(codepoint) ?? CharType.HIRAGANA;
  }
  if (isKatakana(codepoint)) {
    return voicedChars.get(codepoint) ?? CharType.KATAKANA;
  }
  return CharType.OTHER;
};

export default (_: Options): ((_: Iterable<Char>) => Iterable<Char>) =>
  function* (in_: Iterable<Char>) {
    let offset = 0;
    let prevChar: [Char, CharType] | undefined;

    for (const c of in_) {
      const currentChar: [Char, CharType] = [c, getCharType(c.c)];

      // Check for iteration marks
      if (prevChar !== undefined) {
        switch (currentChar[1]) {
          case CharType.HIRAGANA_ITERATION_MARK:
            switch (prevChar[1]) {
              case CharType.HIRAGANA:
                yield { c: prevChar[0].c, offset: offset, source: currentChar[0] };
                offset += prevChar[0].c.length;
                prevChar = currentChar;
                continue;
              case CharType.HIRAGANA_VOICED: {
                const cp = prevChar[0].c.codePointAt(0);
                const unvoiced = cp !== undefined ? unvoicingMap.get(cp) : undefined;
                if (unvoiced !== undefined) {
                  yield { c: unvoiced, offset: offset, source: currentChar[0] };
                  offset += unvoiced.length;
                  prevChar = currentChar;
                  continue;
                }
                break;
              }
            }
            break;
          case CharType.HIRAGANA_VOICED_ITERATION_MARK:
            switch (prevChar[1]) {
              case CharType.HIRAGANA: {
                const cp = prevChar[0].c.codePointAt(0);
                const voiced = cp !== undefined ? voicingMap.get(cp) : undefined;
                if (voiced !== undefined) {
                  yield { c: voiced, offset: offset, source: currentChar[0] };
                  offset += voiced.length;
                  prevChar = currentChar;
                  continue;
                }
                break;
              }
              case CharType.HIRAGANA_VOICED:
                yield { c: prevChar[0].c, offset: offset, source: currentChar[0] };
                offset += prevChar[0].c.length;
                prevChar = currentChar;
                continue;
            }
            break;
          case CharType.KATAKANA_ITERATION_MARK:
            switch (prevChar[1]) {
              case CharType.KATAKANA:
                yield { c: prevChar[0].c, offset: offset, source: currentChar[0] };
                offset += prevChar[0].c.length;
                prevChar = currentChar;
                continue;
              case CharType.KATAKANA_VOICED: {
                const cp = prevChar[0].c.codePointAt(0);
                const unvoiced = cp !== undefined ? unvoicingMap.get(cp) : undefined;
                if (unvoiced !== undefined) {
                  yield { c: unvoiced, offset: offset, source: currentChar[0] };
                  offset += unvoiced.length;
                  prevChar = currentChar;
                  continue;
                }
                break;
              }
            }
            break;
          case CharType.KATAKANA_VOICED_ITERATION_MARK:
            switch (prevChar[1]) {
              case CharType.KATAKANA: {
                const cp = prevChar[0].c.codePointAt(0);
                const voiced = cp !== undefined ? voicingMap.get(cp) : undefined;
                if (voiced !== undefined) {
                  yield { c: voiced, offset: offset, source: currentChar[0] };
                  offset += voiced.length;
                  prevChar = currentChar;
                  continue;
                }
                break;
              }
              case CharType.KATAKANA_VOICED:
                yield { c: prevChar[0].c, offset: offset, source: currentChar[0] };
                offset += prevChar[0].c.length;
                prevChar = currentChar;
                continue;
            }
            break;
          case CharType.KANJI_ITERATION_MARK:
            if (prevChar[1] === CharType.KANJI) {
              yield { c: prevChar[0].c, offset: offset, source: currentChar[0] };
              offset += prevChar[0].c.length;
              prevChar = currentChar;
              continue;
            }
            break;
        }
      }

      yield { c: currentChar[0].c, offset: offset, source: currentChar[0] };
      offset += currentChar[0].c.length;
      prevChar = currentChar;
    }
  };
