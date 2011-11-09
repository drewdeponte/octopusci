require 'spec_helper'

describe Octopusci::IO do
  describe "#initialize" do
    it "should construct an instance of Octopusci::IO" do
      job = stub('job')
      Octopusci::IO.new(job).should be_a(Octopusci::IO)
    end
  end

  describe "#read_all_out" do
    it "should open the output file if it exists" do
      file = stub('file').as_null_object
      File.stub(:exists?).and_return(true)
      File.should_receive(:open).and_return(file)
      Octopusci::IO.new({ 'id' => 23 }).read_all_out
    end

    it "should return all the file content if the output file exists" do
      file = stub('file', :read => 'file content', :close => 0)
      File.stub(:exists?).and_return(true)
      File.stub(:open).and_return(file)
      Octopusci::IO.new({ 'id' => 23 }).read_all_out.should == 'file content'
    end

    it "should return an empty string if the file does not exist" do
      File.stub(:exists?).and_return(false)
      Octopusci::IO.new({ 'id' => 23 }).read_all_out.should == ""
    end
  end

  describe "#read_all_log" do
    it "should open the log file if it exists" do
      file = stub('file').as_null_object
      File.stub(:exists?).and_return(true)
      File.should_receive(:open).and_return(file)
      Octopusci::IO.new({ 'id' => 23 }).read_all_log
    end

    it "should return all the file content if the log file exists" do
      file = stub('file', :read => 'file content', :close => 0)
      File.stub(:exists?).and_return(true)
      File.stub(:open).and_return(file)
      Octopusci::IO.new({ 'id' => 23 }).read_all_log.should == 'file content'
    end

    it "should return an empty string if the file does not exist" do
      File.stub(:exists?).and_return(false)
      Octopusci::IO.new({ 'id' => 23 }).read_all_log.should == ""
    end
  end

  describe "#read_all_out_as_html" do
    it "should get all the output using read_all_out" do
      io = Octopusci::IO.new({ 'id' => 23 })
      io.should_receive(:read_all_out).and_return("\e[31msome stuff\e[0m")
      io.read_all_out_as_html
    end

    it "should parse the output using ansi2html" do
      io = Octopusci::IO.new({ 'id' => 23 })
      io.stub(:read_all_out).and_return("raw out")
      out = stub("string io out obj", :string => "raw out")
      StringIO.stub(:new).and_return(out)
      ANSI2HTML::Main.should_receive(:new).with("raw out", out)
      io.read_all_out_as_html
    end

    it "should wrap ansi colored strings in spans which are classed based on the color" do
      io = Octopusci::IO.new({ 'id' => 23 })
      io.stub(:read_all_out).and_return("\e[31msome stuff\e[0m")
      io.read_all_out_as_html.should == '<span class="red">some stuff</span>'    
    end
  end

  describe "#read_all_log_as_html" do
    it "should get all the log using read_all_log" do
      io = Octopusci::IO.new({ 'id' => 23 })
      io.should_receive(:read_all_log).and_return("\e[31msome stuff\e[0m")
      io.read_all_log_as_html.should == '<span class="red">some stuff</span>'
    end

    it "should parse the log using ansi2html" do
      io = Octopusci::IO.new({ 'id' => 23 })
      io.stub(:read_all_log).and_return("raw out")
      out = stub("string io out obj", :string => "raw out")
      StringIO.stub(:new).and_return(out)
      ANSI2HTML::Main.should_receive(:new).with("raw out", out)
      io.read_all_log_as_html
    end

    it "should wrap ansi colored strings in spans which are classed based on the color" do
      io = Octopusci::IO.new({ 'id' => 23 })
      io.stub(:read_all_log).and_return("\e[31msome stuff\e[0m")
      io.read_all_log_as_html.should == '<span class="red">some stuff</span>'
    end
  end

  describe "#open_log_for_writing" do
  end

  describe "#open_out_for_writing" do
  end

  describe "#puts" do
  end

  describe "#log" do
  end
end