package io.yosina.codegen;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.List;

/** Represents a Roman numeral record from the JSON data file. */
@JsonIgnoreProperties(ignoreUnknown = true)
public class RomanNumeralsRecord {
    private int value;
    private Codes codes;
    private ShiftJis shiftJis;
    private Decomposed decomposed;

    /** Constructs an empty {@code RomanNumeralsRecord} for deserialization. */
    public RomanNumeralsRecord() {}

    /**
     * Returns the numeric value of this Roman numeral.
     *
     * @return the numeric value
     */
    public int getValue() {
        return value;
    }

    /**
     * Sets the numeric value of this Roman numeral.
     *
     * @param value the numeric value
     */
    public void setValue(int value) {
        this.value = value;
    }

    /**
     * Returns the Unicode code strings for this Roman numeral.
     *
     * @return the codes, or {@code null} if absent
     */
    public Codes getCodes() {
        return codes;
    }

    /**
     * Sets the Unicode code strings for this Roman numeral.
     *
     * @param codes the codes to set
     */
    public void setCodes(Codes codes) {
        this.codes = codes;
    }

    /**
     * Returns the Shift-JIS encoding for this Roman numeral.
     *
     * @return the Shift-JIS data, or {@code null} if absent
     */
    @JsonProperty("shift_jis")
    public ShiftJis getShiftJis() {
        return shiftJis;
    }

    /**
     * Sets the Shift-JIS encoding for this Roman numeral.
     *
     * @param shiftJis the Shift-JIS data to set
     */
    public void setShiftJis(ShiftJis shiftJis) {
        this.shiftJis = shiftJis;
    }

    /**
     * Returns the decomposed form of this Roman numeral.
     *
     * @return the decomposed form, or {@code null} if absent
     */
    public Decomposed getDecomposed() {
        return decomposed;
    }

    /**
     * Sets the decomposed form of this Roman numeral.
     *
     * @param decomposed the decomposed form to set
     */
    public void setDecomposed(Decomposed decomposed) {
        this.decomposed = decomposed;
    }

    /** Holds Unicode code strings for upper- and lower-case Roman numeral forms. */
    public static class Codes {
        private String upper;
        private String lower;

        /** Constructs an empty {@code Codes} for deserialization. */
        public Codes() {}

        /**
         * Returns the Unicode code string for the upper-case form.
         *
         * @return the upper-case code string
         */
        public String getUpper() {
            return upper;
        }

        /**
         * Sets the Unicode code string for the upper-case form.
         *
         * @param upper the upper-case code string
         */
        public void setUpper(String upper) {
            this.upper = upper;
        }

        /**
         * Returns the Unicode code string for the lower-case form.
         *
         * @return the lower-case code string
         */
        public String getLower() {
            return lower;
        }

        /**
         * Sets the Unicode code string for the lower-case form.
         *
         * @param lower the lower-case code string
         */
        public void setLower(String lower) {
            this.lower = lower;
        }
    }

    /** Holds Shift-JIS byte sequences for upper- and lower-case Roman numeral forms. */
    public static class ShiftJis {
        private List<Integer> upper;
        private List<Integer> lower;

        /** Constructs an empty {@code ShiftJis} for deserialization. */
        public ShiftJis() {}

        /**
         * Returns the Shift-JIS bytes for the upper-case form.
         *
         * @return the upper-case Shift-JIS bytes
         */
        public List<Integer> getUpper() {
            return upper;
        }

        /**
         * Sets the Shift-JIS bytes for the upper-case form.
         *
         * @param upper the upper-case Shift-JIS bytes
         */
        public void setUpper(List<Integer> upper) {
            this.upper = upper;
        }

        /**
         * Returns the Shift-JIS bytes for the lower-case form.
         *
         * @return the lower-case Shift-JIS bytes
         */
        public List<Integer> getLower() {
            return lower;
        }

        /**
         * Sets the Shift-JIS bytes for the lower-case form.
         *
         * @param lower the lower-case Shift-JIS bytes
         */
        public void setLower(List<Integer> lower) {
            this.lower = lower;
        }
    }

    /** Holds decomposed Unicode string sequences for upper- and lower-case Roman numeral forms. */
    public static class Decomposed {
        private List<String> upper;
        private List<String> lower;

        /** Constructs an empty {@code Decomposed} for deserialization. */
        public Decomposed() {}

        /**
         * Returns the decomposed strings for the upper-case form.
         *
         * @return the upper-case decomposed strings
         */
        public List<String> getUpper() {
            return upper;
        }

        /**
         * Sets the decomposed strings for the upper-case form.
         *
         * @param upper the upper-case decomposed strings
         */
        public void setUpper(List<String> upper) {
            this.upper = upper;
        }

        /**
         * Returns the decomposed strings for the lower-case form.
         *
         * @return the lower-case decomposed strings
         */
        public List<String> getLower() {
            return lower;
        }

        /**
         * Sets the decomposed strings for the lower-case form.
         *
         * @param lower the lower-case decomposed strings
         */
        public void setLower(List<String> lower) {
            this.lower = lower;
        }
    }
}
