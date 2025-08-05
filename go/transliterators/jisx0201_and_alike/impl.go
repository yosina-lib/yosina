package jisx0201_and_alike

import (
	"sync"

	yosina "github.com/yosina-lib/yosina/go"
	"github.com/yosina-lib/yosina/go/transliterators/internal"
)

var jisx0201GLTable = map[rune]rune{
	'\u3000': '\u0020', // 　 -> space
	'\uff01': '\u0021', // ！ -> !
	'\uff02': '\u0022', // ＂ -> "
	'\uff03': '\u0023', // ＃ -> #
	'\uff04': '\u0024', // ＄ -> $
	'\uff05': '\u0025', // ％ -> %
	'\uff06': '\u0026', // ＆ -> &
	'\uff07': '\u0027', // ＇ -> '
	'\uff08': '\u0028', // （ -> (
	'\uff09': '\u0029', // ） -> )
	'\uff0a': '\u002a', // ＊ -> *
	'\uff0b': '\u002b', // ＋ -> +
	'\uff0c': '\u002c', // ， -> ,
	'\uff0d': '\u002d', // － -> -
	'\uff0e': '\u002e', // ． -> .
	'\uff0f': '\u002f', // ／ -> /
	'\uff10': '\u0030', // ０ -> 0
	'\uff11': '\u0031', // １ -> 1
	'\uff12': '\u0032', // ２ -> 2
	'\uff13': '\u0033', // ３ -> 3
	'\uff14': '\u0034', // ４ -> 4
	'\uff15': '\u0035', // ５ -> 5
	'\uff16': '\u0036', // ６ -> 6
	'\uff17': '\u0037', // ７ -> 7
	'\uff18': '\u0038', // ８ -> 8
	'\uff19': '\u0039', // ９ -> 9
	'\uff1a': '\u003a', // ： -> :
	'\uff1b': '\u003b', // ； -> ;
	'\uff1c': '\u003c', // ＜ -> <
	'\uff1d': '\u003d', // ＝ -> =
	'\uff1e': '\u003e', // ＞ -> >
	'\uff1f': '\u003f', // ？ -> ?
	'\uff20': '\u0040', // ＠ -> @
	'\uff21': '\u0041', // Ａ -> A
	'\uff22': '\u0042', // Ｂ -> B
	'\uff23': '\u0043', // Ｃ -> C
	'\uff24': '\u0044', // Ｄ -> D
	'\uff25': '\u0045', // Ｅ -> E
	'\uff26': '\u0046', // Ｆ -> F
	'\uff27': '\u0047', // Ｇ -> G
	'\uff28': '\u0048', // Ｈ -> H
	'\uff29': '\u0049', // Ｉ -> I
	'\uff2a': '\u004a', // Ｊ -> J
	'\uff2b': '\u004b', // Ｋ -> K
	'\uff2c': '\u004c', // Ｌ -> L
	'\uff2d': '\u004d', // Ｍ -> M
	'\uff2e': '\u004e', // Ｎ -> N
	'\uff2f': '\u004f', // Ｏ -> O
	'\uff30': '\u0050', // Ｐ -> P
	'\uff31': '\u0051', // Ｑ -> Q
	'\uff32': '\u0052', // Ｒ -> R
	'\uff33': '\u0053', // Ｓ -> S
	'\uff34': '\u0054', // Ｔ -> T
	'\uff35': '\u0055', // Ｕ -> U
	'\uff36': '\u0056', // Ｖ -> V
	'\uff37': '\u0057', // Ｗ -> W
	'\uff38': '\u0058', // Ｘ -> X
	'\uff39': '\u0059', // Ｙ -> Y
	'\uff3a': '\u005a', // Ｚ -> Z
	'\uff3b': '\u005b', // ［ -> [
	'\uff3d': '\u005d', // ］ -> ]
	'\uff3e': '\u005e', // ＾ -> ^
	'\uff3f': '\u005f', // ＿ -> _
	'\uff40': '\u0060', // ｀ -> `
	'\uff41': '\u0061', // ａ -> a
	'\uff42': '\u0062', // ｂ -> b
	'\uff43': '\u0063', // ｃ -> c
	'\uff44': '\u0064', // ｄ -> d
	'\uff45': '\u0065', // ｅ -> e
	'\uff46': '\u0066', // ｆ -> f
	'\uff47': '\u0067', // ｇ -> g
	'\uff48': '\u0068', // ｈ -> h
	'\uff49': '\u0069', // ｉ -> i
	'\uff4a': '\u006a', // ｊ -> j
	'\uff4b': '\u006b', // ｋ -> k
	'\uff4c': '\u006c', // ｌ -> l
	'\uff4d': '\u006d', // ｍ -> m
	'\uff4e': '\u006e', // ｎ -> n
	'\uff4f': '\u006f', // ｏ -> o
	'\uff50': '\u0070', // ｐ -> p
	'\uff51': '\u0071', // ｑ -> q
	'\uff52': '\u0072', // ｒ -> r
	'\uff53': '\u0073', // ｓ -> s
	'\uff54': '\u0074', // ｔ -> t
	'\uff55': '\u0075', // ｕ -> u
	'\uff56': '\u0076', // ｖ -> v
	'\uff57': '\u0077', // ｗ -> w
	'\uff58': '\u0078', // ｘ -> x
	'\uff59': '\u0079', // ｙ -> y
	'\uff5a': '\u007a', // ｚ -> z
	'\uff5b': '\u007b', // ｛ -> {
	'\uff5c': '\u007c', // ｜ -> |
	'\uff5d': '\u007d', // ｝ -> }
}

// generateGRTable generates the GR table for JIS X 0201 (katakana fullwidth to halfwidth)
func generateGRTable() map[rune]rune {
	result := make(map[rune]rune)

	// Add punctuation marks
	result['\u3002'] = '\uff61' // 。 -> ｡
	result['\u300c'] = '\uff62' // 「 -> ｢
	result['\u300d'] = '\uff63' // 」 -> ｣
	result['\u3001'] = '\uff64' // 、 -> ､
	result['\u30fb'] = '\uff65' // ・ -> ･
	result['\u30fc'] = '\uff70' // ー -> ｰ
	result['\u309b'] = '\uff9e' // ゛ -> ﾞ
	result['\u309c'] = '\uff9f' // ゜-> ﾟ

	// Add katakana mappings from main table
	for _, entry := range internal.HiraganaKatakanaTable {
		if entry.Halfwidth >= 0 {
			result[entry.Katakana.Base] = entry.Halfwidth
		}
	}

	// Add small kana mappings
	for _, entry := range internal.HiraganaKatakanaSmallTable {
		if entry.Halfwidth >= 0 {
			result[entry.Katakana] = entry.Halfwidth
		}
	}

	return result
}

// generateVoicedLettersTable generates the voiced letters table for JIS X 0201
func generateVoicedLettersTable() map[rune][2]rune {
	result := make(map[rune][2]rune)

	for _, entry := range internal.HiraganaKatakanaTable {
		if entry.Halfwidth >= 0 {
			if entry.Katakana.Voiced >= 0 {
				result[entry.Katakana.Voiced] = [2]rune{entry.Halfwidth, '\uff9e'}
			}
			if entry.Katakana.Semivoiced >= 0 {
				result[entry.Katakana.Semivoiced] = [2]rune{entry.Halfwidth, '\uff9f'}
			}
		}
	}

	return result
}

// generateHiraganaTable generates the hiragana to halfwidth table for JIS X 0201
func generateHiraganaTable() map[rune][2]rune {
	result := make(map[rune][2]rune)
	invalidValue := rune(0x7fffffff) // Using yosina.InvalidUnicodeValue

	// Add main table hiragana mappings
	for _, entry := range internal.HiraganaKatakanaTable {
		if entry.Hiragana != nil && entry.Halfwidth >= 0 {
			result[entry.Hiragana.Base] = [2]rune{entry.Halfwidth, invalidValue}
			if entry.Hiragana.Voiced >= 0 {
				result[entry.Hiragana.Voiced] = [2]rune{entry.Halfwidth, '\uff9e'}
			}
			if entry.Hiragana.Semivoiced >= 0 {
				result[entry.Hiragana.Semivoiced] = [2]rune{entry.Halfwidth, '\uff9f'}
			}
		}
	}

	// Add small kana mappings
	for _, entry := range internal.HiraganaKatakanaSmallTable {
		if entry.Halfwidth >= 0 {
			result[entry.Hiragana] = [2]rune{entry.Halfwidth, invalidValue}
		}
	}

	return result
}

// jisx0201GRTable is generated from the shared internal
var jisx0201GRTable = generateGRTable()

// voicedLettersTable is generated from the shared internal
var voicedLettersTable = generateVoicedLettersTable()

// hiraganaTable is generated from the shared internal
var hiraganaTable = generateHiraganaTable()

var specialPunctuationsTable = map[rune]rune{
	'\u30a0': '\u003d', // ゠ -> =
}

type Ternary int

const (
	TernaryUnknown Ternary = 0
	// TernaryFalse represents a false value in a ternary context.
	TernaryFalse = 2
	// TernaryTrue represents a true value in a ternary context.
	TernaryTrue = 3
)

func (t Ternary) IsValid() bool {
	return t&2 != 0
}

func (t Ternary) IsTrue() bool {
	return t == 3
}

func (t Ternary) UnwrapOr(v bool) bool {
	if t.IsValid() {
		return t.IsTrue()
	}
	return v
}

func (t Ternary) UnwrapOrElse(f func() bool) bool {
	if t.IsValid() {
		return t.IsTrue()
	}
	return f()
}

func TernaryOf(v bool) Ternary {
	if v {
		return TernaryTrue
	}
	return TernaryFalse
}

type Options struct {
	FullwidthToHalfwidth    bool
	ConvertGL               bool
	ConvertGR               bool
	ConvertUnsafeSpecials   Ternary
	ConvertHiraganas        bool
	CombineVoicedSoundMarks bool
	U005cAsYenSign          Ternary
	U005cAsBackslash        Ternary
	U007eAsFullwidthTilde   Ternary
	U007eAsWaveDash         Ternary
	U007eAsOverline         Ternary
	U007eAsFullwidthMacron  Ternary
	U00a5AsYenSign          Ternary
}

func Default() Options {
	return Options{
		FullwidthToHalfwidth:    true,
		ConvertGL:               true,
		ConvertGR:               true,
		ConvertUnsafeSpecials:   TernaryUnknown,
		ConvertHiraganas:        false,
		CombineVoicedSoundMarks: true,
		U005cAsYenSign:          TernaryUnknown,
		U005cAsBackslash:        TernaryUnknown,
		U007eAsFullwidthTilde:   TernaryUnknown,
		U007eAsWaveDash:         TernaryUnknown,
		U007eAsOverline:         TernaryUnknown,
		U007eAsFullwidthMacron:  TernaryUnknown,
		U00a5AsYenSign:          TernaryUnknown,
	}
}

func (o Options) WithFullwidthToHalfwidth(v bool) Options {
	o.FullwidthToHalfwidth = v
	return o
}

func (o Options) WithConvertGL(v bool) Options {
	o.ConvertGL = v
	return o
}

func (o Options) WithConvertGR(v bool) Options {
	o.ConvertGR = v
	return o
}

func (o Options) WithConvertUnsafeSpecials(v bool) Options {
	o.ConvertUnsafeSpecials = TernaryOf(v)
	return o
}

func (o Options) WithConvertHiraganas(v bool) Options {
	o.ConvertHiraganas = v
	return o
}

func (o Options) WithCombineVoicedSoundMarks(v bool) Options {
	o.CombineVoicedSoundMarks = v
	return o
}

func (o Options) WithU005cAsYenSign(v bool) Options {
	o.U005cAsYenSign = TernaryOf(v)
	return o
}

func (o Options) WithU005cAsBackslash(v bool) Options {
	o.U005cAsBackslash = TernaryOf(v)
	return o
}

func (o Options) WithU007eAsFullwidthTilde(v bool) Options {
	o.U007eAsFullwidthTilde = TernaryOf(v)
	return o
}

func (o Options) WithU007eAsWaveDash(v bool) Options {
	o.U007eAsWaveDash = TernaryOf(v)
	return o
}

func (o Options) WithU007eAsOverline(v bool) Options {
	o.U007eAsOverline = TernaryOf(v)
	return o
}

func (o Options) WithU007eAsFullwidthMacron(v bool) Options {
	o.U007eAsFullwidthMacron = TernaryOf(v)
	return o
}

func (o Options) WithU00a5AsYenSign(v bool) Options {
	o.U00a5AsYenSign = TernaryOf(v)
	return o
}

type fwdOptions struct {
	ConvertGL              bool
	ConvertGR              bool
	ConvertUnsafeSpecials  bool
	ConvertHiraganas       bool
	U005cAsYenSign         bool
	U005cAsBackslash       bool
	U007eAsFullwidthTilde  bool
	U007eAsWaveDash        bool
	U007eAsOverline        bool
	U007eAsFullwidthMacron bool
	U00a5AsYenSign         bool
}

type revOptions struct {
	ConvertGL               bool
	ConvertGR               bool
	ConvertUnsafeSpecials   bool
	CombineVoicedSoundMarks bool
	U005cAsYenSign          bool
	U005cAsBackslash        bool
	U007eAsFullwidthTilde   bool
	U007eAsWaveDash         bool
	U007eAsOverline         bool
	U007eAsFullwidthMacron  bool
	U00a5AsYenSign          bool
}

func (o *Options) fwdOptions() fwdOptions {
	return fwdOptions{
		ConvertGL:              o.ConvertGL,
		ConvertGR:              o.ConvertGR,
		ConvertUnsafeSpecials:  o.ConvertUnsafeSpecials.UnwrapOr(true),
		ConvertHiraganas:       o.ConvertHiraganas,
		U005cAsYenSign:         o.U005cAsYenSign.UnwrapOrElse(func() bool { return !o.U00a5AsYenSign.IsValid() }),
		U005cAsBackslash:       o.U005cAsBackslash.UnwrapOr(false),
		U007eAsFullwidthTilde:  o.U007eAsFullwidthTilde.UnwrapOr(true),
		U007eAsWaveDash:        o.U007eAsWaveDash.UnwrapOr(true),
		U007eAsOverline:        o.U007eAsOverline.UnwrapOr(false),
		U007eAsFullwidthMacron: o.U007eAsFullwidthMacron.UnwrapOr(false),
		U00a5AsYenSign:         o.U00a5AsYenSign.UnwrapOr(false),
	}
}

func (o *Options) revOptions() revOptions {
	return revOptions{
		ConvertGL:               o.ConvertGL,
		ConvertGR:               o.ConvertGR,
		ConvertUnsafeSpecials:   o.ConvertUnsafeSpecials.UnwrapOr(false),
		CombineVoicedSoundMarks: o.CombineVoicedSoundMarks,
		U005cAsYenSign:          o.U005cAsYenSign.UnwrapOrElse(func() bool { return !o.U005cAsBackslash.IsValid() }),
		U005cAsBackslash:        o.U005cAsBackslash.UnwrapOr(false),
		U007eAsFullwidthTilde: o.U007eAsFullwidthTilde.UnwrapOrElse(func() bool {
			return !o.U007eAsWaveDash.IsValid() && !o.U007eAsOverline.IsValid() && !o.U007eAsFullwidthMacron.IsValid()
		}),
		U007eAsWaveDash:        o.U007eAsWaveDash.UnwrapOr(false),
		U007eAsOverline:        o.U007eAsOverline.UnwrapOr(false),
		U007eAsFullwidthMacron: o.U007eAsFullwidthMacron.UnwrapOr(false),
		U00a5AsYenSign:         o.U00a5AsYenSign.UnwrapOr(true),
	}
}

// fullwidthToHalfwidthIterator implements yosina.CharIterator for fullwidth to halfwidth conversion.
// It handles multi-character mappings and uses a mapping table for character conversion.
type fullwidthToHalfwidthIterator struct {
	yosina.CharIterator
	options  fwdOptions
	mappings map[rune][2]rune
	offset   int
	pending  rune
	c        *yosina.Char
}

func (i *fullwidthToHalfwidthIterator) Next() *yosina.Char {
	if i.pending != yosina.InvalidUnicodeValue {
		c := &yosina.Char{
			C:      [2]rune{i.pending, yosina.InvalidUnicodeValue},
			Offset: i.offset,
			Source: i.c,
		}
		i.pending = yosina.InvalidUnicodeValue
		i.offset += c.RuneLen()
		return c
	}

	c := i.CharIterator.Next()
	if c == nil {
		return nil
	}
	if c.C[0] == yosina.InvalidUnicodeValue {
		return c.WithOffset(i.offset)
	}

	// Convert fullwidth to halfwidth
	if mapped, ok := i.mappings[c.C[0]]; ok {
		// Multi-character mapping
		if mapped[1] != yosina.InvalidUnicodeValue {
			i.pending = mapped[1]
			i.c = c
		}
		c := &yosina.Char{
			C:      [2]rune{mapped[0], yosina.InvalidUnicodeValue},
			Offset: i.offset,
			Source: c,
		}
		i.offset += c.RuneLen()
		return c
	}

	return c
}

type revMappings struct {
	nonvoiced map[rune]rune
	voiced    map[rune]map[rune]rune
}

// halfwidthToFullwidthIterator implements yosina.CharIterator for halfwidth to fullwidth conversion.
// It handles voiced sound mark combinations and regular character mappings.
type halfwidthToFullwidthIterator struct {
	yosina.CharIterator
	options  revOptions
	mappings revMappings
	offset   int
	pending  *yosina.Char
}

func (i *halfwidthToFullwidthIterator) Next() *yosina.Char {
	var c *yosina.Char
	if i.pending != nil {
		c = i.pending
		i.pending = nil
	} else {
		c = i.CharIterator.Next()
		if c == nil {
			return nil
		}
	}

	if c.C[0] == yosina.InvalidUnicodeValue {
		return c.WithOffset(i.offset)
	}

	// Check for voiced sound mark combination
	if i.options.CombineVoicedSoundMarks && c.C[1] == yosina.InvalidUnicodeValue {
		if markMappings, ok := i.mappings.voiced[c.C[0]]; ok {
			// Look ahead for a voice mark
			next := i.CharIterator.Next()
			if next != nil && next.C[0] != yosina.InvalidUnicodeValue {
				if combined, ok := markMappings[next.C[0]]; ok {
					// Combine the characters
					c := &yosina.Char{
						C:      [2]rune{combined, yosina.InvalidUnicodeValue},
						Offset: i.offset,
						Source: c,
					}
					i.offset += c.RuneLen()
					return c
				}
			}
			// No combination possible, set next as pending
			i.pending = next
		}
	}

	// Regular mapping
	if mapped, ok := i.mappings.nonvoiced[c.C[0]]; ok {
		c := &yosina.Char{
			C:      [2]rune{mapped, yosina.InvalidUnicodeValue},
			Offset: i.offset,
			Source: c,
		}
		i.offset += c.RuneLen()
		return c
	}

	c = c.WithOffset(i.offset)
	i.offset += c.RuneLen()
	return c
}

type GuardedValue[T any] struct {
	sync.Mutex
	value T
}

var fwdMappingCache = GuardedValue[map[fwdOptions]*GuardedValue[map[rune][2]rune]]{
	sync.Mutex{},
	make(map[fwdOptions]*GuardedValue[map[rune][2]rune]),
}

func buildFwdMappings(options fwdOptions) map[rune][2]rune {
	var entry *GuardedValue[map[rune][2]rune]
	{
		fwdMappingCache.Lock()
		entry = fwdMappingCache.value[options]
		if entry != nil {
			fwdMappingCache.Unlock()
			entry.Lock()
			defer entry.Unlock()
			return entry.value
		}
		entry = &GuardedValue[map[rune][2]rune]{
			sync.Mutex{},
			make(map[rune][2]rune),
		}
		entry.Lock()
		fwdMappingCache.value[options] = entry
		fwdMappingCache.Unlock()
	}
	defer entry.Unlock()

	mappings := make(map[rune][2]rune)
	if options.ConvertGL {
		for k, v := range jisx0201GLTable {
			mappings[k] = [2]rune{v, yosina.InvalidUnicodeValue}
		}

		// Handle overrides
		if options.U005cAsYenSign {
			mappings['\uffe5'] = [2]rune{'\u005c', yosina.InvalidUnicodeValue}
		}
		if options.U005cAsBackslash {
			mappings['\uff3c'] = [2]rune{'\u005c', yosina.InvalidUnicodeValue}
		}
		if options.U007eAsFullwidthTilde {
			mappings['\uff5e'] = [2]rune{'\u007e', yosina.InvalidUnicodeValue}
		}
		if options.U007eAsWaveDash {
			mappings['\u301c'] = [2]rune{'\u007e', yosina.InvalidUnicodeValue}
		}
		if options.U007eAsOverline {
			mappings['\u203e'] = [2]rune{'\u007e', yosina.InvalidUnicodeValue}
		}
		if options.U007eAsFullwidthMacron {
			mappings['\uffe3'] = [2]rune{'\u007e', yosina.InvalidUnicodeValue}
		}
		if options.U00a5AsYenSign {
			mappings['\uffe5'] = [2]rune{'\u00a5', yosina.InvalidUnicodeValue}
		}
		if options.ConvertUnsafeSpecials {
			for k, v := range specialPunctuationsTable {
				mappings[k] = [2]rune{v, yosina.InvalidUnicodeValue}
			}
		}
	}

	if options.ConvertGR {
		for k, v := range jisx0201GRTable {
			mappings[k] = [2]rune{v, yosina.InvalidUnicodeValue}
		}
		for k, v := range voicedLettersTable {
			mappings[k] = v
		}
		mappings['\u3099'] = [2]rune{'\uff9e', yosina.InvalidUnicodeValue}
		mappings['\u309a'] = [2]rune{'\uff9f', yosina.InvalidUnicodeValue}
		if options.ConvertHiraganas {
			for k, v := range hiraganaTable {
				mappings[k] = v
			}
		}
	}

	entry.value = mappings
	return mappings
}

var revMappingCache = GuardedValue[map[revOptions]*GuardedValue[revMappings]]{
	sync.Mutex{},
	make(map[revOptions]*GuardedValue[revMappings]),
}

func buildRevMappings(options revOptions) revMappings {
	var entry *GuardedValue[revMappings]
	{
		revMappingCache.Lock()
		entry = revMappingCache.value[options]
		if entry != nil {
			revMappingCache.Unlock()
			entry.Lock()
			defer entry.Unlock()
			return entry.value
		}
		entry = &GuardedValue[revMappings]{
			sync.Mutex{},
			revMappings{
				nonvoiced: make(map[rune]rune),
				voiced:    make(map[rune]map[rune]rune),
			},
		}
		entry.Lock()
		revMappingCache.value[options] = entry
		revMappingCache.Unlock()
	}
	defer entry.Unlock()

	mappings := make(map[rune]rune)
	var voicedMappings map[rune]map[rune]rune

	if options.ConvertGL {
		for k, v := range jisx0201GLTable {
			mappings[v] = k
		}

		// Handle overrides
		if options.U005cAsYenSign {
			mappings['\u005c'] = '\uffe5'
		}
		if options.U005cAsBackslash {
			mappings['\u005c'] = '\uff3c'
		}
		if options.U007eAsFullwidthTilde {
			mappings['\u007e'] = '\uff5e'
		}
		if options.U007eAsWaveDash {
			mappings['\u007e'] = '\u301c'
		}
		if options.U007eAsOverline {
			mappings['\u007e'] = '\u203e'
		}
		if options.U007eAsFullwidthMacron {
			mappings['\u007e'] = '\uffe3'
		}
		if options.U00a5AsYenSign {
			mappings['\u00a5'] = '\uffe5'
		}
		if options.ConvertUnsafeSpecials {
			for k, v := range specialPunctuationsTable {
				mappings[v] = k
			}
		}
	}

	if options.ConvertGR {
		for k, v := range jisx0201GRTable {
			mappings[v] = k
		}
		if options.CombineVoicedSoundMarks {
			voicedMappings = make(map[rune]map[rune]rune)
			for fullwidth, halfwidth := range voicedLettersTable {
				baseRune := halfwidth[0]
				markRune := halfwidth[1]
				inner := voicedMappings[baseRune]
				if inner == nil {
					inner = make(map[rune]rune)
					voicedMappings[baseRune] = inner
				}
				inner[markRune] = fullwidth
			}
		}
	}

	entry.value = revMappings{
		nonvoiced: mappings,
		voiced:    voicedMappings,
	}
	return entry.value
}

func Transliterate(i yosina.CharIterator, opts Options) yosina.CharIterator {
	if opts.FullwidthToHalfwidth {
		opts := opts.fwdOptions()
		mappings := buildFwdMappings(opts)
		return &fullwidthToHalfwidthIterator{
			CharIterator: i,
			options:      opts,
			mappings:     mappings,
			pending:      yosina.InvalidUnicodeValue,
		}
	} else {
		opts := opts.revOptions()
		mappings := buildRevMappings(opts)
		return &halfwidthToFullwidthIterator{
			CharIterator: i,
			options:      opts,
			mappings:     mappings,
		}
	}
}
