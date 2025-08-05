import type { Char } from "./types.js";

export const buildCharArray = (text: string): Char[] => {
  const retval: Char[] = [];
  let offset = 0;
  let pc: string | undefined;
  let pcp: number | undefined;
  for (const c of text) {
    const cp = c.codePointAt(0) as number;
    if (pc !== undefined && pcp !== undefined) {
      if ((cp >= 0xfe00 && cp <= 0xfe0f) || (cp >= 0xe0100 && cp <= 0xe01ef)) {
        const cc = pc + c;
        retval.push({ c: cc, offset, source: undefined });
        offset += cc.length;
        pc = pcp = undefined;
        continue;
      }
      retval.push({ c: pc, offset, source: undefined });
      offset += pc.length;
    }
    pc = c;
    pcp = cp;
  }
  if (pc !== undefined && pcp !== undefined) {
    retval.push({ c: pc, offset, source: undefined });
    offset += pc.length;
  }
  // add sentinel
  retval.push({ c: "", offset: offset, source: undefined });
  return retval;
};

export const fromChars = (chars: Iterable<Char>) => {
  let result = "";
  for (const c of chars) {
    result += c.c;
  }
  return result;
};
