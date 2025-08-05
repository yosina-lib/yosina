import { expect, test } from "@jest/globals";
import { buildCharArray, fromChars } from "../../chars.js";
import { default as target } from "../hira-kata-composition.js";

test.each([
  {
    expected: "\u{30AC}\u{30AC}\u{30AD}\u{30AE}\u{30AF}",
    input: "\u{30AB}\u{3099}\u{30AC}\u{30AD}\u{30AD}\u{3099}\u{30AF}",
  },
  {
    expected: "\u{30CF}\u{30D0}\u{30D1}\u{30D2}\u{30D5}\u{30D8}\u{30DB}",
    input: "\u{30CF}\u{30CF}\u{3099}\u{30CF}\u{309A}\u{30D2}\u{30D5}\u{30D8}\u{30DB}",
  },
  {
    expected: "\u{304C}\u{304C}\u{304D}\u{304E}\u{304F}",
    input: "\u{304B}\u{3099}\u{304C}\u{304D}\u{304D}\u{3099}\u{304F}",
  },
  {
    expected: "\u{306F}\u{3070}\u{3071}\u{3072}\u{3075}\u{3078}\u{307B}",
    input: "\u{306F}\u{306F}\u{3099}\u{306F}\u{309A}\u{3072}\u{3075}\u{3078}\u{307B}",
  },
  {
    expected: "\u{30CF}\u{30D0}\u{30D1}\u{30D2}\u{30D5}\u{30D8}\u{30DB}",
    input: "\u{30CF}\u{30CF}\u{309B}\u{30CF}\u{309C}\u{30D2}\u{30D5}\u{30D8}\u{30DB}",
    composeNonCombiningMarks: true,
  },
] satisfies { expected: string; input: string; composeNonCombiningMarks?: boolean }[])(
  "hiraKataComposition $#",
  ({ expected, input, ...options }) => {
    expect(fromChars(target(options)(buildCharArray(input)))).toEqual(expected);
  },
);
