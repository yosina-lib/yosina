# Yosina Browser ESM Example

This directory contains an example demonstrating how to use Yosina in web browsers with ES Modules.

## Overview

This example provides an interactive web interface for testing various Yosina transliteration features. It demonstrates real-time text transformation with configurable options.

## Prerequisites

- A modern web browser with ES Modules support (Chrome 61+, Firefox 60+, Safari 11+, Edge 79+)
- A local web server (due to CORS restrictions for ES modules)

## Setup

### Option 1: Using a simple HTTP server

```bash
# Using Python (if installed)
python -m http.server 8000

# Using Node.js (if installed)
npx http-server -p 8000

# Using Deno (if installed)
deno run --allow-net --allow-read https://deno.land/std/http/file_server.ts
```

### Option 2: Using VS Code Live Server

If you're using Visual Studio Code, install the "Live Server" extension and right-click on `index.html` to select "Open with Live Server".

## Running the Example

1. Start your local web server in this directory
2. Open your browser and navigate to `http://localhost:8000` (or the appropriate port)
3. The interactive interface will load automatically

## Features Demonstrated

The web interface includes:

1. **Text Input Area** - Enter text to be transliterated
2. **Font Selection** - Switch between Noto Sans JP and Kosugi fonts
3. **Recipe Configuration** - Interactive checkboxes for various transliteration options:
   - Full-width to half-width conversion
   - Half-width to full-width conversion
   - Combine decomposed hiraganas and katakanas
   - Remove IVS/SVS selectors
   - Replace various hyphens and dashes
   - Replace ideographic annotations
   - Replace CJK radicals
   - Replace mathematical alphanumerics
   - Replace various spaces
   - Replace suspicious hyphens with prolonged sound marks
   - Convert old-style kanji to modern equivalents
   - Replace combined characters (control symbols, parenthesized chars, Japanese units)
   - Replace circled or squared characters (with optional emoji exclusion)

4. **Live Recipe JSON** - Shows the current configuration in JSON format
5. **Real-time Output** - Displays transliterated text as you type

## Code Structure

The example uses:
- Native ES modules with `import` statements
- Dynamic transliterator creation based on selected options
- Event-driven updates for real-time transformation
- Unicode escape sequence support (e.g., `\u3042` or `\u{1F600}`)

## Key Implementation Details

```javascript
// Import Yosina
import { makeTransliterator } from './yosina/index.js';

// Create transliterator with recipe
const tl = await makeTransliterator(recipe);

// Apply transliteration
const result = tl(inputText);
```

## Browser Compatibility

This example requires a browser with:
- ES Modules support
- Async/await support
- Modern JavaScript features (ES2015+)

## Example Characters to Try

The input area includes helpful placeholders, but here are some interesting characters to experiment with:

### New Transliterators
- **Combined Characters**: `␀␁␂` (control symbols), `⑴⑵⑶` (parenthesized), `㌀㌔㍍` (Japanese units)
- **Circled/Squared Characters**: `①②③` (circled numbers), `ⒶⒷⒸ` (circled letters), `🅰🅱🅲` (squared emojis)

### Other Transliterators
- **Mathematical**: `𝒜𝒷𝒸𝒹𝑒𝑓` (script), `𝟏𝟐𝟑` (bold numbers)
- **Spaces**: ` ` (various Unicode spaces)
- **Hyphens**: `－―‒–` (various dash types)
- **Radicals**: `⺀⺁⼀⼁` (CJK radicals)
- **Old Kanji**: `國學` (old forms)

## Common Use Cases

- **Interactive Text Processing**: Allow users to experiment with different transliteration options
- **Form Validation**: Normalize user input in real-time
- **Content Preview**: Show how text will appear after processing
- **Educational Tool**: Demonstrate various Unicode normalization concepts

## Troubleshooting

### Module Loading Errors

If you see CORS or module loading errors:
1. Ensure you're using a local web server (not opening the file directly)
2. Check that the `yosina` symlink or directory exists
3. Verify the import path in the HTML file

### Font Display Issues

Some characters may not display correctly without the proper fonts:
1. The example loads Noto Sans JP and Kosugi from Google Fonts
2. Ensure your browser can access fonts.googleapis.com
3. Some special characters may require additional font support

## Further Reading

- [Yosina JavaScript README](../../../javascript/README.md)
- [Main Yosina README](../../../README.md)
- [MDN: JavaScript Modules](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Modules)