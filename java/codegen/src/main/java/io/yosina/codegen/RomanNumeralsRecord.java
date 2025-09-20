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

    public int getValue() {
        return value;
    }

    public void setValue(int value) {
        this.value = value;
    }

    public Codes getCodes() {
        return codes;
    }

    public void setCodes(Codes codes) {
        this.codes = codes;
    }

    @JsonProperty("shift_jis")
    public ShiftJis getShiftJis() {
        return shiftJis;
    }

    public void setShiftJis(ShiftJis shiftJis) {
        this.shiftJis = shiftJis;
    }

    public Decomposed getDecomposed() {
        return decomposed;
    }

    public void setDecomposed(Decomposed decomposed) {
        this.decomposed = decomposed;
    }

    public static class Codes {
        private String upper;
        private String lower;

        public String getUpper() {
            return upper;
        }

        public void setUpper(String upper) {
            this.upper = upper;
        }

        public String getLower() {
            return lower;
        }

        public void setLower(String lower) {
            this.lower = lower;
        }
    }

    public static class ShiftJis {
        private List<Integer> upper;
        private List<Integer> lower;

        public List<Integer> getUpper() {
            return upper;
        }

        public void setUpper(List<Integer> upper) {
            this.upper = upper;
        }

        public List<Integer> getLower() {
            return lower;
        }

        public void setLower(List<Integer> lower) {
            this.lower = lower;
        }
    }

    public static class Decomposed {
        private List<String> upper;
        private List<String> lower;

        public List<String> getUpper() {
            return upper;
        }

        public void setUpper(List<String> upper) {
            this.upper = upper;
        }

        public List<String> getLower() {
            return lower;
        }

        public void setLower(List<String> lower) {
            this.lower = lower;
        }
    }
}
