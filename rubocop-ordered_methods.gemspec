# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative 'lib/rubocop/ordered_methods/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-ordered_methods'
  spec.version = RuboCop::OrderedMethods::VERSION
  spec.authors = ['Shane Cavanaugh']
  spec.email = ['shane@shanecav.net']

  spec.summary = 'Checks that methods are ordered alphabetically.'
  spec.homepage = 'https://github.com/shanecav84/rubocop-ordered_methods'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 2.7'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added
  # into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'lint_roller'
  spec.add_dependency 'rubocop', '>= 1.0'

  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['default_lint_roller_plugin'] = 'RuboCop::OrderedMethods::Plugin'
end
