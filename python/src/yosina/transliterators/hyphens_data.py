"""Auto-generated hyphen transliterator data."""

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
HYPHENS_MAPPINGS = {
    '-': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='−', jisx0208_90_windows='−'),
    '|': HyphensRecord(ascii='|', jisx0201='|', jisx0208_90='｜', jisx0208_90_windows='｜'),
    '~': HyphensRecord(ascii='~', jisx0201='~', jisx0208_90='〜', jisx0208_90_windows='～'),
    '¢': HyphensRecord(jisx0208_90='¢', jisx0208_90_windows='￠', jisx0208_verbatim='¢'),
    '£': HyphensRecord(jisx0208_90='£', jisx0208_90_windows='￡', jisx0208_verbatim='£'),
    '¦': HyphensRecord(ascii='|', jisx0201='|', jisx0208_90='｜', jisx0208_90_windows='｜', jisx0208_verbatim='¦'),
    '˗': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='−', jisx0208_90_windows='－'),
    '‐': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='‐', jisx0208_90_windows='‐', jisx0208_verbatim='‐'),
    '‑': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='‐', jisx0208_90_windows='‐'),
    '‒': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='―', jisx0208_90_windows='―'),
    '–': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='―', jisx0208_90_windows='―', jisx0208_verbatim='–'),
    '—': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='—', jisx0208_90_windows='―', jisx0208_verbatim='—'),
    '―': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='―', jisx0208_90_windows='―', jisx0208_verbatim='―'),
    '‖': HyphensRecord(jisx0208_90='‖', jisx0208_90_windows='∥', jisx0208_verbatim='‖'),
    '′': HyphensRecord(ascii="'", jisx0201="'", jisx0208_90='′', jisx0208_90_windows='′', jisx0208_verbatim='′'),
    '″': HyphensRecord(ascii='"', jisx0201='"', jisx0208_90='″', jisx0208_90_windows='″', jisx0208_verbatim='″'),
    '‾': HyphensRecord(jisx0201='~', jisx0208_90='￣', jisx0208_90_windows='￣', jisx0208_verbatim='‽'),
    '⁃': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='‐', jisx0208_90_windows='‐'),
    '⁓': HyphensRecord(ascii='~', jisx0201='~', jisx0208_90='〜', jisx0208_90_windows='〜'),
    '−': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='−', jisx0208_90_windows='－', jisx0208_verbatim='−'),
    '∥': HyphensRecord(jisx0208_90='‖', jisx0208_90_windows='∥', jisx0208_verbatim='∥'),
    '∼': HyphensRecord(ascii='~', jisx0201='~', jisx0208_90='〜', jisx0208_90_windows='～'),
    '∽': HyphensRecord(ascii='~', jisx0201='~', jisx0208_90='〜', jisx0208_90_windows='～'),
    '─': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='―', jisx0208_90_windows='―', jisx0208_verbatim='─'),
    '━': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='―', jisx0208_90_windows='―', jisx0208_verbatim='━'),
    '│': HyphensRecord(ascii='|', jisx0201='|', jisx0208_90='｜', jisx0208_90_windows='｜', jisx0208_verbatim='│'),
    '➖': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='−', jisx0208_90_windows='－'),
    '⧿': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='‐', jisx0208_90_windows='－'),
    '⸺': HyphensRecord(ascii='--', jisx0201='--', jisx0208_90='——', jisx0208_90_windows='――'),
    '⸻': HyphensRecord(ascii='---', jisx0201='---', jisx0208_90='———', jisx0208_90_windows='―――'),
    '〜': HyphensRecord(ascii='~', jisx0201='~', jisx0208_90='〜', jisx0208_90_windows='～', jisx0208_verbatim='〜'),
    '゠': HyphensRecord(ascii='=', jisx0201='=', jisx0208_90='＝', jisx0208_90_windows='＝', jisx0208_verbatim='゠'),
    '・': HyphensRecord(jisx0201='･', jisx0208_90='・', jisx0208_90_windows='・', jisx0208_verbatim='・'),
    'ー': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='ー', jisx0208_90_windows='ー', jisx0208_verbatim='ー'),
    '︱': HyphensRecord(ascii='|', jisx0201='|', jisx0208_90='｜', jisx0208_90_windows='｜'),
    '﹘': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='‐', jisx0208_90_windows='‐'),
    '﹣': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='‐', jisx0208_90_windows='‐'),
    '－': HyphensRecord(ascii='-', jisx0201='-', jisx0208_90='−', jisx0208_90_windows='－'),
    '｜': HyphensRecord(ascii='|', jisx0201='|', jisx0208_90='｜', jisx0208_90_windows='｜', jisx0208_verbatim='｜'),
    '～': HyphensRecord(ascii='~', jisx0201='~', jisx0208_90='〜', jisx0208_90_windows='～'),
    '￤': HyphensRecord(ascii='|', jisx0201='|', jisx0208_90='｜', jisx0208_90_windows='￤', jisx0208_verbatim='￤'),
    'ｰ': HyphensRecord(ascii='-', jisx0201='ｰ', jisx0208_90='ー', jisx0208_90_windows='ー'),
    '￨': HyphensRecord(ascii='|', jisx0201='|', jisx0208_90='｜', jisx0208_90_windows='｜'),
}
