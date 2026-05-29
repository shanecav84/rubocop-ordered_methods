# frozen_string_literal: true

require_relative 'rubocop/ordered_methods'

# We support both the old, unsupported `require` and the new, supported `plugins`
rubocop_version = Gem::Specification.find_by_name('rubocop').version.to_s
RuboCop::OrderedMethods.inject_defaults! if Gem::Version.new(rubocop_version) < Gem::Version.new('1.72')
