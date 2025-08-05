# Yosina Project Makefile - Monitors data changes and regenerates source code
#
# This Makefile watches for changes in the data/ directory and automatically
# regenerates the relevant source code files for each language implementation.

# Default shell
SHELL := /bin/bash

# Directories
DATA_DIR := data
LANGUAGES := csharp go java javascript php python ruby rust

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
	$(DATA_DIR)/circled-or-squared.json

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
	go/transliterators/circled_or_squared/impl.go

JAVASCRIPT_GENERATED := \
	javascript/src/transliterators/spaces.ts \
	javascript/src/transliterators/radicals.ts \
	javascript/src/transliterators/mathematical-alphanumerics.ts \
	javascript/src/transliterators/ideographic-annotations.ts \
	javascript/src/transliterators/kanji-old-new.ts \
	javascript/src/transliterators/hyphens.ts \
	javascript/src/transliterators/ivs-svs-base.ts \
	javascript/src/transliterators/combined.ts \
	javascript/src/transliterators/circled-or-squared.ts

PYTHON_GENERATED := \
	python/src/yosina/transliterators/spaces.py \
	python/src/yosina/transliterators/radicals.py \
	python/src/yosina/transliterators/mathematical_alphanumerics.py \
	python/src/yosina/transliterators/ideographic_annotations.py \
	python/src/yosina/transliterators/kanji_old_new.py \
	python/src/yosina/transliterators/hyphens_data.py \
	python/src/yosina/transliterators/ivs_svs_base_data.py \
	python/src/yosina/transliterators/combined.py \
	python/src/yosina/transliterators/circled_or_squared.py

RUBY_GENERATED := \
	ruby/lib/yosina/transliterators/spaces.rb \
	ruby/lib/yosina/transliterators/radicals.rb \
	ruby/lib/yosina/transliterators/mathematical_alphanumerics.rb \
	ruby/lib/yosina/transliterators/ideographic_annotations.rb \
	ruby/lib/yosina/transliterators/kanji_old_new.rb \
	ruby/lib/yosina/transliterators/hyphens_data.rb \
	ruby/lib/yosina/transliterators/ivs_svs_base_data.rb \
	ruby/lib/yosina/transliterators/combined.rb \
	ruby/lib/yosina/transliterators/circled_or_squared.rb

RUST_GENERATED := \
	rust/src/transliterators/spaces.rs \
	rust/src/transliterators/radicals.rs \
	rust/src/transliterators/mathematical_alphanumerics.rs \
	rust/src/transliterators/ideographic_annotations.rs \
	rust/src/transliterators/kanji_old_new.rs \
	rust/src/transliterators/hyphens_data.rs \
	rust/src/transliterators/ivs_svs_base_data.rs \
	rust/src/transliterators/combined.rs \
	rust/src/transliterators/circled_or_squared_data.rs

PHP_GENERATED := \
	php/src/Transliterators/SpacesTransliterator.php \
	php/src/Transliterators/RadicalsTransliterator.php \
	php/src/Transliterators/MathematicalAlphanumericsTransliterator.php \
	php/src/Transliterators/IdeographicAnnotationsTransliterator.php \
	php/src/Transliterators/KanjiOldNewTransliterator.php \
	php/src/Transliterators/HyphensTransliterator.php \
	php/src/Transliterators/ivs_svs_base.data \
	php/src/Transliterators/CombinedTransliterator.php \
	php/src/Transliterators/CircledOrSquaredTransliterator.php

CSHARP_GENERATED := \
	csharp/src/Yosina/Transliterators/SpacesTransliterator.cs \
	csharp/src/Yosina/Transliterators/RadicalsTransliterator.cs \
	csharp/src/Yosina/Transliterators/MathematicalAlphanumericsTransliterator.cs \
	csharp/src/Yosina/Transliterators/IdeographicAnnotationsTransliterator.cs \
	csharp/src/Yosina/Transliterators/KanjiOldNewTransliterator.cs \
	csharp/src/Yosina/Transliterators/HyphensTransliterator.cs \
	csharp/src/Yosina/Transliterators/ivs_svs_base.data \
	csharp/src/Yosina/Transliterators/CombinedTransliterator.cs \
	csharp/src/Yosina/Transliterators/CircledOrSquaredTransliterator.cs

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
	java/src/main/resources/lib/yosina/transliterators/spaces.data \
	java/src/main/resources/lib/yosina/transliterators/radicals.data \
	java/src/main/resources/lib/yosina/transliterators/mathematical_alphanumerics.data \
	java/src/main/resources/lib/yosina/transliterators/ideographic_annotations.data \
	java/src/main/resources/lib/yosina/transliterators/kanji_old_new.data \
	java/src/main/resources/lib/yosina/transliterators/ivs_svs_base.data \
	java/src/main/resources/lib/yosina/transliterators/combined.data \
	java/src/main/resources/lib/yosina/transliterators/circled_or_squared.data

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# All generated files
ALL_GENERATED := $(GO_GENERATED) $(JAVASCRIPT_GENERATED) $(PYTHON_GENERATED) \
	$(RUBY_GENERATED) $(RUST_GENERATED) $(PHP_GENERATED) \
	$(CSHARP_GENERATED) $(JAVA_GENERATED)

# Default target
.PHONY: all
all: $(ALL_GENERATED)

# Generate all language implementations
.PHONY: generate-all
generate-all: $(ALL_GENERATED)
	@echo -e "$(GREEN)✓ All language implementations regenerated$(NC)"

# Clean all generated files
.PHONY: clean
clean:
	@echo -e "$(YELLOW)Cleaning generated files...$(NC)"
	@rm -f $(ALL_GENERATED)
	@echo -e "$(GREEN)✓ Clean complete$(NC)"

# Generate data files
.PHONY: generate-data
generate-data:
	@echo -e "$(BLUE)Generating data files...$(NC)"
	@cd $(DATA_DIR) && $(MAKE) all
	@echo -e "$(GREEN)✓ Data files generation complete$(NC)"

# Force regeneration of all languages
.PHONY: force-generate
force-generate: clean generate-all

# Rule to generate all files when data changes
$(GO_GENERATED): $(DATA_FILES)
	@echo -e "$(BLUE)Generating Go code...$(NC)"
	@cd go && go run internal/codegen/main.go && go fmt ./...
	@echo -e "$(GREEN)✓ Go code generation complete$(NC)"

$(JAVASCRIPT_GENERATED): $(DATA_FILES)
	@echo -e "$(BLUE)Generating JavaScript/TypeScript code...$(NC)"
	@cd javascript && npm run codegen && npm run format && npm run check -- --fix
	@echo -e "$(GREEN)✓ JavaScript/TypeScript code generation complete$(NC)"

$(PYTHON_GENERATED): $(DATA_FILES)
	@echo -e "$(BLUE)Generating Python code...$(NC)"
	@cd python && python -m codegen && uv run ruff format
	@echo -e "$(GREEN)✓ Python code generation complete$(NC)"

$(RUBY_GENERATED): $(DATA_FILES)
	@echo -e "$(BLUE)Generating Ruby code...$(NC)"
	@cd ruby && bundle exec ruby codegen/main.rb && bundle exec rake rubocop:autocorrect_all
	@echo -e "$(GREEN)✓ Ruby code generation complete$(NC)"

$(RUST_GENERATED): $(DATA_FILES)
	@echo -e "$(BLUE)Generating Rust code...$(NC)"
	@cd rust && cargo run -F codegen --bin codegen && cargo fmt
	@echo -e "$(GREEN)✓ Rust code generation complete$(NC)"

$(PHP_GENERATED): $(DATA_FILES)
	@echo -e "$(BLUE)Generating PHP code...$(NC)"
	@cd php && composer exec php codegen/generate.php && composer cs-fix
	@echo -e "$(GREEN)✓ PHP code generation complete$(NC)"

$(CSHARP_GENERATED): $(DATA_FILES)
	@echo -e "$(BLUE)Generating C# code...$(NC)"
	@cd csharp && dotnet run --project src/Yosina.Codegen/Yosina.Codegen.csproj && $(MAKE) format
	@echo -e "$(GREEN)✓ C# code generation complete$(NC)"

$(JAVA_GENERATED): $(DATA_FILES)
	@echo -e "$(BLUE)Generating Java code...$(NC)"
	@cd java && gradle :codegen:run && gradle spotlessApply
	@echo -e "$(GREEN)✓ Java code generation complete$(NC)"

# Individual language generation targets (phony targets for manual use)
.PHONY: generate-csharp
generate-csharp: $(CSHARP_GENERATED)

.PHONY: generate-go
generate-go: $(GO_GENERATED)

.PHONY: generate-java
generate-java: $(JAVA_GENERATED)

.PHONY: generate-javascript
generate-javascript: $(JAVASCRIPT_GENERATED)

.PHONY: generate-php
generate-php: $(PHP_GENERATED)

.PHONY: generate-python
generate-python: $(PYTHON_GENERATED)

.PHONY: generate-ruby
generate-ruby: $(RUBY_GENERATED)

.PHONY: generate-rust
generate-rust: $(RUST_GENERATED)

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
	@echo "  make force-generate     - Force regeneration of all languages"
	@echo "  make generate-data      - Run data generation in data/ directory"
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
	@cd python && pip install -e .
	@# Ruby
	@echo -e "$(YELLOW)Installing Ruby dependencies...$(NC)"
	@cd ruby && bundle install
	@# Rust
	@echo -e "$(YELLOW)Checking Rust dependencies...$(NC)"
	@cd rust && cargo check
	@echo -e "$(GREEN)✓ All dependencies installed$(NC)"
