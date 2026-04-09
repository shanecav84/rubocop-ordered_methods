# frozen_string_literal: true

require 'lint_roller'

module RuboCop
  module OrderedMethods
    # Official plugin system for Rubocop
    class Plugin < LintRoller::Plugin
      def about
        LintRoller::About.new(
          name: 'rubocop-ordered_methods',
          version: RuboCop::OrderedMethods::VERSION,
          homepage: 'https://github.com/shanecav84/rubocop-ordered_methods',
          description: 'Check that methods are defined alphabetically per access modifier block.'
        )
      end

      def rules(_context)
        LintRoller::Rules.new(
          type: :path,
          config_format: :rubocop,
          value: Pathname.new(__dir__).join('../../../config/default.yml')
        )
      end

      def supported?(context)
        context.engine == :rubocop
      end
    end
  end
end
