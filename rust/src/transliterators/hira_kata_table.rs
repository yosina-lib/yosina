/// Hiragana character forms
#[derive(Debug, Clone, Copy)]
pub struct HiraKata {
    pub base: &'static str,
    pub voiced: Option<&'static str>,
    pub semivoiced: Option<&'static str>,
}

/// Entry in the hiragana-katakana table
#[derive(Debug, Clone, Copy)]
pub struct HiraKataEntry {
    pub hiragana: HiraKata,
    pub katakana: HiraKata,
    pub halfwidth: Option<HiraKata>,
}

/// Shared hiragana-katakana mapping table
pub static HIRAGANA_KATAKANA_TABLE: &[HiraKataEntry] = &[
    // Vowels
    HiraKataEntry {
        hiragana: HiraKata {
            base: "あ",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ア",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｱ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "い",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "イ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｲ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "う",
            voiced: Some("ゔ"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ウ",
            voiced: Some("ヴ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｳ",
            voiced: Some("ｳﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "え",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "エ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｴ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "お",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "オ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｵ",
            voiced: None,
            semivoiced: None,
        }),
    },
    // K-row
    HiraKataEntry {
        hiragana: HiraKata {
            base: "か",
            voiced: Some("が"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "カ",
            voiced: Some("ガ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｶ",
            voiced: Some("ｶﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "き",
            voiced: Some("ぎ"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "キ",
            voiced: Some("ギ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｷ",
            voiced: Some("ｷﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "く",
            voiced: Some("ぐ"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ク",
            voiced: Some("グ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｸ",
            voiced: Some("ｸﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "け",
            voiced: Some("げ"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ケ",
            voiced: Some("ゲ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｹ",
            voiced: Some("ｹﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "こ",
            voiced: Some("ご"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "コ",
            voiced: Some("ゴ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｺ",
            voiced: Some("ｺﾞ"),
            semivoiced: None,
        }),
    },
    // S-row
    HiraKataEntry {
        hiragana: HiraKata {
            base: "さ",
            voiced: Some("ざ"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "サ",
            voiced: Some("ザ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｻ",
            voiced: Some("ｻﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "し",
            voiced: Some("じ"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "シ",
            voiced: Some("ジ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｼ",
            voiced: Some("ｼﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "す",
            voiced: Some("ず"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ス",
            voiced: Some("ズ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｽ",
            voiced: Some("ｽﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "せ",
            voiced: Some("ぜ"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "セ",
            voiced: Some("ゼ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｾ",
            voiced: Some("ｾﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "そ",
            voiced: Some("ぞ"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ソ",
            voiced: Some("ゾ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｿ",
            voiced: Some("ｿﾞ"),
            semivoiced: None,
        }),
    },
    // T-row
    HiraKataEntry {
        hiragana: HiraKata {
            base: "た",
            voiced: Some("だ"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "タ",
            voiced: Some("ダ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾀ",
            voiced: Some("ﾀﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ち",
            voiced: Some("ぢ"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "チ",
            voiced: Some("ヂ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾁ",
            voiced: Some("ﾁﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "つ",
            voiced: Some("づ"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ツ",
            voiced: Some("ヅ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾂ",
            voiced: Some("ﾂﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "て",
            voiced: Some("で"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "テ",
            voiced: Some("デ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾃ",
            voiced: Some("ﾃﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "と",
            voiced: Some("ど"),
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ト",
            voiced: Some("ド"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾄ",
            voiced: Some("ﾄﾞ"),
            semivoiced: None,
        }),
    },
    // N-row
    HiraKataEntry {
        hiragana: HiraKata {
            base: "な",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ナ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾅ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "に",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ニ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾆ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ぬ",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ヌ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾇ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ね",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ネ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾈ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "の",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ノ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾉ",
            voiced: None,
            semivoiced: None,
        }),
    },
    // H-row
    HiraKataEntry {
        hiragana: HiraKata {
            base: "は",
            voiced: Some("ば"),
            semivoiced: Some("ぱ"),
        },
        katakana: HiraKata {
            base: "ハ",
            voiced: Some("バ"),
            semivoiced: Some("パ"),
        },
        halfwidth: Some(HiraKata {
            base: "ﾊ",
            voiced: Some("ﾊﾞ"),
            semivoiced: Some("ﾊﾟ"),
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ひ",
            voiced: Some("び"),
            semivoiced: Some("ぴ"),
        },
        katakana: HiraKata {
            base: "ヒ",
            voiced: Some("ビ"),
            semivoiced: Some("ピ"),
        },
        halfwidth: Some(HiraKata {
            base: "ﾋ",
            voiced: Some("ﾋﾞ"),
            semivoiced: Some("ﾋﾟ"),
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ふ",
            voiced: Some("ぶ"),
            semivoiced: Some("ぷ"),
        },
        katakana: HiraKata {
            base: "フ",
            voiced: Some("ブ"),
            semivoiced: Some("プ"),
        },
        halfwidth: Some(HiraKata {
            base: "ﾌ",
            voiced: Some("ﾌﾞ"),
            semivoiced: Some("ﾌﾟ"),
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "へ",
            voiced: Some("べ"),
            semivoiced: Some("ぺ"),
        },
        katakana: HiraKata {
            base: "ヘ",
            voiced: Some("ベ"),
            semivoiced: Some("ペ"),
        },
        halfwidth: Some(HiraKata {
            base: "ﾍ",
            voiced: Some("ﾍﾞ"),
            semivoiced: Some("ﾍﾟ"),
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ほ",
            voiced: Some("ぼ"),
            semivoiced: Some("ぽ"),
        },
        katakana: HiraKata {
            base: "ホ",
            voiced: Some("ボ"),
            semivoiced: Some("ポ"),
        },
        halfwidth: Some(HiraKata {
            base: "ﾎ",
            voiced: Some("ﾎﾞ"),
            semivoiced: Some("ﾎﾟ"),
        }),
    },
    // M-row
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ま",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "マ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾏ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "み",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ミ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾐ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "む",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ム",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾑ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "め",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "メ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾒ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "も",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "モ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾓ",
            voiced: None,
            semivoiced: None,
        }),
    },
    // Y-row
    HiraKataEntry {
        hiragana: HiraKata {
            base: "や",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ヤ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾔ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ゆ",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ユ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾕ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "よ",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ヨ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾖ",
            voiced: None,
            semivoiced: None,
        }),
    },
    // R-row
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ら",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ラ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾗ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "り",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "リ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾘ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "る",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ル",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾙ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "れ",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "レ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾚ",
            voiced: None,
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ろ",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ロ",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾛ",
            voiced: None,
            semivoiced: None,
        }),
    },
    // W-row
    HiraKataEntry {
        hiragana: HiraKata {
            base: "わ",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ワ",
            voiced: Some("ヷ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾜ",
            voiced: Some("ﾜﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ゐ",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ヰ",
            voiced: Some("ヸ"),
            semivoiced: None,
        },
        halfwidth: None,
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ゑ",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ヱ",
            voiced: Some("ヹ"),
            semivoiced: None,
        },
        halfwidth: None,
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "を",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ヲ",
            voiced: Some("ヺ"),
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ｦ",
            voiced: Some("ｦﾞ"),
            semivoiced: None,
        }),
    },
    HiraKataEntry {
        hiragana: HiraKata {
            base: "ん",
            voiced: None,
            semivoiced: None,
        },
        katakana: HiraKata {
            base: "ン",
            voiced: None,
            semivoiced: None,
        },
        halfwidth: Some(HiraKata {
            base: "ﾝ",
            voiced: None,
            semivoiced: None,
        }),
    },
];

/// Small kana entry
#[derive(Debug, Clone, Copy)]
pub struct SmallKanaEntry {
    pub hiragana: &'static str,
    pub katakana: &'static str,
    pub halfwidth: Option<&'static str>,
}

/// Small kana table
pub static HIRAGANA_KATAKANA_SMALL_TABLE: &[SmallKanaEntry] = &[
    SmallKanaEntry {
        hiragana: "ぁ",
        katakana: "ァ",
        halfwidth: Some("ｧ"),
    },
    SmallKanaEntry {
        hiragana: "ぃ",
        katakana: "ィ",
        halfwidth: Some("ｨ"),
    },
    SmallKanaEntry {
        hiragana: "ぅ",
        katakana: "ゥ",
        halfwidth: Some("ｩ"),
    },
    SmallKanaEntry {
        hiragana: "ぇ",
        katakana: "ェ",
        halfwidth: Some("ｪ"),
    },
    SmallKanaEntry {
        hiragana: "ぉ",
        katakana: "ォ",
        halfwidth: Some("ｫ"),
    },
    SmallKanaEntry {
        hiragana: "っ",
        katakana: "ッ",
        halfwidth: Some("ｯ"),
    },
    SmallKanaEntry {
        hiragana: "ゃ",
        katakana: "ャ",
        halfwidth: Some("ｬ"),
    },
    SmallKanaEntry {
        hiragana: "ゅ",
        katakana: "ュ",
        halfwidth: Some("ｭ"),
    },
    SmallKanaEntry {
        hiragana: "ょ",
        katakana: "ョ",
        halfwidth: Some("ｮ"),
    },
    SmallKanaEntry {
        hiragana: "ゎ",
        katakana: "ヮ",
        halfwidth: None,
    },
    SmallKanaEntry {
        hiragana: "ゕ",
        katakana: "ヵ",
        halfwidth: None,
    },
    SmallKanaEntry {
        hiragana: "ゖ",
        katakana: "ヶ",
        halfwidth: None,
    },
];

/// Generate voiced character mappings
pub fn generate_voiced_characters() -> Vec<(&'static str, &'static str)> {
    let mut result = Vec::new();

    for entry in HIRAGANA_KATAKANA_TABLE {
        if let Some(voiced) = entry.hiragana.voiced {
            result.push((entry.hiragana.base, voiced));
        }
        if let Some(voiced) = entry.katakana.voiced {
            result.push((entry.katakana.base, voiced));
        }
    }

    // Add iteration marks
    result.push(("ゝ", "ゞ"));
    result.push(("ヽ", "ヾ"));
    result.push(("〱", "〲")); // U+3031 -> U+3032 (vertical hiragana)
    result.push(("〳", "〴")); // U+3033 -> U+3034 (vertical katakana)

    result
}

/// Generate semi-voiced character mappings
pub fn generate_semi_voiced_characters() -> Vec<(&'static str, &'static str)> {
    let mut result = Vec::new();

    for entry in HIRAGANA_KATAKANA_TABLE {
        if let Some(semivoiced) = entry.hiragana.semivoiced {
            result.push((entry.hiragana.base, semivoiced));
        }
        if let Some(semivoiced) = entry.katakana.semivoiced {
            result.push((entry.katakana.base, semivoiced));
        }
    }

    result
}
