# frozen_string_literal: true

require_relative '../layout/ordered_methods'
require_relative '../alias_method_order_verifier'
require_relative '../qualifier_node_matchers'

module RuboCop
  module Cop
    # This auto-corrects method order
    class OrderedMethodsCorrector
      include QualifierNodeMatchers

      # @param cop_config ::RuboCop::Config
      def initialize(comment_locations, siblings, cop_config)
        @comment_locations = comment_locations
        @siblings = siblings
        @cop_config = cop_config
      end

      def correct(node, previous_node)
        AliasMethodOrderVerifier.verify!(node, previous_node)
        current_range = join_surroundings(node)
        previous_range = join_surroundings(previous_node)
        lambda do |corrector|
          corrector.replace(current_range, previous_range.source)
          corrector.replace(previous_range, current_range.source)
        end
      end

      private

      def find_last_qualifier_index(node)
        preceding_qualifier_index = node.sibling_index
        last_qualifier_index = @siblings.length - 1
        while preceding_qualifier_index < last_qualifier_index
          break if found_qualifier?(node, @siblings[last_qualifier_index])

          last_qualifier_index -= 1
        end

        last_qualifier_index
      end

      def found_qualifier?(node, next_sibling)
        return false if next_sibling.nil?

        (qualifier?(next_sibling) || alias?(next_sibling)) == node.method_name
      end

      # @param node RuboCop::AST::DefNode
      # @param source_range Parser::Source::Range
      # @return Parser::Source::Range
      def join_comments(node, source_range)
        @comment_locations[node.loc].each do |comment|
          source_range = source_range.join(comment.loc.expression)
        end
        source_range
      end

      # @param node RuboCop::AST::DefNode
      # @param source_range Parser::Source::Range
      # @return Parser::Source::Range
      def join_modifiers_and_aliases(node, source_range)
        preceding_qualifier_index = node.sibling_index
        last_qualifier_index = find_last_qualifier_index(node)
        while preceding_qualifier_index < last_qualifier_index
          source_range = source_range.join(
            @siblings[preceding_qualifier_index + 1].source_range
          )
          preceding_qualifier_index += 1
        end
        source_range
      end

      # @param node RuboCop::AST::DefNode
      # @param source_range Parser::Source::Range
      # @return Parser::Source::Range
      def join_signature(node, source_range)
        sib = node.left_sibling
        if signature?(sib)
          # If there is a comment directly above the sig, first calculate the
          # range that covers both.
          with_comment = join_comments(sib, sib.source_range)
          source_range.join(with_comment)
        else
          source_range
        end
      end

      def join_signature?
        @cop_config['Signature'] == 'sorbet'
      end

      # @param node RuboCop::AST::DefNode
      # @return Parser::Source::Range
      def join_surroundings(node)
        with_modifiers_and_aliases = join_modifiers_and_aliases(
          node,
          node.source_range
        )
        with_comments = join_comments(node, with_modifiers_and_aliases)
        if join_signature?
          join_signature(node, with_comments)
        else
          with_comments
        end
      end

      # https://sorbet.org/docs/sigs
      # @param node RuboCop::AST::Node
      def signature?(node)
        return false unless node&.type == :block
        child = node.children.first
        child&.type == :send && child.method_name == :sig
      end
    end
  end
end
