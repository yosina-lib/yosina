"""JSON data parsers for transliteration datasets."""

import json
import re
from typing import Any

from .models import CircledOrSquaredRecord, HyphensRecord, IvsSvsBaseRecord, RomanNumeralsRecord

__all__ = [
    "parse_simple_transliteration_records",
    "parse_hyphen_transliteration_records",
    "parse_ivs_svs_base_transliteration_records",
    "parse_kanji_old_new_transliteration_records",
    "parse_combined_transliteration_records",
    "parse_circled_or_squared_transliteration_records",
    "parse_roman_numerals_records",
]


def parse_unicode_codepoint(cp_repr: str) -> int:
    """Parse a Unicode codepoint representation like 'U+1234'."""
    match = re.match(r"^U\+([0-9A-Fa-f]+)", cp_repr)
    if not match:
        raise ValueError(f"invalid Unicode codepoint representation: {cp_repr}")
    return int(match.group(1), 16)


def codepoint_to_string(codepoint: int) -> str:
    """Convert a Unicode codepoint to a string."""
    try:
        return chr(codepoint)
    except ValueError as e:
        raise ValueError(f"invalid Unicode codepoint: {codepoint}") from e


def codepoints_to_string(codepoints: list[int]) -> str:
    """Convert a list of Unicode codepoints to a string."""
    try:
        return "".join(chr(cp) for cp in codepoints)
    except ValueError as e:
        raise ValueError(f"invalid Unicode codepoint in list: {codepoints}") from e


def parse_simple_transliteration_records(data: str) -> list[tuple[str, str]]:
    """Parse simple transliteration records from JSON data.

    :param data: JSON string containing codepoint mappings
    :returns: List of (from_char, to_char) tuples
    """
    mapping: dict[str, str | None] = json.loads(data)

    result: list[tuple[str, str]] = []
    for key, value in mapping.items():
        from_codepoint = parse_unicode_codepoint(key)
        from_char = codepoint_to_string(from_codepoint)

        if value is not None:
            to_codepoint = parse_unicode_codepoint(value)
            to_char = codepoint_to_string(to_codepoint)
        else:
            to_char = ""

        result.append((from_char, to_char))

    return result


def parse_hyphen_transliteration_records(data: str) -> list[tuple[str, HyphensRecord]]:
    """Parse hyphen transliteration records from JSON data.

    :param data: JSON string containing hyphen mapping data
    :returns: List of (code_char, HyphensRecord) tuples
    """
    records: list[dict[str, Any]] = json.loads(data)

    result: list[tuple[str, HyphensRecord]] = []
    for record in records:
        code_codepoint = parse_unicode_codepoint(record["code"])
        code_char = codepoint_to_string(code_codepoint)

        # Parse ASCII field
        ascii_val = None
        if record.get("ascii"):
            ascii_codepoints = [parse_unicode_codepoint(s) for s in record["ascii"]]
            ascii_val = codepoints_to_string(ascii_codepoints)

        # Parse JISX0201 field
        jisx0201_val = None
        if record.get("jisx0201"):
            jisx0201_codepoints = [parse_unicode_codepoint(s) for s in record["jisx0201"]]
            jisx0201_val = codepoints_to_string(jisx0201_codepoints)

        # Parse JISX0208-1978 field
        jisx0208_90_val = None
        if record.get("jisx0208-1978"):
            jisx0208_codepoints = [parse_unicode_codepoint(s) for s in record["jisx0208-1978"]]
            jisx0208_90_val = codepoints_to_string(jisx0208_codepoints)

        # Parse JISX0208-1978-windows field
        jisx0208_90_windows_val = None
        if record.get("jisx0208-1978-windows"):
            windows_codepoints = [parse_unicode_codepoint(s) for s in record["jisx0208-1978-windows"]]
            jisx0208_90_windows_val = codepoints_to_string(windows_codepoints)

        # Parse JISX0208-verbatim field
        jisx0208_verbatim_val = None
        if record.get("jisx0208-verbatim"):
            verbatim_codepoint = parse_unicode_codepoint(record["jisx0208-verbatim"])
            jisx0208_verbatim_val = codepoint_to_string(verbatim_codepoint)

        hyphen_record = HyphensRecord(
            ascii=ascii_val,
            jisx0201=jisx0201_val,
            jisx0208_90=jisx0208_90_val,
            jisx0208_90_windows=jisx0208_90_windows_val,
            jisx0208_verbatim=jisx0208_verbatim_val,
        )

        result.append((code_char, hyphen_record))

    return result


def parse_ivs_svs_base_transliteration_records(data: str) -> list[IvsSvsBaseRecord]:
    """Parse IVS/SVS base transliteration records from JSON data.

    :param data: JSON string containing IVS/SVS mapping data
    :returns: List of IvsSvsBaseRecord objects
    """
    records: list[dict[str, Any]] = json.loads(data)

    result: list[IvsSvsBaseRecord] = []
    for record in records:
        # Parse IVS field (required)
        ivs_codepoints = [parse_unicode_codepoint(s) for s in record["ivs"]]
        ivs = codepoints_to_string(ivs_codepoints)

        # Parse SVS field (optional)
        svs = None
        if record.get("svs"):
            svs_codepoints = [parse_unicode_codepoint(s) for s in record["svs"]]
            svs = codepoints_to_string(svs_codepoints)

        # Parse base90 field (optional)
        base90 = None
        if record.get("base90"):
            base90_codepoint = parse_unicode_codepoint(record["base90"])
            base90 = codepoint_to_string(base90_codepoint)

        # Parse base2004 field (optional)
        base2004 = None
        if record.get("base2004"):
            base2004_codepoint = parse_unicode_codepoint(record["base2004"])
            base2004 = codepoint_to_string(base2004_codepoint)

        ivs_svs_record = IvsSvsBaseRecord(
            ivs=ivs,
            svs=svs,
            base90=base90,
            base2004=base2004,
        )

        result.append(ivs_svs_record)

    return result


def parse_kanji_old_new_transliteration_records(data: str) -> list[tuple[str, str]]:
    """Parse kanji old-new transliteration records from JSON data.

    :param data: JSON string containing kanji mapping data
    :returns: List of (old_char, new_char) tuples
    """
    records: list[tuple[dict[str, Any], dict[str, Any]]] = json.loads(data)

    result: list[tuple[str, str]] = []
    for old_record, new_record in records:
        # Parse old kanji
        old_codepoints = [parse_unicode_codepoint(s) for s in old_record["ivs"]]
        old_char = codepoints_to_string(old_codepoints)

        # Parse new kanji
        new_codepoints = [parse_unicode_codepoint(s) for s in new_record["ivs"]]
        new_char = codepoints_to_string(new_codepoints)

        result.append((old_char, new_char))

    return result


def parse_combined_transliteration_records(data: str) -> list[tuple[str, list[str]]]:
    """Parse combined character transliteration records from JSON data.

    :param data: JSON string containing combined character mapping data
    :returns: List of (combined_char, char_list) tuples
    """
    mapping: dict[str, str] = json.loads(data)

    result: list[tuple[str, list[str]]] = []
    for key, value in mapping.items():
        from_codepoint = parse_unicode_codepoint(key)
        from_char = codepoint_to_string(from_codepoint)

        # Split the value into individual characters
        char_list = list(value)

        result.append((from_char, char_list))

    return result


def parse_circled_or_squared_transliteration_records(data: str) -> list[tuple[str, CircledOrSquaredRecord]]:
    """Parse circled or squared character transliteration records from JSON data.

    :param data: JSON string containing circled/squared character mapping data
    :returns: List of (char, CircledOrSquaredRecord) tuples
    """
    mapping: dict[str, dict[str, Any]] = json.loads(data)

    result: list[tuple[str, CircledOrSquaredRecord]] = []
    for key, record_data in mapping.items():
        from_codepoint = parse_unicode_codepoint(key)
        from_char = codepoint_to_string(from_codepoint)

        record = CircledOrSquaredRecord(
            rendering=record_data["rendering"], type=record_data["type"], emoji=record_data["emoji"]
        )

        result.append((from_char, record))

    return result


def parse_roman_numerals_records(data: str) -> list[tuple[str, RomanNumeralsRecord]]:
    """Parse roman numerals transliteration records from JSON data.

    :param data: JSON string containing roman numerals mapping data
    :returns: List of (upper_char, RomanNumeralsRecord) tuples paired by upper char
    """
    records: list[dict[str, Any]] = json.loads(data)

    result: list[tuple[str, RomanNumeralsRecord]] = []
    for record in records:
        # Parse upper and lower codes
        upper_codepoint = parse_unicode_codepoint(record["codes"]["upper"])
        upper_char = codepoint_to_string(upper_codepoint)

        lower_codepoint = parse_unicode_codepoint(record["codes"]["lower"])
        lower_char = codepoint_to_string(lower_codepoint)

        # Parse decomposed forms
        decomposed_upper = [codepoint_to_string(parse_unicode_codepoint(cp)) for cp in record["decomposed"]["upper"]]
        decomposed_lower = [codepoint_to_string(parse_unicode_codepoint(cp)) for cp in record["decomposed"]["lower"]]

        roman_record = RomanNumeralsRecord(
            value=record["value"],
            upper=upper_char,
            lower=lower_char,
            decomposed_upper=decomposed_upper,
            decomposed_lower=decomposed_lower,
        )

        result.append((upper_char, roman_record))

    return result
