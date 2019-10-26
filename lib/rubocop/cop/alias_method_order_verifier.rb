# frozen_string_literal: true

require_relative 'qualifier_node_matchers'

module RuboCop
  module Cop
    # This verifies a method is defined before its alias
    class AliasMethodOrderVerifier
      class << self
        include IgnoredNode
        include QualifierNodeMatchers

        ALIAS_BEFORE_METHOD_WARNING_FMT = "Won't reorder " \
          '%<first_method_name>s and %<second_method_name>s because ' \
          'alias for %<first_method_name>s would be declared before ' \
          'its method definition.'

        # rubocop:disable Style/GuardClause
        def verify!(current_node, previous_node)
          if moving_after_alias?(current_node, previous_node)
            ignore_node(current_node)
            raise_warning!(current_node.method_name, previous_node.method_name)
          end
          if moving_after_alias?(previous_node, current_node)
            ignore_node(previous_node)
            raise_warning!(previous_node.method_name, current_node.method_name)
          end
        end
        # rubocop:enable Style/GuardClause

        private

        def find_aliases(current_node, siblings)
          siblings.select do |sibling|
            (alias?(sibling) || alias_method?(sibling)) ==
              current_node.method_name
          end
        end

        # We don't want a method to be defined after its alias
        def moving_after_alias?(current_node, previous_node)
          siblings = current_node.parent.children
          current_node_aliases = find_aliases(current_node, siblings)
          filter = current_node_aliases.delete_if do |cna|
            cna.sibling_index > current_node.sibling_index
          end
          return false if filter.empty?

          current_node_aliases.any? do |cna|
            previous_node.sibling_index > cna.sibling_index
          end
        end

        def raise_warning!(first_method_name, second_method_name)
          raise Warning, format(
            ALIAS_BEFORE_METHOD_WARNING_FMT,
            first_method_name: first_method_name,
            second_method_name: second_method_name
          )
        end
      end
    end
  end
end
