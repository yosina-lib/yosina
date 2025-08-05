use std::borrow::Cow;
use std::ptr::NonNull;

/// A character with position information and source tracking.
///
/// Represents a character with metadata for transliteration operations.
/// This structure is used to track individual characters through various
/// transformation stages while maintaining information about their original
/// position and source.
///
/// The character string may contain multiple Unicode code points, particularly
/// when handling Ideographic Variation Sequences (IVS) and Standardized
/// Variation Sequences (SVS) where a base character is combined with its
/// variation selector.
///
/// # Examples
///
/// ```
/// use std::borrow::Cow;
/// use yosina::char::Char;
///
/// // Create a simple character
/// let ch = Char {
///     c: Cow::Borrowed("A"),
///     offset: 0,
///     source: None,
/// };
/// ```
#[derive(Debug, PartialEq)]
pub struct Char<'a, 'b>
where
    'b: 'a,
{
    /// The character string (may be multiple Unicode code points).
    ///
    /// This field contains the actual character data. It may be a single
    /// Unicode character or a combination of a base character with variation
    /// selectors (U+FE00-U+FE0F or U+E0100-U+E01EF).
    pub c: Cow<'b, str>,

    /// Byte offset in the original string.
    ///
    /// This represents the position where this character appears in the
    /// original input text, measured in UTF-8 bytes from the beginning.
    pub offset: usize,

    /// Source character that this was derived from (for tracking transformations).
    ///
    /// When a character is transformed during transliteration, this field
    /// maintains a reference to the original character to enable transformation
    /// tracking and debugging.
    pub source: Option<&'a Char<'a, 'b>>,
}

impl<'a, 'b> Char<'a, 'b>
where
    'b: 'a,
{
    /// Creates a new `Char` without source tracking.
    ///
    /// This constructor creates a character with no reference to a source
    /// character, typically used for original input characters.
    ///
    /// # Arguments
    ///
    /// * `c` - The character string content
    /// * `offset` - The byte offset in the original string
    ///
    /// # Returns
    ///
    /// A new `Char` instance with `source` set to `None`
    fn new(c: Cow<'b, str>, offset: usize) -> Self {
        Self {
            c,
            offset,
            source: None,
        }
    }

    /// Creates a new `Char` with optional source tracking.
    ///
    /// This constructor allows creating a character that may reference
    /// another character as its source, enabling transformation tracking.
    ///
    /// # Arguments
    ///
    /// * `c` - The character string content
    /// * `offset` - The byte offset in the original string
    /// * `source` - Optional reference to the source character
    ///
    /// # Returns
    ///
    /// A new `Char` instance with the specified source reference
    fn new_from(c: Cow<'b, str>, offset: usize, source: Option<&'a Char<'a, 'b>>) -> Self {
        Self { c, offset, source }
    }

    /// Creates a sentinel character.
    ///
    /// Sentinel characters are empty characters used to mark the end of
    /// character arrays in the transliteration system. They have an empty
    /// string as content and no source reference.
    ///
    /// # Arguments
    ///
    /// * `offset` - The byte offset where the sentinel should be placed
    ///
    /// # Returns
    ///
    /// A new sentinel `Char` with empty content
    fn new_sentinel(offset: usize) -> Self {
        Self {
            c: Cow::Borrowed(""),
            offset,
            source: None,
        }
    }

    /// Returns the character content if it's not empty.
    ///
    /// This method returns `None` for sentinel characters (which have empty
    /// content) and `Some(&str)` for regular characters.
    ///
    /// # Returns
    ///
    /// * `Some(&str)` - The character content if not empty
    /// * `None` - If this is a sentinel character (empty content)
    pub fn c(&self) -> Option<&str> {
        if self.c.is_empty() {
            None
        } else {
            Some(self.c.as_ref())
        }
    }

    /// Checks if this character is a sentinel.
    ///
    /// Sentinel characters are used to mark boundaries in character arrays
    /// and have empty string content.
    ///
    /// # Returns
    ///
    /// `true` if this is a sentinel character, `false` otherwise
    pub fn is_sentinel(&self) -> bool {
        self.c.is_empty()
    }

    /// Checks if the character has been transliterated.
    ///
    /// This method traverses the source chain of the character to determine
    /// if it has been transformed from its original form. If the character
    /// has a source that differs from its own content, it is considered
    /// transliterated.
    pub fn is_transliterated(&self) -> bool {
        let mut c = self;
        while let Some(source) = c.source {
            if c.c != source.c {
                return true;
            }
            c = source;
        }
        false
    }
}

/// A pool for managing character lifetimes during transliteration.
///
/// `CharPool` is responsible for creating and managing `Char` instances
/// throughout the transliteration process. It ensures that character
/// references remain valid for the duration of the transliteration
/// operations by storing them in a vector.
///
/// The pool uses boxed storage to provide stable references that can
/// be safely returned with the appropriate lifetimes, even as the
/// internal vector grows.
///
/// # Examples
///
/// ```
/// use std::borrow::Cow;
/// use yosina::char::CharPool;
///
/// let mut pool = CharPool::new();
/// let char_ref = pool.new_char(Cow::Borrowed("A"), 0);
/// assert_eq!(char_ref.c, "A");
/// assert_eq!(char_ref.offset, 0);
/// ```
#[derive(Debug)]
pub struct CharPool<'a, 'b>
where
    'b: 'a,
{
    #[allow(clippy::vec_box)]
    chars: Vec<Box<Char<'a, 'b>>>,
}

impl<'a, 'b> PartialEq for CharPool<'a, 'b>
where
    'b: 'a,
{
    fn eq(&self, other: &Self) -> bool {
        NonNull::from(self) == NonNull::from(other)
    }
}

impl<'a, 'b> CharPool<'a, 'b>
where
    'b: 'a,
{
    /// Creates a new empty character pool.
    ///
    /// # Returns
    ///
    /// A new `CharPool` instance ready for character allocation
    #[allow(clippy::new_without_default)]
    pub fn new() -> Self {
        Self { chars: Vec::new() }
    }

    /// Creates a new character in the pool without source tracking.
    ///
    /// This method allocates a new `Char` in the pool and returns a reference
    /// to it. The character will have no source reference, making it suitable
    /// for original input characters.
    ///
    /// # Arguments
    ///
    /// * `c` - The character string content
    /// * `offset` - The byte offset in the original string
    ///
    /// # Returns
    ///
    /// A reference to the newly created character with lifetime `'a`
    ///
    /// # Safety
    ///
    /// This method uses `unsafe` transmute to extend the lifetime of the
    /// returned reference. This is safe because the `CharPool` ensures
    /// the character remains allocated for the duration of `'a`.
    pub fn new_char(&mut self, c: Cow<'b, str>, offset: usize) -> &'a Char<'a, 'b>
    where
        Self: 'a,
    {
        self.chars.push(Box::new(Char::new(c, offset)));
        unsafe { std::mem::transmute::<&_, &'a _>(self.chars.last_mut().unwrap().as_ref()) }
    }

    /// Creates a new character in the pool with source tracking.
    ///
    /// This method allocates a new `Char` in the pool that references
    /// another character as its source. This is useful for tracking
    /// transformations during transliteration.
    ///
    /// # Arguments
    ///
    /// * `c` - The character string content
    /// * `offset` - The byte offset in the original string
    /// * `source` - Reference to the source character
    ///
    /// # Returns
    ///
    /// A reference to the newly created character with lifetime `'a`
    ///
    /// # Safety
    ///
    /// This method uses `unsafe` transmute to extend the lifetime of the
    /// returned reference. This is safe because the `CharPool` ensures
    /// the character remains allocated for the duration of `'a`.
    pub fn new_char_from(
        &mut self,
        c: Cow<'b, str>,
        offset: usize,
        source: &'a Char<'a, 'b>,
    ) -> &'a Char<'a, 'b>
    where
        Self: 'a,
    {
        self.chars
            .push(Box::new(Char::new_from(c, offset, Some(source))));
        unsafe { std::mem::transmute::<&_, &'a _>(self.chars.last_mut().unwrap().as_ref()) }
    }

    pub fn new_with_offset(&mut self, original: &'a Char<'a, 'b>, offset: usize) -> &'a Char<'a, 'b>
    where
        Self: 'a,
    {
        self.new_char_from(original.c.clone(), offset, original)
    }

    /// Creates a new sentinel character in the pool.
    ///
    /// Sentinel characters mark boundaries in character arrays and have
    /// empty string content. They are typically placed at the end of
    /// character arrays to indicate the end of meaningful content.
    ///
    /// # Arguments
    ///
    /// * `offset` - The byte offset where the sentinel should be placed
    ///
    /// # Returns
    ///
    /// A reference to the newly created sentinel character
    ///
    /// # Safety
    ///
    /// This method uses `unsafe` transmute to extend the lifetime of the
    /// returned reference. This is safe because the `CharPool` ensures
    /// the character remains allocated for the duration of `'a`.
    pub fn new_sentinel(&mut self, offset: usize) -> &'a Char<'a, 'b>
    where
        Self: 'a,
    {
        self.chars.push(Box::new(Char::new_sentinel(offset)));
        unsafe { std::mem::transmute::<&_, &'a _>(self.chars.last_mut().unwrap().as_ref()) }
    }

    /// Builds a character array from a text string, handling variation selectors.
    ///
    /// This function properly handles Ideographic Variation Sequences (IVS) and
    /// Standardized Variation Sequences (SVS) by combining base characters with
    /// their variation selectors into single `Char` objects.
    ///
    /// Variation selectors are Unicode characters in the ranges:
    /// - U+FE00–U+FE0F (Variation Selector-1 to Variation Selector-16)
    /// - U+E0100–U+E01EF (Variation Selector-17 to Variation Selector-256)
    ///
    /// When a variation selector is encountered, it is combined with the
    /// preceding character to form a single `Char` object.
    ///
    /// # Arguments
    ///
    /// * `text` - The input string to convert to a character array
    ///
    /// # Returns
    ///
    /// A vector of character references representing the input string,
    /// with a sentinel empty character at the end
    ///
    /// # Examples
    ///
    /// ```
    /// use yosina::char::CharPool;
    ///
    /// let mut pool = CharPool::new();
    /// let chars = pool.build_char_array("Hello");
    /// assert_eq!(chars.len(), 6); // 5 characters + sentinel
    /// assert_eq!(chars[0].c, "H");
    /// assert_eq!(chars[5].c, ""); // sentinel
    /// ```
    pub fn build_char_array(&mut self, text: &'b str) -> Vec<&'a Char<'a, 'b>>
    where
        Self: 'a,
    {
        let mut result = Vec::new();
        let mut chars = text.char_indices();

        let mut prev_pair: Option<(usize, char)> = None;
        for pair in chars.by_ref() {
            if let Some(prev_pair_) = prev_pair {
                // Check for variation selectors
                let cp = pair.1 as u32;
                // Variation Selector-1 to Variation Selector-16 (U+FE00–U+FE0F)
                // Variation Selector-17 to Variation Selector-256 (U+E0100–U+E01EF)
                if (0xFE00u32..=0xFE0F).contains(&cp) || (0xE0100u32..=0xE01EF).contains(&cp) {
                    let mut s = String::new();
                    s.push(prev_pair_.1);
                    s.push(pair.1);
                    result.push(self.new_char(Cow::Owned(s), prev_pair_.0));
                    prev_pair = None;
                    continue;
                }
                result
                    .push(self.new_char(Cow::Borrowed(&text[prev_pair_.0..pair.0]), prev_pair_.0));
            }
            prev_pair = Some(pair);
        }
        if let Some(prev_pair_) = prev_pair {
            result.push(self.new_char(Cow::Borrowed(&text[prev_pair_.0..]), prev_pair_.0));
        }
        result.push(self.new_sentinel(text.len()));
        result
    }
}

/// A trait for iterating over characters in the transliteration system.
///
/// This trait provides a unified interface for iterating over `Char` objects
/// during transliteration operations. It mirrors the standard `Iterator` trait
/// but is specifically designed for the character lifetime management needs
/// of the transliteration system.
///
/// # Examples
///
/// ```
/// use yosina::char::{CharIterator, CharPool};
///
/// let mut pool = CharPool::new();
/// let chars = pool.build_char_array("Hello");
/// let mut iter = chars.into_iter();
///
/// while let Some(ch) = CharIterator::next(&mut iter) {
///     if !ch.is_sentinel() {
///         println!("Character: {}", ch.c.as_ref());
///     }
/// }
/// ```
pub trait CharIterator<'a, 'b> {
    /// Returns the next character in the iteration.
    ///
    /// # Returns
    ///
    /// * `Some(&Char)` - The next character if available
    /// * `None` - If the iteration is complete
    fn next(&mut self) -> Option<&'a Char<'a, 'b>>;
}

/// Implementation of `CharIterator` for any standard iterator over `Char` references.
///
/// This blanket implementation allows any iterator that yields `&Char` references
/// to be used as a `CharIterator`, providing seamless integration with the
/// standard library's iterator infrastructure.
impl<'a, 'b, I> CharIterator<'a, 'b> for I
where
    I: Iterator<Item = &'a Char<'a, 'b>>,
    'b: 'a,
{
    fn next(&mut self) -> Option<&'a Char<'a, 'b>> {
        Iterator::next(self)
    }
}

/// Implementation of standard `Iterator` for boxed `CharIterator` trait objects.
///
/// This implementation allows `CharIterator` trait objects to be used with
/// standard iterator methods and combinators, enabling dynamic dispatch
/// while maintaining compatibility with the iterator ecosystem.
impl<'a, 'b> Iterator for Box<dyn CharIterator<'a, 'b> + 'a>
where
    'b: 'a,
{
    type Item = &'a Char<'a, 'b>;

    fn next(&mut self) -> Option<&'a Char<'a, 'b>> {
        self.as_mut().next()
    }
}

/// A trait for converting collections into character iterators.
///
/// This trait mirrors the standard `IntoIterator` trait but is specifically
/// designed for the character system used in transliteration. It allows
/// various collection types to be converted into `CharIterator` instances.
///
/// # Examples
///
/// ```
/// use yosina::char::{IntoCharIterator, CharPool};
///
/// let mut pool = CharPool::new();
/// let chars = pool.build_char_array("Hello");
///
/// // Convert to iterator and process
/// for ch in chars {
///     if !ch.is_sentinel() {
///         println!("{}", ch.c.as_ref());
///     }
/// }
/// ```
pub trait IntoCharIterator<'a, 'b>
where
    'b: 'a,
{
    /// The type of iterator created by `into_iter`
    type IntoIter: CharIterator<'a, 'b>;

    /// Converts the collection into a character iterator.
    ///
    /// # Returns
    ///
    /// A `CharIterator` that will yield the characters from this collection
    fn into_iter(self) -> Self::IntoIter;
}

/// Implementation of `IntoCharIterator` for any type that implements `IntoIterator`.
///
/// This blanket implementation provides automatic `IntoCharIterator` support
/// for any collection that can be converted into an iterator over `Char` references,
/// such as vectors, slices, and other standard collections.
impl<'a, 'b, I> IntoCharIterator<'a, 'b> for I
where
    I: IntoIterator<Item = &'a Char<'a, 'b>>,
    'b: 'a,
{
    type IntoIter = I::IntoIter;

    fn into_iter(self) -> Self::IntoIter {
        IntoIterator::into_iter(self)
    }
}

/// Implementation of standard `IntoIterator` for boxed `IntoCharIterator` trait objects.
///
/// This implementation enables dynamic dispatch for character iterators while
/// maintaining compatibility with standard iterator patterns. It allows
/// trait objects to be used seamlessly with for loops and iterator methods.
impl<'a, 'b> IntoIterator
    for Box<dyn IntoCharIterator<'a, 'b, IntoIter = Box<dyn CharIterator<'a, 'b> + 'a>>>
where
    'b: 'a,
{
    type Item = &'a Char<'a, 'b>;
    type IntoIter = Box<dyn CharIterator<'a, 'b> + 'a>;

    fn into_iter(self) -> Self::IntoIter {
        Box::new(IntoCharIterator::into_iter(self))
    }
}

/// Converts an iterable of characters back to a string.
///
/// This function filters out sentinel characters (empty strings) that are
/// used internally by the transliteration system and combines the remaining
/// character content into a single string.
///
/// This is the inverse operation of `CharPool::build_char_array`, allowing
/// the reconstruction of text from character arrays after transliteration
/// operations have been performed.
///
/// # Arguments
///
/// * `chars` - An iterable of `Char` references to convert
///
/// # Returns
///
/// A string composed of the non-empty characters from the input
///
/// # Examples
///
/// ```
/// use yosina::char::{CharPool, from_chars};
///
/// let mut pool = CharPool::new();
/// let chars = pool.build_char_array("Hello");
/// let reconstructed = from_chars(chars.iter().cloned());
/// assert_eq!(reconstructed, "Hello");
/// ```
pub fn from_chars<'a, 'b>(chars: impl IntoIterator<Item = &'a Char<'a, 'b>>) -> String
where
    'b: 'a,
{
    chars.into_iter().filter_map(|c| c.c()).collect::<String>()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_build_char_array_basic() {
        let input = "Hello";
        let mut pool = CharPool::new();
        let chars = pool.build_char_array(input);

        assert_eq!(chars.len(), 6); // 5 characters + sentinel
        assert_eq!(chars[0].c, "H");
        assert_eq!(chars[0].offset, 0);
        assert_eq!(chars[1].c, "e");
        assert_eq!(chars[1].offset, 1);
        assert_eq!(chars[4].c, "o");
        assert_eq!(chars[4].offset, 4);
        assert_eq!(chars[5].c, ""); // sentinel
        assert_eq!(chars[5].offset, 5);
    }

    #[test]
    fn test_build_char_array_empty() {
        let input = "";
        let mut pool = CharPool::new();
        let chars = pool.build_char_array(input);

        assert_eq!(chars.len(), 1); // Just sentinel
        assert_eq!(chars[0].c, "");
        assert_eq!(chars[0].offset, 0);
    }

    #[test]
    fn test_build_char_array_unicode() {
        let input = "こんにちは"; // Japanese hiragana
        let mut pool = CharPool::new();
        let chars = pool.build_char_array(input);

        assert_eq!(chars.len(), 6); // 5 characters + sentinel
        assert_eq!(chars[0].c, "こ");
        assert_eq!(chars[1].c, "ん");
        assert_eq!(chars[2].c, "に");
        assert_eq!(chars[3].c, "ち");
        assert_eq!(chars[4].c, "は");
        assert_eq!(chars[5].c, ""); // sentinel
    }

    #[test]
    fn test_build_char_array_offsets() {
        let input = "A𝓣"; // 'A' (1 byte) + Mathematical Script Capital T (4 bytes UTF-8)
        let mut pool = CharPool::new();
        let chars = pool.build_char_array(input);

        assert_eq!(chars.len(), 3); // 2 characters + sentinel
        assert_eq!(chars[0].c, "A");
        assert_eq!(chars[0].offset, 0);
        assert_eq!(chars[1].c, "𝓣");
        assert_eq!(chars[1].offset, 1); // Offset in UTF-8 bytes
        assert_eq!(chars[2].offset, 5); // Should be after both characters
    }

    #[test]
    fn test_from_chars_basic() {
        let mut pool = CharPool::new();
        let chars = [
            pool.new_char("H".into(), 0),
            pool.new_char("e".into(), 1),
            pool.new_char("l".into(), 2),
            pool.new_char("l".into(), 3),
            pool.new_char("o".into(), 4),
            pool.new_sentinel(5), // sentinel
        ];
        let result = from_chars(chars.iter().cloned());
        assert_eq!(result, "Hello");
    }

    #[test]
    fn test_char_iterator_dyn_compatibility() {
        let mut pool = CharPool::new();
        let chars = pool.build_char_array("Hello");
        let iter: Box<dyn CharIterator<'_, '_>> = Box::new(chars.iter().cloned());

        let collected: Vec<_> = iter.collect();
        assert_eq!(collected.len(), 6); // 5 characters + sentinel
        assert_eq!(collected[0].c, "H");
        assert_eq!(collected[1].c, "e");
        assert_eq!(collected[5].c, ""); // sentinel
    }
}
