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
      Octopusci::IO.new({ :id => 23 }).read_all_out
    end

    it "should return all the file content if the output file exists" do
      file = stub('file', :read => 'file content')
      File.stub(:exists?).and_return(true)
      File.stub(:open).and_return(file)
      Octopusci::IO.new({ :id => 23 }).read_all_out.should == 'file content'
    end

    it "should return an empty string if the file does not exist" do
      File.stub(:exists?).and_return(false)
      Octopusci::IO.new({ :id => 23 }).read_all_out.should == ""
    end
  end

  describe "#read_all_log" do
    it "should open the log file if it exists" do
      file = stub('file').as_null_object
      File.stub(:exists?).and_return(true)
      File.should_receive(:open).and_return(file)
      Octopusci::IO.new({ :id => 23 }).read_all_log
    end

    it "should return all the file content if the log file exists" do
      file = stub('file', :read => 'file content')
      File.stub(:exists?).and_return(true)
      File.stub(:open).and_return(file)
      Octopusci::IO.new({ :id => 23 }).read_all_log.should == 'file content'
    end

    it "should return an empty string if the file does not exist" do
      File.stub(:exists?).and_return(false)
      Octopusci::IO.new({ :id => 23 }).read_all_log.should == ""
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