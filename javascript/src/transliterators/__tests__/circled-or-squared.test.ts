import { describe, expect, test } from "@jest/globals";
import { buildCharArray, fromChars } from "../../chars.js";
import { default as circledOrSquared } from "../circled-or-squared.js";

describe("CircledOrSquaredTransliterator", () => {
  describe("default options", () => {
    const transliterator = circledOrSquared({});

    describe("circled numbers", () => {
      test("① to (1)", () => {
        const result = fromChars(transliterator(buildCharArray("①")));
        expect(result).toBe("(1)");
      });

      test("② to (2)", () => {
        const result = fromChars(transliterator(buildCharArray("②")));
        expect(result).toBe("(2)");
      });

      test("⑳ to (20)", () => {
        const result = fromChars(transliterator(buildCharArray("⑳")));
        expect(result).toBe("(20)");
      });

      test("⓪ to (0)", () => {
        const result = fromChars(transliterator(buildCharArray("⓪")));
        expect(result).toBe("(0)");
      });
    });

    describe("circled uppercase letters", () => {
      test("Ⓐ to (A)", () => {
        const result = fromChars(transliterator(buildCharArray("Ⓐ")));
        expect(result).toBe("(A)");
      });

      test("Ⓩ to (Z)", () => {
        const result = fromChars(transliterator(buildCharArray("Ⓩ")));
        expect(result).toBe("(Z)");
      });
    });

    describe("circled lowercase letters", () => {
      test("ⓐ to (a)", () => {
        const result = fromChars(transliterator(buildCharArray("ⓐ")));
        expect(result).toBe("(a)");
      });

      test("ⓩ to (z)", () => {
        const result = fromChars(transliterator(buildCharArray("ⓩ")));
        expect(result).toBe("(z)");
      });
    });

    describe("circled kanji", () => {
      test("㊀ to (一)", () => {
        const result = fromChars(transliterator(buildCharArray("㊀")));
        expect(result).toBe("(一)");
      });

      test("㊊ to (月)", () => {
        const result = fromChars(transliterator(buildCharArray("㊊")));
        expect(result).toBe("(月)");
      });

      test("㊰ to (夜)", () => {
        const result = fromChars(transliterator(buildCharArray("㊰")));
        expect(result).toBe("(夜)");
      });
    });

    describe("circled katakana", () => {
      test("㋐ to (ア)", () => {
        const result = fromChars(transliterator(buildCharArray("㋐")));
        expect(result).toBe("(ア)");
      });

      test("㋾ to (ヲ)", () => {
        const result = fromChars(transliterator(buildCharArray("㋾")));
        expect(result).toBe("(ヲ)");
      });
    });

    describe("squared letters", () => {
      test("🅰 to [A]", () => {
        const result = fromChars(transliterator(buildCharArray("🅰")));
        expect(result).toBe("[A]");
      });

      test("🆉 to [Z]", () => {
        const result = fromChars(transliterator(buildCharArray("🆉")));
        expect(result).toBe("[Z]");
      });
    });

    describe("regional indicator symbols", () => {
      test("🇦 to [A]", () => {
        const result = fromChars(transliterator(buildCharArray("🇦")));
        expect(result).toBe("[A]");
      });

      test("🇿 to [Z]", () => {
        const result = fromChars(transliterator(buildCharArray("🇿")));
        expect(result).toBe("[Z]");
      });
    });

    describe("emoji exclusion (default)", () => {
      test("🅰 (emoji) not processed when includeEmojis is false", () => {
        const result = fromChars(transliterator(buildCharArray("🆂🅾🆂")));
        expect(result).toBe("[S][O][S]");
      });
    });

    test("empty string", () => {
      const result = fromChars(transliterator(buildCharArray("")));
      expect(result).toBe("");
    });

    test("unmapped characters", () => {
      const input = "hello world 123 abc こんにちは";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(input);
    });

    test("mixed content", () => {
      const input = "Hello ① World Ⓐ Test";
      const expected = "Hello (1) World (A) Test";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });
  });

  describe("custom templates", () => {
    const transliterator = circledOrSquared({
      templates: {
        circle: "〔?〕",
        square: "【?】",
      },
    });

    test("custom circle template", () => {
      const result = fromChars(transliterator(buildCharArray("①")));
      expect(result).toBe("〔1〕");
    });

    test("custom square template", () => {
      const result = fromChars(transliterator(buildCharArray("🅰")));
      expect(result).toBe("【A】");
    });

    test("custom templates with kanji", () => {
      const result = fromChars(transliterator(buildCharArray("㊀")));
      expect(result).toBe("〔一〕");
    });
  });

  describe("includeEmojis option", () => {
    describe("includeEmojis: true", () => {
      const transliterator = circledOrSquared({
        includeEmojis: true,
      });

      test("emoji characters are processed", () => {
        const result = fromChars(transliterator(buildCharArray("🆂🅾🆂")));
        expect(result).toBe("[S][O][S]");
      });

      test("non-emoji characters are still processed", () => {
        const result = fromChars(transliterator(buildCharArray("①Ⓐ")));
        expect(result).toBe("(1)(A)");
      });
    });

    describe("includeEmojis: false (default)", () => {
      const transliterator = circledOrSquared({
        includeEmojis: false,
      });

      test("non-emoji characters are processed", () => {
        const result = fromChars(transliterator(buildCharArray("①Ⓐ")));
        expect(result).toBe("(1)(A)");
      });
    });
  });

  describe("complex scenarios", () => {
    const transliterator = circledOrSquared({});

    test("sequence of circled numbers", () => {
      const input = "①②③④⑤";
      const expected = "(1)(2)(3)(4)(5)";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("sequence of circled letters", () => {
      const input = "ⒶⒷⒸ";
      const expected = "(A)(B)(C)";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("mixed circles and squares", () => {
      const input = "①🅰②🅱";
      const expected = "(1)[A](2)[B]";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("circled kanji sequence", () => {
      const input = "㊀㊁㊂㊃㊄";
      const expected = "(一)(二)(三)(四)(五)";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("Japanese text with circled elements", () => {
      const input = "項目①は重要で、項目②は補足です。";
      const expected = "項目(1)は重要で、項目(2)は補足です。";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("numbered list with circled numbers", () => {
      const input = "①準備\n②実行\n③確認";
      const expected = "(1)準備\n(2)実行\n(3)確認";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });
  });

  describe("edge cases", () => {
    const transliterator = circledOrSquared({});

    test("large circled numbers", () => {
      const input = "㊱㊲㊳";
      const expected = "(36)(37)(38)";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("circled numbers up to 50", () => {
      const input = "㊿";
      const expected = "(50)";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });

    test("special circled characters", () => {
      const input = "🄴🅂";
      const expected = "[E][S]";
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    });
  });
});
