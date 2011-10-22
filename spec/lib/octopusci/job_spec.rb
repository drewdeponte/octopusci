require 'spec_helper'

describe Octopusci::Job do

  describe "self.run" do
    it "when not overridden should raise Ocotpusci::PureVirtualMethod" do
      class SomeJob < Octopusci::Job; end
      expect { SomeJob.run(nil) }.to raise_error(Octopusci::PureVirtualMethod)
    end
  end

  describe "self.failed!" do
    it "should create an instance of Octopusci::JobRunFailed with the given message" do
      excep_bef_mock = Octopusci::JobRunFailed.new("foo bar")
      Octopusci::JobRunFailed.should_receive(:new).with("a test failure message").and_return(excep_bef_mock)
      class SomeJob < Octopusci::Job; end
      begin
        SomeJob.failed!("a test failure message")
      rescue Octopusci::JobRunFailed
      end
    end

    it "should raise Octopusci::JobRunFailed" do
      class SomeJob < Octopusci::Job; end
      expect { SomeJob.failed!("a test failure message") }.to raise_error(Octopusci::JobRunFailed)
    end
  end

  describe "self.context" do
    it "should push context string onto the context stack" do
      class SomeJob < Octopusci::Job; end
      SomeJob.context_stack.should_receive(:push).with("commit")
      SomeJob.context("commit") {}
    end

    it "should execute the given block" do
      class SomeJob < Octopusci::Job; end
      @a = mock('some_inst_var_in_block')
      @a.should_receive(:foo)
      SomeJob.context("commit") { @a.foo }
    end

    it "should pop context string off the context stack" do
      class SomeJob < Octopusci::Job; end
      SomeJob.context_stack.should_receive(:pop)
      SomeJob.context("commit") {}
    end

    it "should pop context even if an exception is thrown inside the context" do
      class SomeJob < Octopusci::Job; end
      class FooExcep < RuntimeError; end
      SomeJob.context_stack.should_receive(:pop)
      begin
        SomeJob.context("commit") { raise FooExcep.new('aoeuaoee') }
      rescue FooExcep
      end
    end

    it "should raise a Octopusci::JobHalted exception if the failed! method is called inside the context" do
      job_rec = stub('job_record')
      class SomeJob < Octopusci::Job
        def self.run(job_rec)
          context("commit") do
            failed!("some reason")
          end
        end
      end
      expect { SomeJob.run(job_rec) }.to raise_error(Octopusci::JobHalted)
    end

    it "should stop execution from continuing after the failed!" do
      job_rec = mock('job_record')
      job_rec.should_receive(:foo)
      job_rec.should_not_receive(:bar)
      class SomeJob < Octopusci::Job
        def self.run(job_rec)
          context("commit") do
            job_rec.foo
            failed!("some failure")
            job_rec.bar
          end
        end
      end
      begin
        SomeJob.run(job_rec)
      rescue Octopusci::JobHalted
      end
    end
  end

  describe "self.run_shell_cmd" do

  end

  describe "self.log" do

  end

  describe "self.perform" do

  end
end