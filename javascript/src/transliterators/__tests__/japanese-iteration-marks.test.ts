import { expect, test } from "@jest/globals";
import { buildCharArray, fromChars } from "../../chars.js";
import { default as target } from "../japanese-iteration-marks.js";

test.each([
  // Hiragana repetition mark ゝ - valid cases
  {
    expected: "かか",
    input: "かゝ",
  },
  {
    expected: "きき",
    input: "きゝ",
  },
  {
    expected: "すす",
    input: "すゝ",
  },
  {
    expected: "たた",
    input: "たゝ",
  },
  {
    expected: "なな",
    input: "なゝ",
  },
  {
    expected: "はは",
    input: "はゝ",
  },
  {
    expected: "まま",
    input: "まゝ",
  },
  {
    expected: "やや",
    input: "やゝ",
  },
  {
    expected: "らら",
    input: "らゝ",
  },
  {
    expected: "わわ",
    input: "わゝ",
  },
  {
    expected: "がか", // voiced character
    input: "がゝ",
  },

  // Hiragana repetition mark ゝ - invalid cases (should remain unchanged)
  {
    expected: "んゝ", // hatsuon cannot be repeated
    input: "んゝ",
  },
  {
    expected: "っゝ", // sokuon cannot be repeated
    input: "っゝ",
  },
  {
    expected: "ぱゝ", // semi-voiced character cannot be repeated
    input: "ぱゝ",
  },

  // Hiragana voiced repetition mark ゞ - valid cases
  {
    expected: "かが",
    input: "かゞ",
  },
  {
    expected: "がが",
    input: "がゞ",
  },
  {
    expected: "きぎ",
    input: "きゞ",
  },
  {
    expected: "くぐ",
    input: "くゞ",
  },
  {
    expected: "さざ",
    input: "さゞ",
  },
  {
    expected: "しじ",
    input: "しゞ",
  },
  {
    expected: "ただ",
    input: "たゞ",
  },
  {
    expected: "はば",
    input: "はゞ",
  },

  // Hiragana voiced repetition mark ゞ - invalid cases
  {
    expected: "あゞ", // 'あ' cannot be voiced
    input: "あゞ",
  },
  {
    expected: "んゞ", // hatsuon cannot be repeated
    input: "んゞ",
  },
  {
    expected: "っゞ", // sokuon cannot be repeated
    input: "っゞ",
  },

  // Katakana repetition mark ヽ - valid cases
  {
    expected: "カカ",
    input: "カヽ",
  },
  {
    expected: "キキ",
    input: "キヽ",
  },
  {
    expected: "スス",
    input: "スヽ",
  },
  {
    expected: "タタ",
    input: "タヽ",
  },
  {
    expected: "ガカ", // voiced character cannot be repeated
    input: "ガヽ",
  },

  // Katakana repetition mark ヽ - invalid cases
  {
    expected: "ンヽ", // hatsuon cannot be repeated
    input: "ンヽ",
  },
  {
    expected: "ッヽ", // sokuon cannot be repeated
    input: "ッヽ",
  },
  {
    expected: "パヽ", // semi-voiced character cannot be repeated
    input: "パヽ",
  },

  // Katakana voiced repetition mark ヾ - valid cases
  {
    expected: "カガ",
    input: "カヾ",
  },
  {
    expected: "キギ",
    input: "キヾ",
  },
  {
    expected: "クグ",
    input: "クヾ",
  },
  {
    expected: "サザ",
    input: "サヾ",
  },
  {
    expected: "タダ",
    input: "タヾ",
  },
  {
    expected: "ハバ",
    input: "ハヾ",
  },
  {
    expected: "ガガ", // already voiced character
    input: "ガヾ",
  },

  // Katakana voiced repetition mark ヾ - invalid cases
  {
    expected: "アヾ", // 'ア' cannot be voiced
    input: "アヾ",
  },

  // Kanji repetition mark 々 - valid cases
  {
    expected: "人人",
    input: "人々",
  },
  {
    expected: "山山",
    input: "山々",
  },
  {
    expected: "木木",
    input: "木々",
  },
  {
    expected: "日日",
    input: "日々",
  },

  // Kanji repetition mark 々 - invalid cases
  {
    expected: "か々", // hiragana before 々
    input: "か々",
  },
  {
    expected: "カ々", // katakana before 々
    input: "カ々",
  },

  // Edge cases and combinations
  {
    expected: "かかきき",
    input: "かゝきゝ",
  },
  {
    expected: "かがきぎ",
    input: "かゞきゞ",
  },
  {
    expected: "カカキキ",
    input: "カヽキヽ",
  },
  {
    expected: "カガキギ",
    input: "カヾキヾ",
  },
  {
    expected: "人人山山",
    input: "人々山々",
  },

  // Mixed script cases
  {
    expected: "こころ、ココロ、其其",
    input: "こゝろ、コヽロ、其々",
  },

  // No previous character cases
  {
    expected: "ゝ", // no previous character
    input: "ゝ",
  },
  {
    expected: "ゞ", // no previous character
    input: "ゞ",
  },
  {
    expected: "ヽ", // no previous character
    input: "ヽ",
  },
  {
    expected: "ヾ", // no previous character
    input: "ヾ",
  },
  {
    expected: "々", // no previous character
    input: "々",
  },

  // Complex sentences
  {
    expected: "私はここで勉強します",
    input: "私はこゝで勉強します",
  },
  {
    expected: "トトロのキキ",
    input: "トヽロのキヽ",
  },
  {
    expected: "山山の木木",
    input: "山々の木々",
  },

  // Vertical kana repeat marks (U+3031, U+3032, U+3033, U+3034)
  // U+3031 〱 - vertical hiragana repeat mark
  {
    expected: "かか",
    input: "か〱",
  },
  {
    expected: "きき",
    input: "き〱",
  },
  {
    expected: "がか", // voiced character followed by unvoiced vertical mark
    input: "が〱",
  },
  {
    expected: "ん〱", // hatsuon cannot be repeated
    input: "ん〱",
  },
  {
    expected: "っ〱", // sokuon cannot be repeated
    input: "っ〱",
  },

  // U+3032 〲 - vertical hiragana voiced repeat mark
  {
    expected: "かが",
    input: "か〲",
  },
  {
    expected: "きぎ",
    input: "き〲",
  },
  {
    expected: "がが", // voiced character followed by voiced vertical mark
    input: "が〲",
  },
  {
    expected: "あ〲", // 'あ' cannot be voiced
    input: "あ〲",
  },

  // U+3033 〳 - vertical katakana repeat mark
  {
    expected: "カカ",
    input: "カ〳",
  },
  {
    expected: "キキ",
    input: "キ〳",
  },
  {
    expected: "ガカ", // voiced character followed by unvoiced vertical mark
    input: "ガ〳",
  },
  {
    expected: "ン〳", // hatsuon cannot be repeated
    input: "ン〳",
  },
  {
    expected: "ッ〳", // sokuon cannot be repeated
    input: "ッ〳",
  },

  // U+3034 〴 - vertical katakana voiced repeat mark
  {
    expected: "カガ",
    input: "カ〴",
  },
  {
    expected: "キギ",
    input: "キ〴",
  },
  {
    expected: "ガガ", // voiced character followed by voiced vertical mark
    input: "ガ〴",
  },
  {
    expected: "ア〴", // 'ア' cannot be voiced
    input: "ア〴",
  },

  // Mixed vertical marks with regular text
  {
    expected: "ここもココロも",
    input: "こ〱もコ〳ロも",
  },
  {
    expected: "はばとハバ",
    input: "は〲とハ〴",
  },

  // Vertical marks at beginning (no previous character)
  {
    expected: "〱", // no previous character
    input: "〱",
  },
  {
    expected: "〲", // no previous character
    input: "〲",
  },
  {
    expected: "〳", // no previous character
    input: "〳",
  },
  {
    expected: "〴", // no previous character
    input: "〴",
  },
] satisfies { expected: string; input: string }[])("japaneseIterationMarks $#", ({ expected, input }) => {
  expect(fromChars(target({})(buildCharArray(input)))).toEqual(expected);
});
