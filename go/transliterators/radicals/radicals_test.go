package radicals

import (
	"testing"

	"github.com/stretchr/testify/assert"

	yosina "github.com/yosina-lib/yosina/go"
)

func TestRadicalsComprehensive(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		// CJK Radicals Supplement (⺀-⻳)
		{"Radical ice (variant) to standard ice", "⺀", "冫"},
		{"Radical cliff (variant) to standard cliff", "⺁", "厂"},
		{"Radical second (variant) to standard second", "⺂", "乛"},
		{"Radical second three (variant) to standard", "⺃", "乚"},
		{"Radical second (variant) to standard second", "⺄", "乙"},
		{"Radical person (variant) to standard person", "⺅", "亻"},
		{"Radical wide (variant) to standard wide", "⺆", "冂"},
		{"Radical knife (variant) to standard knife", "⺉", "刂"},
		{"Radical divination (variant) to standard", "⺊", "卜"},
		{"Radical seal (variant) to standard seal", "⺋", "㔾"},
		{"Radical heart (variant) to standard heart", "⺖", "忄"},
		{"Radical hand (variant) to standard hand", "⺘", "扌"},
		{"Radical rap (variant) to standard rap", "⺙", "攵"},
		{"Radical water (variant) to standard water", "⺡", "氵"},
		{"Radical fire (variant) to standard fire", "⺣", "灬"},
		{"Radical claw (variant) to standard claw", "⺥", "爫"},
		{"Radical dog (variant) to standard dog", "⺨", "犭"},
		{"Radical spirit (variant) to standard spirit", "⺭", "礻"},
		{"Radical silk (variant) to standard silk", "⺯", "糹"},
		{"Radical silk simplified (variant) to standard", "⺰", "纟"},
		{"Radical grass (variant) to standard grass", "⺾", "艹"},
		{"Radical grass (variant 2) to standard grass", "⺿", "艹"},
		{"Radical grass (variant 3) to standard grass", "⻀", "艹"},
		{"Radical clothes (variant) to standard clothes", "⻂", "衤"},
		{"Radical speech simplified (variant) to standard", "⻈", "讠"},
		{"Radical shell simplified (variant) to standard", "⻉", "贝"},
		{"Radical vehicle simplified (variant) to standard", "⻋", "车"},
		{"Radical walk (variant) to standard walk", "⻍", "辶"},
		{"Radical city (variant) to standard city", "⻏", "阝"},
		{"Radical metal simplified (variant) to standard", "⻐", "钅"},
		{"Radical mound (variant) to standard mound", "⻖", "阝"},
		{"Radical eat (variant) to standard eat", "⻟", "飠"},
		{"Radical eat simplified (variant) to standard", "⻠", "饣"},
		{"Radical horse simplified (variant) to standard", "⻢", "马"},
		{"Radical fish simplified (variant) to standard", "⻥", "鱼"},
		{"Radical bird simplified (variant) to standard", "⻦", "鸟"},

		// Kangxi Radicals (⼀-⿕)
		{"Kangxi radical one to standard one", "⼀", "一"},
		{"Kangxi radical line to standard line", "⼁", "丨"},
		{"Kangxi radical dot to standard dot", "⼂", "丶"},
		{"Kangxi radical slash to standard slash", "⼃", "丿"},
		{"Kangxi radical second to standard second", "⼄", "乙"},
		{"Kangxi radical hook to standard hook", "⼅", "亅"},
		{"Kangxi radical two to standard two", "⼆", "二"},
		{"Kangxi radical lid to standard lid", "⼇", "亠"},
		{"Kangxi radical person to standard person", "⼈", "人"},
		{"Kangxi radical legs to standard legs", "⼉", "儿"},
		{"Kangxi radical enter to standard enter", "⼊", "入"},
		{"Kangxi radical eight to standard eight", "⼋", "八"},
		{"Kangxi radical down box to standard down box", "⼌", "冂"},
		{"Kangxi radical cover to standard cover", "⼍", "冖"},
		{"Kangxi radical ice to standard ice", "⼎", "冫"},
		{"Kangxi radical table to standard table", "⼏", "几"},
		{"Kangxi radical open box to standard open box", "⼐", "凵"},
		{"Kangxi radical knife to standard knife", "⼑", "刀"},
		{"Kangxi radical power to standard power", "⼒", "力"},
		{"Kangxi radical wrap to standard wrap", "⼓", "勹"},
		{"Kangxi radical spoon to standard spoon", "⼔", "匕"},
		{"Kangxi radical right open box to standard", "⼕", "匚"},
		{"Kangxi radical hiding enclosure to standard", "⼖", "匸"},
		{"Kangxi radical ten to standard ten", "⼗", "十"},
		{"Kangxi radical divination to standard divination", "⼘", "卜"},
		{"Kangxi radical seal to standard seal", "⼙", "卩"},
		{"Kangxi radical cliff to standard cliff", "⼚", "厂"},
		{"Kangxi radical private to standard private", "⼛", "厶"},
		{"Kangxi radical again to standard again", "⼜", "又"},
		{"Kangxi radical mouth to standard mouth", "⼝", "口"},
		{"Kangxi radical enclosure to standard enclosure", "⼞", "囗"},
		{"Kangxi radical earth to standard earth", "⼟", "土"},
		{"Kangxi radical scholar to standard scholar", "⼠", "士"},
		{"Kangxi radical go to standard go", "⼡", "夂"},
		{"Kangxi radical go slowly to standard go slowly", "⼢", "夊"},
		{"Kangxi radical evening to standard evening", "⼣", "夕"},
		{"Kangxi radical big to standard big", "⼤", "大"},
		{"Kangxi radical woman to standard woman", "⼥", "女"},
		{"Kangxi radical child to standard child", "⼦", "子"},
		{"Kangxi radical roof to standard roof", "⼧", "宀"},
		{"Kangxi radical inch to standard inch", "⼨", "寸"},
		{"Kangxi radical small to standard small", "⼩", "小"},
		{"Kangxi radical lame to standard lame", "⼪", "尢"},
		{"Kangxi radical corpse to standard corpse", "⼫", "尸"},
		{"Kangxi radical sprout to standard sprout", "⼬", "屮"},
		{"Kangxi radical mountain to standard mountain", "⼭", "山"},
		{"Kangxi radical river to standard river", "⼮", "巛"},
		{"Kangxi radical work to standard work", "⼯", "工"},
		{"Kangxi radical oneself to standard oneself", "⼰", "己"},
		{"Kangxi radical turban to standard turban", "⼱", "巾"},
		{"Kangxi radical dry to standard dry", "⼲", "干"},
		{"Kangxi radical short thread to standard", "⼳", "幺"},
		{"Kangxi radical dotted cliff to standard", "⼴", "广"},
		{"Kangxi radical long stride to standard", "⼵", "廴"},
		{"Kangxi radical arch to standard arch", "⼶", "廾"},
		{"Kangxi radical shoot to standard shoot", "⼷", "弋"},
		{"Kangxi radical bow to standard bow", "⼸", "弓"},
		{"Kangxi radical snout to standard snout", "⼹", "彐"},
		{"Kangxi radical bristle to standard bristle", "⼺", "彡"},
		{"Kangxi radical step to standard step", "⼻", "彳"},
		{"Kangxi radical heart to standard heart", "⼼", "心"},
		{"Kangxi radical halberd to standard halberd", "⼽", "戈"},
		{"Kangxi radical door to standard door", "⼾", "戶"},
		{"Kangxi radical hand to standard hand", "⼿", "手"},
		{"Kangxi radical branch to standard branch", "⽀", "支"},
		{"Kangxi radical rap to standard rap", "⽁", "攴"},
		{"Kangxi radical script to standard script", "⽂", "文"},
		{"Kangxi radical dipper to standard dipper", "⽃", "斗"},
		{"Kangxi radical axe to standard axe", "⽄", "斤"},
		{"Kangxi radical square to standard square", "⽅", "方"},
		{"Kangxi radical not to standard not", "⽆", "无"},
		{"Kangxi radical sun to standard sun", "⽇", "日"},
		{"Kangxi radical say to standard say", "⽈", "曰"},
		{"Kangxi radical moon to standard moon", "⽉", "月"},
		{"Kangxi radical tree to standard tree", "⽊", "木"},
		{"Kangxi radical lack to standard lack", "⽋", "欠"},
		{"Kangxi radical stop to standard stop", "⽌", "止"},
		{"Kangxi radical death to standard death", "⽍", "歹"},
		{"Kangxi radical weapon to standard weapon", "⽎", "殳"},
		{"Kangxi radical do not to standard do not", "⽏", "毋"},
		{"Kangxi radical compare to standard compare", "⽐", "比"},
		{"Kangxi radical fur to standard fur", "⽑", "毛"},
		{"Kangxi radical clan to standard clan", "⽒", "氏"},
		{"Kangxi radical steam to standard steam", "⽓", "气"},
		{"Kangxi radical water to standard water", "⽔", "水"},
		{"Kangxi radical fire to standard fire", "⽕", "火"},
		{"Kangxi radical claw to standard claw", "⽖", "爪"},
		{"Kangxi radical father to standard father", "⽗", "父"},
		{"Kangxi radical double x to standard double x", "⽘", "爻"},
		{"Kangxi radical half tree trunk to standard", "⽙", "爿"},
		{"Kangxi radical slice to standard slice", "⽚", "片"},
		{"Kangxi radical fang to standard fang", "⽛", "牙"},
		{"Kangxi radical cow to standard cow", "⽜", "牛"},
		{"Kangxi radical dog to standard dog", "⽝", "犬"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := yosina.StringFromChars(
				Transliterate(yosina.NewCharIteratorFromSlice(yosina.BuildCharArray(tt.input))),
			)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestRadicalsContextual(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{"mixed kangxi and cjk supplement", "部首⺀漢字⼀", "部首冫漢字一"},
		{"kangxi radicals sequence", "⼀⼆⼃⼄⼅⼆⼇⼈⼉⼊", "一二丿乙亅二亠人儿入"},
		{"cjk radicals supplement sequence", "⺀⺁⺂⺃⺄⺅⺆", "冫厂乛乚乙亻冂"},
		{"hand radical variants", "⺘⼿", "扌手"},
		{"water radical variants", "⺡⽔", "氵水"},
		{"grass radical variants", "⺾⺿⻀⾋", "艹艹艹艸"},
		{"simplified radicals", "⻈⻉⻋⻐⻢⻥⻦", "讠贝车钅马鱼鸟"},
		{"radicals in context", "⼭の⽊を⽔で育てる", "山の木を水で育てる"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := yosina.StringFromChars(
				Transliterate(yosina.NewCharIteratorFromSlice(yosina.BuildCharArray(tt.input))),
			)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestRadicalsEdgeCases(t *testing.T) {
	tests := []struct {
		name     string
		input    string
		expected string
	}{
		{"empty string", "", ""},
		{"unmapped characters", "hello world 123 abc こんにちは 漢字", "hello world 123 abc こんにちは 漢字"},
		{"no radicals present", "普通の漢字です", "普通の漢字です"},
		{"radical at start", "⼀番目", "一番目"},
		{"radical at end", "最後は⼈", "最後は人"},
		{"consecutive radicals", "⼀⼆⼈⼿⽔", "一二人手水"},
		{"radical between non-cjk", "A⼀B⼆C", "A一B二C"},
		{"newlines and whitespace", "⼀\n⼆\t⼈ ⼿", "一\n二\t人 手"},
		{"unicode surrogates preservation", "𝓗⼀𝓮⼆𝓵⼈", "𝓗一𝓮二𝓵人"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := yosina.StringFromChars(
				Transliterate(yosina.NewCharIteratorFromSlice(yosina.BuildCharArray(tt.input))),
			)
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestRadicalsIteratorProperties(t *testing.T) {
	input := "⼀⼆⼃"
	result := Transliterate(yosina.NewCharIteratorFromSlice(yosina.BuildCharArray(input)))
	assert.NotNil(t, result)

	// Check that we can iterate through the result
	count := 0
	for {
		char := result.Next()
		if char == nil {
			break
		}
		count++
	}
	assert.Greater(t, count, 0)
}
