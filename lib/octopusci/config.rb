require 'octopusci/notifier'

module Octopusci
  class Config
    class MissingConfigField < RuntimeError; end
    class ConfigNotInitialized < RuntimeError; end
    
    def initialize()
      @options = {}
    end
    
    # read the configuration values into the object from a YML file.
    def load_yaml(yaml_file)
      @options = YAML.load_file(yaml_file)
    end
    
    # allow options to be accessed as if this object is a Hash.
    def [](key_name)
      if @options.nil?
        raise ConfigNotInitialized, "Can't access the '#{key_name}' field because the config hasn't been initialized."
      end
      if !@options.has_key?(key_name.to_s())
        raise MissingConfigField, "'#{key_name}' is NOT defined as a config field."
      end
      return @options[key_name.to_s()]
    end
    
    # allow options to be set as if this object is a Hash.
    def []=(key_name, value)
      @options[key_name.to_s()] = value
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
  end
  
  # On evaluation of the module it defines a new singleton of Config.
  if (!defined?(CONFIG))
    CONFIG = Config.new()
  end

  def self.configure(yaml_file = nil, &block)    
    CONFIG.load_yaml(yaml_file) if !yaml_file.nil?
    yield CONFIG if block
    
    Notifier.default :from => Octopusci::CONFIG['smtp']['notification_from_email']
    Notifier.delivery_method = :smtp
    Notifier.smtp_settings = {
      :address => Octopusci::CONFIG['smtp']['address'],
      :port => Octopusci::CONFIG['smtp']['port'].to_s,
      :authentication => Octopusci::CONFIG['smtp']['authentication'],
      :enable_starttls_auto => Octopusci::CONFIG['smtp']['enable_starttls_auto'],
      :user_name => Octopusci::CONFIG['smtp']['user_name'],
      :password => Octopusci::CONFIG['smtp']['password'],
      :raise_delivery_errors => Octopusci::CONFIG['smtp']['raise_delivery_errors']
    }
    Notifier.logger = Logger.new(STDOUT)
  end  
end