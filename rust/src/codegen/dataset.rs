use std::collections::BTreeMap;
use std::path::Path;

use super::loaders::*;
use super::models::*;

#[derive(Debug, Clone)]
pub struct Dataset {
    pub spaces: Vec<(String, String)>,
    pub radicals: Vec<(String, String)>,
    pub mathematical_alphanumerics: Vec<(String, String)>,
    pub ideographic_annotations: Vec<(String, String)>,
    pub hyphens: Vec<(String, HyphensRecord)>,
    pub ivs_svs_base: Vec<IvsSvsBaseRecord>,
    pub kanji_old_new: Vec<(String, String)>,
    pub combined: Vec<(String, String)>,
    pub circled_or_squared: Vec<(String, CircledOrSquaredRecord)>,
}

pub type DatasetSourceDefs = BTreeMap<String, String>;

impl Dataset {
    pub fn from_data_root(root: &Path, defs: &DatasetSourceDefs) -> Result<Self, anyhow::Error> {
        let spaces = load_spaces(&root.join(&defs["spaces"]))?;
        let radicals = load_radicals(&root.join(&defs["radicals"]))?;
        let mathematical_alphanumerics =
            load_mathematical_alphanumerics(&root.join(&defs["mathematical_alphanumerics"]))?;
        let ideographic_annotations =
            load_ideographic_annotations(&root.join(&defs["ideographic_annotations"]))?;
        let hyphens = load_hyphens(&root.join(&defs["hyphens"]))?;
        let ivs_svs_base = load_ivs_svs_base(&root.join(&defs["ivs_svs_base"]))?;
        let kanji_old_new = load_kanji_old_new(&root.join(&defs["kanji_old_new"]))?;
        let combined = load_combined(&root.join(&defs["combined"]))?;
        let circled_or_squared = load_circled_or_squared(&root.join(&defs["circled_or_squared"]))?;

        Ok(Dataset {
            spaces,
            radicals,
            mathematical_alphanumerics,
            ideographic_annotations,
            hyphens,
            ivs_svs_base,
            kanji_old_new,
            combined,
            circled_or_squared,
        })
    }
}
