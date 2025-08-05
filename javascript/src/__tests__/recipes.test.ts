import { describe, expect, it } from "@jest/globals";
import { buildCharArray, fromChars } from "../chars.js";
import { makeChainedTransliterator } from "../intrinsics.js";
import { buildTransliteratorConfigsFromRecipe } from "../recipes.js";

// Test basic recipe functionality
describe("Basic Recipe", () => {
  it("empty recipe produces empty configs", () => {
    const configs = buildTransliteratorConfigsFromRecipe({});
    expect(configs).toEqual([]);
  });

  it("default values are correct", () => {
    // Recipe in TypeScript doesn't expose defaults, but we can verify behavior
    const configs = buildTransliteratorConfigsFromRecipe({});
    expect(configs).toEqual([]);
  });
});

// Test individual transliterator configurations
describe("Individual Transliterators", () => {
  it("kanji_old_new configuration with IVS/SVS", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      kanjiOldNew: true,
    });

    // Should contain kanji-old-new and IVS/SVS configurations
    const configNames = configs.map((c) => c[0]);
    expect(configNames).toContain("kanji-old-new");
    expect(configNames).toContain("ivs-svs-base");

    // Should have at least 3 configs: ivs-or-svs, kanji-old-new, base
    expect(configs.length).toBeGreaterThanOrEqual(3);
  });

  it("prolonged sound marks configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceSuspiciousHyphensToProlongedSoundMarks: true,
    });

    const config = configs.find((c) => c[0] === "prolonged-sound-marks");
    expect(config).toBeDefined();
    expect(config?.[1]).toEqual({ replaceProlongedMarksFollowingAlnums: true });
  });

  it("circled_or_squared configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceCircledOrSquaredCharacters: true,
    });

    const config = configs.find((c) => c[0] === "circled-or-squared");
    expect(config).toBeDefined();
    expect(config?.[1]).toEqual({ includeEmojis: true });
  });

  it("circled_or_squared exclude emojis configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceCircledOrSquaredCharacters: "exclude-emojis",
    });

    const config = configs.find((c) => c[0] === "circled-or-squared");
    expect(config).toBeDefined();
    expect(config?.[1]).toEqual({ includeEmojis: false });
  });

  it("combined configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceCombinedCharacters: true,
    });

    const configNames = configs.map((c) => c[0]);
    expect(configNames).toContain("combined");
  });

  it("ideographic annotations configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceIdeographicAnnotations: true,
    });

    const configNames = configs.map((c) => c[0]);
    expect(configNames).toContain("ideographic-annotations");
  });

  it("radicals configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceRadicals: true,
    });

    const configNames = configs.map((c) => c[0]);
    expect(configNames).toContain("radicals");
  });

  it("spaces configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceSpaces: true,
    });

    const configNames = configs.map((c) => c[0]);
    expect(configNames).toContain("spaces");
  });

  it("mathematical alphanumerics configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceMathematicalAlphanumerics: true,
    });

    const configNames = configs.map((c) => c[0]);
    expect(configNames).toContain("mathematical-alphanumerics");
  });

  it("hira kata composition configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      combineDecomposedHiraganasAndKatakanas: true,
    });

    const config = configs.find((c) => c[0] === "hira-kata-composition");
    expect(config).toBeDefined();
    expect(config?.[1]).toEqual({ composeNonCombiningMarks: true });
  });
});

// Test complex option configurations
describe("Complex Options", () => {
  it("hyphens default precedence", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceHyphens: true,
    });

    const config = configs.find((c) => c[0] === "hyphens");
    expect(config).toBeDefined();
    expect(config?.[1]).toEqual({ precedence: ["jisx0208_90_windows", "jisx0201"] });
  });

  it("hyphens custom precedence", () => {
    const customPrecedence: ("jisx0201" | "ascii")[] = ["jisx0201", "ascii"];
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceHyphens: customPrecedence,
    });

    const config = configs.find((c) => c[0] === "hyphens");
    expect(config).toBeDefined();
    expect(config?.[1]).toEqual({ precedence: customPrecedence });
  });

  it("to_fullwidth basic configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      toFullwidth: true,
    });

    const config = configs.find((c) => c[0] === "jisx0201-and-alike");
    expect(config).toBeDefined();
    expect(config?.[1]).toMatchObject({
      fullwidthToHalfwidth: false,
      u005cAsYenSign: false,
    });
  });

  it("to_fullwidth yen sign configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      toFullwidth: "u005c-as-yen-sign",
    });

    const config = configs.find((c) => c[0] === "jisx0201-and-alike");
    expect(config).toBeDefined();
    expect(config?.[1]).toMatchObject({
      fullwidthToHalfwidth: false,
      u005cAsYenSign: true,
    });
  });

  it("to_halfwidth basic configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      toHalfwidth: true,
    });

    const config = configs.find((c) => c[0] === "jisx0201-and-alike");
    expect(config).toBeDefined();
    expect(config?.[1]).toEqual({
      fullwidthToHalfwidth: true,
      convertGL: true,
      convertGR: false,
    });
  });

  it("to_halfwidth hankaku kana configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      toHalfwidth: "hankaku-kana",
    });

    const config = configs.find((c) => c[0] === "jisx0201-and-alike");
    expect(config).toBeDefined();
    expect(config?.[1]).toEqual({
      fullwidthToHalfwidth: true,
      convertGL: true,
      convertGR: true,
    });
  });

  it("remove_ivs_svs basic configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      removeIVSSVS: true,
    });

    // Should have two ivs-svs-base configs
    const ivsSvsConfigs = configs.filter((c) => c[0] === "ivs-svs-base");
    expect(ivsSvsConfigs.length).toBe(2);

    // Check modes
    const modes = ivsSvsConfigs.map((c) => (c[1] as { mode?: string }).mode);
    expect(modes).toContain("ivs-or-svs");
    expect(modes).toContain("base");

    // Check drop_selectors_altogether is false for basic mode
    const baseConfig = ivsSvsConfigs.find((c) => (c[1] as { mode?: string }).mode === "base");
    expect((baseConfig?.[1] as { dropSelectorsAltogether?: boolean }).dropSelectorsAltogether).toBe(false);
  });

  it("remove_ivs_svs drop all configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      removeIVSSVS: "drop-all-selectors",
    });

    // Find base mode config
    const baseConfig = configs.find((c) => c[0] === "ivs-svs-base" && (c[1] as { mode?: string }).mode === "base");
    expect(baseConfig).toBeDefined();
    expect((baseConfig?.[1] as { dropSelectorsAltogether?: boolean }).dropSelectorsAltogether).toBe(true);
  });

  it("charset configuration", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      kanjiOldNew: true,
      charset: "unijis_90",
    });

    // Find the ivs-svs-base config with mode "base" which should have charset
    const baseConfig = configs.find((c) => c[0] === "ivs-svs-base" && (c[1] as { mode?: string }).mode === "base");
    expect(baseConfig).toBeDefined();
    expect((baseConfig?.[1] as { charset?: string }).charset).toBe("unijis_90");
  });
});

// Test transliterator ordering
describe("Order Verification", () => {
  it("circled-or-squared and combined order", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceCircledOrSquaredCharacters: true,
      replaceCombinedCharacters: true,
    });

    const configNames = configs.map((c) => c[0]);

    // Both should be present
    expect(configNames).toContain("circled-or-squared");
    expect(configNames).toContain("combined");

    // In JavaScript's implementation, combined comes before circled-or-squared
    const circledPos = configNames.indexOf("circled-or-squared");
    const combinedPos = configNames.indexOf("combined");
    expect(combinedPos).toBeLessThan(circledPos);
  });

  it("comprehensive ordering", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      kanjiOldNew: true,
      replaceSuspiciousHyphensToProlongedSoundMarks: true,
      replaceSpaces: true,
      combineDecomposedHiraganasAndKatakanas: true,
      toHalfwidth: true,
    });

    const configNames = configs.map((c) => c[0]);

    // Verify some key orderings
    // hira-kata-composition should be early (head insertion)
    expect(configNames).toContain("hira-kata-composition");

    // jisx0201-and-alike should be at the end (tail insertion)
    expect(configNames[configNames.length - 1]).toBe("jisx0201-and-alike");

    // All should be present
    expect(configNames).toContain("spaces");
    expect(configNames).toContain("prolonged-sound-marks");
    expect(configNames).toContain("kanji-old-new");
  });
});

// Test mutually exclusive options
describe("Mutual Exclusion", () => {
  it("fullwidth halfwidth mutual exclusion", () => {
    expect(() => {
      buildTransliteratorConfigsFromRecipe({
        toFullwidth: true,
        toHalfwidth: true,
      });
    }).toThrow("mutually exclusive");
  });
});

// Test comprehensive recipe configurations
describe("Comprehensive Configuration", () => {
  it("all transliterators enabled", () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      combineDecomposedHiraganasAndKatakanas: true,
      kanjiOldNew: true,
      removeIVSSVS: "drop-all-selectors",
      replaceHyphens: true,
      replaceIdeographicAnnotations: true,
      replaceSuspiciousHyphensToProlongedSoundMarks: true,
      replaceRadicals: true,
      replaceSpaces: true,
      replaceCircledOrSquaredCharacters: true,
      replaceCombinedCharacters: true,
      replaceMathematicalAlphanumerics: true,
      toHalfwidth: "hankaku-kana",
      charset: "unijis_90",
    });

    const configNames = configs.map((c) => c[0]);

    // Verify all expected transliterators are present
    const expectedTransliterators = [
      "ivs-svs-base", // appears twice
      "kanji-old-new",
      "prolonged-sound-marks",
      "circled-or-squared",
      "combined",
      "ideographic-annotations",
      "radicals",
      "spaces",
      "hyphens",
      "mathematical-alphanumerics",
      "hira-kata-composition",
      "jisx0201-and-alike",
    ];

    for (const expected of expectedTransliterators) {
      expect(configNames).toContain(expected);
    }

    // Verify specific configurations
    const hyphensConfig = configs.find((c) => c[0] === "hyphens");
    expect(hyphensConfig?.[1]).toEqual({ precedence: ["jisx0208_90_windows", "jisx0201"] });

    const jisxConfig = configs.find((c) => c[0] === "jisx0201-and-alike");
    expect((jisxConfig?.[1] as { convertGR?: boolean }).convertGR).toBe(true);

    // Count ivs-svs-base occurrences
    const ivsSvsCount = configs.filter((c) => c[0] === "ivs-svs-base").length;
    expect(ivsSvsCount).toBe(2);
  });
});

// Test functional integration with actual transliteration
describe("Functional Integration", () => {
  it("basic transliteration", async () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceCircledOrSquaredCharacters: true,
      replaceCombinedCharacters: true,
      replaceSpaces: true,
      replaceMathematicalAlphanumerics: true,
    });
    const transliterator = await makeChainedTransliterator(configs);

    // Test mixed content
    const testCases: [string, string][] = [
      ["①", "(1)"], // Circled number
      ["⑴", "(1)"], // Parenthesized number (combined)
      ["𝐇𝐞𝐥𝐥𝐨", "Hello"], // Mathematical alphanumerics
      ["　", " "], // Full-width space
    ];

    for (const [input, expected] of testCases) {
      const result = fromChars(transliterator(buildCharArray(input)));
      expect(result).toBe(expected);
    }
  });

  it("exclude emojis functional", async () => {
    const configs = buildTransliteratorConfigsFromRecipe({
      replaceCircledOrSquaredCharacters: "exclude-emojis",
    });
    const transliterator = await makeChainedTransliterator(configs);

    // Regular circled characters should still work
    expect(fromChars(transliterator(buildCharArray("①")))).toBe("(1)");
    expect(fromChars(transliterator(buildCharArray("Ⓐ")))).toBe("(A)");

    // Non-emoji squared letters should still be processed
    expect(fromChars(transliterator(buildCharArray("🅰")))).toBe("[A]");

    // Emoji characters should not be processed
    expect(fromChars(transliterator(buildCharArray("🆘")))).toBe("🆘");
  });
});
