export type Char = {
  c: string;
  offset: number;
  source: Char | undefined;
};

export type Transliterator = (in_: Iterable<Char>) => Iterable<Char>;

export type TransliteratorFactory = (options: Record<string, unknown>) => Transliterator;
