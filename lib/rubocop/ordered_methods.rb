# frozen_string_literal: true

module RuboCop
  # Our namespace
  module OrderedMethods
    PROJECT_ROOT = Pathname.new(__dir__).parent.parent.expand_path.freeze
    CONFIG_DEFAULT = PROJECT_ROOT.join('config', 'default.yml').freeze

    def self.inject_defaults!
      path = CONFIG_DEFAULT.to_s
      hash = ConfigLoader.send(:load_yaml_configuration, path)
      config = Config.new(hash, path)
      puts "configuration from #{path}" if ConfigLoader.debug?
      config = ConfigLoader.merge_with_default(config, path)
      ConfigLoader.instance_variable_set(:@default_configuration, config)
    end
  end
end
