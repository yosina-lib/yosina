import { expect, test } from "@jest/globals";
import { buildCharArray, fromChars } from "../../chars.js";
import { default as target } from "../ivs-svs-base.js";

test.each([
  {
    expected: "\u{9038}\u{E0100}\u{70BA}\u{E0100}",
    input: "\u{9038}\u{70BA}",
    mode: "ivs-or-svs",
  },
  {
    expected: "\u{9038}\u{70BA}",
    input: "\u{9038}\u{E0100}\u{70BA}\u{E0100}",
    mode: "base",
  },
  {
    expected: "\u{8fbb}\u{E0101}",
    input: "\u{8fbb}",
    mode: "ivs-or-svs",
  },
  {
    expected: "\u{8fbb}",
    input: "\u{8fbb}\u{E0101}",
    mode: "base",
  },
  {
    expected: "\u{8fbb}\u{E0100}",
    input: "\u{8fbb}\u{E0100}",
    mode: "base",
  },
  {
    expected: "\u{8fbb}",
    input: "\u{8fbb}\u{E0100}",
    mode: "base",
    dropSelectorsAltogether: true,
  },
  {
    expected: "\u{8fbb}",
    input: "\u{8fbb}\u{E0101}",
    mode: "base",
    dropSelectorsAltogether: true,
  },
] satisfies {
  expected: string;
  input: string;
  mode: "ivs-or-svs" | "base";
  charset?: string;
  preferSVS?: boolean;
  dropSelectorsAltogether?: boolean;
}[])("ivsSVSBase %#", ({ expected, input, ...options }) => {
  expect(
    Array.from(fromChars(target(options)(buildCharArray(input)))).map((c) => c.codePointAt(0)?.toString(16)),
  ).toEqual(Array.from(expected).map((c) => c.codePointAt(0)?.toString(16)));
});
