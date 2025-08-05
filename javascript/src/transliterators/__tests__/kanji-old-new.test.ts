import { expect, test } from "@jest/globals";
import { buildCharArray, fromChars } from "../../chars.js";
import { default as target } from "../kanji-old-new.js";

test.each([
  {
    expected: "\u6867\u{e0100}",
    input: "\u6a9c\u{e0100}",
  },
  {
    expected: "\u8fbb\u{e0100}",
    input: "\u8fbb\u{e0101}",
  },
] satisfies { expected: string; input: string; composeNonCombiningMarks?: boolean }[])(
  "kanjiOldNew %#",
  ({ expected, input }) => {
    expect(fromChars(target({})(buildCharArray(input)))).toEqual(expected);
  },
);
