import { describe, expect, test } from "@jest/globals";
import { buildCharArray, fromChars } from "../../chars.js";
import { default as factory } from "../hira-kata.js";

describe("hira-kata", () => {
  describe("hira-to-kata mode", () => {
    const transliterator = factory({ mode: "hira-to-kata" });

    test("should convert hiragana to katakana", () => {
      const input = "あいうえお";
      const expected = "アイウエオ";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("should convert voiced hiragana to katakana", () => {
      const input = "がぎぐげご";
      const expected = "ガギグゲゴ";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("should convert semi-voiced hiragana to katakana", () => {
      const input = "ぱぴぷぺぽ";
      const expected = "パピプペポ";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("should convert small hiragana to katakana", () => {
      const input = "ぁぃぅぇぉっゃゅょ";
      const expected = "ァィゥェォッャュョ";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("should preserve non-hiragana characters", () => {
      const input = "あいうえお123ABCアイウエオ";
      const expected = "アイウエオ123ABCアイウエオ";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("should handle mixed text", () => {
      const input = "こんにちは、世界！";
      const expected = "コンニチハ、世界！";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });
  });

  describe("kata-to-hira mode", () => {
    const transliterator = factory({ mode: "kata-to-hira" });

    test("should convert katakana to hiragana", () => {
      const input = "アイウエオ";
      const expected = "あいうえお";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("should convert voiced katakana to hiragana", () => {
      const input = "ガギグゲゴ";
      const expected = "がぎぐげご";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("should convert semi-voiced katakana to hiragana", () => {
      const input = "パピプペポ";
      const expected = "ぱぴぷぺぽ";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("should convert small katakana to hiragana", () => {
      const input = "ァィゥェォッャュョ";
      const expected = "ぁぃぅぇぉっゃゅょ";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("should preserve non-katakana characters", () => {
      const input = "アイウエオ123ABCあいうえお";
      const expected = "あいうえお123ABCあいうえお";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("should handle mixed text", () => {
      const input = "コンニチハ、世界！";
      const expected = "こんにちは、世界！";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("should handle vu character", () => {
      const input = "ヴ";
      const expected = "ゔ";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("should preserve special katakana characters without hiragana equivalents", () => {
      const input = "ヷヸヹヺ";
      const expected = "ヷヸヹヺ"; // These remain unchanged as they have no hiragana equivalents
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });
  });
});
