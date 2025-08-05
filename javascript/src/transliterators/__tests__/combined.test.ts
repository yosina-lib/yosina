import { describe, expect, test } from "@jest/globals";
import { buildCharArray, fromChars } from "../../chars.js";
import { default as combined } from "../combined.js";

describe("CombinedTransliterator", () => {
  const transliterator = combined({});

  describe("control characters", () => {
    test("null symbol to NUL", () => {
      const result = fromChars(transliterator(buildCharArray("␀")));
      expect(result).toBe("NUL");
    });

    test("start of heading to SOH", () => {
      const result = fromChars(transliterator(buildCharArray("␁")));
      expect(result).toBe("SOH");
    });

    test("start of text to STX", () => {
      const result = fromChars(transliterator(buildCharArray("␂")));
      expect(result).toBe("STX");
    });

    test("backspace to BS", () => {
      const result = fromChars(transliterator(buildCharArray("␈")));
      expect(result).toBe("BS");
    });

    test("horizontal tab to HT", () => {
      const result = fromChars(transliterator(buildCharArray("␉")));
      expect(result).toBe("HT");
    });

    test("carriage return to CR", () => {
      const result = fromChars(transliterator(buildCharArray("␍")));
      expect(result).toBe("CR");
    });

    test("space symbol to SP", () => {
      const result = fromChars(transliterator(buildCharArray("␠")));
      expect(result).toBe("SP");
    });

    test("delete symbol to DEL", () => {
      const result = fromChars(transliterator(buildCharArray("␡")));
      expect(result).toBe("DEL");
    });
  });

  describe("parenthesized numbers", () => {
    test("(1) to (1)", () => {
      const result = fromChars(transliterator(buildCharArray("⑴")));
      expect(result).toBe("(1)");
    });

    test("(5) to (5)", () => {
      const result = fromChars(transliterator(buildCharArray("⑸")));
      expect(result).toBe("(5)");
    });

    test("(10) to (10)", () => {
      const result = fromChars(transliterator(buildCharArray("⑽")));
      expect(result).toBe("(10)");
    });

    test("(20) to (20)", () => {
      const result = fromChars(transliterator(buildCharArray("⒇")));
      expect(result).toBe("(20)");
    });
  });

  describe("period numbers", () => {
    test("1. to 1.", () => {
      const result = fromChars(transliterator(buildCharArray("⒈")));
      expect(result).toBe("1.");
    });

    test("10. to 10.", () => {
      const result = fromChars(transliterator(buildCharArray("⒑")));
      expect(result).toBe("10.");
    });

    test("20. to 20.", () => {
      const result = fromChars(transliterator(buildCharArray("⒛")));
      expect(result).toBe("20.");
    });
  });

  describe("parenthesized letters", () => {
    test("(a) to (a)", () => {
      const result = fromChars(transliterator(buildCharArray("⒜")));
      expect(result).toBe("(a)");
    });

    test("(z) to (z)", () => {
      const result = fromChars(transliterator(buildCharArray("⒵")));
      expect(result).toBe("(z)");
    });
  });

  describe("parenthesized kanji", () => {
    test("(一) to (一)", () => {
      const result = fromChars(transliterator(buildCharArray("㈠")));
      expect(result).toBe("(一)");
    });

    test("(月) to (月)", () => {
      const result = fromChars(transliterator(buildCharArray("㈪")));
      expect(result).toBe("(月)");
    });

    test("(株) to (株)", () => {
      const result = fromChars(transliterator(buildCharArray("㈱")));
      expect(result).toBe("(株)");
    });
  });

  describe("Japanese units", () => {
    test("アパート to アパート", () => {
      const result = fromChars(transliterator(buildCharArray("㌀")));
      expect(result).toBe("アパート");
    });

    test("キロ to キロ", () => {
      const result = fromChars(transliterator(buildCharArray("㌔")));
      expect(result).toBe("キロ");
    });

    test("メートル to メートル", () => {
      const result = fromChars(transliterator(buildCharArray("㍍")));
      expect(result).toBe("メートル");
    });
  });

  describe("scientific units", () => {
    test("hPa to hPa", () => {
      const result = fromChars(transliterator(buildCharArray("㍱")));
      expect(result).toBe("hPa");
    });

    test("kHz to kHz", () => {
      const result = fromChars(transliterator(buildCharArray("㎑")));
      expect(result).toBe("kHz");
    });

    test("kg to kg", () => {
      const result = fromChars(transliterator(buildCharArray("㎏")));
      expect(result).toBe("kg");
    });
  });

  describe("mixed content", () => {
    test("combined control and numbers", () => {
      const result = fromChars(transliterator(buildCharArray("␉⑴␠⒈")));
      expect(result).toBe("HT(1)SP1.");
    });

    test("combined with regular text", () => {
      const result = fromChars(transliterator(buildCharArray("Hello ⑴ World ␉")));
      expect(result).toBe("Hello (1) World HT");
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

  test("sequence of combined characters", () => {
    const input = "␀␁␂␃␄";
    const expected = "NULSOHSTXETXEOT";
    const result = fromChars(transliterator(buildCharArray(input)));
    expect(result).toBe(expected);
  });

  test("Japanese months", () => {
    const input = "㋀㋁㋂";
    const expected = "1月2月3月";
    const result = fromChars(transliterator(buildCharArray(input)));
    expect(result).toBe(expected);
  });

  test("Japanese units combinations", () => {
    const input = "㌀㌁㌂";
    const expected = "アパートアルファアンペア";
    const result = fromChars(transliterator(buildCharArray(input)));
    expect(result).toBe(expected);
  });

  test("scientific measurements", () => {
    const input = "\u3378\u3379\u337a";
    const expected = "dm2dm3IU";
    const result = fromChars(transliterator(buildCharArray(input)));
    expect(result).toBe(expected);
  });
});
