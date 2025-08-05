import type { Char } from "../types.js";
import { semiVoicedCharacters, voicedCharacters } from "./hira-kata-table.js";

export type Options = Record<string, never>;

// Create lookup maps from the existing tables
const voicingMap = new Map<string, string>();
const semiVoicedChars = new Set<string>();

for (const [unvoiced, voiced] of voicedCharacters) {
  voicingMap.set(unvoiced, voiced);
}

for (const [unvoiced, semiVoiced] of semiVoicedCharacters) {
  semiVoicedChars.add(semiVoiced);
}

// Derived set of all voiced characters (values from voicing map)
const voicedChars = new Set(voicingMap.values());

// Helper function to check if a character is a hiragana
const isHiragana = (char: string): boolean => {
  const code = char.codePointAt(0);
  return code !== undefined && code >= 0x3041 && code <= 0x3096;
};

// Helper function to check if a character is a katakana
const isKatakana = (char: string): boolean => {
  const code = char.codePointAt(0);
  return code !== undefined && code >= 0x30a1 && code <= 0x30f6;
};

// Helper function to check if a character is a kanji
const isKanji = (char: string): boolean => {
  const code = char.codePointAt(0);
  return (
    code !== undefined &&
    ((code >= 0x4e00 && code <= 0x9fff) || // CJK Unified Ideographs
      (code >= 0x3400 && code <= 0x4dbf) || // CJK Extension A
      (code >= 0x20000 && code <= 0x2a6df) || // CJK Extension B
      (code >= 0x2a700 && code <= 0x2b73f) || // CJK Extension C
      (code >= 0x2b740 && code <= 0x2b81f) || // CJK Extension D
      (code >= 0x2b820 && code <= 0x2ceaf) || // CJK Extension E
      (code >= 0x2ceb0 && code <= 0x2ebef) || // CJK Extension F
      (code >= 0x30000 && code <= 0x3134f)) // CJK Extension G
  );
};

// Helper function to check if a hiragana/katakana character is voiced or semi-voiced
const isVoicedOrSemiVoiced = (char: string): boolean => {
  return voicedChars.has(char) || semiVoicedChars.has(char);
};

// Helper function to check if a character is a hatsuon (ん/ン)
const isHatsuon = (char: string): boolean => {
  return char === "ん" || char === "ン";
};

// Helper function to check if a character is a sokuon (っ/ッ)
const isSokuon = (char: string): boolean => {
  return char === "っ" || char === "ッ";
};

// Helper function to get the voiced version of a hiragana/katakana character
const getVoicedVersion = (char: string): string | undefined => {
  return voicingMap.get(char);
};

// Helper function to check if a character can be repeated
const canBeRepeated = (char: string): boolean => {
  return (isHiragana(char) || isKatakana(char)) && !isVoicedOrSemiVoiced(char) && !isHatsuon(char) && !isSokuon(char);
};

// Helper function to check if a character can be voiced
const canBeVoiced = (char: string): boolean => {
  return canBeRepeated(char) && getVoicedVersion(char) !== undefined;
};

export default (_: Options): ((_: Iterable<Char>) => Iterable<Char>) =>
  function* (in_: Iterable<Char>) {
    let offset = 0;
    let previousChar: Char | undefined;

    for (const currentChar of in_) {
      let outputChar = currentChar.c;
      let source = currentChar;

      // Check for iteration marks
      if (previousChar) {
        const prevCharStr = previousChar.c;
        const currentCharStr = currentChar.c;

        if (currentCharStr === "ゝ") {
          // Hiragana repetition mark
          if (isHiragana(prevCharStr) && canBeRepeated(prevCharStr)) {
            outputChar = prevCharStr;
            source = currentChar;
          }
        } else if (currentCharStr === "ゞ") {
          // Hiragana voiced repetition mark
          if (isHiragana(prevCharStr) && canBeVoiced(prevCharStr)) {
            const voiced = getVoicedVersion(prevCharStr);
            if (voiced) {
              outputChar = voiced;
              source = currentChar;
            }
          }
        } else if (currentCharStr === "ヽ") {
          // Katakana repetition mark
          if (isKatakana(prevCharStr) && canBeRepeated(prevCharStr)) {
            outputChar = prevCharStr;
            source = currentChar;
          }
        } else if (currentCharStr === "ヾ") {
          // Katakana voiced repetition mark
          if (isKatakana(prevCharStr) && canBeVoiced(prevCharStr)) {
            const voiced = getVoicedVersion(prevCharStr);
            if (voiced) {
              outputChar = voiced;
              source = currentChar;
            }
          }
        } else if (currentCharStr === "々") {
          // Kanji repetition mark
          if (isKanji(prevCharStr)) {
            outputChar = prevCharStr;
            source = currentChar;
          }
        }
      }

      yield { c: outputChar, offset: offset, source: source };
      offset += outputChar.length;
      previousChar = currentChar;
    }
  };
