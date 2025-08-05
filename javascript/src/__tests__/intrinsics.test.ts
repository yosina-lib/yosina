import { describe, expect, it } from "@jest/globals";
import { buildCharArray, fromChars } from "../chars.js";
import { makeChainedTransliterator } from "../intrinsics.js";

describe("makeChainedTransliterator", () => {
  it("can yield a new Transliterator from the chain of the specified transliterators", async () => {
    const tl = await makeChainedTransliterator([
      "mathematical-alphanumerics",
      "hyphens",
      ["prolonged-sound-marks", { replaceProlongedMarksFollowingAlnums: true }],
    ]);
    expect(
      fromChars(
        tl(
          buildCharArray(
            "\uD835\uDD83１\u002D\u002D\u002D１\u002D\u30FC\uD835\uDFD9勇気爆発ﾊﾞ\u2015ﾝプレイバ\u2015ン１\u30FC\u30FC",
          ),
        ),
      ),
    ).toBe("X１\uff0d\uff0d\uff0d１\uff0d\uff0d1勇気爆発ﾊﾞ\uFF70ﾝプレイバ\u30FCン１\uff0d\uff0d");
  });
});
