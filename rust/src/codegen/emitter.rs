use proc_macro2::{Span, TokenStream};
use quote::{format_ident, quote};
use syn::{LitInt, LitStr};

use super::models::{CircledOrSquaredRecord, HyphensRecord, IvsSvsBaseRecord, RomanNumeralsRecord};

pub fn render_simple_transliterator(
    module_name: &str,
    data: &[(String, String)],
) -> Result<String, anyhow::Error> {
    let struct_name = format_ident!("{}Transliterator", module_name);
    let mappings_name = format_ident!("{}_MAPPINGS", module_name.to_uppercase());
    // Build the phf_map entries as tokns
    let map_entries: Vec<TokenStream> = data
        .iter()
        .map(|(from, to)| {
            // Use actual Unicode characters instead of escape sequences
            let from_lit = LitStr::new(from, Span::call_site());
            let to_lit = LitStr::new(to, Span::call_site());
            quote! { #from_lit => #to_lit }
        })
        .collect();

    // Create factory struct name
    let factory_name = format_ident!("{}TransliteratorFactory", module_name);

    // Generate the complete module using quote!
    let tokens = quote! {
        // Auto-generated code - DO NOT EDIT
        use crate::transliterators::SimpleTransliterator;
        use crate::transliterator::{Transliterator, TransliteratorFactory, TransliteratorFactoryError, TransliterationError};
        use crate::char::{Char, CharPool};

        // Generated mapping data
        static #mappings_name: phf::Map<&'static str, &'static str> = phf::phf_map! {
            #(#map_entries),*
        };

        // Wrapper struct for the specific transliterator to avoid type alias conflicts
        pub struct #struct_name {
            inner: SimpleTransliterator,
        }

        impl #struct_name {
            #[allow(clippy::new_without_default)]
            pub fn new() -> Self {
                Self {
                    inner: SimpleTransliterator::new(&#mappings_name),
                }
            }
        }

        impl Transliterator for #struct_name {
            fn transliterate<'a, 'b>(
                &self,
                pool: &mut CharPool<'a, 'b>,
                input: &[&'a Char<'a, 'b>],
            ) -> Result<Vec<&'a Char<'a, 'b>>, TransliterationError> {
                self.inner.transliterate(pool, input)
            }
        }

        // Separate factory struct - this makes more sense than self-implementing factories
        pub struct #factory_name;

        impl #factory_name {
            #[allow(clippy::new_without_default)]
            pub fn new() -> Self {
                Self
            }
        }

        impl TransliteratorFactory for #factory_name {
            fn new_transliterator(&self) -> Result<Box<dyn Transliterator>, TransliteratorFactoryError> {
                Ok(Box::new(#struct_name::new()))
            }
        }
    };

    Ok(tokens.to_string())
}

pub fn render_hyphens_transliterator_data(
    data: &[(String, HyphensRecord)],
) -> Result<String, anyhow::Error> {
    // Build mapping insert statements as tokens
    let mapping_inserts: Vec<TokenStream> = data
        .iter()
        .map(|(key, record)| {
            let key_lit = LitStr::new(key, Span::call_site());

            let ascii_expr = record
                .ascii
                .as_ref()
                .map(|s| {
                    let lit = LitStr::new(s, Span::call_site());
                    quote! { Some(#lit) }
                })
                .unwrap_or_else(|| quote! { None });

            let jisx0201_expr = record
                .jisx0201
                .as_ref()
                .map(|s| {
                    let lit = LitStr::new(s, Span::call_site());
                    quote! { Some(#lit) }
                })
                .unwrap_or_else(|| quote! { None });

            let jisx0208_90_expr = record
                .jisx0208_90
                .as_ref()
                .map(|s| {
                    let lit = LitStr::new(s, Span::call_site());
                    quote! { Some(#lit) }
                })
                .unwrap_or_else(|| quote! { None });

            let jisx0208_90_windows_expr = record
                .jisx0208_90_windows
                .as_ref()
                .map(|s| {
                    let lit = LitStr::new(s, Span::call_site());
                    quote! { Some(#lit) }
                })
                .unwrap_or_else(|| quote! { None });

            let jisx0208_verbatim_expr = record
                .jisx0208_verbatim
                .as_ref()
                .map(|s| {
                    let lit = LitStr::new(s, Span::call_site());
                    quote! { Some(#lit) }
                })
                .unwrap_or_else(|| quote! { None });

            quote! {
                mappings.insert(
                    #key_lit,
                    HyphensRecord {
                        ascii: #ascii_expr,
                        jisx0201: #jisx0201_expr,
                        jisx0208_90: #jisx0208_90_expr,
                        jisx0208_90_windows: #jisx0208_90_windows_expr,
                        jisx0208_verbatim: #jisx0208_verbatim_expr,
                    }
                );
            }
        })
        .collect();

    // Generate the complete module using quote!
    let tokens = quote! {
        // Auto-generated code - DO NOT EDIT
        use lazy_static::lazy_static;

        lazy_static! {
            static ref MAPPINGS: HashMap<&'static str, HyphensRecord> = {
                let mut mappings = HashMap::new();
                #(#mapping_inserts)*
                mappings
            };
        }
    };

    Ok(tokens.to_string())
}

pub fn build_compressed_ivs_svs_base_records(data: &[IvsSvsBaseRecord]) -> String {
    data.iter()
        .flat_map(|r| {
            vec![
                r.ivs.as_str(),
                r.svs.as_deref().unwrap_or(""),
                r.base90.as_deref().unwrap_or(""),
                r.base2004.as_deref().unwrap_or(""),
            ]
        })
        .collect::<Vec<_>>()
        .join("\0")
}

pub fn render_ivs_svs_base_data(data: &[IvsSvsBaseRecord]) -> Result<String, anyhow::Error> {
    // Build compressed data table: each record contributes 4 consecutive strings
    // [ivs, svs, base90, base2004, ivs, svs, base90, base2004, ...]
    let compressed_data = build_compressed_ivs_svs_base_records(data);
    let compressed_data_lit = LitStr::new(&compressed_data, Span::call_site());
    let records_count = LitInt::new(&data.len().to_string(), Span::call_site());

    // Generate the complete module using quote!
    let tokens = quote! {
        // Auto-generated code - DO NOT EDIT
        use lazy_static::lazy_static;

        // Compressed data table - 4 strings per record: [ivs, svs, base90, base2004, ...]
        const COMPRESSED_DATA: &str = #compressed_data_lit;
        const RECORDS_COUNT: usize = #records_count;

        lazy_static! {
            static ref MAPPINGS: Vec<IvsSvsBaseRecord> = {
                let mut mappings = Vec::with_capacity(RECORDS_COUNT);

                // Parse compressed data at runtime
                expand_compressed_data(&mut mappings);

                mappings
            };
        }

        // Function to expand compressed data into HashMap
        fn expand_compressed_data(mappings: &mut Vec<IvsSvsBaseRecord>) {
            let mut field_start = 0;
            let mut field_index = 0;
            let mut record_parts: [Option<&str>; 4] = [None, None, None, None];
            let data_bytes = COMPRESSED_DATA.as_bytes();

            for (i, &byte) in data_bytes.iter().enumerate() {
                if byte == 0 { // null byte separator
                    let field_slice = &data_bytes[field_start..i];
                    let field_str = std::str::from_utf8(field_slice).expect("Invalid UTF-8 in compressed data");

                    record_parts[field_index] = if field_str.is_empty() { None } else { Some(field_str) };
                    field_start = i + 1;
                    field_index += 1;

                    if field_index == 4 {
                        // Complete record
                        if let Some(ivs) = record_parts[0] {
                            mappings.push(
                                IvsSvsBaseRecord {
                                    ivs,
                                    svs: record_parts[1],
                                    base90: record_parts[2],
                                    base2004: record_parts[3],
                                }
                            );
                        }
                        field_index = 0;
                        record_parts = [None, None, None, None];
                    }
                }
            }
        }
    };

    Ok(tokens.to_string())
}

pub fn render_circled_or_squared_data(
    data: &[(String, CircledOrSquaredRecord)],
) -> Result<String, anyhow::Error> {
    // Build the entries for the phf_map
    let mapping_inserts: Vec<TokenStream> = data
        .iter()
        .map(|(key, record)| {
            let key_lit = LitStr::new(key, Span::call_site());
            let rendering_lit = LitStr::new(&record.rendering, Span::call_site());
            let type_lit = LitStr::new(&record.type_, Span::call_site());
            let emoji_lit = if record.emoji {
                quote! { true }
            } else {
                quote! { false }
            };

            quote! {
                mappings.insert(
                    #key_lit,
                    CircledOrSquaredRecord {
                        rendering: #rendering_lit.to_string(),
                        type_: #type_lit.to_string(),
                        emoji: #emoji_lit,
                    }
                );
            }
        })
        .collect();

    // Generate the complete module using quote!
    let tokens = quote! {
        // Auto-generated code - DO NOT EDIT
        use lazy_static::lazy_static;
        use std::collections::HashMap;

        #[derive(Debug, Clone)]
        pub struct CircledOrSquaredRecord {
            pub rendering: String,
            pub type_: String,
            pub emoji: bool,
        }

        lazy_static! {
            pub static ref MAPPINGS: HashMap<&'static str, CircledOrSquaredRecord> = {
                let mut mappings = HashMap::new();
                #(#mapping_inserts)*
                mappings
            };
        }
    };

    Ok(tokens.to_string())
}

pub fn render_roman_numerals_data(
    data: &[(String, RomanNumeralsRecord)],
) -> Result<String, anyhow::Error> {
    // Build mapping entries for both upper and lower cases
    let mapping_inserts: Vec<TokenStream> = data
        .iter()
        .flat_map(|(_, record)| {
            let upper_codepoint = u32::from_str_radix(&record.codes.upper[2..], 16).unwrap();
            let upper_char = char::from_u32(upper_codepoint).unwrap().to_string();
            let lower_codepoint = u32::from_str_radix(&record.codes.lower[2..], 16).unwrap();
            let lower_char = char::from_u32(lower_codepoint).unwrap().to_string();

            let upper_decomposed = record.decomposed.upper.join("");
            let lower_decomposed = record.decomposed.lower.join("");

            vec![
                quote! {
                    mappings.insert(#upper_char, #upper_decomposed);
                },
                quote! {
                    mappings.insert(#lower_char, #lower_decomposed);
                },
            ]
        })
        .collect();

    let tokens = quote! {
        use std::collections::HashMap;
        use lazy_static::lazy_static;

        lazy_static! {
            pub static ref MAPPINGS: HashMap<&'static str, &'static str> = {
                let mut mappings = HashMap::new();
                #(#mapping_inserts)*
                mappings
            };
        }
    };

    Ok(tokens.to_string())
}
