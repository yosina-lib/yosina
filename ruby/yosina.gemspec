# frozen_string_literal: true

require_relative 'lib/yosina/version'

Gem::Specification.new do |spec|
  spec.name = 'yosina'
  spec.version = Yosina::VERSION
  spec.authors = ['Moriyoshi Koizumi']
  spec.email = ['mozo@mozo.jp']

  spec.summary = 'Japanese text transliteration library'
  spec.description = 'Yosina is a transliteration library that specifically deals with the letters and symbols used' \
                     ' in Japanese writing.'
  spec.homepage = 'https://github.com/yosina-lib/yosina'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/yosina-lib/yosina'
  spec.metadata['changelog_uri'] = 'https://github.com/yosina-lib/yosina/releases'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Development dependencies
  spec.add_development_dependency 'minitest', '~> 5.25'
  spec.add_development_dependency 'rake', '~> 13'
  spec.add_development_dependency 'rubocop', '~> 1.79'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.38'
  spec.add_development_dependency 'yard', '~> 0.9'
end
