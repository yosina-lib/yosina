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
  // Hiragana iteration mark tests
  {
    expected: "\u{309E}", // ゞ
    input: "\u{309D}\u{3099}", // ゝ + combining voiced mark
  },
  // Katakana iteration mark tests
  {
    expected: "\u{30FE}", // ヾ
    input: "\u{30FD}\u{3099}", // ヽ + combining voiced mark
  },
  // Special katakana with dakuten
  {
    expected: "\u{30F7}", // ヷ
    input: "\u{30EF}\u{3099}", // ワ + combining voiced mark
  },
  {
    expected: "\u{30F8}", // ヸ
    input: "\u{30F0}\u{3099}", // ヰ + combining voiced mark
  },
  {
    expected: "\u{30F9}", // ヹ
    input: "\u{30F1}\u{3099}", // ヱ + combining voiced mark
  },
  {
    expected: "\u{30FA}", // ヺ
    input: "\u{30F2}\u{3099}", // ヲ + combining voiced mark
  },
  // Iteration marks with non-combining marks
  {
    expected: "\u{309E}", // ゞ
    input: "\u{309D}\u{309B}", // ゝ + non-combining voiced mark
    composeNonCombiningMarks: true,
  },
  {
    expected: "\u{30FE}", // ヾ
    input: "\u{30FD}\u{309B}", // ヽ + non-combining voiced mark
    composeNonCombiningMarks: true,
  },
  // Mixed sequences with iteration marks
  {
    expected: "テスト\u{309E}カタカナ\u{30FE}",
    input: "テスト\u{309D}\u{3099}カタカナ\u{30FD}\u{3099}",
  },
] satisfies { expected: string; input: string; composeNonCombiningMarks?: boolean }[])(
  "hiraKataComposition $#",
  ({ expected, input, ...options }) => {
    expect(fromChars(target(options)(buildCharArray(input)))).toEqual(expected);
  },
);
