// Command docgen converts GitHub-flavored Markdown from stdin to a
// self-contained HTML page on stdout.
package main

import (
	"bytes"
	"fmt"
	"io"
	"os"

	"github.com/yuin/goldmark"
	"github.com/yuin/goldmark/renderer/html"
)

func main() {
	src, err := io.ReadAll(os.Stdin)
	if err != nil {
		fmt.Fprintf(os.Stderr, "docgen: reading stdin: %v\n", err)
		os.Exit(1)
	}

	md := goldmark.New(
		goldmark.WithRendererOptions(
			html.WithUnsafe(),
		),
	)

	var buf bytes.Buffer
	if err := md.Convert(src, &buf); err != nil {
		fmt.Fprintf(os.Stderr, "docgen: converting markdown: %v\n", err)
		os.Exit(1)
	}

	fmt.Print(`<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>yosina – Go API Reference</title>
<style>
body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; max-width: 960px; margin: 0 auto; padding: 2rem; line-height: 1.6; color: #24292f; }
code, pre { font-family: SFMono-Regular, Consolas, "Liberation Mono", Menlo, monospace; }
pre { background: #f6f8fa; padding: 1rem; overflow-x: auto; border-radius: 6px; }
code { background: #f6f8fa; padding: 0.2em 0.4em; border-radius: 3px; font-size: 85%; }
pre code { background: none; padding: 0; font-size: 100%; }
a { color: #0969da; text-decoration: none; }
a:hover { text-decoration: underline; }
h1, h2, h3 { border-bottom: 1px solid #d0d7de; padding-bottom: 0.3em; }
</style>
</head>
<body>
`)
	buf.WriteTo(os.Stdout)
	fmt.Print(`
</body>
</html>
`)
}
