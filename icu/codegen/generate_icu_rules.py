#!/usr/bin/env python3
"""Generate ICU transliteration rules from yosina data files."""

import sys
from pathlib import Path
from typing import Literal

# Add Python codegen to path to reuse existing data structures
sys.path.insert(0, str(Path(__file__).parent.parent.parent / "python"))

from codegen.dataset import DatasetSourceDefs, build_dataset_from_data_root
from codegen.models import CircledOrSquaredRecord, HyphensRecord, IvsSvsBaseRecord, RomanNumeralsRecord


Charset = Literal["unijis_90", "unijis_2004"]


def to_unicode_escape(s: str) -> str:
    """Convert a string to Unicode escape sequences for ICU rules.

    ICU uses \\uXXXX for BMP characters and \\UXXXXXXXX for supplementary plane characters.
    """
    result = ""
    for char in s:
        cp = ord(char)
        if cp > 0xFFFF:
            result += f"\\U{cp:08X}"
        else:
            result += f"\\u{cp:04X}"
    return result


def unicode_to_char(unicode_str: str) -> str:
    """Convert U+XXXX format to actual character."""
    if unicode_str.startswith("U+"):
        return chr(int(unicode_str[2:], 16))
    return unicode_str


def generate_simple_transliterator(name: str, data: list[tuple[str, str]]) -> str:
    """Generate ICU rules for simple character-to-character mappings."""
    rules = []
    rules.append(f"# {name} transliterator")
    rules.append("# Generated from yosina data")
    rules.append("")
    
    for source, target in data:
        if target is None:
            # Skip null mappings
            continue
        source_char = unicode_to_char(source)
        target_char = unicode_to_char(target)
        
        # Convert to Unicode escapes for safety
        source_escaped = to_unicode_escape(source_char)
        target_escaped = to_unicode_escape(target_char)
            
        rules.append(f"{source_escaped} > {target_escaped};")
    
    return "\n".join(rules)


def generate_hyphens_transliterator(data: list[tuple[str, HyphensRecord]]) -> str:
    """Generate ICU rules for hyphen transliterations."""
    rules = []
    rules.append("# Hyphens transliterator")
    rules.append("# Generated from yosina data")
    rules.append("")
    
    # For hyphens, we'll use the ASCII mapping as the default
    for source, record in data:
        if record.ascii is None:
            continue
        source_char = unicode_to_char(source)
        target_char = unicode_to_char(record.ascii)
        
        source_escaped = to_unicode_escape(source_char)
        target_escaped = to_unicode_escape(target_char)
            
        rules.append(f"{source_escaped} > {target_escaped};")
    
    return "\n".join(rules)


def generate_ivs_svs_base_transliterator(data: list[IvsSvsBaseRecord], charset: Charset) -> str:
    """Generate ICU rules for IVS/SVS to base character mappings."""
    rules = []
    rules.append("# IVS/SVS Base transliterator")
    rules.append("# Generated from yosina data")
    rules.append("")
    
    for record in data:
        # Use base90 as the default mapping
        if charset == "unijis_90":
            map_to = record.base90
        else:
            map_to = record.base2004

        if map_to is None:
            continue
            
        source_char = unicode_to_char(record.ivs)
        target_char = unicode_to_char(map_to)
        
        source_escaped = to_unicode_escape(source_char)
        target_escaped = to_unicode_escape(target_char)
            
        rules.append(f"{source_escaped} > {target_escaped};")
    
    return "\n".join(rules)


def generate_combined_transliterator(data: list[tuple[str, list[str]]]) -> str:
    """Generate ICU rules for combined character decomposition."""
    rules = []
    rules.append("# Combined characters transliterator")
    rules.append("# Generated from yosina data")
    rules.append("")
    
    for source, components in data:
        if not components:
            continue
            
        source_char = unicode_to_char(source)
        target_chars = "".join(unicode_to_char(c) for c in components)
        
        source_escaped = to_unicode_escape(source_char)
        # For target, use unicode escapes for the entire string
        target_escaped = to_unicode_escape(target_chars)
                
        rules.append(f"{source_escaped} > {target_escaped};")
    
    return "\n".join(rules)


def generate_kanji_old_new_transliterator(data: list[tuple[str, str]]) -> str:
    """Generate ICU rules for kanji old-new form mappings.

    The source data contains IVS-tagged character pairs. This generates:
    1. Rules for IVS-tagged characters (old+IVS → new+IVS)
    2. Rules for base characters only (old → new), deduplicated
    """
    rules = []
    rules.append("# kanji_old_new transliterator")
    rules.append("# Generated from yosina data")
    rules.append("")

    # First: generate IVS-tagged rules (more specific, must come first)
    rules.append("# IVS-tagged mappings (base char + variation selector)")
    for source, target in data:
        if target is None:
            continue
        source_escaped = to_unicode_escape(source)
        target_escaped = to_unicode_escape(target)
        rules.append(f"{source_escaped} > {target_escaped};")

    rules.append("")

    # Second: extract base-char-only mappings (strip IVS selectors)
    # IVS selectors are in range U+E0100-U+E01EF
    base_mappings: dict[str, str] = {}
    for source, target in data:
        if target is None:
            continue
        # Extract base characters (strip IVS/SVS selectors)
        source_base = "".join(c for c in source if not (0xE0100 <= ord(c) <= 0xE01EF) and not (0xFE00 <= ord(c) <= 0xFE0F))
        target_base = "".join(c for c in target if not (0xE0100 <= ord(c) <= 0xE01EF) and not (0xFE00 <= ord(c) <= 0xFE0F))
        if source_base != target_base and source_base not in base_mappings:
            base_mappings[source_base] = target_base

    rules.append("# Base character mappings (without variation selectors)")
    for source_base, target_base in base_mappings.items():
        source_escaped = to_unicode_escape(source_base)
        target_escaped = to_unicode_escape(target_base)
        rules.append(f"{source_escaped} > {target_escaped};")

    return "\n".join(rules)


def generate_circled_or_squared_transliterator(data: list[tuple[str, CircledOrSquaredRecord]]) -> str:
    """Generate ICU rules for circled/squared character mappings."""
    rules = []
    rules.append("# Circled/Squared characters transliterator")
    rules.append("# Generated from yosina data")
    rules.append("")
    
    for source, record in data:
        source_char = unicode_to_char(source)
        target_char = record.rendering
        
        source_escaped = to_unicode_escape(source_char)
        target_escaped = to_unicode_escape(target_char)
            
        # Add comment about the type
        comment = f" # {record.type}"
        if record.emoji:
            comment += " (emoji)"
            
        rules.append(f"{source_escaped} > {target_escaped};{comment}")
    
    return "\n".join(rules)


def generate_roman_numerals_transliterator(data: list[tuple[str, RomanNumeralsRecord]]) -> str:
    """Generate ICU rules for roman numeral decomposition."""
    rules = []
    rules.append("# roman_numerals transliterator")
    rules.append("# Generated from yosina data")
    rules.append("")

    for _source, record in data:
        # Upper case: e.g. Ⅱ (U+2161) → II
        upper_source = to_unicode_escape(unicode_to_char(record.upper))
        upper_target = to_unicode_escape("".join(unicode_to_char(c) for c in record.decomposed_upper))
        rules.append(f"{upper_source} > {upper_target};")

        # Lower case: e.g. ⅱ (U+2171) → ii
        lower_source = to_unicode_escape(unicode_to_char(record.lower))
        lower_target = to_unicode_escape("".join(unicode_to_char(c) for c in record.decomposed_lower))
        rules.append(f"{lower_source} > {lower_target};")

    return "\n".join(rules)


def main():
    """Main entry point."""
    # Paths
    project_root = Path(__file__).parent.parent.parent
    data_root = project_root / "data"
    rules_root = Path(__file__).parent.parent / "rules"
    
    print(f"Loading data from: {data_root}")
    print(f"Writing ICU rules to: {rules_root}")
    
    # Ensure rules directory exists
    rules_root.mkdir(exist_ok=True)
    
    # Define dataset sources
    defs = DatasetSourceDefs(
        spaces="spaces.json",
        radicals="radicals.json",
        mathematical_alphanumerics="mathematical-alphanumerics.json",
        ideographic_annotations="ideographic-annotation-marks.json",
        hyphens="hyphens.json",
        ivs_svs_base="ivs-svs-base-mappings.json",
        kanji_old_new="kanji-old-new-form.json",
        combined="combined-chars.json",
        circled_or_squared="circled-or-squared.json",
        roman_numerals="roman-numerals.json",
        archaic_hirakatas="archaic-hirakatas.json",
        small_hirakatas="small-hirakatas.json",
    )
    
    # Load dataset
    dataset = build_dataset_from_data_root(data_root, defs)
    
    # Generate simple transliterators
    simple_transliterators = [
        ("spaces", dataset.spaces),
        ("radicals", dataset.radicals),
        ("mathematical_alphanumerics", dataset.mathematical_alphanumerics),
        ("ideographic_annotations", dataset.ideographic_annotations),
        ("small_hirakatas", dataset.small_hirakatas),
        ("archaic_hirakatas", dataset.archaic_hirakatas),
    ]

    for name, data in simple_transliterators:
        output = generate_simple_transliterator(name, data)
        filepath = rules_root / f"{name}.txt"
        print(f"Generating: {filepath.name}")
        filepath.write_text(output, encoding="utf-8")

    # Generate kanji old-new transliterator (needs special handling for IVS)
    output = generate_kanji_old_new_transliterator(dataset.kanji_old_new)
    filepath = rules_root / "kanji_old_new.txt"
    print(f"Generating: {filepath.name}")
    filepath.write_text(output, encoding="utf-8")
    
    # Generate hyphens transliterator
    output = generate_hyphens_transliterator(dataset.hyphens)
    filepath = rules_root / "hyphens.txt"
    print(f"Generating: {filepath.name}")
    filepath.write_text(output, encoding="utf-8")
    
    # Generate IVS/SVS to base / base to IVS/SVS transliterators
    for charset in ("unijis_90", "unijis_2004"):
        output = generate_ivs_svs_base_transliterator(dataset.ivs_svs_base, charset)
        filepath = rules_root / f"ivs_svs_base_{charset}.txt"
        print(f"Generating: {filepath.name}")
        filepath.write_text(output, encoding="utf-8")

    # Generate combined transliterator
    output = generate_combined_transliterator(dataset.combined)
    filepath = rules_root / "combined.txt"
    print(f"Generating: {filepath.name}")
    filepath.write_text(output, encoding="utf-8")
    
    # Generate circled/squared transliterator
    output = generate_circled_or_squared_transliterator(dataset.circled_or_squared)
    filepath = rules_root / "circled_or_squared.txt"
    print(f"Generating: {filepath.name}")
    filepath.write_text(output, encoding="utf-8")
    
    # Generate roman numerals transliterator
    output = generate_roman_numerals_transliterator(dataset.roman_numerals)
    filepath = rules_root / "roman_numerals.txt"
    print(f"Generating: {filepath.name}")
    filepath.write_text(output, encoding="utf-8")

    print("ICU rule generation complete!")


if __name__ == "__main__":
    main()