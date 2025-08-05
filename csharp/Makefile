.PHONY: all build test format lint check clean restore

# Default target
all: format build test

# Restore dependencies and tools
restore:
	@echo "Restoring dependencies..."
	@dotnet restore
	@echo "Restoring tools..."
	@dotnet tool restore

# Build the solution
build: restore
	@echo "Building solution..."
	@dotnet build --no-restore

# Run tests
test: build
	@echo "Running tests..."
	@dotnet test --no-build --verbosity normal

# Format code using dotnet-format
format: restore
	@echo "Formatting code..."
	@dotnet format --verbosity diagnostic

# Run linting (code analysis)
lint: restore
	@echo "Running code analysis..."
	@dotnet build --no-restore /p:RunAnalyzersDuringBuild=true /p:TreatWarningsAsErrors=false

# Run format check without fixing (for CI)
check: restore
	@echo "Checking code format..."
	@dotnet format --verify-no-changes --verbosity diagnostic

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@dotnet clean
	@find . -type d -name "bin" -o -name "obj" | xargs rm -rf

# Install global tools (run once)
install-tools:
	@echo "Installing dotnet-format tool..."
	@dotnet tool install -g dotnet-format || true

# Help
help:
	@echo "Available targets:"
	@echo "  make all      - Format, build, and test (default)"
	@echo "  make build    - Build the solution"
	@echo "  make test     - Run tests"
	@echo "  make format   - Format code using dotnet-format"
	@echo "  make lint     - Run code analysis"
	@echo "  make check    - Check code format without fixing"
	@echo "  make clean    - Clean build artifacts"
	@echo "  make restore  - Restore dependencies and tools"
	@echo "  make install-tools - Install required global tools"