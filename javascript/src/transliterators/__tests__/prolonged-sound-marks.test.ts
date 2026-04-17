import { expect, test } from "@jest/globals";
import { buildCharArray, fromChars } from "../../chars.js";
import { default as target } from "../prolonged-sound-marks.js";

test.each([
  {
    name: "fullwidth hyphen-minus to prolonged sound mark",
    input: "イ\uff0dハト\uff0dヴォ",
    expected: "イ\u30fcハト\u30fcヴォ",
  },
  {
    name: "fullwidth hyphen-minus at end of word",
    input: "カトラリ\uff0d",
    expected: "カトラリ\u30fc",
  },
  {
    name: "ASCII hyphen-minus to prolonged sound mark",
    input: "イ\u002dハト\u002dヴォ",
    expected: "イ\u30fcハト\u30fcヴォ",
  },
  {
    name: "ASCII hyphen-minus at end of word",
    input: "カトラリ\u002d",
    expected: "カトラリ\u30fc",
  },
  {
    name: "don't replace between prolonged sound marks",
    input: "1\u30fc\uff0d2\u30fc3",
    expected: "1\u30fc\uff0d2\u30fc3",
  },
  {
    name: "replace prolonged marks between alphanumerics",
    input: "1\u30fc\uff0d2\u30fc3",
    expected: "1\u002d\u002d2\u002d3",
    replaceProlongedMarksFollowingAlnums: true,
  },
  {
    name: "replace prolonged marks between fullwidth alphanumerics",
    input: "\uff11\u30fc\uff0d\uff12\u30fc\uff13",
    expected: "\uff11\uff0d\uff0d\uff12\uff0d\uff13",
    replaceProlongedMarksFollowingAlnums: true,
  },
  {
    name: "don't prolong sokuon by default",
    input: "ウッ\uff0dウン\uff0d",
    expected: "ウッ\uff0dウン\uff0d",
  },
  {
    name: "allow prolonged sokuon",
    input: "ウッ\uff0dウン\uff0d",
    expected: "ウッ\u30fcウン\uff0d",
    allowProlongedSokuon: true,
  },
  {
    name: "allow prolonged hatsuon",
    input: "ウッ\uff0dウン\uff0d",
    expected: "ウッ\uff0dウン\u30fc",
    allowProlongedHatsuon: true,
  },
  {
    name: "allow both prolonged sokuon and hatsuon",
    input: "ウッ\uff0dウン\uff0d",
    expected: "ウッ\u30fcウン\u30fc",
    allowProlongedSokuon: true,
    allowProlongedHatsuon: true,
  },
  {
    name: "empty string",
    input: "",
    expected: "",
  },
  {
    name: "string with no hyphens",
    input: "こんにちは世界",
    expected: "こんにちは世界",
  },
  {
    name: "mixed hiragana and katakana with hyphens",
    input: "あいう\u002dかきく\uff0d",
    expected: "あいう\u30fcかきく\u30fc",
  },
  {
    name: "halfwidth katakana with hyphen",
    input: "ｱｲｳ\u002d",
    expected: "ｱｲｳ\uff70",
  },
  {
    name: "halfwidth katakana with fullwidth hyphen",
    input: "ｱｲｳ\uff0d",
    expected: "ｱｲｳ\uff70",
  },
  {
    name: "hyphen after non-Japanese character",
    input: "ABC\u002d123\uff0d",
    expected: "ABC\u002d123\uff0d",
  },
  {
    name: "multiple hyphens in sequence",
    input: "ア\u002d\u002d\u002dイ",
    expected: "ア\u30fc\u30fc\u30fcイ",
  },
  {
    name: "various hyphen types",
    input: "ア\u002dイ\u2010ウ\u2014エ\u2015オ\u2212カ\uff0d",
    expected: "ア\u30fcイ\u30fcウ\u30fcエ\u30fcオ\u30fcカ\u30fc",
  },
  {
    name: "prolonged sound mark remains unchanged (1)",
    input: "ア\u30fcＡ\uff70Ｂ",
    expected: "ア\u30fcＡ\uff70Ｂ",
  },
  {
    name: "prolonged sound mark remains unchanged (2)",
    input: "ア\u30fcン\uff70ウ",
    expected: "ア\u30fcン\uff70ウ",
  },
  {
    name: "mixed alphanumeric and Japanese with replace option",
    input: "A\u30fcB\uff0dアイウ\u002d123\u30fc",
    expected: "A\u002dB\u002dアイウ\u30fc123\u002d",
    replaceProlongedMarksFollowingAlnums: true,
  },
  {
    name: "hiragana sokuon with hyphen",
    input: "あっ\u002d",
    expected: "あっ\u002d",
  },
  {
    name: "hiragana sokuon with hyphen and allow prolonged sokuon",
    input: "あっ\u002d",
    expected: "あっ\u30fc",
    allowProlongedSokuon: true,
  },
  {
    name: "hiragana hatsuon with hyphen",
    input: "あん\u002d",
    expected: "あん\u002d",
  },
  {
    name: "hiragana hatsuon with hyphen and allow prolonged hatsuon",
    input: "あん\u002d",
    expected: "あん\u30fc",
    allowProlongedHatsuon: true,
  },
  {
    name: "halfwidth katakana sokuon with hyphen",
    input: "ｳｯ\u002d",
    expected: "ｳｯ\u002d",
  },
  {
    name: "halfwidth katakana sokuon with hyphen and allow prolonged sokuon",
    input: "ｳｯ\u002d",
    expected: "ｳｯ\uff70",
    allowProlongedSokuon: true,
  },
  {
    name: "halfwidth katakana hatsuon with hyphen",
    input: "ｳﾝ\u002d",
    expected: "ｳﾝ\u002d",
  },
  {
    name: "halfwidth katakana hatsuon with hyphen and allow prolonged hatsuon",
    input: "ｳﾝ\u002d",
    expected: "ｳﾝ\uff70",
    allowProlongedHatsuon: true,
  },
  {
    name: "hyphen at start of string",
    input: "\u002dアイウ",
    expected: "\u002dアイウ",
  },
  {
    name: "only hyphens",
    input: "\u002d\uff0d\u2010\u2014\u2015\u2212",
    expected: "\u002d\uff0d\u2010\u2014\u2015\u2212",
  },
  {
    name: "newline and tab characters",
    input: "ア\n\u002d\tイ\uff0d",
    expected: "ア\n\u002d\tイ\u30fc",
  },
  {
    name: "emoji with hyphens",
    input: "😀\u002d😊\uff0d",
    expected: "😀\u002d😊\uff0d",
  },
  {
    name: "unicode surrogates",
    input: "\u{1f600}ア\u002d\u{1f601}イ\uff0d",
    expected: "\u{1f600}ア\u30fc\u{1f601}イ\u30fc",
  },
  {
    name: "hyphen between different character types",
    input: "あ\u002dア\u002dA\u002d1\u002dａ\u002d１",
    expected: "あ\u30fcア\u30fcA\u002d1\u002dａ\u002d１",
  },
  {
    name: "hyphen between different character types with replace option",
    input: "A\u002d1\u30fcａ\uff70１",
    expected: "A\u002d1\u002dａ\uff0d１",
    replaceProlongedMarksFollowingAlnums: true,
  },
  {
    name: "skip already transliterated chars option",
    input: "ア\u002dイ\uff0d",
    expected: "ア\u30fcイ\u30fc",
    skipAlreadyTransliteratedChars: true,
  },
  {
    name: "hiragana vowel-ended characters",
    input: "あ\u002dか\u002dさ\u002dた\u002dな\u002dは\u002dま\u002dや\u002dら\u002dわ\u002d",
    expected: "あ\u30fcか\u30fcさ\u30fcた\u30fcな\u30fcは\u30fcま\u30fcや\u30fcら\u30fcわ\u30fc",
  },
  {
    name: "katakana vowel-ended characters",
    input: "ア\u002dカ\u002dサ\u002dタ\u002dナ\u002dハ\u002dマ\u002dヤ\u002dラ\u002dワ\u002d",
    expected: "ア\u30fcカ\u30fcサ\u30fcタ\u30fcナ\u30fcハ\u30fcマ\u30fcヤ\u30fcラ\u30fcワ\u30fc",
  },
  {
    name: "halfwidth katakana vowel-ended characters",
    input: "ｱ\u002dｶ\u002dｻ\u002dﾀ\u002dﾅ\u002dﾊ\u002dﾏ\u002dﾔ\u002dﾗ\u002dﾜ\u002d",
    expected: "ｱ\uff70ｶ\uff70ｻ\uff70ﾀ\uff70ﾅ\uff70ﾊ\uff70ﾏ\uff70ﾔ\uff70ﾗ\uff70ﾜ\uff70",
  },
  {
    name: "digits with hyphens",
    input: "0\u002d1\u002d2\u002d3\u002d4\u002d5\u002d6\u002d7\u002d8\u002d9\u002d",
    expected: "0\u002d1\u002d2\u002d3\u002d4\u002d5\u002d6\u002d7\u002d8\u002d9\u002d",
  },
  {
    name: "fullwidth digits with hyphens",
    input: "０\u002d１\u002d２\u002d３\u002d４\u002d５\u002d６\u002d７\u002d８\u002d９\u002d",
    expected: "０\u002d１\u002d２\u002d３\u002d４\u002d５\u002d６\u002d７\u002d８\u002d９\u002d",
  },
  {
    name: "fullwidth digits with hyphens with options",
    input: "０\u002d１\u002d２\u002d３\u002d４\u002d５\u002d６\u002d７\u002d８\u002d９\u002d",
    expected: "０\uff0d１\uff0d２\uff0d３\uff0d４\uff0d５\uff0d６\uff0d７\uff0d８\uff0d９\uff0d",
    replaceProlongedMarksFollowingAlnums: true,
  },
  {
    name: "alphabet with hyphens",
    input: "A\u002dB\u002dC\u002da\u002db\u002dc\u002d",
    expected: "A\u002dB\u002dC\u002da\u002db\u002dc\u002d",
  },
  {
    name: "alphabet with hyphens with options",
    input: "A\u002dB\u002dC\u002da\u002db\u002dc\u002d",
    expected: "A\u002dB\u002dC\u002da\u002db\u002dc\u002d",
    replaceProlongedMarksFollowingAlnums: true,
  },
  {
    name: "fullwidth alphabet with hyphens",
    input: "Ａ\u002dＢ\u002dＣ\u002dａ\u002dｂ\u002dｃ\u002d",
    expected: "Ａ\u002dＢ\u002dＣ\u002dａ\u002dｂ\u002dｃ\u002d",
  },
  {
    name: "fullwidth alphabet with hyphens with options",
    input: "Ａ\u002dＢ\u002dＣ\u002dａ\u002dｂ\u002dｃ\u002d",
    expected: "Ａ\uff0dＢ\uff0dＣ\uff0dａ\uff0dｂ\uff0dｃ\uff0d",
    replaceProlongedMarksFollowingAlnums: true,
  },
  {
    name: "PSM between non-kana OTHER chars",
    input: "漢\u30fc字",
    expected: "漢\uff0d字",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "PSM between halfwidth alnums with non-kana option",
    input: "1\u30fc2",
    expected: "1\u002d2",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "PSM between fullwidth alnums with non-kana option",
    input: "１\u30fc２",
    expected: "１\uff0d２",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "PSM between mixed width with non-kana option",
    input: "1\u30fc２",
    expected: "1\u002d２",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "PSM after kana not replaced with non-kana option",
    input: "カ\u30fc漢",
    expected: "カ\u30fc漢",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "PSM before kana not replaced with non-kana option",
    input: "漢\u30fcカ",
    expected: "漢\u30fcカ",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "multiple consecutive hyphens between non-kana",
    input: "漢\u002d\u002d字",
    expected: "漢\uff0d\uff0d字",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "multiple consecutive PSMs between non-kana",
    input: "漢\u30fc\u30fc\u30fc字",
    expected: "漢\uff0d\uff0d\uff0d字",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "multiple consecutive PSMs between non-kana followed by kana",
    input: "漢\u30fc\u30fc\u30fcカ",
    expected: "漢\u30fc\u30fc\u30fcカ",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "trailing consecutive PSMs after fullwidth non-kana",
    input: "漢\u30fc\u30fc\u30fc",
    expected: "漢\uff0d\uff0d\uff0d",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "trailing consecutive PSMs after halfwidth non-kana",
    input: "1\u30fc\u30fc\u30fc",
    expected: "1\u002d\u002d\u002d",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "PSM between emoji",
    input: "😀\u30fc😊",
    expected: "😀\uff0d😊",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "trailing PSM after non-kana",
    input: "漢\u30fc",
    expected: "漢\uff0d",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "non-kana option only: PSM after alnum before kana not replaced",
    input: "A\u30fcカ",
    expected: "A\u30fcカ",
    replaceProlongedMarksBetweenNonKanas: true,
  },
  {
    name: "both options: PSM after alnum before kana replaced by alnum option",
    input: "A\u30fcカ",
    expected: "A\u002dカ",
    replaceProlongedMarksFollowingAlnums: true,
    replaceProlongedMarksBetweenNonKanas: true,
  },
] satisfies {
  name: string;
  expected: string;
  input: string;
  allowProlongedHatsuon?: boolean;
  allowProlongedSokuon?: boolean;
  replaceProlongedMarksFollowingAlnums?: boolean;
  replaceProlongedMarksBetweenNonKanas?: boolean;
  skipAlreadyTransliteratedChars?: boolean;
}[])("prolongedSoundMarks: %s", ({ name, expected, input, ...options }) => {
  expect(fromChars(target(options)(buildCharArray(input)))).toBe(expected);
});
