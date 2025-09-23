# Yosina Project Makefile - Monitors data changes and regenerates source code
#
# This Makefile watches for changes in the data/ directory and automatically
# regenerates the relevant source code files for each language implementation.

# Default shell
SHELL := /bin/bash

# Directories
DATA_DIR := data
LANGUAGES := csharp dart go java javascript php python ruby rust swift

# Static list of JSON data files
DATA_FILES := \
	$(DATA_DIR)/spaces.json \
	$(DATA_DIR)/radicals.json \
	$(DATA_DIR)/mathematical-alphanumerics.json \
	$(DATA_DIR)/ideographic-annotation-marks.json \
	$(DATA_DIR)/kanji-old-new-form.json \
	$(DATA_DIR)/hyphens.json \
	$(DATA_DIR)/ivs-svs-base-mappings.json \
	$(DATA_DIR)/combined-chars.json \
	$(DATA_DIR)/circled-or-squared.json \
	$(DATA_DIR)/roman-numerals.json

# Generated files for each language
GO_GENERATED := \
	go/transliterators/spaces/impl.go \
	go/transliterators/radicals/impl.go \
	go/transliterators/mathematical_alphanumerics/impl.go \
	go/transliterators/ideographic_annotations/impl.go \
	go/transliterators/kanji_old_new/impl.go \
	go/transliterators/hyphens/impl.go \
	go/transliterators/ivs_svs_base/impl.go \
	go/transliterators/combined/impl.go \
	go/transliterators/circled_or_squared/impl.go \
	go/transliterators/roman_numerals/impl.go

JAVASCRIPT_GENERATED := \
	javascript/src/transliterators/spaces.ts \
	javascript/src/transliterators/radicals.ts \
	javascript/src/transliterators/mathematical-alphanumerics.ts \
	javascript/src/transliterators/ideographic-annotations.ts \
	javascript/src/transliterators/kanji-old-new.ts \
	javascript/src/transliterators/hyphens.ts \
	javascript/src/transliterators/ivs-svs-base.ts \
	javascript/src/transliterators/combined.ts \
	javascript/src/transliterators/circled-or-squared.ts \
	javascript/src/transliterators/roman-numerals.ts

PYTHON_GENERATED := \
	python/src/yosina/transliterators/spaces.py \
	python/src/yosina/transliterators/radicals.py \
	python/src/yosina/transliterators/mathematical_alphanumerics.py \
	python/src/yosina/transliterators/ideographic_annotations.py \
	python/src/yosina/transliterators/kanji_old_new.py \
	python/src/yosina/transliterators/hyphens_data.py \
	python/src/yosina/transliterators/ivs_svs_base_data.py \
	python/src/yosina/transliterators/combined.py \
	python/src/yosina/transliterators/circled_or_squared.py \
	python/src/yosina/transliterators/roman_numerals.py

RUBY_GENERATED := \
	ruby/lib/yosina/transliterators/spaces.rb \
	ruby/lib/yosina/transliterators/radicals.rb \
	ruby/lib/yosina/transliterators/mathematical_alphanumerics.rb \
	ruby/lib/yosina/transliterators/ideographic_annotations.rb \
	ruby/lib/yosina/transliterators/kanji_old_new.rb \
	ruby/lib/yosina/transliterators/hyphens_data.rb \
	ruby/lib/yosina/transliterators/ivs_svs_base_data.rb \
	ruby/lib/yosina/transliterators/combined.rb \
	ruby/lib/yosina/transliterators/circled_or_squared.rb \
	ruby/lib/yosina/transliterators/roman_numerals.rb

RUST_GENERATED := \
	rust/src/transliterators/spaces.rs \
	rust/src/transliterators/radicals.rs \
	rust/src/transliterators/mathematical_alphanumerics.rs \
	rust/src/transliterators/ideographic_annotations.rs \
	rust/src/transliterators/kanji_old_new.rs \
	rust/src/transliterators/hyphens_data.rs \
	rust/src/transliterators/ivs_svs_base_data.rs \
	rust/src/transliterators/combined.rs \
	rust/src/transliterators/circled_or_squared_data.rs \
	rust/src/transliterators/roman_numerals.rs \
	rust/src/transliterators/roman_numerals_data.rs

PHP_GENERATED := \
	php/src/Transliterators/SpacesTransliterator.php \
	php/src/Transliterators/RadicalsTransliterator.php \
	php/src/Transliterators/MathematicalAlphanumericsTransliterator.php \
	php/src/Transliterators/IdeographicAnnotationsTransliterator.php \
	php/src/Transliterators/KanjiOldNewTransliterator.php \
	php/src/Transliterators/HyphensTransliterator.php \
	php/src/Transliterators/ivs_svs_base.data \
	php/src/Transliterators/CombinedTransliterator.php \
	php/src/Transliterators/CircledOrSquaredTransliterator.php \
	php/src/Transliterators/RomanNumeralsTransliterator.php

CSHARP_GENERATED := \
	csharp/src/Yosina/Transliterators/SpacesTransliterator.cs \
	csharp/src/Yosina/Transliterators/RadicalsTransliterator.cs \
	csharp/src/Yosina/Transliterators/MathematicalAlphanumericsTransliterator.cs \
	csharp/src/Yosina/Transliterators/IdeographicAnnotationsTransliterator.cs \
	csharp/src/Yosina/Transliterators/KanjiOldNewTransliterator.cs \
	csharp/src/Yosina/Transliterators/HyphensTransliterator.cs \
	csharp/src/Yosina/Transliterators/ivs_svs_base.data \
	csharp/src/Yosina/Transliterators/CombinedTransliterator.cs \
	csharp/src/Yosina/Transliterators/CircledOrSquaredTransliterator.cs \
	csharp/src/Yosina/Transliterators/RomanNumeralsTransliterator.cs

JAVA_GENERATED := \
	java/src/main/java/lib/yosina/transliterators/SpacesTransliterator.java \
	java/src/main/java/lib/yosina/transliterators/RadicalsTransliterator.java \
	java/src/main/java/lib/yosina/transliterators/MathematicalAlphanumericsTransliterator.java \
	java/src/main/java/lib/yosina/transliterators/IdeographicAnnotationsTransliterator.java \
	java/src/main/java/lib/yosina/transliterators/KanjiOldNewTransliterator.java \
	java/src/main/java/lib/yosina/transliterators/HyphensTransliterator.java \
	java/src/main/java/lib/yosina/transliterators/IvsSvsBaseTransliterator.java \
	java/src/main/java/lib/yosina/transliterators/Combined.java \
	java/src/main/java/lib/yosina/transliterators/CircledOrSquared.java \
	java/src/main/java/lib/yosina/transliterators/RomanNumeralsTransliterator.java \
	java/src/main/resources/lib/yosina/transliterators/spaces.data \
	java/src/main/resources/lib/yosina/transliterators/radicals.data \
	java/src/main/resources/lib/yosina/transliterators/mathematical_alphanumerics.data \
	java/src/main/resources/lib/yosina/transliterators/ideographic_annotations.data \
	java/src/main/resources/lib/yosina/transliterators/kanji_old_new.data \
	java/src/main/resources/lib/yosina/transliterators/ivs_svs_base.data \
	java/src/main/resources/lib/yosina/transliterators/combined.data \
	java/src/main/resources/lib/yosina/transliterators/circled_or_squared.data \
	java/src/main/resources/lib/yosina/transliterators/roman_numerals.data

DART_GENERATED := \
	dart/lib/src/transliterators/spaces_transliterator.dart \
	dart/lib/src/transliterators/radicals_transliterator.dart \
	dart/lib/src/transliterators/mathematical_alphanumerics_transliterator.dart \
	dart/lib/src/transliterators/ideographic_annotations_transliterator.dart \
	dart/lib/src/transliterators/kanji_old_new_transliterator.dart \
	dart/lib/src/transliterators/hyphens_data.dart \
	dart/lib/src/transliterators/ivs_svs_base.data \
	dart/lib/src/transliterators/combined_transliterator.dart \
	dart/lib/src/transliterators/circled_or_squared_data.dart \
	dart/lib/src/transliterators/roman_numerals_transliterator.dart

SWIFT_GENERATED := \
	swift/Sources/Yosina/Transliterators/SpacesTransliterator.swift \
	swift/Sources/Yosina/Transliterators/RadicalsTransliterator.swift \
	swift/Sources/Yosina/Transliterators/MathematicalAlphanumericsTransliterator.swift \
	swift/Sources/Yosina/Transliterators/IdeographicAnnotationsTransliterator.swift \
	swift/Sources/Yosina/Transliterators/KanjiOldNewTransliterator.swift \
	swift/Sources/Yosina/Transliterators/HyphensTransliterator.swift \
	swift/Sources/Yosina/Transliterators/IvsSvsBaseTransliterator.swift \
	swift/Sources/Yosina/Transliterators/CombinedTransliterator.swift \
	swift/Sources/Yosina/Transliterators/CircledOrSquaredTransliterator.swift \
	swift/Sources/Yosina/Transliterators/RomanNumeralsTransliterator.swift \

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Default target
.PHONY: all
all: codegen

.PHONY: clean
clean: codegen-clean

# Generate all language implementations
.PHONY: codegen
codegen: codegen-csharp codegen-dart codegen-go codegen-java codegen-javascript codegen-php codegen-python codegen-ruby codegen-rust codegen-swift
	@echo -e "$(GREEN)✓ All language implementations regenerated$(NC)"

# Clean all generated files
.PHONY: codegen-clean
codegen-clean:
	@echo -e "$(YELLOW)Cleaning generated files...$(NC)"
	@rm -f $(ALL_GENERATED)
	@echo -e "$(GREEN)✓ Clean complete$(NC)"

# Rule to generate all files when data changes
$(GO_GENERATED) &:: $(DATA_FILES)
	@echo -e "$(BLUE)Generating Go code...$(NC)"
	@cd go && go run internal/codegen/main.go && go fmt ./...
	@echo -e "$(GREEN)✓ Go code generation complete$(NC)"

.PHONY: codegen-go
codegen-go: $(GO_GENERATED)

$(JAVASCRIPT_GENERATED) &:: $(DATA_FILES)
	@echo -e "$(BLUE)Generating JavaScript/TypeScript code...$(NC)"
	@cd javascript && npm run codegen && npm run format && npm run check -- --fix
	@echo -e "$(GREEN)✓ JavaScript/TypeScript code generation complete$(NC)"

.PHONY: codegen-javascript
codegen-javascript: $(JAVASCRIPT_GENERATED)

$(PYTHON_GENERATED) &:: $(DATA_FILES)
	@echo -e "$(BLUE)Generating Python code...$(NC)"
	@cd python && python -m codegen && uv run ruff format
	@echo -e "$(GREEN)✓ Python code generation complete$(NC)"

.PHONY: codegen-python
codegen-python: $(PYTHON_GENERATED)

$(RUBY_GENERATED) &:: $(DATA_FILES)
	@echo -e "$(BLUE)Generating Ruby code...$(NC)"
	@cd ruby && bundle exec ruby codegen/main.rb && bundle exec rake rubocop:autocorrect_all
	@echo -e "$(GREEN)✓ Ruby code generation complete$(NC)"

.PHONY: codegen-ruby
codegen-ruby: $(RUBY_GENERATED)

$(RUST_GENERATED) &:: $(DATA_FILES)
	@echo -e "$(BLUE)Generating Rust code...$(NC)"
	@cd rust && cargo run -F codegen --bin codegen && cargo fmt
	@echo -e "$(GREEN)✓ Rust code generation complete$(NC)"

.PHONY: codegen-rust
codegen-rust: $(RUST_GENERATED)

$(PHP_GENERATED) &:: $(DATA_FILES)
	@echo -e "$(BLUE)Generating PHP code...$(NC)"
	@cd php && composer exec php codegen/generate.php && composer cs-fix
	@echo -e "$(GREEN)✓ PHP code generation complete$(NC)"

.PHONY: codegen-php
codegen-php: $(PHP_GENERATED)

$(CSHARP_GENERATED) &:: $(DATA_FILES)
	@echo -e "$(BLUE)Generating C# code...$(NC)"
	@cd csharp && dotnet run --project src/Yosina.Codegen/Yosina.Codegen.csproj && $(MAKE) format
	@echo -e "$(GREEN)✓ C# code generation complete$(NC)"

.PHONY: codegen-csharp
codegen-csharp: $(CSHARP_GENERATED)

$(JAVA_GENERATED) &:: $(DATA_FILES)
	@echo -e "$(BLUE)Generating Java code...$(NC)"
	@cd java && gradle :codegen:run && gradle spotlessApply
	@echo -e "$(GREEN)✓ Java code generation complete$(NC)"

.PHONY: codegen-java
codegen-java: $(JAVA_GENERATED)

$(DART_GENERATED) &:: $(DATA_FILES)
	@echo -e "$(BLUE)Generating Dart code...$(NC)"
	@cd dart && dart run codegen/generate.dart && dart fix --apply . && dart format .
	@echo -e "$(GREEN)✓ Dart code generation complete$(NC)"

.PHONY: codegen-dart
codegen-dart: $(DART_GENERATED)

$(SWIFT_GENERATED) &:: $(DATA_FILES)
	@echo -e "$(BLUE)Generating Swift code...$(NC)"
	@cd swift/codegen && swift run && cd .. && swiftformat Sources/
	@echo -e "$(GREEN)✓ Swift code generation complete$(NC)"

.PHONY: codegen-swift
codegen-swift: $(SWIFT_GENERATED)

# Documentation generation targets for individual languages
.PHONY: docs-csharp
docs-csharp: $(CSHARP_DOC_MARKER)
	@echo -e "$(GREEN)✓ C# documentation generated$(NC)"

.PHONY: docs-go
docs-go: $(GO_DOC_MARKER)
	@echo -e "$(GREEN)✓ Go documentation generated$(NC)"

.PHONY: docs-java
docs-java: $(JAVA_DOC_MARKER)
	@echo -e "$(GREEN)✓ Java documentation generated$(NC)"

.PHONY: docs-javascript
docs-javascript: $(JAVASCRIPT_DOC_MARKER)
	@echo -e "$(GREEN)✓ JavaScript documentation generated$(NC)"

.PHONY: docs-php
docs-php: $(PHP_DOC_MARKER)
	@echo -e "$(GREEN)✓ PHP documentation generated$(NC)"

.PHONY: docs-python
docs-python: $(PYTHON_DOC_MARKER)
	@echo -e "$(GREEN)✓ Python documentation generated$(NC)"

.PHONY: docs-ruby
docs-ruby: $(RUBY_DOC_MARKER)
	@echo -e "$(GREEN)✓ Ruby documentation generated$(NC)"

.PHONY: docs-rust
docs-rust: $(RUST_DOC_MARKER)
	@echo -e "$(GREEN)✓ Rust documentation generated$(NC)"

.PHONY: docs-dart
docs-dart: $(DART_DOC_MARKER)
	@echo -e "$(GREEN)✓ Dart documentation generated$(NC)"

.PHONY: docs-swift
docs-swift: $(SWIFT_DOC_MARKER)
	@echo -e "$(GREEN)✓ Swift documentation generated$(NC)"

.PHONY: help
help:
	@echo -e "$(BLUE)Yosina Project Makefile$(NC)"
	@echo ""
	@echo "This Makefile monitors changes in the data/ directory and regenerates"
	@echo "source code for each language implementation when updates are detected."
	@echo ""
	@echo -e "$(YELLOW)Available targets:$(NC)"
	@echo "  make                    - Check for updates and regenerate if needed"
	@echo "  make generate-all       - Regenerate all language implementations"
	@echo "  make generate-<lang>    - Regenerate specific language (e.g., generate-go)"
	@echo "                           Available: csharp dart go java javascript php python ruby rust swift"
	@echo "  make force-generate     - Force regeneration of all languages"
	@echo "  make generate-data      - Run data generation in data/ directory"
	@echo "  make docs               - Build and collect API documentation for all languages"
	@echo "  make docs-<lang>        - Build documentation for specific language (e.g., docs-go)"
	@echo "  make clean-docs         - Remove all generated documentation"
	@echo "  make clean-all          - Remove all generated files and documentation"
	@echo "  make help               - Show this help message"
	@echo ""
	@echo -e "$(YELLOW)Supported languages:$(NC) $(LANGUAGES)"

# Install dependencies for all languages
.PHONY: install-deps
install-deps:
	@echo -e "$(BLUE)Installing dependencies for all languages...$(NC)"
	@# C#
	@echo -e "$(YELLOW)Installing C# dependencies...$(NC)"
	@cd csharp && dotnet restore
	@# Go
	@echo -e "$(YELLOW)Installing Go dependencies...$(NC)"
	@cd go && go mod download
	@# JavaScript
	@echo -e "$(YELLOW)Installing JavaScript dependencies...$(NC)"
	@cd javascript && npm install
	@# PHP
	@echo -e "$(YELLOW)Installing PHP dependencies...$(NC)"
	@cd php && composer install
	@# Python
	@echo -e "$(YELLOW)Installing Python dependencies...$(NC)"
	@cd python && uv sync
	@# Ruby
	@echo -e "$(YELLOW)Installing Ruby dependencies...$(NC)"
	@cd ruby && bundle install
	@# Rust
	@echo -e "$(YELLOW)Checking Rust dependencies...$(NC)"
	@cd rust && cargo check
	@# Dart
	@echo -e "$(YELLOW)Installing Dart dependencies...$(NC)"
	@cd dart && dart pub get
	@# Swift
	@echo -e "$(YELLOW)Resolving Swift dependencies...$(NC)"
	@cd swift && swift package resolve
	@echo -e "$(GREEN)✓ All dependencies installed$(NC)"

# API Documentation targets
DOCS_DIR := _site/api

# Documentation marker files (indicate successful build)
JAVASCRIPT_DOC_MARKER := javascript/docs/index.html
CSHARP_DOC_MARKER := csharp/docs/_site/index.html
PYTHON_DOC_MARKER := python/docs/build/html/index.html
RUBY_DOC_MARKER := ruby/doc/index.html
RUST_DOC_MARKER := rust/target/doc/yosina/index.html
JAVA_DOC_MARKER := java/build/docs/javadoc/index.html
PHP_DOC_MARKER := php/docs/index.html
GO_DOC_MARKER := go/docs/index.html
DART_DOC_MARKER := dart/doc/api/index.html
SWIFT_DOC_MARKER := swift/.build/documentation/yosina/index.html

# Collected documentation markers
JAVASCRIPT_COLLECTED := $(DOCS_DIR)/javascript/index.html
CSHARP_COLLECTED := $(DOCS_DIR)/csharp/index.html
PYTHON_COLLECTED := $(DOCS_DIR)/python/index.html
RUBY_COLLECTED := $(DOCS_DIR)/ruby/index.html
RUST_COLLECTED := $(DOCS_DIR)/rust/index.html
JAVA_COLLECTED := $(DOCS_DIR)/java/index.html
PHP_COLLECTED := $(DOCS_DIR)/php/index.html
DART_COLLECTED := $(DOCS_DIR)/dart/index.html
SWIFT_COLLECTED := $(DOCS_DIR)/swift/index.html

ALL_DOC_MARKERS := $(JAVASCRIPT_DOC_MARKER) $(CSHARP_DOC_MARKER) $(PYTHON_DOC_MARKER) \
	$(RUBY_DOC_MARKER) $(RUST_DOC_MARKER) $(JAVA_DOC_MARKER) $(PHP_DOC_MARKER) \
	$(DART_DOC_MARKER) $(SWIFT_DOC_MARKER)

ALL_COLLECTED := $(JAVASCRIPT_COLLECTED) $(CSHARP_COLLECTED) $(PYTHON_COLLECTED) \
	$(RUBY_COLLECTED) $(RUST_COLLECTED) $(JAVA_COLLECTED) $(GO_COLLECTED) $(PHP_COLLECTED) \
	$(DART_COLLECTED) $(SWIFT_COLLECTED)

# Main documentation target
.PHONY: docs
docs: $(ALL_COLLECTED)
	@echo -e "$(GREEN)✓ API documentation complete$(NC)"

$(JAVASCRIPT_COLLECTED): $(JAVASCRIPT_DOC_MARKER)
	@mkdir -p $(DOCS_DIR)
	echo -e "$(YELLOW)Copying JavaScript API docs...$(NC)"; \
	cp -r javascript/docs $(DOCS_DIR)/javascript; \
	echo -e "$(GREEN)✓ JavaScript docs copied$(NC)"; \

$(CSHARP_COLLECTED): $(CSHARP_DOC_MARKER)
	@mkdir -p $(DOCS_DIR)
	echo -e "$(YELLOW)Copying C# API docs...$(NC)"; \
	cp -r csharp/docs/_site $(DOCS_DIR)/csharp; \
	echo -e "$(GREEN)✓ C# docs copied$(NC)"; \

$(PYTHON_COLLECTED): $(PYTHON_DOC_MARKER)
	@mkdir -p $(DOCS_DIR)
	echo -e "$(YELLOW)Copying Python API docs...$(NC)"; \
	cp -r python/docs/build/html $(DOCS_DIR)/python; \
	echo -e "$(GREEN)✓ Python docs copied$(NC)"; \

$(RUBY_COLLECTED): $(RUBY_DOC_MARKER)
	@mkdir -p $(DOCS_DIR)
	echo -e "$(YELLOW)Copying Ruby API docs...$(NC)"; \
	cp -r ruby/doc $(DOCS_DIR)/ruby; \
	echo -e "$(GREEN)✓ Ruby docs copied$(NC)"; \

$(RUST_COLLECTED): $(RUST_DOC_MARKER)
	@mkdir -p $(DOCS_DIR)
	echo -e "$(YELLOW)Copying Rust API docs...$(NC)"; \
	cp -r rust/target/doc $(DOCS_DIR)/rust; \
	echo -e "$(GREEN)✓ Rust docs copied$(NC)"; \

$(JAVA_COLLECTED): $(JAVA_DOC_MARKER)
	@mkdir -p $(DOCS_DIR)
	echo -e "$(YELLOW)Copying Java API docs...$(NC)"; \
	cp -r java/build/docs/javadoc $(DOCS_DIR)/java; \
	echo -e "$(GREEN)✓ Java docs copied$(NC)"; \

$(PHP_COLLECTED): $(PHP_DOC_MARKER)
	@mkdir -p $(DOCS_DIR)
	echo -e "$(YELLOW)Copying PHP API docs...$(NC)"; \
	cp -r php/docs $(DOCS_DIR)/php; \
	echo -e "$(GREEN)✓ PHP docs copied$(NC)"; \

$(DART_COLLECTED): $(DART_DOC_MARKER)
	@mkdir -p $(DOCS_DIR)
	echo -e "$(YELLOW)Copying Dart API docs...$(NC)"; \
	cp -r dart/doc/api $(DOCS_DIR)/dart; \
	echo -e "$(GREEN)✓ Dart docs copied$(NC)"; \

$(SWIFT_COLLECTED): $(SWIFT_DOC_MARKER)
	@mkdir -p $(DOCS_DIR)
	echo -e "$(YELLOW)Copying Swift API docs...$(NC)"; \
	cp -r swift/.build/documentation/yosina $(DOCS_DIR)/swift; \
	echo -e "$(GREEN)✓ Swift docs copied$(NC)"; \

# Individual language documentation build rules
$(JAVASCRIPT_DOC_MARKER): $(JAVASCRIPT_GENERATED)
	@echo -e "$(BLUE)Building JavaScript API docs...$(NC)"
	@cd javascript && npm run docs:build

$(CSHARP_DOC_MARKER): $(CSHARP_GENERATED)
	@echo -e "$(BLUE)Building C# API docs...$(NC)"
	@cd csharp && docfx docs/docfx.json

$(PYTHON_DOC_MARKER): $(PYTHON_GENERATED)
	@echo -e "$(BLUE)Building Python API docs...$(NC)"
	@cd python/docs && uv run make clean html

$(RUBY_DOC_MARKER): $(RUBY_GENERATED)
	@echo -e "$(BLUE)Building Ruby API docs...$(NC)"
	@cd ruby && bundle exec rake yard

$(RUST_DOC_MARKER): $(RUST_GENERATED)
	@echo -e "$(BLUE)Building Rust API docs...$(NC)"
	@cd rust && cargo doc --no-deps

$(JAVA_DOC_MARKER): $(JAVA_GENERATED)
	@echo -e "$(BLUE)Building Java API docs...$(NC)"
	@cd java && gradle javadoc

$(PHP_DOC_MARKER): $(PHP_GENERATED)
	@echo -e "$(BLUE)Building PHP API docs...$(NC)"
	@cd php && ./vendor/bin/phpdoc -d src -t docs --quiet

$(DART_DOC_MARKER): $(DART_GENERATED)
	@echo -e "$(BLUE)Building Dart API docs...$(NC)"
	@cd dart && dart doc

$(SWIFT_DOC_MARKER): $(SWIFT_GENERATED)
	@echo -e "$(BLUE)Building Swift API docs...$(NC)"
	@cd swift && swift-docc generate --target Yosina --output-path .build/documentation

.PHONY: sync-split-repos
sync-split-repos: sync-split-repo-php sync-split-repo-swift

.PHONY: sync-split-repo-php
sync-split-repo-php:
	git push git@github.com:yosina-lib/yosina-php.git -f $(shell git subtree split --prefix php):refs/heads/main

.PHONY: sync-split-repo-swift
sync-split-repo-swift:
	git push git@github.com:yosina-lib/yosina-swift.git -f $(shell git subtree split --prefix swift):refs/heads/main

# Clean documentation
.PHONY: clean-docs
clean-docs:
	@echo -e "$(YELLOW)Cleaning documentation...$(NC)"
	@rm -rf $(DOCS_DIR)
	@rm -rf javascript/docs csharp/docs/_site python/docs/build ruby/doc rust/target/doc java/build/docs php/docs go/docs dart/doc swift/.build/documentation
	@echo -e "$(GREEN)✓ Documentation cleaned$(NC)"

# Clean all (including documentation)
.PHONY: clean-all
clean-all: clean clean-docs
	@echo -e "$(GREEN)✓ Full clean complete$(NC)"

# Version management
.PHONY: update-version
update-version:
	@if [ -z "$(VERSION)" ]; then \
		echo -e "$(RED)Error: VERSION parameter is required$(NC)"; \
		echo "Usage: make update-version VERSION=x.y.z"; \
		exit 1; \
	fi
	@echo -e "$(BLUE)Updating version to $(VERSION)...$(NC)"
	@# Update package files
	@sed -i.bak 's/<Version>.*<\/Version>/<Version>$(VERSION)<\/Version>/' csharp/src/Yosina/Yosina.csproj && rm csharp/src/Yosina/Yosina.csproj.bak
	@sed -i.bak 's/^version: .*/version: $(VERSION)/' dart/pubspec.yaml && rm dart/pubspec.yaml.bak
	@sed -i.bak 's/"version": "[^"]*"/"version": "$(VERSION)"/' javascript/package.json && rm javascript/package.json.bak
	@sed -i.bak 's/"version": "[^"]*"/"version": "$(VERSION)"/' php/composer.json && rm php/composer.json.bak
	@sed -i.bak 's/^version = ".*"/version = "$(VERSION)"/' python/pyproject.toml && rm python/pyproject.toml.bak
	@sed -i.bak 's/VERSION = .*/VERSION = "$(VERSION)"/' ruby/lib/yosina/version.rb && rm ruby/lib/yosina/version.rb.bak
	@sed -i.bak 's/^version = ".*"/version = "$(VERSION)"/' rust/Cargo.toml && rm rust/Cargo.toml.bak
	@sed -i.bak "s/version = '[^']*'/version = '$(VERSION)'/" java/build.gradle && rm java/build.gradle.bak
	@# Update README files
	@sed -i.bak 's/yosina = "[^"]*"/yosina = "$(VERSION)"/' README.md && rm README.md.bak
	@sed -i.bak 's/yosina = "[^"]*"/yosina = "$(VERSION)"/' README.ja.md && rm README.ja.md.bak
	@sed -i.bak "s/yosina-java:[^']*'/yosina-java:$(VERSION)'/" README.md && rm README.md.bak
	@sed -i.bak "s/yosina-java:[^']*'/yosina-java:$(VERSION)'/" README.ja.md && rm README.ja.md.bak
	@# Update language-specific README files
	@sed -i.bak 's/yosina: \^[0-9.]*/yosina: ^$(VERSION)/' dart/README.md dart/README.ja.md && rm dart/README.md.bak dart/README.ja.md.bak
	@sed -i.bak "s/yosina-java:[^']*'/yosina-java:$(VERSION)'/" java/README.md java/README.ja.md && rm java/README.md.bak java/README.ja.md.bak
	@sed -i.bak 's/yosina = "[^"]*"/yosina = "$(VERSION)"/' rust/README.md rust/README.ja.md && rm rust/README.md.bak rust/README.ja.md.bak
	@sed -i.bak 's/from: "[^"]*"/from: "$(VERSION)"/' swift/README.md && rm swift/README.md.bak
	@echo -e "$(GREEN)✓ Version updated to $(VERSION)$(NC)"

# Publishing targets
.PHONY: publish-all
publish-all: publish-csharp publish-dart publish-java publish-javascript publish-python publish-ruby publish-rust
	@echo -e "$(GREEN)✓ All packages published$(NC)"

.PHONY: publish-csharp
publish-csharp:
	@echo -e "$(BLUE)Publishing C# package to NuGet...$(NC)"
	@cd csharp && dotnet pack -c Release src/Yosina/Yosina.csproj && dotnet nuget push bin/Release/Yosina.*.nupkg --source https://api.nuget.org/v3/index.json --api-key $(NUGET_API_KEY)

.PHONY: publish-dart
publish-dart:
	@echo -e "$(BLUE)Publishing Dart package to pub.dev...$(NC)"
	@cd dart && dart pub publish

.PHONY: publish-java
publish-java:
	@echo -e "$(BLUE)Publishing Java package to Maven Central...$(NC)"
	@cd java && gradle publish

.PHONY: publish-javascript
publish-javascript:
	@echo -e "$(BLUE)Publishing JavaScript package to npm...$(NC)"
	@cd javascript && npm publish

.PHONY: publish-python
publish-python:
	@echo -e "$(BLUE)Publishing Python package to PyPI...$(NC)"
	@cd python && uv build && uv publish

.PHONY: publish-ruby
publish-ruby:
	@echo -e "$(BLUE)Publishing Ruby gem to RubyGems...$(NC)"
	@cd ruby && gem build yosina.gemspec && gem push yosina-*.gem

.PHONY: publish-rust
publish-rust:
	@echo -e "$(BLUE)Publishing Rust crate to crates.io...$(NC)"
	@cd rust && cargo publish
