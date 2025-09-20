"""Main entry point for code generation."""

from pathlib import Path

from .dataset import DatasetSourceDefs, build_dataset_from_data_root
from .emitters import (
    render_circled_or_squared_transliterator,
    render_combined_transliterator,
    render_hyphens_transliterator_data,
    render_ivs_svs_base_transliterator_data,
    render_roman_numerals_transliterator,
    render_simple_transliterator,
)


def snake_case(s: str) -> str:
    """Convert camelCase to snake_case."""
    result: list[str] = []
    for i, char in enumerate(s):
        if char.isupper() and i > 0:
            result.append("_")
        result.append(char.lower())
    return "".join(result)


def main() -> None:
    """Main code generation entry point."""
    # Determine project paths
    current_dir = Path(__file__).parent
    project_root = current_dir.parent.parent
    data_root = project_root / "data"
    dest_root = current_dir.parent / "src" / "yosina" / "transliterators"

    print(f"Loading dataset from: {data_root}")
    print(f"Writing output to: {dest_root}")

    # Ensure destination directory exists
    dest_root.mkdir(exist_ok=True)

    # Define dataset source definitions
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
    )

    # Load the dataset
    dataset = build_dataset_from_data_root(data_root, defs)

    # Generate simple transliterators
    simple_transliterators = [
        (
            "spaces",
            "Replace various space characters with plain whitespace.",
            dataset.spaces,
        ),
        (
            "radicals",
            "Replace Kangxi radicals with equivalent CJK ideographs.",
            dataset.radicals,
        ),
        (
            "mathematical_alphanumerics",
            "Replace mathematical alphanumeric symbols with plain characters.",
            dataset.mathematical_alphanumerics,
        ),
        (
            "ideographic_annotations",
            "Replace ideographic annotation marks used in traditional translation.",
            dataset.ideographic_annotations,
        ),
        (
            "kanji_old_new",
            "Replace old-style kanji with modern equivalents.",
            dataset.kanji_old_new,
        ),
    ]

    for name, description, data in simple_transliterators:
        output = render_simple_transliterator(name, description, data)
        filename = f"{snake_case(name)}.py"
        filepath = dest_root / filename
        print(f"Generating: {filename}")
        filepath.write_text(output, encoding="utf-8")

    # Generate hyphens data
    output = render_hyphens_transliterator_data(dataset.hyphens)
    filepath = dest_root / "hyphens_data.py"
    print("Generating: hyphens_data.py")
    filepath.write_text(output, encoding="utf-8")

    # Generate IVS/SVS base data
    output = render_ivs_svs_base_transliterator_data(dataset.ivs_svs_base)
    filepath = dest_root / "ivs_svs_base_data.py"
    print("Generating: ivs_svs_base_data.py")
    filepath.write_text(output, encoding="utf-8")

    # Generate combined transliterator
    output = render_combined_transliterator(dataset.combined)
    filepath = dest_root / "combined.py"
    print("Generating: combined.py")
    filepath.write_text(output, encoding="utf-8")

    # Generate circled or squared transliterator
    output = render_circled_or_squared_transliterator(dataset.circled_or_squared)
    filepath = dest_root / "circled_or_squared.py"
    print("Generating: circled_or_squared.py")
    filepath.write_text(output, encoding="utf-8")

    # Generate roman numerals transliterator
    output = render_roman_numerals_transliterator(dataset.roman_numerals)
    filepath = dest_root / "roman_numerals.py"
    print("Generating: roman_numerals.py")
    filepath.write_text(output, encoding="utf-8")

    print("Code generation complete!")
