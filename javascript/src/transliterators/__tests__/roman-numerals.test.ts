import { describe, expect, test } from "@jest/globals";
import { buildCharArray, fromChars } from "../../chars.js";
import romanNumerals from "../roman-numerals.js";

describe("roman-numerals", () => {
  const transliterator = romanNumerals({});

  const uppercaseTestCases = [
    ["I", "Ⅰ", "Roman I"],
    ["II", "Ⅱ", "Roman II"],
    ["III", "Ⅲ", "Roman III"],
    ["IV", "Ⅳ", "Roman IV"],
    ["V", "Ⅴ", "Roman V"],
    ["VI", "Ⅵ", "Roman VI"],
    ["VII", "Ⅶ", "Roman VII"],
    ["VIII", "Ⅷ", "Roman VIII"],
    ["IX", "Ⅸ", "Roman IX"],
    ["X", "Ⅹ", "Roman X"],
    ["XI", "Ⅺ", "Roman XI"],
    ["XII", "Ⅻ", "Roman XII"],
    ["L", "Ⅼ", "Roman L"],
    ["C", "Ⅽ", "Roman C"],
    ["D", "Ⅾ", "Roman D"],
    ["M", "Ⅿ", "Roman M"],
  ];

  test.each(uppercaseTestCases)("transliterates uppercase %s to %s (%s)", (expected, input, _description) => {
    const result = fromChars(transliterator(buildCharArray(input)));
    expect(result).toBe(expected);
  });

  const lowercaseTestCases = [
    ["i", "ⅰ", "Roman i"],
    ["ii", "ⅱ", "Roman ii"],
    ["iii", "ⅲ", "Roman iii"],
    ["iv", "ⅳ", "Roman iv"],
    ["v", "ⅴ", "Roman v"],
    ["vi", "ⅵ", "Roman vi"],
    ["vii", "ⅶ", "Roman vii"],
    ["viii", "ⅷ", "Roman viii"],
    ["ix", "ⅸ", "Roman ix"],
    ["x", "ⅹ", "Roman x"],
    ["xi", "ⅺ", "Roman xi"],
    ["xii", "ⅻ", "Roman xii"],
    ["l", "ⅼ", "Roman l"],
    ["c", "ⅽ", "Roman c"],
    ["d", "ⅾ", "Roman d"],
    ["m", "ⅿ", "Roman m"],
  ];

  test.each(lowercaseTestCases)("transliterates lowercase %s to %s (%s)", (expected, input, _description) => {
    const result = fromChars(transliterator(buildCharArray(input)));
    expect(result).toBe(expected);
  });

  const mixedTextTestCases = [
    ["Year XII", "Year Ⅻ", "Year with Roman numeral"],
    ["Chapter iv", "Chapter ⅳ", "Chapter with lowercase Roman"],
    ["Section III.A", "Section Ⅲ.A", "Section with Roman and period"],
    ["I II III", "Ⅰ Ⅱ Ⅲ", "Multiple uppercase Romans"],
    ["i, ii, iii", "ⅰ, ⅱ, ⅲ", "Multiple lowercase Romans"],
  ];

  test.each(mixedTextTestCases)("handles mixed text %s to %s (%s)", (expected, input, _description) => {
    const result = fromChars(transliterator(buildCharArray(input)));
    expect(result).toBe(expected);
  });

  const edgeCaseTestCases = [
    ["", "", "Empty string"],
    ["ABC123", "ABC123", "No Roman numerals"],
    ["IIIIII", "ⅠⅡⅢ", "Consecutive Romans"],
  ];

  test.each(edgeCaseTestCases)("handles edge case %s to %s (%s)", (expected, input, _description) => {
    const result = fromChars(transliterator(buildCharArray(input)));
    expect(result).toBe(expected);
  });
});
