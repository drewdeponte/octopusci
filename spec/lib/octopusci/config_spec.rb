require 'spec_helper'

describe Octopusci::ConfigStore do

  before(:each) do
    @config_store = Octopusci::ConfigStore.new
  end

  describe "#initialize" do
    it "should create an instance of Octopusci::ConfigStore class with an empty options set" do
      @config_store.options.should == {}
    end
  end

  describe "#options" do
    it "should return a hash of the options" do
      @config_store.options.class.should == Hash
    end
  end

  describe "#load" do
    it "should load a yml file into the options set additively" do
      tmp_file_path = "/tmp/octopusci_test_config.yml"
      File.open(tmp_file_path, "w") do |f|
        f << "jack:\n"
        f << "  jobs_path: \"/etc/octopusci/jobs\"\n"
        f << "  workspace_base_path: \"/Users/adeponte/.octopusci\"\n"
      end

      @config_store.load(tmp_file_path)

      @config_store.options.should == { 'jack' => { 'jobs_path' => "/etc/octopusci/jobs", "workspace_base_path" => "/Users/adeponte/.octopusci" } }

      tmp_file_path = "/tmp/octopusci_test_config.yml"
      File.open(tmp_file_path, "w") do |f|
        f << "joe:\n"
        f << "  hello: \"world\"\n"
      end

      @config_store.load(tmp_file_path)

      @config_store.options.should == { 'jack' => { 'jobs_path' => "/etc/octopusci/jobs", "workspace_base_path" => "/Users/adeponte/.octopusci" }, 'joe' => { 'hello' => 'world' } }
    end

    it "should load a provided block into the options set additively" do
      @config_store.load() do |c|
        c['jackie'] = 'fool'
      end

      @config_store.options.should == { 'jackie' => 'fool' }

      @config_store.load() do |c|
        c['brown'] = 'ace'
      end

      @config_store.options.should == { 'jackie' => 'fool', 'brown' => 'ace' }
    end

    it "should load a yml file and a provided block into the options set additively" do
      tmp_file_path = "/tmp/octopusci_test_config.yml"
      File.open(tmp_file_path, "w") do |f|
        f << "alice:\n"
        f << "  hi: \"there\"\n"
      end

      @config_store.load(tmp_file_path) do |c|
        c['bob'] = 'hey alice'
      end

      @config_store.options.should == { 'alice' => { 'hi' => 'there' }, 'bob' => 'hey alice' }

      tmp_file_path = "/tmp/octopusci_test_config.yml"
      File.open(tmp_file_path, "w") do |f|
        f << "cindy:\n"
        f << "  good: \"bye\"\n"
      end

      @config_store.load(tmp_file_path) do |c|
        c['rachel'] = 'cya'
      end

      @config_store.options.should == { 'alice' => { 'hi' => 'there' }, 'bob' => 'hey alice', 'cindy' => { 'good' => 'bye' }, 'rachel' => 'cya' }
    end
  end

  describe "#reset" do
    it "should reset the options set back to an empty set" do
      @config_store.load() do |c|
        c['kitty'] = 'little'
      end

      @config_store.options.should == { 'kitty' => 'little' }

      @config_store.reset()

      @config_store.options.should == {}
    end
  end

  describe "#reload" do
    it "should reset the options set to an empty set and then perform a normal additive load" do
      @config_store.load() do |c|
        c['big'] = 'dog'
      end

      @config_store.options.should == { 'big' => 'dog' }

      @config_store.reload() do |c|
        c['albino'] = 'zebra'
      end

      @config_store.options.should == { 'albino' => 'zebra' }
    end
  end

  describe "hash style getter" do
    it "should return the value of the option with the given key" do
      @config_store.load() do |c|
        c['test_getter'] = 'winning'
      end

      @config_store['test_getter'].should == 'winning'
    end

    it "should raise Octopusci::ConfigStore::MissingConfigField if try to get a key that doesn't exist" do
      lambda { @config_store['blowup'] }.should raise_error(Octopusci::ConfigStore::MissingConfigField)
    end
  end

  describe "hash style setter" do
    it "should set the value of the option with the given key to the given value" do
      @config_store['test_setter'] = 'bi-winning'
      @config_store.options.should == { 'test_setter' => 'bi-winning' }
    end
  end

  describe "method style getter" do
    it "should return the value of the option with the give key as the method name" do
      @config_store.load() do |c|
        c['pirate'] = 'hords'
      end

      @config_store.pirate.should == 'hords'
    end

    it "should raise Octopusci::ConfigStore::MissingConfigField if try to get a key that doesn't exist" do
      lambda { @config_store.hippy }.should raise_error(Octopusci::ConfigStore::MissingConfigField)
    end
  end

  describe "method style setter" do
    it "should set the value of the option with the given key as the method name to the given value" do
      @config_store.ship = 'it'

      @config_store.options.should == { 'ship' => 'it' }
    end
  end

  describe "#has_key?" do
    it "should return a boolean value indicating whether or not there is an option in the option set with the given key" do
      @config_store['foo'] = 1

      @config_store.has_key?('foo').should be_true
      @config_store.has_key?('bar').should be_false
    end
  end

  describe "#after_load" do
    it "should set the after load callback when given a block" do
      @config_store.after_load do
        @config_store['after_load_cb_test'] = 'wootwoot'
      end

      @config_store.options.should == {}

      @config_store.load() do |c|
        @config_store['feet'] = 'wet'
      end

      @config_store.options.should == { 'feet' => 'wet', 'after_load_cb_test' => 'wootwoot' }
    end

    it "should execute the after load callback when NOT given a block and the callback has been previously set" do
      @config_store.after_load do
        @config_store['after_load_cb_test'] = 'wootwoot'
      end

      @config_store.load() do |c|
        @config_store['feet'] = 'wet'
      end

      @config_store.options.should == { 'feet' => 'wet', 'after_load_cb_test' => 'wootwoot' }
    end
  end
end