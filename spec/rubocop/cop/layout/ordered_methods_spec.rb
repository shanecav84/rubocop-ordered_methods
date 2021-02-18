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
    expect_offense(<<-RUBY.gsub(/^\s+\|/, ''))
      class Foo
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

        public

        def public_b; end
        def public_a; end
        ^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.

        private

        def private_d; end
        def private_c; end
        ^^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.

        protected

        def protected_b; end
        def protected_a; end
        ^^^^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.

        def self.class_d; end
        def self.class_c; end
        ^^^^^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.

        def instance_d; end
        def instance_c; end
        ^^^^^^^^^^^^^^^^^^^ Methods should be sorted in alphabetical order.
      end
    RUBY
  end

  it 'does not register an offense when methods are in alphabetical order' do
    expect_no_offenses(<<-RUBY.gsub(/^\s+\|/, ''))
      def a; end
      def b; end
    RUBY
  end

  it 'autocorrects methods that are not in alphabetical order' do
    new_source = autocorrect_source_file(<<-RUBY.gsub(/^\s+\|/, ''))
      class Foo
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
      end
    RUBY

    expect(new_source).to eq(<<-RUBY.gsub(/^\s+\|/, ''))
      class Foo
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
      end
    RUBY
  end

  it 'autocorrects with comments and modifiers' do
    source = <<-RUBY
      # Long
      # Preceding
      # Comment
      # class_b
      def self.class_b; end
      private_class_method :class_b

      def self.class_a; end
      # Long
      # Succeeding
      # Comment
      # class_a
      public_class_method :class_a

      # Preceding comment for instance_b
      def instance_b; end
      # Long
      # Succeeding
      # Comment
      # instance_b
      alias_method :orig_instance_b, :instance_b
      module_function :instance_b
      private :instance_b
      protected :instance_b
      public :instance_b

      # Long
      # Preceding
      # Comment
      # instance_a
      def instance_a; end
      # Succeeding comment for instance_a
      alias :new_instance_a :instance_a
      alias_method :orig_instance_a, :instance_a
      module_function :instance_a
      private :instance_a
      protected :instance_a
      public :instance_a
    RUBY

    expect(autocorrect_source_file(source)).to eq(<<-RUBY)
      def self.class_a; end
      # Long
      # Succeeding
      # Comment
      # class_a
      public_class_method :class_a

      # Long
      # Preceding
      # Comment
      # class_b
      def self.class_b; end
      private_class_method :class_b

      # Long
      # Preceding
      # Comment
      # instance_a
      def instance_a; end
      # Succeeding comment for instance_a
      alias :new_instance_a :instance_a
      alias_method :orig_instance_a, :instance_a
      module_function :instance_a
      private :instance_a
      protected :instance_a
      public :instance_a

      # Preceding comment for instance_b
      def instance_b; end
      # Long
      # Succeeding
      # Comment
      # instance_b
      alias_method :orig_instance_b, :instance_b
      module_function :instance_b
      private :instance_b
      protected :instance_b
      public :instance_b
    RUBY
  end

  it 'autocorrects when qualifiers are not immediately adjacent' do
    source = <<-RUBY
      def method_b; end
      alias_method :method_from_parent_class_orig, :method_from_parent_class
      alias_method :method_from_parent_class, :method_b

      def method_a; end
    RUBY

    expect(autocorrect_source_file(source)).to eq(<<-RUBY)
      def method_a; end

      def method_b; end
      alias_method :method_from_parent_class_orig, :method_from_parent_class
      alias_method :method_from_parent_class, :method_b
    RUBY
  end

  # We integration-test our cop via `::RuboCop::CLI`. This is quite close to an
  # end-to-end test, with the normal pros and cons that entails. We exercise
  # more of our code, but our assertions are more fragile, for example asserting
  # very specific output.
  context 'when run via RuboCop CLI' do
    include_context 'mock console output'
    include FileHelper

    it 'does not register offense when methods are alphabetical' do
      cli = ::RuboCop::CLI.new
      file = Tempfile.new('rubocop_ordered_methods_spec_input.rb')
      create_file(file.path, <<~INPUT)
        class RTA
          def self.a; end
          def self.b; end
        end
      INPUT
      exit_status_code =
        cli.run([
                  '--require',
                  'rubocop-ordered_methods',
                  '--format',
                  'simple',
                  '--only',
                  'Layout/OrderedMethods',
                  file.path
                ])
      expect($stderr.string).to eq('')
      expect(exit_status_code).to eq(::RuboCop::CLI::STATUS_SUCCESS)
      expect($stdout.string.strip).to eq('1 file inspected, no offenses detected')
    end

    it 'registers an offense when methods are not in alphabetical order' do
      cli = ::RuboCop::CLI.new
      file = Tempfile.new('rubocop_ordered_methods_spec_input.rb')
      create_file(file.path, <<~INPUT)
        class RTA
          def self.b; end
          def self.a; end
        end
      INPUT
      exit_status_code =
        cli.run([
                  '--require',
                  'rubocop-ordered_methods',
                  '--format',
                  'simple',
                  '--only',
                  'Layout/OrderedMethods',
                  file.path
                ])
      expect($stderr.string).to eq('')
      expect(exit_status_code).to eq(::RuboCop::CLI::STATUS_OFFENSES)
      expect($stdout.string).to eq(<<~OUTPUT)
        == #{file.path} ==
        C:  3:  3: [Correctable] Layout/OrderedMethods: Methods should be sorted in alphabetical order.

        1 file inspected, 1 offense detected, 1 offense auto-correctable
      OUTPUT
    end
  end
end
