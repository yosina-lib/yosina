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
