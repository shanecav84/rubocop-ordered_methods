# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # @example EnforcedStyle: alphabetical (default)
      #   # Check that methods are defined alphabetically.
      #
      #   # bad
      #   def self.b; end
      #   def self.a; end
      #
      #   def b; end
      #   def a; end
      #
      #   private
      #
      #   def d; end
      #   def c; end
      #
      #   # good
      #   def self.a; end
      #   def self.b; end
      #
      #   def a; end
      #   def b; end
      #
      #   private
      #
      #   def c; end
      #   def d; end
      class OrderedMethods < Cop
        include IgnoredMethods
        include RangeHelp

        COMPARISONS = {
          'alphabetical' => lambda do |left_method, right_method|
            (left_method.method_name <=> right_method.method_name) != 1
          end
        }.freeze
        ERR_INVALID_COMPARISON = 'Invalid "Comparison" config for ' \
          "#{cop_name}. Expected one of: #{COMPARISONS.keys.join(', ')}".freeze

        def autocorrect(node)
          @corrector.correct(node, @previous_node)
        end

        def on_begin(node)
          cache(node)
          consecutive_methods(@siblings) do |previous, current|
            unless ordered?(previous, current)
              @previous_node = previous
              add_offense(
                current,
                message: 'Methods should be sorted in ' \
                  "#{cop_config['EnforcedStyle']} order."
              )
            end
          end
        end

        private

        def access_modified?(node, is_class_method_block)
          (node.defs_type? && !is_class_method_block) ||
            (node.def_type? && is_class_method_block) ||
            (node.send_type? && node.bare_access_modifier?)
        end

        # Cache to avoid traversing the AST multiple times
        def cache(node)
          @cache ||= begin
            @siblings = node.children

            # Init the corrector with the cache to avoid traversing
            # the AST in the corrector
            if @options[:auto_correct]
              comments = processed_source.ast_with_comments
              @corrector = OrderedMethodsCorrector.new(comments, @siblings)
            end
          end
        end

        # We disable `Style/ExplicitBlockArgument` for performance. See
        # https://github.com/shanecav84/rubocop-ordered_methods/pull/5#pullrequestreview-562957146
        # rubocop:disable Style/ExplicitBlockArgument
        def consecutive_methods(nodes)
          filtered = filter_relevant_nodes(nodes)
          filtered_and_grouped = group_methods_by_access_modifier(filtered)
          filtered_and_grouped.each do |method_group|
            method_group.each_cons(2) do |left_method, right_method|
              yield left_method, right_method
            end
          end
        end
        # rubocop:enable Style/ExplicitBlockArgument

        def filter_relevant_nodes(nodes)
          nodes.select do |node|
            (
              (node.defs_type? || node.def_type?) &&
                !ignored_method?(node.method_name)
            ) || (node.send_type? && node.bare_access_modifier?)
          end
        end

        # Group methods by the access modifier block they are declared in.
        # Multiple blocks of the same modifier will have their methods grouped
        # separately; for example, the following would be separated into two
        # groups:
        #   private
        #   def a; end
        #   private
        #   def b; end
        def group_methods_by_access_modifier(nodes)
          is_class_method_block = false

          nodes.each_with_object([[]]) do |node, grouped_methods|
            if access_modified?(node, is_class_method_block)
              grouped_methods << []
            end
            is_class_method_block = node.defs_type?
            next if node.send_type? && node.bare_access_modifier?

            grouped_methods.last << node
          end
        end

        def ordered?(left_method, right_method)
          comparison = COMPARISONS[cop_config['EnforcedStyle']]
          raise Error, ERR_INVALID_COMPARISON if comparison.nil?

          comparison.call(left_method, right_method)
        end
      end
    end
  end
end
