require 'spec_helper'

describe Octopusci::JobStore do

  describe "#prepend" do
    it "should increment the job count" do
      r = mock('redis').as_null_object
      Octopusci::JobStore.stub(:redis).and_return(r)
      r.should_receive(:incr).with('octopusci:job_count')
      Octopusci::JobStore.prepend({ "stub_job" => "foo", 'ref' => 'refs/heads/master' })
    end

    it "should store the job record" do
      r = mock('redis').as_null_object
      Octopusci::JobStore.stub(:redis).and_return(r)
      r.stub(:incr).and_return(1)
      Octopusci::JobStore.should_receive(:set).with(1, { "stub_job" => "foo", 'ref' => 'refs/heads/master', 'id' => 1 })
      Octopusci::JobStore.prepend({ "stub_job" => "foo", 'ref' => 'refs/heads/master' })
    end

    it "should prepend the job id to the job ids list" do
      r = mock('redis').as_null_object
      Octopusci::JobStore.stub(:redis).and_return(r)
      r.stub(:incr).and_return(10)
      r.should_receive(:lpush).with("octopusci:jobs", 10)
      Octopusci::JobStore.prepend({ "stub_job" => "foo", 'ref' => 'refs/heads/master' })
    end

    it "should prepend the job id to the project, branch, job ids list" do
      r = mock('redis').as_null_object
      Octopusci::JobStore.stub(:redis).and_return(r)
      r.stub(:incr).and_return(10)
      r.should_receive(:lpush).with("octopusci:foo:bar:jobs", 10)
      Octopusci::JobStore.prepend({ 'repo_name' => 'foo', 'ref' => 'refs/heads/bar' })      
    end

    it "should return the prepended jobs id" do
      r = mock('redis').as_null_object
      r.stub(:incr).and_return(1)
      Octopusci::JobStore.stub(:redis).and_return(r)
      Octopusci::JobStore.prepend({ "stub_job" => "foo", 'ref' => 'refs/heads/foo' }).should == 1
    end
  end

  describe "#set" do
    it "should store the passed job record serialized at the proper key" do
      r = mock('redis')
      Octopusci::JobStore.stub(:redis).and_return(r)
      r.should_receive(:set).with("octopusci:jobs:1", YAML.dump({ "stub_job" => "foo"}))
      Octopusci::JobStore.set(1, { "stub_job" => "foo"})
    end
  end

  describe "#get" do
    it "should get the job record using the proper key" do
      r = mock('redis')
      Octopusci::JobStore.stub(:redis).and_return(r)
      r.should_receive(:get).with("octopusci:jobs:1")
      Octopusci::JobStore.get(1)
    end
  end

  describe "#size" do
    it "should get the number of jobs in the jobs list" do
      r = mock('redis')
      Octopusci::JobStore.stub(:redis).and_return(r)
      r.should_receive(:llen).with("octopusci:jobs").and_return(8)
      Octopusci::JobStore.size
    end

    it "should return the number of jobs in the jobs list" do
      r = mock('redis')
      Octopusci::JobStore.stub(:redis).and_return(r)
      r.stub(:llen).and_return(8)
      Octopusci::JobStore.size.should == 8
    end
  end

  describe "#repo_branch_size" do
    it "should get the number of jobs in the list for the branch name of the given repository" do
      r = mock('redis')
      Octopusci::JobStore.stub(:redis).and_return(r)
      r.should_receive(:llen).with("octopusci:foo:bar:jobs").and_return(8)
      Octopusci::JobStore.repo_branch_size("owner", "foo", "bar")
    end

    it "should return the number of jbos in the list for the branch name of the given repository" do
      r = mock('redis')
      Octopusci::JobStore.stub(:redis).and_return(r)
      r.should_receive(:llen).with("octopusci:foo:bar:jobs").and_return(8)
      Octopusci::JobStore.repo_branch_size("owner", "foo", "bar").should == 8
    end
  end

  describe "#list_job_ids" do
    it "should return a list of count job ids from the first index given" do
      r = mock('redis')
      Octopusci::JobStore.stub(:redis).and_return(r)
      Octopusci::JobStore.stub(:size).and_return(2)
      r.should_receive(:lrange).with("octopusci:jobs", 0, 1)
      Octopusci::JobStore.list_job_ids(0, 2)
    end

    it "should return a list of all job ids from the first index given if count is larger than the start index to the end of the list" do
      r = mock('redis')
      Octopusci::JobStore.stub(:redis).and_return(r)
      Octopusci::JobStore.stub(:size).and_return(2)
      r.should_receive(:lrange).with("octopusci:jobs", 0, 1)
      Octopusci::JobStore.list_job_ids(0, 3423)
    end
  end

  describe "#list_repo_branch_job_ids" do
    it "should return a list of count job ids from the first index given for the provided repo and branch" do
      r = mock('redis')
      Octopusci::JobStore.stub(:redis).and_return(r)
      Octopusci::JobStore.stub(:repo_branch_size).and_return(2)
      r.should_receive(:lrange).with("octopusci:foo:bar:jobs", 0, 1)
      Octopusci::JobStore.list_repo_branch_job_ids('owner', 'foo', 'bar', 0, 2)
    end

    it "should return a list of all job ids from the first index given if count is larger than the start index to the end of the repositories branch job list" do
      r = mock('redis')
      Octopusci::JobStore.stub(:redis).and_return(r)
      Octopusci::JobStore.stub(:repo_branch_size).and_return(2)
      r.should_receive(:lrange).with("octopusci:foo:bar:jobs", 0, 1)
      Octopusci::JobStore.list_repo_branch_job_ids('owner', 'foo', 'bar', 0, 4232)
    end
  end

  describe "#list" do
    it "should get a list of all the job ids given starting index and a count" do
      Octopusci::JobStore.stub(:list_job_ids).and_return([1, 2, 3, 4, 5])
      Octopusci::JobStore.stub(:get).with(1).and_return("foo1")
      Octopusci::JobStore.stub(:get).with(2).and_return("foo2")
      Octopusci::JobStore.stub(:get).with(3).and_return("foo3")
      Octopusci::JobStore.stub(:get).with(4).and_return("foo4")
      Octopusci::JobStore.stub(:get).with(5).and_return("foo5")
      Octopusci::JobStore.list(0, 5).should == ["foo1", "foo2", "foo3", "foo4", "foo5"]
    end
  end

  describe "#list_repo_branch" do
    it "should get a list of all the job ids given starting index and a count" do
      Octopusci::JobStore.stub(:list_repo_branch_job_ids).and_return([1, 2, 3, 4, 5])
      Octopusci::JobStore.stub(:get).with(1).and_return("foo1")
      Octopusci::JobStore.stub(:get).with(2).and_return("foo2")
      Octopusci::JobStore.stub(:get).with(3).and_return("foo3")
      Octopusci::JobStore.stub(:get).with(4).and_return("foo4")
      Octopusci::JobStore.stub(:get).with(5).and_return("foo5")
      Octopusci::JobStore.list_repo_branch("owner", "foo", "bar", 0, 5).should == ["foo1", "foo2", "foo3", "foo4", "foo5"]
    end
  end

end