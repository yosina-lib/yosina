package yosina

// Transliterator is the interface for character transformation
type Transliterator interface {
	Transliterate(input CharIterator) (CharIterator, error)
}

// TransliteratorFunc is a function type that implements Transliterator
type TransliteratorFunc func(input CharIterator) (CharIterator, error)

// Transliterate implements the Transliterator interface
func (f TransliteratorFunc) Transliterate(input CharIterator) (CharIterator, error) {
	return f(input)
}

// ChainedTransliterator applies multiple transliterators in sequence
type ChainedTransliterator struct {
	transliterators []Transliterator
}

// NewChainedTransliterator creates a new chained transliterator
func NewChainedTransliterator(transliterators []Transliterator) *ChainedTransliterator {
	return &ChainedTransliterator{
		transliterators: transliterators,
	}
}

// Transliterate applies all transliterators in sequence
func (ct *ChainedTransliterator) Transliterate(input CharIterator) (CharIterator, error) {
	current := input
	for _, t := range ct.transliterators {
		result, err := t.Transliterate(current)
		if err != nil {
			return nil, err
		}
		current = result
	}
	return current, nil
}
