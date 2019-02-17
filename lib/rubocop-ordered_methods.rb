require 'rubocop'
require_relative 'rubocop/ordered_methods'
require_relative 'rubocop/cop/layout/ordered_methods'
require_relative 'rubocop/cop/correctors/ordered_methods_corrector'

RuboCop::OrderedMethods.inject_defaults!
