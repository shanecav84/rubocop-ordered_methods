# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Layout::OrderedMethods do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      'Layout/OrderedMethods' => {
        'IgnoredMethods' => %w[initialize],
        'EnforcedStyle' => enforced_style
      }
    )
  end
  let(:enforced_style) { 'alphabetical' }

  it 'registers an offense when methods are not in alphabetical order' do
    expect_offense(<<-RUBY.strip_indent)
      def self.class_b; end
      def self.class_a; end
      ^^^^^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.

      def instance_b; end
      def instance_a; end
      ^^^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.

      module_function

      def module_function_b; end
      def module_function_a; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.

      private

      def private_b; end
      def private_a; end
      ^^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.

      private

      def private_d; end
      def private_c; end
      ^^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.

      protected

      def protected_b; end
      def protected_a; end
      ^^^^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.

      public

      def public_b; end
      def public_a; end
      ^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.

      def self.class_d; end
      def self.class_c; end
      ^^^^^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.

      def instance_d; end
      def instance_c; end
      ^^^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.
    RUBY
  end

  it 'does not register an offense when methods are in alphabetical order' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def a; end
      def b; end
    RUBY
  end

  it 'autocorrects methods that are not in alphabetical order' do
    new_source = autocorrect_source_with_loop(<<-RUBY.strip_indent)
      # Comment class_b
      def self.class_b; end
      def self.class_a; end

      # Comment instance_b
      def instance_b; end
      def instance_a; end
      alias foo instance_a
      alias_method :foo, :instance_a

      module_function

      # Comment module_function_b
      def module_function_b; end
      def module_function_a; end

      private

      # Comment private_b
      def private_b; end
      def private_a; end

      private

      # Comment private_d
      def private_d; end
      def private_c; end

      protected

      # Comment protected_b
      def protected_b; end
      def protected_a; end

      public

      # Comment public_b
      def public_b; end
      def public_a; end

      # Comment class_d
      def self.class_d; end
      def self.class_c; end

      # Comment instance_d
      def instance_d; end
      def instance_c; end
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      def self.class_a; end
      # Comment class_b
      def self.class_b; end

      def instance_a; end
      alias foo instance_a
      alias_method :foo, :instance_a
      # Comment instance_b
      def instance_b; end

      module_function

      def module_function_a; end
      # Comment module_function_b
      def module_function_b; end

      private

      def private_a; end
      # Comment private_b
      def private_b; end

      private

      def private_c; end
      # Comment private_d
      def private_d; end

      protected

      def protected_a; end
      # Comment protected_b
      def protected_b; end

      public

      def public_a; end
      # Comment public_b
      def public_b; end

      def self.class_c; end
      # Comment class_d
      def self.class_d; end

      def instance_c; end
      # Comment instance_d
      def instance_d; end
    RUBY
  end

  it 'autocorrects preceding and succeeding comments' do
    source = <<-RUBY
      # Preceding comment for instance_b
      def instance_b; end
      # Succeeding comment for instance_b

      # Preceding comment for instance_a
      def instance_a; end
      # Succeeding comment for instance_a
    RUBY

    expect(autocorrect_source_with_loop(source)).to eq(<<-RUBY)
      # Preceding comment for instance_a
      def instance_a; end
      # Succeeding comment for instance_a

      # Preceding comment for instance_b
      def instance_b; end
      # Succeeding comment for instance_b
    RUBY
  end
end
