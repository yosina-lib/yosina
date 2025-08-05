/***
 * Transliterator that replaces circled or squared characters with their corresponding templates.
 *
 * @module
 */
type Char = {
  c: string;
  offset: number;
  source: Char | undefined;
};

type Record_ = [string, "c" | "s", boolean];

type Mappings = Record<string, Record_>;

export type Options = {
  /**
   * Templates used to render circled or squared characters.
   */
  templates?: {
    circle?: string;
    square?: string;
  };
  /**
   * Whether to include emojis in the transliteration. If false, only non-emoji characters will be processed.
   */
  includeEmojis?: boolean;
};

const mappings: Mappings = {};

/**
 * A transliterator that replaces circled or squared characters.
 *
 * @param options Options for the transliterator.
 * @returns An iterable that yields transliterated characters.
 */
export default (options: Options): ((_: Iterable<Char>) => Iterable<Char>) => {
  const includeEmojis = options.includeEmojis ?? false;
  const templates = {
    c: options.templates?.circle ?? "(?)",
    s: options.templates?.square ?? "[?]",
  };

  return function* (in_: Iterable<Char>) {
    let offset = 0;
    for (const c of in_) {
      const r = mappings[c.c];
      if (r != null && (!r[2] || includeEmojis)) {
        for (const rc of templates[r[1]].replace("?", r[0])) {
          yield { c: rc, offset: offset, source: c };
          offset += rc.length;
        }
      } else {
        yield { c: c.c, offset: offset, source: c };
        offset += c.c.length;
      }
    }
  };
};
