# Publishing Guide

This guide explains how to publish new versions of Yosina to various package repositories.

## Version Management

### Updating Version Numbers

To update the version across all language implementations and README files:

```bash
make update-version VERSION=x.y.z
```

This command will update:
- Package configuration files for all languages
- Version references in README files
- Language-specific README files

### Git Tags

After updating versions, create and push a git tag:

```bash
git add .
git commit -m "Release version x.y.z"
git tag -a vx.y.z -m "Release version x.y.z"
git tag -a go/vx.y.z -m "Release version x.y.z"
git push origin main --tags
```

## Publishing to Package Repositories

### Prerequisites

Set up the following environment variables or configuration files:

- **C# (NuGet)**: `NUGET_API_KEY` environment variable
- **Java (Maven Central)**: Properties in `~/.gradle/gradle.properties`:
  - `mavenCentralUsername`
  - `mavenCentralPassword`
  - `signingKey` (GPG private key)
  - `signingPassword`
- **JavaScript (npm)**: Run `npm login` first
- **Python (PyPI)**: Configure with `uv` or set up `~/.pypirc`
- **Ruby (RubyGems)**: Run `gem signin` first
- **Rust (crates.io)**: Run `cargo login` first
- **Dart (pub.dev)**: Run `dart pub login` first
- **PHP (Packagist)**: Automatically synced via GitHub webhook
- **Go**: Uses git tags for versioning (no separate publishing needed)
- **Swift**: Uses git tags for versioning (no separate publishing needed)

### Publishing All Packages

To publish all packages at once:

```bash
make publish-all
```

### Publishing Individual Packages

You can also publish packages individually:

```bash
# C# (.NET/NuGet)
make publish-csharp

# Dart (pub.dev)
make publish-dart

# Java (Maven Central)
make publish-java

# JavaScript/TypeScript (npm)
make publish-javascript

# PHP (Packagist) - automatic via webhook
make publish-php

# Python (PyPI)
make publish-python

# Ruby (RubyGems)
make publish-ruby

# Rust (crates.io)
make publish-rust
```

## Language-Specific Notes

### Go and Swift

Go and Swift packages use git tags for versioning. After pushing a new tag, the packages will be automatically available:

- Go: Users can fetch with `go get github.com/yosina-lib/yosina@vx.y.z`
- Swift: Users can specify the version in Package.swift

### PHP (Packagist)

PHP packages are automatically synchronized with Packagist via a GitHub webhook. Ensure the webhook is configured at:
https://packagist.org/packages/yosina-lib/yosina

### Java (Maven Central)

The Java package is now configured for the new Maven Central publishing portal. Make sure you have:
1. A Maven Central account with publishing rights
2. GPG signing keys configured
3. Credentials stored in `~/.gradle/gradle.properties`

## Release Checklist

1. [ ] Update version numbers: `make update-version VERSION=x.y.z`
2. [ ] Run tests for all languages
3. [ ] Update CHANGELOG if applicable
4. [ ] Commit changes: `git commit -m "Release version x.y.z"`
5. [ ] Create git tag: `git tag -a vx.y.z -m "Release version x.y.z"` `git tag -a go/vx.y.z -m "Release version x.y.z"`
6. [ ] Push changes and tags: `git push origin main --tags`
7. [ ] Publish packages: `make publish-all`
8. [ ] Verify packages are available on respective repositories
9. [ ] Create GitHub release with release notes
