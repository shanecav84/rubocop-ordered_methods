# frozen_string_literal: true

require_relative '../layout/ordered_methods'

module RuboCop
  module Cop
    # This auto-corrects method order
    class OrderedMethodsCorrector
      class << self
        include IgnoredNode
        extend NodePattern::Macros

        ALIAS_BEFORE_METHOD_WARNING_FMT = "Won't reorder " \
          '%<first_method_name>s and %<second_method_name>s because ' \
          'alias for %<first_method_name>s would be declared before ' \
          'its method definition.'.freeze
        QUALIFIERS = %i[
          alias_method
          module_function
          private_class_method
          public_class_method
          private
          protected
          public
        ].freeze

        def_node_matcher :alias?, '(:alias ... (sym $_method_name))'
        def_node_matcher :qualifier?, <<-PATTERN
          (send nil? {#{QUALIFIERS.map(&:inspect).join(' ')}}
            ... (sym $_method_name))
        PATTERN

        def correct(processed_source, node, previous_node)
          @processed_source = processed_source
          @current_node = node
          @previous_node = previous_node

          verify_alias_method_order
          current_range = join_surroundings(@current_node)
          previous_range = join_surroundings(@previous_node)
          lambda do |corrector|
            corrector.replace(current_range, previous_range.source)
            corrector.replace(previous_range, current_range.source)
          end
        end

        private

        def found_qualifier?(node, next_sibling)
          return false if next_sibling.nil?

          (qualifier?(next_sibling) || alias?(next_sibling)) == node.method_name
        end

        def join_comments(node, source_range)
          @processed_source.ast_with_comments[node].each do |comment|
            source_range = source_range.join(comment.loc.expression)
          end
          source_range
        end

        def join_modifiers_and_aliases(node, source_range)
          siblings = node.parent.children
          preceding_qualifier_index = node.sibling_index
          while found_qualifier?(node, siblings[preceding_qualifier_index + 1])
            source_range = source_range.join(
              siblings[preceding_qualifier_index + 1].source_range
            )
            preceding_qualifier_index += 1
          end
          source_range
        end

        def join_surroundings(node)
          with_modifiers_and_aliases = join_modifiers_and_aliases(
            node,
            node.source_range
          )
          join_comments(node, with_modifiers_and_aliases)
        end

        # We don't want a method to be defined after its alias
        def moving_after_alias?(current_node, previous_node)
          siblings = current_node.parent.children
          current_node_aliases = siblings.select do |sibling|
            alias?(sibling) == current_node.method_name
          end
          filter = current_node_aliases.delete_if do |cna|
            cna.sibling_index == current_node.sibling_index + 1
          end
          return false if filter.empty?

          current_node_aliases.any? do |cna|
            previous_node.sibling_index > cna.sibling_index
          end
        end

        # rubocop:disable Metrics/MethodLength, Style/GuardClause
        def verify_alias_method_order
          if moving_after_alias?(@current_node, @previous_node)
            ignore_node(@current_node)
            raise Warning, format(
              ALIAS_BEFORE_METHOD_WARNING_FMT,
              first_method_name: @current_node.method_name,
              second_method_name: @previous_node.method_name
            )
          end
          if moving_after_alias?(@previous_node, @current_node)
            ignore_node(@previous_node)
            raise Warning, format(
              ALIAS_BEFORE_METHOD_WARNING_FMT,
              first_method_name: @previous_node.method_name,
              second_method_name: @current_node.method_name
            )
          end
        end
        # rubocop:enable Metrics/MethodLength, Style/GuardClause
      end
    end
  end
end
