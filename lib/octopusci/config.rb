require 'octopusci/notifier'

module Octopusci
  class ConfigStore
    class MissingConfigField < RuntimeError; end
    
    def initialize
      reset()
    end

    def reset
      @options = {}
    end

    def options
      @options
    end

    def load(yaml_file = nil, &block)
      load_yaml(yaml_file) if !yaml_file.nil?
      yield self if block
      after_load()
    end

    def reload(yaml_file = nil, &block)
      reset()
      load(yaml_file, &block)
    end
    
    # allow options to be accessed as if this object is a Hash.
    def [](key_name)
      if !@options.has_key?(key_name.to_s())
        raise MissingConfigField, "'#{key_name}' is NOT defined as a config field."
      end
      return @options[key_name.to_s()]
    end
    
    # allow options to be set as if this object is a Hash.
    def []=(key_name, value)
      @options[key_name.to_s()] = value
    end
    
    def has_key?(key_name)
      return @options.has_key?(key_name)
    end
    
    # allow options to be read and set using method calls.  This capability is primarily for
    # allowing the configuration to be defined through a block passed to the configure() function
    # from an initializer or similar file.
    def method_missing(key_name, *args)
      key_name_str = key_name.to_s()
      if key_name_str =~ /=$/ then
        self[key_name_str.chop()] = args[0]
      else
        return self[key_name_str]
      end
    end

    def after_load(&block)
      if block
        @after_load = block
      elsif @after_load
        @after_load.call
      end
    end

    private

    # read the configuration values into the object from a YML file.
    def load_yaml(yaml_file)
      @options.merge!(YAML.load_file(yaml_file))
    end
  end

  # On evaluation of the module it defines a new singleton of Config.
  if (!defined?(::Octopusci::Config))
    ::Octopusci::Config = ConfigStore.new()
  end
end

# Setup the config after load callback
Octopusci::Config.after_load do
  if Octopusci::Config['stages'] == nil
    raise "You have defined stages as an option but have no items in it."
  end

  Octopusci::Notifier.default :from => Octopusci::Config['smtp']['notification_from_email']
  Octopusci::Notifier.delivery_method = :smtp
  Octopusci::Notifier.smtp_settings = {
    :address => Octopusci::Config['smtp']['address'],
    :port => Octopusci::Config['smtp']['port'].to_s,
    :authentication => Octopusci::Config['smtp']['authentication'],
    :enable_starttls_auto => Octopusci::Config['smtp']['enable_starttls_auto'],
    :user_name => Octopusci::Config['smtp']['user_name'],
    :password => Octopusci::Config['smtp']['password'],
    :raise_delivery_errors => Octopusci::Config['smtp']['raise_delivery_errors']
  }
  Octopusci::Notifier.logger = Logger.new(STDOUT)

  Dir.open(Octopusci::Config['general']['jobs_path']) do |d|
    job_file_names = d.entries.reject { |e| e == '..' || e == '.' }
    job_file_names.each do |f_name|
      load Octopusci::Config['general']['jobs_path'] + "/#{f_name}"
    end
  end
end

# Load the actual config file
Octopusci::Config.load("/etc/octopusci/config.yml")
