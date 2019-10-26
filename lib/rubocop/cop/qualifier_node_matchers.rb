# frozen_string_literal: true

module RuboCop
  module Cop
    # defines matchers for qualifier nodes
    module QualifierNodeMatchers
      extend NodePattern::Macros

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
      def_node_matcher :alias_method?,
                       '(send nil? {:alias_method} ... (sym $_method_name))'
      def_node_matcher :qualifier?, <<-PATTERN
          (send nil? {#{QUALIFIERS.map(&:inspect).join(' ')}}
            ... (sym $_method_name))
      PATTERN
    end
  end
end
