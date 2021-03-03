# frozen_string_literal: true

require 'byebug'
require 'rubocop'
require 'rubocop/rspec/support'
require 'rubocop-ordered_methods'

# Require supporting files (custom matchers and macros, etc)
# in ./support and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/rubocop/cop/}) do |meta|
    meta[:type] = :cop_spec
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = 'tmp/.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.order = :random

  # We should address configuration warnings when we upgrade
  config.raise_errors_for_deprecations!

  # RSpec gives helpful warnings when you are doing something wrong.
  # We should take their advice!
  config.raise_on_warning = true

  config.include(::RuboCop::RSpec::ExpectOffense)
end
