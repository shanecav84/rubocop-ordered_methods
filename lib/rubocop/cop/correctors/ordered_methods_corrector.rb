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
        QUALIFIERS = (
            %i[alias_method private_class_method public_class_method] +
                       ::RuboCop::Cop::Layout::OrderedMethods::
                         VISIBILITY_MODIFIERS
          ).freeze

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
          current_range = with_surroundings(@current_node)
          previous_range = with_surroundings(@previous_node)
          lambda do |corrector|
            corrector.replace(current_range, previous_range.source)
            corrector.replace(previous_range, current_range.source)
          end
        end

        private

        def found_qualifier?(node, next_sibling)
          (qualifier?(next_sibling) || alias?(next_sibling)) == node.method_name
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

        def with_comments(node)
          surrounding_range = node.source_range
          @processed_source.ast_with_comments[node].each do |comment|
            if immediate_comment_for_node?(surrounding_range, comment)
              surrounding_range = surrounding_range.join(comment.loc.expression)
            end
          end
          surrounding_range
        end

        def immediate_comment_for_node?(node, comment)
          # Immediate preceding comment, e.g.:
          #   # Immediately preceding comment
          #   def a; end
          comment.loc.expression.end_pos == node.begin_pos - 1 ||
            # Immediate succeeding comment, e.g.:
            #   def a; end
            #   # Immediately succeeding comment
            comment.loc.expression.begin_pos == node.end_pos + 1
        end

        def with_modifiers_and_aliases(node)
          surrounding_range = node.source_range
          siblings = node.parent.children
          qualifier_index = node.sibling_index
          while found_qualifier?(node, siblings[qualifier_index + 1])
            qualifier_index += 1
          end
          found_node_range = with_comments(siblings[qualifier_index])
          surrounding_range.join(found_node_range)
        end

        def with_surroundings(node)
          node.source_range
              .join(with_comments(node))
              .join(with_modifiers_and_aliases(node))
        end
      end
    end
  end
end
