use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct HyphensRecord {
    pub ascii: Option<String>,
    pub jisx0201: Option<String>,
    pub jisx0208_90: Option<String>,
    pub jisx0208_90_windows: Option<String>,
    pub jisx0208_verbatim: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IvsSvsBaseRecord {
    pub ivs: String,
    pub svs: Option<String>,
    pub base90: Option<String>,
    pub base2004: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CircledOrSquaredRecord {
    pub rendering: String,
    #[serde(rename = "type")]
    pub type_: String,
    pub emoji: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RomanNumeralsRecord {
    pub value: i32,
    pub codes: RomanNumeralsCodes,
    pub shift_jis: RomanNumeralsShiftJis,
    pub decomposed: RomanNumeralsDecomposed,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RomanNumeralsCodes {
    pub upper: String,
    pub lower: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RomanNumeralsShiftJis {
    pub upper: Vec<u8>,
    pub lower: Vec<u8>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RomanNumeralsDecomposed {
    pub upper: Vec<String>,
    pub lower: Vec<String>,
}
