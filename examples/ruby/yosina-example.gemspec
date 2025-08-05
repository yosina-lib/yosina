# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'yosina-example'
  spec.version = '0.1.0'
  spec.authors = ['Moriyoshi Koizumi']
  spec.email = ['mozo@mozo.jp']

  spec.summary = 'Example usage of the Yosina gem'
  spec.description = 'Demonstrates basic and advanced usage of the Yosina Japanese text transliteration library'
  spec.homepage = 'https://github.com/yosina-lib/yosina'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.files = Dir['*.rb', 'README.md', 'README.ja.md', 'Gemfile', '*.gemspec']
  spec.require_paths = ['.']

  # Runtime dependency
  spec.add_dependency 'yosina'
end