"""Code emitters for generating Python transliterator modules."""

from .models import CircledOrSquaredRecord, HyphensRecord, IvsSvsBaseRecord, RomanNumeralsRecord

__all__ = [
    "render_simple_transliterator",
    "render_hyphens_transliterator_data",
    "render_ivs_svs_base_transliterator_data",
    "build_compressed_ivs_svs_base_records",
    "render_combined_transliterator",
    "render_circled_or_squared_transliterator",
    "render_roman_numerals_transliterator",
]


def unicode_escape_string(s: str) -> str:
    """Convert a string to Unicode escape sequences."""
    return "".join(f"\\u{ord(c):04x}" for c in s)


def python_repr_dict(data: dict[str, str]) -> str:
    """Generate Python dict literal representation with proper string escaping."""
    if not data:
        return "{}"

    items: list[str] = []
    for key, value in data.items():
        # Use repr() for proper Python string literal generation
        key_repr = f'"{key.encode("unicode_escape").decode("ascii")}"'
        value_repr = f'"{value.encode("unicode_escape").decode("ascii")}"'
        items.append(f"    {key_repr}: {value_repr}")

    return "{\n" + ",\n".join(items) + ",\n}"


def python_repr_multi_char_dict(data: dict[str, list[str]]) -> str:
    """Generate Python dict literal representation for multi-character mappings."""
    if not data:
        return "{}"

    items: list[str] = []
    for key, value_list in data.items():
        # Use repr() for proper Python string literal generation
        key_repr = f'"{key.encode("unicode_escape").decode("ascii")}"'
        value_repr = repr(value_list)
        items.append(f"    {key_repr}: {value_repr}")

    return "{\n" + ",\n".join(items) + ",\n}"


def render_simple_transliterator(module_name: str, description: str, data: list[tuple[str, str]]) -> str:
    """Render a simple transliterator module.

    :param module_name: Name for the transliterator (e.g. "spaces")
    :param description: Description of what the transliterator does
    :param data: List of (from_char, to_char) tuples
    :returns: Generated Python module code
    """
    # Convert data to dict format for easier lookup
    mapping_dict = dict(data)
    mapping_repr = python_repr_dict(mapping_dict)

    # Convert module name to proper Python identifiers
    constant_name = module_name.upper() + "_MAPPINGS"

    code = f'''"""Auto-generated {module_name} transliterator.

{description}
"""
from collections.abc import Iterable
from typing import Any

from ..chars import Char

__all__ = ["Transliterator"]

# Generated mapping data
{constant_name} = {mapping_repr}


class Transliterator:
    """Transliterator for {module_name}.

    {description}
    """

    def __init__(self, **_options: Any) -> None:
        """Initialize the transliterator with options.

        :param _options: Configuration options (currently unused)
        """

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """{description}"""
        offset = 0

        for char in input_chars:
            replacement = {constant_name}.get(char.c)
            if replacement is not None:
                yield Char(c=replacement, offset=offset, source=char)
                offset += len(replacement)
            else:
                yield char.with_offset(offset)
                offset += len(char.c)

'''

    return code


def render_hyphens_transliterator_data(data: list[tuple[str, HyphensRecord]]) -> str:
    """Render hyphen transliterator data module.

    :param data: List of (code_char, HyphensRecord) tuples
    :returns: Generated Python module code for hyphen data
    """
    # Build mapping entries
    mapping_entries: list[str] = []
    for code_char, record in data:
        code_repr = repr(code_char)

        # Build HyphensRecord constructor call
        fields: list[str] = []
        if record.ascii is not None:
            fields.append(f"ascii={repr(record.ascii)}")
        if record.jisx0201 is not None:
            fields.append(f"jisx0201={repr(record.jisx0201)}")
        if record.jisx0208_90 is not None:
            fields.append(f"jisx0208_90={repr(record.jisx0208_90)}")
        if record.jisx0208_90_windows is not None:
            fields.append(f"jisx0208_90_windows={repr(record.jisx0208_90_windows)}")
        if record.jisx0208_verbatim is not None:
            fields.append(f"jisx0208_verbatim={repr(record.jisx0208_verbatim)}")

        record_repr = f"HyphensRecord({', '.join(fields)})"
        mapping_entries.append(f"    {code_repr}: {record_repr}")

    mappings_repr = "{\n" + ",\n".join(mapping_entries) + ",\n}"

    code = f'''"""Auto-generated hyphen transliterator data."""

from dataclasses import dataclass

__all__ = ["HyphensRecord", "HYPHENS_MAPPINGS"]


@dataclass
class HyphensRecord:
    """Record for hyphen transliteration data."""

    ascii: str | None = None
    jisx0201: str | None = None
    jisx0208_90: str | None = None
    jisx0208_90_windows: str | None = None
    jisx0208_verbatim: str | None = None


# Generated mapping data
HYPHENS_MAPPINGS = {mappings_repr}
'''

    return code


def build_compressed_ivs_svs_base_records(data: list[IvsSvsBaseRecord]) -> str:
    """Build compressed string representation of IVS/SVS base records.

    :param data: List of IvsSvsBaseRecord objects
    :returns: Compressed string with null-byte separators
    """
    parts: list[str] = []
    for record in data:
        parts.extend(
            [
                record.ivs,
                record.svs or "",
                record.base90 or "",
                record.base2004 or "",
            ]
        )
    return "\0".join(parts)


def render_ivs_svs_base_transliterator_data(data: list[IvsSvsBaseRecord]) -> str:
    """Render IVS/SVS base transliterator data module.

    :param data: List of IvsSvsBaseRecord objects
    :returns: Generated Python module code for IVS/SVS base data
    """
    compressed_data = build_compressed_ivs_svs_base_records(data)
    compressed_repr = repr(compressed_data)
    records_count = len(data)

    code = f'''"""Auto-generated IVS/SVS base transliterator data."""

from dataclasses import dataclass
from typing import Literal

__all__ = [
    "IvsSvsBaseRecord",
    "expand_compressed_data",
    "get_ivs_svs_mappings",
    "get_base_to_variants_mappings",
    "get_variants_to_base_mappings",
]


@dataclass
class IvsSvsBaseRecord:
    """Record for IVS/SVS base transliteration data."""

    ivs: str
    svs: str | None = None
    base90: str | None = None
    base2004: str | None = None


# Compressed data table - 4 strings per record: [ivs, svs, base90, base2004, ...]
COMPRESSED_DATA = {compressed_repr}
RECORDS_COUNT = {records_count}


def expand_compressed_data() -> dict[str, IvsSvsBaseRecord]:
    """Expand compressed data into a mapping dictionary.

    :returns: Dictionary mapping IVS strings to IvsSvsBaseRecord objects
    """
    mappings: dict[str, IvsSvsBaseRecord] = {{}}

    # Split by null bytes to get all fields
    fields = COMPRESSED_DATA.split("\\0")

    # Process 4 fields at a time (ivs, svs, base90, base2004)
    for i in range(0, len(fields), 4):
        if i + 3 < len(fields):
            ivs = fields[i]
            svs = fields[i + 1] if fields[i + 1] else None
            base90 = fields[i + 2] if fields[i + 2] else None
            base2004 = fields[i + 3] if fields[i + 3] else None

            if ivs:  # Only add if ivs is not empty
                mappings[ivs] = IvsSvsBaseRecord(
                    ivs=ivs,
                    svs=svs,
                    base90=base90,
                    base2004=base2004,
                )

    return mappings


# Lazy-loaded mappings
Charset = Literal["unijis_2004", "unijis_90"]
_mappings_cache: dict[str, IvsSvsBaseRecord] | None = None
_base_to_variants_cache: dict[str, dict[str, IvsSvsBaseRecord]] | None = None
_variants_to_base_cache: dict[str, IvsSvsBaseRecord] | None = None


def get_ivs_svs_mappings() -> dict[str, IvsSvsBaseRecord]:
    """Get the IVS/SVS mappings dictionary, loading it if necessary.

    :returns: Dictionary mapping IVS strings to IvsSvsBaseRecord objects
    """
    global _mappings_cache
    if _mappings_cache is None:
        _mappings_cache = expand_compressed_data()
    return _mappings_cache


def populate_lookup_tables() -> None:
    """Build optimized lookup tables for base-to-variants and variants-to-base mappings.

    :returns: Tuple of (base_to_variants, variants_to_base) dictionaries
    """
    global _base_to_variants_cache, _variants_to_base_cache
    if _base_to_variants_cache is not None and _variants_to_base_cache is not None:
        return

    mappings = get_ivs_svs_mappings()

    # For base->IVS/SVS lookup (used in "ivs-or-svs" mode)
    base_to_variants_2004: dict[str, IvsSvsBaseRecord] = {{}}
    base_to_variants_90: dict[str, IvsSvsBaseRecord] = {{}}

    # For IVS/SVS->base lookup (used in "base" mode)
    variants_to_base: dict[str, IvsSvsBaseRecord] = {{}}

    for variant_seq, record in mappings.items():
        # Map base characters to their IVS/SVS variants
        if record.base2004 and record.base2004 not in base_to_variants_2004:
            base_to_variants_2004[record.base2004] = record

        if record.base90 and record.base90 not in base_to_variants_90:
            base_to_variants_90[record.base90] = record

        # Map IVS/SVS variants back to base characters
        variants_to_base[variant_seq] = record

    _base_to_variants_cache = {{
        "unijis_2004": base_to_variants_2004,
        "unijis_90": base_to_variants_90,
    }}
    _variants_to_base_cache = variants_to_base


def get_base_to_variants_mappings(charset: Charset = "unijis_2004") -> dict[str, IvsSvsBaseRecord]:
    """Get base character to variants mapping for the specified charset.

    :param charset: Either "unijis_2004" or "unijis_90"
    :returns: Dictionary mapping base characters to IvsSvsBaseRecord objects
    """
    global _base_to_variants_cache
    populate_lookup_tables()
    assert _base_to_variants_cache is not None
    return _base_to_variants_cache[charset]


def get_variants_to_base_mappings() -> dict[str, IvsSvsBaseRecord]:
    """Get variants to base character mapping.

    :returns: Dictionary mapping variant sequences to IvsSvsBaseRecord objects
    """
    global _variants_to_base_cache
    populate_lookup_tables()
    assert _variants_to_base_cache is not None
    return _variants_to_base_cache
'''

    return code


def render_combined_transliterator(data: list[tuple[str, list[str]]]) -> str:
    """Render a combined character transliterator module.

    :param data: List of (combined_char, char_list) tuples
    :returns: Generated Python module code
    """
    # Convert data to dict format for easier lookup
    mapping_dict = dict(data)
    mapping_repr = python_repr_multi_char_dict(mapping_dict)

    code = f'''"""Auto-generated combined character transliterator.

Replace each combined character with its corresponding individual characters.
"""
from collections.abc import Iterable
from typing import Any

from ..chars import Char

__all__ = ["Transliterator"]

# Generated mapping data
COMBINED_MAPPINGS = {mapping_repr}


class Transliterator:
    """Transliterator for combined characters.

    Replace each combined character with its corresponding individual characters.
    """

    def __init__(self, **_options: Any) -> None:
        """Initialize the transliterator with options.

        :param _options: Configuration options (currently unused)
        """

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Replace each combined character with its corresponding individual characters."""
        offset = 0
        for char in input_chars:
            replacement_list = COMBINED_MAPPINGS.get(char.c)
            if replacement_list is not None:
                for replacement_char in replacement_list:
                    yield Char(c=replacement_char, offset=offset, source=char)
                    offset += len(replacement_char)
            else:
                yield char.with_offset(offset)
                offset += len(char.c)

'''

    return code


def render_circled_or_squared_transliterator(data: list[tuple[str, CircledOrSquaredRecord]]) -> str:
    """Render a circled or squared character transliterator module.

    :param data: List of (char, CircledOrSquaredRecord) tuples
    :returns: Generated Python module code
    """
    # Build mapping entries
    mapping_entries: list[str] = []
    for char, record in data:
        char_repr = f'"{char.encode("unicode_escape").decode("ascii")}"'
        # Convert type to single character abbreviation
        type_abbrev = "c" if record.type == "circle" else "s"
        record_repr = f'("{record.rendering}", "{type_abbrev}", {record.emoji})'
        mapping_entries.append(f"    {char_repr}: {record_repr}")

    mappings_repr = "{\n" + ",\n".join(mapping_entries) + ",\n}"

    code = f'''"""Auto-generated circled or squared character transliterator.

Replace circled or squared characters with their corresponding templates.
"""
from collections.abc import Iterable
from typing import Literal

from ..chars import Char

__all__ = ["Transliterator"]

# Generated mapping data: char -> [rendering, type_abbrev, is_emoji]
CIRCLED_OR_SQUARED_MAPPINGS: dict[str, tuple[str, Literal["c", "s"], bool]] = {mappings_repr}


class Transliterator:
    """Transliterator for circled or squared characters.

    Replace circled or squared characters with their corresponding templates.
    """

    templates: dict[Literal["c", "s"], str]
    """Templates for circle and square formatting."""

    include_emojis: bool
    """Whether to include emojis in the transliteration."""

    def __init__(
        self, *,
        templates: dict[Literal["circle", "square"], str] | None = None,
        include_emojis: bool = False,
    ) -> None:
        """Initialize the transliterator with options.

        :param options: Configuration options
        """
        self.include_emojis = include_emojis
        c = templates.get("circle") if templates else None
        s = templates.get("square") if templates else None
        self.templates = {{
            "c": "(?)" if c is None else c,
            "s": "[?]" if s is None else s,
        }}

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Replace circled or squared characters with their corresponding templates."""
        offset = 0
        for char in input_chars:
            mapping = CIRCLED_OR_SQUARED_MAPPINGS.get(char.c)
            if mapping is not None and (not mapping[2] or self.include_emojis):
                rendering, type_abbrev, _ = mapping
                template = self.templates[type_abbrev]
                replacement = template.replace("?", rendering)
                for replacement_char in replacement:
                    yield Char(c=replacement_char, offset=offset, source=char)
                    offset += len(replacement_char)
            else:
                yield char.with_offset(offset)
                offset += len(char.c)
'''

    return code


def render_roman_numerals_transliterator(data: list[tuple[str, RomanNumeralsRecord]]) -> str:
    """Render a roman numerals transliterator module.

    :param data: List of (upper_char, RomanNumeralsRecord) tuples
    :returns: Generated Python module code
    """
    # Build mapping dicts for upper and lower to decomposed forms
    upper_to_decomposed: dict[str, list[str]] = {}
    lower_to_decomposed: dict[str, list[str]] = {}

    for _, record in data:
        upper_to_decomposed[record.upper] = record.decomposed_upper
        lower_to_decomposed[record.lower] = record.decomposed_lower

    # Combine both mappings
    all_mappings = {**upper_to_decomposed, **lower_to_decomposed}
    mapping_repr = python_repr_multi_char_dict(all_mappings)

    code = f'''"""Auto-generated roman numerals transliterator.

Replace roman numeral characters with their ASCII letter equivalents.
"""
from collections.abc import Iterable
from typing import Any

from ..chars import Char

__all__ = ["Transliterator"]

# Generated mapping data
ROMAN_NUMERAL_MAPPINGS = {mapping_repr}


class Transliterator:
    """Transliterator for roman numerals.

    Replace roman numeral characters with their ASCII letter equivalents.
    """

    def __init__(self, **_options: Any) -> None:
        """Initialize the transliterator with options.

        :param _options: Configuration options (currently unused)
        """

    def __call__(self, input_chars: Iterable[Char]) -> Iterable[Char]:
        """Replace each roman numeral with its ASCII letter equivalent."""
        offset = 0
        for char in input_chars:
            replacement_list = ROMAN_NUMERAL_MAPPINGS.get(char.c)
            if replacement_list is not None:
                for replacement_char in replacement_list:
                    yield Char(c=replacement_char, offset=offset, source=char)
                    offset += len(replacement_char)
            else:
                yield char.with_offset(offset)
                offset += len(char.c)
'''

    return code
