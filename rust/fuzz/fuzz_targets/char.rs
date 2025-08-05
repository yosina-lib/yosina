#![no_main]

use libfuzzer_sys::fuzz_target;

use yosina::char::{from_chars, CharPool};

fuzz_target!(|data: &str| {
    let mut pool = CharPool::new();
    let chars = pool.build_char_array(data);
    let _ = from_chars(chars);
});
