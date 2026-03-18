import { describe, expect, test } from "@jest/globals";
import { buildCharArray, fromChars } from "../../chars.js";
import { default as factory } from "../historical-hirakatas.js";

describe("historical-hirakatas", () => {
  describe("simple hiragana (default)", () => {
    const transliterator = factory({});

    test("should convert ゐ to い and ゑ to え", () => {
      expect(fromChars(transliterator(buildCharArray("ゐゑ")))).toBe("いえ");
    });

    test("should preserve non-historical characters", () => {
      expect(fromChars(transliterator(buildCharArray("あいう")))).toBe("あいう");
    });

    test("should handle mixed input", () => {
      expect(fromChars(transliterator(buildCharArray("あゐいゑう")))).toBe("あいいえう");
    });
  });

  describe("decompose hiragana", () => {
    const transliterator = factory({
      hiraganas: "decompose",
      katakanas: "skip",
    });

    test("should decompose ゐ to うぃ and ゑ to うぇ", () => {
      expect(fromChars(transliterator(buildCharArray("ゐゑ")))).toBe("うぃうぇ");
    });
  });

  describe("skip hiragana", () => {
    const transliterator = factory({
      hiraganas: "skip",
      katakanas: "skip",
    });

    test("should leave historical hiragana unchanged", () => {
      expect(fromChars(transliterator(buildCharArray("ゐゑ")))).toBe("ゐゑ");
    });
  });

  describe("simple katakana (default)", () => {
    const transliterator = factory({});

    test("should convert ヰ to イ and ヱ to エ", () => {
      expect(fromChars(transliterator(buildCharArray("ヰヱ")))).toBe("イエ");
    });
  });

  describe("decompose katakana", () => {
    const transliterator = factory({
      hiraganas: "skip",
      katakanas: "decompose",
    });

    test("should decompose ヰ to ウィ and ヱ to ウェ", () => {
      expect(fromChars(transliterator(buildCharArray("ヰヱ")))).toBe("ウィウェ");
    });
  });

  describe("voiced katakana decompose", () => {
    const transliterator = factory({
      hiraganas: "skip",
      katakanas: "skip",
      voicedKatakanas: "decompose",
    });

    test("should decompose voiced historical katakana", () => {
      expect(fromChars(transliterator(buildCharArray("ヷヸヹヺ")))).toBe("ヴァヴィヴェヴォ");
    });
  });

  describe("voiced katakana skip (default)", () => {
    const transliterator = factory({
      hiraganas: "skip",
      katakanas: "skip",
    });

    test("should leave voiced historical katakana unchanged", () => {
      expect(fromChars(transliterator(buildCharArray("ヷヸヹヺ")))).toBe("ヷヸヹヺ");
    });
  });

  describe("all decompose", () => {
    const transliterator = factory({
      hiraganas: "decompose",
      katakanas: "decompose",
      voicedKatakanas: "decompose",
    });

    test("should decompose all historical kana", () => {
      expect(fromChars(transliterator(buildCharArray("ゐゑヰヱヷヸヹヺ")))).toBe("うぃうぇウィウェヴァヴィヴェヴォ");
    });
  });

  describe("all skip", () => {
    const transliterator = factory({
      hiraganas: "skip",
      katakanas: "skip",
      voicedKatakanas: "skip",
    });

    test("should leave all historical kana unchanged", () => {
      expect(fromChars(transliterator(buildCharArray("ゐゑヰヱヷヸヹヺ")))).toBe("ゐゑヰヱヷヸヹヺ");
    });
  });

  describe("decomposed voiced katakana input", () => {
    test("decomposed input with decompose mode should convert like composed", () => {
      const transliterator = factory({
        hiraganas: "skip",
        katakanas: "skip",
        voicedKatakanas: "decompose",
      });
      expect(fromChars(transliterator(buildCharArray("ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099")))).toBe(
        "ウ\u3099ァウ\u3099ィウ\u3099ェウ\u3099ォ",
      );
    });

    test("decomposed input with skip mode should pass through unchanged", () => {
      const transliterator = factory({
        hiraganas: "skip",
        katakanas: "skip",
        voicedKatakanas: "skip",
      });
      expect(fromChars(transliterator(buildCharArray("ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099")))).toBe(
        "ワ\u3099ヰ\u3099ヱ\u3099ヲ\u3099",
      );
    });

    test("decomposed voiced must not split base from combining mark", () => {
      const transliterator = factory({
        hiraganas: "skip",
        katakanas: "simple",
        voicedKatakanas: "skip",
      });
      // ヰ+゙ should be treated as ヸ (voiced), not as ヰ (katakana) + separate ゙
      expect(fromChars(transliterator(buildCharArray("ヰ\u3099")))).toBe("ヰ\u3099");
    });

    test("decomposed voiced with decompose mode", () => {
      const transliterator = factory({
        hiraganas: "skip",
        katakanas: "skip",
        voicedKatakanas: "decompose",
      });
      // ヰ+゙ = ヸ, should produce ウ+゙+ィ (decomposed)
      expect(fromChars(transliterator(buildCharArray("ヰ\u3099")))).toBe("ウ\u3099ィ");
    });
  });

  describe("empty input", () => {
    const transliterator = factory({});

    test("should handle empty input", () => {
      expect(fromChars(transliterator(buildCharArray("")))).toBe("");
    });
  });
});
