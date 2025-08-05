package io.yosina.transliterators;

import io.yosina.Char;
import io.yosina.CharIterator;
import io.yosina.CodePointTuple;
import io.yosina.Transliterator;
import io.yosina.annotations.RegisteredTransliterator;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.NoSuchElementException;
import java.util.Objects;
import java.util.Set;

/**
 * Prolonged sound marks transliterator.
 *
 * <p>This transliterator handles the replacement of hyphen-like characters with appropriate
 * prolonged sound marks (ー or ｰ) when they appear after Japanese characters that can be prolonged.
 */
@RegisteredTransliterator(name = "prolonged-sound-marks")
public class ProlongedSoundMarksTransliterator implements Transliterator {

    /** Character type classification flags. */
    /** Character type classification for determining whether a character can be prolonged. */
    private enum CharType {
        /** Other character types */
        OTHER(0x00),
        /** Hiragana character */
        HIRAGANA(0x20),
        /** Katakana character */
        KATAKANA(0x40),
        /** Alphabetic character */
        ALPHABET(0x60),
        /** Digit character */
        DIGIT(0x80),
        /** Either hiragana or katakana */
        EITHER(0xA0),

        /** Halfwidth character flag */
        HALFWIDTH(1 << 0),
        /** Vowel-ended character flag */
        VOWEL_ENDED(1 << 1),
        /** Hatsuon (ん/ン) character flag */
        HATSUON(1 << 2),
        /** Sokuon (っ/ッ) character flag */
        SOKUON(1 << 3),
        /** Prolonged sound mark flag */
        PROLONGED_SOUND_MARK(1 << 4),

        /** Halfwidth digit */
        HALFWIDTH_DIGIT(DIGIT.value | HALFWIDTH.value),
        /** Fullwidth digit */
        FULLWIDTH_DIGIT(DIGIT.value),
        /** Halfwidth alphabet */
        HALFWIDTH_ALPHABET(ALPHABET.value | HALFWIDTH.value),
        /** Fullwidth alphabet */
        FULLWIDTH_ALPHABET(ALPHABET.value),
        /** Ordinary hiragana (vowel-ended) */
        ORDINARY_HIRAGANA(HIRAGANA.value | VOWEL_ENDED.value),
        /** Ordinary katakana (vowel-ended) */
        ORDINARY_KATAKANA(KATAKANA.value | VOWEL_ENDED.value),
        /** Ordinary halfwidth katakana (vowel-ended) */
        ORDINARY_HALFWIDTH_KATAKANA(KATAKANA.value | VOWEL_ENDED.value | HALFWIDTH.value);

        private final int value;

        CharType(int value) {
            this.value = value;
        }

        /**
         * Checks if the character type is alphanumeric.
         *
         * @param typeValue the character type value
         * @return true if the character is alphanumeric, false otherwise
         */
        public static boolean isAlnum(int typeValue) {
            int t = (typeValue & 0xe0);
            return t == ALPHABET.value || t == DIGIT.value;
        }

        /**
         * Checks if the character type is halfwidth.
         *
         * @param typeValue the character type value
         * @return true if the character is halfwidth, false otherwise
         */
        public static boolean isHalfwidth(int typeValue) {
            return (typeValue & HALFWIDTH.value) != 0;
        }

        /**
         * Checks if the character type has a specific flag.
         *
         * @param typeValue the character type value
         * @param flag the flag to check
         * @return true if the character has the flag, false otherwise
         */
        public static boolean hasFlag(int typeValue, CharType flag) {
            return (typeValue & flag.value) != 0;
        }

        /**
         * Combines multiple character types into a single value.
         *
         * @param types the character types to combine
         * @return the combined character type value
         */
        public static int combine(CharType... types) {
            int combined = 0;
            for (CharType type : types) {
                combined |= type.value;
            }
            return combined;
        }

        /**
         * Determines the character type from a Unicode code point.
         *
         * @param codepoint the Unicode code point
         * @return the character type value
         */
        public static int fromCodepoint(int codepoint) {
            // Halfwidth digits
            if (0x30 <= codepoint && codepoint <= 0x39) {
                return HALFWIDTH_DIGIT.value;
            }

            // Fullwidth digits
            if (0xFF10 <= codepoint && codepoint <= 0xFF19) {
                return FULLWIDTH_DIGIT.value;
            }

            // Halfwidth alphabets
            if ((0x41 <= codepoint && codepoint <= 0x5A)
                    || (0x61 <= codepoint && codepoint <= 0x7A)) {
                return HALFWIDTH_ALPHABET.value;
            }

            // Fullwidth alphabets
            if ((0xFF21 <= codepoint && codepoint <= 0xFF3A)
                    || (0xFF41 <= codepoint && codepoint <= 0xFF5A)) {
                return FULLWIDTH_ALPHABET.value;
            }

            // Special characters
            if (SPECIALS.containsKey(codepoint)) {
                return SPECIALS.get(codepoint);
            }

            // Hiragana
            if ((0x3041 <= codepoint && codepoint <= 0x309C) || codepoint == 0x309F) {
                return ORDINARY_HIRAGANA.value;
            }

            // Katakana
            if ((0x30A1 <= codepoint && codepoint <= 0x30FA)
                    || (0x30FD <= codepoint && codepoint <= 0x30FF)) {
                return ORDINARY_KATAKANA.value;
            }

            // Halfwidth katakana
            if ((0xFF66 <= codepoint && codepoint <= 0xFF6F)
                    || (0xFF71 <= codepoint && codepoint <= 0xFF9F)) {
                return ORDINARY_HALFWIDTH_KATAKANA.value;
            }

            return OTHER.value;
        }
    }

    // Special character mappings
    private static final Map<Integer, Integer> SPECIALS = new HashMap<>();

    static {
        SPECIALS.put(
                0xFF70,
                CharType.combine(
                        CharType.KATAKANA, CharType.PROLONGED_SOUND_MARK, CharType.HALFWIDTH)); // ｰ
        SPECIALS.put(0x30FC, CharType.combine(CharType.EITHER, CharType.PROLONGED_SOUND_MARK)); // ー
        SPECIALS.put(0x3063, CharType.combine(CharType.HIRAGANA, CharType.SOKUON)); // っ
        SPECIALS.put(0x3093, CharType.combine(CharType.HIRAGANA, CharType.HATSUON)); // ん
        SPECIALS.put(0x30C3, CharType.combine(CharType.KATAKANA, CharType.SOKUON)); // ッ
        SPECIALS.put(0x30F3, CharType.combine(CharType.KATAKANA, CharType.HATSUON)); // ン
        SPECIALS.put(
                0xFF6F,
                CharType.combine(CharType.KATAKANA, CharType.SOKUON, CharType.HALFWIDTH)); // ｯ
        SPECIALS.put(
                0xFF9D,
                CharType.combine(CharType.KATAKANA, CharType.HATSUON, CharType.HALFWIDTH)); // ﾝ
    }

    // Hyphen-like characters that could be prolonged sound marks
    private static final Set<String> HYPHEN_LIKE_CHARS =
            Set.of("\u002d", "\u2010", "\u2014", "\u2015", "\u2212", "\uff0d", "\uff70", "\u30fc");

    /** Options for the transliterator. */
    public static class Options {
        private final boolean skipAlreadyTransliteratedChars;
        private final boolean allowProlongedHatsuon;
        private final boolean allowProlongedSokuon;
        private final boolean replaceProlongedMarksFollowingAlnums;

        /**
         * Creates a new Options instance with default settings. All options are disabled by
         * default.
         */
        public Options() {
            this(false, false, false, false);
        }

        /**
         * Creates a new Options instance with the specified settings.
         *
         * @param skipAlreadyTransliteratedChars if true, skip characters that have already been
         *     transliterated
         * @param allowProlongedHatsuon if true, allow prolonging hatsuon (ん/ン) characters
         * @param allowProlongedSokuon if true, allow prolonging sokuon (っ/ッ) characters
         * @param replaceProlongedMarksFollowingAlnums if true, replace prolonged marks following
         *     alphanumeric characters
         */
        public Options(
                boolean skipAlreadyTransliteratedChars,
                boolean allowProlongedHatsuon,
                boolean allowProlongedSokuon,
                boolean replaceProlongedMarksFollowingAlnums) {
            this.skipAlreadyTransliteratedChars = skipAlreadyTransliteratedChars;
            this.allowProlongedHatsuon = allowProlongedHatsuon;
            this.allowProlongedSokuon = allowProlongedSokuon;
            this.replaceProlongedMarksFollowingAlnums = replaceProlongedMarksFollowingAlnums;
        }

        /**
         * Returns whether already transliterated characters should be skipped.
         *
         * @return true if already transliterated characters should be skipped, false otherwise
         */
        public boolean isSkipAlreadyTransliteratedChars() {
            return skipAlreadyTransliteratedChars;
        }

        /**
         * Returns whether hatsuon characters can be prolonged.
         *
         * @return true if hatsuon characters can be prolonged, false otherwise
         */
        public boolean isAllowProlongedHatsuon() {
            return allowProlongedHatsuon;
        }

        /**
         * Returns whether sokuon characters can be prolonged.
         *
         * @return true if sokuon characters can be prolonged, false otherwise
         */
        public boolean isAllowProlongedSokuon() {
            return allowProlongedSokuon;
        }

        /**
         * Returns whether prolonged marks following alphanumeric characters should be replaced.
         *
         * @return true if prolonged marks following alphanumerics should be replaced, false
         *     otherwise
         */
        public boolean isReplaceProlongedMarksFollowingAlnums() {
            return replaceProlongedMarksFollowingAlnums;
        }

        /**
         * Creates a new Options instance with the specified skip already transliterated chars
         * setting.
         *
         * @param skipAlreadyTransliteratedChars the new skip already transliterated chars setting
         * @return a new Options instance with the updated setting
         */
        public Options withSkipAlreadyTransliteratedChars(boolean skipAlreadyTransliteratedChars) {
            return new Options(
                    skipAlreadyTransliteratedChars,
                    this.allowProlongedHatsuon,
                    this.allowProlongedSokuon,
                    this.replaceProlongedMarksFollowingAlnums);
        }

        /**
         * Creates a new Options instance with the specified allow prolonged hatsuon setting.
         *
         * @param allowProlongedHatsuon the new allow prolonged hatsuon setting
         * @return a new Options instance with the updated setting
         */
        public Options withAllowProlongedHatsuon(boolean allowProlongedHatsuon) {
            return new Options(
                    this.skipAlreadyTransliteratedChars,
                    allowProlongedHatsuon,
                    this.allowProlongedSokuon,
                    this.replaceProlongedMarksFollowingAlnums);
        }

        /**
         * Creates a new Options instance with the specified allow prolonged sokuon setting.
         *
         * @param allowProlongedSokuon the new allow prolonged sokuon setting
         * @return a new Options instance with the updated setting
         */
        public Options withAllowProlongedSokuon(boolean allowProlongedSokuon) {
            return new Options(
                    this.skipAlreadyTransliteratedChars,
                    this.allowProlongedHatsuon,
                    allowProlongedSokuon,
                    this.replaceProlongedMarksFollowingAlnums);
        }

        /**
         * Creates a new Options instance with the specified replace prolonged marks following
         * alphanumerics setting.
         *
         * @param replaceProlongedMarksFollowingAlnums the new replace prolonged marks following
         *     alphanumerics setting
         * @return a new Options instance with the updated setting
         */
        public Options withReplaceProlongedMarksFollowingAlnums(
                boolean replaceProlongedMarksFollowingAlnums) {
            return new Options(
                    this.skipAlreadyTransliteratedChars,
                    this.allowProlongedHatsuon,
                    this.allowProlongedSokuon,
                    replaceProlongedMarksFollowingAlnums);
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) return true;
            if (obj == null || getClass() != obj.getClass()) return false;
            Options options = (Options) obj;
            return skipAlreadyTransliteratedChars == options.skipAlreadyTransliteratedChars
                    && allowProlongedHatsuon == options.allowProlongedHatsuon
                    && allowProlongedSokuon == options.allowProlongedSokuon
                    && replaceProlongedMarksFollowingAlnums
                            == options.replaceProlongedMarksFollowingAlnums;
        }

        @Override
        public int hashCode() {
            return Objects.hash(
                    skipAlreadyTransliteratedChars,
                    allowProlongedHatsuon,
                    allowProlongedSokuon,
                    replaceProlongedMarksFollowingAlnums);
        }
    }

    private final Options options;
    private final EnumSet<CharType> prolongables;

    /** Creates a new ProlongedSoundMarksTransliterator with default options. */
    public ProlongedSoundMarksTransliterator() {
        this(new Options());
    }

    /**
     * Creates a new ProlongedSoundMarksTransliterator with the specified options.
     *
     * @param options the options for configuring the transliterator behavior
     */
    public ProlongedSoundMarksTransliterator(Options options) {
        this.options = options;

        // Build prolongable character types
        this.prolongables = EnumSet.of(CharType.VOWEL_ENDED, CharType.PROLONGED_SOUND_MARK);
        if (options.allowProlongedHatsuon) {
            this.prolongables.add(CharType.HATSUON);
        }
        if (options.allowProlongedSokuon) {
            this.prolongables.add(CharType.SOKUON);
        }
    }

    /**
     * Transliterates the input by converting hyphen-like characters to prolonged sound marks.
     *
     * @param input the input character iterator
     * @return a new character iterator with prolonged sound marks
     */
    @Override
    public CharIterator transliterate(CharIterator input) {
        return new ProlongedSoundMarksCharIterator(input, options, prolongables);
    }

    private static class ProlongedSoundMarksCharIterator implements CharIterator {
        private final CharIterator input;
        private final Options options;
        private final EnumSet<CharType> prolongables;
        private int offset = 0;
        private boolean processedCharsInLookahead = false;
        private final List<Char> lookaheadBuf = new ArrayList<>();
        private CharWithType lastNonProlongedChar = null;
        private Char pendingChar = null;
        private final List<Char> outputBuf = new ArrayList<>();

        private static class CharWithType {
            final int type;

            CharWithType(Char character, int type) {
                this.type = type;
            }
        }

        public ProlongedSoundMarksCharIterator(
                CharIterator input, Options options, EnumSet<CharType> prolongables) {
            this.input = input;
            this.options = options;
            this.prolongables = prolongables;
        }

        @Override
        public boolean hasNext() {
            return !outputBuf.isEmpty()
                    || pendingChar != null
                    || !lookaheadBuf.isEmpty()
                    || input.hasNext();
        }

        @Override
        public Char next() {
            if (!hasNext()) {
                throw new NoSuchElementException();
            }

            // If we have output characters buffered, return them first
            if (!outputBuf.isEmpty()) {
                return outputBuf.remove(0);
            }

            // If we have a pending character from previous iteration, return it
            if (pendingChar != null) {
                Char result = pendingChar;
                pendingChar = null;
                return result;
            }

            // If we're processing lookahead buffer
            if (!lookaheadBuf.isEmpty()) {
                processLookaheadBuffer();
                if (!outputBuf.isEmpty()) {
                    return outputBuf.remove(0);
                }
            }

            // Get next character from input
            Char character = input.next();
            if (character == null || character.isSentinel()) {
                return character;
            }

            // Check if this is a hyphen-like character
            String charStr = character.get().toString();
            if (HYPHEN_LIKE_CHARS.contains(charStr)) {
                return processHyphenLikeChar(character);
            } else {
                // Update last non-prolonged character
                int codepoint = character.get().size() > 0 ? character.get().get(0) : -1;
                lastNonProlongedChar =
                        new CharWithType(character, CharType.fromCodepoint(codepoint));

                // Pass through the character
                Char result = character.withOffset(offset);
                offset += result.charCount();
                return result;
            }
        }

        private Char processHyphenLikeChar(Char character) {
            boolean shouldProcess =
                    !options.skipAlreadyTransliteratedChars || !character.isTransliterated();

            if (shouldProcess && lastNonProlongedChar != null) {
                // Check if the last character can be prolonged
                if (hasProlongableFlag(lastNonProlongedChar.type)) {
                    // Replace with appropriate prolonged sound mark
                    String replacement =
                            CharType.isHalfwidth(lastNonProlongedChar.type) ? "\uff70" : "\u30fc";
                    Char result = new Char(CodePointTuple.of(replacement), offset, character);
                    offset += result.charCount();
                    return result;
                } else if (options.replaceProlongedMarksFollowingAlnums
                        && CharType.isAlnum(lastNonProlongedChar.type)) {
                    // Start buffering for potential alphanumeric replacement
                    lookaheadBuf.add(character);
                    if (character.getSource() != null) {
                        processedCharsInLookahead = true;
                    }

                    // Continue reading hyphen-like characters
                    while (input.hasNext()) {
                        Char nextChar = input.next();
                        if (nextChar == null || nextChar.isSentinel()) {
                            pendingChar = nextChar;
                            break;
                        }
                        String nextCharStr = nextChar.get().toString();
                        if (HYPHEN_LIKE_CHARS.contains(nextCharStr)) {
                            lookaheadBuf.add(nextChar);
                            if (nextChar.getSource() != null) {
                                processedCharsInLookahead = true;
                            }
                        } else {
                            pendingChar = nextChar;
                            break;
                        }
                    }

                    processLookaheadBuffer();
                    if (!outputBuf.isEmpty()) {
                        return outputBuf.remove(0);
                    }
                }
            }

            // Default: pass through the character
            Char result = character.withOffset(offset);
            offset += result.charCount();
            return result;
        }

        private void processLookaheadBuffer() {
            if (lookaheadBuf.isEmpty()) {
                return;
            }

            CharWithType prevNonProlongedChar = lastNonProlongedChar;

            // Update last non-prolonged character if we have a pending char
            if (pendingChar != null) {
                int codepoint = pendingChar.get().size() > 0 ? pendingChar.get().get(0) : -1;
                lastNonProlongedChar =
                        new CharWithType(pendingChar, CharType.fromCodepoint(codepoint));
            }

            // Check if we should replace with hyphens for alphanumerics
            if ((prevNonProlongedChar == null || CharType.isAlnum(prevNonProlongedChar.type))
                    && (!options.skipAlreadyTransliteratedChars || !processedCharsInLookahead)) {

                // Determine replacement based on width
                String replacement;
                if (prevNonProlongedChar == null) {
                    replacement =
                            lastNonProlongedChar != null
                                            && CharType.isHalfwidth(lastNonProlongedChar.type)
                                    ? "\u002d"
                                    : "\uff0d";
                } else {
                    replacement =
                            CharType.isHalfwidth(prevNonProlongedChar.type) ? "\u002d" : "\uff0d";
                }

                // Replace ALL characters in buffer
                for (Char bufferedChar : lookaheadBuf) {
                    Char result = new Char(CodePointTuple.of(replacement), offset, bufferedChar);
                    outputBuf.add(result);
                    offset += result.charCount();
                }
            } else {
                // Just pass through all buffered characters
                for (Char bufferedChar : lookaheadBuf) {
                    Char result = bufferedChar.withOffset(offset);
                    outputBuf.add(result);
                    offset += result.charCount();
                }
            }

            // Clear the buffer and reset state
            lookaheadBuf.clear();
            processedCharsInLookahead = false;
        }

        private boolean hasProlongableFlag(int typeValue) {
            // Don't prolong if the character is already a prolonged sound mark
            if (CharType.hasFlag(typeValue, CharType.PROLONGED_SOUND_MARK)) {
                return false;
            }

            for (CharType prolongable : prolongables) {
                if (CharType.hasFlag(typeValue, prolongable)) {
                    return true;
                }
            }
            return false;
        }
    }
}
